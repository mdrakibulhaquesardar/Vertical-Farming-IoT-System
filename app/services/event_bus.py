import asyncio
from collections import defaultdict
from typing import AsyncIterator, Dict


class DeviceEventBus:
    def __init__(self) -> None:
        self._queues: Dict[str, asyncio.Queue] = defaultdict(asyncio.Queue)

    async def publish(self, device_id: str, message: dict) -> None:
        await self._queues[device_id].put(message)

    async def subscribe(self, device_id: str) -> AsyncIterator[dict]:
        queue = self._queues[device_id]
        while True:
            data = await queue.get()
            yield data


event_bus = DeviceEventBus()
