package auth

import (
	"database/sql"
	"errors"
	"strings"

	"github.com/krishnasah371/smartAttendanceApp/backend/pkg/security"
	"github.com/rs/zerolog/log"
)

// AuthenticateUserService verifies user credentials and returns a JWT token if authentication is successful.
//
// It retrieves the user from the database by email and verifies the password using Argon2 hashing.
// If authentication succeeds, a JWT token is generated and returned.
func AuthenticateUserService(email, password string) (string, *User, error) {
	user, err := GetUserByEmail(email)
	if err != nil {
		log.Warn().Str("email", email).Msg("⚠️ Authentication failed: User not found")
		return "", nil, errors.New("invalid credentials")
	}

	matched, err := security.VerifyPassword(password, user.PasswordHash)
	if err != nil || !matched {
		log.Warn().Str("email", email).Msg("⚠️ Authentication failed: Invalid password")
		return "", nil, errors.New("invalid credentials")
	}

	log.Info().Str("email", email).Msg("✅ Authentication successful")

	token, err := security.GenerateJWT(user.ID, user.Email, user.Role)
	if err != nil {
		return "", nil, err
	}

	return token, user, nil
}

// RegisterUserService handles user registration by validating input, hashing the password, and storing the user.
//
// It checks if the user already exists, ensures the role is valid, and securely hashes the password before saving.
// If successful, the user is added to the database.
func RegistgerUserService(name, email, password string) (*User, error) {
	role := ""
	if strings.HasSuffix(email, "my.fisk.edu") {
		role = "student"
	} else if strings.HasSuffix(email, "fisk.edu") {
		role = "teacher"
	} else {
		role = "student"
	}

	// Check if user already exists
	existingUser, err := GetUserByEmail(email)
	if err != nil && err != sql.ErrNoRows {
		log.Error().Err(err).Str("email", email).Msg("❌ Failed to check existing user")
		return nil, errors.New("database error")
	}
	if existingUser != nil {
		return nil, errors.New("user already exists")
	}

	// Hash password
	passwordHash, err := security.HashPassword(password)
	if err != nil {
		log.Error().Err(err).Msg("❌ Error hashing password")
		return nil, err
	}

	// Store user
	err = RegisterUser(name, email, passwordHash, role)
	if err != nil {
		return nil, err
	}

	// Fetch newly inserted user
	user, err := GetUserByEmail(email)
	if err != nil {
		return nil, errors.New("failed to fetch newly created user")
	}

	return user, nil
}
