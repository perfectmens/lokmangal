#!/usr/bin/env python3
"""
Auraliss OTA Update Distribution Service
Lightweight Dockerized backend for distributing Android updates, manifests, and binaries.
"""

import os
import httpx
from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse, FileResponse
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Auraliss Update Backend", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

GITHUB_OWNER = os.getenv("GITHUB_OWNER", "perfectmens")
GITHUB_REPO = os.getenv("GITHUB_REPO", "lokmangal")
GITHUB_TOKEN = os.getenv("GITHUB_TOKEN", "")

@app.get("/health")
def health():
    return {"status": "healthy", "service": "Auraliss-update-engine"}

@app.get("/api/v1/app/latest")
async def get_latest_version():
    url = f"https://api.github.com/repos/{GITHUB_OWNER}/{GITHUB_REPO}/releases/latest"
    headers = {"Accept": "application/vnd.github+json"}
    if GITHUB_TOKEN:
        headers["Authorization"] = f"Bearer {GITHUB_TOKEN}"

    async with httpx.AsyncClient() as client:
        resp = await client.get(url, headers=headers)
        if resp.status_code == 404:
            raise HTTPException(status_code=404, detail="No releases found")
        if resp.status_code != 200:
            raise HTTPException(status_code=resp.status_code, detail="Failed to fetch release")

        release = resp.json()
        version_asset = next((a for a in release.get("assets", []) if a["name"] == "version.json"), None)
        if not version_asset:
            return {
                "versionName": release.get("tag_name", "").lstrip("v"),
                "releaseNotes": release.get("body", ""),
                "publishedAt": release.get("published_at", "")
            }

        manifest_resp = await client.get(version_asset["browser_download_url"])
        if manifest_resp.status_code == 200:
            return manifest_resp.json()
        return {
            "versionName": release.get("tag_name", "").lstrip("v"),
            "downloadUrl": version_asset["browser_download_url"]
        }
