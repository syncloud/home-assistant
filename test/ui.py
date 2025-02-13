from os.path import dirname, join
from subprocess import check_output

import pytest
from syncloudlib.integration.hosts import add_host_alias

from test import lib

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
