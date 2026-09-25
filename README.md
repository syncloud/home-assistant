Home-Assistant

## Matter

Add the Matter integration and accept the default URL. Devices are commissioned
from the Home Assistant Companion app on your phone, which does the Bluetooth
part, so nothing extra is needed on this device.

## Thread

You only need this if you do not already have a Thread border router. An Apple
TV or HomePod, Nest Hub or Nest Wifi Pro, Echo or SmartThings hub is already
one, and Thread devices joined to it work with Home Assistant as they are.

To make this device a border router instead, plug in an 802.15.4 USB dongle
(for example Home Assistant SkyConnect or Sonoff ZBDongle-E), point the snap at
it and restart:

    snap set home-assistant otbr.device=/dev/ttyUSB0
    snap restart home-assistant.otbr

Then add the Thread integration and accept the default URL. If your dongle
needs a baud rate other than 460800:

    snap set home-assistant otbr.baudrate=115200

To stop using the dongle again:

    snap unset home-assistant otbr.device
    snap restart home-assistant.otbr
