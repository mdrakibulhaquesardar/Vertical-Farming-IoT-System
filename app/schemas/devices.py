from datetime import datetime
from pydantic import BaseModel, Field


class DeviceBase(BaseModel):
    device_id: str = Field(..., min_length=1, max_length=128)
    type: str | None = Field(default=None, max_length=64)
    location: str | None = Field(default=None, max_length=255)


class DeviceCreate(DeviceBase):
    pass


class SensorBase(BaseModel):
    sensor_id: str = Field(..., min_length=1, max_length=128)
    type: str = Field(..., min_length=1, max_length=64)
    unit: str | None = Field(default=None, max_length=32)


class SensorCreate(SensorBase):
    device_id: int


class SensorRead(SensorBase):
    id: int
    device_id: int

    class Config:
        from_attributes = True


class DeviceRead(DeviceBase):
    id: int
    status: str
    last_seen_at: datetime | None
    sensors: list[SensorRead] = []

    class Config:
        from_attributes = True
