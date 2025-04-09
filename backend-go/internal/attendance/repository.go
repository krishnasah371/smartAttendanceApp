package attendance

import (
	"encoding/json"

	"github.com/krishnasah371/smartAttendanceApp/backend/pkg/database"
	"github.com/rs/zerolog/log"
)

// InsertAttendance saves a new attendance record for a student.
// It marshals the optional location field to JSONB before storing.
func InsertAttendance(studentID, classID int, status string, location any, isManual bool) error {
	query := `
		INSERT INTO attendance (student_id, class_id, status, location, is_manual)
		VALUES ($1, $2, $3, $4, $5)
	`

	var locationJSON []byte
	var err error

	if location != nil {
		locationJSON, err = json.Marshal(location)
		if err != nil {
			log.Error().Err(err).Msg("❌ Failed to marshal location to JSON")
			return err
		}
	}

	_, err = database.DB.Exec(query, studentID, classID, status, locationJSON, isManual)
	if err != nil {
		log.Error().
			Err(err).
			Int("student_id", studentID).
			Int("class_id", classID).
			Str("status", status).
			Msg("❌ Failed to insert attendance")
		return err
	}

	log.Info().
		Int("student_id", studentID).
		Int("class_id", classID).
		Str("status", status).
		Msg("✅ Attendance marked successfully")

	return nil
}

// HasMarkedAttendanceToday checks if the student has already marked attendance for this class today.
func HasMarkedAttendanceToday(studentID, classID int) (bool, error) {
	query := `
		SELECT COUNT(*) FROM attendance
		WHERE student_id = $1
		AND class_id = $2
		AND DATE(timestamp) = CURRENT_DATE
	`

	var count int
	err := database.DB.QueryRow(query, studentID, classID).Scan(&count)
	if err != nil {
		log.Error().
			Err(err).
			Int("student_id", studentID).
			Int("class_id", classID).
			Msg("❌ Failed to check attendance existence")
		return false, err
	}

	return count > 0, nil
}

// GetStudentAttendance fetches all attendance records for a student, with optional filters.
func GetStudentAttendance(studentID int, classID *int, date *string) ([]AttendanceRecord, error) {
	query := `
		SELECT a.id, a.class_id, c.name, a.status, a.timestamp, a.is_manual, a.location
		FROM attendance a
		JOIN classes c ON a.class_id = c.id
		WHERE a.student_id = $1
	`
	args := []any{studentID}

	if classID != nil {
		query += " AND a.class_id = $2"
		args = append(args, *classID)
	}
	if date != nil {
		if classID != nil {
			query += " AND DATE(a.timestamp) = $3"
		} else {
			query += " AND DATE(a.timestamp) = $2"
		}
		args = append(args, *date)
	}

	query += " ORDER BY a.timestamp DESC"

	rows, err := database.DB.Query(query, args...)
	if err != nil {
		log.Error().Err(err).Msg("❌ Failed to fetch student attendance")
		return nil, err
	}
	defer rows.Close()

	var records []AttendanceRecord
	for rows.Next() {
		var rec AttendanceRecord
		if err := rows.Scan(&rec.ID, &rec.ClassID, &rec.ClassName, &rec.Status, &rec.Timestamp, &rec.IsManual, &rec.Location); err != nil {
			log.Error().Err(err).Msg("❌ Failed to scan attendance record")
			continue
		}
		records = append(records, rec)
	}

	return records, nil
}

// GetAttendanceByClassID fetches attendance records for a specific class with student details.
func GetAttendanceByClassID(classID int) ([]AttendanceRecord, error) {
	query := `
		SELECT 
			a.id, a.student_id, u.name, a.class_id, c.name, a.status,
			a.timestamp, a.is_manual, a.location, a.created_at, a.updated_at
		FROM attendance a
		JOIN users u ON a.student_id = u.id
		JOIN classes c ON a.class_id = c.id
		WHERE a.class_id = $1
		ORDER BY a.timestamp DESC
	`

	rows, err := database.DB.Query(query, classID)
	if err != nil {
		log.Error().Err(err).Int("class_id", classID).Msg("❌ Failed to fetch class attendance")
		return nil, err
	}
	defer rows.Close()

	var records []AttendanceRecord
	for rows.Next() {
		var rec AttendanceRecord
		if err := rows.Scan(
			&rec.ID, &rec.StudentID, &rec.StudentName,
			&rec.ClassID, &rec.ClassName,
			&rec.Status, &rec.Timestamp, &rec.IsManual,
			&rec.Location, &rec.CreatedAt, &rec.UpdatedAt,
		); err != nil {
			log.Error().Err(err).Msg("❌ Failed to scan attendance record")
			continue
		}
		records = append(records, rec)
	}

	return records, nil
}

// UpdateAttendanceRecord updates the fields of an existing attendance record.
func UpdateAttendanceRecord(attendanceID int, status string, location any, isManual bool) error {
	query := `
		UPDATE attendance
		SET status = $1, location = $2, is_manual = $3, updated_at = CURRENT_TIMESTAMP
		WHERE id = $4
	`

	// Marshal location JSON
	var locationJSON []byte
	var err error
	if location != nil {
		locationJSON, err = json.Marshal(location)
		if err != nil {
			log.Error().Err(err).Msg("❌ Failed to marshal updated location")
			return err
		}
	}

	_, err = database.DB.Exec(query, status, locationJSON, isManual, attendanceID)
	if err != nil {
		log.Error().Err(err).Int("attendance_id", attendanceID).Msg("❌ Failed to update attendance")
		return err
	}

	log.Info().
		Int("attendance_id", attendanceID).
		Str("status", status).
		Msg("✅ Attendance updated successfully")

	return nil
}
