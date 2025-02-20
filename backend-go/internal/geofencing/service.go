package geogencing

import (
	"errors"

	"github.com/rs/zerolog/log"
)

// IsWithinGeofence checks if a user's location is inside the defined geofence.
func IsWithinGeofence(classID int, userLat, userLon float64) (bool, error) {
	geofence, err := GetGeofenceByClassID(classID)
	if err != nil || geofence == nil {
		return false, errors.New("no geofence found for this class")
	}

	area := geofence.AllowedArea

	// Check if the point is inside the geofence
	switch area.Type {
	case "circle":
		distance := HaversineDistance(userLat, userLon, area.Center[0], area.Center[1])
		return distance <= area.Radius, nil

	case "polygon":
		return IsPointInPolygon(userLat, userLon, area.Coords), nil

	default:
		log.Warn().Str("type", area.Type).Msg("⚠️ Unsupported geofence type")
		return false, errors.New("unsupported geofence type")
	}
}

// ValidateBLEPresence checks if detected BLE UUIDs match classroom beacons.
func ValidateBLEPresence(classID int, detectedUUIDs []string) bool {
	registeredBeacons, err := GetBLEDeviceByClassId(classID)
	if err != nil {
		log.Error().Err(err).Msg("❌ Failed to fetch BLE beacons")
		return false
	}

	for _, beacon := range registeredBeacons {
		for _, detectedUUID := range detectedUUIDs {
			if beacon.UUID == detectedUUID {
				log.Info().Str("beacon_uuid", detectedUUID).Msg("✅ BLE validation passed")
				return true
			}
		}
	}

	log.Warn().Msg("⚠️ No valid BLE beacons detected")
	return false
}

// ProcessGeofencingValidation handles the full geofence + BLE validation process.
func ProcessGeofencingValidation(classID int, userLat, userLon float64, detectedUUIDs []string) (bool, error) {
	// Validate GPS location
	isInGeofence, err := IsWithinGeofence(classID, userLat, userLon)
	if err != nil {
		return false, err
	}

	// Validate BLE presence
	isBLEValid := ValidateBLEPresence(classID, detectedUUIDs)

	// Only pass if both GPS and BLE are validated
	return isInGeofence && isBLEValid, nil
}
