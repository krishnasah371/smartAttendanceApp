package database

import "github.com/rs/zerolog/log"

// MigrateDB creates necessary tables in PostgreSQL database
func MigrateDB() {
	query := `
	DO $$ BEGIN
		CREATE TYPE user_role AS ENUM ('student', 'teacher', 'admin');
	EXCEPTION
		WHEN duplicate_object THEN null;
	END $$;

	CREATE TABLE IF NOT EXISTS users (
		id 				SERIAL PRIMARY KEY,
		name 			VARCHAR(100) NOT NULL,
		email 			VARCHAR(100) UNIQUE NOT NULL,
		password_hash 	TEXT NOT NULL,
		role 			user_role NOT NULL DEFAULT 'student',
		created_at 		TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	);
	`

	_, err := DB.Exec(query)
	if err != nil {
		log.Fatal().Err(err).Msg(("❌ Failed to migrate database"))
	}

	log.Info().Msg("✅ Database migration completed successfully.")
}
