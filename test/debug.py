import os
from os.path import dirname, join, exists

from selenium import webdriver
from syncloudlib.integration.selenium_wrapper import SeleniumWrapper

from test.ui import *

DIR = dirname(__file__)


def test():
    # sudo docker network create --ipv6 --subnet 2001:0DB8::/112 ip6net
    # sudo docker run -d --name chrome --network ip6net -p 4444:4444 -p 5900:5900 -p 7900:7900 --shm-size="2g" selenium/standalone-chrome:4.21.0-20240517
    # firefox http://localhost:7900
    # password: secret
    # pytest -p no:[path]/test/conftest.py

    options = webdriver.ChromeOptions()
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.set_capability('goog:loggingPrefs', {'performance': 'ALL'})
    options.set_capability('acceptInsecureCerts', True)
    driver = webdriver.Remote(options=options)
    driver.maximize_window()
    screenshot_dir = join(DIR, "artifact")
    if not exists(screenshot_dir):
        os.mkdir(screenshot_dir)

    selenium = SeleniumWrapper(
        driver,
        "desktop",
        screenshot_dir,
        "home-assistant.borisarm64.syncloud.it",
        2,
        "chrome"
    )

    try:
        test_login(selenium, "test", "test1234")
        test_main(selenium)
    finally:
        print()
        selenium.log()
        driver.quit()
