from fastapi import APIRouter, WebSocket, WebSocketDisconnect
import json

from app.services.event_bus import event_bus

router = APIRouter(prefix="/realtime", tags=["realtime"])


@router.websocket("/{device_id}")
async def ws_device_stream(websocket: WebSocket, device_id: str):
    await websocket.accept()
    try:
        async for event in event_bus.subscribe(device_id):
            await websocket.send_text(json.dumps(event))
    except WebSocketDisconnect:
        return
