package api

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/winpilot/agent/internal/windows"
)

// ─────────────────────────────────────────────────────────────────────────────
// Processes (Task Manager)
// ─────────────────────────────────────────────────────────────────────────────

func (s *Server) handleListProcesses(c *gin.Context) {
	procs, err := windows.ListProcesses()
	if err != nil {
		fail(c, http.StatusInternalServerError, err.Error())
		return
	}
	success(c, procs)
}

func (s *Server) handleKillProcess(c *gin.Context) {
	pidStr := c.Param("pid")
	pid, err := strconv.Atoi(pidStr)
	if err != nil {
		fail(c, http.StatusBadRequest, "invalid PID")
		return
	}

	if err := windows.KillProcess(pid); err != nil {
		fail(c, http.StatusInternalServerError, err.Error())
		return
	}

	success(c, gin.H{"message": "Process terminated"})
}
