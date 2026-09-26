package installer

import (
	"os"
	"strings"
)

func RemoveTopLevelBlock(content string, key string) string {
	lines := strings.Split(content, "\n")
	var kept []string
	skipping := false

	for _, line := range lines {
		if skipping {
			trimmed := strings.TrimSpace(line)
			if trimmed == "" || line[0] == ' ' || line[0] == '\t' {
				continue
			}
			skipping = false
		}
		if strings.HasPrefix(line, key+":") {
			skipping = true
			continue
		}
		kept = append(kept, line)
	}

	return strings.Join(kept, "\n")
}

func (i *Installer) RemoveHttpYaml() error {
	configFile := i.haConfigFile
	content, err := os.ReadFile(configFile)
	if err != nil {
		if os.IsNotExist(err) {
			return nil
		}
		return err
	}

	updated := RemoveTopLevelBlock(string(content), "http")
	if updated == string(content) {
		return nil
	}

	i.logger.Info("removing deprecated http block from configuration.yaml")
	return os.WriteFile(configFile, []byte(updated), 0644)
}
