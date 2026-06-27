# WinPilot v1.0 (Gold Master) 🚀
> **Your Personal Windows Control Center**

[![Go](https://img.shields.io/badge/Go-1.22+-00ADD8?style=flat&logo=go)](https://go.dev)
[![Flutter](https://img.shields.io/badge/Flutter-Stable-02569B?style=flat&logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
![Version](https://img.shields.io/badge/version-1.0_MVP-success.svg)
![Status](https://img.shields.io/badge/Status-100%25_Completed-brightgreen.svg)

WinPilot mengubah komputer Windows Anda menjadi **server pribadi** yang dapat dikontrol dari mana saja menggunakan aplikasi Flutter — tanpa cloud, tanpa biaya, tanpa kompromi privasi.

Misi utama (MVP) telah **100% Selesai**, merealisasikan seluruh ide dari *Product Requirements Document (PRD)* tanpa terkecuali!

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

## 🚀 Quick Start (Production Server)

### Setup Server Windows Anda

1. Unduh paket rilis terbaru `WinPilot-Server-v1.0.zip` (Berada di `build/release/`).
2. Ekstrak *file* ZIP tersebut ke direktori PC Windows Anda (misalnya `C:\WinPilot\`).
3. Jalankan `winpilot-start.bat` untuk menghidupkan agen secara senyap (*background*).
4. PC Anda kini siap menerima instruksi dari aplikasi WinPilot Mobile!

*(Untuk menghentikan agen, cukup jalankan `winpilot-stop.bat`).*

---

## 🛠 Panduan Developer (Build from Source)

### Prasyarat

- Go 1.22+
- Flutter Stable
- Windows 10/11 (Target) atau Linux (Development)

### Setup

```bash
# Clone
git clone https://github.com/winpilot/winpilot.git
cd winpilot

# Setup semua dependencies
make setup

# Buat paket Release Windows (EXE, Script, dan Android APK)
make release

# Jalankan agent (dev mode di terminal)
make agent-dev

# Jalankan aplikasi mobile
make flutter-run
```

Agent secara bawaan berjalan di `http://localhost:8080`.

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

## 🗺 Pencapaian PRD (100% Selesai)

Seluruh pilar utilitas sistem telah berhasil direalisasikan.

| Sprint | Modul yang Diselesaikan | Status |
|---|---|---|
| **Sprint 1-2** | Agent Core, Auth, SQLite, Flutter Dashboard, WebSocket | ✅ Selesai |
| **Sprint 3-4** | Task Manager, File Manager (Explorer), Terminal CLI | ✅ Selesai |
| **Sprint 5-7** | Automation (Rules), Plugin System (SDK) | ✅ Selesai |
| **Sprint 8-9** | Clipboard, Audio, Power, Service Manager, Printers, Apps | ✅ Selesai |
| **Sprint 10** | **AI Command Center** (Offline Intent Parser) | ✅ Selesai |
| **Sprint 11-12** | Download Manager, Device Hub, Network, OS Update, Display | ✅ Selesai |
| **Sprint 13** | Windows Cross-compilation & Release Packaging | ✅ Selesai |

---

## 📄 License

MIT © WinPilot Contributors
