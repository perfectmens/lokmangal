FROM python:3.11-slim

WORKDIR /app

RUN pip install --no-cache-dir fastapi uvicorn httpx

COPY update_server.py /app/update_server.py

EXPOSE 8080

CMD ["uvicorn", "update_server:app", "--host", "0.0.0.0", "--port", "8080"]
