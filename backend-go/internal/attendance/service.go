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

// FetchClassAttendance validates the user's role and class ownership before returning records.
func FetchClassAttendance(userID, classID int, role string) ([]AttendanceRecord, error) {
	// Admins can view all
	if role == "admin" {
		return GetAttendanceRecords(classID)
	}

	// Teachers can only view their own classes
	if role == "teacher" {
		owns, err := classes.DoesTeacherOwnClass(userID, classID)
		if err != nil {
			return nil, err
		}
		if !owns {
			return nil, errors.New("unauthorized: you do not own this class")
		}
		return GetAttendanceRecords(classID)
	}

	return nil, errors.New("unauthorized")
}

// GetFullClassAttendance checks access and returns all attendance records for a class.
func GetFullClassAttendance(userRole string, classID int) ([]AttendanceRecord, error) {
	if userRole != "teacher" && userRole != "admin" {
		return nil, errors.New("unauthorized")
	}

	return GetAllAttendanceForClass(classID)
}

// FetchAttendanceForDate validates access before returning date-specific attendance.
//
// Teachers must own the class. Admins have access to all classes.
func FetchAttendanceForDate(userID, classID int, role, date string) ([]AttendanceRecord, error) {
	if role == "admin" {
		return GetAttendanceRecordsByDate(classID, date)
	}

	if role == "teacher" {
		owns, err := classes.DoesTeacherOwnClass(userID, classID)
		if err != nil {
			return nil, err
		}
		if !owns {
			return nil, errors.New("unauthorized: you do not own this class")
		}
		return GetAttendanceRecordsByDate(classID, date)
	}

	return nil, errors.New("unauthorized")
}

// FetchPreviousAttendance checks if the user is authorized to view full attendance.
//
// Admins can view any class. Teachers must own the class.
func FetchPreviousAttendance(userID, classID int, role string) ([]AttendanceRecord, error) {
	if role == "admin" {
		return GetAllAttendanceForClass(classID)
	}

	if role == "teacher" {
		owns, err := classes.DoesTeacherOwnClass(userID, classID)
		if err != nil {
			return nil, err
		}
		if !owns {
			return nil, errors.New("unauthorized: you do not own this class")
		}
		return GetAllAttendanceForClass(classID)
	}

	return nil, errors.New("unauthorized")
}
