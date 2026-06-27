package monitor

import (
	"os/exec"
	"strings"
	"time"

	"github.com/shirou/gopsutil/v4/cpu"
	"github.com/shirou/gopsutil/v4/disk"
	"github.com/shirou/gopsutil/v4/host"
	"github.com/shirou/gopsutil/v4/mem"
	"github.com/shirou/gopsutil/v4/net"
)

// collectPlatform returns real monitoring data on Windows using gopsutil.
func collectPlatform(c *Collector) Metrics {
	now := time.Now()
	m := Metrics{
		Timestamp: now,
		CPU:       CPUMetrics{},
		RAM:       RAMMetrics{},
		Disk:      []DiskMetrics{},
		Network:   NetMetrics{},
		Battery:   BatteryMetrics{}, // Keep mock/empty for now
		GPU:       GPUMetrics{},
		OS:        OSInfo{},
		Temp:      TempMetrics{},
	}

	// 1. OS & Uptime
	if info, err := host.Info(); err == nil {
		m.OS.Name = info.OS
		m.OS.Version = info.PlatformVersion
		m.OS.Hostname = info.Hostname
		m.Uptime = int64(info.Uptime)
	}

	// 2. CPU
	if p, err := cpu.Percent(0, false); err == nil && len(p) > 0 {
		m.CPU.UsagePercent = p[0]
	}
	if info, err := cpu.Info(); err == nil && len(info) > 0 {
		m.CPU.ModelName = info[0].ModelName
		m.CPU.Cores = int(info[0].Cores)
		m.CPU.FrequencyMHz = info[0].Mhz
	}
	
	// 3. RAM
	if v, err := mem.VirtualMemory(); err == nil {
		m.RAM.TotalMB = float64(v.Total) / 1024 / 1024
		m.RAM.UsedMB = float64(v.Used) / 1024 / 1024
		m.RAM.FreeMB = float64(v.Free) / 1024 / 1024
		m.RAM.UsedPercent = v.UsedPercent
	}

	// 4. Disk
	if parts, err := disk.Partitions(false); err == nil {
		for _, part := range parts {
			// Skip CD-ROM or non-NTFS drives commonly
			optsStr := strings.Join(part.Opts, ",")
			if !strings.Contains(optsStr, "rw") {
				continue
			}
			
			if usage, err := disk.Usage(part.Mountpoint); err == nil {
				d := DiskMetrics{
					Drive:       part.Mountpoint,
					Label:       part.Fstype,
					TotalGB:     float64(usage.Total) / 1024 / 1024 / 1024,
					UsedGB:      float64(usage.Used) / 1024 / 1024 / 1024,
					FreeGB:      float64(usage.Free) / 1024 / 1024 / 1024,
					UsedPercent: usage.UsedPercent,
					IsSystem:    strings.HasPrefix(strings.ToUpper(part.Mountpoint), "C:"),
					Type:        "Unknown",
				}
				m.Disk = append(m.Disk, d)
			}
		}
	}

	// 5. Network
	if ioStat, err := net.IOCounters(false); err == nil && len(ioStat) > 0 {
		stat := ioStat[0]
		elapsed := now.Sub(c.prevTime).Seconds()
		if elapsed > 0 && !c.prevTime.IsZero() {
			sent := float64(stat.BytesSent - c.prevNetSent)
			recv := float64(stat.BytesRecv - c.prevNetRecv)
			if sent >= 0 {
				m.Network.UploadBps = int64(sent / elapsed)
			}
			if recv >= 0 {
				m.Network.DownloadBps = int64(recv / elapsed)
			}
		}
		c.prevNetSent = stat.BytesSent
		c.prevNetRecv = stat.BytesRecv
		c.prevTime = now
		m.Network.Connected = true
	}

	// 6. GPU via WMI (PowerShell)
	cmd := exec.Command("powershell", "-NoProfile", "-Command", "(Get-WmiObject Win32_VideoController).Name")
	out, err := cmd.Output()
	if err == nil {
		gpuName := strings.TrimSpace(string(out))
		if gpuName != "" {
			gpus := strings.Split(strings.ReplaceAll(gpuName, "\r\n", "\n"), "\n")
			validGpus := []string{}
			for _, g := range gpus {
				if strings.TrimSpace(g) != "" {
					validGpus = append(validGpus, strings.TrimSpace(g))
				}
			}
			if len(validGpus) > 0 {
				m.GPU.Available = true
				m.GPU.ModelName = strings.Join(validGpus, " + ")
			}
		}
	}

	return m
}
