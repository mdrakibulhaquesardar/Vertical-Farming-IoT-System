from datetime import datetime
from pydantic import BaseModel, Field


class ControlRequest(BaseModel):
    target: str = Field(..., pattern="^(motor|light|relay)$")
    desired_state: str = Field(..., pattern="^(on|off)$")


class ControlResponse(BaseModel):
    device_id: str
    target: str
    desired_state: str
    published_at: datetime
