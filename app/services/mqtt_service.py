import asyncio
import json
from contextlib import AsyncExitStack
from datetime import datetime
from typing import AsyncIterator

import aiomqtt
from sqlalchemy.orm import Session

from app.db.session import SessionLocal
from app.models.models import Sensor, SensorData, Device


TOPIC_FILTERS = [
    "farm/+/sensor/temperature",
    "farm/+/sensor/humidity",
    "farm/+/sensor/waterflow",
    "farm/+/sensor/waterlevel",
]


def _map_payload_to_value(sensor_type: str, payload: dict) -> tuple[float | None, str | None]:
    if sensor_type == "temperature":
        return payload.get("value_c"), None
    if sensor_type == "humidity":
        return payload.get("value_pct"), None
    if sensor_type == "waterflow":
        return payload.get("l_per_min"), None
    if sensor_type == "waterlevel":
        return payload.get("cm"), None
    val = payload.get("value")
    if isinstance(val, (int, float)):
        return float(val), None
    return None, json.dumps(payload)


def _ensure_device_and_sensor(db: Session, device_id: str, sensor_type: str) -> Sensor:
    device = db.query(Device).filter(Device.device_id == device_id).first()
    if not device:
        device = Device(device_id=device_id, type=None, location=None, status="online")
        db.add(device)
        db.commit()
        db.refresh(device)
    sensor = db.query(Sensor).filter(Sensor.sensor_id == f"{device_id}-{sensor_type}").first()
    if not sensor:
        sensor = Sensor(sensor_id=f"{device_id}-{sensor_type}", type=sensor_type, unit=None, device_id=device.id)
        db.add(sensor)
        db.commit()
        db.refresh(sensor)
    return sensor


async def handle_message(topic: str, payload_bytes: bytes) -> None:
    parts = topic.split("/")
    if len(parts) < 4:
        return
    device_id = parts[1]
    sensor_type = parts[3]

    try:
        payload = json.loads(payload_bytes.decode("utf-8"))
    except Exception:
        payload = {"raw": payload_bytes.decode("utf-8", errors="ignore")}

    value_numeric, value_text = _map_payload_to_value(sensor_type, payload)

    db: Session = SessionLocal()
    try:
        sensor = _ensure_device_and_sensor(db, device_id, sensor_type)
        reading = SensorData(
            sensor_id=sensor.id,
            ts=datetime.utcnow(),
            value_numeric=value_numeric,
            value_text=value_text,
        )
        db.add(reading)
        db.commit()
    finally:
        db.close()


async def mqtt_runner(host: str, port: int) -> None:
    reconnect_interval = 5
    while True:
        try:
            async with aiomqtt.Client(hostname=host, port=port) as client:
                for tf in TOPIC_FILTERS:
                    await client.subscribe(tf, qos=1)
                async with client.messages() as messages:
                    async for message in messages:
                        asyncio.create_task(handle_message(message.topic, message.payload))
        except aiomqtt.MqttError:
            await asyncio.sleep(reconnect_interval)
