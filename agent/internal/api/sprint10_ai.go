package api

import (
	"net/http"
	"os/exec"
	"runtime"
	"strings"

	"github.com/gin-gonic/gin"
)

// ─────────────────────────────────────────────────────────────────────────────
// AI Command Center (Offline Intent Parser)
// ─────────────────────────────────────────────────────────────────────────────

func (s *Server) handleAICommand(c *gin.Context) {
	var req struct {
		Command string `json:"command"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		fail(c, http.StatusBadRequest, "Invalid request payload")
		return
	}

	text := strings.ToLower(strings.TrimSpace(req.Command))
	if text == "" {
		fail(c, http.StatusBadRequest, "Command cannot be empty")
		return
	}

	// Simple Rule-Based NLP Pipeline
	intent, target, actionDesc := parseIntent(text)

	if intent == "unknown" {
		c.JSON(http.StatusOK, gin.H{
			"success": false,
			"message": "Maaf, saya tidak mengerti maksud perintah tersebut.",
		})
		return
	}

	// Execute Intent
	err := executeIntent(intent, target)
	if err != nil {
		fail(c, http.StatusInternalServerError, "Gagal mengeksekusi: "+err.Error())
		return
	}

	success(c, gin.H{"message": actionDesc})
}

// parseIntent parses the natural language text into an intent, target, and description.
func parseIntent(text string) (intent string, target string, desc string) {
	// 1. Power Commands
	if containsAny(text, "mati", "shutdown", "turn off", "power off") {
		return "power_shutdown", "", "Mematikan PC..."
	}
	if containsAny(text, "restart", "reboot", "mulai ulang") {
		return "power_restart", "", "Merestart PC..."
	}
	if containsAny(text, "kunci", "lock", "tutup layar") {
		return "power_lock", "", "Mengunci layar PC..."
	}
	if containsAny(text, "tidur", "sleep", "mode tidur") {
		return "power_sleep", "", "Mengaktifkan mode Sleep..."
	}

	// 2. Media Commands
	if containsAny(text, "mute", "senyap", "matikan suara", "bisukan") {
		return "media_mute", "", "Sistem di-mute."
	}
	if containsAny(text, "play", "pause", "putar", "jeda", "mainkan") {
		return "media_playpause", "", "Media di-play/pause."
	}

	// 3. App Launch Commands (e.g. "buka kalkulator", "buka chrome")
	if containsAny(text, "buka", "jalankan", "open", "launch", "start") {
		// Extract target
		target = extractAppTarget(text)
		if target != "" {
			return "app_launch", target, "Membuka aplikasi: " + target
		}
	}

	return "unknown", "", ""
}

func containsAny(text string, keywords ...string) bool {
	for _, k := range keywords {
		if strings.Contains(text, k) {
			return true
		}
	}
	return false
}

func extractAppTarget(text string) string {
	words := strings.Fields(text)
	appMap := map[string]string{
		"kalkulator": "calc.exe",
		"calc":       "calc.exe",
		"calculator": "calc.exe",
		"notepad":    "notepad.exe",
		"catatan":    "notepad.exe",
		"chrome":     "chrome.exe",
		"browser":    "chrome.exe",
		"edge":       "msedge.exe",
		"explorer":   "explorer.exe",
		"file":       "explorer.exe",
		"cmd":        "cmd.exe",
		"terminal":   "cmd.exe",
		"paint":      "mspaint.exe",
		"task":       "taskmgr.exe",
		"spotify":    "spotify.exe",
	}

	for _, w := range words {
		if exe, ok := appMap[w]; ok {
			return exe
		}
	}
	return ""
}

func executeIntent(intent string, target string) error {
	if runtime.GOOS != "windows" {
		return nil // Mock success on linux
	}

	switch intent {
	case "power_shutdown":
		return exec.Command("shutdown", "/s", "/t", "0").Run()
	case "power_restart":
		return exec.Command("shutdown", "/r", "/t", "0").Run()
	case "power_lock":
		return exec.Command("rundll32.exe", "user32.dll,LockWorkStation").Run()
	case "power_sleep":
		return exec.Command("rundll32.exe", "powrprof.dll,SetSuspendState", "0,1,0").Run()
	case "media_mute":
		cmd := exec.Command("powershell", "-c", "$obj = new-object -com wscript.shell; $obj.SendKeys([char]173)")
		return cmd.Run()
	case "media_playpause":
		cmd := exec.Command("powershell", "-c", "$obj = new-object -com wscript.shell; $obj.SendKeys([char]179)")
		return cmd.Run()
	case "app_launch":
		cmd := exec.Command("cmd", "/c", "start", "", target)
		return cmd.Start()
	}
	return nil
}
