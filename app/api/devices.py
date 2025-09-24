from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, joinedload

from app.db.deps import get_db
from app.models.models import Device, Sensor
from app.schemas.devices import DeviceCreate, DeviceRead, SensorCreate, SensorRead

router = APIRouter(prefix="/devices", tags=["devices"])


@router.post("/register", response_model=DeviceRead, status_code=status.HTTP_201_CREATED)
def register_device(payload: DeviceCreate, db: Session = Depends(get_db)):
    existing = db.query(Device).options(joinedload(Device.sensors)).filter(Device.device_id == payload.device_id).first()
    if existing:
        return existing
    device = Device(device_id=payload.device_id, type=payload.type, location=payload.location, status="online")
    db.add(device)
    db.commit()
    db.refresh(device)
    return device


@router.get("/", response_model=list[DeviceRead])
def list_devices(db: Session = Depends(get_db)):
    devices = db.query(Device).options(joinedload(Device.sensors)).order_by(Device.id.desc()).all()
    return devices


@router.post("/{device_id}/sensors", response_model=SensorRead, status_code=status.HTTP_201_CREATED)
def add_sensor(device_id: str, payload: SensorCreate, db: Session = Depends(get_db)):
    device = db.query(Device).filter(Device.device_id == device_id).first()
    if not device:
        raise HTTPException(status_code=404, detail="Device not found")
    existing = db.query(Sensor).filter(Sensor.sensor_id == payload.sensor_id).first()
    if existing:
        return existing
    sensor = Sensor(sensor_id=payload.sensor_id, type=payload.type, unit=payload.unit, device_id=device.id)
    db.add(sensor)
    db.commit()
    db.refresh(sensor)
    return sensor
