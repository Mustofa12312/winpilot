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
// Device Hub (Hardware, USB, Bluetooth)
// ─────────────────────────────────────────────────────────────────────────────

type WinDevice struct {
	Name         string `json:"name"`
	Description  string `json:"description"`
	Manufacturer string `json:"manufacturer"`
	Status       string `json:"status"`
	DeviceClass  string `json:"class"` // "USB", "Bluetooth", "Display", "Other"
}

func (s *Server) handleListHardwareDevices(c *gin.Context) {
	if runtime.GOOS != "windows" {
		success(c, []WinDevice{
			{Name: "Mock USB Drive", Status: "OK", DeviceClass: "USB"},
			{Name: "Mock Bluetooth Headset", Status: "OK", DeviceClass: "Bluetooth"},
		})
		return
	}

	// PowerShell to query Win32_PnPEntity
	// We filter for devices that are present and have a name
	cmd := exec.Command("powershell", "-c", `
		Get-WmiObject Win32_PnPEntity -Filter "Present=true AND Name IS NOT NULL" | 
		Select-Object Name, Description, Manufacturer, Status, PNPClass | 
		ConvertTo-Json -Compress
	`)
	
	out, err := cmd.Output()
	if err != nil {
		fail(c, http.StatusInternalServerError, "Failed to list devices")
		return
	}

	rawJson := string(out)
	if len(rawJson) > 0 && rawJson[0] == '{' {
		rawJson = "[" + rawJson + "]"
	}

	var rawDevices []struct {
		Name         string `json:"Name"`
		Description  string `json:"Description"`
		Manufacturer string `json:"Manufacturer"`
		Status       string `json:"Status"`
		PNPClass     string `json:"PNPClass"`
	}

	if err := json.Unmarshal([]byte(rawJson), &rawDevices); err != nil {
		fail(c, http.StatusInternalServerError, "Failed to parse devices")
		return
	}

	var devices []WinDevice
	for _, rd := range rawDevices {
		class := "Other"
		lowerClass := strings.ToLower(rd.PNPClass)
		lowerName := strings.ToLower(rd.Name)
		
		if strings.Contains(lowerClass, "usb") || strings.Contains(lowerName, "usb") {
			class = "USB"
		} else if strings.Contains(lowerClass, "bluetooth") || strings.Contains(lowerName, "bluetooth") {
			class = "Bluetooth"
		} else if strings.Contains(lowerClass, "display") || strings.Contains(lowerClass, "monitor") {
			class = "Display"
		} else if strings.Contains(lowerClass, "media") {
			class = "Audio"
		}

		// Only include specific categories to avoid cluttering the UI with 100+ system devices
		if class != "Other" || strings.Contains(lowerClass, "diskdrive") {
			if class == "Other" && strings.Contains(lowerClass, "diskdrive") {
				class = "Disk"
			}
			
			devices = append(devices, WinDevice{
				Name:         rd.Name,
				Description:  rd.Description,
				Manufacturer: rd.Manufacturer,
				Status:       rd.Status,
				DeviceClass:  class,
			})
		}
	}

	success(c, devices)
}
