package installer

import (
	"os"
	"path"
	"testing"

	"github.com/stretchr/testify/assert"
	"go.uber.org/zap"
)

func TestEnsureHttpStoreSeedsWhenMissing(t *testing.T) {
	ha, haConfigDir := newTestHa(t)

	assert.NoError(t, ha.EnsureHttpStore())

	content, err := os.ReadFile(path.Join(haConfigDir, ".storage", "http"))
	assert.NoError(t, err)
	assert.Equal(t, `{"seeded":true}`, string(content))
}
func TestEnsureHttpStoreKeepsExisting(t *testing.T) {
	ha, haConfigDir := newTestHa(t)

	storage := path.Join(haConfigDir, ".storage")
	assert.NoError(t, os.MkdirAll(storage, 0755))
	assert.NoError(t, os.WriteFile(path.Join(storage, "http"), []byte(`{"existing":true}`), 0644))

	assert.NoError(t, ha.EnsureHttpStore())

	content, err := os.ReadFile(path.Join(storage, "http"))
	assert.NoError(t, err)
	assert.Equal(t, `{"existing":true}`, string(content))
}
func newTestHa(t *testing.T) (*Ha, string) {
	root := t.TempDir()
	appDir := path.Join(root, "app")
	haConfigDir := path.Join(root, "ha.config")

	seedDir := path.Join(appDir, "config", "default", ".storage")
	assert.NoError(t, os.MkdirAll(seedDir, 0755))
	assert.NoError(t, os.WriteFile(path.Join(seedDir, "http"), []byte(`{"seeded":true}`), 0644))
	assert.NoError(t, os.MkdirAll(haConfigDir, 0755))

	return NewHa(appDir, haConfigDir, zap.NewNop()), haConfigDir
}
