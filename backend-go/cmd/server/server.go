package server

import (
	"github.com/gin-gonic/gin"
	"github.com/krishnasah371/smartAttendanceApp/backend/config"
	"github.com/krishnasah371/smartAttendanceApp/backend/internal/auth"
	geogencing "github.com/krishnasah371/smartAttendanceApp/backend/internal/geofencing"
	"github.com/krishnasah371/smartAttendanceApp/backend/pkg/logger"

	"github.com/rs/zerolog/log"
)

func Start(ginMode string) {
	if ginMode == "" {
		// Default to release mode if no argument is provided for safety reasons
		ginMode = "release"
	}

	gin.SetMode(ginMode)
	SERVER_PORT := config.GetEnv("SERVER_PORT", "8080")

	router := gin.New()

	// Used to catch panics, prevents server from crashing.
	// Automatically recovers from panics
	router.Use(gin.Recovery())

	// Logger middleware to log apis and panics
	router.Use(logger.RequestLogger())
	router.Use(logger.RecoveryLogger())

	// Set truseted proxies to empty for safety reasons.
	router.SetTrustedProxies(nil)

	// Register module routes
	api := router.Group("/api")
	auth.RegisterRoutes(api)
	geogencing.RegisterRoutes(api)

	log.Info().Str("port", SERVER_PORT).Msg("📢 Server has started")
	err := router.Run("localhost:" + SERVER_PORT)
	if err != nil {
		log.Fatal().Err(err).Msg("❌ Failed to start server")
	}
}
