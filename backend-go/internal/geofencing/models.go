package geogencing

import "time"

// Geofence represents a classroom geofence boundary.
type Geofence struct {
	ID          int         `json:"id"`
	ClassID     int         `json:"class_id"`
	AllowedArea AllowedArea `json:"allowed_area"` // Shoud be a JSON (circle/polygon)
	BLEDeviceID string      `json:"ble_device_id"`
	CreatedAt   time.Time   `json:"created_at"`
}

// BLEDevice represents a Bluetooth beacon inside a classroom.
type BLEDevice struct {
	ID        string    `json:"id"`
	ClassID   int       `json:"class_id"`
	UUID      string    `json:"uuid"` // Unique BLE identifier
	CreatedAt time.Time `json:"created_at"`
}
