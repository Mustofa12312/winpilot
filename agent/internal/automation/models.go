package automation

import (
	"time"
)

// Rule represents an automation workflow (If This -> Then That)
type Rule struct {
	ID          string    `json:"id"`
	Name        string    `json:"name"`
	IsActive    bool      `json:"is_active"`
	TriggerType string    `json:"trigger_type"` // "metric", "schedule"
	TriggerData string    `json:"trigger_data"` // JSON representing trigger conditions
	ActionType  string    `json:"action_type"`  // "notification", "shutdown", "sleep"
	ActionData  string    `json:"action_data"`  // JSON representing action payload
	CreatedAt   time.Time `json:"created_at"`
	LastFired   time.Time `json:"last_fired"`
}

// MetricTrigger defines a condition based on system metrics
type MetricTrigger struct {
	Metric   string  `json:"metric"`   // "cpu", "ram"
	Operator string  `json:"operator"` // ">", "<", "=="
	Value    float64 `json:"value"`
	Duration int     `json:"duration"` // Seconds the condition must hold before firing
}

// ScheduleTrigger defines a condition based on time
type ScheduleTrigger struct {
	IntervalMinutes int `json:"interval_minutes"`
}

// NotificationAction defines sending a notification to the app
type NotificationAction struct {
	Title string `json:"title"`
	Body  string `json:"body"`
}
