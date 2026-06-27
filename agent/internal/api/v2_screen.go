package api

import (
	"bytes"
	"image/jpeg"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/kbinani/screenshot"
)

// handleScreenCapture captures the main display and returns a JPEG image.
func (s *Server) handleScreenCapture(c *gin.Context) {
	n := screenshot.NumActiveDisplays()
	if n <= 0 {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "No active display found"})
		return
	}

	// Capture the first display
	bounds := screenshot.GetDisplayBounds(0)
	img, err := screenshot.CaptureRect(bounds)
	if err != nil {
		s.log.Error("api", "screen_capture", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Capture failed"})
		return
	}

	// Encode to JPEG in memory
	var buf bytes.Buffer
	err = jpeg.Encode(&buf, img, &jpeg.Options{Quality: 60}) // Low quality for fast streaming over LAN
	if err != nil {
		s.log.Error("api", "screen_encode", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Encoding failed"})
		return
	}

	// Send raw JPEG bytes
	c.Data(http.StatusOK, "image/jpeg", buf.Bytes())
}
