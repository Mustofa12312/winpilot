package automation

import (
	"encoding/json"
	"fmt"
	"sync"
	"time"

	"github.com/winpilot/agent/internal/events"
	"github.com/winpilot/agent/internal/logger"
	"github.com/winpilot/agent/internal/monitor"
	"github.com/winpilot/agent/internal/storage"
)

// Engine evaluates rules and triggers actions
type Engine struct {
	db     *storage.DB
	bus    *events.Bus
	log    *logger.Logger
	rules  []Rule
	mu     sync.RWMutex
	ticker *time.Ticker
	quit   chan struct{}
}

// NewEngine creates a new automation engine
func NewEngine(db *storage.DB, bus *events.Bus, log *logger.Logger) *Engine {
	return &Engine{
		db:   db,
		bus:  bus,
		log:  log,
		quit: make(chan struct{}),
	}
}

// Start begins the automation loops (scheduler)
func (e *Engine) Start() {
	e.LoadRules()

	e.ticker = time.NewTicker(1 * time.Minute)
	go func() {
		for {
			select {
			case <-e.ticker.C:
				e.evaluateSchedules()
			case <-e.quit:
				e.ticker.Stop()
				return
			}
		}
	}()
	e.log.Info("automation", "engine_started", "ok")
}

// Stop halts the automation engine
func (e *Engine) Stop() {
	close(e.quit)
}

// LoadRules reloads all rules from the database
func (e *Engine) LoadRules() {
	e.mu.Lock()
	defer e.mu.Unlock()

	// TODO: Load from SQLite table
	// e.rules = e.db.GetAutomationRules()
	
	// For now, start with empty rules
	e.rules = []Rule{}
}

// AddRule adds a new rule
func (e *Engine) AddRule(rule Rule) {
	e.mu.Lock()
	defer e.mu.Unlock()
	e.rules = append(e.rules, rule)
	// TODO: Save to SQLite
}

// ToggleRule enables or disables a rule
func (e *Engine) ToggleRule(id string, active bool) error {
	e.mu.Lock()
	defer e.mu.Unlock()
	for i, r := range e.rules {
		if r.ID == id {
			e.rules[i].IsActive = active
			return nil
		}
	}
	return fmt.Errorf("rule not found")
}

// DeleteRule removes a rule
func (e *Engine) DeleteRule(id string) {
	e.mu.Lock()
	defer e.mu.Unlock()
	for i, r := range e.rules {
		if r.ID == id {
			e.rules = append(e.rules[:i], e.rules[i+1:]...)
			return
		}
	}
}

// GetRules returns a copy of all rules
func (e *Engine) GetRules() []Rule {
	e.mu.RLock()
	defer e.mu.RUnlock()
	copyRules := make([]Rule, len(e.rules))
	copy(copyRules, e.rules)
	return copyRules
}

// EvaluateMetrics checks metric triggers against the current system state
func (e *Engine) EvaluateMetrics(m *monitor.Metrics) {
	e.mu.Lock()
	defer e.mu.Unlock()

	for i, rule := range e.rules {
		if !rule.IsActive || rule.TriggerType != "metric" {
			continue
		}

		var trigger MetricTrigger
		if err := json.Unmarshal([]byte(rule.TriggerData), &trigger); err != nil {
			continue
		}

		var currentValue float64
		switch trigger.Metric {
		case "cpu":
			currentValue = m.CPU.UsagePercent
		case "ram":
			currentValue = m.RAM.UsedPercent
		default:
			continue
		}

		triggered := false
		switch trigger.Operator {
		case ">":
			triggered = currentValue > trigger.Value
		case "<":
			triggered = currentValue < trigger.Value
		case "==":
			triggered = currentValue == trigger.Value
		}

		// Simple implementation without duration checking for now
		if triggered {
			// Cooldown of 5 minutes to prevent spam
			if time.Since(rule.LastFired) > 5*time.Minute {
				e.log.Info("automation", "rule_triggered", rule.Name, "value", currentValue)
				e.executeAction(rule)
				e.rules[i].LastFired = time.Now()
			}
		}
	}
}

func (e *Engine) evaluateSchedules() {
	e.mu.Lock()
	defer e.mu.Unlock()

	now := time.Now()
	for i, rule := range e.rules {
		if !rule.IsActive || rule.TriggerType != "schedule" {
			continue
		}

		var trigger ScheduleTrigger
		if err := json.Unmarshal([]byte(rule.TriggerData), &trigger); err != nil {
			continue
		}

		// Check if interval has passed since last fired (or if never fired, since creation)
		lastTime := rule.LastFired
		if lastTime.IsZero() {
			lastTime = rule.CreatedAt
		}

		if now.Sub(lastTime).Minutes() >= float64(trigger.IntervalMinutes) {
			e.log.Info("automation", "schedule_triggered", rule.Name)
			e.executeAction(rule)
			e.rules[i].LastFired = now
		}
	}
}

func (e *Engine) executeAction(rule Rule) {
	switch rule.ActionType {
	case "notification":
		var act NotificationAction
		if err := json.Unmarshal([]byte(rule.ActionData), &act); err == nil {
			e.bus.PublishAsync(events.NewEvent("automation", events.EventNotification, map[string]any{
				"title": act.Title,
				"body":  act.Body,
			}))
		}
	case "shutdown":
		e.bus.PublishAsync(events.NewEvent("automation", events.EventPowerShutdown, map[string]any{
			"delay":   60,
			"message": "Automated shutdown triggered by rule: " + rule.Name,
		}))
	case "sleep":
		e.bus.PublishAsync(events.NewEvent("automation", events.EventPowerSleep, nil))
	}
}
