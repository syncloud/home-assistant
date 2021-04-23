from os.path import dirname, join
from subprocess import check_output

import pytest
from selenium.webdriver.support.wait import WebDriverWait
from syncloudlib.integration.hosts import add_host_alias_by_ip

DIR = dirname(__file__)
TMP_DIR = '/tmp/syncloud/ui'


@pytest.fixture(scope="session")
def module_setup(request, device, artifact_dir, ui_mode):
    def module_teardown():
        device.activated()
        device.run_ssh('mkdir -p {0}'.format(TMP_DIR), throw=False)
        device.run_ssh('journalctl > {0}/journalctl.ui.{1}.log'.format(TMP_DIR, ui_mode), throw=False)
        device.run_ssh('cp /var/log/syslog {0}/syslog.ui.{1}.log'.format(TMP_DIR, ui_mode), throw=False)
        device.scp_from_device('{0}/*'.format(TMP_DIR), join(artifact_dir, 'log'))
        check_output('chmod -R a+r {0}'.format(artifact_dir), shell=True)

    request.addfinalizer(module_teardown)


def test_start(module_setup, app, domain, device_host):
    add_host_alias_by_ip(app, domain, device_host)


def test_index(selenium):
    selenium.open_app()
    selenium.screenshot('index')


def test_login(selenium, device_user, device_password):
    selenium.driver.execute_script(
        'return document'
        '.querySelector("ha-authorize").shadowRoot'
        '.querySelector("ha-auth-flow").shadowRoot'
        '.querySelector("ha-form").shadowRoot'
        '.querySelectorAll("ha-form")[0].shadowRoot'
        '.querySelector("ha-form-string").shadowRoot'
        '.querySelector("paper-input").shadowRoot'
        '.querySelector("paper-input-container iron-input input")'
    ).send_keys(device_user)

    selenium.driver.execute_script(
        'return document'
        '.querySelector("ha-authorize").shadowRoot'
        '.querySelector("ha-auth-flow").shadowRoot'
        '.querySelector("ha-form").shadowRoot'
        '.querySelectorAll("ha-form")[1].shadowRoot'
        '.querySelector("ha-form-string").shadowRoot'
        '.querySelector("paper-input").shadowRoot'
        '.querySelector("paper-input-container iron-input input")'
    ).send_keys(device_password)
    selenium.screenshot('login-credentials')

    selenium.driver.execute_script(
        'return document'
        '.querySelector("ha-authorize").shadowRoot'
        '.querySelector("ha-auth-flow").shadowRoot'
        '.querySelector("mwc-button")'
    ).click()


def test_main(selenium):
    header = 'return document.querySelector("home-assistant").shadowRoot' \
             '.querySelector("home-assistant-main").shadowRoot' \
             '.querySelector("ha-panel-lovelace").shadowRoot' \
             '.querySelector("hui-root").shadowRoot' \
             '.querySelector("app-toolbar")' \
             '.querySelector("div")' \
             '.textContent'

    def predicate(driver):
        try:
            return driver.execute_script(header) == 'Home'
        except Exception as e:
            print(str(e))
            return False

    WebDriverWait(selenium.driver, 30).until(predicate)
    selenium.screenshot('main')