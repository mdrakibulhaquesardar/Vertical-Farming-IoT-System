from fastapi import FastAPI
import asyncio
import os

from app.api.routes import api_router
from app.services.mqtt_service import mqtt_runner

app = FastAPI(title="Vertical Farming IoT Backend", version="0.1.0")


@app.on_event("startup")
async def startup_event() -> None:
    host = os.getenv("MQTT_BROKER_HOST", "localhost")
    port = int(os.getenv("MQTT_BROKER_PORT", "1883"))
    asyncio.create_task(mqtt_runner(host, port))


@app.get("/")
def read_root():
    return {"status": "ok", "service": "vertical-farm-backend"}


@app.get("/healthz")
def health_check():
    return {"status": "healthy"}


# Versioned API
app.include_router(api_router, prefix="/api/v1")
