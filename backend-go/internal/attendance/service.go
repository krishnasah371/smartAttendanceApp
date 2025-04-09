package attendance

import (
	"errors"

	"github.com/krishnasah371/smartAttendanceApp/backend/internal/classes"
)

// MarkAttendanceForStudent handles attendance logic for students.
// It checks if the student is enrolled, verifies BLE ID, and saves the attendance record.
func MarkAttendanceForStudent(studentID, classID int, status string, location any, receivedBLEID string) error {
	// Check enrollment
	enrolled, err := classes.IsAlreadyEnrolled(studentID, classID)
	if err != nil {
		return err
	}
	if !enrolled {
		return errors.New("you are not enrolled in this class")
	}

	// Fetch expected BLE ID from the class
	expectedBLEID, err := classes.GetClassBLEID(classID)
	if err != nil {
		return err
	}
	if expectedBLEID != receivedBLEID {
		return errors.New("invalid BLE device — you are not near the class")
	}

	// Prevent duplicate attendance for the same class/day
	alreadyMarked, err := HasMarkedAttendanceToday(studentID, classID)
	if err != nil {
		return err
	}
	if alreadyMarked {
		return errors.New("attendance already marked for today")
	}

	// Record attendance
	return InsertAttendance(studentID, classID, status, location, false)
}

// UpdateAttendanceForTeacher validates access and updates the record.
func UpdateAttendanceForTeacher(teacherID, classID, attendanceID int, req UpdateAttendanceRequest) error {
	// Ensure the teacher owns the class
	owns, err := classes.DoesTeacherOwnClass(teacherID, classID)
	if err != nil {
		return err
	}
	if !owns {
		return errors.New("unauthorized: you do not own this class")
	}

	// Update the record
	return UpdateAttendanceRecord(attendanceID, req.Status, req.Location, req.IsManual)
}
