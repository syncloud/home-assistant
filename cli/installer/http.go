package installer

import (
	"os"
	"path"
)

func (i *Installer) EnsureHttpStore() error {
	target := path.Join(i.haConfigDir, ".storage", "http")
	_, err := os.Stat(target)
	if err == nil {
		return nil
	}
	if !os.IsNotExist(err) {
		return err
	}

	seed, err := os.ReadFile(path.Join(i.appDir, "config", "default", ".storage", "http"))
	if err != nil {
		return err
	}

	err = os.MkdirAll(path.Dir(target), 0755)
	if err != nil {
		return err
	}

	i.logger.Info("seeding http config store")
	return os.WriteFile(target, seed, 0644)
}
