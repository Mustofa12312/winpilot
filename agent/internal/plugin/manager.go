package plugin

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"sync"
	"time"

	"github.com/winpilot/agent/internal/events"
	"github.com/winpilot/agent/internal/logger"
)

// Manager handles loading, managing, and running external plugins
type Manager struct {
	pluginsDir string
	bus        *events.Bus
	log        *logger.Logger
	plugins    map[string]*Plugin
	mu         sync.RWMutex
}

// NewManager creates a new plugin manager
func NewManager(baseDir string, bus *events.Bus, log *logger.Logger) *Manager {
	dir := filepath.Join(baseDir, "plugins")
	// Ensure plugins directory exists
	os.MkdirAll(dir, 0755)

	return &Manager{
		pluginsDir: dir,
		bus:        bus,
		log:        log,
		plugins:    make(map[string]*Plugin),
	}
}

// Start loads all plugins found in the plugins directory
func (m *Manager) Start() {
	m.log.Info("plugin", "manager_starting", "ok", "dir", m.pluginsDir)
	m.LoadAll()
}

// LoadAll scans the plugins directory and loads valid plugins
func (m *Manager) LoadAll() {
	m.mu.Lock()
	defer m.mu.Unlock()

	entries, err := os.ReadDir(m.pluginsDir)
	if err != nil {
		m.log.Error("plugin", "read_dir_failed", err)
		return
	}

	for _, entry := range entries {
		if !entry.IsDir() {
			continue
		}

		pluginDir := filepath.Join(m.pluginsDir, entry.Name())
		manifestPath := filepath.Join(pluginDir, "manifest.json")

		data, err := os.ReadFile(manifestPath)
		if err != nil {
			m.log.Warn("plugin", "skip_no_manifest", entry.Name())
			continue
		}

		var manifest Manifest
		if err := json.Unmarshal(data, &manifest); err != nil {
			m.log.Warn("plugin", "invalid_manifest", entry.Name(), "err", err)
			continue
		}

		m.plugins[manifest.ID] = &Plugin{
			Manifest: manifest,
			Dir:      pluginDir,
			IsActive: true,
			Status:   "loaded",
		}
		m.log.Info("plugin", "loaded", manifest.ID, "name", manifest.Name)
	}
}

// GetPlugins returns a list of all loaded plugins
func (m *Manager) GetPlugins() []Plugin {
	m.mu.RLock()
	defer m.mu.RUnlock()

	list := make([]Plugin, 0, len(m.plugins))
	for _, p := range m.plugins {
		list = append(list, *p)
	}
	return list
}

// TogglePlugin activates or deactivates a plugin
func (m *Manager) TogglePlugin(id string, active bool) error {
	m.mu.Lock()
	defer m.mu.Unlock()

	p, exists := m.plugins[id]
	if !exists {
		return fmt.Errorf("plugin not found: %s", id)
	}

	p.IsActive = active
	return nil
}

// RunPlugin executes a script plugin and returns its output
func (m *Manager) RunPlugin(id string) (string, error) {
	m.mu.RLock()
	p, exists := m.plugins[id]
	m.mu.RUnlock()

	if !exists {
		return "", fmt.Errorf("plugin not found: %s", id)
	}

	if !p.IsActive {
		return "", fmt.Errorf("plugin is disabled: %s", id)
	}

	entrypoint := filepath.Join(p.Dir, p.Manifest.Entrypoint)
	if _, err := os.Stat(entrypoint); os.IsNotExist(err) {
		return "", fmt.Errorf("entrypoint not found: %s", entrypoint)
	}

	// Execution context with timeout
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	// Handle scripts correctly based on OS/extension
	var cmd *exec.Cmd
	ext := filepath.Ext(entrypoint)
	switch ext {
	case ".bat", ".cmd":
		cmd = exec.CommandContext(ctx, "cmd", "/c", entrypoint)
	case ".ps1":
		cmd = exec.CommandContext(ctx, "powershell", "-ExecutionPolicy", "Bypass", "-File", entrypoint)
	case ".sh":
		cmd = exec.CommandContext(ctx, "bash", entrypoint)
	case ".py":
		cmd = exec.CommandContext(ctx, "python", entrypoint)
	default:
		// For binary executables or scripts with shebang on linux
		cmd = exec.CommandContext(ctx, entrypoint)
	}

	cmd.Dir = p.Dir
	output, err := cmd.CombinedOutput()

	if err != nil {
		m.log.Error("plugin", "exec_failed", err, "id", id, "out", string(output))
		return string(output), fmt.Errorf("execution failed: %w (output: %s)", err, string(output))
	}

	m.log.Info("plugin", "exec_success", id)
	return string(output), nil
}
