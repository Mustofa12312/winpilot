// Package windows provides OS-level abstractions for WinPilot.
package windows

import (
	"fmt"
	"io"
	"io/fs"
	"os"
	"path/filepath"
	"strings"
	"time"
)

// FileInfo represents a file or directory in the file system.
type FileInfo struct {
	Name         string    `json:"name"`
	Path         string    `json:"path"`
	IsDirectory  bool      `json:"is_dir"`
	Size         int64     `json:"size"`
	Extension    string    `json:"extension"`
	ModifiedAt   time.Time `json:"modified_at"`
	IsHidden     bool      `json:"is_hidden"`
}

// ListDirectory returns the contents of a directory.
func ListDirectory(path string) ([]FileInfo, error) {
	if path == "" {
		// Default to C:\ on Windows or / on Linux
		path = "/" // Using / as fallback for Linux dev environment
	}

	entries, err := os.ReadDir(path)
	if err != nil {
		return nil, fmt.Errorf("list directory: %w", err)
	}

	var files []FileInfo
	for _, entry := range entries {
		info, err := entry.Info()
		if err != nil {
			continue // skip if we can't get info
		}

		isHidden := strings.HasPrefix(entry.Name(), ".")
		
		ext := ""
		if !entry.IsDir() {
			ext = strings.ToLower(filepath.Ext(entry.Name()))
		}

		files = append(files, FileInfo{
			Name:        entry.Name(),
			Path:        filepath.Join(path, entry.Name()),
			IsDirectory: entry.IsDir(),
			Size:        info.Size(),
			Extension:   ext,
			ModifiedAt:  info.ModTime(),
			IsHidden:    isHidden,
		})
	}

	return files, nil
}

// RenameFile renames or moves a file.
func RenameFile(oldPath, newPath string) error {
	return os.Rename(oldPath, newPath)
}

// DeleteFile deletes a file or directory.
func DeleteFile(path string) error {
	return os.RemoveAll(path)
}

// CreateDirectory creates a new directory.
func CreateDirectory(path string) error {
	return os.MkdirAll(path, 0755)
}

// GetFileStream returns a reader for a file.
func GetFileStream(path string) (io.ReadCloser, int64, error) {
	file, err := os.Open(path)
	if err != nil {
		return nil, 0, err
	}

	info, err := file.Stat()
	if err != nil {
		file.Close()
		return nil, 0, err
	}

	return file, info.Size(), nil
}

// SaveFileStream saves a stream to a file.
func SaveFileStream(path string, stream io.Reader) error {
	if err := os.MkdirAll(filepath.Dir(path), 0755); err != nil {
		return err
	}

	file, err := os.OpenFile(path, os.O_CREATE|os.O_WRONLY|os.O_TRUNC, 0644)
	if err != nil {
		return err
	}
	defer file.Close()

	_, err = io.Copy(file, stream)
	return err
}
