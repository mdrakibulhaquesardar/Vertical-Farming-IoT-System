from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Float, Text, Index
from sqlalchemy.orm import relationship, Mapped, mapped_column
from datetime import datetime

from app.db.session import Base


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    email: Mapped[str] = mapped_column(String(255), unique=True, nullable=False)
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)
    role: Mapped[str] = mapped_column(String(32), default="user", nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False)

    devices: Mapped[list["Device"]] = relationship("Device", back_populates="owner")


class Device(Base):
    __tablename__ = "devices"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    device_id: Mapped[str] = mapped_column(String(128), unique=True, index=True, nullable=False)
    type: Mapped[str] = mapped_column(String(64), nullable=True)
    location: Mapped[str] = mapped_column(String(255), nullable=True)
    status: Mapped[str] = mapped_column(String(32), default="unknown", nullable=False)
    last_seen_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    owner_user_id: Mapped[int | None] = mapped_column(ForeignKey("users.id"), nullable=True)

    owner: Mapped[User | None] = relationship("User", back_populates="devices")
    sensors: Mapped[list["Sensor"]] = relationship("Sensor", back_populates="device", cascade="all, delete-orphan")


class Sensor(Base):
    __tablename__ = "sensors"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    sensor_id: Mapped[str] = mapped_column(String(128), unique=True, index=True, nullable=False)
    type: Mapped[str] = mapped_column(String(64), nullable=False)
    unit: Mapped[str | None] = mapped_column(String(32), nullable=True)
    device_id: Mapped[int] = mapped_column(ForeignKey("devices.id"), nullable=False)

    device: Mapped[Device] = relationship("Device", back_populates="sensors")
    readings: Mapped[list["SensorData"]] = relationship("SensorData", back_populates="sensor", cascade="all, delete-orphan")


class SensorData(Base):
    __tablename__ = "sensor_data"
    __table_args__ = (
        Index("ix_sensor_data_sensor_ts", "sensor_id", "ts"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    sensor_id: Mapped[int] = mapped_column(ForeignKey("sensors.id"), index=True, nullable=False)
    ts: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, index=True, nullable=False)
    value_numeric: Mapped[float | None] = mapped_column(Float, nullable=True)
    value_text: Mapped[str | None] = mapped_column(Text, nullable=True)

    sensor: Mapped[Sensor] = relationship("Sensor", back_populates="readings")


class ControlLog(Base):
    __tablename__ = "control_logs"
    __table_args__ = (
        Index("ix_control_logs_device_ts", "device_id", "ts"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    command: Mapped[str] = mapped_column(String(64), nullable=False)
    desired_state: Mapped[str | None] = mapped_column(String(64), nullable=True)
    device_id: Mapped[int] = mapped_column(ForeignKey("devices.id"), index=True, nullable=False)
    user_id: Mapped[int | None] = mapped_column(ForeignKey("users.id"), nullable=True)
    ts: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, index=True, nullable=False)
    result: Mapped[str | None] = mapped_column(String(64), nullable=True)


class Threshold(Base):
    __tablename__ = "thresholds"
    __table_args__ = (
        Index("ix_threshold_device_type", "device_id", "sensor_type", unique=True),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    device_id: Mapped[int] = mapped_column(ForeignKey("devices.id"), nullable=False)
    sensor_type: Mapped[str] = mapped_column(String(64), nullable=False)
    min_value: Mapped[float | None] = mapped_column(Float, nullable=True)
    max_value: Mapped[float | None] = mapped_column(Float, nullable=True)
    last_alerted_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
