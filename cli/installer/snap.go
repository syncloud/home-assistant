package installer

import (
	"os/exec"
	"strings"
)

type Snap struct{}

func NewSnap() *Snap {
	return &Snap{}
}

func (s *Snap) Get(key string) string {
	out, err := exec.Command("snapctl", "get", key).Output()
	if err != nil {
		return ""
	}
	return strings.TrimSpace(string(out))
}
