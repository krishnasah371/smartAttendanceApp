package main

import (
	"github.com/rs/zerolog/log"

	"github.com/krishnasah371/smartAttendanceApp/backend/cmd/server"
	"github.com/krishnasah371/smartAttendanceApp/backend/config"
	"github.com/krishnasah371/smartAttendanceApp/backend/pkg/database"
	"github.com/krishnasah371/smartAttendanceApp/backend/pkg/logger"

	utils "github.com/krishnasah371/smartAttendanceApp/backend/pkg/utils"
)

func main() {
	log.Info().Msg("🚀 Running Smart Attendance Backend...")

	// Load all the environment variables from .env and initialize logger
	config.LoadEnv()
	logger.InitLogger()

	// Ensure GIN_MODE is explicitly set (default to "release" for safety)
	ginMode := config.GetEnv("GIN_MODE", "release")
	command := utils.ParseCommand()

	// Initialize the database
	database.InitDB()

	// Run database migration
	database.MigrateDB()

	switch command {
	case "server":
		log.Info().Msg("📢 Starting Smart Attendance Server...")
		server.Start(ginMode)
	case "":
		log.Warn().Msg("⚠️  No command provided. Defaulting to server...")
		server.Start(ginMode)
	default:
		log.Error().Str("command", command).Msg("❌ Unknown command")
	}
}
