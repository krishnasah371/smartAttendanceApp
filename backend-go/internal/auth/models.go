package auth

import "time"

// User represents the database structure for users
type User struct {
	ID           int       `json:"id"`
	Name         string    `json:"name"`
	Email        string    `json:"email"`
	PasswordHash string    `json:"_"`
	Role         string    `json:"role"`
	CreatedAt    time.Time `json:"created_at"`
}
