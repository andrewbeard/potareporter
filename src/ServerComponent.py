import logging

import anyio
from anyio.abc import SocketStream
from asphalt.core import Component, current_context, run_application

from NewSpotEventSource import NewSpotEventSource
from Spot import Spot


async def handle_client(stream: SocketStream) -> None:
    await stream.send("Welcome to POTA Reporter\n".encode())
    spots = await current_context().request_resource(dict[str, Spot], "spots")
    assert spots is not None
    new_spots = await current_context().request_resource(list[Spot], "new_spots")
    assert new_spots is not None

    event_source = await current_context().request_resource(
        NewSpotEventSource, "new_spot_event_source"
    )
    assert event_source is not None

    for spot in spots.values():
        await stream.send(f"{str(spot)}\n".encode())

    while True:
        await event_source.signal.wait_event()
        for spot in new_spots:
            await stream.send(f"{str(spot)}\n".encode())


async def serve_requests() -> None:
    async with await anyio.create_tcp_listener(
        local_host="0.0.0.0", local_port=7373
    ) as listener:
        logging.info("Server started on 0.0.0.0:7373")
        await listener.serve(handle_client)


class ServerComponent(Component):
    def __init__(self):
        self.task_group = None

    async def start(self, ctx) -> None:
        self.task_group = anyio.create_task_group()
        await self.task_group.__aenter__()
        self.task_group.start_soon(serve_requests)

    async def stop(self) -> None:
        if self.task_group:
            await self.task_group.__aexit__(None, None, None)


if __name__ == "__main__":
    run_application(ServerComponent())
