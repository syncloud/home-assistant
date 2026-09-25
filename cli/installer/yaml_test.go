package installer

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestRemoveTopLevelBlockRemovesHttpAndKeepsTheRest(t *testing.T) {
	content := `default_config:

http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 127.0.0.1
    - ::1

ffmpeg:
  ffmpeg_bin: /snap/home-assistant/current/home-assistant/bin/ffmpeg
`

	result := RemoveTopLevelBlock(content, "http")

	assert.NotContains(t, result, "use_x_forwarded_for")
	assert.NotContains(t, result, "trusted_proxies")
	assert.NotContains(t, result, "127.0.0.1")
	assert.Contains(t, result, "default_config:")
	assert.Contains(t, result, "ffmpeg:")
	assert.Contains(t, result, "ffmpeg_bin: /snap/home-assistant/current/home-assistant/bin/ffmpeg")
}

func TestRemoveTopLevelBlockLeavesContentWithoutTheKeyUnchanged(t *testing.T) {
	content := `default_config:

ffmpeg:
  ffmpeg_bin: /bin/ffmpeg
`

	assert.Equal(t, content, RemoveTopLevelBlock(content, "http"))
}

func TestRemoveTopLevelBlockDoesNotMatchSimilarKeys(t *testing.T) {
	content := `http_extra:
  keep: true

https:
  keep: true
`

	result := RemoveTopLevelBlock(content, "http")

	assert.Contains(t, result, "http_extra:")
	assert.Contains(t, result, "https:")
}

func TestRemoveTopLevelBlockAtEndOfFile(t *testing.T) {
	content := `default_config:

http:
  use_x_forwarded_for: true
`

	result := RemoveTopLevelBlock(content, "http")

	assert.Contains(t, result, "default_config:")
	assert.NotContains(t, result, "use_x_forwarded_for")
}

func TestRemoveTopLevelBlockKeepsNextKeyAfterBlankLines(t *testing.T) {
	content := `http:
  use_x_forwarded_for: true


logger:
  default: info
`

	result := RemoveTopLevelBlock(content, "http")

	assert.NotContains(t, result, "use_x_forwarded_for")
	assert.Contains(t, result, "logger:")
	assert.Contains(t, result, "default: info")
}
