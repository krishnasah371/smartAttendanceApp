package logger

import (
	"os"
	"time"

	"github.com/krishnasah371/smartAttendanceApp/backend/config"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
)

// InitLogger initializes zerolog for development or production mode
func InitLogger() {
	env := config.GetEnv("GIN_MODE")

	// Set log level & formatting based on environment
	if env == "release" {
		zerolog.TimeFieldFormat = zerolog.TimeFormatUnix
		log.Logger = zerolog.New(os.Stdout).With().Timestamp().Logger()
	} else {
		zerolog.TimeFieldFormat = time.RFC3339
		log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stdout, TimeFormat: time.RFC3339})
	}

	log.Info().Str("mode", env).Msg("✅ Logger initialized successfully")
}
