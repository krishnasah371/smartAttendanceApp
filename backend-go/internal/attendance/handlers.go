package attendance

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
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

// GetClassAttendanceHandler returns all attendance records for a given class (teacher view).
//
// @Summary View class attendance
// @Tags Attendance
// @Produce json
// @Param id path int true "Class ID"
// @Success 200 {object} map[string]any
// @Failure 403,500 {object} map[string]string
// @Router /classes/{id}/attendance [get]
// @Security Bearer
func GetClassAttendanceHandler(c *gin.Context) {
	classID, err := strconv.Atoi(c.Param("id"))
	if err != nil || classID <= 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid class ID"})
		return
	}

	userRole := c.GetString("role")
	if userRole != "teacher" && userRole != "admin" {
		c.JSON(http.StatusForbidden, gin.H{"error": "Only teachers or admins can view class attendance"})
		return
	}

	records, err := GetAttendanceByClassID(classID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch attendance"})
		return
	}

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
