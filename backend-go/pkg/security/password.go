package security

import (
	"crypto/rand"
	"encoding/base64"
	"errors"
	"fmt"
	"strings"

	"github.com/rs/zerolog/log"
	"golang.org/x/crypto/argon2"
)

const (
	ArgonTime    = 1         // Number iterations
	ArgonMemory  = 64 * 1024 // 64MB of memory uses
	ArgonThreads = 4         // Number of parallel threads
	ArgonKeyLen  = 32        // Length of derived key
	ArgonSaltLen = 16        // Salt length
)

// GenerateSalt creates a random salt for
func GenerateSalt() (string, error) {
	salt := make([]byte, ArgonSaltLen)
	_, err := rand.Read(salt)
	if err != nil {
		return "", err
	}

	return base64.RawStdEncoding.EncodeToString(salt), nil
}

// HashPassword securely hashes a password using Argon2
func HashPassword(password string) (string, error) {
	salt, err := GenerateSalt()
	if err != nil {
		return "", err
	}

	saltBytes, _ := base64.RawStdEncoding.DecodeString(salt)
	hashedPassword := argon2.IDKey([]byte(password), saltBytes, ArgonTime, ArgonMemory, ArgonThreads, ArgonKeyLen)

	return fmt.Sprintf("%s$%s", salt, base64.RawStdEncoding.EncodeToString(hashedPassword)), nil
}

// VerifyPassword checks if a password matches the hashed version
func VerifyPassword(password, storedHashed string) (bool, error) {
	parts := strings.Split(storedHashed, "$")
	if len(parts) != 2 {
		log.Warn().Msg("⚠️ Invalid hash format detected")
		return false, errors.New("invalid hash format")
	}

	salt, hash := parts[0], parts[1]
	saltBytes, _ := base64.RawStdEncoding.DecodeString(salt)
	expectedHash := argon2.IDKey([]byte(password), saltBytes, ArgonTime, ArgonMemory, ArgonThreads, ArgonKeyLen)

	if base64.RawStdEncoding.EncodeToString(expectedHash) == hash {
		log.Info().Msg("✅ Password verified successfully")
		return true, nil
	}

	log.Warn().Msg("❌ Password verification failed")
	return false, errors.New("password does not match")
}
