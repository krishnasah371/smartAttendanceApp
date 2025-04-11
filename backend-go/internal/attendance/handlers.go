package attendance

import (
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/rs/zerolog/log"
)

// / MarkAttendanceHandler handles the POST request to mark attendance for a student.
//
// @Summary Mark attendance
// @Description Student can mark their attendance during class using BLE device verification.
// @Tags Attendance
// @Accept json
// @Produce json
// @Param id path int true "Class ID"
// @Param Authorization header string true "Bearer token"
// @Param body body MarkAttendanceRequest true "Attendance request body"
// @Success 200 {object} map[string]string
// @Failure 400,403,404,500 {object} map[string]string
// @Router /classes/{id}/attendance/mark [post]
// @Security Bearer
func MarkAttendanceHandler(c *gin.Context) {
	classID, err := strconv.Atoi(c.Param("id"))
	if err != nil || classID <= 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid class ID"})
		return
	}

	var req MarkAttendanceRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userID := c.GetInt("user_id")
	role := c.GetString("role")

	if role != "student" {
		c.JSON(http.StatusForbidden, gin.H{"error": "Only students can mark attendance"})
		return
	}

	err = MarkAttendanceForStudent(userID, classID, req.Status, req.Location, req.BLEID)
	if err != nil {
		switch err.Error() {
		case "you are not enrolled in this class":
			c.JSON(http.StatusForbidden, gin.H{"error": err.Error()})
		case "invalid BLE device — you are not near the class":
			c.JSON(http.StatusForbidden, gin.H{"error": err.Error()})
		case "class not found":
			c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		case "attendance already marked for today":
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		default:
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Attendance marking failed"})
		}
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Attendance marked successfully"})
}

// GetClassAttendanceHandler returns all attendance records for a class (teacher/admin only).
//
// @Summary View class attendance
// @Tags Attendance
// @Produce json
// @Param id path int true "Class ID"
// @Success 200 {object} map[string][]AttendanceRecord
// @Failure 400,403,500 {object} map[string]string
// @Router /classes/{id}/attendance [get]
// @Security Bearer
func GetClassAttendanceHandler(c *gin.Context) {
	classID, err := strconv.Atoi(c.Param("id"))
	if err != nil || classID <= 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid class ID"})
		return
	}

	userID := c.GetInt("user_id")
	role := c.GetString("role")

	records, err := FetchClassAttendance(userID, classID, role)
	if err != nil {
		switch err.Error() {
		case "unauthorized":
			c.JSON(http.StatusForbidden, gin.H{"error": "Only teachers/admins can view class attendance"})
		case "unauthorized: you do not own this class":
			c.JSON(http.StatusForbidden, gin.H{"error": err.Error()})
		default:
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch attendance"})
		}
		return
	}

	c.JSON(http.StatusOK, gin.H{"attendance": records})
}

// GetAttendanceForDateHandler returns attendance for a class on a specific date (teacher/admin only).
//
// @Summary View attendance for a specific date
// @Tags Attendance
// @Produce json
// @Param id path int true "Class ID"
// @Param date query string true "Date (YYYY-MM-DD)"
// @Success 200 {object} map[string][]AttendanceRecord
// @Failure 400,403,500 {object} map[string]string
// @Router /classes/{id}/attendance/by-date [get]
// @Security Bearer
func GetAttendanceForDateHandler(c *gin.Context) {
	classID, err := strconv.Atoi(c.Param("id"))
	if err != nil || classID <= 0 {
		log.Warn().Msg("⚠️ Invalid class ID in path")
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid class ID"})
		return
	}

	date := c.Query("date")
	if date == "" {
		log.Warn().Msg("⚠️ Missing date query parameter")
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing 'date' query param"})
		return
	}

	userID := c.GetInt("user_id")
	role := c.GetString("role")

	log.Info().
		Int("user_id", userID).
		Int("class_id", classID).
		Str("role", role).
		Str("date", date).
		Msg("📥 Fetching attendance for class on specific date")

	records, err := FetchAttendanceForDate(userID, classID, role, date)
	if err != nil {
		switch err.Error() {
		case "unauthorized":
			c.JSON(http.StatusForbidden, gin.H{"error": "Only teachers or admins can view attendance by date"})
		case "unauthorized: you do not own this class":
			c.JSON(http.StatusForbidden, gin.H{"error": err.Error()})
		default:
			log.Error().Err(err).Msg("❌ Internal error while fetching date-based attendance")
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch attendance for date"})
		}
		return
	}

	log.Info().Int("count", len(records)).Msg("✅ Attendance for date fetched successfully")
	c.JSON(http.StatusOK, gin.H{"attendance": records})
}

// GetPreviousAttendanceHandler returns full attendance history for a class (teacher/admin only).
//
// @Summary View full attendance history
// @Tags Attendance
// @Produce json
// @Param id path int true "Class ID"
// @Success 200 {object} map[string][]AttendanceRecord
// @Failure 400,403,500 {object} map[string]string
// @Router /classes/{id}/attendance/previous [get]
// @Security Bearer
func GetPreviousAttendanceHandler(c *gin.Context) {
	classID, err := strconv.Atoi(c.Param("id"))
	if err != nil || classID <= 0 {
		log.Warn().Msg("⚠️ Invalid class ID in path")
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid class ID"})
		return
	}

	userID := c.GetInt("user_id")
	role := c.GetString("role")

	log.Info().
		Int("user_id", userID).
		Int("class_id", classID).
		Str("role", role).
		Msg("📥 Fetching full attendance history")

	records, err := FetchPreviousAttendance(userID, classID, role)
	if err != nil {
		switch err.Error() {
		case "unauthorized":
			c.JSON(http.StatusForbidden, gin.H{"error": "Only teachers or admins can view full attendance history"})
		case "unauthorized: you do not own this class":
			c.JSON(http.StatusForbidden, gin.H{"error": err.Error()})
		default:
			log.Error().Err(err).Msg("❌ Failed to fetch attendance history")
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch attendance history"})
		}
		return
	}

	log.Info().Int("count", len(records)).Msg("✅ Full attendance history fetched")
	c.JSON(http.StatusOK, gin.H{"attendance": records})
}

// UpdateAttendanceHandler allows a teacher/admin to edit a student's attendance.
//
// @Summary Update attendance
// @Tags Attendance
// @Accept json
// @Produce json
// @Param id path int true "Class ID"
// @Param attendance_id path int true "Attendance Record ID"
// @Param Authorization header string true "Bearer token"
// @Param body body UpdateAttendanceRequest true "Updated attendance"
// @Success 200 {object} map[string]string
// @Failure 400,403,404,500 {object} map[string]string
// @Router /classes/{id}/attendance/{attendance_id} [put]
// @Security Bearer
func UpdateAttendanceHandler(c *gin.Context) {
	classID, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid class ID"})
		return
	}

	attendanceID, err := strconv.Atoi(c.Param("attendance_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid attendance ID"})
		return
	}

	userID := c.GetInt("user_id")
	role := c.GetString("role")
	if role != "teacher" && role != "admin" {
		c.JSON(http.StatusForbidden, gin.H{"error": "Only teachers or admins can edit attendance"})
		return
	}

	var req UpdateAttendanceRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err = UpdateAttendanceForTeacher(userID, classID, attendanceID, req)
	if err != nil {
		switch err.Error() {
		case "unauthorized: you do not own this class":
			c.JSON(http.StatusForbidden, gin.H{"error": err.Error()})
		default:
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update attendance"})
		}
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Attendance updated successfully"})
}

// StartAttendanceBroadcastHandler handles BLE broadcast start by teachers.
func StartAttendanceBroadcastHandler(c *gin.Context) {
	classID := c.Param("id")
	var req StartBroadcastRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Only teachers or admins can start the session
	role := c.GetString("role")
	if role != "teacher" && role != "admin" {
		c.JSON(http.StatusForbidden, gin.H{"error": "Only teachers or admins can start attendance session"})
		return
	}

	// Store BLE session in memory for 5 minutes
	setSession(classID, req.Date, req.BluetoothID, 5*time.Minute)

	c.JSON(http.StatusOK, gin.H{"message": "BLE broadcast started for 5 minutes"})
}

// GetCurrentBLEIDHandler returns the BLE ID currently active for a class+date.
func GetCurrentBLEIDHandler(c *gin.Context) {
	classID := c.Param("id")
	date := c.Query("date")

	if date == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing 'date' query param"})
		return
	}

	bleID := getSession(classID, date)
	c.JSON(http.StatusOK, gin.H{"bluetooth_id": bleID})
}
