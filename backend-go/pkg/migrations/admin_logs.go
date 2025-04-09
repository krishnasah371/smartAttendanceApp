package migrations

import (
	"github.com/krishnasah371/smartAttendanceApp/backend/pkg/database"
	"github.com/rs/zerolog/log"
)

func MigrateAdminLogs() {
	query := `
	CREATE TABLE IF NOT EXISTS admin_logs (
		id 				SERIAL PRIMARY KEY,
		admin_id 		INTEGER NOT NULL REFERENCES users(id),
		action 			TEXT NOT NULL,
		target_user_id 	INTEGER NOT NULL REFERENCES users(id),
		class_id 		INTEGER NOT NULL REFERENCES classes(id),
		timestamp 		TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	);
	`

	_, err := database.DB.Exec(query)
	if err != nil {
		log.Fatal().Err(err).Msg("❌ Failed to migrate admin logs module")
	}

	log.Info().Msg("✅ Admin logs module migration completed.")
}
