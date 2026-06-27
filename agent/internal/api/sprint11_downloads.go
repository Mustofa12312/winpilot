package api

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
)

// ─────────────────────────────────────────────────────────────────────────────
// Download Manager
// ─────────────────────────────────────────────────────────────────────────────

type DownloadStatus struct {
	ID         string  `json:"id"`
	URL        string  `json:"url"`
	Filename   string  `json:"filename"`
	TotalBytes int64   `json:"total_bytes"`
	Downloaded int64   `json:"downloaded"`
	Progress   float64 `json:"progress"` // 0 to 100
	Speed      int64   `json:"speed"`    // bytes per second
	State      string  `json:"state"`    // "downloading", "completed", "error"
	Error      string  `json:"error,omitempty"`
}

var (
	downloadsMu sync.RWMutex
	downloads   = make(map[string]*DownloadStatus)
)

// PassThruReader tracks progress of io.Copy
type PassThruReader struct {
	io.Reader
	total      int64
	downloaded int64
	status     *DownloadStatus
	lastTime   time.Time
	lastBytes  int64
}

func (pt *PassThruReader) Read(p []byte) (int, error) {
	n, err := pt.Reader.Read(p)
	if n > 0 {
		pt.downloaded += int64(n)

		now := time.Now()
		elapsed := now.Sub(pt.lastTime).Seconds()

		// Update status every 500ms
		if elapsed >= 0.5 {
			speed := float64(pt.downloaded-pt.lastBytes) / elapsed

			downloadsMu.Lock()
			pt.status.Downloaded = pt.downloaded
			if pt.total > 0 {
				pt.status.Progress = float64(pt.downloaded) / float64(pt.total) * 100
			}
			pt.status.Speed = int64(speed)
			downloadsMu.Unlock()

			pt.lastTime = now
			pt.lastBytes = pt.downloaded
		}
	}
	return n, err
}

func (s *Server) handleStartDownload(c *gin.Context) {
	var req struct {
		URL      string `json:"url"`
		Filename string `json:"filename"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		fail(c, http.StatusBadRequest, "Invalid request payload")
		return
	}

	if req.URL == "" {
		fail(c, http.StatusBadRequest, "URL is required")
		return
	}

	// Create unique ID
	id := fmt.Sprintf("%d", time.Now().UnixNano())
	
	filename := req.Filename
	if filename == "" {
		filename = filepath.Base(req.URL)
		if filename == "" || filename == "/" || filename == "." {
			filename = "download_" + id
		}
	}

	status := &DownloadStatus{
		ID:       id,
		URL:      req.URL,
		Filename: filename,
		State:    "starting",
	}

	downloadsMu.Lock()
	downloads[id] = status
	downloadsMu.Unlock()

	// Run download in background
	go startDownload(id, req.URL, filename)

	success(c, gin.H{
		"message": "Download started",
		"id":      id,
	})
}

func (s *Server) handleListDownloads(c *gin.Context) {
	downloadsMu.RLock()
	defer downloadsMu.RUnlock()

	var list []DownloadStatus
	for _, v := range downloads {
		list = append(list, *v)
	}

	success(c, list)
}

func startDownload(id string, url string, filename string) {
	updateState := func(state string, errStr string) {
		downloadsMu.Lock()
		defer downloadsMu.Unlock()
		if dl, ok := downloads[id]; ok {
			dl.State = state
			dl.Error = errStr
			if state == "completed" {
				dl.Progress = 100
				dl.Speed = 0
			} else if state == "error" {
				dl.Speed = 0
			}
		}
	}

	updateState("downloading", "")

	resp, err := http.Get(url)
	if err != nil {
		updateState("error", err.Error())
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		updateState("error", fmt.Sprintf("bad status: %s", resp.Status))
		return
	}

	// Determine Downloads folder
	userHome, err := os.UserHomeDir()
	if err != nil {
		updateState("error", "could not find home dir")
		return
	}
	downloadPath := filepath.Join(userHome, "Downloads", filename)

	out, err := os.Create(downloadPath)
	if err != nil {
		updateState("error", err.Error())
		return
	}
	defer out.Close()

	downloadsMu.Lock()
	dlStatus := downloads[id]
	dlStatus.TotalBytes = resp.ContentLength
	downloadsMu.Unlock()

	ptReader := &PassThruReader{
		Reader:   resp.Body,
		total:    resp.ContentLength,
		status:   dlStatus,
		lastTime: time.Now(),
	}

	_, err = io.Copy(out, ptReader)
	if err != nil {
		updateState("error", err.Error())
		return
	}

	updateState("completed", "")
}
