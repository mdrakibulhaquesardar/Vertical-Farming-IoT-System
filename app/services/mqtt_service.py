import asyncio
import json
import logging
from contextlib import AsyncExitStack
from datetime import datetime
from typing import AsyncIterator

import aiomqtt
from sqlalchemy.orm import Session

from app.db.session import SessionLocal
from app.models.models import Sensor, SensorData, Device, Threshold
from app.services.event_bus import event_bus

logger = logging.getLogger(__name__)

TOPIC_FILTERS = [
    "farm/+/sensor/temperature",
    "farm/+/sensor/humidity",
    "farm/+/sensor/waterflow",
    "farm/+/sensor/waterlevel",
    "farm/+/sensor/tds",
    "farm/+/status",
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
    if sensor_type == "tds":
        return payload.get("ppm"), None
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


async def handle_message(topic, payload_bytes: bytes) -> None:
    topic_str = getattr(topic, "value", None) or str(topic)
    parts = topic_str.split("/")
    if len(parts) < 3:
        return
    device_id = parts[1]
    
    # Handle status messages (farm/device_id/status)
    if len(parts) == 3 and parts[2] == "status":
        try:
            payload = json.loads(payload_bytes.decode("utf-8"))
            # Publish status directly to WebSocket
            await event_bus.publish(device_id, {
                "type": "status",
                "device_id": device_id,
                "data": payload,
                "ts": datetime.utcnow().isoformat()
            })
            logger.info("published status message", extra={"device_id": device_id, "payload": payload})
        except Exception as e:
            logger.error("failed to process status message", extra={"device_id": device_id, "error": str(e)})
        return
    
    # Handle sensor messages (farm/device_id/sensor/type)
    if len(parts) < 4:
        return
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
        logger.info("ingested mqtt message", extra={"device_id": device_id, "sensor": sensor.sensor_id, "type": sensor.type, "value_numeric": value_numeric})

        # publish to event bus for websocket listeners
        ws_message = {
            "device_id": device_id,
            "sensor_id": sensor.sensor_id,
            "type": sensor.type,
            "ts": reading.ts.isoformat(),
            "value_numeric": value_numeric,
            "value_text": value_text,
        }
        # Enrich waterflow with additional metrics if present in payload
        if sensor.type == "waterflow" and isinstance(payload, dict):
            extra_keys = ("total_liters", "avg_l_per_min", "pulses")
            for k in extra_keys:
                if k in payload:
                    ws_message[k] = payload[k]
        await event_bus.publish(device_id, ws_message)

        # Threshold check and alert
        if value_numeric is not None:
            thr = (
                db.query(Threshold)
                .filter(Threshold.device_id == sensor.device_id, Threshold.sensor_type == sensor.type)
                .first()
            )
            breached = False
            reason = None
            if thr:
                if thr.min_value is not None and value_numeric < thr.min_value:
                    breached = True
                    reason = "below_min"
                if thr.max_value is not None and value_numeric > thr.max_value:
                    breached = True
                    reason = "above_max"
            if breached:
                alert = {
                    "device_id": device_id,
                    "sensor_id": sensor.sensor_id,
                    "type": sensor.type,
                    "ts": reading.ts.isoformat(),
                    "value": value_numeric,
                    "reason": reason,
                }
                await event_bus.publish(device_id, {"alert": alert})
                # Also publish to MQTT alert topic (non-retained)
                try:
                    async with aiomqtt.Client(hostname="mosquitto", port=1883) as client:
                        await client.publish(f"farm/{device_id}/alert/{sensor.type}", json.dumps(alert).encode("utf-8"), qos=1, retain=False)
                except Exception:
                    logger.warning("failed to publish alert mqtt", extra=alert)
    finally:
        db.close()


async def mqtt_runner(host: str, port: int) -> None:
    reconnect_interval = 5
    while True:
        try:
            logger.info("mqtt connecting", extra={"host": host, "port": port})
            async with aiomqtt.Client(hostname=host, port=port) as client:
                for tf in TOPIC_FILTERS:
                    await client.subscribe(tf, qos=1)
                    logger.info("mqtt subscribed", extra={"topic": tf})
                async with client.messages() as messages:
                    async for message in messages:
                        asyncio.create_task(handle_message(message.topic, message.payload))
        except aiomqtt.MqttError:
            logger.warning("mqtt disconnected, retrying", extra={"sleep_s": reconnect_interval})
            await asyncio.sleep(reconnect_interval)
