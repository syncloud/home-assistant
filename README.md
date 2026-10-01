Home-Assistant

## Matter

Add the Matter integration and accept the default URL. Devices are commissioned
from the Home Assistant Companion app on your phone, which does the Bluetooth
part, so nothing extra is needed on this device.

## Thread

You only need this if you do not already have a Thread border router. An Apple
TV or HomePod, Nest Hub or Nest Wifi Pro, Echo or SmartThings hub is already
one, and Thread devices joined to it work with Home Assistant as they are.

To make this device a border router you need an 802.15.4 USB dongle running
OpenThread RCP firmware.

### 1. Flash the dongle

Dongles ship with Zigbee firmware and will not work as a Thread radio until
they are re-flashed. For the Sonoff ZBDongle-E use the
[Sonoff Dongle Flasher](https://dongle.sonoff.tech/sonoff-dongle-flasher/) and
pick a firmware whose description mentions Thread, OpenThread and RCP.

### 2. Point the snap at it

Find the dongle, then configure and restart:

    ls -l /dev/serial/by-id/
    snap set home-assistant otbr.device=/dev/ttyUSB0
    snap restart home-assistant.otbr
    snap logs home-assistant.otbr

The log should say `starting thread border router`. If the firmware uses a
baud rate other than 460800:

    snap set home-assistant otbr.baudrate=115200

### 3. Add the integration

Add the Thread integration and accept the default URL.

### Notes

Until a dongle is configured the `otbr` service shows as `inactive`. That is
expected: it exits cleanly rather than restarting every ten seconds on devices
that have no dongle. Once configured it stays active.

To stop using the dongle again:

    snap unset home-assistant otbr.device
    snap restart home-assistant.otbr
