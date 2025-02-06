package config

import (
	"log"
	"os"

	"github.com/joho/godotenv"
)

// LoadEnv loads environment variables from .env file
func LoadEnv() {
	err := godotenv.Load("config/app.env")
	if err != nil {
		log.Println("Warning: No .env file found, using system environment variables.")
	} else {
		log.Println("✅ Environmental variables loaded successfully.")
	}
}

// GetEnv retrieves the value of the environment variable specified by `key`
// If the env variable is set, the function returns its value.
// If teh variable is not set, it returns the provided `fallback` value instead
func GetEnv(key string, fallback ...string) string {
	value, exists := os.LookupEnv(key)
	if exists {
		return value
	}
	if len(fallback) > 0 {
		log.Printf("⚠️  Environment variable %s not found, using fallback: %s\n", key, fallback)
		return fallback[0]
	}

	log.Printf("⚠️  Environment variable %s not found!", key)
	return ""
}
