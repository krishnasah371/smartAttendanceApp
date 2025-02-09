package security

import (
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/krishnasah371/smartAttendanceApp/backend/config"
)

// GenerateJWT creates a JWT token for authenticated users
func GenerateJWT(userId int, email, role string) (string, error) {
	claims := jwt.MapClaims{
		"user_id": userId,
		"email":   email,
		"role":    role,
		"exp":     time.Now().Add(time.Hour * 72).Unix(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(config.GetEnv("JWT_SECRET")))
}
