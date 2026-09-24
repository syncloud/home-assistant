Home-Assistant

## Matter

The snap runs a Matter controller (`python-matter-server`) on `127.0.0.1:5580`.

To connect Home Assistant to it, add the Matter integration
(Settings -> Devices & services -> Add integration -> Matter) and accept the
default WebSocket URL `ws://localhost:5580/ws`.

Commissioning a new Matter device over Bluetooth needs a Bluetooth adapter on
the device. Where there is none, commission with the Home Assistant companion
app or an ESPHome Bluetooth proxy.

## Thread

The snap ships an OpenThread Border Router. It needs an 802.15.4 radio
(for example Home Assistant SkyConnect or Sonoff ZBDongle-E) plugged into the
device; until one is configured the service idles and logs that it is waiting.

Point it at the radio and restart:

    echo /dev/ttyUSB0 > /var/snap/home-assistant/current/otbr/device
    snap restart home-assistant.otbr

The default baud rate is 460800. Override it with:

    echo 115200 > /var/snap/home-assistant/current/otbr/baudrate

Then add the Thread integration and point it at `http://127.0.0.1:8081`.

Thread devices also work without this border router if any commercial one
(Apple TV, HomePod, Nest Hub, Echo) is on the same network — the Matter
controller discovers it over mDNS.
