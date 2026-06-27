package api

import (
	"encoding/json"
	"net/http"
	"os/exec"
	"runtime"
	"strings"

	"github.com/gin-gonic/gin"
)

// ─────────────────────────────────────────────────────────────────────────────
// Media Controls
// ─────────────────────────────────────────────────────────────────────────────

func (s *Server) handleMediaMute(c *gin.Context) {
	if runtime.GOOS == "windows" {
		// Key code for Volume Mute/Unmute is 173 (0xAD)
		cmd := exec.Command("powershell", "-c", "$obj = new-object -com wscript.shell; $obj.SendKeys([char]173)")
		_ = cmd.Run()
	}
	success(c, gin.H{"message": "Mute toggled"})
}

func (s *Server) handleMediaPlayPause(c *gin.Context) {
	if runtime.GOOS == "windows" {
		// Key code for Media Play/Pause is 179 (0xB3)
		cmd := exec.Command("powershell", "-c", "$obj = new-object -com wscript.shell; $obj.SendKeys([char]179)")
		_ = cmd.Run()
	}
	success(c, gin.H{"message": "Play/Pause toggled"})
}

func (s *Server) handleMediaNext(c *gin.Context) {
	if runtime.GOOS == "windows" {
		// Key code for Media Next Track is 176 (0xB0)
		cmd := exec.Command("powershell", "-c", "$obj = new-object -com wscript.shell; $obj.SendKeys([char]176)")
		_ = cmd.Run()
	}
	success(c, gin.H{"message": "Next track"})
}

func (s *Server) handleMediaPrev(c *gin.Context) {
	if runtime.GOOS == "windows" {
		// Key code for Media Prev Track is 177 (0xB1)
		cmd := exec.Command("powershell", "-c", "$obj = new-object -com wscript.shell; $obj.SendKeys([char]177)")
		_ = cmd.Run()
	}
	success(c, gin.H{"message": "Previous track"})
}

// ─────────────────────────────────────────────────────────────────────────────
// Clipboard Manager
// ─────────────────────────────────────────────────────────────────────────────

func (s *Server) handleClipboardGet(c *gin.Context) {
	if runtime.GOOS != "windows" {
		success(c, gin.H{"text": "Platform not supported"})
		return
	}

	cmd := exec.Command("powershell", "-c", "Get-Clipboard")
	out, err := cmd.Output()
	if err != nil {
		fail(c, http.StatusInternalServerError, "Failed to get clipboard")
		return
	}

	success(c, gin.H{"text": strings.TrimSpace(string(out))})
}

func (s *Server) handleClipboardSet(c *gin.Context) {
	var req struct {
		Text string `json:"text"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		fail(c, http.StatusBadRequest, "Invalid request")
		return
	}

	if runtime.GOOS == "windows" {
		// Using Write-Output and Set-Clipboard
		cmd := exec.Command("powershell", "-c", "param($t) Set-Clipboard -Value $t", "-t", req.Text)
		err := cmd.Run()
		if err != nil {
			fail(c, http.StatusInternalServerError, "Failed to set clipboard")
			return
		}
	}
	success(c, gin.H{"message": "Clipboard updated"})
}

// ─────────────────────────────────────────────────────────────────────────────
// Service Manager
// ─────────────────────────────────────────────────────────────────────────────

type WinService struct {
	Name        string `json:"name"`
	DisplayName string `json:"display_name"`
	Status      string `json:"status"` // Running, Stopped
}

func (s *Server) handleListServices(c *gin.Context) {
	if runtime.GOOS != "windows" {
		success(c, []WinService{})
		return
	}

	cmd := exec.Command("powershell", "-Command", "Get-Service | Select-Object Name, DisplayName, Status | ConvertTo-Json -Compress -Depth 1")
	out, err := cmd.Output()
	if err != nil {
		fail(c, http.StatusInternalServerError, "Failed to list services")
		return
	}

	var rawServices []struct {
		Name        string `json:"Name"`
		DisplayName string `json:"DisplayName"`
		Status      int    `json:"Status"` // 1 = Stopped, 4 = Running
	}

	if err := json.Unmarshal(out, &rawServices); err != nil {
		// Sometimes PowerShell returns a single object if there's only 1 service, but Get-Service returns many.
		fail(c, http.StatusInternalServerError, "Failed to parse services")
		return
	}

	var services []WinService
	for _, rs := range rawServices {
		statusStr := "Stopped"
		if rs.Status == 4 {
			statusStr = "Running"
		}
		services = append(services, WinService{
			Name:        rs.Name,
			DisplayName: rs.DisplayName,
			Status:      statusStr,
		})
	}

	success(c, services)
}

func (s *Server) handleToggleService(c *gin.Context) {
	name := c.Param("name")
	
	var req struct {
		Action string `json:"action"` // start or stop
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		fail(c, http.StatusBadRequest, "Invalid request")
		return
	}

	if runtime.GOOS == "windows" {
		cmdStr := "Start-Service"
		if req.Action == "stop" {
			cmdStr = "Stop-Service"
		}
		cmd := exec.Command("powershell", "-c", cmdStr, "-Name", "'"+strings.ReplaceAll(name, "'", "''")+"'")
		err := cmd.Run()
		if err != nil {
			fail(c, http.StatusInternalServerError, "Failed to change service status (may require admin privileges)")
			return
		}
	}
	success(c, gin.H{"message": "Service status changed"})
}
