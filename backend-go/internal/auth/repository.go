package auth

import (
	"database/sql"

	"github.com/krishnasah371/smartAttendanceApp/backend/pkg/database"
	"github.com/rs/zerolog/log"
)

// RegisterUser inserts a new user into the database with hashed password.
//
// It takes user details (name, email, passwordHash, role) and stores them in the database.
// Logs success or failure messages accordingly.
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

// GetUserByEmail retrieves a user from the database using their email.
//
// It queries the database for a user with the given email and returns the user object.
// If no user is found, it returns `sql.ErrNoRows`.
// Logs a message if the user is not found or if there is a database error.
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
