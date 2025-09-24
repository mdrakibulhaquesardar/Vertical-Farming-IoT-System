from fastapi import APIRouter

from app.api.devices import router as devices_router
from app.api.control import router as control_router
from app.api.data import router as data_router

api_router = APIRouter()


@api_router.get("/health")
def api_health():
    return {"status": "ok"}


api_router.include_router(devices_router)
api_router.include_router(control_router)
api_router.include_router(data_router)
