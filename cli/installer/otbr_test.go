package installer

import (
	"os"
	"path"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestWriteOrRemoveWritesValue(t *testing.T) {
	file := path.Join(t.TempDir(), "device")

	assert.NoError(t, writeOrRemove(file, "/dev/ttyUSB0"))

	content, err := os.ReadFile(file)
	assert.NoError(t, err)
	assert.Equal(t, "/dev/ttyUSB0\n", string(content))
}
func TestWriteOrRemoveDeletesOnEmpty(t *testing.T) {
	file := path.Join(t.TempDir(), "device")
	assert.NoError(t, os.WriteFile(file, []byte("/dev/ttyUSB0\n"), 0644))

	assert.NoError(t, writeOrRemove(file, ""))

	_, err := os.Stat(file)
	assert.True(t, os.IsNotExist(err))
}
func TestWriteOrRemoveEmptyOnMissingFileIsNotAnError(t *testing.T) {
	assert.NoError(t, writeOrRemove(path.Join(t.TempDir(), "device"), ""))
}
func TestWriteOrRemoveOverwrites(t *testing.T) {
	file := path.Join(t.TempDir(), "baudrate")
	assert.NoError(t, writeOrRemove(file, "460800"))

	assert.NoError(t, writeOrRemove(file, "115200"))

	content, err := os.ReadFile(file)
	assert.NoError(t, err)
	assert.Equal(t, "115200\n", string(content))
}
