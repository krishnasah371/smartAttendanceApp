package geogencing

// CheckGeofenceRequest represents the request payload for geofence validation.
type CheckGeofenceRequest struct {
	Latitude  float64  `json:"latitude" binding:"required"`
	Longitude float64  `json:"longitude" binding:"required"`
	BLEUUIDs  []string `json:"ble_uuids"`
}

// CheckGeofenceResponse represents the response payload for geofence validation.
type CheckGeofenceResponse struct {
	Success   bool   `json:"success"`
	Message   string `json:"message"`
	ClassID   int    `json:"class_id,omitempty"`
	Validated bool   `json:"validated"`
}
