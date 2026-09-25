package installer

import (
	"os"
	"path"

	"go.uber.org/zap"
)

type Ha struct {
	appDir    string
	configDir string
	logger    *zap.Logger
}

func NewHa(appDir string, configDir string, logger *zap.Logger) *Ha {
	return &Ha{
		appDir:    appDir,
		configDir: configDir,
		logger:    logger,
	}
}

func (h *Ha) EnsureHttpStore() error {
	target := path.Join(h.configDir, ".storage", "http")
	_, err := os.Stat(target)
	if err == nil {
		return nil
	}
	if !os.IsNotExist(err) {
		return err
	}

	seed, err := os.ReadFile(path.Join(h.appDir, "config", "default", ".storage", "http"))
	if err != nil {
		return err
	}

	err = os.MkdirAll(path.Dir(target), 0755)
	if err != nil {
		return err
	}

	h.logger.Info("seeding http config store")
	return os.WriteFile(target, seed, 0644)
}
