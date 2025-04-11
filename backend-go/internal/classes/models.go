package classes

// Class represents a single class created by a teacher or admin.
type Class struct {
	ID        int    `json:"id"`
	Name      string `json:"name"`
	TeacherID int    `json:"teacher_id"`
	Schedule  string `json:"schedule"`
	BLEID     string `json:"ble_id"`
	TimeZone  string `json:"timezone"`
	StartDate string `json:"start_date"`
	EndDate   string `json:"end_date"`
	CreatedAt string `json:"created_at"`
}

// StudentInfo represents a student enrolled in a class.
type StudentInfo struct {
	ID         int    `json:"id"`
	Name       string `json:"name"`
	Email      string `json:"email"`
	EnrolledAt string `json:"enrolled_at"`
}
