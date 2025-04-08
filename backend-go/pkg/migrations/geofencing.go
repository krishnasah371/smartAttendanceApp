package migrations

import (
	"github.com/krishnasah371/smartAttendanceApp/backend/pkg/database"
	"github.com/rs/zerolog/log"
)

func MigrateGeofencing() {
	query := `
	CREATE TABLE IF NOT EXISTS geofence (
		id				SERIAL PRIMARY KEY,
		class_id		INT UNIQUE NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
		allowed_area	JSONB NOT NULL,
		ble_device_id	INT REFERENCES ble_devices(id) ON DELETE SET NULL,
		created_at		TIMESTAMP DEFAULT NOW()
	);

	CREATE TABLE IF NOT EXISTS ble_devices (
		id				SERIAL PRIMARY KEY,
		class_id		INT NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
		uuid			TEXT NOT NULL UNIQUE,
		created_at		TIMESTAMP DEFAULT NOW()
	);
	
	CREATE INDEX IF NOT EXISTS idx_geofencing_class ON geofencing(class_id);
	CREATE INDEX IF NOT EXISTS idx_ble_devices_class ON ble_devices(class_id);
	`

	_, err := database.DB.Exec(query)
	if err != nil {
		log.Fatal().Err(err).Msg("❌ Failed to migrate geofencing module")
	}

	log.Info().Msg("✅ Geofencing module migration completed.")
}
