package monitor

import (
	"os/exec"
	"strings"
)

// collectPlatform returns dev stub data but overrides GPU with real WMI data on Windows.
func collectPlatform(c *Collector) Metrics {
	m := collect(c)

	// Fetch Real GPU Info via WMI
	cmd := exec.Command("powershell", "-NoProfile", "-Command", "(Get-WmiObject Win32_VideoController).Name")
	out, err := cmd.Output()
	if err == nil {
		gpuName := strings.TrimSpace(string(out))
		// If multiple GPUs exist, they will be separated by newlines, we can take the first one or join them
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
