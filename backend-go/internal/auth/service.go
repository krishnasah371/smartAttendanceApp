package auth

import (
	"database/sql"
	"errors"

	"github.com/krishnasah371/smartAttendanceApp/backend/pkg/security"
	"github.com/rs/zerolog/log"
)

// RegisterUserService handle user registration with Argon2 hashing
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
