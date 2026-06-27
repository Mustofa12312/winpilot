package api

import (
	"context"
	"net/http"
	"os/exec"
	"runtime"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
)

// ─────────────────────────────────────────────────────────────────────────────
// Terminal Engine
// ─────────────────────────────────────────────────────────────────────────────

func (s *Server) handleTerminalExecute(c *gin.Context) {
	var req struct {
		Command string `json:"command"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		fail(c, http.StatusBadRequest, "Invalid request payload")
		return
	}

	cmdStr := strings.TrimSpace(req.Command)
	if cmdStr == "" {
		fail(c, http.StatusBadRequest, "Command cannot be empty")
		return
	}

	// 10 seconds timeout for standard commands
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var cmd *exec.Cmd
	if runtime.GOOS == "windows" {
		cmd = exec.CommandContext(ctx, "cmd", "/c", cmdStr)
	} else {
		cmd = exec.CommandContext(ctx, "bash", "-c", cmdStr)
	}

	out, err := cmd.CombinedOutput()
	outputStr := string(out)

	if err != nil {
		if ctx.Err() == context.DeadlineExceeded {
			outputStr += "\n\n[Timeout: Command exceeded 10 seconds execution limit]"
		}
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": err.Error(),
			"output":  outputStr,
		})
		return
	}

	success(c, gin.H{
		"message": "Command executed successfully",
		"output":  outputStr,
	})
}
