// Package monitor provides system metrics collection for WinPilot.
// On Linux (dev mode): returns realistic mock data.
// On Windows: uses actual Windows APIs via build tags.
package monitor

import (
	"runtime"
	"time"
)

// Metrics holds a snapshot of all system metrics.
type Metrics struct {
	CPU       CPUMetrics     `json:"cpu"`
	RAM       RAMMetrics     `json:"ram"`
	Disk      []DiskMetrics  `json:"disk"`
	Network   NetMetrics     `json:"network"`
	Battery   BatteryMetrics `json:"battery"`
	GPU       GPUMetrics     `json:"gpu"`
	Temp      TempMetrics    `json:"temp"`
	OS        OSInfo         `json:"os"`
	Uptime    int64          `json:"uptime_seconds"`
	Timestamp time.Time      `json:"timestamp"`
}

// CPUMetrics holds CPU stats.
type CPUMetrics struct {
	UsagePercent  float64   `json:"usage_percent"`
	Cores         int       `json:"cores"`
	Threads       int       `json:"threads"`
	FrequencyMHz  float64   `json:"frequency_mhz"`
	ModelName     string    `json:"model_name"`
	CoreUsage     []float64 `json:"core_usage"`
}

// RAMMetrics holds memory stats.
type RAMMetrics struct {
	TotalMB     float64 `json:"total_mb"`
	UsedMB      float64 `json:"used_mb"`
	FreeMB      float64 `json:"free_mb"`
	UsedPercent float64 `json:"used_percent"`
	CacheMB     float64 `json:"cache_mb"`
}

// DiskMetrics holds per-drive stats.
type DiskMetrics struct {
	Drive       string  `json:"drive"`
	Label       string  `json:"label"`
	TotalGB     float64 `json:"total_gb"`
	UsedGB      float64 `json:"used_gb"`
	FreeGB      float64 `json:"free_gb"`
	UsedPercent float64 `json:"used_percent"`
	IsSystem    bool    `json:"is_system"`
	Type        string  `json:"type"` // SSD, HDD, Unknown
}

// NetMetrics holds network stats.
type NetMetrics struct {
	UploadBps    int64   `json:"upload_bps"`
	DownloadBps  int64   `json:"download_bps"`
	LatencyMs    float64 `json:"latency_ms"`
	SSID         string  `json:"ssid"`
	LocalIP      string  `json:"local_ip"`
	PublicIP     string  `json:"public_ip"`
	Gateway      string  `json:"gateway"`
	Connected    bool    `json:"connected"`
	InternetOK   bool    `json:"internet_ok"`
}

// BatteryMetrics holds battery info (laptops).
type BatteryMetrics struct {
	Present     bool    `json:"present"`
	Percent     float64 `json:"percent"`
	IsCharging  bool    `json:"is_charging"`
	RemainingMin int    `json:"remaining_min"`
}

// GPUMetrics holds GPU info (if available).
type GPUMetrics struct {
	Available    bool    `json:"available"`
	UsagePercent float64 `json:"usage_percent"`
	VRAM_Total   float64 `json:"vram_total_mb"`
	VRAM_Used    float64 `json:"vram_used_mb"`
	TempCelsius  float64 `json:"temp_celsius"`
	ModelName    string  `json:"model_name"`
}

// TempMetrics holds temperature readings.
type TempMetrics struct {
	CPU         float64 `json:"cpu_celsius"`
	GPU         float64 `json:"gpu_celsius"`
	Motherboard float64 `json:"motherboard_celsius"`
	Available   bool    `json:"available"`
}

// OSInfo holds OS-level info.
type OSInfo struct {
	Name         string `json:"name"`
	Version      string `json:"version"`
	Build        string `json:"build"`
	Arch         string `json:"arch"`
	Hostname     string `json:"hostname"`
	LastBoot     string `json:"last_boot"`
	IsActivated  bool   `json:"is_activated"`
}

// Collector collects system metrics.
type Collector struct {
	prevNetSent uint64
	prevNetRecv uint64
	prevTime    time.Time
}

// NewCollector creates a Collector.
func NewCollector() *Collector {
	return &Collector{prevTime: time.Now()}
}

// Collect returns the current system snapshot.
// On non-Windows platforms returns realistic stub data for development.
func (c *Collector) Collect() Metrics {
	return collectPlatform(c)
}

// collect provides platform-agnostic collection logic.
func collect(c *Collector) Metrics {
	now := time.Now()
	_ = now

	// Realistic dev stub that simulates a live system
	m := Metrics{
		Timestamp: now,
		Uptime:    172800, // 48 hours
		CPU: CPUMetrics{
			UsagePercent: 18.4,
			Cores:        runtime.NumCPU(),
			Threads:      runtime.NumCPU() * 2,
			FrequencyMHz: 3600,
			ModelName:    "Intel Core i7-12700H",
			CoreUsage:    make([]float64, runtime.NumCPU()),
		},
		RAM: RAMMetrics{
			TotalMB:     16384,
			UsedMB:      6820,
			FreeMB:      9564,
			UsedPercent: 41.6,
			CacheMB:     2048,
		},
		Disk: []DiskMetrics{
			{
				Drive:       "C:",
				Label:       "Windows",
				TotalGB:     500,
				UsedGB:      305,
				FreeGB:      195,
				UsedPercent: 61.0,
				IsSystem:    true,
				Type:        "SSD",
			},
			{
				Drive:       "D:",
				Label:       "Data",
				TotalGB:     1000,
				UsedGB:      422,
				FreeGB:      578,
				UsedPercent: 42.2,
				IsSystem:    false,
				Type:        "HDD",
			},
		},
		Network: NetMetrics{
			UploadBps:   512000,
			DownloadBps: 15360000,
			LatencyMs:   8.5,
			SSID:        "HomeNetwork",
			LocalIP:     "192.168.1.100",
			Gateway:     "192.168.1.1",
			Connected:   true,
			InternetOK:  true,
		},
		Battery: BatteryMetrics{
			Present:     false,
			Percent:     100,
			IsCharging:  true,
		},
		GPU: GPUMetrics{
			Available:    false,
			ModelName:    "Not Detected",
		},
		Temp: TempMetrics{
			CPU:       62.0,
			Available: true,
		},
		OS: OSInfo{
			Name:        "Windows 11",
			Version:     "23H2",
			Build:       "22631",
			Arch:        "amd64",
			Hostname:    "WINPILOT-PC",
			LastBoot:    "2026-06-25 09:00:00",
			IsActivated: true,
		},
	}

	// Fill core usage with slight variation
	for i := range m.CPU.CoreUsage {
		m.CPU.CoreUsage[i] = 10 + float64(i*3)
	}

	return m
}

// HealthScore computes a 0–100 system health score.
func HealthScore(m Metrics) int {
	score := 100

	// CPU penalty
	if m.CPU.UsagePercent > 90 {
		score -= 30
	} else if m.CPU.UsagePercent > 70 {
		score -= 10
	}

	// RAM penalty
	if m.RAM.UsedPercent > 95 {
		score -= 25
	} else if m.RAM.UsedPercent > 80 {
		score -= 10
	}

	// Disk penalty (per drive)
	for _, d := range m.Disk {
		if d.UsedPercent > 95 {
			score -= 20
		} else if d.UsedPercent > 85 {
			score -= 5
		}
	}

	// Internet
	if !m.Network.InternetOK {
		score -= 5
	}

	// Temperature
	if m.Temp.Available && m.Temp.CPU > 85 {
		score -= 15
	}

	if score < 0 {
		score = 0
	}
	return score
}
