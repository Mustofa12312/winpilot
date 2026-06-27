## WinPilot Development Makefile
## Usage: make <target>

GO := $(shell which go 2>/dev/null || echo ~/go/bin/go)
FLUTTER := $(shell which flutter 2>/dev/null || echo ~/flutter/bin/flutter)
AGENT_DIR := agent
MOBILE_DIR := mobile
BUILD_DIR := build

.PHONY: all agent flutter clean run-agent test help

all: agent flutter

## Agent
agent:
	@echo "🔨 Building WinPilot Agent..."
	@cd $(AGENT_DIR) && $(GO) build -o ../$(BUILD_DIR)/winpilot-agent ./cmd/winpilot/
	@echo "✅ Agent built: $(BUILD_DIR)/winpilot-agent"

agent-dev:
	@echo "🚀 Running WinPilot Agent (dev mode)..."
	@cd $(AGENT_DIR) && $(GO) run ./cmd/winpilot/

agent-test:
	@echo "🧪 Testing Agent..."
	@cd $(AGENT_DIR) && $(GO) test ./... -v

agent-tidy:
	@cd $(AGENT_DIR) && $(GO) mod tidy

## Flutter
flutter:
	@echo "🔨 Building Flutter Mobile..."
	@cd $(MOBILE_DIR) && $(FLUTTER) build apk --release
	@echo "✅ APK built: $(MOBILE_DIR)/build/app/outputs/flutter-apk/app-release.apk"

flutter-run:
	@echo "📱 Running Flutter in debug mode..."
	@cd $(MOBILE_DIR) && $(FLUTTER) run

flutter-web:
	@echo "🌐 Running Flutter Web..."
	@cd $(MOBILE_DIR) && $(FLUTTER) run -d web-server --web-port=3000

flutter-analyze:
	@cd $(MOBILE_DIR) && $(FLUTTER) analyze --no-fatal-infos

flutter-test:
	@cd $(MOBILE_DIR) && $(FLUTTER) test

## Development
dev:
	@make -j2 agent-dev flutter-run

## Clean
clean:
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)
	@cd $(MOBILE_DIR) && $(FLUTTER) clean
	@echo "✅ Cleaned"

## Setup
setup:
	@echo "🛠 Setting up WinPilot development environment..."
	@mkdir -p $(BUILD_DIR)
	@cd $(AGENT_DIR) && $(GO) mod tidy
	@cd $(MOBILE_DIR) && $(FLUTTER) pub get
	@echo "✅ Setup complete. Run 'make agent-dev' to start the agent."

## Help
help:
	@echo ""
	@echo "  WinPilot — Your Personal Windows Control Center"
	@echo ""
	@echo "  Usage: make <target>"
	@echo ""
	@echo "  Agent:"
	@echo "    make agent         Build Go agent binary"
	@echo "    make agent-dev     Run agent in dev mode (hot reload)"
	@echo "    make agent-test    Run Go unit tests"
	@echo ""
	@echo "  Flutter:"
	@echo "    make flutter       Build release APK"
	@echo "    make flutter-run   Run on connected device"
	@echo "    make flutter-web   Run as web app on :3000"
	@echo ""
	@echo "  General:"
	@echo "    make setup         Install all dependencies"
	@echo "    make clean         Clean build artifacts"
	@echo "    make help          Show this help"
	@echo ""
