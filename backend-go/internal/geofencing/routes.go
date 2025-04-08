package geogencing

import (
	"github.com/gin-gonic/gin"
	"github.com/rs/zerolog/log"
)

// RegisterRoutes registers geofencing-related API endpoints.
func RegisterRoutes(router *gin.RouterGroup) {
	geofenceGroup := router.Group("/geofence")
	{
		// Check GPS + BLE validation
		geofenceGroup.POST("/check/:classID", CheckGeofenceHandler)
	}

	log.Info().Msg("✅ Geofencing module initialized!")
}
