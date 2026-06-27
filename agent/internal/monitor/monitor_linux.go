// Platform-specific metrics collection: Linux/dev stub.
//go:build !windows

package monitor

// collectPlatform returns dev stub data on non-Windows platforms.
func collectPlatform(c *Collector) Metrics {
	return collect(c)
}
