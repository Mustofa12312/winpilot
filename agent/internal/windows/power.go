package windows

import (
	"fmt"
	"os/exec"
	"runtime"

	"github.com/winpilot/agent/internal/events"
	"github.com/winpilot/agent/internal/logger"
)

// InitPowerSubscribers listens for power events and executes them on Windows.
func InitPowerSubscribers(bus *events.Bus, log *logger.Logger) {
	// Only attach real handlers if running on Windows
	if runtime.GOOS != "windows" {
		log.Warn("windows", "power", "Power commands are only supported on Windows")
		return
	}

	// Shutdown
	bus.Subscribe(events.EventPowerShutdown, func(e events.Event) {
		delayFloat, _ := e.Data["delay"].(float64)
		delay := int(delayFloat)
		log.Info("windows", "power_shutdown", "executing", "delay", delay)
		
		cmd := exec.Command("shutdown", "/s", "/t", fmt.Sprintf("%d", delay))
		if err := cmd.Run(); err != nil {
			log.Error("windows", "power_shutdown", err)
		}
	})

	// Restart
	bus.Subscribe(events.EventPowerRestart, func(e events.Event) {
		delayFloat, _ := e.Data["delay"].(float64)
		delay := int(delayFloat)
		log.Info("windows", "power_restart", "executing", "delay", delay)
		
		cmd := exec.Command("shutdown", "/r", "/t", fmt.Sprintf("%d", delay))
		if err := cmd.Run(); err != nil {
			log.Error("windows", "power_restart", err)
		}
	})

	// Lock
	bus.Subscribe(events.EventPowerLock, func(e events.Event) {
		log.Info("windows", "power_lock", "executing")
		
		cmd := exec.Command("rundll32.exe", "user32.dll,LockWorkStation")
		if err := cmd.Run(); err != nil {
			log.Error("windows", "power_lock", err)
		}
	})

	// Sleep
	bus.Subscribe(events.EventPowerSleep, func(e events.Event) {
		log.Info("windows", "power_sleep", "executing")
		
		// Note: Hibernate must be disabled (powercfg -h off) for this to trigger Standby/Sleep, 
		// otherwise it triggers Hibernate.
		cmd := exec.Command("rundll32.exe", "powrprof.dll,SetSuspendState", "0,1,0")
		if err := cmd.Run(); err != nil {
			log.Error("windows", "power_sleep", err)
		}
	})
	
	log.Info("windows", "power", "Power subscribers initialized")
}
