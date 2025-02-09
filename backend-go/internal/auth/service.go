package auth

import (
	"database/sql"
	"errors"

	"github.com/krishnasah371/smartAttendanceApp/backend/pkg/security"
	"github.com/rs/zerolog/log"
)

// AuthenticateUserService verifies user credentials and returns a JWT token if authentication is successful.
//
// It retrieves the user from the database by email and verifies the password using Argon2 hashing.
// If authentication succeeds, a JWT token is generated and returned.
func AuthenticateUserService(email, password string) (string, error) {
	// Fetch user from the database
	user, err := GetUserByEmail(email)
	if err != nil {
		log.Warn().Str("email", email).Msg("⚠️ Authentication failed: User not found")
		return "", errors.New("invalid credentials")
	}

	// Validate user by verifying password using Argon2
	matched, err := security.VerifyPassword(password, user.PasswordHash)
	if err != nil || !matched {
		log.Warn().Str("email", email).Msg("⚠️ Authentication failed: Invalid password")
		return "", errors.New("invalid credentials")
	}

	log.Info().Str("email", email).Msg("✅ Authentication successful")

	// Generate JWT token and returns it
	return security.GenerateJWT(user.ID, user.Email, user.Role)
}

// RegisterUserService handles user registration by validating input, hashing the password, and storing the user.
//
// It checks if the user already exists, ensures the role is valid, and securely hashes the password before saving.
// If successful, the user is added to the database.
func RegistgerUserService(name, email, password, role string) error {
	// Validate role
	validRoles := map[string]bool{"student": true, "teacher": true, "admin": true}
	if _, exists := validRoles[role]; !exists {
		log.Warn().Str("role", role).Msg("⚠️ Invalid user role")
		return errors.New("invalid user role")
	}
	// Check if user already exists
	existingUser, err := GetUserByEmail(email)
	if err != nil {
		if err == sql.ErrNoRows {
			log.Info().Str("email", email).Msg("✅ Proceeding with registration")
		} else {
			log.Error().Err(err).Str("email", email).Msg("❌ Failed to fetch user from database")
			return errors.New("database error")
		}
	}

	if existingUser != nil {
		return errors.New("user already exists")
	}

	// Hash the password before storing it in the database
	passwordHash, err := security.HashPassword(password)
	if err != nil {
		log.Error().Err(err).Msg("❌ Error hashing password")
		return err
	}

	// Store user in database
	return RegisterUser(name, email, passwordHash, role)
}
