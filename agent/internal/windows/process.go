// Package windows provides OS-level abstractions.
package windows

import (
	"errors"
	"math/rand"
)

// ProcessInfo represents a running process.
type ProcessInfo struct {
	PID         int     `json:"pid"`
	Name        string  `json:"name"`
	MemoryUsage int64   `json:"memory_usage"` // in bytes
	CPUUsage    float64 `json:"cpu_usage"`    // percentage
	Username    string  `json:"username"`
}

// ListProcesses returns a list of running processes.
func ListProcesses() ([]ProcessInfo, error) {
	// Stub implementation for cross-platform dev mode.
	// On Windows, this will be replaced with WMI or syscalls.
	
	names := []string{"chrome.exe", "code.exe", "winpilot.exe", "discord.exe", "spotify.exe", "explorer.exe"}
	
	var procs []ProcessInfo
	for i := 0; i < 20; i++ {
		procs = append(procs, ProcessInfo{
			PID:         1000 + rand.Intn(9000),
			Name:        names[rand.Intn(len(names))],
			MemoryUsage: int64(rand.Intn(1024) * 1024 * 1024), // Random up to 1GB
			CPUUsage:    rand.Float64() * 15,
			Username:    "mustofa",
		})
	}
	
	return procs, nil
}

// KillProcess forcefully terminates a process by PID.
func KillProcess(pid int) error {
	// Stub implementation
	if pid <= 0 {
		return errors.New("invalid PID")
	}
	// Simulated success
	return nil
}
