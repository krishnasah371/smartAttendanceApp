package geogencing

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/rs/zerolog/log"
)

func CheckGeofenceHandler(c *gin.Context) {
	classID, err := strconv.Atoi(c.Param("classID"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid class ID"})
		return
	}

	var req CheckGeofenceRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Perform geofencing + BLE validation
	isValid, err := ProcessGeofencingValidation(classID, req.Latitude, req.Longitude, req.BLEUUIDs)
	if err != nil {
		log.Warn().Err(err).Msg("⚠️ Geofencing validation failed")
		c.JSON(http.StatusForbidden, CheckGeofenceResponse{
			Success:   false,
			Message:   err.Error(),
			Validated: false,
		})

		return
	}

	if isValid {
		c.JSON(http.StatusOK, CheckGeofenceResponse{
			Success:   true,
			Message:   "User is within geofence",
			ClassID:   classID,
			Validated: true,
		})
	} else {
		c.JSON(http.StatusUnauthorized, CheckGeofenceResponse{
			Success:   false,
			Message:   "Geofence or BLE validation failed",
			Validated: false,
		})
	}
}
