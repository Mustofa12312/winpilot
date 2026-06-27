// Package events implements the WinPilot internal pub/sub Event Bus.
// All modules communicate exclusively via events — no direct calls between plugins.
package events

import (
	"sync"
	"time"
)

// EventType is the type of a system event.
type EventType string

// Core system events.
const (
	// System events
	EventSystemStarted  EventType = "system.started"
	EventSystemStopping EventType = "system.stopping"

	// Auth events
	EventDevicePaired   EventType = "auth.device.paired"
	EventDeviceRevoked  EventType = "auth.device.revoked"
	EventLoginSuccess   EventType = "auth.login.success"
	EventLoginFailed    EventType = "auth.login.failed"

	// Power events
	EventPowerShutdown  EventType = "power.shutdown"
	EventPowerRestart   EventType = "power.restart"
	EventPowerSleep     EventType = "power.sleep"
	EventPowerLock      EventType = "power.lock"

	// File events
	EventFileCreated    EventType = "file.created"
	EventFileDeleted    EventType = "file.deleted"
	EventFileChanged    EventType = "file.changed"
	EventUploadComplete EventType = "file.upload.complete"
	EventDownloadComplete EventType = "file.download.complete"

	// Printer events
	EventPrinterOnline  EventType = "printer.online"
	EventPrinterOffline EventType = "printer.offline"
	EventPrintComplete  EventType = "printer.print.complete"

	// Monitoring events
	EventCPUHigh        EventType = "monitor.cpu.high"
	EventRAMHigh        EventType = "monitor.ram.high"
	EventDiskLow        EventType = "monitor.disk.low"
	EventTempHigh       EventType = "monitor.temp.high"

	// USB / Device events
	EventUSBConnected    EventType = "device.usb.connected"
	EventUSBDisconnected EventType = "device.usb.disconnected"

	// Plugin events
	EventPluginLoaded   EventType = "plugin.loaded"
	EventPluginCrashed  EventType = "plugin.crashed"
	EventPluginDisabled EventType = "plugin.disabled"

	// Notification
	EventNotification EventType = "notification"
)

// Event is a message published on the bus.
type Event struct {
	Type      EventType      `json:"type"`
	Source    string         `json:"source"`    // module that published
	Timestamp time.Time      `json:"timestamp"`
	Data      map[string]any `json:"data"`
}

// Handler is a function that handles an event.
type Handler func(Event)

// Bus is a thread-safe in-process pub/sub event bus.
type Bus struct {
	mu          sync.RWMutex
	subscribers map[EventType][]Handler
	wildcard    []Handler // receive all events
}

// New creates a new Event Bus.
func New() *Bus {
	return &Bus{
		subscribers: make(map[EventType][]Handler),
	}
}

// Subscribe registers a handler for a specific event type.
func (b *Bus) Subscribe(eventType EventType, handler Handler) {
	b.mu.Lock()
	defer b.mu.Unlock()
	b.subscribers[eventType] = append(b.subscribers[eventType], handler)
}

// SubscribeAll registers a handler that receives every event.
func (b *Bus) SubscribeAll(handler Handler) {
	b.mu.Lock()
	defer b.mu.Unlock()
	b.wildcard = append(b.wildcard, handler)
}

// Publish sends an event to all registered subscribers.
// Handlers are called synchronously to preserve ordering.
func (b *Bus) Publish(evt Event) {
	if evt.Timestamp.IsZero() {
		evt.Timestamp = time.Now()
	}

	b.mu.RLock()
	handlers := make([]Handler, len(b.subscribers[evt.Type]))
	copy(handlers, b.subscribers[evt.Type])
	wildcards := make([]Handler, len(b.wildcard))
	copy(wildcards, b.wildcard)
	b.mu.RUnlock()

	for _, h := range handlers {
		h(evt)
	}
	for _, h := range wildcards {
		h(evt)
	}
}

// PublishAsync sends an event in a goroutine — fire and forget.
func (b *Bus) PublishAsync(evt Event) {
	go b.Publish(evt)
}

// NewEvent is a convenience constructor.
func NewEvent(source string, eventType EventType, data map[string]any) Event {
	return Event{
		Type:      eventType,
		Source:    source,
		Timestamp: time.Now(),
		Data:      data,
	}
}
