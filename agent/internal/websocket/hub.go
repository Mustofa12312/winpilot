// Package websocket implements the WinPilot WebSocket hub.
// Every connected client receives realtime events from the Event Bus.
package websocket

import (
	"encoding/json"
	"net/http"
	"sync"
	"time"

	"github.com/gorilla/websocket"
	"github.com/winpilot/agent/internal/events"
	"github.com/winpilot/agent/internal/logger"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 4096,
	// In production, validate Origin here
	CheckOrigin: func(r *http.Request) bool { return true },
}

// Message is the envelope sent to WebSocket clients.
type Message struct {
	Type      string         `json:"type"`
	Data      map[string]any `json:"data"`
	Timestamp time.Time      `json:"timestamp"`
}

// Client represents a connected WebSocket client.
type Client struct {
	conn     *websocket.Conn
	send     chan []byte
	deviceID string
	hub      *Hub
}

// Hub manages all WebSocket connections.
type Hub struct {
	mu      sync.RWMutex
	clients map[*Client]bool
	log     *logger.Logger
}

// NewHub creates a new WebSocket Hub.
func NewHub(log *logger.Logger) *Hub {
	return &Hub{
		clients: make(map[*Client]bool),
		log:     log,
	}
}

// SubscribeToEvents connects the Hub to the Event Bus so all events
// are automatically broadcast to connected clients.
func (h *Hub) SubscribeToEvents(bus *events.Bus) {
	bus.SubscribeAll(func(evt events.Event) {
		h.Broadcast(Message{
			Type:      string(evt.Type),
			Data:      evt.Data,
			Timestamp: evt.Timestamp,
		})
	})
}

// ServeWS upgrades an HTTP connection to WebSocket.
func (h *Hub) ServeWS(w http.ResponseWriter, r *http.Request, deviceID string) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		h.log.Error("websocket", "upgrade", err)
		return
	}

	client := &Client{
		conn:     conn,
		send:     make(chan []byte, 64),
		deviceID: deviceID,
		hub:      h,
	}

	h.register(client)

	go client.writePump()
	go client.readPump()

	h.log.Info("websocket", "client_connected", "ok", "device", deviceID)
}

// Broadcast sends a message to all connected clients.
func (h *Hub) Broadcast(msg Message) {
	data, err := json.Marshal(msg)
	if err != nil {
		return
	}

	h.mu.RLock()
	clients := make([]*Client, 0, len(h.clients))
	for c := range h.clients {
		clients = append(clients, c)
	}
	h.mu.RUnlock()

	for _, c := range clients {
		select {
		case c.send <- data:
		default:
			// Slow client — drop and disconnect
			h.unregister(c)
		}
	}
}

// ConnectedCount returns the number of active WebSocket connections.
func (h *Hub) ConnectedCount() int {
	h.mu.RLock()
	defer h.mu.RUnlock()
	return len(h.clients)
}

func (h *Hub) register(c *Client) {
	h.mu.Lock()
	defer h.mu.Unlock()
	h.clients[c] = true
}

func (h *Hub) unregister(c *Client) {
	h.mu.Lock()
	defer h.mu.Unlock()
	if _, ok := h.clients[c]; ok {
		delete(h.clients, c)
		close(c.send)
	}
}

// writePump sends queued messages to the WebSocket connection.
func (c *Client) writePump() {
	ticker := time.NewTicker(30 * time.Second)
	defer func() {
		ticker.Stop()
		c.conn.Close()
		c.hub.unregister(c)
	}()

	for {
		select {
		case msg, ok := <-c.send:
			c.conn.SetWriteDeadline(time.Now().Add(10 * time.Second))
			if !ok {
				c.conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}
			if err := c.conn.WriteMessage(websocket.TextMessage, msg); err != nil {
				return
			}

		case <-ticker.C:
			// Ping to keep connection alive
			c.conn.SetWriteDeadline(time.Now().Add(10 * time.Second))
			if err := c.conn.WriteMessage(websocket.PingMessage, nil); err != nil {
				return
			}
		}
	}
}

// readPump reads from the connection (handles pong, close messages).
func (c *Client) readPump() {
	defer func() {
		c.hub.unregister(c)
		c.conn.Close()
	}()

	c.conn.SetReadLimit(512)
	c.conn.SetReadDeadline(time.Now().Add(60 * time.Second))
	c.conn.SetPongHandler(func(string) error {
		c.conn.SetReadDeadline(time.Now().Add(60 * time.Second))
		return nil
	})

	for {
		_, _, err := c.conn.ReadMessage()
		if err != nil {
			break
		}
	}
}
