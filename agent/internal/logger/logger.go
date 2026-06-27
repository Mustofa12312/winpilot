// Package logger provides structured logging for WinPilot Agent.
// Every log entry has: Time, Level, Module, Action, Result, Duration.
package logger

import (
	"fmt"
	"io"
	"log/slog"
	"os"
	"path/filepath"
	"time"
)

// Level represents log severity.
type Level string

const (
	LevelDebug Level = "debug"
	LevelInfo  Level = "info"
	LevelWarn  Level = "warn"
	LevelError Level = "error"
)

// Logger is the WinPilot structured logger.
type Logger struct {
	slog *slog.Logger
	dir  string
}

// Entry represents a single structured log event.
type Entry struct {
	Module   string
	Action   string
	Result   string
	Duration time.Duration
	Error    error
	Extra    map[string]any
}

// New creates a logger writing to stdout and optionally to a log file.
func New(level Level, format string, logDir string) *Logger {
	var handler slog.Handler
	var writers []io.Writer
	writers = append(writers, os.Stdout)

	// Create log directory if needed
	if logDir != "" {
		if err := os.MkdirAll(logDir, 0755); err == nil {
			logPath := filepath.Join(logDir, fmt.Sprintf("winpilot-%s.log", time.Now().Format("2006-01-02")))
			f, err := os.OpenFile(logPath, os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0644)
			if err == nil {
				writers = append(writers, f)
			}
		}
	}

	w := io.MultiWriter(writers...)

	slogLevel := slog.LevelInfo
	switch level {
	case LevelDebug:
		slogLevel = slog.LevelDebug
	case LevelWarn:
		slogLevel = slog.LevelWarn
	case LevelError:
		slogLevel = slog.LevelError
	}

	opts := &slog.HandlerOptions{Level: slogLevel}
	if format == "json" {
		handler = slog.NewJSONHandler(w, opts)
	} else {
		handler = slog.NewTextHandler(w, opts)
	}

	return &Logger{
		slog: slog.New(handler),
		dir:  logDir,
	}
}

// Info logs an informational entry.
func (l *Logger) Info(module, action, result string, extra ...any) {
	args := append([]any{
		"module", module,
		"action", action,
		"result", result,
	}, extra...)
	l.slog.Info("", args...)
}

// Debug logs a debug entry.
func (l *Logger) Debug(module, action, result string, extra ...any) {
	args := append([]any{
		"module", module,
		"action", action,
		"result", result,
	}, extra...)
	l.slog.Debug("", args...)
}

// Warn logs a warning entry.
func (l *Logger) Warn(module, action, result string, extra ...any) {
	args := append([]any{
		"module", module,
		"action", action,
		"result", result,
	}, extra...)
	l.slog.Warn("", args...)
}

// Error logs an error entry.
func (l *Logger) Error(module, action string, err error, extra ...any) {
	args := append([]any{
		"module", module,
		"action", action,
		"error", err.Error(),
	}, extra...)
	l.slog.Error("", args...)
}

// Timed logs an action with its duration.
func (l *Logger) Timed(module, action string, fn func() error) {
	start := time.Now()
	err := fn()
	dur := time.Since(start)

	if err != nil {
		l.slog.Error("",
			"module", module,
			"action", action,
			"result", "failed",
			"duration_ms", dur.Milliseconds(),
			"error", err.Error(),
		)
		return
	}
	l.slog.Info("",
		"module", module,
		"action", action,
		"result", "ok",
		"duration_ms", dur.Milliseconds(),
	)
}
