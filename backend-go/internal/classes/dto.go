package classes

// CreateClassRequest defines the expected input when creating a new class.
//
// It is used in POST /classes and includes the class name (required)
// and optional schedule as a JSON string.
type CreateClassRequest struct {
	Name      string `json:"name" binding:"required"`
	Schedule  string `json:"schedule"` // JSON string
	BLEID     string `json:"ble_id"`
	TimeZone  string `json:"timezone" binding:"required"`
	StartDate string `json:"start_date" binding:"required"` // Format: "2006-01-02"
	EndDate   string `json:"end_date" binding:"required"`   // Format: "2006-01-02"
}

// ClassResponse defines what we return to the client when listing classes.
type ClassResponse struct {
	ID           int    `json:"id"`
	Name         string `json:"name"`
	Schedule     string `json:"schedule"`
	TeacherID    int    `json:"teacher_id"`
	TeacherName  string `json:"teacher_name,omitempty"`
	TeacherEmail string `json:"teacher_email,omitempty"`
	BLEID        string `json:"ble_id,omitempty"`
	TimeZone     string `json:"timezone"`
	StartDate    string `json:"start_date"`
	EndDate      string `json:"end_date"`
}

// EnrollClassResponse represents the confirmation after enrollment.
type EnrollClassResponse struct {
	Message string `json:"message"`
}

// ClassDetailResponse represents the full info of a single class.
type ClassDetailResponse struct {
	ID          int    `json:"id"`
	Name        string `json:"name"`
	Schedule    string `json:"schedule"`
	TeacherID   int    `json:"teacher_id"`
	TeacherName string `json:"teacher_name"`
	BLEID       string `json:"ble_id"`
	TimeZone    string `json:"timezone"`
	StartDate   string `json:"start_date"`
	EndDate     string `json:"end_date"`
	CreatedAt   string `json:"created_at"`
}

// UpdateBLEIDRequest defines the input when updating a class's BLE ID.
//
// Used in PUT /classes/:id/ble
type UpdateBLEIDRequest struct {
	BLEID string `json:"ble_id" binding:"required"` // New BLE device ID
}
