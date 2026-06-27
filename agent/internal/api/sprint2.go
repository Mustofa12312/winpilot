package api

import (
	"fmt"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/winpilot/agent/internal/windows"
)

// ─────────────────────────────────────────────────────────────────────────────
// Files
// ─────────────────────────────────────────────────────────────────────────────

func (s *Server) handleListFiles(c *gin.Context) {
	path := c.Query("path")
	files, err := windows.ListDirectory(path)
	if err != nil {
		fail(c, http.StatusInternalServerError, err.Error())
		return
	}
	success(c, files)
}

func (s *Server) handleDownloadFile(c *gin.Context) {
	path := c.Query("path")
	if path == "" {
		fail(c, http.StatusBadRequest, "path required")
		return
	}

	stream, size, err := windows.GetFileStream(path)
	if err != nil {
		fail(c, http.StatusInternalServerError, err.Error())
		return
	}
	defer stream.Close()

	c.Header("Content-Length", strconv.FormatInt(size, 10))
	c.Header("Content-Disposition", fmt.Sprintf("attachment; filename=%q", path))
	c.DataFromReader(http.StatusOK, size, "application/octet-stream", stream, nil)
}

func (s *Server) handleUploadFile(c *gin.Context) {
	path := c.Query("path")
	if path == "" {
		fail(c, http.StatusBadRequest, "path required")
		return
	}

	file, err := c.FormFile("file")
	if err != nil {
		fail(c, http.StatusBadRequest, "no file uploaded")
		return
	}

	src, err := file.Open()
	if err != nil {
		fail(c, http.StatusInternalServerError, err.Error())
		return
	}
	defer src.Close()

	if err := windows.SaveFileStream(path, src); err != nil {
		fail(c, http.StatusInternalServerError, err.Error())
		return
	}

	success(c, gin.H{"message": "File uploaded successfully"})
}

func (s *Server) handleFileAction(c *gin.Context) {
	var req struct {
		Action  string `json:"action"` // rename, move, delete, mkdir
		OldPath string `json:"old_path"`
		NewPath string `json:"new_path"`
		Path    string `json:"path"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		fail(c, http.StatusBadRequest, err.Error())
		return
	}

	switch req.Action {
	case "rename", "move":
		if err := windows.RenameFile(req.OldPath, req.NewPath); err != nil {
			fail(c, http.StatusInternalServerError, err.Error())
			return
		}
	case "delete":
		if err := windows.DeleteFile(req.Path); err != nil {
			fail(c, http.StatusInternalServerError, err.Error())
			return
		}
	case "mkdir":
		if err := windows.CreateDirectory(req.Path); err != nil {
			fail(c, http.StatusInternalServerError, err.Error())
			return
		}
	default:
		fail(c, http.StatusBadRequest, "invalid action")
		return
	}

	success(c, gin.H{"message": "Action completed successfully"})
}

// ─────────────────────────────────────────────────────────────────────────────
// Clipboard
// ─────────────────────────────────────────────────────────────────────────────

func (s *Server) handleGetClipboard(c *gin.Context) {
	text, err := windows.ReadClipboard()
	if err != nil {
		fail(c, http.StatusInternalServerError, err.Error())
		return
	}
	success(c, gin.H{"text": text})
}

func (s *Server) handleSetClipboard(c *gin.Context) {
	var req struct {
		Text string `json:"text"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		fail(c, http.StatusBadRequest, err.Error())
		return
	}

	if err := windows.WriteClipboard(req.Text); err != nil {
		fail(c, http.StatusInternalServerError, err.Error())
		return
	}
	success(c, gin.H{"message": "Clipboard updated"})
}

// ─────────────────────────────────────────────────────────────────────────────
// Audio
// ─────────────────────────────────────────────────────────────────────────────

func (s *Server) handleGetAudio(c *gin.Context) {
	vol, muted, err := windows.GetVolume()
	if err != nil {
		fail(c, http.StatusInternalServerError, err.Error())
		return
	}
	success(c, gin.H{
		"volume": vol,
		"muted":  muted,
	})
}

func (s *Server) handleSetVolume(c *gin.Context) {
	var req struct {
		Volume *int  `json:"volume"`
		Muted  *bool `json:"muted"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		fail(c, http.StatusBadRequest, err.Error())
		return
	}

	if req.Volume != nil {
		if err := windows.SetVolume(*req.Volume); err != nil {
			fail(c, http.StatusInternalServerError, err.Error())
			return
		}
	}

	if req.Muted != nil {
		if err := windows.SetMuted(*req.Muted); err != nil {
			fail(c, http.StatusInternalServerError, err.Error())
			return
		}
	}

	success(c, gin.H{"message": "Audio settings updated"})
}

// ─────────────────────────────────────────────────────────────────────────────
// Printers
// ─────────────────────────────────────────────────────────────────────────────

func (s *Server) handleListPrinters(c *gin.Context) {
	printers, err := windows.ListPrinters()
	if err != nil {
		fail(c, http.StatusInternalServerError, err.Error())
		return
	}
	success(c, printers)
}
