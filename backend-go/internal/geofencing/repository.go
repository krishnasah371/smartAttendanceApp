package geogencing

import (
	"database/sql"

	"github.com/krishnasah371/smartAttendanceApp/backend/pkg/database"
	"github.com/rs/zerolog/log"
)

// GetGeofenceByClassID retrieves the geofence setting for a class.
func GetGeofenceByClassID(classID int) (*Geofence, error) {
	var geo Geofence

	query := `SELECT id, class_id, allowed_area, ble_device_id, created_at FROM geofence WHERE class_id = $1`
	err := database.DB.QueryRow(query, classID).Scan(&geo.ID, &geo.ClassID, &geo.AllowedArea, &geo.BLEDeviceID, &geo.CreatedAt)
	if err != nil {
		if err == sql.ErrNoRows {
			log.Warn().Int("class_id", classID).Msg("⚠️ No geofence found for the class.")
			return nil, nil
		}
		log.Error().Err(err).Msg("❌ Failed to determine the geofence for the class.")
		return nil, err
	}

	return &geo, nil
}

// GetBLEDeviceByClassId retrieves registered BLE beacons for a class.
func GetBLEDeviceByClassId(classID int) ([]BLEDevice, error) {
	query := `SELECT id, class_id, uuid, created_at FROM ble_devices WHERE class_id = $1`
	rows, err := database.DB.Query(query, classID)
	if err != nil {
		log.Error().Err(err).Msg("❌ Failed to fetch BLE devices info.")
		return nil, nil
	}
	defer rows.Close()

	var devices []BLEDevice
	for rows.Next() {
		var device BLEDevice
		if err := rows.Scan(&device.ID, &device.ClassID, &device.UUID, &device.CreatedAt); err != nil {
			log.Error().Err(err).Msg("❌ Error Scanning BLE Device")
			continue
		}
		devices = append(devices, device)
	}

	return devices, nil
}
