package classes

// CreateClassRequest defines the expected input when creating a new class.
//
// It is used in POST /classes and includes the class name (required)
// and optional schedule as a JSON string.
type CreateClassRequest struct {
	Name     string `json:"name" binding:"required"` // Name of the class
	Schedule string `json:"schedule"`                // Optional schedule (JSON string)
	BLEID    string `json:"ble_id" binding:"required"`
}

// ClassResponse defines what we return to the client when listing classes.
type ClassResponse struct {
	ID          int    `json:"id"`
	Name        string `json:"name"`
	Schedule    string `json:"schedule"`
	TeacherID   int    `json:"teacher_id"`
	TeacherName string `json:"teacher_name,omitempty"`
	BLEID       string `json:"ble_id,omitempty"`
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
	CreatedAt   string `json:"created_at"`
}
