from datetime import datetime
import json
import os

from fastapi import APIRouter, Depends, HTTPException, status
import aiomqtt

from app.schemas.control import ControlRequest, ControlResponse

router = APIRouter(prefix="/control", tags=["control"])


@router.post("/{device_id}", response_model=ControlResponse, status_code=status.HTTP_202_ACCEPTED)
async def send_control(device_id: str, body: ControlRequest):
    host = os.getenv("MQTT_BROKER_HOST", "localhost")
    port = int(os.getenv("MQTT_BROKER_PORT", "1883"))

    # Handle status request differently
    if body.target == "status" and body.desired_state == "request":
        # Send status request to ESP32
        topic = f"farm/{device_id}/status/request"
        payload = json.dumps({
            "command": "status_request",
            "ts": int(datetime.utcnow().timestamp() * 1000),
            "issued_by": "api",
        })
    else:
        # Regular control command
        topic = f"farm/{device_id}/control/{body.target}"
        payload = json.dumps({
            "command": body.target,
            "desired_state": body.desired_state,
            "ts": int(datetime.utcnow().timestamp() * 1000),
            "issued_by": "api",  # placeholder; wire auth later
        })

    try:
        async with aiomqtt.Client(hostname=host, port=port) as client:
            await client.publish(topic, payload.encode("utf-8"), qos=1, retain=True)
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"MQTT publish failed: {e}")

    return ControlResponse(
        device_id=device_id,
        target=body.target,
        desired_state=body.desired_state,
        published_at=datetime.utcnow(),
    )
