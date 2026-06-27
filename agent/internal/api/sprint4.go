package api

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/winpilot/agent/internal/automation"
)

// ─────────────────────────────────────────────────────────────────────────────
// Automation Engine
// ─────────────────────────────────────────────────────────────────────────────

func (s *Server) handleListRules(c *gin.Context) {
	if s.automationEngine == nil {
		fail(c, http.StatusNotImplemented, "Automation engine not initialized")
		return
	}
	success(c, s.automationEngine.GetRules())
}

func (s *Server) handleCreateRule(c *gin.Context) {
	if s.automationEngine == nil {
		fail(c, http.StatusNotImplemented, "Automation engine not initialized")
		return
	}

	var req struct {
		Name        string `json:"name" binding:"required"`
		TriggerType string `json:"trigger_type" binding:"required"`
		TriggerData string `json:"trigger_data" binding:"required"`
		ActionType  string `json:"action_type" binding:"required"`
		ActionData  string `json:"action_data" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		fail(c, http.StatusBadRequest, err.Error())
		return
	}

	rule := automation.Rule{
		ID:          uuid.New().String(),
		Name:        req.Name,
		IsActive:    true,
		TriggerType: req.TriggerType,
		TriggerData: req.TriggerData,
		ActionType:  req.ActionType,
		ActionData:  req.ActionData,
		CreatedAt:   time.Now(),
	}

	s.automationEngine.AddRule(rule)
	success(c, rule)
}

func (s *Server) handleToggleRule(c *gin.Context) {
	if s.automationEngine == nil {
		fail(c, http.StatusNotImplemented, "Automation engine not initialized")
		return
	}

	id := c.Param("id")
	var req struct {
		IsActive bool `json:"is_active"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		fail(c, http.StatusBadRequest, err.Error())
		return
	}

	if err := s.automationEngine.ToggleRule(id, req.IsActive); err != nil {
		fail(c, http.StatusNotFound, err.Error())
		return
	}

	success(c, gin.H{"message": "Rule toggled successfully"})
}

func (s *Server) handleDeleteRule(c *gin.Context) {
	if s.automationEngine == nil {
		fail(c, http.StatusNotImplemented, "Automation engine not initialized")
		return
	}

	id := c.Param("id")
	s.automationEngine.DeleteRule(id)
	success(c, gin.H{"message": "Rule deleted successfully"})
}
