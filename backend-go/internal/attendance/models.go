package attendance

// AttendanceRecord represents a saved attendance entry.
type AttendanceRecord struct {
	ID          int    `json:"id"`
	StudentID   int    `json:"student_id,omitempty"`
	StudentName string `json:"student_name,omitempty"`
	ClassID     int    `json:"class_id"`
	ClassName   string `json:"class_name,omitempty"`
	Status      string `json:"status"`
	Timestamp   string `json:"timestamp"`
	IsManual    bool   `json:"is_manual"`
	Location    any    `json:"location,omitempty"`
	CreatedAt   string `json:"created_at,omitempty"`
	UpdatedAt   string `json:"updated_at,omitempty"`
}
