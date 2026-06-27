// Package auth implements WinPilot's authentication system.
// Flow: QR/OTP Pairing → Device Token → JWT Access + Refresh Tokens
package auth

import (
	"crypto/rand"
	"database/sql"
	"encoding/hex"
	"errors"
	"fmt"
	"math/big"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

// Errors
var (
	ErrInvalidCredentials = errors.New("invalid credentials")
	ErrDeviceNotTrusted   = errors.New("device not trusted")
	ErrDeviceBlocked      = errors.New("device is blocked")
	ErrTokenExpired       = errors.New("token expired")
	ErrTokenInvalid       = errors.New("token invalid")
	ErrCodeExpired        = errors.New("pairing code expired or already used")
	ErrCodeInvalid        = errors.New("invalid pairing code")
	ErrTooManyAttempts    = errors.New("too many login attempts")
)

// Claims is the JWT payload.
type Claims struct {
	jwt.RegisteredClaims
	UserID    string   `json:"uid"`
	DeviceID  string   `json:"did"`
	Role      string   `json:"role"`
	IsOwner   bool     `json:"owner"`
	Permissions []string `json:"perms"`
}

// TokenPair holds both JWT tokens.
type TokenPair struct {
	AccessToken  string    `json:"access_token"`
	RefreshToken string    `json:"refresh_token"`
	ExpiresAt    time.Time `json:"expires_at"`
}

// Service handles all authentication logic.
type Service struct {
	db                 *sql.DB
	jwtSecret          []byte
	accessTokenExpiry  time.Duration
	refreshTokenExpiry time.Duration
	pairingCodeExpiry  time.Duration
}

// ServiceConfig configures the auth service.
type ServiceConfig struct {
	DB                 *sql.DB
	JWTSecret          string
	AccessTokenExpiry  time.Duration
	RefreshTokenExpiry time.Duration
	PairingCodeExpiry  time.Duration
}

// NewService creates a new Auth Service.
func NewService(cfg ServiceConfig) *Service {
	return &Service{
		db:                 cfg.DB,
		jwtSecret:          []byte(cfg.JWTSecret),
		accessTokenExpiry:  cfg.AccessTokenExpiry,
		refreshTokenExpiry: cfg.RefreshTokenExpiry,
		pairingCodeExpiry:  cfg.PairingCodeExpiry,
	}
}

// GeneratePairingQR generates a one-time QR pairing code.
func (s *Service) GeneratePairingQR() (string, error) {
	code, err := generateSecureToken(32)
	if err != nil {
		return "", err
	}

	expires := time.Now().Add(s.pairingCodeExpiry)
	_, err = s.db.Exec(
		`INSERT INTO pairing_codes (code, type, used, created_at, expires_at) VALUES (?, 'qr', 0, ?, ?)`,
		code, time.Now(), expires,
	)
	if err != nil {
		return "", fmt.Errorf("auth: generate qr: %w", err)
	}

	return code, nil
}

// GeneratePairingOTP generates a 6-digit numeric OTP for pairing.
func (s *Service) GeneratePairingOTP() (string, error) {
	n, err := rand.Int(rand.Reader, big.NewInt(1000000))
	if err != nil {
		return "", err
	}
	code := fmt.Sprintf("%06d", n.Int64())

	expires := time.Now().Add(s.pairingCodeExpiry)
	_, err = s.db.Exec(
		`INSERT INTO pairing_codes (code, type, used, created_at, expires_at) VALUES (?, 'otp', 0, ?, ?)`,
		code, time.Now(), expires,
	)
	if err != nil {
		return "", fmt.Errorf("auth: generate otp: %w", err)
	}

	return code, nil
}

// PairDevice validates a pairing code and registers the device.
func (s *Service) PairDevice(code, deviceName, deviceType, deviceOS, deviceIP string) (*TokenPair, string, error) {
	// Validate pairing code
	var dbCode string
	var used bool
	var expiresAt time.Time

	err := s.db.QueryRow(
		`SELECT code, used, expires_at FROM pairing_codes WHERE code = ?`,
		code,
	).Scan(&dbCode, &used, &expiresAt)

	if err == sql.ErrNoRows {
		return nil, "", ErrCodeInvalid
	}
	if err != nil {
		return nil, "", err
	}
	if used {
		return nil, "", ErrCodeExpired
	}
	if time.Now().After(expiresAt) {
		return nil, "", ErrCodeExpired
	}

	// Mark code as used
	_, err = s.db.Exec(`UPDATE pairing_codes SET used = 1 WHERE code = ?`, code)
	if err != nil {
		return nil, "", err
	}

	// Get or create the owner user
	var ownerID string
	err = s.db.QueryRow(`SELECT id FROM users WHERE is_owner = 1`).Scan(&ownerID)
	if err == sql.ErrNoRows {
		// Create default owner on first pairing
		ownerID, err = s.createDefaultOwner()
		if err != nil {
			return nil, "", err
		}
	} else if err != nil {
		return nil, "", err
	}

	// Create device
	deviceID, err := generateSecureToken(16)
	if err != nil {
		return nil, "", err
	}

	defaultPerms := `{"shutdown":true,"restart":true,"lock":true,"files":true,"printer":true,"clipboard":true,"screenshot":true}`
	_, err = s.db.Exec(
		`INSERT INTO devices (id, user_id, name, device_type, os, paired_at, last_seen, last_ip, is_trusted, is_blocked, permissions)
		 VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1, 0, ?)`,
		deviceID, ownerID, deviceName, deviceType, deviceOS,
		time.Now(), time.Now(), deviceIP, defaultPerms,
	)
	if err != nil {
		return nil, "", fmt.Errorf("auth: create device: %w", err)
	}

	// Issue tokens
	tokens, err := s.issueTokens(ownerID, deviceID, "owner", true, nil)
	if err != nil {
		return nil, "", err
	}

	return tokens, deviceID, nil
}

// Login authenticates a device by deviceID + refresh token.
func (s *Service) Login(deviceID, refreshToken string) (*TokenPair, error) {
	// Verify device is trusted and not blocked
	var userID, role string
	var isOwner, isBlocked, isTrusted bool

	err := s.db.QueryRow(
		`SELECT u.id, u.role, u.is_owner, d.is_blocked, d.is_trusted
		 FROM devices d JOIN users u ON d.user_id = u.id
		 WHERE d.id = ?`,
		deviceID,
	).Scan(&userID, &role, &isOwner, &isBlocked, &isTrusted)

	if err == sql.ErrNoRows {
		return nil, ErrDeviceNotTrusted
	}
	if err != nil {
		return nil, err
	}
	if isBlocked {
		return nil, ErrDeviceBlocked
	}
	if !isTrusted {
		return nil, ErrDeviceNotTrusted
	}

	// Validate refresh token
	var sessionID string
	var sessionExpiry time.Time
	err = s.db.QueryRow(
		`SELECT id, expires_at FROM sessions WHERE device_id = ? AND refresh_token = ?`,
		deviceID, refreshToken,
	).Scan(&sessionID, &sessionExpiry)

	if err == sql.ErrNoRows || time.Now().After(sessionExpiry) {
		return nil, ErrTokenExpired
	}
	if err != nil {
		return nil, err
	}

	// Update device last_seen
	s.db.Exec(`UPDATE devices SET last_seen = ? WHERE id = ?`, time.Now(), deviceID) //nolint:errcheck

	return s.issueTokens(userID, deviceID, role, isOwner, nil)
}

// ValidateAccessToken validates a JWT access token and returns the claims.
func (s *Service) ValidateAccessToken(tokenStr string) (*Claims, error) {
	token, err := jwt.ParseWithClaims(tokenStr, &Claims{}, func(t *jwt.Token) (interface{}, error) {
		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", t.Header["alg"])
		}
		return s.jwtSecret, nil
	})
	if err != nil {
		if errors.Is(err, jwt.ErrTokenExpired) {
			return nil, ErrTokenExpired
		}
		return nil, ErrTokenInvalid
	}

	claims, ok := token.Claims.(*Claims)
	if !ok || !token.Valid {
		return nil, ErrTokenInvalid
	}

	return claims, nil
}

// RevokeDevice revokes all sessions for a device.
func (s *Service) RevokeDevice(deviceID string) error {
	tx, err := s.db.Begin()
	if err != nil {
		return err
	}
	defer tx.Rollback() //nolint:errcheck

	if _, err := tx.Exec(`DELETE FROM sessions WHERE device_id = ?`, deviceID); err != nil {
		return err
	}
	if _, err := tx.Exec(`UPDATE devices SET is_trusted = 0 WHERE id = ?`, deviceID); err != nil {
		return err
	}

	return tx.Commit()
}

// issueTokens creates and stores a new JWT pair.
func (s *Service) issueTokens(userID, deviceID, role string, isOwner bool, perms []string) (*TokenPair, error) {
	now := time.Now()
	accessExpiry := now.Add(s.accessTokenExpiry)

	claims := &Claims{
		RegisteredClaims: jwt.RegisteredClaims{
			Issuer:    "winpilot",
			Subject:   userID,
			IssuedAt:  jwt.NewNumericDate(now),
			ExpiresAt: jwt.NewNumericDate(accessExpiry),
		},
		UserID:      userID,
		DeviceID:    deviceID,
		Role:        role,
		IsOwner:     isOwner,
		Permissions: perms,
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	accessToken, err := token.SignedString(s.jwtSecret)
	if err != nil {
		return nil, fmt.Errorf("auth: sign access token: %w", err)
	}

	// Generate refresh token
	refreshToken, err := generateSecureToken(32)
	if err != nil {
		return nil, err
	}

	refreshExpiry := now.Add(s.refreshTokenExpiry)
	sessionID, err := generateSecureToken(16)
	if err != nil {
		return nil, err
	}

	// Invalidate old sessions for this device (one active session per device)
	s.db.Exec(`DELETE FROM sessions WHERE device_id = ?`, deviceID) //nolint:errcheck

	_, err = s.db.Exec(
		`INSERT INTO sessions (id, device_id, refresh_token, created_at, expires_at)
		 VALUES (?, ?, ?, ?, ?)`,
		sessionID, deviceID, refreshToken, now, refreshExpiry,
	)
	if err != nil {
		return nil, fmt.Errorf("auth: save session: %w", err)
	}

	return &TokenPair{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		ExpiresAt:    accessExpiry,
	}, nil
}

// createDefaultOwner creates the first owner user.
func (s *Service) createDefaultOwner() (string, error) {
	id, err := generateSecureToken(16)
	if err != nil {
		return "", err
	}

	// Default password "winpilot" — user should change this
	hash, err := bcrypt.GenerateFromPassword([]byte("winpilot"), bcrypt.DefaultCost)
	if err != nil {
		return "", err
	}

	now := time.Now()
	_, err = s.db.Exec(
		`INSERT INTO users (id, username, password, role, is_owner, created_at, updated_at)
		 VALUES (?, 'owner', ?, 'owner', 1, ?, ?)`,
		id, string(hash), now, now,
	)
	if err != nil {
		return "", fmt.Errorf("auth: create owner: %w", err)
	}

	return id, nil
}

// generateSecureToken creates a cryptographically random hex token.
func generateSecureToken(length int) (string, error) {
	b := make([]byte, length)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	return hex.EncodeToString(b), nil
}

// HashPassword returns a bcrypt hash of the password.
func HashPassword(password string) (string, error) {
	hash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	return string(hash), err
}

// CheckPassword checks a password against its bcrypt hash.
func CheckPassword(password, hash string) bool {
	return bcrypt.CompareHashAndPassword([]byte(hash), []byte(password)) == nil
}
