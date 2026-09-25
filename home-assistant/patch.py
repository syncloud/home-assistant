import glob
import os
import sys

BUILD_DIR = sys.argv[1]


def only_match(pattern):
    matches = glob.glob(pattern)
    if len(matches) != 1:
        raise SystemExit("expected one match for {0}, got {1}".format(pattern, matches))
    return matches[0]


def patch(path, replacements):
    with open(path) as f:
        content = f.read()
    for old, new in replacements:
        if old not in content:
            raise SystemExit("pattern not found in {0}: {1!r}".format(path, old[:70]))
        content = content.replace(old, new, 1)
    with open(path, "w") as f:
        f.write(content)


connection = only_match(
    os.path.join(BUILD_DIR, "usr/local/lib/python3.*/site-packages/matter_server/client/connection.py")
)

patch(connection, [
    (
        "from aiohttp import ClientSession, ClientWebSocketResponse, WSMsgType, client_exceptions",
        "from aiohttp import (\n"
        "    ClientSession,\n"
        "    ClientWebSocketResponse,\n"
        "    UnixConnector,\n"
        "    WSMsgType,\n"
        "    client_exceptions,\n"
        ")\n"
        "\n"
        "UNIX_PREFIX = \"unix://\"",
    ),
    (
        "        self._ws_client: ClientWebSocketResponse | None = None",
        "        self._ws_client: ClientWebSocketResponse | None = None\n"
        "        self._unix_session: ClientSession | None = None",
    ),
    (
        "            self._ws_client = await self._aiohttp_session.ws_connect(\n"
        "                self.ws_server_url,",
        "            session = self._aiohttp_session\n"
        "            url = self.ws_server_url\n"
        "            if url.startswith(UNIX_PREFIX):\n"
        "                self._unix_session = ClientSession(\n"
        "                    connector=UnixConnector(path=url[len(UNIX_PREFIX):])\n"
        "                )\n"
        "                session = self._unix_session\n"
        "                url = \"ws://localhost/ws\"\n"
        "            self._ws_client = await session.ws_connect(\n"
        "                url,",
    ),
    (
        "        self._ws_client = None\n"
        "\n"
        "    async def receive_message_or_raise",
        "        self._ws_client = None\n"
        "        if self._unix_session is not None:\n"
        "            await self._unix_session.close()\n"
        "            self._unix_session = None\n"
        "\n"
        "    async def receive_message_or_raise",
    ),
])

config_flow = os.path.join(
    BUILD_DIR, "usr/src/homeassistant/homeassistant/components/matter/config_flow.py"
)

patch(config_flow, [
    (
        'DEFAULT_URL = "ws://localhost:5580/ws"',
        'DEFAULT_URL = "unix:///var/snap/home-assistant/current/matter.socket"',
    ),
])

print("patched matter client for unix socket transport")

otbr_api = only_match(
    os.path.join(BUILD_DIR, "usr/local/lib/python3.*/site-packages/python_otbr_api/__init__.py")
)

patch(otbr_api, [
    (
        "        self._session = session\n"
        "        self._url = url",
        "        if url.startswith(\"unix://\"):\n"
        "            self._session = aiohttp.ClientSession(\n"
        "                connector=aiohttp.UnixConnector(path=url[len(\"unix://\"):])\n"
        "            )\n"
        "            self._url = \"http://localhost\"\n"
        "        else:\n"
        "            self._session = session\n"
        "            self._url = url",
    ),
])

print("patched otbr client for unix socket transport")

