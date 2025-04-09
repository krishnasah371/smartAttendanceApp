package classes

// Class represents a single class created by a teacher or admin.
type Class struct {
	ID        int    `json:"id"`         // Unique class ID (auto-increment)
	Name      string `json:"name"`       // Name of the class (e.g., "Physics 101")
	TeacherID int    `json:"teacher_id"` // ID of the teacher who created the class
	Schedule  string `json:"schedule"`   // Class schedule in JSON format
	BLEID     string `json:"ble_id"`     // BLE ID registered for this class
	CreatedAt string `json:"created_at"` // Timestamp of when the class was created
}

// StudentInfo represents a student enrolled in a class.
type StudentInfo struct {
	ID         int    `json:"id"`
	Name       string `json:"name"`
	Email      string `json:"email"`
	EnrolledAt string `json:"enrolled_at"`
}
