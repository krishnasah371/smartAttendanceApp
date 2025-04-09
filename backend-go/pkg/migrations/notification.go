package migrations

import (
	"github.com/krishnasah371/smartAttendanceApp/backend/pkg/database"
	"github.com/rs/zerolog/log"
)

func MigrateNotifications() {
	query := `
	DO $$ BEGIN
		CREATE TYPE notification_status AS ENUM ('pending', 'sent', 'failed');
	EXCEPTION
		WHEN duplicate_object THEN null;
	END $$;

	CREATE TABLE IF NOT EXISTS notifications (
		id 			SERIAL PRIMARY KEY,
		user_id 	INTEGER NOT NULL REFERENCES users(id),
		message 	TEXT NOT NULL,
		status 		notification_status NOT NULL,
		created_at 	TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	);
	`

	_, err := database.DB.Exec(query)
	if err != nil {
		log.Fatal().Err(err).Msg("❌ Failed to migrate notifications module")
	}

	log.Info().Msg("✅ Notifications module migration completed.")
}
