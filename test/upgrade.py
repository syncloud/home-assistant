import pytest
from subprocess import check_output
from syncloudlib.integration.hosts import add_host_alias
from test import lib
from syncloudlib.integration.installer import local_install, wait_for_installer
from syncloudlib.http import wait_for_rest
import requests
TMP_DIR = '/tmp/syncloud'


@pytest.fixture(scope="session")
def module_setup(request, device, artifact_dir):
    def module_teardown():
        device.run_ssh('journalctl > {0}/refresh.journalctl.log'.format(TMP_DIR), throw=False)
        device.scp_from_device('{0}/*'.format(TMP_DIR), artifact_dir)
        check_output('cp /videos/* {0}'.format(artifact_dir), shell=True)
        check_output('chmod -R a+r {0}'.format(artifact_dir), shell=True)

    request.addfinalizer(module_teardown)


def test_start(module_setup, app, device_host, domain, device):
    add_host_alias(app, device_host, domain)
    device.activated()
    device.run_ssh('rm -rf {0}'.format(TMP_DIR), throw=False)
    device.run_ssh('mkdir {0}'.format(TMP_DIR), throw=False)


def test_upgrade(device, device_user, device_password, device_host, app_archive_path, app_domain, app_dir):
    device.run_ssh('snap remove home-assistant')
    device.run_ssh('snap install home-assistant')
    local_install(device_host, device_password, app_archive_path)
    wait_for_rest(requests.session(), "https://{0}".format(app_domain), 200, 10)

def test_login(selenium, device_user, device_password):
    lib.login(selenium, device_user, device_password)
