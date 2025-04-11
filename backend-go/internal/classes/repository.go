package classes

import (
	"database/sql"
	"errors"

	"github.com/krishnasah371/smartAttendanceApp/backend/pkg/database"
	"github.com/rs/zerolog/log"
)

// FetchAllPublicClasses retrieves all classes with teacher details from the database.
//
// Joins classes with users (teachers) and returns full class metadata.
// This function is used by unauthenticated public endpoints.
func FetchAllPublicClasses() ([]ClassResponse, error) {
	query := `
		SELECT c.id, c.name, c.schedule, c.teacher_id, u.name, u.email, 
		       c.ble_id, c.timezone, c.start_date, c.end_date
		FROM classes c
		JOIN users u ON c.teacher_id = u.id
	`

	rows, err := database.DB.Query(query)
	if err != nil {
		log.Error().Err(err).Msg("❌ Failed to fetch all classes")
		return nil, err
	}
	defer rows.Close()

	var classes []ClassResponse
	for rows.Next() {
		var class ClassResponse
		err := rows.Scan(
			&class.ID,
			&class.Name,
			&class.Schedule,
			&class.TeacherID,
			&class.TeacherName,
			&class.TeacherEmail,
			&class.BLEID,
			&class.TimeZone,
			&class.StartDate,
			&class.EndDate,
		)
		if err != nil {
			log.Error().Err(err).Msg("❌ Failed to scan class row (public)")
			continue
		}
		classes = append(classes, class)
	}

	return classes, nil
}

// InsertClass adds a new class record to the database.
//
// Assumes all validation is already performed.
func InsertClass(name, schedule string, teacherID int, bleID, timeZone, startDate, endDate string) error {
	query := `
		INSERT INTO classes (name, schedule, teacher_id, ble_id, timezone, start_date, end_date)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
	`

	_, err := database.DB.Exec(query, name, schedule, teacherID, bleID, timeZone, startDate, endDate)
	if err != nil {
		log.Error().
			Err(err).
			Str("class_name", name).
			Int("teacher_id", teacherID).
			Msg("❌ DB insert failed")
		return err
	}

	return nil
}

// GetClassesByTeacherID fetches all classes created by a specific teacher.
func GetClassesByTeacherID(teacherID int) ([]ClassResponse, error) {
	query := `
		SELECT id, name, schedule, teacher_id, ble_id, timezone, start_date, end_date
		FROM classes
		WHERE teacher_id = $1
	`

	rows, err := database.DB.Query(query, teacherID)
	if err != nil {
		log.Error().
			Err(err).
			Int("teacher_id", teacherID).
			Msg("❌ Failed to fetch classes for teacher")
		return nil, err
	}
	defer rows.Close()

	var classes []ClassResponse
	for rows.Next() {
		var class ClassResponse
		if err := rows.Scan(&class.ID, &class.Name, &class.Schedule, &class.TeacherID, &class.BLEID, &class.TimeZone, &class.StartDate, &class.EndDate); err != nil {
			log.Error().Err(err).Msg("❌ Failed to scan class row (teacher)")
			continue
		}
		classes = append(classes, class)
	}

	return classes, nil
}

// GetClassesByStudentID fetches all classes a student is enrolled in, including the teacher's name.
func GetClassesByStudentID(studentID int) ([]ClassResponse, error) {
	query := `
		SELECT c.id, c.name, c.schedule, c.teacher_id, u.name, 
		       c.ble_id, c.timezone, c.start_date, c.end_date
		FROM class_enrollments ce
		JOIN classes c ON ce.class_id = c.id
		JOIN users u ON c.teacher_id = u.id
		WHERE ce.student_id = $1
		AND ce.currently_enrolled = TRUE
	`

	rows, err := database.DB.Query(query, studentID)
	if err != nil {
		log.Error().
			Err(err).
			Int("student_id", studentID).
			Msg("❌ Failed to fetch enrolled classes for student")
		return nil, err
	}
	defer rows.Close()

	var classes []ClassResponse
	for rows.Next() {
		var class ClassResponse
		err := rows.Scan(
			&class.ID,
			&class.Name,
			&class.Schedule,
			&class.TeacherID,
			&class.TeacherName,
			&class.BLEID,
			&class.TimeZone,
			&class.StartDate,
			&class.EndDate,
		)
		if err != nil {
			log.Error().Err(err).Msg("❌ Failed to scan class row (student)")
			continue
		}
		classes = append(classes, class)
	}

	return classes, nil
}

// EnrollStudentInClass inserts a new record in class_enrollments.
//
// Returns an error if already enrolled (via UNIQUE constraint).
func EnrollStudentInClass(studentID, classID int) error {
	query := `
		INSERT INTO class_enrollments (student_id, class_id)
		VALUES ($1, $2)
	`
	_, err := database.DB.Exec(query, studentID, classID)
	if err != nil {
		log.Error().
			Err(err).
			Int("student_id", studentID).
			Int("class_id", classID).
			Msg("❌ Failed to enroll student in class")
		return err
	}

	log.Info().
		Int("student_id", studentID).
		Int("class_id", classID).
		Msg("✅ Student enrolled successfully")
	return nil
}

// ClassExists checks whether a class with the given ID exists.
func ClassExists(classID int) (bool, error) {
	query := `SELECT 1 FROM classes WHERE id = $1`
	var exists int
	err := database.DB.QueryRow(query, classID).Scan(&exists)
	if err == sql.ErrNoRows {
		return false, nil
	}
	if err != nil {
		log.Error().Err(err).Int("class_id", classID).Msg("❌ Error checking if class exists")
		return false, err
	}
	return true, nil
}

// IsAlreadyEnrolled checks if the student is currently enrolled in the class.
func IsAlreadyEnrolled(studentID, classID int) (bool, error) {
	query := `
		SELECT 1 FROM class_enrollments
		WHERE student_id = $1 AND class_id = $2 AND currently_enrolled = TRUE
	`
	var exists int
	err := database.DB.QueryRow(query, studentID, classID).Scan(&exists)
	if err == sql.ErrNoRows {
		return false, nil
	}
	if err != nil {
		log.Error().
			Err(err).
			Int("student_id", studentID).
			Int("class_id", classID).
			Msg("❌ Failed to check current enrollment")
		return false, err
	}
	return true, nil
}

// ReactivateEnrollment sets currently_enrolled to true for a previously dropped class.
func ReactivateEnrollment(studentID, classID int) error {
	query := `
		UPDATE class_enrollments
		SET currently_enrolled = TRUE
		WHERE student_id = $1 AND class_id = $2 AND currently_enrolled = FALSE
	`
	result, err := database.DB.Exec(query, studentID, classID)
	if err != nil {
		log.Error().
			Err(err).
			Int("student_id", studentID).
			Int("class_id", classID).
			Msg("❌ Failed to reactivate enrollment")
		return err
	}

	rows, _ := result.RowsAffected()
	if rows > 0 {
		log.Info().
			Int("student_id", studentID).
			Int("class_id", classID).
			Msg("✅ Reactivated previous enrollment")
		return nil
	}

	return errors.New("no inactive enrollment found to reactivate")
}

// UnenrollStudentFromClass sets currently_enrolled to false for a student's class enrollment.
func UnenrollStudentFromClass(studentID, classID int) error {
	query := `
		UPDATE class_enrollments
		SET currently_enrolled = FALSE
		WHERE student_id = $1 AND class_id = $2 AND currently_enrolled = TRUE
	`
	result, err := database.DB.Exec(query, studentID, classID)
	if err != nil {
		log.Error().
			Err(err).
			Int("student_id", studentID).
			Int("class_id", classID).
			Msg("❌ Failed to unenroll student from class")
		return err
	}

	rowsAffected, _ := result.RowsAffected()
	if rowsAffected == 0 {
		log.Warn().
			Int("student_id", studentID).
			Int("class_id", classID).
			Msg("⚠️ Student is not currently enrolled")
		return errors.New("you are not currently enrolled in this class")
	}

	log.Info().
		Int("student_id", studentID).
		Int("class_id", classID).
		Msg("✅ Student successfully unenrolled")

	return nil
}

// GetStudentsByClassID returns currently enrolled students in a class with enrollment timestamps.
func GetStudentsByClassID(classID int) ([]StudentInfo, error) {
	query := `
		SELECT u.id, u.name, u.email, ce.enrolled_at
		FROM class_enrollments ce
		JOIN users u ON ce.student_id = u.id
		WHERE ce.class_id = $1
		  AND ce.currently_enrolled = TRUE
		  AND u.role = 'student'
	`

	rows, err := database.DB.Query(query, classID)
	if err != nil {
		log.Error().
			Err(err).
			Int("class_id", classID).
			Msg("❌ Failed to fetch students for class")
		return nil, err
	}
	defer rows.Close()

	var students []StudentInfo
	for rows.Next() {
		var s StudentInfo
		if err := rows.Scan(&s.ID, &s.Name, &s.Email, &s.EnrolledAt); err != nil {
			log.Error().Err(err).Msg("❌ Failed to scan student row")
			continue
		}
		students = append(students, s)
	}

	log.Info().
		Int("class_id", classID).
		Int("count", len(students)).
		Msg("✅ Students fetched for class")

	return students, nil
}

// GetClassOwnerID returns the teacher ID who created the class.
func GetClassOwnerID(classID int) (int, error) {
	query := `SELECT teacher_id FROM classes WHERE id = $1`
	var teacherID int
	err := database.DB.QueryRow(query, classID).Scan(&teacherID)
	if err == sql.ErrNoRows {
		return 0, errors.New("class not found")
	}
	if err != nil {
		log.Error().Err(err).Int("class_id", classID).Msg("❌ Failed to fetch class owner")
		return 0, err
	}
	return teacherID, nil
}

// GetClassByID fetches full class details by ID, including teacher name.
func GetClassByID(classID int) (*ClassDetailResponse, error) {
	query := `
		SELECT c.id, c.name, c.schedule, c.teacher_id, u.name, 
		       c.ble_id, c.timezone, c.start_date, c.end_date, c.created_at
		FROM classes c
		JOIN users u ON c.teacher_id = u.id
		WHERE c.id = $1
	`

	var class ClassDetailResponse
	err := database.DB.QueryRow(query, classID).Scan(
		&class.ID,
		&class.Name,
		&class.Schedule,
		&class.TeacherID,
		&class.TeacherName,
		&class.BLEID,
		&class.TimeZone,
		&class.StartDate,
		&class.EndDate,
		&class.CreatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, errors.New("class not found")
	}
	if err != nil {
		log.Error().Err(err).Int("class_id", classID).Msg("❌ Failed to fetch class detail")
		return nil, err
	}

	log.Info().Int("class_id", classID).Msg("✅ Fetched class detail")
	return &class, nil
}

// Get Registered BLE ID for the given classID
func GetClassBLEID(classID int) (string, error) {
	query := `SELECT ble_id FROM classes WHERE id = $1`
	var bleID string
	err := database.DB.QueryRow(query, classID).Scan(&bleID)
	if err == sql.ErrNoRows {
		return "", errors.New("class not found")
	}
	if err != nil {
		log.Error().Err(err).Int("class_id", classID).Msg("❌ Failed to fetch class BLE ID")
		return "", err
	}
	return bleID, nil
}

// DoesTeacherOwnClass checks if the given teacher owns the specified class.
func DoesTeacherOwnClass(teacherID, classID int) (bool, error) {
	query := `SELECT COUNT(*) FROM classes WHERE id = $1 AND teacher_id = $2`

	var count int
	err := database.DB.QueryRow(query, classID, teacherID).Scan(&count)
	if err != nil {
		log.Error().
			Err(err).
			Int("teacher_id", teacherID).
			Int("class_id", classID).
			Msg("❌ Failed to check class ownership")
		return false, err
	}

	return count > 0, nil
}

// UpdateBLEID sets a new BLE ID for the given class.
//
// Returns error if the update fails.
func UpdateBLEID(classID int, bleID string) error {
	query := `UPDATE classes SET ble_id = $1 WHERE id = $2`

	_, err := database.DB.Exec(query, bleID, classID)
	if err != nil {
		log.Error().
			Err(err).
			Int("class_id", classID).
			Str("ble_id", bleID).
			Msg("❌ Failed to update BLE ID")
		return err
	}

	log.Info().
		Int("class_id", classID).
		Str("ble_id", bleID).
		Msg("✅ BLE ID updated")
	return nil
}
