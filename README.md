# WinPilot

> **Your Personal Windows Control Center**

[![Go](https://img.shields.io/badge/Go-1.22+-00ADD8?style=flat&logo=go)](https://go.dev)
[![Flutter](https://img.shields.io/badge/Flutter-Stable-02569B?style=flat&logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

WinPilot mengubah komputer Windows Anda menjadi **server pribadi** yang dapat dikontrol dari mana saja menggunakan aplikasi Flutter atau browser — tanpa cloud, tanpa biaya, tanpa kompromi privasi.

---

## ✨ Filosofi

| Prinsip | Keterangan |
|---|---|
| **Privacy First** | Semua data di komputer Anda. Tidak ada cloud wajib. |
| **Offline First** | Tetap berfungsi di jaringan lokal meski internet mati. |
| **Performance First** | Agent < 30MB RAM idle, < 0.2% CPU. |
| **Modular First** | Setiap fitur adalah plugin independen. |
| **User First** | Semua fungsi penting bisa diakses dari HP. |

---

## 🏗 Arsitektur

```
Flutter Android / Flutter Web
         │
   HTTPS + WebSocket
         │
┌────────────────────────┐
│   WinPilot Core (Go)   │
├────────────────────────┤
│ Authentication (JWT)   │
│ Plugin Manager         │
│ REST API (Gin)         │
│ WebSocket Hub          │
│ Event Bus (Pub/Sub)    │
│ Scheduler              │
│ SQLite Repository      │
│ Logging                │
└──────────┬─────────────┘
           │
    Windows API / PowerShell / WMI
           │
    Windows 10 / 11
```

---

## 🚀 Quick Start

### Prasyarat

- Go 1.22+
- Flutter Stable
- Windows 10/11 (untuk agent production) atau Linux (untuk development)

### Setup

```bash
# Clone
git clone https://github.com/winpilot/winpilot.git
cd winpilot

# Setup semua dependencies
make setup

# Jalankan agent (dev mode)
make agent-dev

# Di terminal lain, jalankan Flutter
make flutter-run
```

Agent akan berjalan di `http://localhost:8080`.

---

## 📂 Struktur Proyek

```
winpilot/
├── agent/                 # Go Agent (Windows Service)
│   ├── cmd/winpilot/      # Entry point
│   └── internal/
│       ├── api/           # REST API (Gin)
│       ├── auth/          # JWT + Pairing
│       ├── config/        # Configuration
│       ├── core/          # Bootstrap engine
│       ├── events/        # Event Bus (pub/sub)
│       ├── logger/        # Structured logger
│       ├── monitor/       # System metrics
│       ├── storage/       # SQLite + migrations
│       └── websocket/     # WebSocket hub
│
├── mobile/                # Flutter App (Android + Web)
│   └── lib/
│       ├── core/          # Theme, routing, HTTP client
│       ├── modules/
│       │   ├── auth/      # Login + Pairing screens
│       │   └── dashboard/ # Mission Control
│       └── shared/        # Reusable widgets
│
├── plugins/               # Plugin modules
│   ├── power/
│   ├── system/
│   ├── file/
│   └── printer/
│
├── docs/                  # Documentation & PRDs
├── Makefile
└── README.md
```

---

## 🔌 API Endpoints (v1)

| Method | Endpoint | Deskripsi |
|---|---|---|
| `POST` | `/api/v1/auth/pair` | Pairing perangkat baru |
| `POST` | `/api/v1/auth/pair/otp` | Generate kode OTP |
| `POST` | `/api/v1/auth/refresh` | Refresh JWT token |
| `DELETE` | `/api/v1/auth/logout` | Logout perangkat |
| `GET` | `/api/v1/system` | Info sistem + health score |
| `GET` | `/api/v1/metrics` | CPU, RAM, disk, network realtime |
| `POST` | `/api/v1/power/shutdown` | Shutdown Windows |
| `POST` | `/api/v1/power/restart` | Restart Windows |
| `POST` | `/api/v1/power/sleep` | Sleep mode |
| `POST` | `/api/v1/power/lock` | Lock screen |
| `WS` | `/ws?token=<jwt>` | WebSocket realtime events |

---

## 🔒 Keamanan

- Semua komunikasi via HTTPS/TLS
- JWT HS256 dengan Access + Refresh Token
- Device pairing wajib sebelum akses
- Permission granular per device
- Rate limiting on login
- Semua aksi sensitif tercatat di audit log

---

## 🗺 Roadmap

| Sprint | Target |
|---|---|
| **Sprint 1** ✅ | Agent core, Auth, Metrics, Flutter Dashboard |
| **Sprint 2** | File Explorer, Clipboard, Printer, Audio |
| **Sprint 3** | Monitoring Center, Notifications, Download Manager |
| **Sprint 4** | Automation Engine, Workflow Builder, Scheduler |
| **Sprint 5** | Plugin SDK, Developer Tools |
| **Sprint 6** | AI Command, Optimization, Testing |

---

## 📄 License

MIT © WinPilot Contributors
