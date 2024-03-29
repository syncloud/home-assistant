import logging
import os
from os.path import join, isfile
import shutil

from syncloudlib import fs, linux, gen, logger
from syncloudlib.application import paths, storage
import uuid

APP_NAME = 'home-assistant'
USER_NAME = APP_NAME


class Installer:
    def __init__(self):
        if not logger.factory_instance:
            logger.init(logging.DEBUG, True)

        self.log = logger.get_logger('{0}_installer'.format(APP_NAME))
        self.app_dir = paths.get_app_dir(APP_NAME)
        self.common_dir = paths.get_data_dir(APP_NAME)
        self.snap_data_dir = os.environ['SNAP_DATA']
        self.config_dir = join(self.snap_data_dir, 'config')
        self.ha_config_dir = join(self.snap_data_dir, 'ha.config')

    def install_config(self):

        home_folder = join(self.common_dir, USER_NAME)
        linux.useradd(USER_NAME, home_folder=home_folder)
        
        fs.makepath(join(self.common_dir, 'log'))
        fs.makepath(join(self.common_dir, 'nginx'))

        storage.init_storage(APP_NAME, USER_NAME)

        templates_path = join(self.app_dir, 'config')

        variables = {
            'app': APP_NAME,
            'app_dir': self.app_dir,
            'common_dir': self.common_dir,
            'snap_data': self.snap_data_dir
        }
        gen.generate_files(templates_path, self.config_dir, variables)
        fs.chownpath(self.snap_data_dir, USER_NAME, recursive=True)
        fs.chownpath(self.common_dir, USER_NAME, recursive=True)

    def install(self):
        self.install_config()
        shutil.copytree(join(self.config_dir, 'default'), self.ha_config_dir)
        fs.chownpath(self.ha_config_dir, USER_NAME, recursive=True)
        install_id_file = join(self.ha_config_dir, '.install-id')
        with open(install_id_file, 'w') as the_file:
            the_file.write(str(uuid.uuid4()))

    def refresh(self):
        self.install_config()
        shutil.copy(join(self.config_dir, 'default/configuration.yaml'), self.ha_config_dir)

    def configure(self):
        self.prepare_storage()
        install_file = join(self.common_dir, 'installed')
        if not isfile(install_file):
            fs.touchfile(install_file)
        # else:
            # upgrade
    
    def on_disk_change(self):
        self.prepare_storage()
        
    def prepare_storage(self):
        app_storage_dir = storage.init_storage(APP_NAME, USER_NAME)
