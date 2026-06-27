// Package windows provides OS-level abstractions.
package windows

import (
	"github.com/atotto/clipboard"
)

// ReadClipboard returns the current text in the clipboard.
func ReadClipboard() (string, error) {
	return clipboard.ReadAll()
}

// WriteClipboard writes text to the clipboard.
func WriteClipboard(text string) error {
	return clipboard.WriteAll(text)
}
