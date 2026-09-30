#!/usr/bin/env python3
"""
API Mapping Validator
Validates api-mapping.yaml for structure, uniqueness of IDs, methods, paths, and consumer integrity.
"""
import sys
import yaml
from pathlib import Path

def validate():
    file_path = Path("api-mapping.yaml")
    if not file_path.exists():
        print(f"❌ Error: {file_path} not found.")
        return 1

    with open(file_path, "r", encoding="utf-8") as f:
        try:
            data = yaml.safe_load(f)
        except Exception as e:
            print(f"❌ YAML parse error: {e}")
            return 1

    if not isinstance(data, dict) or "apis" not in data:
        print("❌ Error: Missing top-level 'apis' list in api-mapping.yaml")
        return 1

    apis = data["apis"]
    ids = set()
    endpoints = set()
    errors = []

    for idx, item in enumerate(apis):
        api_id = item.get("id")
        method = item.get("method")
        path = item.get("path")
        purpose = item.get("purpose")
        consumers = item.get("consumers", [])

        if not api_id:
            errors.append(f"Entry {idx}: Missing 'id'")
        elif api_id in ids:
            errors.append(f"Duplicate id '{api_id}'")
        else:
            ids.add(api_id)

        if not method or method not in ["GET", "POST", "PUT", "PATCH", "DELETE"]:
            errors.append(f"Entry '{api_id}': Invalid or missing method '{method}'")

        if not path:
            errors.append(f"Entry '{api_id}': Missing path")
        else:
            combo = (method, path)
            if combo in endpoints:
                errors.append(f"Duplicate (method, path) combination: {method} {path}")
            else:
                endpoints.add(combo)

        if not purpose:
            errors.append(f"Entry '{api_id}': Missing purpose")

        if not consumers:
            errors.append(f"Entry '{api_id}': No consumers defined")

    if errors:
        print(f"[FAIL] Validation failed with {len(errors)} error(s):")
        for err in errors:
            print(f"  - {err}")
        return 1

    print(f"[PASS] api-mapping.yaml passed validation! ({len(apis)} active API contracts verified)")
    return 0

if __name__ == "__main__":
    sys.exit(validate())
