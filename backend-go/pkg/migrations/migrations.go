package migrations

import (
	"github.com/krishnasah371/smartAttendanceApp/backend/pkg/database"
	"github.com/rs/zerolog/log"
)

// MigrateDB creates necessary tables in PostgreSQL database
func MigrateDB() {
	log.Info().Msg("🚀 Starting database migration...")

	if database.DB == nil {
		log.Fatal().Msg("❌ Database connection is not initialized")
		return
	}

	// Run all the database migrations
	MigrateAuth()
	MigrateGeofencing()

	log.Info().Msg("✅ Database migrations completed successfully.")
}
