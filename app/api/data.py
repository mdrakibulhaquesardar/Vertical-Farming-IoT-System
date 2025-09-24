from datetime import datetime
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select, desc
from sqlalchemy.orm import Session

from app.db.deps import get_db
from app.models.models import Device, Sensor, SensorData

router = APIRouter(prefix="/data", tags=["data"])


@router.get("/latest/{device_id}")
def latest_by_device(device_id: str, db: Session = Depends(get_db)):
    device = db.query(Device).filter(Device.device_id == device_id).first()
    if not device:
        raise HTTPException(status_code=404, detail="Device not found")

    sensors = db.query(Sensor).filter(Sensor.device_id == device.id).all()
    result = {"device_id": device_id, "latest": []}
    for s in sensors:
        row = (
            db.query(SensorData)
            .filter(SensorData.sensor_id == s.id)
            .order_by(SensorData.ts.desc())
            .first()
        )
        if row:
            result["latest"].append(
                {
                    "sensor_id": s.sensor_id,
                    "type": s.type,
                    "ts": row.ts,
                    "value_numeric": row.value_numeric,
                    "value_text": row.value_text,
                }
            )
    return result


@router.get("/history/{sensor_id}")
def history_by_sensor(
    sensor_id: str,
    db: Session = Depends(get_db),
    limit: int = Query(100, ge=1, le=1000),
    before: Optional[datetime] = None,
):
    sensor = db.query(Sensor).filter(Sensor.sensor_id == sensor_id).first()
    if not sensor:
        raise HTTPException(status_code=404, detail="Sensor not found")

    q = db.query(SensorData).filter(SensorData.sensor_id == sensor.id)
    if before:
        q = q.filter(SensorData.ts < before)
    q = q.order_by(SensorData.ts.desc()).limit(limit)

    rows = q.all()
    return {
        "sensor_id": sensor_id,
        "count": len(rows),
        "data": [
            {
                "ts": r.ts,
                "value_numeric": r.value_numeric,
                "value_text": r.value_text,
            }
            for r in rows
        ],
    }
