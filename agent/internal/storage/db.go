// Package storage manages the WinPilot SQLite database.
// All database access must go through Repository — never raw queries from plugins.
package storage

import (
	"database/sql"
	"fmt"
	"time"

	_ "github.com/mattn/go-sqlite3"
)

// DB wraps the SQLite database connection.
type DB struct {
	conn *sql.DB
}

// Open opens (or creates) the SQLite database at the given path.
func Open(path string) (*DB, error) {
	conn, err := sql.Open("sqlite3", path+"?_journal_mode=WAL&_foreign_keys=on")
	if err != nil {
		return nil, fmt.Errorf("storage: open db: %w", err)
	}

	conn.SetMaxOpenConns(1) // SQLite is single-writer
	conn.SetMaxIdleConns(1)
	conn.SetConnMaxLifetime(0)

	db := &DB{conn: conn}
	if err := db.migrate(); err != nil {
		return nil, fmt.Errorf("storage: migrate: %w", err)
	}

	return db, nil
}

// Close shuts down the database connection.
func (db *DB) Close() error {
	return db.conn.Close()
}

// migrate runs all database migrations idempotently.
func (db *DB) migrate() error {
	migrations := []string{
		// Users table
		`CREATE TABLE IF NOT EXISTS users (
			id          TEXT PRIMARY KEY,
			username    TEXT NOT NULL UNIQUE,
			password    TEXT NOT NULL,  -- bcrypt hash
			role        TEXT NOT NULL DEFAULT 'viewer',
			is_owner    INTEGER NOT NULL DEFAULT 0,
			created_at  DATETIME NOT NULL,
			updated_at  DATETIME NOT NULL
		)`,

		// Devices table
		`CREATE TABLE IF NOT EXISTS devices (
			id          TEXT PRIMARY KEY,
			user_id     TEXT NOT NULL REFERENCES users(id),
			name        TEXT NOT NULL,
			device_type TEXT NOT NULL,
			os          TEXT NOT NULL,
			paired_at   DATETIME NOT NULL,
			last_seen   DATETIME,
			last_ip     TEXT,
			is_trusted  INTEGER NOT NULL DEFAULT 1,
			is_blocked  INTEGER NOT NULL DEFAULT 0,
			permissions TEXT NOT NULL DEFAULT '{}',  -- JSON
			FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
		)`,

		// Sessions table
		`CREATE TABLE IF NOT EXISTS sessions (
			id             TEXT PRIMARY KEY,
			device_id      TEXT NOT NULL,
			refresh_token  TEXT NOT NULL UNIQUE,
			ip_address     TEXT,
			location_type  TEXT,  -- 'local' or 'remote'
			created_at     DATETIME NOT NULL,
			expires_at     DATETIME NOT NULL,
			FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE CASCADE
		)`,

		// Pairing codes table
		`CREATE TABLE IF NOT EXISTS pairing_codes (
			code        TEXT PRIMARY KEY,
			type        TEXT NOT NULL,  -- 'qr' or 'otp'
			used        INTEGER NOT NULL DEFAULT 0,
			created_at  DATETIME NOT NULL,
			expires_at  DATETIME NOT NULL
		)`,

		// Audit logs table
		`CREATE TABLE IF NOT EXISTS logs (
			id         TEXT PRIMARY KEY,
			user_id    TEXT,
			device_id  TEXT,
			module     TEXT NOT NULL,
			action     TEXT NOT NULL,
			result     TEXT NOT NULL,  -- 'ok', 'failed', 'denied'
			details    TEXT,           -- JSON
			ip_address TEXT,
			duration   INTEGER,        -- milliseconds
			created_at DATETIME NOT NULL
		)`,

		// Plugins table
		`CREATE TABLE IF NOT EXISTS plugins (
			id          TEXT PRIMARY KEY,
			name        TEXT NOT NULL UNIQUE,
			version     TEXT NOT NULL,
			author      TEXT,
			status      TEXT NOT NULL DEFAULT 'enabled',  -- enabled, disabled, error
			permissions TEXT NOT NULL DEFAULT '[]',       -- JSON array
			ram_mb      REAL,
			cpu_pct     REAL,
			installed_at DATETIME NOT NULL,
			updated_at   DATETIME NOT NULL
		)`,

		// Settings table
		`CREATE TABLE IF NOT EXISTS settings (
			key         TEXT PRIMARY KEY,
			value       TEXT NOT NULL,  -- JSON
			updated_at  DATETIME NOT NULL
		)`,

		// Notifications table
		`CREATE TABLE IF NOT EXISTS notifications (
			id          TEXT PRIMARY KEY,
			type        TEXT NOT NULL,
			title       TEXT NOT NULL,
			body        TEXT NOT NULL,
			icon        TEXT,
			action_url  TEXT,
			read        INTEGER NOT NULL DEFAULT 0,
			created_at  DATETIME NOT NULL
		)`,

		// Automation table
		`CREATE TABLE IF NOT EXISTS automation (
			id          TEXT PRIMARY KEY,
			name        TEXT NOT NULL,
			description TEXT,
			trigger     TEXT NOT NULL,   -- JSON
			condition   TEXT,            -- JSON
			actions     TEXT NOT NULL,   -- JSON
			enabled     INTEGER NOT NULL DEFAULT 1,
			run_count   INTEGER NOT NULL DEFAULT 0,
			last_run    DATETIME,
			created_at  DATETIME NOT NULL,
			updated_at  DATETIME NOT NULL
		)`,

		// Workflow execution history
		`CREATE TABLE IF NOT EXISTS workflow_history (
			id           TEXT PRIMARY KEY,
			workflow_id  TEXT NOT NULL,
			status       TEXT NOT NULL,  -- running, success, failed, stopped
			started_at   DATETIME NOT NULL,
			finished_at  DATETIME,
			log          TEXT            -- JSON array of log entries
		)`,

		// Favorites (files/folders)
		`CREATE TABLE IF NOT EXISTS favorites (
			id         TEXT PRIMARY KEY,
			user_id    TEXT NOT NULL,
			type       TEXT NOT NULL,  -- 'folder', 'file', 'app', 'action'
			label      TEXT NOT NULL,
			path       TEXT NOT NULL,
			icon       TEXT,
			sort_order INTEGER NOT NULL DEFAULT 0,
			created_at DATETIME NOT NULL
		)`,

		// Metrics history (time-series snapshots)
		`CREATE TABLE IF NOT EXISTS metrics (
			id         TEXT PRIMARY KEY,
			cpu_pct    REAL,
			ram_pct    REAL,
			disk_pct   REAL,
			net_up     INTEGER,
			net_down   INTEGER,
			temp_cpu   REAL,
			battery    REAL,
			recorded_at DATETIME NOT NULL
		)`,

		// Indexes
		`CREATE INDEX IF NOT EXISTS idx_logs_created_at ON logs(created_at)`,
		`CREATE INDEX IF NOT EXISTS idx_metrics_recorded_at ON metrics(recorded_at)`,
		`CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications(read)`,
		`CREATE INDEX IF NOT EXISTS idx_sessions_device ON sessions(device_id)`,
	}

	tx, err := db.conn.Begin()
	if err != nil {
		return err
	}
	defer tx.Rollback() //nolint:errcheck

	for _, migration := range migrations {
		if _, err := tx.Exec(migration); err != nil {
			return fmt.Errorf("migration failed: %w\nSQL: %s", err, migration)
		}
	}

	return tx.Commit()
}

// Conn returns the underlying sql.DB for repository use.
func (db *DB) Conn() *sql.DB {
	return db.conn
}

// Helper: NullTime converts *time.Time to sql.NullTime.
func NullTime(t *time.Time) sql.NullTime {
	if t == nil {
		return sql.NullTime{}
	}
	return sql.NullTime{Time: *t, Valid: true}
}
