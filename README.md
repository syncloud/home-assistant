Home-Assistant

## Matter

The snap runs a Matter controller ([matter.js server](https://github.com/matter-js/matterjs-server)) on a unix socket at
`/var/snap/home-assistant/current/matter.socket`. It opens no TCP port.

To connect Home Assistant to it, add the Matter integration
(Settings -> Devices & services -> Add integration -> Matter) and accept the
default URL, which is already the socket path.

Commissioning over Bluetooth uses `hci0`. Devices without a Bluetooth adapter
cannot commission over Bluetooth at all; use the Home Assistant companion app
or an ESPHome Bluetooth proxy instead. After plugging an adapter in, restart:

    snap restart home-assistant.matter

## Thread

The snap ships an OpenThread Border Router. It needs an 802.15.4 radio
(for example Home Assistant SkyConnect or Sonoff ZBDongle-E) plugged into the
device; until one is configured the service idles and logs that it is waiting.

Point it at the radio and restart:

    echo /dev/ttyUSB0 > /var/snap/home-assistant/current/otbr/device
    snap restart home-assistant.otbr

The default baud rate is 460800. Override it with:

    echo 115200 > /var/snap/home-assistant/current/otbr/baudrate

Then add the Thread integration and accept the default URL, which is the
socket at `/var/snap/home-assistant/current/otbr.socket`. It opens no TCP port.

Thread devices also work without this border router if any commercial one
(Apple TV, HomePod, Nest Hub, Echo) is on the same network — the Matter
controller discovers it over mDNS.
