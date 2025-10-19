from os.path import dirname, join
from subprocess import check_output

import pytest
from syncloudlib.integration.hosts import add_host_alias

from test import lib

DIR = dirname(__file__)
TMP_DIR = '/tmp/syncloud/ui'


@pytest.fixture(scope="session")
def module_setup(request, device, artifact_dir, ui_mode, driver, selenium):
    def teardown():
        device.activated()
        device.run_ssh('mkdir -p {0}'.format(TMP_DIR), throw=False)
        device.run_ssh('journalctl > {0}/journalctl.ui.{1}.log'.format(TMP_DIR, ui_mode), throw=False)
        device.run_ssh('cat /var/snap/platform/current/config/authelia/config.yml > {0}/authelia.config.ui.log'.format(TMP_DIR), throw=False)
        device.scp_from_device('{0}/*'.format(TMP_DIR), join(artifact_dir, 'log'))
        check_output('cp /videos/* {0}'.format(artifact_dir), shell=True)
        check_output('chmod -R a+r {0}'.format(artifact_dir), shell=True)
        selenium.log()

    request.addfinalizer(teardown)


def test_start(module_setup, app, domain, device_host, device):
    add_host_alias(app, device_host, domain)
    device.activated()


def test_login(selenium, device_user, device_password):
    lib.login(selenium, device_user, device_password)


def test_main(selenium):
    home = selenium.element_by_js(
        'document'
        '.querySelector("body > home-assistant").shadowRoot'
        '.querySelector("home-assistant-main").shadowRoot'
        '.querySelector("ha-drawer > partial-panel-resolver > ha-panel-lovelace").shadowRoot'
        '.querySelector("hui-root").shadowRoot'
        '.querySelector("#view > hui-view > hui-masonry-view").shadowRoot'
        '.querySelector("#columns > div > hui-card > hui-empty-state-card").shadowRoot'
        '.querySelector("ha-card").shadowRoot'
        '.querySelector("h1")')
    assert home.text == 'Welcome Home'
    selenium.screenshot('main')


def test_hacs(selenium):
    selenium.element_by_js(
        'document'
        '.querySelector("home-assistant").shadowRoot'
        '.querySelector("home-assistant-main").shadowRoot'
        '.querySelector("ha-sidebar").shadowRoot'
        '.querySelector(".configuration")'
    ).click()

    integrations = selenium.element_by_js(
        'document'
        '.querySelector("home-assistant").shadowRoot'
        '.querySelector("home-assistant-main").shadowRoot'
        '.querySelector("ha-config-dashboard").shadowRoot'
        '.querySelector("ha-config-navigation").shadowRoot'
        '.querySelector("ha-navigation-list").shadowRoot'
        '.querySelector("ha-list-item:nth-child(2)")'
    )
    assert 'Integrations' in integrations.text
    selenium.screenshot('hacs-integrations')
    integrations.click()

    add_integration = selenium.element_by_js(
        'document'
        '.querySelector("home-assistant").shadowRoot'
        '.querySelector("home-assistant-main").shadowRoot'
        '.querySelector("ha-config-integrations-dashboard").shadowRoot'
        '.querySelector("ha-fab").shadowRoot'
        '.querySelector("button")'
    )
    assert 'add integration' in add_integration.text.lower()
    add_integration.click()
    selenium.screenshot('hacs-add-integratiosn')

    search = selenium.element_by_js(
        'document'
        '.querySelector("home-assistant").shadowRoot'
        '.querySelector("dialog-add-integration").shadowRoot'
        '.querySelector("search-input").shadowRoot'
        '.querySelector("ha-textfield").shadowRoot'
        '.querySelector("input")'
    )
    search.send_keys('hacs')
    selenium.screenshot('hacs-search')

    found = selenium.element_by_js(
        'document'
        '.querySelector("home-assistant").shadowRoot'
        '.querySelector("dialog-add-integration").shadowRoot'
        '.querySelectorAll("ha-integration-list-item")'
    )

    assert len(found) == 1

    selenium.screenshot('hacs')
