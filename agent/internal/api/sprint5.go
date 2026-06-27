package api

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// ─────────────────────────────────────────────────────────────────────────────
// Plugin SDK Engine
// ─────────────────────────────────────────────────────────────────────────────

func (s *Server) handleListPlugins(c *gin.Context) {
	if s.pluginManager == nil {
		fail(c, http.StatusNotImplemented, "Plugin manager not initialized")
		return
	}
	success(c, s.pluginManager.GetPlugins())
}

func (s *Server) handleRunPlugin(c *gin.Context) {
	if s.pluginManager == nil {
		fail(c, http.StatusNotImplemented, "Plugin manager not initialized")
		return
	}

	id := c.Param("id")
	output, err := s.pluginManager.RunPlugin(id)

	if err != nil {
		// Even on error, we might have partial stdout/stderr output we want to return
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": err.Error(),
			"output":  output,
		})
		return
	}

	success(c, gin.H{
		"message": "Plugin executed successfully",
		"output":  output,
	})
}

func (s *Server) handleTogglePlugin(c *gin.Context) {
	if s.pluginManager == nil {
		fail(c, http.StatusNotImplemented, "Plugin manager not initialized")
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

	if err := s.pluginManager.TogglePlugin(id, req.IsActive); err != nil {
		fail(c, http.StatusNotFound, err.Error())
		return
	}

	success(c, gin.H{"message": "Plugin toggled successfully"})
}
