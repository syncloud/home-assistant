from pathlib import Path

import hass_web_proxy_lib

DOMAIN = "deps_check"


async def async_setup(hass, config):
    marker = Path(hass.config.path("deps_check.ok"))
    await hass.async_add_executor_job(marker.write_text, hass_web_proxy_lib.__name__)
    return True
