from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from app.db.deps import get_db
from app.models.models import Device, Threshold

router = APIRouter(prefix="/thresholds", tags=["thresholds"])


class ThresholdPayload(BaseModel):
    sensor_type: str = Field(..., min_length=1, max_length=64)
    min_value: float | None = None
    max_value: float | None = None


@router.put("/{device_id}")
def upsert_threshold(device_id: str, payload: ThresholdPayload, db: Session = Depends(get_db)):
    device = db.query(Device).filter(Device.device_id == device_id).first()
    if not device:
        raise HTTPException(status_code=404, detail="Device not found")
    item = (
        db.query(Threshold)
        .filter(Threshold.device_id == device.id, Threshold.sensor_type == payload.sensor_type)
        .first()
    )
    if not item:
        item = Threshold(
            device_id=device.id,
            sensor_type=payload.sensor_type,
            min_value=payload.min_value,
            max_value=payload.max_value,
        )
        db.add(item)
    else:
        item.min_value = payload.min_value
        item.max_value = payload.max_value
    db.commit()
    db.refresh(item)
    return {
        "device_id": device_id,
        "sensor_type": item.sensor_type,
        "min_value": item.min_value,
        "max_value": item.max_value,
    }


@router.get("/{device_id}")
def list_thresholds(device_id: str, db: Session = Depends(get_db)):
    device = db.query(Device).filter(Device.device_id == device_id).first()
    if not device:
        raise HTTPException(status_code=404, detail="Device not found")
    rows = db.query(Threshold).filter(Threshold.device_id == device.id).all()
    return [
        {
            "sensor_type": r.sensor_type,
            "min_value": r.min_value,
            "max_value": r.max_value,
        }
        for r in rows
    ]
