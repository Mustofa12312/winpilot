package api

import (
	"encoding/json"
	"net/http"
	"os/exec"
	"runtime"

	"github.com/gin-gonic/gin"
)

// ─────────────────────────────────────────────────────────────────────────────
// App Launcher
// ─────────────────────────────────────────────────────────────────────────────

func (s *Server) handleAppLaunch(c *gin.Context) {
	var req struct {
		Name string `json:"name"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		fail(c, http.StatusBadRequest, "Invalid request payload")
		return
	}

	if req.Name == "" {
		fail(c, http.StatusBadRequest, "App name is required")
		return
	}

	if runtime.GOOS == "windows" {
		// Start process detached using cmd /c start
		// "start" command opens default handler if it's a URL, or launches exe.
		cmd := exec.Command("cmd", "/c", "start", "", req.Name)
		if err := cmd.Start(); err != nil {
			fail(c, http.StatusInternalServerError, "Failed to launch application")
			return
		}
	} else {
		// Mock for unix testing
		cmd := exec.Command("sh", "-c", req.Name)
		_ = cmd.Start()
	}

	success(c, gin.H{"message": "App launch signal sent: " + req.Name})
}

// ─────────────────────────────────────────────────────────────────────────────
// Printer Manager
// ─────────────────────────────────────────────────────────────────────────────

type WinPrinter struct {
	Name      string `json:"name"`
	Status    string `json:"status"`
	IsDefault bool   `json:"is_default"`
}

func (s *Server) handleListPrinters(c *gin.Context) {
	if runtime.GOOS != "windows" {
		success(c, []WinPrinter{
			{Name: "PDF Printer (Mock)", Status: "Idle", IsDefault: true},
		})
		return
	}

	// Use Get-Printer which is available on Win 10/11
	cmd := exec.Command("powershell", "-c", `
		Get-WmiObject -Class Win32_Printer | Select-Object Name, Default, PrinterStatus, PrinterState | ConvertTo-Json -Compress
	`)
	
	out, err := cmd.Output()
	if err != nil {
		fail(c, http.StatusInternalServerError, "Failed to list printers")
		return
	}

	// Handle case where WMI returns single object instead of array
	rawJson := string(out)
	if len(rawJson) > 0 && rawJson[0] == '{' {
		rawJson = "[" + rawJson + "]"
	}

	var rawPrinters []struct {
		Name          string `json:"Name"`
		Default       bool   `json:"Default"`
		PrinterStatus uint16 `json:"PrinterStatus"`
		PrinterState  uint32 `json:"PrinterState"`
	}

	if err := json.Unmarshal([]byte(rawJson), &rawPrinters); err != nil {
		fail(c, http.StatusInternalServerError, "Failed to parse printers")
		return
	}

	var printers []WinPrinter
	for _, rp := range rawPrinters {
		statusStr := "Ready"
		// Basic WMI Status translation
		if rp.PrinterStatus == 1 || rp.PrinterStatus == 2 {
			statusStr = "Unknown"
		} else if rp.PrinterStatus == 4 {
			statusStr = "Printing"
		} else if rp.PrinterStatus == 6 || rp.PrinterStatus == 7 {
			statusStr = "Error/Offline"
		} else if rp.PrinterState > 0 { // Detailed state error
			statusStr = "Requires Attention"
		}

		printers = append(printers, WinPrinter{
			Name:      rp.Name,
			Status:    statusStr,
			IsDefault: rp.Default,
		})
	}

	success(c, printers)
}
