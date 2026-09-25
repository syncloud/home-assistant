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
(for example Home Assistant SkyConnect or Sonoff ZBDongle-E), point the service
at it and restart:

    echo /dev/ttyUSB0 > /var/snap/home-assistant/current/otbr/device
    snap restart home-assistant.otbr

Then add the Thread integration and accept the default URL. If your dongle
needs a baud rate other than 460800:

    echo 115200 > /var/snap/home-assistant/current/otbr/baudrate
