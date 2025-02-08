package auth

import (
	"database/sql"

	"github.com/krishnasah371/smartAttendanceApp/backend/pkg/database"
	"github.com/rs/zerolog/log"
)

// RegisterUserService handles user registration with Argon2 hashing
func RegisterUser(name, email, passwordHash, role string) error {
	query := `INSERT INTO users (name, email, password_hash, role) VALUES ($1, $2, $3, $4)`
	_, err := database.DB.Exec(query, name, email, passwordHash, role)
	if err != nil {
		log.Error().Err(err).Msg("❌ Failed to insert into database")
		return err
	}

	log.Info().Str("email", email).Msg("✅ User registered successfully in DB")
	return nil
}

// GetUserByEmail retrives a user from the database by email
func GetUserByEmail(email string) (*User, error) {
	var user User
	query := `SELECT id, name, email, password_hash, role, created_at FROM users WHERE email = $1`
	err := database.DB.QueryRow(query, email).Scan(&user.ID, &user.Name, &user.Email, &user.PasswordHash, &user.Role, &user.CreatedAt)
	if err != nil {
		if err == sql.ErrNoRows {
			log.Info().Str("email", email).Msg("⚠️ User not found (new user can be registered)")
			return nil, err
		}
		log.Error().Err(err).Str("email", email).Msg("❌ Failed to fetch user from database")
		return nil, err
	}

	return &user, nil
}
