import sys
import json
import machine


sys.path.append("")

from micropython import const
from machine import Pin

import uasyncio as asyncio
import aioble
import bluetooth
import utime

_PROX_SENSE_UUID = bluetooth.UUID(0x181C)
_PROX_SENSE_TEMP_UUID = bluetooth.UUID(0x2B99)
_ADV_APPEARANCE_GENERIC_PROXIMITY_SENSOR = const(0x0551)

# How frequently to send advertising beacons.
_ADV_INTERVAL_MS = 250_000


# Register GATT server.
prox_service = aioble.Service(_PROX_SENSE_UUID)
prox_characteristic = aioble.Characteristic(
    prox_service, _PROX_SENSE_TEMP_UUID, read=True, notify=True
)
aioble.register_services(prox_service)

trigger = Pin(26, Pin.OUT)
echo = Pin(27, Pin.IN)

def _ultra():
    trigger.low()
    utime.sleep_us(2)
    trigger.high()
    utime.sleep_us(5)
    trigger.low()
    while echo.value() == 0:
        signaloff = utime.ticks_us()
    while echo.value() == 1:
        signalon = utime.ticks_us()
    timepassed = signalon - signaloff
    distance = (timepassed * 0.0343) / 2
    print("The distance from object is ", distance, "cm")
    return distance

# This would be periodically polling a hardware sensor.
async def sensor_task():
    while True:
        data = f'{_ultra()}'
        print(data)
        prox_characteristic.write(data, send_update=True)
        await asyncio.sleep_ms(2000)


# Serially wait for connections. Don't advertise while a central is
# connected.
async def peripheral_task():
    while True:
        async with await aioble.advertise(
            _ADV_INTERVAL_MS,
            name="mpy-prox_sensor",
            services=[_PROX_SENSE_UUID],
            appearance=_ADV_APPEARANCE_GENERIC_PROXIMITY_SENSOR,
        ) as connection:
            print("Connection from", connection.device)
            await connection.disconnected()


# Run both tasks.
async def main():
    t1 = asyncio.create_task(sensor_task())
    t2 = asyncio.create_task(peripheral_task())
    await asyncio.gather(t1, t2)


asyncio.run(main())