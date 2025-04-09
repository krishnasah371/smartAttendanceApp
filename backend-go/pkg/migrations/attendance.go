package migrations

import (
	"github.com/krishnasah371/smartAttendanceApp/backend/pkg/database"
	"github.com/rs/zerolog/log"
)

func MigrateAttendance() {
	query := `
	DO $$ BEGIN
		CREATE TYPE attendance_status AS ENUM ('present', 'absent', 'late');
	EXCEPTION
		WHEN duplicate_object THEN null;
	END $$;

	CREATE TABLE IF NOT EXISTS attendance (
		id 			SERIAL PRIMARY KEY,
		student_id 	INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
		class_id 	INTEGER NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
		timestamp 	TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
		status 		attendance_status NOT NULL,
		location 	JSONB,
		is_manual 	BOOLEAN DEFAULT false,
		created_at 	TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		updated_at 	TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	);
	`
	_, err := database.DB.Exec(query)
	if err != nil {
		log.Fatal().Err(err).Msg("❌ Failed to migrate attendance module")
	}

	log.Info().Msg("✅ Attendance module migration completed.")
}
