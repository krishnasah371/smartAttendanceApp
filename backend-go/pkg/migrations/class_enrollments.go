package migrations

import (
	"github.com/krishnasah371/smartAttendanceApp/backend/pkg/database"
	"github.com/rs/zerolog/log"
)

func MigrateClassEnrollments() {
	query := `
	CREATE TABLE IF NOT EXISTS class_enrollments (
		id SERIAL PRIMARY KEY,
		class_id INTEGER NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
		student_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
		enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		UNIQUE (class_id, student_id)
	);
	`

	_, err := database.DB.Exec(query)
	if err != nil {
		log.Fatal().Err(err).Msg("❌ Failed to migrate class enrollments")
	}

	log.Info().Msg("✅ Class enrollments migration completed.")
}
