package installer

import (
	"path"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestInitialized(t *testing.T) {
	tempDir := t.TempDir()

	installer := &Installer{
		installFile: path.Join(tempDir, "installer"),
	}
	assert.False(t, installer.IsInstalled())
	err := installer.MarkInstalled()
	assert.NoError(t, err)
	assert.True(t, installer.IsInstalled())
}

