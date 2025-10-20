package installer

import (
	"fmt"
	"github.com/google/uuid"
	cp "github.com/otiai10/copy"
	"github.com/syncloud/golib/config"
	"github.com/syncloud/golib/linux"
	"github.com/syncloud/golib/platform"
	"go.uber.org/zap"

	"os"
	"path"
)

const (
	App = "home-assistant"
)

type Variables struct {
	Domain    string
	DataDir   string
	AppDir    string
	CommonDir string
	Url       string
	App       string
}

type Installer struct {
	newVersionFile     string
	currentVersionFile string
	configDir          string
	platformClient     *platform.Client
	installFile        string
	executor           *Executor
	appDir             string
	dataDir            string
	commonDir          string
	haConfigDir        string
	logger             *zap.Logger
}

func New(logger *zap.Logger) *Installer {
	appDir := fmt.Sprint("/snap/", App, "/current")
	dataDir := fmt.Sprint("/var/snap/", App, "/current")
	commonDir := fmt.Sprint("/var/snap/", App, "/common")
	configDir := path.Join(dataDir, "config")
	haConfigDir := path.Join(dataDir, "ha.config")

	executor := NewExecutor(logger)
	return &Installer{
		newVersionFile:     path.Join(appDir, "version"),
		currentVersionFile: path.Join(dataDir, "version"),
		configDir:          configDir,
		platformClient:     platform.New(),
		installFile:        path.Join(commonDir, "installed"),
		executor:           executor,
		appDir:             appDir,
		dataDir:            dataDir,
		commonDir:          commonDir,
		haConfigDir:        haConfigDir,
		logger:             logger,
	}
}

func (i *Installer) Install() error {
	err := linux.CreateUser(App)
	if err != nil {
		return err
	}

	err = i.UpdateConfigs()
	if err != nil {
		return err
	}

	err = cp.Copy(path.Join(i.configDir, "default"), i.haConfigDir)
	if err != nil {
		return err
	}
	installIdFile := path.Join(i.haConfigDir, ".install-id")
	secret := uuid.New().String()
	err = os.WriteFile(installIdFile, []byte(secret), 0644)
	if err != nil {
		return err
	}

	return nil
}

func (i *Installer) Configure() error {
	if i.IsInstalled() {
		err := i.Upgrade()
		if err != nil {
			return err
		}
	} else {
		err := i.Initialize()
		if err != nil {
			return err
		}
	}

	err := linux.CreateMissingDirs(
		path.Join(i.dataDir, "tmp"),
	)
	if err != nil {
		return err
	}

	err = i.FixPermissions()
	if err != nil {
		return err
	}

	return i.UpdateVersion()
}

func (i *Installer) IsInstalled() bool {
	_, err := os.Stat(i.installFile)
	return err == nil
}

func (i *Installer) Initialize() error {
	err := i.StorageChange()
	if err != nil {
		return err
	}
	err = i.MarkInstalled()
	if err != nil {
		return err
	}
	return nil
}

func (i *Installer) MarkInstalled() error {
	return os.WriteFile(i.installFile, []byte("installed"), 0644)
}

func (i *Installer) Upgrade() error {
	err := i.StorageChange()
	if err != nil {
		return err
	}

	return nil
}

func (i *Installer) PreRefresh() error {
	return nil
}

func (i *Installer) PostRefresh() error {
	err := i.UpdateConfigs()
	if err != nil {
		return err
	}

	err = i.ClearVersion()
	if err != nil {
		return err
	}

	err = i.FixPermissions()
	if err != nil {
		return err
	}
	return nil

}
func (i *Installer) AccessChange() error {
	err := i.UpdateConfigs()
	if err != nil {
		return err
	}

	return nil
}

func (i *Installer) StorageChange() error {
	storageDir, err := i.platformClient.InitStorage(App, App)
	if err != nil {
		return err
	}

	err = linux.Chown(storageDir, App)
	if err != nil {
		return err
	}

	return nil
}

func (i *Installer) ClearVersion() error {
	return os.RemoveAll(i.currentVersionFile)
}

func (i *Installer) UpdateVersion() error {
	return cp.Copy(i.newVersionFile, i.currentVersionFile)
}

func (i *Installer) UpdateConfigs() error {

	err := linux.CreateMissingDirs(
		path.Join(i.dataDir, "nginx"),
		path.Join(i.haConfigDir, "custom_components"),
	)
	if err != nil {
		return err
	}
	hacsLink := path.Join(i.haConfigDir, "custom_components", "hacs")
	hacsPath := path.Join(i.appDir, "custom_components", "hacs")
	_, err = os.Stat(hacsLink)
	if os.IsNotExist(err) {
		err = os.Symlink(hacsPath, hacsLink)
		if err != nil {
			return err
		}
	}

	err = i.StorageChange()
	if err != nil {
		return err
	}

	variables := Variables{
		DataDir:   i.dataDir,
		AppDir:    i.appDir,
		CommonDir: i.commonDir,
	}

	err = config.Generate(
		path.Join(i.appDir, "config"),
		path.Join(i.dataDir, "config"),
		variables,
	)
	if err != nil {
		return err
	}

	err = i.FixPermissions()
	if err != nil {
		return err
	}

	return nil

}

func (i *Installer) FixPermissions() error {
	storageDir, err := i.platformClient.InitStorage(App, App)
	if err != nil {
		return err
	}

	err = linux.Chown(i.dataDir, App)
	if err != nil {
		return err
	}
	err = linux.Chown(i.commonDir, App)
	if err != nil {
		return err
	}

	err = linux.Chown(storageDir, App)
	if err != nil {
		return err
	}

	return nil
}

func (i *Installer) BackupPreStop() error {
	return i.PreRefresh()
}

func (i *Installer) RestorePreStart() error {
	return i.PostRefresh()
}

func (i *Installer) RestorePostStart() error {
	return i.Configure()
}
