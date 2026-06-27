// WinPilot Agent — Entry Point
// Your Personal Windows Control Center
package main

import (
	"context"
	"flag"
	"fmt"
	"os"
	"os/signal"
	"syscall"

	"github.com/winpilot/agent/internal/config"
	"github.com/winpilot/agent/internal/core"
)

func main() {
	configPath := flag.String("config", "config.json", "Path to configuration file")
	flag.Parse()

	// Load configuration
	cfg, err := config.Load(*configPath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to load config: %v\n", err)
		os.Exit(1)
	}

	// Create agent
	agent, err := core.New(cfg)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to initialize agent: %v\n", err)
		os.Exit(1)
	}

	// Setup graceful shutdown
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, os.Interrupt, syscall.SIGTERM)

	go func() {
		<-sigCh
		fmt.Println("\n⚡ Shutdown signal received...")
		cancel()
	}()

	// Run blocking
	if err := agent.Run(ctx); err != nil {
		fmt.Fprintf(os.Stderr, "Agent error: %v\n", err)
		os.Exit(1)
	}
}
