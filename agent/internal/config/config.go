// Package config manages WinPilot Agent configuration.
// Config is stored as JSON on disk and loaded at startup.
package config

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"sync"
	"time"
)

// Config holds all configuration for the WinPilot Agent.
type Config struct {
	mu sync.RWMutex

	Server   ServerConfig   `json:"server"`
	Auth     AuthConfig     `json:"auth"`
	Database DatabaseConfig `json:"database"`
	Logging  LoggingConfig  `json:"logging"`
	Plugins  PluginsConfig  `json:"plugins"`
}

// ServerConfig defines HTTP/WebSocket server settings.
type ServerConfig struct {
	Host    string `json:"host"`
	Port    int    `json:"port"`
	TLS     bool   `json:"tls"`
	CertFile string `json:"cert_file"`
	KeyFile  string `json:"key_file"`
}

// AuthConfig holds authentication settings.
type AuthConfig struct {
	JWTSecret          string        `json:"jwt_secret"`
	AccessTokenExpiry  time.Duration `json:"access_token_expiry"`
	RefreshTokenExpiry time.Duration `json:"refresh_token_expiry"`
	PairingCodeExpiry  time.Duration `json:"pairing_code_expiry"`
	MaxLoginAttempts   int           `json:"max_login_attempts"`
}

// DatabaseConfig holds SQLite settings.
type DatabaseConfig struct {
	Path string `json:"path"`
}

// LoggingConfig holds logging settings.
type LoggingConfig struct {
	Level  string `json:"level"`  // debug, info, warn, error
	Format string `json:"format"` // text, json
	Dir    string `json:"dir"`
}

// PluginsConfig holds plugin directory settings.
type PluginsConfig struct {
	Dir              string `json:"dir"`
	AllowUnsigned    bool   `json:"allow_unsigned"`
	ResourceBudgetMB int    `json:"resource_budget_mb"`
}

// DefaultConfig returns a production-ready default config.
func DefaultConfig() *Config {
	return &Config{
		Server: ServerConfig{
			Host: "0.0.0.0",
			Port: 8080,
			TLS:  false,
		},
		Auth: AuthConfig{
			JWTSecret:          "winpilot-change-this-secret-in-production",
			AccessTokenExpiry:  15 * time.Minute,
			RefreshTokenExpiry: 7 * 24 * time.Hour,
			PairingCodeExpiry:  5 * time.Minute,
			MaxLoginAttempts:   5,
		},
		Database: DatabaseConfig{
			Path: "winpilot.db",
		},
		Logging: LoggingConfig{
			Level:  "info",
			Format: "text",
			Dir:    "logs",
		},
		Plugins: PluginsConfig{
			Dir:              "plugins",
			AllowUnsigned:    true,
			ResourceBudgetMB: 20,
		},
	}
}

// Load reads config from the given path, or returns defaults if not found.
func Load(path string) (*Config, error) {
	cfg := DefaultConfig()

	data, err := os.ReadFile(path)
	if err != nil {
		if os.IsNotExist(err) {
			// First run: save defaults
			if err := cfg.Save(path); err != nil {
				return nil, err
			}
			return cfg, nil
		}
		return nil, err
	}

	if err := json.Unmarshal(data, cfg); err != nil {
		return nil, err
	}

	return cfg, nil
}

// Save writes the config to the given path.
func (c *Config) Save(path string) error {
	c.mu.RLock()
	defer c.mu.RUnlock()

	if err := os.MkdirAll(filepath.Dir(path), 0755); err != nil {
		return err
	}

	data, err := json.MarshalIndent(c, "", "  ")
	if err != nil {
		return err
	}

	return os.WriteFile(path, data, 0600)
}

// GetServerAddr returns formatted address string.
func (c *Config) GetServerAddr() string {
	c.mu.RLock()
	defer c.mu.RUnlock()
	return fmt.Sprintf("%s:%d", c.Server.Host, c.Server.Port)
}
