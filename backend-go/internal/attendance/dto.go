package attendance

// MarkAttendanceRequest defines the request body for marking attendance.
type MarkAttendanceRequest struct {
	Status   string `json:"status" binding:"required,oneof=present absent late"` // Required status
	Location any    `json:"location,omitempty"`                                  // Optional JSON object (e.g., lat/lng)
	BLEID    string `json:"ble_id" binding:"required"`                           // BLE ID from student device
}

// UpdateAttendanceRequest defines the body for updating an attendance record.
type UpdateAttendanceRequest struct {
	Status   string `json:"status" binding:"required,oneof=present absent late"`
	Location any    `json:"location,omitempty"` // optional updated location
	IsManual bool   `json:"is_manual"`          // must be true if manually edited
}

// StartBroadcastRequest is sent by the teacher to begin BLE attendance session
type StartBroadcastRequest struct {
	BluetoothID string `json:"bluetooth_id" binding:"required"`
	Date        string `json:"date" binding:"required"` // Format: YYYY-MM-DD
}
