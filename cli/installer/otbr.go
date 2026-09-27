package installer

import (
	"os"
	"path"
)

var otbrKeys = []string{"device", "baudrate"}

type Otbr struct {
	dataDir string
	snap    *Snap
}

func NewOtbr(dataDir string, snap *Snap) *Otbr {
	return &Otbr{
		dataDir: dataDir,
		snap:    snap,
	}
}

func (o *Otbr) ApplyConfig() error {
	for _, key := range otbrKeys {
		err := writeOrRemove(path.Join(o.dataDir, "otbr", key), o.snap.Get("otbr."+key))
		if err != nil {
			return err
		}
	}
	return nil
}

func writeOrRemove(file string, value string) error {
	if value == "" {
		err := os.Remove(file)
		if err != nil && !os.IsNotExist(err) {
			return err
		}
		return nil
	}
	return os.WriteFile(file, []byte(value+"\n"), 0644)
}
