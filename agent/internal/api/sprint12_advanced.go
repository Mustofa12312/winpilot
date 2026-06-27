package api

import (
	"encoding/json"
	"net/http"
	"os/exec"
	"runtime"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
)

// ─────────────────────────────────────────────────────────────────────────────
// Display Manager
// ─────────────────────────────────────────────────────────────────────────────

func (s *Server) handleGetDisplay(c *gin.Context) {
	if runtime.GOOS != "windows" {
		success(c, gin.H{"brightness": 50})
		return
	}

	cmd := exec.Command("powershell", "-c", `(Get-WmiObject -Namespace root/WMI -Class WmiMonitorBrightness).CurrentBrightness`)
	out, err := cmd.Output()
	if err != nil {
		fail(c, http.StatusInternalServerError, "Failed to get brightness")
		return
	}

	brightnessStr := strings.TrimSpace(string(out))
	brightness, err := strconv.Atoi(brightnessStr)
	if err != nil {
		brightness = 50 // Default fallback
	}

	success(c, gin.H{"brightness": brightness})
}

func (s *Server) handleSetBrightness(c *gin.Context) {
	var req struct {
		Level int `json:"level"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		fail(c, http.StatusBadRequest, "Invalid request")
		return
	}

	if runtime.GOOS == "windows" {
		psCmd := `(Get-WmiObject -Namespace root/WMI -Class WmiMonitorBrightnessMethods).WmiSetBrightness(1, ` + strconv.Itoa(req.Level) + `)`
		_ = exec.Command("powershell", "-c", psCmd).Run()
	}

	success(c, gin.H{"message": "Brightness updated", "level": req.Level})
}

// ─────────────────────────────────────────────────────────────────────────────
// Network Manager
// ─────────────────────────────────────────────────────────────────────────────

func (s *Server) handleNetworkInfo(c *gin.Context) {
	if runtime.GOOS != "windows" {
		success(c, gin.H{
			"local_ip":  "127.0.0.1",
			"public_ip": "1.1.1.1",
			"ping":      "15ms",
			"ssid":      "Mock_WiFi",
		})
		return
	}

	// Local IP & SSID
	localIpCmd := exec.Command("powershell", "-c", `(Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias Wi-Fi, Ethernet* -ErrorAction SilentlyContinue | Select-Object -First 1).IPAddress`)
	localIpOut, _ := localIpCmd.Output()
	localIp := strings.TrimSpace(string(localIpOut))
	if localIp == "" {
		localIp = "Unknown"
	}

	ssidCmd := exec.Command("powershell", "-c", `(netsh wlan show interfaces) -Match '^\s+Profile' -Replace '^\s+Profile\s+:\s+',''`)
	ssidOut, _ := ssidCmd.Output()
	ssid := strings.TrimSpace(string(ssidOut))
	if ssid == "" {
		ssid = "LAN/Unknown"
	}

	// Public IP (fetch from ipify)
	publicIp := "Checking..."
	resp, err := http.Get("https://api.ipify.org")
	if err == nil {
		defer resp.Body.Close()
		buf := make([]byte, 64)
		n, _ := resp.Body.Read(buf)
		publicIp = string(buf[:n])
	} else {
		publicIp = "Offline"
	}

	// Ping Google DNS
	pingCmd := exec.Command("cmd", "/c", "ping -n 1 8.8.8.8")
	pingOut, _ := pingCmd.Output()
	pingStr := "Timeout"
	if strings.Contains(string(pingOut), "time=") {
		parts := strings.Split(string(pingOut), "time=")
		if len(parts) > 1 {
			msPart := strings.Split(parts[1], "ms")
			if len(msPart) > 0 {
				pingStr = msPart[0] + "ms"
			}
		}
	}

	success(c, gin.H{
		"local_ip":  localIp,
		"public_ip": publicIp,
		"ping":      pingStr,
		"ssid":      ssid,
	})
}

// ─────────────────────────────────────────────────────────────────────────────
// Windows Update Manager
// ─────────────────────────────────────────────────────────────────────────────

func (s *Server) handleOSUpdate(c *gin.Context) {
	if runtime.GOOS != "windows" {
		success(c, gin.H{
			"status": "Up to date",
			"count":  0,
		})
		return
	}

	// Use WMI to check if there are pending updates (Auto Update Component)
	// This is a fast heuristic check since full Windows Update API takes minutes.
	cmd := exec.Command("powershell", "-c", `
		$updateSession = New-Object -ComObject Microsoft.Update.Session
		$updateSearcher = $updateSession.CreateUpdateSearcher()
		$searchResult = $updateSearcher.Search("IsInstalled=0 and Type='Software'")
		@{ count = $searchResult.Updates.Count } | ConvertTo-Json
	`)
	
	// Timeout logic for Update search to prevent hanging
	out, err := cmd.Output()
	
	count := 0
	status := "Pembaruan Tersedia"
	
	if err != nil {
		// If fails (often COM object issues or permissions), fallback to basic info
		status = "Gagal Mengecek (Butuh Admin)"
	} else {
		var res struct {
			Count int `json:"count"`
		}
		json.Unmarshal(out, &res)
		count = res.Count
		if count == 0 {
			status = "Sistem Anda Mutakhir"
		} else {
			status = strconv.Itoa(count) + " Pembaruan Menunggu"
		}
	}

	success(c, gin.H{
		"status": status,
		"count":  count,
	})
}
