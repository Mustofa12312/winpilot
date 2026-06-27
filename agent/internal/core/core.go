// Package core implements the WinPilot Agent core engine.
// Core is responsible for bootstrapping and coordinating all subsystems.
// Core does NOT directly manipulate files, print, or shutdown — plugins do that.
package core

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"time"

	"github.com/winpilot/agent/internal/api"
	"github.com/winpilot/agent/internal/auth"
	"github.com/winpilot/agent/internal/automation"
	"github.com/winpilot/agent/internal/config"
	"github.com/winpilot/agent/internal/events"
	"github.com/winpilot/agent/internal/logger"
	"github.com/winpilot/agent/internal/monitor"
	"github.com/winpilot/agent/internal/plugin"
	"github.com/winpilot/agent/internal/storage"
	ws "github.com/winpilot/agent/internal/websocket"
)

const version = "1.0.0"

// Agent is the core WinPilot engine.
type Agent struct {
	cfg       *config.Config
	log       *logger.Logger
	db        *storage.DB
	bus       *events.Bus
	auth      *auth.Service
	collector *monitor.Collector
	hub              *ws.Hub
	server           *api.Server
	httpSrv          *http.Server
	automationEngine *automation.Engine
	pluginManager    *plugin.Manager
	cancel           context.CancelFunc
}

// New creates and wires up all Agent subsystems.
func New(cfg *config.Config) (*Agent, error) {
	// Logger
	log := logger.New(
		logger.Level(cfg.Logging.Level),
		cfg.Logging.Format,
		cfg.Logging.Dir,
	)

	log.Info("core", "init", "starting", "version", version)

	// Storage
	db, err := storage.Open(cfg.Database.Path)
	if err != nil {
		return nil, fmt.Errorf("core: open db: %w", err)
	}
	log.Info("core", "storage", "ok", "path", cfg.Database.Path)

	// Event Bus
	bus := events.New()

	// Auth Service
	authSvc := auth.NewService(auth.ServiceConfig{
		DB:                 db.Conn(),
		JWTSecret:          cfg.Auth.JWTSecret,
		AccessTokenExpiry:  cfg.Auth.AccessTokenExpiry,
		RefreshTokenExpiry: cfg.Auth.RefreshTokenExpiry,
		PairingCodeExpiry:  cfg.Auth.PairingCodeExpiry,
	})
	log.Info("core", "auth", "ok")

	// Metrics Collector
	collector := monitor.NewCollector()

	// WebSocket Hub
	hub := ws.NewHub(log)
	hub.SubscribeToEvents(bus)

	// Automation Engine
	autoEngine := automation.NewEngine(db, bus, log)

	// Plugin Manager
	currentDir, _ := os.Getwd()
	pluginManager := plugin.NewManager(currentDir, bus, log)

	// API Server
	apiServer := api.NewServer(api.ServerConfig{
		Auth:             authSvc,
		Bus:              bus,
		Collector:        collector,
		AutomationEngine: autoEngine,
		PluginManager:    pluginManager,
		Hub:              hub,
		Log:              log,
	})

	httpSrv := &http.Server{
		Addr:         fmt.Sprintf("%s:%d", cfg.Server.Host, cfg.Server.Port),
		Handler:      apiServer.Handler(),
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 30 * time.Second,
		IdleTimeout:  120 * time.Second,
	}

	return &Agent{
		cfg:       cfg,
		log:       log,
		db:        db,
		bus:       bus,
		auth:      authSvc,
		collector: collector,
		hub:              hub,
		server:           apiServer,
		httpSrv:          httpSrv,
		automationEngine: autoEngine,
		pluginManager:    pluginManager,
	}, nil
}

// Run starts the Agent and blocks until the context is cancelled.
func (a *Agent) Run(ctx context.Context) error {
	ctx, cancel := context.WithCancel(ctx)
	a.cancel = cancel
	defer cancel()

	// Start metrics broadcast loop
	go a.metricsLoop(ctx)

	// Start OTP cleanup loop
	go a.cleanupLoop(ctx)

	// Start Automation Engine
	a.automationEngine.Start()

	// Start Plugin Manager
	a.pluginManager.Start()

	// Publish started event
	a.bus.Publish(events.NewEvent("core", events.EventSystemStarted, map[string]any{
		"version": version,
		"addr":    a.httpSrv.Addr,
	}))

	a.log.Info("core", "server_start", "ok", "addr", a.httpSrv.Addr)
	fmt.Printf("\n")
	fmt.Printf("  ██╗    ██╗██╗███╗   ██╗██████╗ ██╗██╗      ██████╗ ████████╗\n")
	fmt.Printf("  ██║    ██║██║████╗  ██║██╔══██╗██║██║     ██╔═══██╗╚══██╔══╝\n")
	fmt.Printf("  ██║ █╗ ██║██║██╔██╗ ██║██████╔╝██║██║     ██║   ██║   ██║   \n")
	fmt.Printf("  ██║███╗██║██║██║╚██╗██║██╔═══╝ ██║██║     ██║   ██║   ██║   \n")
	fmt.Printf("  ╚███╔███╔╝██║██║ ╚████║██║     ██║███████╗╚██████╔╝   ██║   \n")
	fmt.Printf("   ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝╚═╝     ╚═╝╚══════╝ ╚═════╝    ╚═╝   \n")
	fmt.Printf("\n")
	fmt.Printf("  🚀 WinPilot Agent v%s — Your Personal Windows Control Center\n", version)
	fmt.Printf("  📡 API Server: http://%s\n", a.httpSrv.Addr)
	fmt.Printf("  🔌 WebSocket:  ws://%s/ws\n", a.httpSrv.Addr)
	fmt.Printf("\n")

	// Start HTTP server
	errCh := make(chan error, 1)
	go func() {
		if err := a.httpSrv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			errCh <- err
		}
	}()

	select {
	case err := <-errCh:
		return fmt.Errorf("core: http server: %w", err)
	case <-ctx.Done():
		return a.shutdown()
	}
}

// shutdown gracefully stops all subsystems.
func (a *Agent) shutdown() error {
	a.log.Info("core", "shutdown", "starting")

	a.bus.Publish(events.NewEvent("core", events.EventSystemStopping, nil))

	shutdownCtx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := a.httpSrv.Shutdown(shutdownCtx); err != nil {
		a.log.Warn("core", "http_shutdown", "forced")
	}

	a.automationEngine.Stop()
	a.db.Close()
	a.log.Info("core", "shutdown", "complete")
	return nil
}

// metricsLoop broadcasts system metrics every second via WebSocket.
func (a *Agent) metricsLoop(ctx context.Context) {
	ticker := time.NewTicker(1 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			m := a.collector.Collect()
			
			// Evaluate automation rules
			a.automationEngine.EvaluateMetrics(&m)

			a.bus.PublishAsync(events.NewEvent("monitor", "metrics.update", map[string]any{
				"cpu":          m.CPU,
				"ram":          m.RAM,
				"disk":         m.Disk,
				"network":      m.Network,
				"battery":      m.Battery,
				"temp":         m.Temp,
				"health_score": monitor.HealthScore(m),
				"timestamp":    m.Timestamp,
			}))
		}
	}
}

// cleanupLoop periodically removes expired pairing codes.
func (a *Agent) cleanupLoop(ctx context.Context) {
	ticker := time.NewTicker(5 * time.Minute)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			a.db.Conn().Exec(
				`DELETE FROM pairing_codes WHERE expires_at < ? OR used = 1`,
				time.Now().Add(-10*time.Minute),
			)
		}
	}
}
