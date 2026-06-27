// Package windows provides OS-level abstractions.
package windows

import (
	"fmt"

	"github.com/shirou/gopsutil/v4/process"
)

// ProcessInfo represents a running process.
type ProcessInfo struct {
	PID         int     `json:"pid"`
	Name        string  `json:"name"`
	MemoryUsage int64   `json:"memory_usage"` // in bytes
	CPUUsage    float64 `json:"cpu_usage"`    // percentage
	Username    string  `json:"username"`
}

// ListProcesses returns a list of running processes on Windows using gopsutil.
func ListProcesses() ([]ProcessInfo, error) {
	procs, err := process.Processes()
	if err != nil {
		return nil, fmt.Errorf("failed to list processes: %w", err)
	}

	var results []ProcessInfo
	for _, p := range procs {
		name, err := p.Name()
		if err != nil || name == "" {
			continue // Skip processes we can't read
		}

		// Optionally get CPU and RAM. Errors are ignored because some processes (e.g. System) 
		// deny access to these metrics without admin rights.
		cpu, _ := p.CPUPercent()
		var memUsage int64
		if memInfo, err := p.MemoryInfo(); err == nil && memInfo != nil {
			memUsage = int64(memInfo.RSS)
		}

		user, _ := p.Username()

		results = append(results, ProcessInfo{
			PID:         int(p.Pid),
			Name:        name,
			MemoryUsage: memUsage,
			CPUUsage:    cpu,
			Username:    user,
		})
	}

	return results, nil
}

// KillProcess forcefully terminates a process by PID.
func KillProcess(pid int) error {
	p, err := process.NewProcess(int32(pid))
	if err != nil {
		return fmt.Errorf("process not found: %w", err)
	}

	if err := p.Kill(); err != nil {
		return fmt.Errorf("failed to kill process: %w", err)
	}
	
	return nil
}
