// Package api implements the WinPilot REST API.
// All routes follow /api/v1/ convention.
// Authentication middleware validates JWT on every protected endpoint.
package api

import (
	"net/http"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/winpilot/agent/internal/auth"
	"github.com/winpilot/agent/internal/automation"
	"github.com/winpilot/agent/internal/events"
	"github.com/winpilot/agent/internal/logger"
	"github.com/winpilot/agent/internal/monitor"
	"github.com/winpilot/agent/internal/plugin"
	wsHub "github.com/winpilot/agent/internal/websocket"
)

type Server struct {
	router           *gin.Engine
	auth             *auth.Service
	bus              *events.Bus
	collector        *monitor.Collector
	automationEngine *automation.Engine
	pluginManager    *plugin.Manager
	hub              *wsHub.Hub
	log              *logger.Logger
}

// ServerConfig holds all dependencies.
type ServerConfig struct {
	Auth             *auth.Service
	Bus              *events.Bus
	Collector        *monitor.Collector
	AutomationEngine *automation.Engine
	PluginManager    *plugin.Manager
	Hub              *wsHub.Hub
	Log              *logger.Logger
}

// NewServer creates and configures the Gin HTTP server.
func NewServer(cfg ServerConfig) *Server {
	gin.SetMode(gin.ReleaseMode)

	r := gin.New()
	r.Use(gin.Recovery())
	r.Use(corsMiddleware())
	r.Use(requestLoggerMiddleware(cfg.Log))

	s := &Server{
		router:           r,
		auth:             cfg.Auth,
		bus:              cfg.Bus,
		collector:        cfg.Collector,
		automationEngine: cfg.AutomationEngine,
		pluginManager:    cfg.PluginManager,
		hub:              cfg.Hub,
		log:              cfg.Log,
	}

	s.registerRoutes()
	return s
}

// Handler returns the underlying http.Handler.
func (s *Server) Handler() http.Handler {
	return s.router
}

// registerRoutes wires all API routes.
func (s *Server) registerRoutes() {
	r := s.router

	// Health check (public)
	r.GET("/health", s.handleHealth)

	// WebSocket (requires auth via query param token)
	r.GET("/ws", s.handleWebSocket)

	v1 := r.Group("/api/v1")
	{
		// Auth routes (public)
		authRoutes := v1.Group("/auth")
		{
			authRoutes.POST("/pair", s.handlePair)
			authRoutes.POST("/refresh", s.handleRefresh)
			authRoutes.POST("/pair/otp", s.handleGenerateOTP)
		}

		// Protected routes
		protected := v1.Group("")
		protected.Use(s.authMiddleware())
		{
			// Auth management
			protected.DELETE("/auth/logout", s.handleLogout)
			protected.GET("/auth/devices", s.handleListDevices)
			protected.DELETE("/auth/devices/:id", s.handleRevokeDevice)

			// System & Metrics
			protected.GET("/system", s.handleSystemInfo)
			protected.GET("/metrics", s.handleMetrics)

			// Power
			protected.POST("/power/shutdown", s.handleShutdown)
			protected.POST("/power/restart", s.handleRestart)
			protected.POST("/power/sleep", s.handleSleep)
			protected.POST("/power/lock", s.handleLock)

			// Files
			protected.GET("/files", s.handleListFiles)
			protected.GET("/files/download", s.handleDownloadFile)
			protected.POST("/files/upload", s.handleUploadFile)
			protected.POST("/files/action", s.handleFileAction)

			// Clipboard
			protected.GET("/clipboard", s.handleGetClipboard)
			protected.POST("/clipboard", s.handleSetClipboard)

			// Audio
			protected.GET("/audio", s.handleGetAudio)
			protected.POST("/audio/volume", s.handleSetVolume)

			// Printers
			protected.GET("/printers", s.handleListPrinters)

			// Processes (Task Manager)
			protected.GET("/processes", s.handleListProcesses)
			protected.POST("/processes/:pid/kill", s.handleKillProcess)

			// Automation
			protected.GET("/automation/rules", s.handleListRules)
			protected.POST("/automation/rules", s.handleCreateRule)
			protected.PUT("/automation/rules/:id/toggle", s.handleToggleRule)
			protected.DELETE("/automation/rules/:id", s.handleDeleteRule)

			// Plugins
			protected.GET("/plugins", s.handleListPlugins)
			protected.POST("/plugins/:id/run", s.handleRunPlugin)
			protected.PUT("/plugins/:id/toggle", s.handleTogglePlugin)

			// Notifications
			protected.GET("/notifications", s.handleListNotifications)
			protected.POST("/notifications/:id/read", s.handleMarkRead)
		}
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Response helpers
// ─────────────────────────────────────────────────────────────────────────────

func success(c *gin.Context, data any) {
	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "OK",
		"data":    data,
	})
}

func fail(c *gin.Context, code int, message string) {
	c.JSON(code, gin.H{
		"success": false,
		"code":    code,
		"message": message,
	})
}

// ─────────────────────────────────────────────────────────────────────────────
// Auth handlers
// ─────────────────────────────────────────────────────────────────────────────

func (s *Server) handlePair(c *gin.Context) {
	var req struct {
		Code       string `json:"code" binding:"required"`
		DeviceName string `json:"device_name" binding:"required"`
		DeviceType string `json:"device_type" binding:"required"`
		OS         string `json:"os" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		fail(c, http.StatusBadRequest, "invalid request: "+err.Error())
		return
	}

	tokens, deviceID, err := s.auth.PairDevice(
		req.Code, req.DeviceName, req.DeviceType, req.OS, c.ClientIP(),
	)
	if err != nil {
		switch err {
		case auth.ErrCodeInvalid:
			fail(c, http.StatusBadRequest, "invalid pairing code")
		case auth.ErrCodeExpired:
			fail(c, http.StatusBadRequest, "pairing code expired or already used")
		default:
			s.log.Error("api", "pair_device", err)
			fail(c, http.StatusInternalServerError, "pairing failed")
		}
		return
	}

	s.bus.PublishAsync(events.NewEvent("api", events.EventDevicePaired, map[string]any{
		"device_id": deviceID,
		"device":    req.DeviceName,
		"ip":        c.ClientIP(),
	}))

	success(c, gin.H{
		"device_id":     deviceID,
		"access_token":  tokens.AccessToken,
		"refresh_token": tokens.RefreshToken,
		"expires_at":    tokens.ExpiresAt,
	})
}

func (s *Server) handleGenerateOTP(c *gin.Context) {
	otp, err := s.auth.GeneratePairingOTP()
	if err != nil {
		fail(c, http.StatusInternalServerError, "failed to generate OTP")
		return
	}
	success(c, gin.H{"otp": otp, "expires_in_seconds": 300})
}

func (s *Server) handleRefresh(c *gin.Context) {
	var req struct {
		DeviceID     string `json:"device_id" binding:"required"`
		RefreshToken string `json:"refresh_token" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		fail(c, http.StatusBadRequest, "invalid request")
		return
	}

	tokens, err := s.auth.Login(req.DeviceID, req.RefreshToken)
	if err != nil {
		switch err {
		case auth.ErrTokenExpired:
			fail(c, http.StatusUnauthorized, "token expired — re-pair required")
		case auth.ErrDeviceBlocked:
			fail(c, http.StatusForbidden, "device is blocked")
		default:
			fail(c, http.StatusUnauthorized, "unauthorized")
		}
		return
	}

	success(c, tokens)
}

func (s *Server) handleLogout(c *gin.Context) {
	claims := getClaims(c)
	if err := s.auth.RevokeDevice(claims.DeviceID); err != nil {
		fail(c, http.StatusInternalServerError, "logout failed")
		return
	}
	success(c, gin.H{"message": "logged out"})
}

func (s *Server) handleListDevices(c *gin.Context) {
	// TODO: query devices from DB
	success(c, []gin.H{})
}

func (s *Server) handleRevokeDevice(c *gin.Context) {
	deviceID := c.Param("id")
	if err := s.auth.RevokeDevice(deviceID); err != nil {
		fail(c, http.StatusInternalServerError, "revoke failed")
		return
	}
	success(c, gin.H{"message": "device revoked"})
}

// ─────────────────────────────────────────────────────────────────────────────
// System handlers
// ─────────────────────────────────────────────────────────────────────────────

func (s *Server) handleHealth(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"status":  "ok",
		"version": "1.0.0",
		"time":    time.Now().Format(time.RFC3339),
	})
}

func (s *Server) handleSystemInfo(c *gin.Context) {
	m := s.collector.Collect()
	success(c, gin.H{
		"os":           m.OS,
		"health_score": monitor.HealthScore(m),
		"uptime":       m.Uptime,
		"ws_clients":   s.hub.ConnectedCount(),
	})
}

func (s *Server) handleMetrics(c *gin.Context) {
	m := s.collector.Collect()
	success(c, gin.H{
		"cpu":          m.CPU,
		"ram":          m.RAM,
		"disk":         m.Disk,
		"network":      m.Network,
		"battery":      m.Battery,
		"gpu":          m.GPU,
		"temp":         m.Temp,
		"health_score": monitor.HealthScore(m),
		"timestamp":    m.Timestamp,
	})
}

// ─────────────────────────────────────────────────────────────────────────────
// Power handlers
// ─────────────────────────────────────────────────────────────────────────────

func (s *Server) handleShutdown(c *gin.Context) {
	var req struct {
		DelaySeconds int    `json:"delay_seconds"`
		Message      string `json:"message"`
	}
	c.ShouldBindJSON(&req)

	claims := getClaims(c)
	s.log.Info("api", "shutdown_requested", "dispatched",
		"user", claims.UserID, "device", claims.DeviceID,
		"delay", req.DelaySeconds)

	s.bus.PublishAsync(events.NewEvent("api", events.EventPowerShutdown, map[string]any{
		"delay":   req.DelaySeconds,
		"message": req.Message,
		"user":    claims.UserID,
	}))

	success(c, gin.H{
		"message":       "Shutdown scheduled",
		"delay_seconds": req.DelaySeconds,
	})
}

func (s *Server) handleRestart(c *gin.Context) {
	var req struct {
		DelaySeconds int `json:"delay_seconds"`
	}
	c.ShouldBindJSON(&req)

	claims := getClaims(c)
	s.log.Info("api", "restart_requested", "dispatched",
		"user", claims.UserID, "device", claims.DeviceID)

	s.bus.PublishAsync(events.NewEvent("api", events.EventPowerRestart, map[string]any{
		"delay": req.DelaySeconds,
		"user":  claims.UserID,
	}))

	success(c, gin.H{"message": "Restart scheduled"})
}

func (s *Server) handleSleep(c *gin.Context) {
	claims := getClaims(c)
	s.bus.PublishAsync(events.NewEvent("api", events.EventPowerSleep, map[string]any{
		"user": claims.UserID,
	}))
	success(c, gin.H{"message": "Sleep command sent"})
}

func (s *Server) handleLock(c *gin.Context) {
	claims := getClaims(c)
	s.bus.PublishAsync(events.NewEvent("api", events.EventPowerLock, map[string]any{
		"user": claims.UserID,
	}))
	success(c, gin.H{"message": "Lock command sent"})
}

// ─────────────────────────────────────────────────────────────────────────────
// Notification handlers
// ─────────────────────────────────────────────────────────────────────────────

func (s *Server) handleListNotifications(c *gin.Context) {
	success(c, []gin.H{})
}

func (s *Server) handleMarkRead(c *gin.Context) {
	success(c, gin.H{"message": "marked as read"})
}

// ─────────────────────────────────────────────────────────────────────────────
// WebSocket handler
// ─────────────────────────────────────────────────────────────────────────────

func (s *Server) handleWebSocket(c *gin.Context) {
	// Validate token from query param (WebSocket can't set headers easily)
	token := c.Query("token")
	if token == "" {
		fail(c, http.StatusUnauthorized, "missing token")
		return
	}

	claims, err := s.auth.ValidateAccessToken(token)
	if err != nil {
		fail(c, http.StatusUnauthorized, "invalid token")
		return
	}

	s.hub.ServeWS(c.Writer, c.Request, claims.DeviceID)
}

// ─────────────────────────────────────────────────────────────────────────────
// Middleware
// ─────────────────────────────────────────────────────────────────────────────

// authMiddleware validates JWT Bearer tokens.
func (s *Server) authMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			fail(c, http.StatusUnauthorized, "missing authorization header")
			c.Abort()
			return
		}

		parts := strings.SplitN(authHeader, " ", 2)
		if len(parts) != 2 || parts[0] != "Bearer" {
			fail(c, http.StatusUnauthorized, "invalid authorization format")
			c.Abort()
			return
		}

		claims, err := s.auth.ValidateAccessToken(parts[1])
		if err != nil {
			switch err {
			case auth.ErrTokenExpired:
				fail(c, http.StatusUnauthorized, "token expired")
			default:
				fail(c, http.StatusUnauthorized, "invalid token")
			}
			c.Abort()
			return
		}

		c.Set("claims", claims)
		c.Next()
	}
}

// corsMiddleware adds CORS headers for browser/Flutter Web access.
func corsMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Header("Access-Control-Allow-Origin", "*")
		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Authorization, Content-Type")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(http.StatusNoContent)
			return
		}
		c.Next()
	}
}

// requestLoggerMiddleware logs every incoming request.
func requestLoggerMiddleware(log *logger.Logger) gin.HandlerFunc {
	return func(c *gin.Context) {
		start := time.Now()
		c.Next()
		dur := time.Since(start)

		log.Info("api", c.Request.Method+" "+c.Request.URL.Path,
			http.StatusText(c.Writer.Status()),
			"status", c.Writer.Status(),
			"duration_ms", dur.Milliseconds(),
			"ip", c.ClientIP(),
		)
	}
}

// getClaims extracts auth claims from the Gin context.
func getClaims(c *gin.Context) *auth.Claims {
	val, _ := c.Get("claims")
	claims, _ := val.(*auth.Claims)
	return claims
}
