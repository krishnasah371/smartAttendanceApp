package classes

import (
	"errors"

	"github.com/rs/zerolog/log"
)

// GetAllPublicClasses returns a list of all available classes for public access.
//
// This wraps the repository call in case future filtering or formatting is added.
func GetAllPublicClasses() ([]ClassResponse, error) {
	return FetchAllPublicClasses()
}

// GetClassesForUser returns class data for the current user depending on their role.
//
// - Teachers see classes they created.
// - Students see classes they're enrolled in.
// - Other roles return an error.
func GetClassesForUser(userID int, role string) ([]ClassResponse, error) {
	log.Info().
		Int("user_id", userID).
		Str("role", role).
		Msg("🧠 Determining class fetch strategy based on user role")

	switch role {
	case "teacher":
		return GetClassesByTeacherID(userID)

	case "student":
		return GetClassesByStudentID(userID)

	default:
		log.Warn().
			Int("user_id", userID).
			Str("role", role).
			Msg("⛔ Unsupported role for class access")
		return nil, errors.New("unauthorized or unsupported role")
	}
}

// CreateClassWithValidation validates role and delegates to the repository layer.
//
// Returns error if role is not allowed or insert fails.
func CreateClassWithValidation(userID int, role string, req CreateClassRequest) error {
	if role != "teacher" && role != "admin" {
		log.Warn().
			Int("user_id", userID).
			Str("role", role).
			Msg("⛔ Unauthorized create attempt")
		return errors.New("unauthorized")
	}

	err := InsertClass(
		req.Name,
		req.Schedule,
		userID,
		req.BLEID,
		req.TimeZone,
		req.StartDate,
		req.EndDate,
	)

	if err != nil {
		log.Error().
			Err(err).
			Int("user_id", userID).
			Str("class_name", req.Name).
			Msg("❌ Failed to create class")
		return err
	}

	log.Info().
		Int("user_id", userID).
		Str("class_name", req.Name).
		Str("ble_id", req.BLEID).
		Msg("✅ Class created")

	return nil
}

// EnrollUserIntoClass handles all logic for student enrollment.
//
// - Prevents non-students
// - Checks if class exists
// - Prevents re-enrolling if already active
// - Reactivates previous enrollment if inactive
// - Otherwise creates a new record
func EnrollUserIntoClass(userID int, role string, classID int) error {
	if role != "student" {
		log.Warn().
			Int("user_id", userID).
			Str("role", role).
			Msg("⛔ Unauthorized enroll attempt (non-student)")
		return errors.New("only students can enroll in classes")
	}

	// Validate class exists
	exists, err := ClassExists(classID)
	if err != nil {
		return err
	}
	if !exists {
		return errors.New("class not found")
	}

	// Check if student is already actively enrolled
	alreadyEnrolled, err := IsAlreadyEnrolled(userID, classID)
	if err != nil {
		return err
	}
	if alreadyEnrolled {
		return errors.New("you are already enrolled in this class")
	}

	// Try to reactivate a previous enrollment
	// TODO: for now its reactive but we need to fix this logic to keep new records after certain time to keep it for history purpose.
	if err := ReactivateEnrollment(userID, classID); err == nil {
		log.Info().
			Int("user_id", userID).
			Int("class_id", classID).
			Msg("✅ Rejoined previously left class")
		return nil
	}

	// Insert a new enrollment
	log.Info().
		Int("user_id", userID).
		Int("class_id", classID).
		Msg("📥 Enrolling as new record")

	return EnrollStudentInClass(userID, classID)
}

// UnenrollUserFromClass validates role and removes a student from a class.
func UnenrollUserFromClass(userID int, role string, classID int) error {
	if role != "student" {
		log.Warn().
			Int("user_id", userID).
			Str("role", role).
			Msg("⛔ Unauthorized unenroll attempt")
		return errors.New("only students can unenroll from classes")
	}

	// Check if class exists
	exists, err := ClassExists(classID)
	if err != nil {
		return err
	}
	if !exists {
		return errors.New("class not found")
	}

	// Perform unenrollment
	return UnenrollStudentFromClass(userID, classID)
}

// GetStudentsInClass validates access and returns enrolled students to the teacher.
func GetStudentsInClass(userID int, role string, classID int) ([]StudentInfo, error) {
	if role != "teacher" {
		log.Warn().
			Int("user_id", userID).
			Str("role", role).
			Msg("⛔ Unauthorized access to class student list")
		return nil, errors.New("only teachers can view class enrollments")
	}

	// Ensure the class belongs to the requesting teacher
	ownerID, err := GetClassOwnerID(classID)
	if err != nil {
		return nil, err
	}
	if ownerID != userID {
		return nil, errors.New("you do not own this class")
	}

	// Fetch students from repository
	return GetStudentsByClassID(classID)
}

// GetClassDetail returns a class with teacher info.
// Accessible to any authenticated user.
func GetClassDetail(classID int) (*ClassDetailResponse, error) {
	return GetClassByID(classID)
}

// UpdateClassBLEID verifies ownership and updates the BLE ID for a class.
//
// Only the teacher who owns the class can update its BLE device ID.
// Returns an error if unauthorized or if the DB update fails.
func UpdateClassBLEID(teacherID, classID int, newBLEID string) error {
	owns, err := DoesTeacherOwnClass(teacherID, classID)
	if err != nil {
		return err
	}
	if !owns {
		return errors.New("unauthorized: you do not own this class")
	}

	return UpdateBLEID(classID, newBLEID)
}
