from datetime import datetime
from typing import Any


def rpad(value: Any, width: int) -> str:
    return str(value)[:width].rjust(width)


def lpad(value: Any, width: int) -> str:
    return str(value)[:width].ljust(width)


class Spot:
    def __init__(self, spot: dict[str, Any]):
        self.callsign = spot["activator"]
        self.frequency = float(spot["frequency"])
        self.grid = spot["grid4"]
        self.mode = spot["mode"]
        self.name = spot["name"]
        self.reference = spot["reference"]
        self.id = spot["spotId"]
        self.spotter = spot["spotter"]
        self.timestamp = datetime.fromisoformat(spot["spotTime"])

    def __str__(self):
        notes = ", ".join(filter(lambda x: x, [self.mode, self.reference]))
        return f"{lpad(self.spotter, 10)} {rpad(self.frequency, 8)} {self.callsign.ljust(12)} {lpad(notes, 30)} {self.timestamp.strftime('%H%MZ')} {self.grid}"

    @property
    def dxspider_output(self) -> str:
        notes = ", ".join(filter(lambda x: x, [self.mode, self.reference]))
        return f"{rpad(self.frequency, 9)} {self.callsign.ljust(11)} {rpad(self.timestamp.strftime('%d-%b-%Y'), 11)} {self.timestamp.strftime('%H%MZ')} {lpad(notes, 25)} {rpad('<' + self.spotter + '>', 10)}"
