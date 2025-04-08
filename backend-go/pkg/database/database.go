package database

import (
	"database/sql"
	"fmt"

	"github.com/krishnasah371/smartAttendanceApp/backend/config"
	_ "github.com/lib/pq"
	"github.com/rs/zerolog/log"
)

var DB *sql.DB

func InitDB() {
	dbURL := fmt.Sprintf(
		"postgres://%s:%s@%s:%s/%s?sslmode=disable",
		config.GetEnv("DB_USER"),
		config.GetEnv("DB_PASSWORD"),
		config.GetEnv("DB_HOST"),
		config.GetEnv("DB_PORT"),
		config.GetEnv("DB_NAME"),
	)

	var err error
	DB, err = sql.Open("postgres", dbURL)
	if err != nil {
		log.Fatal().Err(err).Msg("❌ Failed to connect to the database")

	}

	// Verify the database connection
	if err = DB.Ping(); err != nil {
		log.Fatal().Err(err).Msg("❌ Database is unreachable.")
	}

	log.Info().Msg("✅ connected to PostgreSQL database successfully.")
}
