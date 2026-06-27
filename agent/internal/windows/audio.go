// Package windows provides OS-level abstractions.
package windows

import (
	"github.com/itchyny/volume-go"
)

// GetVolume returns the current volume percentage (0-100) and mute status.
func GetVolume() (int, bool, error) {
	vol, err := volume.GetVolume()
	if err != nil {
		return 0, false, err
	}

	muted, err := volume.GetMuted()
	if err != nil {
		return vol, false, err
	}

	return vol, muted, nil
}

// SetVolume sets the volume percentage (0-100).
func SetVolume(vol int) error {
	if vol < 0 {
		vol = 0
	}
	if vol > 100 {
		vol = 100
	}
	return volume.SetVolume(vol)
}

// SetMuted sets the mute status.
func SetMuted(muted bool) error {
	if muted {
		return volume.Mute()
	}
	return volume.Unmute()
}
