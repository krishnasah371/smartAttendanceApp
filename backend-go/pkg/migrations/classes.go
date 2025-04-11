package migrations

import (
	"github.com/krishnasah371/smartAttendanceApp/backend/pkg/database"
	"github.com/rs/zerolog/log"
)

func MigrateClasses() {
	query := `
	CREATE TABLE IF NOT EXISTS classes (
		id 			SERIAL PRIMARY KEY,
		name 		VARCHAR(100) NOT NULL,
		teacher_id 	INTEGER NOT NULL REFERENCES users(id),
		schedule 	JSONB,
		ble_id 		TEXT,
		timezone 	TEXT NOT NULL,
		start_date 	DATE NOT NULL,
		end_date 	DATE NOT NULL,
		created_at 	TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	);
	`

	_, err := database.DB.Exec(query)
	if err != nil {
		log.Fatal().Err(err).Msg("❌ Failed to migrate classes module")
	}

	log.Info().Msg("✅ Classes module migration completed.")
}
