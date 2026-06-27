# 📘 PRD-001 — WinPilot

## Product Foundation & System Architecture

**Version:** 1.0
**Status:** Draft
**Project Name:** WinPilot
**Tagline:** _Your Personal Windows Control Center_

---

# 1. Product Vision

## Visi

Membangun platform yang mengubah komputer Windows menjadi **server pribadi (Private Windows Server)** yang dapat dikontrol dari mana saja menggunakan aplikasi Flutter atau browser, dengan fokus pada:

- Ringan
- Aman
- Cepat
- Modular
- Gratis
- Tidak bergantung pada cloud

WinPilot bukan sekadar aplikasi remote desktop, tetapi sebuah **platform manajemen Windows** yang memungkinkan pengguna mengelola komputer, file, printer, aplikasi, layanan sistem, dan otomatisasi secara real-time.

---

# 2. Product Philosophy

WinPilot dibangun berdasarkan lima prinsip utama:

### Privacy First

Semua data tetap berada di komputer pengguna. Tidak ada penyimpanan wajib di cloud.

### Offline First

Tetap berfungsi di jaringan lokal meskipun internet tidak tersedia.

### Performance First

Agent harus berjalan sangat ringan agar tidak mengganggu penggunaan sehari-hari.

### Modular First

Setiap fitur dapat ditambahkan atau dihapus melalui sistem plugin.

### User First

Semua fungsi penting dapat diakses dari HP, browser, atau perangkat lain dengan pengalaman penggunaan yang konsisten.

---

# 3. Product Goals

## Tujuan Utama

- Mengelola Windows dari mana saja.
- Mengurangi kebutuhan remote desktop penuh untuk tugas administratif.
- Memberikan kontrol penuh terhadap file, printer, proses, layanan, dan perangkat keras.
- Menjadi platform yang mudah dikembangkan melalui plugin.

---

# 4. Non Goals

Versi pertama tidak akan berfokus pada:

- Cloud Storage bawaan.
- Kolaborasi publik.
- Marketplace plugin online.
- Sinkronisasi lintas akun.
- Dukungan Linux/macOS sebagai Agent.

Semua fitur tersebut dapat dipertimbangkan di masa depan.

---

# 5. Target User

### Personal User

Pengguna yang ingin mengakses komputer pribadi dari HP atau perangkat lain.

### Power User

Pengguna yang membutuhkan kontrol mendalam terhadap sistem Windows.

### Developer

Pengembang yang ingin menambahkan plugin atau mengotomatisasi pekerjaan melalui API.

---

# 6. Core Principles

1. Tidak bergantung pada cloud.
2. Semua komunikasi terenkripsi.
3. Semua modul dapat dinonaktifkan.
4. Konsumsi RAM rendah.
5. CPU idle mendekati nol.
6. UI sederhana dan modern.
7. Semua fitur dapat diakses dari perangkat mobile.

---

# 7. High Level Architecture

```text
┌─────────────────────────────┐
│ Flutter Android             │
├─────────────────────────────┤
│ Flutter Web                 │
├─────────────────────────────┤
│ Flutter Desktop (Future)    │
└──────────────┬──────────────┘
               │
     HTTPS / WebSocket
               │
┌──────────────▼──────────────┐
│ WinPilot Agent (Go)         │
├─────────────────────────────┤
│ Authentication              │
│ Plugin Manager              │
│ REST API                    │
│ WebSocket                   │
│ Command Dispatcher          │
└──────────────┬──────────────┘
               │
Windows API / PowerShell / WMI
               │
┌──────────────▼──────────────┐
│ Windows 11                  │
└─────────────────────────────┘
```

---

# 8. Technology Stack

### Frontend

- Flutter
- GetX
- Material 3
- Responsive UI

### Backend

- Go (Golang)

### Database

- SQLite

### Communication

- REST API
- WebSocket

### Serialization

- JSON

### Authentication

- JWT
- Refresh Token
- Device Pairing

### Local Storage

- SQLite
- JSON Config

---

# 9. Performance Targets

## Windows Agent

RAM Idle

```
< 30 MB
```

RAM Aktif

```
< 80 MB
```

CPU Idle

```
< 0.2%
```

CPU Monitoring

```
< 1%
```

Startup Time

```
< 2 detik
```

Reconnect

```
< 3 detik
```

---

# 10. Supported Platforms

### Agent

- Windows 11
- Windows 10

### Client

- Android
- Browser
- Windows Desktop (Future)
- Linux Desktop (Future)

---

# 11. Security Principles

Semua komunikasi menggunakan HTTPS/TLS.

Setiap perangkat harus dipasangkan (pairing) sebelum dapat mengakses Agent.

Setiap perangkat memiliki token unik.

Hak akses dapat diatur berdasarkan perangkat dan pengguna.

Semua aktivitas penting dicatat dalam audit log.

Tidak ada akses anonim.

---

# 12. Module Architecture

## Core Modules

- Authentication
- API Server
- WebSocket Server
- Plugin Manager
- Configuration Manager
- Event Bus
- Notification Manager
- Logging
- Scheduler

## System Modules

- File Manager
- Process Manager
- Printer Manager
- Clipboard Manager
- Audio Manager
- Power Manager
- Network Manager
- Service Manager
- Task Manager
- Device Manager

## Advanced Modules

- Automation Engine
- AI Command
- Plugin SDK
- Dashboard
- Live Monitoring

---

# 13. Folder Structure

```text
winpilot/

├── agent/
├── mobile/
├── web/
├── shared/
├── docs/
├── sdk/
├── plugins/
├── installer/
├── scripts/
├── assets/
└── tests/
```

---

# 14. Coding Standards

## Backend

- Clean Architecture
- SOLID
- Dependency Injection
- Interface Based Design

## Flutter

- Feature First Structure
- GetX
- Repository Pattern
- Responsive Layout
- Material 3

---

# 15. Design Language

UI akan menggunakan:

- Glassmorphism ringan.
- Material 3.
- Animasi halus.
- Ikon sederhana.
- Tema Light & Dark.
- Aksen warna yang dapat diubah.

Tujuannya adalah tampilan profesional, modern, namun tetap ringan.

---

# 16. Roadmap Pengembangan

### Fase 1 — Pondasi

- Windows Agent.
- Login.
- Pairing perangkat.
- Dashboard dasar.

### Fase 2 — Kontrol Sistem

- File Explorer.
- Printer.
- Audio.
- Clipboard.
- Power.
- Proses.

### Fase 3 — Monitoring

- CPU.
- RAM.
- Disk.
- Jaringan.
- GPU.
- Suhu.

### Fase 4 — Otomasi

- Scheduler.
- Workflow.
- Event Trigger.
- Notifikasi.

### Fase 5 — Ekosistem

- Plugin SDK.
- API publik.
- AI Command.
- Aplikasi desktop.
- Dukungan multi-komputer.

# 📘 PRD-002

# WinPilot Windows Agent

Version 1.0

---

# 1. Tujuan

WinPilot Agent adalah aplikasi yang berjalan di Windows sebagai **Windows Service**.

Tugas utamanya:

- Menjadi server lokal.
- Menghubungkan HP/Web ke Windows.
- Menjalankan command.
- Mengelola plugin.
- Mengirim data realtime.
- Menjaga keamanan.

Agent **tidak memiliki UI utama**. Semua kontrol dilakukan dari aplikasi Flutter atau browser.

---

# 2. Filosofi Agent

Agent bukan aplikasi desktop.

Agent adalah **Operating System Companion**.

Semua komunikasi menuju Windows harus melewati Agent.

```text
Flutter

↓

REST API

↓

Agent

↓

Command Dispatcher

↓

Windows API
```

Tidak boleh ada modul yang langsung memanggil Windows API tanpa Dispatcher.

---

# 3. Arsitektur

```
Agent

├── Core
├── Plugin Engine
├── REST API
├── WebSocket
├── Scheduler
├── Authentication
├── Event Bus
├── Logger
├── Config
├── Notification

↓

Windows Layer

↓

Windows API
```

---

# 4. Core Engine

Core hanya memiliki satu tugas:

Menjalankan sistem.

Core tidak boleh:

- Print.
- Membaca File.
- Shutdown.
- Screenshot.

Semuanya dilakukan oleh plugin.

---

# 5. Plugin Engine

Ini adalah bagian paling penting.

Semua fitur nantinya berupa plugin.

Misalnya

```
plugins

file

printer

music

terminal

clipboard

power

browser

network

camera

flutter

docker

git

vscode

download

...
```

Plugin cukup didaftarkan.

Core akan otomatis mengenali.

---

# 6. Plugin Lifecycle

Saat Agent hidup

```
Load Plugin

↓

Initialize

↓

Register API

↓

Register Event

↓

Ready
```

Saat Agent mati

```
Save State

↓

Dispose

↓

Unload
```

---

# 7. Event Bus

Semua komunikasi internal menggunakan Event Bus.

Misalnya

```
Printer selesai

↓

Event

↓

Notification

↓

Mobile
```

Contoh lain

```
CPU 95%

↓

Event

↓

Monitoring

↓

Push Notification
```

Plugin tidak saling memanggil.

Plugin hanya mengirim Event.

---

# 8. Command Dispatcher

Semua command melewati Dispatcher.

Misalnya

```
Shutdown

↓

Permission Check

↓

Log

↓

Execute

↓

Response
```

Tidak boleh ada plugin yang langsung menjalankan command.

---

# 9. Authentication Flow

Pertama kali

```
HP

↓

Scan QR

↓

Agent

↓

Pair Device

↓

Generate Device ID

↓

Generate JWT

↓

Trusted Device
```

Setelah itu

```
JWT

↓

Refresh

↓

Access
```

---

# 10. Device Manager

Agent menyimpan daftar device.

Misalnya

```
Pixel 8a

Online

Ubuntu Laptop

Offline

Tablet

Online
```

Setiap device memiliki

- nama
- tipe
- izin
- terakhir aktif
- token
- IP terakhir

---

# 11. Permission

Permission granular.

Contoh

```
Shutdown

✓

Restart

✓

Delete File

✕

Print

✓

Terminal

✕

Screenshot

✓
```

Setiap user dapat memiliki kombinasi izin yang berbeda.

---

# 12. File Service

Tugas

- Browse
- Upload
- Download
- Rename
- Delete
- Copy
- Paste
- ZIP
- Search
- Favorite

Target

Semua operasi realtime.

---

# 13. Printer Service

Mampu

- daftar printer
- default printer
- print PDF
- print image
- cancel
- queue
- status
- toner (jika didukung driver)

---

# 14. Audio Service

- volume
- mute
- play
- pause
- next
- previous

Jika Spotify aktif

Plugin dapat mengontrol Spotify.

Jika YouTube aktif

Plugin mengontrol Browser.

---

# 15. Power Service

- shutdown
- restart
- sleep
- hibernate
- lock
- logout

Semua command dapat diberi timer.

---

# 16. Clipboard Service

Sinkron dua arah.

HP

↓

Copy

↓

Windows

↓

Paste

Windows

↓

Copy

↓

HP

↓

Paste

---

# 17. Screenshot Service

- screenshot
- multi monitor
- kualitas
- crop
- streaming preview

---

# 18. Notification Service

Mengirim

- print selesai
- download selesai
- drive penuh
- CPU tinggi
- login baru
- USB masuk
- update tersedia

Realtime.

---

# 19. Scheduler

Contoh

```
22.00

↓

Backup

↓

ZIP

↓

Shutdown
```

---

# 20. Logging

Semua command dicatat.

```
10.00

Shutdown

10.05

Delete File

10.20

Print

10.45

Login
```

Log dapat dicari.

---

# 21. Database

SQLite

Tabel

```
users

devices

logs

plugins

settings

permissions

notifications

automation

sessions
```

---

# 22. REST API

Contoh

```
GET

/files
```

```
POST

/shutdown
```

```
POST

/restart
```

```
GET

/printers
```

```
POST

/print
```

```
GET

/system
```

Semua API memiliki versi:

```
/api/v1/
```

---

# 23. WebSocket

Realtime

Contoh

```
CPU berubah

↓

langsung update
```

```
Download selesai

↓

langsung muncul
```

```
Printer selesai

↓

langsung muncul
```

---

# 24. Resource Target

Idle

RAM

```
<30MB
```

CPU

```
<0.2%
```

Saat Monitoring

RAM

```
<80MB
```

CPU

```
<1%
```

---

# 25. Error Recovery

Jika plugin crash

```
Restart Plugin
```

Jika gagal

```
Disable Plugin
```

Agent tetap hidup.

Core **tidak boleh ikut crash**.

---

# 26. Prinsip Pengembangan

Setiap fitur baru harus memenuhi aturan berikut:

- Tidak mengubah Core.
- Dibuat sebagai plugin.
- Memiliki dokumentasi API.
- Mendukung izin (permission).
- Mengirim event jika ada perubahan.
- Memiliki unit test.
- Tidak boleh membuat Agent berhenti bekerja.

# 📘 PRD-003

# Flutter Application & UX Design

**Version:** 1.0

---

# 1. Design Philosophy

WinPilot bukan aplikasi remote desktop.

WinPilot adalah **Control Center**.

Saat aplikasi dibuka, pengguna harus langsung tahu:

- Apakah komputer online?
- Berapa CPU?
- Ada notifikasi?
- Ada download?
- Ada print?
- Ada warning?

Tanpa membuka banyak menu.

---

# 2. Target Platform

Flutter

↓

Android

↓

Web

↓

Windows Desktop (Future)

↓

Linux Desktop (Future)

Semua menggunakan code yang sama.

---

# 3. Framework

Flutter Stable

State Management

GetX

Navigation

GetX Route

Theme

Material 3

Animation

Implicit Animation

Hero Animation

Lottie (opsional)

---

# 4. Design Language

Style

Glassmorphism ringan

-

Windows 11

-

Material 3

-

Apple-like spacing

Artinya

UI bersih

Card besar

Shadow tipis

Animasi halus

Tidak banyak warna

---

# 5. Color System

Default

Primary

Blue

Success

Green

Warning

Orange

Danger

Red

Background

Dynamic

Accent

Bisa diubah pengguna.

---

# 6. Navigation

Bottom Navigation

```text
🏠 Home

📂 Files

⚡ Automation

🔔 Notifications

⚙ Settings
```

Jika layar besar

Sidebar otomatis muncul.

---

# 7. Dashboard

Saat membuka aplikasi.

Pengguna melihat.

```text
Windows 11

🟢 Online

CPU

12%

RAM

42%

Storage

60%

Internet

120 Mbps

Battery

100%

Printer

Ready

Downloads

3

Notifications

2
```

Semuanya realtime.

---

# 8. Quick Actions

Di bagian atas.

```text
Shutdown

Restart

Lock

Screenshot

Print

Clipboard
```

Satu sentuhan.

---

# 9. Favorite Actions

User dapat memilih.

Misalnya.

```text
Screenshot

Open Downloads

Restart Explorer

Open Spotify

Shutdown
```

Tidak perlu masuk menu.

---

# 10. Search

Saya ingin Search menjadi pusat aplikasi.

Misalnya.

User mengetik.

```text
shutdown
```

langsung muncul.

Shutdown PC

Shutdown Monitor

Shutdown Service

---

User mengetik.

```text
spotify
```

langsung muncul.

Open Spotify

Pause Spotify

Volume Spotify

---

User mengetik.

```text
invoice
```

langsung muncul semua file.

Search harus berada di semua halaman.

---

# 11. Notification Center

Menampilkan.

Print selesai

Download selesai

CPU tinggi

Drive penuh

Login baru

USB masuk

Build selesai

Plugin error

Klik notifikasi.

Langsung menuju halaman terkait.

---

# 12. Live Monitoring

Realtime.

CPU

RAM

Disk

GPU

Temperature

Network

Battery

Printer

Service

Semuanya tanpa refresh.

---

# 13. File Explorer

Target.

Semirip mungkin dengan Explorer Windows.

Fitur.

Folder Tree

Breadcrumb

Favorite

Recent

Search

Preview

Copy

Paste

Rename

Delete

ZIP

Extract

Share

Upload

Download

Drag & Drop (Web/Desktop)

---

# 14. File Preview

Preview.

Image

PDF

TXT

Markdown

Video

Audio

Tanpa download.

---

# 15. Multi Upload

Upload.

100 file

↓

Progress masing-masing

↓

Pause

↓

Resume

↓

Retry

---

# 16. Download Manager

Menampilkan.

Nama

Progress

Speed

ETA

Pause

Resume

Cancel

History

---

# 17. Printer

Printer List

↓

Queue

↓

Print

↓

Cancel

↓

History

↓

Preview

---

# 18. Music

Album

Volume

Next

Previous

Mute

Playlist (opsional)

---

# 19. Application Manager

Daftar aplikasi.

Running

CPU

RAM

Close

Restart

Force Kill

Open

---

# 20. Terminal

Browser Terminal.

PowerShell

CMD

Git Bash

History

Auto Complete (Future)

---

# 21. Automation

Visual Workflow.

Contoh.

```text
Download selesai

↓

Print

↓

Bunyikan suara

↓

Notifikasi HP
```

User cukup drag & drop.

---

# 22. Device Manager

Daftar device.

Pixel

Online

Ubuntu

Offline

Tablet

Online

Klik.

↓

Permission

↓

Token

↓

History

↓

Logout

---

# 23. Plugin Manager

Menampilkan.

Plugin aktif

Plugin mati

Version

Update

Setting

---

# 24. Theme

Light

Dark

Auto

Accent Color

Blur Level

Animation Speed

---

# 25. Responsiveness

HP

Tablet

Desktop

Browser

Semua layout berbeda.

Bukan hanya diperbesar.

---

# 26. UX Rules

Tidak boleh lebih dari.

3 klik

Untuk fitur penting.

Misalnya.

Screenshot.

Home

↓

Screenshot

Selesai.

---

Shutdown.

Home

↓

Shutdown

↓

Confirm

Selesai.

---

# 27. Offline Experience

Jika internet mati.

Tampilan.

```text
⚪ Local Mode

Menghubungkan ke jaringan lokal...
```

Jika internet kembali.

```text
🟢 Remote Connected
```

Transisi otomatis.

---

# 28. Animation

Durasi.

200 ms

Tidak boleh.

Lebih dari 300 ms.

Aplikasi harus terasa cepat.

---

# 29. Accessibility

Ukuran font bisa diubah.

Kontras tinggi.

Dukungan screen reader.

Target sentuh minimal 48dp.

---

# 30. Error UX

Jika gagal print.

Jangan hanya.

```text
Error
```

Harus.

```text
Printer Epson L3210 sedang offline.

Coba hidupkan printer atau pilih printer lain.
```

Semua error harus mudah dipahami.

---

# 31. Prinsip Pengembangan UI

Saya menetapkan beberapa aturan yang wajib dipatuhi selama pengembangan:

- **Kecepatan lebih penting daripada animasi berlebihan.**
- **Informasi penting selalu terlihat tanpa harus membuka banyak menu.**
- **Satu fungsi = satu tujuan yang jelas.**
- **Setiap halaman harus memiliki pencarian jika datanya banyak.**
- **Semua aksi penting harus memberikan umpan balik (loading, sukses, atau gagal).**
- **Desain harus konsisten di Android, Web, dan Desktop.**

# 📘 PRD-004

# Authentication, Security & Device Management

**Version:** 1.0

---

# 1. Tujuan

Menyediakan sistem autentikasi yang:

- Aman
- Cepat
- Ringan
- Mudah digunakan
- Tidak bergantung pada cloud
- Mendukung banyak perangkat dan banyak pengguna

---

# 2. Filosofi

Prinsip utama:

> **Komputer adalah pemilik sistem. Semua perangkat lain harus mendapatkan izin dari komputer tersebut.**

Artinya:

- HP tidak bisa langsung mengakses Agent.
- Browser tidak bisa langsung login.
- Semua perangkat harus dipasangkan (pairing) terlebih dahulu.

---

# 3. Security Layer

WinPilot memiliki beberapa lapisan keamanan:

```text
Internet / LAN
        │
        ▼
TLS Encryption
        │
        ▼
Authentication
        │
        ▼
Device Validation
        │
        ▼
Permission Check
        │
        ▼
Command Dispatcher
        │
        ▼
Windows API
```

Setiap perintah harus melewati semua lapisan di atas.

---

# 4. Pairing Pertama

Saat pertama kali menghubungkan HP.

Langkah:

```
HP membuka aplikasi

↓

Pilih "Tambah Komputer"

↓

Scan QR Code

↓

Agent membuat Device Token

↓

Komputer meminta konfirmasi

↓

Pairing berhasil
```

QR Code hanya berlaku dalam waktu singkat dan hanya bisa dipakai satu kali.

---

# 5. Pairing Alternatif

Jika kamera tidak tersedia:

- Kode 6 digit sekali pakai (OTP lokal).
- Pairing menggunakan LAN.
- Pairing menggunakan file konfigurasi yang diekspor dari Agent.

---

# 6. Device Identity

Setiap perangkat memiliki identitas unik:

- Device ID
- Nama perangkat
- Tipe perangkat
- Sistem operasi
- Waktu pairing
- Token autentikasi
- Kunci publik (untuk fitur keamanan lanjutan di masa depan)

---

# 7. User Management

Mendukung multi-user.

Contoh:

```
Administrator

Mustofa

Ayah

Teman
```

Setiap akun memiliki izin yang berbeda.

---

# 8. Role-Based Access Control (RBAC)

Peran bawaan:

### Owner

Kontrol penuh.

### Administrator

Mengelola pengguna, plugin, dan sistem.

### Operator

Mengelola file, printer, dan monitoring.

### Viewer

Hanya melihat status dan monitoring.

Peran kustom juga dapat dibuat sesuai kebutuhan.

---

# 9. Permission Granular

Setiap aksi memiliki izin tersendiri.

Contoh:

```
Shutdown PC

Restart

Lock

Delete File

Rename File

Upload File

Download File

Terminal

Clipboard

Print

Manage Plugin

Automation

Camera

Microphone
```

Hak akses dapat diatur satu per satu.

---

# 10. Trusted Device

Setelah pairing berhasil.

Perangkat masuk ke daftar:

```
Pixel 8a

Trusted

Ubuntu Laptop

Trusted

Office Laptop

Trusted
```

Perangkat dapat dicabut kapan saja.

---

# 11. Session Management

Sistem menyimpan:

- Login aktif.
- Waktu login.
- Alamat IP.
- Lokasi jaringan (LAN atau internet).
- Jenis koneksi.

Owner dapat mengakhiri sesi tertentu tanpa memengaruhi perangkat lain.

---

# 12. Login Protection

Jika terjadi beberapa kali percobaan login gagal:

- Penundaan sementara (rate limiting).
- Pencatatan ke audit log.
- Notifikasi ke pemilik.

---

# 13. Audit Log

Semua aktivitas keamanan dicatat.

Contoh:

```
09:12

Login berhasil

09:14

Shutdown dibatalkan

09:20

Pairing perangkat baru

09:30

Izin pengguna diubah

09:35

Plugin dinonaktifkan
```

Log dapat difilter berdasarkan waktu, pengguna, atau jenis aktivitas.

---

# 14. Token Management

Setelah login:

- Access Token untuk permintaan API.
- Refresh Token untuk memperbarui sesi.

Token memiliki masa berlaku dan dapat dicabut sewaktu-waktu.

---

# 15. Logout

Mendukung:

- Logout perangkat ini.
- Logout semua perangkat.
- Cabut satu perangkat tertentu.
- Paksa semua perangkat melakukan login ulang.

---

# 16. Device Approval

Untuk perangkat baru.

Owner dapat memilih:

```
Terima

Tolak

Tolak & blokir
```

Perangkat yang ditolak dapat dimasukkan ke daftar blokir.

---

# 17. Secure Communication

Semua komunikasi menggunakan TLS.

Tidak ada perintah sensitif yang dikirim dalam bentuk teks biasa.

---

# 18. Local Mode & Remote Mode

### Local Mode

- Menggunakan jaringan lokal.
- Latensi sangat rendah.
- Tidak memerlukan internet.

### Remote Mode

- Menggunakan VPN atau relay (sesuai konfigurasi pengguna).
- Tetap memakai sistem autentikasi yang sama.

Peralihan dilakukan otomatis tanpa mengubah cara penggunaan.

---

# 19. Recovery

Jika HP hilang:

Owner dapat:

- Menghapus token perangkat.
- Memutus semua sesi.
- Memblokir perangkat.
- Melakukan pairing ulang dengan perangkat baru.

---

# 20. Emergency Lock

Fitur darurat.

Dengan satu tombol:

- Semua sesi dihentikan.
- Semua token dicabut.
- Pairing baru dinonaktifkan sementara.
- Hanya Owner yang dapat membuka kembali akses.

---

# 21. Prinsip Keamanan

- Tidak ada kata sandi yang disimpan dalam bentuk teks biasa.
- Semua komunikasi terenkripsi.
- Semua aksi sensitif harus melewati pemeriksaan izin.
- Semua perubahan keamanan harus masuk audit log.
- Pairing hanya bisa dilakukan dengan persetujuan dari komputer yang menjadi server.

---

# 22. Persiapan Masa Depan

Arsitektur keamanan sudah disiapkan untuk mendukung:

- Autentikasi dua faktor (2FA).
- Login biometrik di aplikasi mobile (sidik jari atau Face ID jika perangkat mendukung).
- Single Sign-On lokal.
- Sertifikat perangkat.
- Dukungan hardware security key.

# 📘 PRD-005

# File Management System

**Version:** 1.0

---

# 1. Tujuan

Membuat sistem manajemen file yang:

- Sangat cepat.
- Aman.
- Realtime.
- Mendukung file berukuran besar.
- Terasa seperti menggunakan Windows Explorer secara langsung.

---

# 2. Filosofi

Target utama.

Ketika user membuka menu File.

Harus terasa seperti membuka.

```text
Windows Explorer
```

bukan

```text
Website Upload File
```

---

# 3. Modul

File System terdiri dari:

```text
Explorer

Search

Preview

Upload

Download

Transfer

Clipboard

Favorite

History

Trash

Sharing

Index
```

---

# 4. Explorer

Halaman utama.

Menampilkan.

```
Desktop

Documents

Downloads

Pictures

Videos

Music

Drive C

Drive D

Drive E
```

User juga dapat menambahkan folder favorit.

---

# 5. Folder Tree

Sebelah kiri.

```
C:

D:

Downloads

Project

Flutter

Pictures
```

Klik.

↓

Isi folder langsung muncul.

---

# 6. Breadcrumb

Contoh.

```
C:

↓

Users

↓

Mustofa

↓

Downloads

↓

Flutter
```

Klik salah satu.

Langsung kembali.

---

# 7. View

User dapat memilih.

```
Grid

List

Details

Large Icon

Small Icon
```

---

# 8. File Detail

Menampilkan.

Nama

Ukuran

Tanggal

Tipe

Owner

Permission

Checksum (opsional)

---

# 9. Preview

Preview tanpa download.

Support.

✓ Image

✓ PDF

✓ TXT

✓ Markdown

✓ MP3

✓ MP4

✓ JSON

✓ CSV

✓ DOCX (preview dasar)

✓ XLSX (preview dasar)

Jika format tidak didukung.

Tampilkan informasi file.

---

# 10. Upload

Target.

Drag & Drop.

↓

Progress.

↓

Pause.

↓

Resume.

↓

Retry.

↓

Cancel.

---

# 11. Download

Target.

100GB+

Harus bisa.

↓

Resume

↓

Retry

↓

Integrity Check

↓

History

Jika koneksi putus.

Lanjut dari byte terakhir.

---

# 12. Copy

Contoh.

```
Copy

↓

Paste

↓

Realtime
```

Tidak perlu refresh.

---

# 13. Move

```
Move

↓

Progress

↓

Done
```

---

# 14. Rename

Rename.

Single.

Mass Rename (Future).

---

# 15. Delete

Saat Delete.

Masuk.

```
Recycle Bin WinPilot
```

Bukan langsung hilang.

---

# 16. Restore

```
Recycle Bin

↓

Restore
```

---

# 17. Permanent Delete

Owner.

↓

Confirm.

↓

Delete.

---

# 18. Favorite

Folder.

↓

Pin.

↓

Selalu muncul.

---

# 19. Recent

Menampilkan.

File yang baru.

- dibuka
- diupload
- didownload
- diubah

---

# 20. Search

Ini bagian penting.

Target.

Lebih cepat daripada Explorer.

Menggunakan.

```
Index Database
```

Bukan scan disk setiap kali.

Contoh.

```
invoice
```

↓

0.02 detik.

---

# 21. Search Filter

Filter.

Nama

Ukuran

Tanggal

Extension

Folder

Owner

Tag

Favorite

---

# 22. Upload Queue

Semua upload.

Masuk queue.

```
Upload 1

Upload 2

Upload 3

Upload 4
```

Bisa.

Pause.

Resume.

Prioritas.

---

# 23. Download Queue

Sama.

Semua download.

Masuk queue.

---

# 24. Clipboard

```
Copy

Cut

Paste
```

Mirip Windows.

---

# 25. ZIP

Support.

```
Compress

Extract
```

Target.

ZIP

7z (opsional)

RAR (opsional jika library tersedia)

---

# 26. Checksum

Generate.

```
SHA256

MD5
```

Untuk memastikan file tidak rusak setelah transfer.

---

# 27. Duplicate Finder

Cari.

```
Duplicate File
```

Berdasarkan.

Hash.

---

# 28. File Tag

User dapat memberi.

```
Penting

Flutter

Project

Backup

Dokumen
```

---

# 29. Folder Color

Misalnya.

```
Project

↓

Blue
```

```
Photo

↓

Green
```

---

# 30. Quick Action

Long press.

↓

Menu.

```
Copy

Move

Rename

Delete

Share

ZIP

Properties
```

---

# 31. File Properties

Menampilkan.

```
Ukuran

Lokasi

Tanggal

Permission

Checksum

Tag

Version
```

---

# 32. Transfer Engine

Target.

Memakai.

```
Chunk Upload
```

Bukan upload satu file penuh.

Misalnya.

100MB.

↓

1MB

↓

100 chunk.

Jika chunk 75 gagal.

Mulai lagi dari.

76.

---

# 33. Compression

Jika user mau.

```
Download

↓

Compress dulu

↓

Transfer
```

Lebih cepat.

---

# 34. Encryption

Opsional.

User dapat memilih.

```
Encrypt File
```

Sebelum transfer.

---

# 35. Sync

Folder.

↓

Realtime.

Jika file berubah.

↓

HP langsung tahu.

---

# 36. Offline Queue

Misalnya.

Internet mati.

↓

Upload.

↓

Masuk Queue.

↓

Internet hidup.

↓

Lanjut otomatis.

---

# 37. Conflict Resolver

Misalnya.

File sama.

```
Replace

Rename

Skip

Compare
```

---

# 38. Thumbnail Engine

Semua.

Image.

Video.

PDF.

Memiliki thumbnail.

Tidak perlu generate berulang.

Disimpan cache.

---

# 39. Index Engine

Saya ingin membuat.

```
Everything-like Search
```

Agent akan membuat index.

Saat ada file baru.

↓

Index otomatis update.

---

# 40. Resource Target

Search.

```
<100ms
```

Open Folder.

```
<150ms
```

Preview.

```
<200ms
```

Upload.

```
10GB+

Resume
```

---

# 41. Keamanan

## Folder sensitif dapat diberi aturan tambahan, misalnya meminta konfirmasi ulang atau hanya bisa diakses oleh Owner. Semua operasi file penting (hapus permanen, pindah, salin ke luar folder tertentu) dicatat dalam audit log.

# 📘 PRD-006

# Device & System Management

**Version:** 1.0

---

# 1. Tujuan

Memberikan kontrol penuh terhadap Windows tanpa harus membuka Remote Desktop.

Targetnya adalah **95% pekerjaan administrasi komputer bisa dilakukan tanpa melihat layar Windows**.

---

# 2. Filosofi

Semua yang bisa dilakukan di Windows seharusnya bisa dilakukan melalui WinPilot jika aman dan diizinkan.

WinPilot bukan hanya "mengendalikan komputer", tetapi **mengelola sistem operasi**.

---

# 3. Module Overview

```text
System Manager

├── Power
├── Process
├── Services
├── Applications
├── Audio
├── Display
├── Printer
├── Clipboard
├── Downloads
├── Network
├── Bluetooth
├── USB
├── Storage
├── Environment
├── Windows Update
└── Device Health
```

---

# 4. Power Manager

## Fungsi

- Shutdown
- Restart
- Sleep
- Hibernate
- Lock
- Sign Out
- Restart Explorer
- Safe Mode (opsional)

### Penjadwalan

Contoh:

```
Shutdown dalam 30 menit
```

atau

```
Restart jam 23.30
```

---

# 5. Process Manager

Mirip Task Manager.

Menampilkan:

- Nama proses
- PID
- CPU
- RAM
- Status
- User
- Waktu berjalan

Aksi:

- Kill Process
- Restart Process
- Priority (Low/Normal/High)
- Detail Process

---

# 6. Service Manager

Mengontrol Windows Services.

Contoh:

```
Print Spooler

Running
```

```
Windows Update

Stopped
```

Aksi:

- Start
- Stop
- Restart
- Startup Type (Manual/Automatic/Disabled)

---

# 7. Application Manager

Menampilkan aplikasi yang sedang berjalan dan aplikasi yang terpasang.

Fitur:

- Jalankan aplikasi
- Tutup aplikasi
- Restart aplikasi
- Pin aplikasi favorit
- Riwayat penggunaan

Contoh:

```
VS Code

Running
```

```
Spotify

Stopped
```

---

# 8. Audio Manager

Mengontrol:

- Master Volume
- Mute
- Output Device
- Input Device (mikrofon)
- Volume per aplikasi

Jika memungkinkan:

- Menampilkan lagu yang sedang diputar.
- Tombol Play/Pause.
- Next/Previous.

---

# 9. Display Manager

Informasi:

- Resolusi
- Refresh Rate
- Monitor aktif
- Brightness (jika didukung)

Fitur:

- Ganti resolusi.
- Atur brightness.
- Matikan monitor.
- Screenshot monitor tertentu.

---

# 10. Printer Manager

Menampilkan:

- Semua printer.
- Status.
- Printer default.

Fitur:

- Cetak dokumen.
- Cetak gambar.
- Cetak PDF.
- Batalkan antrean.
- Lihat riwayat cetak.

---

# 11. Clipboard Manager

Sinkron dua arah.

Mendukung:

- Teks
- Gambar
- File (melalui referensi)

Menampilkan riwayat clipboard (opsional).

---

# 12. Download Manager

Menampilkan:

- Semua unduhan aktif.
- Kecepatan.
- Progress.
- ETA.

Fitur:

- Pause
- Resume
- Cancel
- Buka folder hasil unduhan

---

# 13. Network Manager

Informasi:

- IP Lokal
- IP Publik (jika tersedia)
- Kecepatan koneksi
- Wi-Fi SSID
- Gateway
- DNS

Fitur:

- Ping host.
- Tes koneksi.
- Lihat penggunaan bandwidth.

---

# 14. Bluetooth Manager

Menampilkan perangkat Bluetooth.

Aksi:

- Pair
- Unpair
- Connect
- Disconnect

---

# 15. USB Manager

Deteksi:

- Flashdisk
- HDD eksternal
- Webcam
- Keyboard
- Mouse

Event:

```
USB masuk
```

↓

Notifikasi.

↓

Automation.

---

# 16. Storage Manager

Menampilkan:

- Kapasitas drive.
- Ruang kosong.
- Jenis drive (SSD/HDD jika dapat dideteksi).
- Kesehatan disk (jika didukung).

Memberi peringatan ketika ruang penyimpanan hampir habis.

---

# 17. Windows Update

Status:

- Tidak ada pembaruan.
- Pembaruan tersedia.
- Sedang mengunduh.
- Perlu restart.

Fitur:

- Mulai pembaruan.
- Tunda pembaruan.
- Restart setelah selesai.

---

# 18. Device Health

Monitoring:

- CPU
- RAM
- GPU (jika tersedia)
- Disk
- Suhu (bergantung dukungan perangkat)
- Uptime

Status:

🟢 Normal

🟡 Warning

🔴 Critical

---

# 19. Live Dashboard

Semua informasi diperbarui melalui WebSocket.

Tidak perlu refresh.

Perubahan CPU, RAM, atau status printer langsung terlihat.

---

# 20. Command Center

Saya ingin ada satu halaman khusus.

Misalnya.

```
Cari:

restart printer
```

↓

Muncul:

- Restart Print Spooler
- Restart Printer Service
- Restart Windows

Satu pencarian untuk semua perintah.

---

# 21. Device Event Engine

Semua perubahan perangkat menghasilkan event.

Contoh:

```
Flashdisk dipasang

↓

Event

↓

Notification

↓

Automation
```

atau

```
Printer offline

↓

Event

↓

Notifikasi ke HP
```

---

# 22. Resource Target

Monitoring sistem:

- CPU Agent < 1%
- RAM Agent < 80 MB
- Pembaruan status default setiap 1 detik (dapat diubah untuk menghemat sumber daya).

---

# 23. Integrasi

Modul ini terhubung dengan:

- Automation Engine.
- Notification Service.
- Logging.
- Permission System.
- Dashboard.
- AI Command.

---

# 24. Prinsip Desain

- Semua aksi yang berisiko (shutdown, stop service, force kill) harus meminta konfirmasi sesuai pengaturan pengguna.
- Operasi yang gagal harus memberikan pesan yang jelas beserta alasan jika tersedia.
- Semua perubahan penting dicatat di audit log.
- Jika sebuah fitur tidak didukung oleh perangkat keras atau Windows edisi tertentu, UI tetap konsisten dan menampilkan status "tidak tersedia" daripada menghasilkan error.

---

# 💡 Usulan Arsitektur yang Saya Ingin Tambahkan

Saya ingin menambahkan sebuah **System Action Pipeline**.

Daripada setiap tombol langsung mengeksekusi perintah, semua aksi akan melalui alur berikut:

```text
User
   │
   ▼
Permission Check
   │
   ▼
Policy Engine
   │
   ▼
Command Queue
   │
   ▼
Execute
   │
   ▼
Audit Log
   │
   ▼
Notification
```

Keuntungannya:

- Perintah dapat dijadwalkan.
- Bisa dibatalkan sebelum dijalankan (jika masih di antrean).
- Semua aksi memiliki jejak audit.
- Mudah ditambahkan aturan (misalnya hanya boleh dilakukan di jam tertentu atau oleh peran tertentu).
- Arsitektur tetap rapi saat jumlah fitur bertambah.

# 📘 PRD-007

# Automation Engine & Workflow System

**Version:** 1.0

---

# 1. Vision

Automation Engine memungkinkan pengguna membuat **workflow otomatis** tanpa perlu menulis kode.

Targetnya adalah:

> **"If This → Then That" untuk Windows pribadi.**

---

# 2. Filosofi

Automation harus:

- Mudah dibuat.
- Mudah dibaca.
- Aman.
- Bisa diuji sebelum dijalankan.
- Bisa dihentikan kapan saja.

---

# 3. Konsep Dasar

Setiap automation terdiri dari:

```text
Trigger
   │
Condition (Opsional)
   │
Action
```

Contoh:

```text
USB Masuk
    │
Nama = BackupDisk
    │
Copy Folder Project
    │
Kirim Notifikasi
```

---

# 4. Workflow Builder

UI menggunakan sistem **drag & drop**.

Contoh:

```text
+ Trigger
      ↓
+ Condition
      ↓
+ Action
      ↓
+ Delay
      ↓
+ Action
```

Semua node dapat dipindahkan.

---

# 5. Trigger

Automation bisa dimulai oleh:

## System

- Windows menyala
- Windows mati
- Login
- Logout
- Sleep
- Wake Up

---

## File

- File dibuat
- File dihapus
- File diubah
- Folder berubah

---

## Device

- USB masuk
- USB dicabut
- Printer online
- Printer offline
- Bluetooth connect
- Bluetooth disconnect

---

## Network

- WiFi tersambung
- WiFi putus
- Internet kembali
- VPN aktif

---

## Time

- Jam tertentu
- Setiap menit
- Setiap jam
- Setiap hari
- Setiap minggu
- Setiap bulan

---

## Manual

User menekan tombol.

---

## API

Automation dipanggil melalui REST API.

---

## Future

Voice Command.

---

# 6. Condition

Condition bersifat opsional.

Contoh.

```text
CPU > 90%
```

atau

```text
Jam > 22.00
```

atau

```text
Hari = Sabtu
```

atau

```text
Drive D < 10%
```

---

# 7. Condition Library

Mendukung:

- CPU
- RAM
- GPU
- Storage
- User
- Folder
- Printer
- WiFi
- Bluetooth
- Battery
- Device
- Application
- Service
- Plugin
- File Size
- File Name
- Extension
- Process Running

---

# 8. Actions

Automation dapat melakukan:

## File

- Copy
- Move
- Rename
- Delete
- ZIP
- Extract
- Download
- Upload

---

## System

- Shutdown
- Restart
- Sleep
- Lock

---

## Printer

- Print
- Cancel Queue

---

## Audio

- Play
- Pause
- Volume

---

## Notification

- Android
- Browser
- Desktop

---

## Terminal

Menjalankan:

- CMD
- PowerShell

---

## Application

- Open
- Close
- Restart

---

## Service

- Start
- Stop
- Restart

---

## Plugin

Memanggil plugin tertentu.

---

# 9. Delay

Contoh.

```text
Restart

↓

Tunggu 30 detik

↓

Shutdown
```

---

# 10. Repeat

Automation dapat diulang.

Contoh.

```text
Setiap 5 menit
```

---

# 11. Parallel Execution

Workflow dapat berjalan bersamaan.

Contoh.

```text
Copy Folder

│

├── ZIP

├── Backup

└── Notification
```

---

# 12. Variables

Automation dapat menggunakan variabel.

Contoh.

```text
${CURRENT_DATE}

${USERNAME}

${DEVICE}

${IP}

${FILENAME}

${DOWNLOAD_PATH}
```

---

# 13. Templates

Disediakan template bawaan.

Misalnya.

Backup Harian

↓

ZIP

↓

Copy

↓

Notification

---

Download Selesai

↓

Print

↓

Notification

---

USB Backup

↓

Copy

↓

Verify

↓

Notification

---

# 14. Scheduler

Automation dapat dijadwalkan.

Contoh.

```text
23.00

↓

Backup

↓

Shutdown
```

---

# 15. Workflow Status

Menampilkan.

Running

Waiting

Success

Failed

Stopped

---

# 16. Logs

Setiap workflow memiliki log.

Contoh.

```text
22:00

Workflow dimulai

22:01

Copy berhasil

22:03

ZIP berhasil

22:04

Notifikasi terkirim

22:05

Workflow selesai
```

---

# 17. Error Handling

Jika satu langkah gagal.

User dapat memilih.

```text
Stop
```

atau

```text
Retry
```

atau

```text
Skip
```

atau

```text
Continue
```

---

# 18. Workflow Version

Setiap workflow memiliki.

Version.

History.

Rollback.

---

# 19. Import & Export

Workflow dapat.

Export.

↓

JSON.

Import.

↓

JSON.

Berbagi workflow menjadi mudah.

---

# 20. Permission

Workflow memiliki izin.

Misalnya.

Workflow ini.

↓

Tidak boleh.

Shutdown.

Karena user hanya Viewer.

---

# 21. Workflow Search

Cari.

```text
backup
```

↓

Semua workflow backup muncul.

---

# 22. Dashboard

Menampilkan.

Workflow aktif.

Workflow gagal.

Workflow hari ini.

Workflow minggu ini.

Workflow favorit.

---

# 23. Performance Target

100 workflow aktif.

↓

CPU tetap rendah.

Workflow idle.

↓

Hampir tidak memakai CPU.

---

# 24. Automation API

Workflow dapat dipanggil.

REST API.

WebSocket.

Plugin.

CLI.

---

# 25. Integrasi AI (Future)

Misalnya user mengetik:

> Backup folder Project setiap malam jam 23.00 lalu matikan komputer.

AI akan mengubah kalimat tersebut menjadi workflow otomatis.

---

# 26. Automation Marketplace (Future)

Pengguna dapat berbagi workflow.

Contoh.

Backup NAS.

Flutter Build.

Gaming Mode.

Office Mode.

Photo Backup.

---

# 27. Prinsip Desain

Automation harus:

- Mudah dipahami.
- Tidak membuat Windows terasa lambat.
- Aman terhadap loop tak berujung.
- Dapat diuji sebelum diaktifkan.
- Selalu memberikan log yang jelas.

---

# 💡 Tambahan Besar yang Saya Usulkan

Di sinilah saya ingin membawa WinPilot ke level yang jauh lebih tinggi.

## **Macro Recorder**

Fitur ini akan merekam aktivitas pengguna di Windows (sesuai izin yang diberikan), kemudian mengubahnya menjadi workflow otomatis.

Contoh:

Anda melakukan:

```text
Buka Folder

↓

Copy File

↓

Paste

↓

ZIP

↓

Print
```

WinPilot merekam urutan tersebut.

Kemudian muncul.

```text
Save sebagai Workflow?
```

Klik.

↓

Selesai.

Tidak perlu membuat workflow dari nol.

---

## **Workflow Simulator**

Sebelum workflow dijalankan.

User bisa menekan.

```text
▶ Simulate
```

Agent menjalankan simulasi.

Menampilkan.

```text
✓ Folder ditemukan

✓ Printer siap

✓ Internet aktif

✓ Workflow valid
```

# 📘 PRD-008

# Monitoring Center & Health Engine

**Version:** 1.0

---

# 1. Vision

Monitoring bukan hanya menampilkan angka.

Monitoring harus bisa:

- Memberi tahu masalah.
- Menjelaskan penyebab.
- Memberikan rekomendasi.
- Memicu Automation.
- Mengirim notifikasi.

WinPilot bukan hanya melihat kondisi komputer.

WinPilot harus **memahami kondisi komputer**.

---

# 2. Monitoring Architecture

```text
Windows

↓

Collector

↓

Metrics Engine

↓

Health Engine

↓

Event Bus

↓

Dashboard

↓

Flutter
```

Semua data diproses sebelum dikirim.

Flutter hanya menerima data yang sudah siap ditampilkan.

---

# 3. Monitoring Modules

```text
CPU

RAM

GPU

Storage

Temperature

Battery

Internet

Network

Processes

Printer

Bluetooth

USB

Windows

Security

Services

Plugins
```

---

# 4. CPU Monitor

Menampilkan:

- Total Usage
- Core Usage
- Threads
- Frequency
- Maximum Frequency
- Temperature (jika tersedia)
- Load Average

Grafik:

- 1 menit
- 5 menit
- 30 menit
- 24 jam

---

# 5. RAM Monitor

Informasi:

- Total RAM
- Used
- Free
- Cache
- Available
- Swap/Page File

Grafik realtime.

---

# 6. GPU Monitor

Jika GPU tersedia.

Menampilkan.

- GPU Usage
- VRAM
- Temperature
- Fan Speed (jika tersedia)
- Clock

Jika tidak tersedia.

UI tetap tampil.

↓

"Not Supported"

---

# 7. Storage Monitor

Per Drive.

```text
C:

Total

Used

Free

SSD Health

Read Speed

Write Speed
```

Semua drive.

---

# 8. Network Monitor

Menampilkan.

Upload Speed

Download Speed

Latency

Packet Loss

Gateway

DNS

IP

SSID

Internet Status

---

# 9. Internet Health

Status.

🟢 Excellent

🟡 Good

🟠 Slow

🔴 Offline

Ditentukan otomatis.

---

# 10. Temperature Monitor

Jika hardware mendukung.

CPU

GPU

SSD

Motherboard

Battery

---

# 11. Battery

Laptop.

↓

Health

Cycle

Voltage

Remaining Time

Charging

Power Adapter

---

# 12. Process Monitor

Realtime.

Top CPU

Top RAM

Top Disk

Top Network

Klik.

↓

Detail Process.

---

# 13. Printer Monitor

Status.

Ready

Printing

Paused

Offline

Paper Jam

Low Ink (jika driver mendukung)

---

# 14. USB Monitor

Menampilkan.

USB masuk.

↓

Nama

Serial

Type

Speed

Capacity

---

# 15. Bluetooth Monitor

Perangkat.

Connected

Disconnected

Battery (jika tersedia)

---

# 16. Windows Health

Menampilkan.

Windows Version

Windows Activation

Windows Update

Last Boot

Uptime

---

# 17. Service Monitor

Semua service penting.

Running

Stopped

Error

Restart Count

---

# 18. Plugin Monitor

Plugin.

Running

Disabled

Error

Memory

CPU

Version

---

# 19. Dashboard

Halaman utama.

```text
🟢 Windows Healthy

CPU

18%

RAM

41%

Storage

62%

Internet

Excellent

Battery

100%

Printer

Ready

Notification

2
```

---

# 20. Health Score

Saya ingin membuat skor.

Misalnya.

```text
System Health

96/100
```

Dihitung dari.

CPU

RAM

Disk

Temperature

Windows Update

Storage

Plugin

Internet

Printer

---

# 21. Warning Engine

Contoh.

CPU > 90%

↓

Warning

RAM > 95%

↓

Warning

SSD < 10%

↓

Warning

Printer Offline

↓

Warning

Internet Putus

↓

Warning

---

# 22. Critical Engine

Jika kondisi serius.

```text
CPU 100%

↓

Critical
```

atau.

```text
SSD Full
```

↓

Critical.

---

# 23. Recommendation Engine

Ini fitur yang menurut saya akan membuat WinPilot terasa pintar.

Contoh.

```text
CPU tinggi.

Kemungkinan disebabkan oleh:

Google Chrome.

VS Code.

Windows Update.
```

atau.

```text
Drive C tinggal 2GB.

Disarankan:

Bersihkan Downloads.

Kosongkan Recycle Bin.

Hapus Temporary Files.
```

---

# 24. Timeline

Semua perubahan.

Masuk Timeline.

```text
09.00

CPU 95%

09.10

Normal

09.30

Printer Offline

09.35

Printer Online
```

---

# 25. Charts

Semua grafik.

Interaktif.

Zoom.

Pan.

Export PNG.

Export CSV.

---

# 26. History

Semua data.

Disimpan.

1 Hari

7 Hari

30 Hari

365 Hari (opsional)

Pengguna dapat mengatur masa penyimpanan agar tidak memenuhi disk.

---

# 27. Event Correlation

Ini fitur yang sangat saya inginkan.

Misalnya.

```text
Printer Offline

↓

USB Printer Dicabut

↓

Internet Putus

↓

Automation gagal
```

Agent menampilkan.

Kemungkinan penyebab.

↓

USB Printer dicabut.

---

# 28. Live Alert

Realtime.

Android.

↓

Notification.

Browser.

↓

Notification.

Windows.

↓

Toast Notification.

---

# 29. Monitoring API

Semua monitoring.

Tersedia.

REST.

WebSocket.

Plugin.

Automation.

---

# 30. Resource Target

Monitoring.

CPU.

<1%

RAM.

<80MB

Refresh.

1 detik.

Bisa diubah.

---

# 31. Performance Analyzer

Saya ingin Agent menghitung.

```text
Hari ini.

CPU rata-rata

18%

RAM rata-rata

39%

Internet rata-rata

120Mbps
```

---

# 32. Predictive Warning (Future)

Misalnya.

```text
Drive C

Naik

500MB

per hari
```

↓

Diperkirakan.

Penuh dalam.

14 hari.

---

Atau.

```text
Battery Health

Turun

2%

per bulan
```

↓

Diperkirakan.

80%.

Dalam.

6 bulan.

---

# 33. Smart Notification

Saya tidak ingin spam.

Misalnya.

CPU.

90%

91%

92%

93%

Tidak perlu.

4 notifikasi.

Cukup.

```text
CPU Tinggi Selama 5 Menit
```

Satu notifikasi.

---

# 34. Monitoring Workspace

User dapat membuat dashboard sendiri.

Misalnya.

Workspace.

```text
Gaming

CPU

GPU

FPS

Temperature
```

Workspace.

```text
Office

Printer

Storage

Download

Internet
```

Workspace.

```text
Server

Service

CPU

RAM

Logs
```

---

# 35. Widget Dashboard

Pengguna bisa drag & drop widget.

Contoh widget:

- CPU Gauge
- RAM Gauge
- Network Speed
- Storage Card
- Printer Status
- Download Queue
- Notification Feed
- Timeline
- Health Score
- Quick Actions

Semua widget dapat diatur ukurannya dan posisinya.

---

# 36. Resource Budget

Setiap modul monitoring memiliki "budget" penggunaan sumber daya.

Contoh:

- CPU Monitor: maksimal 0,2% CPU.
- RAM Monitor: maksimal 10 MB.
- Network Monitor: maksimal 5 MB.

Jika melebihi budget, Agent otomatis menurunkan frekuensi pembaruan atau menghentikan modul yang tidak penting.

---

# 37. Safe Mode Monitoring

Jika Agent mengalami masalah.

Monitoring tetap berjalan.

Automation dimatikan.

Plugin non-esensial dimatikan.

Core tetap hidup.

Jadi pengguna masih dapat mengetahui kondisi komputer.

---

# 38. Integrasi

Monitoring menjadi sumber data bagi:

- Dashboard
- Notification
- Automation
- AI Command
- Plugin
- API
- Logs
- Health Score

Semua modul mengambil data dari Monitoring Engine, bukan langsung dari Windows.

---

# 39. Prinsip Desain

- Monitoring harus selalu lebih ringan daripada aplikasi yang sedang dipantau.
- Semua data penting tersedia secara real-time.
- Informasi disajikan dalam bentuk yang mudah dipahami, bukan hanya angka.
- Jika suatu sensor tidak didukung oleh perangkat keras, aplikasi tetap berjalan normal dan menjelaskan bahwa data tersebut tidak tersedia.
- Semua ambang batas (threshold) dapat dikustomisasi oleh pengguna.

---

# 💡 Fitur Besar yang Saya Usulkan

## **System Digital Twin**

Ini menurut saya akan menjadi fitur yang belum banyak dimiliki aplikasi sejenis.

WinPilot membuat representasi virtual komputer.

Misalnya.

```text
Windows PC

🟢 CPU

🟢 RAM

🟡 Drive C

🟢 Internet

🔴 Printer

🟢 Bluetooth

🟢 USB
```

Klik.

↓

Masuk detail.

Klik CPU.

↓

Semua core muncul.

Klik Drive.

↓

Semua folder.

Klik Printer.

↓

Queue.

Klik Internet.

↓

Bandwidth.

# 📘 PRD-009

# Plugin SDK & Extension Platform

**Version:** 1.0

---

# 1. Vision

Core WinPilot harus tetap kecil, stabil, dan ringan.

Semua kemampuan tambahan berada di luar Core.

Target akhirnya adalah:

> **"Core tetap kecil, fitur terus bertambah."**

---

# 2. Filosofi

Core hanya bertugas:

- Authentication
- API
- WebSocket
- Event Bus
- Plugin Loader
- Logger
- Scheduler
- Config
- Database

Selain itu...

Harus menjadi Plugin.

---

# 3. Plugin Architecture

```text
WinPilot Core

│

├── Plugin Manager

├── Event Bus

├── SDK

└── Plugin Loader

        │

        ▼

Plugin

├── File

├── Printer

├── Browser

├── Docker

├── Git

├── VS Code

├── Flutter

├── Spotify

├── OBS

├── AI

└── Custom
```

---

# 4. Plugin Folder

```text
plugins/

file/

printer/

network/

terminal/

clipboard/

browser/

download/

notification/

automation/

docker/

flutter/

git/

vscode/

obs/

spotify/

youtube/

camera/

microphone/

custom/
```

---

# 5. Plugin Structure

Contoh.

```text
printer/

manifest.json

plugin.exe

icon.png

README.md

config.json

assets/

locales/
```

---

# 6. Plugin Manifest

Setiap plugin memiliki manifest.

Contoh.

```json
{
  "name": "Printer",
  "version": "1.0.0",
  "author": "WinPilot",
  "permission": ["printer", "notification"]
}
```

Manifest digunakan untuk:

- Identitas plugin.
- Hak akses.
- Dependensi.
- Versi.
- Kompatibilitas.

---

# 7. Plugin Lifecycle

Saat Agent menyala.

```text
Discover Plugin

↓

Validate

↓

Load

↓

Initialize

↓

Register API

↓

Register Event

↓

Ready
```

Saat Agent dimatikan.

```text
Save

↓

Dispose

↓

Unload
```

---

# 8. Plugin Types

### System Plugin

Plugin bawaan.

Tidak bisa dihapus.

Contoh.

File.

Printer.

Power.

---

### Official Plugin

Plugin resmi.

Dapat diperbarui.

---

### Community Plugin

Plugin buatan pengguna.

---

### Local Plugin

Plugin pribadi.

Tidak dipublikasikan.

---

# 9. SDK

SDK menyediakan.

Logger

Notification

Database

REST API

WebSocket

Storage

Settings

Scheduler

Event

Permission

Plugin tidak boleh langsung mengakses Core.

Harus melalui SDK.

---

# 10. Event System

Plugin dapat mengirim event.

Misalnya.

```text
Printer Ready

↓

Notification

↓

Dashboard
```

atau.

```text
Flutter Build Finished

↓

Automation

↓

Notification
```

---

# 11. Plugin API

Plugin dapat membuat endpoint sendiri.

Contoh.

```text
/api/v1/plugin/flutter/build
```

atau.

```text
/api/v1/plugin/spotify/play
```

Core otomatis mendaftarkan endpoint tersebut.

---

# 12. Plugin UI

Plugin dapat menambahkan.

Halaman.

Menu.

Widget Dashboard.

Quick Action.

Settings.

Semuanya menggunakan komponen UI yang disediakan WinPilot agar tampilannya tetap konsisten.

---

# 13. Plugin Permission

Plugin harus meminta izin.

Misalnya.

```text
Printer

↓

Printer Access

Clipboard

↓

Clipboard Access

Camera

↓

Camera Access
```

Owner dapat mencabut izin kapan saja.

---

# 14. Plugin Settings

Setiap plugin memiliki pengaturan sendiri.

Contoh.

Printer.

↓

Default Printer.

↓

Paper Size.

↓

Copies.

Plugin lain tidak boleh membaca pengaturan plugin lain tanpa izin.

---

# 15. Plugin Storage

Setiap plugin memiliki ruang penyimpanan sendiri.

Contoh.

```text
plugins/

printer/

data/

config.db

logs/

cache/
```

Plugin tidak boleh menulis ke folder plugin lain.

---

# 16. Plugin Logging

Setiap plugin mempunyai log.

Contoh.

```text
09:00

Print Success

09:02

Printer Offline

09:05

Reconnect
```

Log dipisahkan dari log Core.

---

# 17. Plugin Crash Recovery

Jika plugin crash.

```text
Restart Plugin
```

Jika masih gagal.

```text
Disable Plugin
```

Core tetap hidup.

Plugin lain tetap berjalan.

---

# 18. Plugin Dependency

Plugin dapat bergantung pada plugin lain.

Contoh.

```text
Flutter Plugin

↓

Terminal Plugin
```

Jika dependensi belum tersedia.

Plugin tidak akan dimuat dan pengguna mendapat penjelasan yang jelas.

---

# 19. Plugin Version

Setiap plugin memiliki:

Version

Release Notes

Update Channel

Rollback

---

# 20. Plugin Update

Plugin dapat diperbarui tanpa menghentikan seluruh Agent.

Alur:

```text
Download

↓

Verify

↓

Install

↓

Restart Plugin
```

---

# 21. Plugin Marketplace (Future)

Walaupun inti WinPilot tetap bisa digunakan tanpa internet.

Marketplace dapat digunakan untuk:

- Install Plugin.
- Update Plugin.
- Rating.
- Dokumentasi.

Marketplace bersifat opsional.

---

# 22. Plugin Signature

Plugin resmi.

↓

Signed.

Plugin Community.

↓

Unsigned.

Owner dapat memilih.

```text
Allow Unsigned Plugin
```

atau.

```text
Official Plugin Only
```

---

# 23. Plugin Sandbox

Plugin tidak boleh.

Menghapus file sistem.

Mengakses plugin lain.

Membaca database Core secara langsung.

Semua akses melalui SDK.

---

# 24. Plugin Performance Budget

Target.

RAM.

<20MB.

CPU Idle.

<0.1%.

Jika melebihi.

Plugin diberi peringatan.

---

# 25. Plugin Health

Dashboard.

```text
Printer

🟢

Flutter

🟢

Spotify

🟡

OBS

🔴
```

Klik.

↓

Detail.

↓

Log.

↓

Restart.

---

# 26. Plugin Development Kit

Developer mendapatkan.

Template.

CLI.

Debugger.

Hot Reload (untuk plugin yang mendukung).

Contoh:

```bash
winpilot plugin create my-plugin
```

↓

Struktur folder otomatis dibuat.

---

# 27. Plugin Documentation

Setiap plugin wajib memiliki:

- README.
- API Reference.
- Changelog.
- Permission List.
- Contoh penggunaan.

---

# 28. Plugin Testing

Sebelum dipasang.

Plugin dapat diuji.

↓

Sandbox.

↓

Validation.

↓

Compatibility Check.

---

# 29. Plugin Metrics

Core mengumpulkan statistik.

Contoh.

```text
Printer Plugin

RAM

12MB

CPU

0.1%

API

40 Request

Error

0
```

---

# 30. Plugin Removal

Jika plugin dihapus.

Core menawarkan.

```text
Delete Data?

YES

NO
```

---

# 31. Prinsip Desain

- Plugin tidak boleh membuat Core crash.
- Semua plugin menggunakan API resmi.
- Plugin harus bisa diperbarui secara independen.
- Setiap plugin memiliki batas penggunaan sumber daya.
- Plugin tidak boleh mengambil alih kontrol penuh sistem tanpa izin yang sesuai.

---

# 💡 Usulan Besar yang Saya Ingin Tambahkan

## **Plugin Store Lokal**

Berbeda dengan marketplace online.

Saya ingin WinPilot memiliki:

```text
Plugin Pack

Office Pack

Developer Pack

Media Pack

Printer Pack

Network Pack
```

Misalnya Anda menginstal.

```text
Developer Pack
```

↓

Otomatis terpasang:

- Git
- Terminal
- Docker
- Flutter
- VS Code

Atau.

```text
Office Pack
```

↓

Otomatis:

- Printer
- Scanner
- PDF
- Excel
- Word

Jadi pengguna cukup memilih paket sesuai kebutuhan.

---

## **Plugin Dependency Visualizer**

Jika sebuah plugin membutuhkan plugin lain.

User melihat.

```text
Flutter Plugin

↓

Terminal

↓

Notification

↓

Logger
```

Dalam bentuk grafik.

---

## **Plugin Resource Governor**

Ini fitur yang menurut saya sangat penting.

Jika ada plugin yang tiba-tiba memakai:

- CPU 30%
- RAM 500MB

Core otomatis.

↓

Throttle.

↓

Warning.

↓

Disable jika perlu.

# 📘 PRD-010

# AI Command Center & Intelligence Engine

**Version:** 1.0

---

# 1. Vision

AI bukan fitur utama.

AI adalah **lapisan pintar** yang membantu semua modul.

Target.

User cukup berkata:

> "Print file laporan bulan ini."

↓

WinPilot tahu.

↓

Cari file.

↓

Pilih printer.

↓

Print.

↓

Notifikasi.

Tanpa membuka menu.

---

# 2. Philosophy

AI tidak boleh mengambil alih sistem.

AI hanya:

- memahami
- membantu
- menyarankan
- menjalankan

Semua aksi penting tetap membutuhkan izin.

---

# 3. AI Architecture

```text
User

↓

Natural Language

↓

Intent Parser

↓

Command Engine

↓

Permission

↓

Action

↓

Response
```

---

# 4. AI Layers

Saya membagi AI menjadi beberapa lapisan.

```text
Language Layer

↓

Intent Layer

↓

Planning Layer

↓

Execution Layer

↓

Response Layer
```

---

# 5. Intent Recognition

Misalnya.

User mengetik.

```text
shutdown pc
```

Intent.

↓

Power.Shutdown

---

User.

```text
copy project flutter ke drive d
```

Intent.

↓

File.Copy

---

User.

```text
berapa sisa drive c
```

Intent.

↓

Storage.Info

---

# 6. Supported Intent

Power

File

Printer

Clipboard

Music

Automation

Monitoring

Application

Plugin

Terminal

Settings

Notification

Network

Downloads

Search

Device

---

# 7. Smart Search

Misalnya.

```text
folder flutter yang saya buka minggu lalu
```

↓

Search.

↓

Recent.

↓

Folder.

---

Atau.

```text
foto tanggal kemarin
```

↓

Image.

↓

Yesterday.

↓

Result.

---

# 8. AI Planner

Ini menurut saya fitur paling keren.

Misalnya.

User.

```text
backup project lalu matikan komputer
```

AI.

↓

Planning.

```text
Copy

↓

ZIP

↓

Verify

↓

Shutdown
```

User tinggal.

OK.

↓

Run.

---

# 9. Confirmation Layer

Action berbahaya.

Misalnya.

Delete.

↓

Shutdown.

↓

Restart.

↓

Format.

AI.

↓

Confirm.

```text
Apakah Anda yakin?
```

---

# 10. Voice Command

Future.

Misalnya.

```text
Restart komputer.
```

↓

Execute.

---

# 11. Context Engine

AI mengetahui konteks.

Misalnya.

User sedang membuka.

Downloads.

Lalu.

```text
hapus file terbesar
```

AI tahu.

Yang dimaksud.

Folder Downloads.

---

# 12. Command History

Semua command.

Disimpan.

↓

Search.

↓

Favorite.

↓

Repeat.

---

# 13. Favorite Command

Misalnya.

```text
restart explorer
```

↓

Favorite.

↓

One Tap.

---

# 14. AI Suggestion

Contoh.

Drive penuh.

↓

AI menyarankan.

```text
Hapus Temporary File
```

↓

Button.

↓

Execute.

---

# 15. Recommendation

Misalnya.

CPU.

95%.

AI.

↓

Kemungkinan.

Chrome.

↓

VS Code.

↓

Windows Update.

---

# 16. AI Workflow Builder

User.

```text
Setiap jam 22.00 backup folder project.
```

AI.

↓

Membuat.

Workflow.

↓

Automation.

---

# 17. AI File Finder

User.

```text
cari pdf invoice bulan april
```

↓

Search.

↓

Filter.

↓

PDF.

↓

April.

↓

Result.

---

# 18. AI Monitoring

AI membaca.

Health Engine.

Misalnya.

SSD.

95%.

↓

Warning.

↓

Saran.

---

# 19. AI Notification

Bukan.

```text
CPU 91%
```

Tetapi.

```text
CPU tinggi selama 15 menit.

Kemungkinan Windows Update sedang berjalan.
```

---

# 20. AI Explanation

Misalnya.

Printer Error.

AI menjelaskan.

Kemungkinan.

- Kabel USB terlepas.
- Printer mati.
- Driver bermasalah.

---

# 21. AI Assistant

Saya **tidak ingin ada layar chat yang mendominasi**.

Saya ingin.

Command Bar.

```text
Cari...

atau ketik perintah...
```

Seperti Spotlight di macOS atau Command Palette di VS Code.

---

# 22. AI Memory

AI mengingat.

Favorite Folder.

Printer.

Workflow.

Device.

Recent Command.

Bukan mengingat percakapan pribadi.

---

# 23. AI Privacy

Semua.

Default.

Offline.

Tidak mengirim data.

Ke cloud.

Jika user ingin memakai AI cloud.

↓

Harus mengaktifkan sendiri.

---

# 24. AI Plugin

AI dapat memakai plugin.

Misalnya.

Flutter Plugin.

↓

Build.

↓

Notification.

---

# 25. AI API

Plugin dapat menambah intent.

Misalnya.

Spotify Plugin.

↓

Intent.

```text
play music
```

OBS Plugin.

↓

Intent.

```text
start recording
```

---

# 26. AI Performance

Target.

Idle.

↓

0 CPU.

Saat digunakan.

↓

Respon.

<500ms.

Untuk command lokal.

---

# 27. AI Learning

Saya **tidak ingin AI belajar diam-diam**.

User harus memilih.

```text
Improve Suggestions

ON

OFF
```

Jika OFF.

Tidak ada data penggunaan yang disimpan untuk pembelajaran.

---

# 28. Local AI (Future)

Jika user memiliki.

LLM lokal.

↓

WinPilot.

↓

Menggunakannya.

Misalnya.

- Ollama
- llama.cpp
- LM Studio

Tanpa mengirim data keluar.

---

# 29. AI Safety

AI.

Tidak boleh.

- Format Disk.
- Delete System File.
- Disable Security.

Tanpa.

Konfirmasi.

---

# 30. Prinsip Desain

AI harus:

- Cepat.
- Ringan.
- Tidak wajib.
- Tidak mengganggu.
- Tidak mengirim data tanpa izin.
- Bisa dimatikan sepenuhnya.

---

# 31. AI Capability Matrix

| Kemampuan                | V1  | V2  | V3  |
| ------------------------ | --- | --- | --- |
| Natural Language Command | ✅  | -   | -   |
| Smart Search             | ✅  | -   | -   |
| Workflow Builder         | ✅  | -   | -   |
| Context Awareness        | ✅  | ✅  | -   |
| Voice Command            | -   | ✅  | -   |
| Local LLM Integration    | -   | ✅  | -   |
| Predictive Analysis      | -   | -   | ✅  |
| Multi-step Reasoning     | -   | -   | ✅  |

---

# 32. AI Prompt Engine

Daripada hardcode semua perintah.

Saya ingin.

```text
Prompt

↓

Intent

↓

JSON

↓

Command

↓

Execution
```

Jadi.

Plugin.

Bisa menambahkan Prompt sendiri.

---

# 33. Command Palette (Fitur Ikonik)

Menurut saya.

Ini akan menjadi.

"Signature Feature"

WinPilot.

Tekan.

```text
Ctrl + Space
```

atau.

Android.

↓

Floating Button.

↓

Muncul.

```text
─────────────────────

🔍 Cari...

atau

Ketik Perintah

─────────────────────

restart explorer

shutdown

printer

spotify

cpu

workflow

backup

flutter

─────────────────────
```

Semua.

Dalam.

Satu tempat.

---

# 34. AI Action Preview

Saya **tidak ingin AI langsung mengeksekusi**.

Contoh.

User.

```text
Backup semua project lalu shutdown.
```

AI.

Menampilkan.

```text
Yang akan dilakukan.

✓ Copy Folder

✓ ZIP

✓ Verify

✓ Shutdown
```

Button.

```text
Run

Cancel

Edit
```

---

# 35. AI Confidence Score

Setiap command memiliki tingkat keyakinan.

Misalnya.

```text
Restart Explorer

98%
```

↓

Langsung.

Execute.

---

```text
Delete Semua File

41%
```

↓

Minta klarifikasi.

---

# 36. AI Error Recovery

Jika AI gagal memahami.

Jangan.

```text
Unknown Command.
```

Tetapi.

```text
Apakah maksud Anda:

Restart Windows

Restart Explorer

Restart Printer
```

---

# 💡 Usulan Besar (V2)

## **Digital Operator**

Ini menurut saya akan menjadi fitur paling unik.

Bukan chatbot.

Tetapi.

Operator.

Contoh.

Anda mengetik.

> "Komputer saya terasa lambat."

Digital Operator akan:

1. Memeriksa CPU.
2. Memeriksa RAM.
3. Memeriksa SSD.
4. Memeriksa Startup Apps.
5. Memeriksa Windows Update.
6. Memeriksa proses berat.
7. Memberikan laporan.

Mantap. Menurut saya, **PRD-011 adalah dokumen yang membedakan proyek hobi dengan produk profesional**.

Banyak aplikasi memiliki banyak fitur, tetapi gagal karena:

- memory leak,
- CPU tinggi,
- update rusak,
- crash,
- logging buruk.

# 📘 PRD-011

# Quality Engineering, Reliability & Operations

**Version:** 1.0

---

# 1. Vision

Target WinPilot bukan hanya memiliki banyak fitur.

Targetnya adalah:

> **"WinPilot harus dapat berjalan 24 jam sehari selama berbulan-bulan tanpa perlu restart."**

---

# 2. Quality Philosophy

Urutan prioritas:

```
Stability

↓

Performance

↓

Security

↓

Features
```

Jika sebuah fitur membuat Agent menjadi berat.

↓

Fitur tersebut harus diperbaiki atau ditunda.

---

# 3. Reliability Target

Availability

```
99.9%
```

Crash Recovery

```
<5 detik
```

Startup

```
<2 detik
```

Shutdown

```
<2 detik
```

---

# 4. Performance Budget

## Agent

RAM Idle

```
<30MB
```

RAM Maximum

```
<100MB
```

CPU Idle

```
<0.2%
```

CPU Maximum

```
<2%
```

Disk IO

Serendah mungkin.

---

## Flutter

Cold Start

```
<3 detik
```

Hot Reload UI

```
<500ms
```

Page Navigation

```
<150ms
```

---

# 5. API Performance

GET

```
<100ms
```

POST

```
<150ms
```

WebSocket

Realtime

Latency

```
<50ms
```

Pada jaringan lokal.

---

# 6. Plugin Performance

Target.

Plugin.

RAM

```
<20MB
```

CPU

```
<0.5%
```

Jika melebihi.

↓

Plugin Governor.

↓

Throttle.

↓

Warning.

↓

Disable.

---

# 7. Crash Recovery

Saya ingin.

```text
Plugin Crash

↓

Restart Plugin

↓

Log

↓

Notification
```

Kalau gagal.

↓

Disable.

Core tetap hidup.

---

# 8. Memory Leak Protection

Agent melakukan.

Self Check.

Setiap.

5 menit.

Jika.

RAM naik terus.

↓

Warning.

↓

Restart Plugin.

---

# 9. Auto Recovery

Misalnya.

Printer Plugin.

Crash.

↓

Restart.

↓

Success.

User bahkan tidak sadar.

---

# 10. Backup

Agent.

Backup.

Database.

Workflow.

Plugin.

Settings.

Automation.

History.

---

# 11. Restore

Restore.

↓

One Click.

Tidak perlu install ulang.

---

# 12. Update

Agent.

↓

Download.

↓

Verify.

↓

Install.

↓

Restart.

↓

Rollback jika gagal.

---

# 13. Version Management

Semua.

Plugin.

Core.

Flutter.

Memiliki.

Version.

Release Note.

Rollback.

---

# 14. Logging

Log dipisahkan.

Core.

Plugin.

API.

Automation.

Security.

Crash.

Performance.

---

# 15. Log Viewer

Flutter.

↓

Search.

↓

Filter.

↓

Export.

↓

Share.

---

# 16. Diagnostic Mode

Misalnya.

User.

↓

"Komputer saya lambat"

↓

Diagnostic.

↓

Generate Report.

---

# 17. Report

Berisi.

CPU.

RAM.

Plugin.

Crash.

Version.

Windows.

Network.

---

# 18. Export

Report.

↓

ZIP.

↓

Kirim.

↓

Developer.

---

# 19. Health Checker

Saat startup.

Agent memeriksa.

Database.

Plugin.

Port.

Permission.

Config.

---

# 20. Safe Mode

Jika.

Database rusak.

↓

Safe Mode.

↓

Monitoring tetap hidup.

↓

Automation mati.

↓

Plugin mati.

↓

Recovery.

---

# 21. Testing Strategy

Unit Test.

Integration Test.

API Test.

Plugin Test.

Automation Test.

UI Test.

Stress Test.

Long Running Test.

---

# 22. Stress Test

Target.

1000.

API Request.

↓

Tidak crash.

---

Plugin.

100.

↓

Tetap stabil.

---

Workflow.

1000.

↓

Tetap berjalan.

---

# 23. Benchmark

Boot.

API.

Search.

Upload.

Download.

Print.

Automation.

Semua memiliki benchmark.

---

# 24. Telemetry

Default.

OFF.

Jika user setuju.

↓

Kirim.

Crash Report.

Anonim.

Tidak wajib.

---

# 25. CI/CD

GitHub.

↓

Build.

↓

Test.

↓

Release.

↓

Installer.

---

# 26. Installer

Installer.

Harus.

Satu klik.

↓

Install.

↓

Run Service.

↓

Done.

---

# 27. Uninstaller

Menghapus.

Core.

Plugin.

Registry.

Service.

Log.

Data.

Atau.

Simpan Data.

---

# 28. Configuration

Semua.

JSON.

SQLite.

Tidak memakai Registry Windows untuk konfigurasi utama.

---

# 29. Code Quality

Backend.

- SOLID.
- Clean Architecture.
- Dependency Injection.
- Interface First.

Flutter.

- Feature First.
- GetX.
- Repository.
- Modular.

---

# 30. Documentation

Developer.

↓

API.

Plugin.

Architecture.

User.

↓

Tutorial.

FAQ.

Troubleshooting.

---

# 31. Release Channel

Stable.

Beta.

Nightly.

User bebas memilih.

---

# 32. Feature Flag

Fitur eksperimen.

↓

ON/OFF.

Tanpa update.

---

# 33. Compatibility

Windows 10.

Windows 11.

ARM (Future).

---

# 34. Disaster Recovery

Jika.

Agent rusak.

↓

Restore.

↓

Backup.

↓

Run.

---

# 35. Security Audit

Sebelum release.

↓

Static Analysis.

↓

Dependency Scan.

↓

Permission Audit.

↓

API Audit.

---

# 36. Resource Governor

Core mengawasi.

Plugin.

Automation.

API.

Monitoring.

Jika salah satu memakai resource berlebihan.

↓

Throttle.

↓

Log.

↓

Warning.

↓

Disable jika perlu.

---

# 37. Development Rules

Tidak boleh.

Plugin.

↓

Mengakses Database Core.

Tidak boleh.

Plugin.

↓

Memanggil Plugin lain.

Semua.

Melalui SDK.

---

# 38. Release Checklist

Sebelum release.

- Semua test lulus.
- Tidak ada memory leak.
- Benchmark sesuai target.
- Installer berhasil.
- Rollback diuji.
- Dokumentasi diperbarui.
- Changelog dibuat.

---

# 💡 Usulan Terbesar (Yang Belum Pernah Saya Sebut)

## **Mission Control**

Saya ingin membuat halaman khusus untuk Owner.

Semua informasi ada di satu tempat.

```text
──────────────────────────

🟢 Windows Online

Health Score

98

CPU

18%

RAM

42%

Storage

61%

Internet

Excellent

Printer

Ready

Workflow

2 Running

Plugin

31 Active

Notification

1

──────────────────────────

Quick Action

Restart

Shutdown

Screenshot

Open Downloads

Automation

──────────────────────────

Recent Activity

09.00 Print

09.10 Upload

09.30 Shutdown Cancelled

09.35 USB Connected

──────────────────────────

Recommendation

✓ Drive C hampir penuh

✓ Windows Update tersedia

✓ Backup belum dijalankan

──────────────────────────
```

Halaman ini menjadi **"cockpit"** utama WinPilot.

Owner tidak perlu membuka menu lain.

Semuanya tersedia di satu layar.

---

# 📊 Evaluasi Seluruh Arsitektur

Setelah 11 PRD, menurut saya WinPilot sudah berada di level **produk enterprise**, bukan lagi sekadar aplikasi remote.

Yang sudah dirancang:

- ✅ Arsitektur inti.
- ✅ Windows Agent.
- ✅ Flutter Client.
- ✅ Multi-user & keamanan.
- ✅ File Management.
- ✅ Device & System Control.
- ✅ Automation Engine.
- ✅ Monitoring Center.
- ✅ Plugin SDK.
- ✅ AI Orchestrator.
- ✅ Quality Engineering & Operations.

# 📘 PRD-012

# Final Engineering Blueprint

## WinPilot v1.0

---

# 1. Final Vision

WinPilot adalah **Private Windows Management Platform** yang mengubah komputer Windows menjadi server pribadi yang dapat dikelola dari mana saja menggunakan Flutter.

Bukan Remote Desktop.

Bukan Cloud.

Bukan TeamViewer.

Tetapi Operating System Management Platform.

---

# 2. Product Goals

Target WinPilot.

✓ Ringan

✓ Cepat

✓ Modular

✓ Plugin Based

✓ Offline First

✓ Privacy First

✓ AI Assisted

✓ Enterprise Quality

---

# 3. Final Architecture

```text
                Flutter Android
                      │
                Flutter Web
                      │
           REST API + WebSocket
                      │
        ┌────────────────────────┐
        │     WinPilot Core      │
        ├────────────────────────┤
        │ Authentication         │
        │ Permission             │
        │ Event Bus              │
        │ Scheduler              │
        │ Plugin Manager         │
        │ Notification           │
        │ Logger                 │
        │ Metrics               │
        └──────────┬─────────────┘
                   │
      ┌────────────┼────────────┐
      │            │            │
 Plugin        Automation    Monitoring
      │            │            │
      └────────────┼────────────┘
                   │
             Windows API
```

---

# 4. Monorepo Structure

Saya menyarankan seluruh proyek memakai **Monorepo**.

```text
winpilot/

docs/
    PRD/
    API/
    SDK/

agent/

core/

plugins/

mobile/

web/

shared/

installer/

scripts/

tests/

examples/

sdk/

tools/

.github/

build/

assets/
```

---

# 5. Folder Agent

```text
agent/

cmd/

internal/

api/

auth/

config/

core/

dispatcher/

events/

logger/

metrics/

monitor/

plugin/

scheduler/

storage/

utils/

windows/
```

Semua folder memiliki satu tanggung jawab.

---

# 6. Folder Flutter

```text
mobile/

lib/

core/

shared/

modules/

dashboard/

files/

monitoring/

automation/

plugins/

settings/

login/

widgets/

theme/

routes/
```

Setiap fitur menjadi module sendiri.

---

# 7. Folder Plugin

```text
plugins/

printer/

browser/

clipboard/

download/

docker/

flutter/

git/

spotify/

obs/

terminal/

network/

camera/

microphone/
```

Semuanya independen.

---

# 8. API Convention

Semua API.

```
/api/v1/
```

Contoh.

```
GET

/api/v1/system
```

```
POST

/api/v1/shutdown
```

```
GET

/api/v1/files
```

```
POST

/api/v1/print
```

Semua Response.

```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

Error.

```json
{
  "success": false,
  "code": 403,
  "message": "Permission Denied"
}
```

---

# 9. SQLite

Tabel utama.

```
users

roles

permissions

devices

sessions

logs

plugins

automation

workflow

settings

notifications

history

favorites

storage

metrics
```

---

# 10. Core Components

Core hanya memiliki.

Authentication

Permission

API

WebSocket

Plugin Loader

Logger

Metrics

Scheduler

Configuration

Database

Tidak lebih.

---

# 11. Plugin Components

Plugin.

Harus memiliki.

Manifest

Version

Permission

Logger

Setting

Storage

API

Event

Semuanya melalui SDK.

---

# 12. Event Bus

Saya ingin.

Semua modul.

Tidak saling memanggil.

Semua memakai.

```
Publish

Subscribe
```

Misalnya.

```
Printer

↓

Event

↓

Notification

↓

Dashboard
```

---

# 13. Database Access

Saya **melarang**.

Plugin.

↓

Query Database langsung.

Semua.

Melalui Repository.

---

# 14. Coding Rules

Go.

↓

Clean Architecture.

Flutter.

↓

Feature First.

Tidak boleh.

Business Logic.

Masuk Widget.

---

# 15. Naming Convention

Go.

camelCase.

Package.

snake_case.

Flutter.

Feature.

snake_case.

Class.

PascalCase.

Widget.

PascalCase.

---

# 16. Error Standard

Semua Error.

Harus.

Code.

↓

Title.

↓

Description.

↓

Suggestion.

Contoh.

```
Printer Offline

Printer Epson L3210 sedang offline.

Pastikan printer hidup atau pilih printer lain.
```

---

# 17. Logging Standard

Setiap Log.

Harus memiliki.

Time.

Level.

Module.

Action.

Result.

Duration.

---

# 18. Security Standard

JWT.

TLS.

Permission.

Audit.

Device.

Session.

Rate Limit.

Semua wajib.

---

# 19. Testing Standard

Coverage.

80%.

Minimal.

Unit Test.

Integration.

Plugin.

Automation.

UI.

---

# 20. Build Pipeline

Git Push.

↓

Test.

↓

Lint.

↓

Build.

↓

Package.

↓

Installer.

↓

Release.

---

# 21. Release

Stable.

↓

Beta.

↓

Nightly.

---

# 22. Installer

Satu Klik.

↓

Install.

↓

Windows Service.

↓

Firewall Rule (opsional dengan izin pengguna).

↓

Run.

↓

Done.

---

# 23. Update

Agent.

↓

Auto Update.

Plugin.

↓

Independent Update.

Flutter.

↓

OTA untuk aset (bukan kode native).

---

# 24. Resource Budget

Target.

```
Core

30MB
```

Plugin.

```
20MB
```

Flutter.

```
200MB Max
```

CPU.

Idle.

```
<0.2%
```

---

# 25. MVP Roadmap

## Sprint 1

Authentication

REST API

WebSocket

Windows Service

Dashboard

---

## Sprint 2

File Explorer

Clipboard

Power

Printer

---

## Sprint 3

Monitoring

Notification

Download

Upload

---

## Sprint 4

Automation

Workflow

Scheduler

---

## Sprint 5

Plugin SDK

Developer Tools

---

## Sprint 6

AI

Optimization

Testing

---

# 26. Enterprise Roadmap

Setelah MVP.

Tambahkan.

Cluster.

Remote Relay.

Plugin Marketplace.

Desktop App.

Linux Agent.

macOS Agent.

Open SDK.

---

# 27. Open Source Strategy

Core.

↓

Open Source.

Plugin.

↓

Boleh.

Closed Source.

SDK.

↓

Open Source.

---

# 28. Final Product Identity

Nama.

```
WinPilot
```

Tagline.

```
Your Personal Windows Control Center
```

---

# 29. Filosofi Terakhir

Saya ingin WinPilot memiliki filosofi berikut:

> **"Semua komputer pribadi layak memiliki pusat kendali sendiri tanpa bergantung pada cloud."**

---

# 💡 Satu Usulan Terakhir (Yang Menurut Saya Akan Menjadikan WinPilot Sangat Berbeda)

Setelah menyusun 12 PRD ini, saya melihat bahwa WinPilot sebenarnya memiliki potensi untuk berkembang menjadi **ekosistem**, bukan hanya satu aplikasi.

Saya mengusulkan pembagian menjadi empat produk dalam satu monorepo:

## 1. WinPilot Core

Mesin utama yang berjalan sebagai Windows Service.

## 2. WinPilot Mobile

Aplikasi Flutter untuk Android (dan iOS jika suatu saat diinginkan).

## 3. WinPilot Web

Dashboard berbasis Flutter Web untuk diakses melalui browser.

## 4. WinPilot SDK

Perangkat pengembangan untuk membuat plugin, automation, dan integrasi pihak ketiga.

Dengan pembagian ini:

- Core tetap kecil dan stabil.
- Mobile fokus pada pengalaman pengguna.
- Web fokus pada administrasi.
- SDK memungkinkan komunitas atau Anda sendiri menambahkan fitur baru tanpa mengubah inti sistem.

---
