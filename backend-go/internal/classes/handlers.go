package classes

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/rs/zerolog/log"
)

// / CreateClassHandler handles the creation of a new class, including BLE ID.
//
// @Summary Create a class
// @Description Allows a teacher or admin to create a class by providing name, schedule, and BLE ID.
// @Tags Classes
// @Accept json
// @Produce json
// @Param Authorization header string true "Bearer token"
// @Param class body CreateClassRequest true "Class data"
// @Success 200 {object} map[string]string "Class created successfully"
// @Failure 400 {object} map[string]string "Invalid input"
// @Failure 403 {object} map[string]string "Only teachers or admins allowed"
// @Failure 500 {object} map[string]string "Internal server error"
// @Router /classes [post]
// @Security Bearer
func CreateClassHandler(c *gin.Context) {
	var req CreateClassRequest

	// Bind request JSON to struct
	if err := c.ShouldBindJSON(&req); err != nil {
		log.Warn().Err(err).Msg("⚠️ Invalid class creation input")
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	teacherID := c.GetInt("user_id")
	role := c.GetString("role")

	// Role check
	if role != "teacher" && role != "admin" {
		log.Warn().
			Int("user_id", teacherID).
			Str("role", role).
			Msg("⛔ Unauthorized attempt to create class")
		c.JSON(http.StatusForbidden, gin.H{"error": "Only teachers or admins can create classes"})
		return
	}

	// Call updated repository function with BLE ID
	err := CreateClass(req.Name, req.Schedule, teacherID, req.BLEID, req.TimeZone, req.StartDate, req.EndDate)
	if err != nil {
		log.Error().
			Err(err).
			Int("teacher_id", teacherID).
			Str("class_name", req.Name).
			Str("ble_id", req.BLEID).
			Msg("❌ Failed to create class in DB")
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not create class"})
		return
	}

	log.Info().
		Int("teacher_id", teacherID).
		Str("class_name", req.Name).
		Str("ble_id", req.BLEID).
		Str("time_zone", req.TimeZone).
		Str("start_date", req.StartDate).
		Str("end_date", req.EndDate).
		Msg("✅ Class created successfully with BLE ID")

	c.JSON(http.StatusOK, gin.H{"message": "Class created successfully"})
}

// GetClassesHandler handles GET /classes to return classes based on user role.
//
// @Summary Get classes for the current user
// @Description Teachers get the classes they created, students get the classes they're enrolled in.
// @Tags Classes
// @Produce json
// @Success 200 {object} map[string][]ClassResponse
// @Failure 500 {object} map[string]string "Internal server error"
// @Router /classes [get]
// @Security Bearer
func GetClassesHandler(c *gin.Context) {
	// Extract user context from JWT middleware
	userID := c.GetInt("user_id")
	role := c.GetString("role")

	log.Info().
		Int("user_id", userID).
		Str("role", role).
		Msg("📦 Fetching classes for user")

	// Delegate role-specific class logic to service layer
	classes, err := GetClassesForUser(userID, role)
	if err != nil {
		log.Error().
			Err(err).
			Int("user_id", userID).
			Str("role", role).
			Msg("❌ Failed to fetch classes")
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch classes"})
		return
	}

	log.Info().
		Int("user_id", userID).
		Int("count", len(classes)).
		Msg("✅ Classes fetched successfully")

	// Return list of classes in JSON
	c.JSON(http.StatusOK, gin.H{"classes": classes})
}

// EnrollInClassHandler allows a student to enroll in a class.
//
// @Summary Enroll in a class
// @Description Allows students to join a class by ID.
// @Tags Classes
// @Produce json
// @Param id path int true "Class ID"
// @Success 200 {object} EnrollClassResponse
// @Failure 400 {object} map[string]string
// @Failure 403 {object} map[string]string
// @Failure 500 {object} map[string]string
// @Router /classes/{id}/enroll [post]
// @Security Bearer
func EnrollInClassHandler(c *gin.Context) {
	classID, err := strconv.Atoi(c.Param("id"))
	if err != nil || classID <= 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid class ID"})
		return
	}

	userID := c.GetInt("user_id")
	role := c.GetString("role")

	if err := EnrollUserIntoClass(userID, role, classID); err != nil {
		switch err.Error() {
		case "only students can enroll in classes":
			c.JSON(http.StatusForbidden, gin.H{"error": err.Error()})
		case "class not found":
			c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		case "you are already enrolled in this class":
			c.JSON(http.StatusConflict, gin.H{"error": err.Error()})
		default:
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Enrollment failed"})
		}
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Enrolled in class successfully"})
}

// UnenrollFromClassHandler allows a student to leave a class.
//
// @Summary Unenroll from a class
// @Description Sets currently_enrolled = false
// @Tags Classes
// @Produce json
// @Param id path int true "Class ID"
// @Success 200 {object} map[string]string
// @Failure 400,403,404,500 {object} map[string]string
// @Router /classes/{id}/unenroll [delete]
// @Security Bearer
func UnenrollFromClassHandler(c *gin.Context) {
	classID, err := strconv.Atoi(c.Param("id"))
	if err != nil || classID <= 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid class ID"})
		return
	}

	userID := c.GetInt("user_id")
	role := c.GetString("role")

	err = UnenrollUserFromClass(userID, role, classID)
	if err != nil {
		switch err.Error() {
		case "only students can unenroll from classes":
			c.JSON(http.StatusForbidden, gin.H{"error": err.Error()})
		case "class not found":
			c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		case "you are not currently enrolled in this class":
			c.JSON(http.StatusConflict, gin.H{"error": err.Error()})
		default:
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Unenrollment failed"})
		}
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Unenrolled from class successfully"})
}

// GetStudentsInClassHandler returns students currently enrolled in a class.
//
// @Summary Get students in a class
// @Description Teachers can view students enrolled in their own class
// @Tags Classes
// @Produce json
// @Param id path int true "Class ID"
// @Success 200 {object} map[string][]StudentInfo
// @Failure 403,404,500 {object} map[string]string
// @Router /classes/{id}/students [get]
// @Security Bearer
func GetStudentsInClassHandler(c *gin.Context) {
	classID, err := strconv.Atoi(c.Param("id"))
	if err != nil || classID <= 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid class ID"})
		return
	}

	userID := c.GetInt("user_id")
	role := c.GetString("role")

	students, err := GetStudentsInClass(userID, role, classID)
	if err != nil {
		switch err.Error() {
		case "only teachers can view class enrollments":
			c.JSON(http.StatusForbidden, gin.H{"error": err.Error()})
		case "you do not own this class":
			c.JSON(http.StatusForbidden, gin.H{"error": err.Error()})
		case "class not found":
			c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		default:
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch students"})
		}
		return
	}

	c.JSON(http.StatusOK, gin.H{"students": students})
}

// GetClassDetailHandler returns detailed info about a specific class.
//
// @Summary Get class details
// @Description Returns name, schedule, teacher info, and created timestamp
// @Tags Classes
// @Produce json
// @Param id path int true "Class ID"
// @Success 200 {object} map[string]ClassDetailResponse
// @Failure 400,404,500 {object} map[string]string
// @Router /classes/{id} [get]
// @Security Bearer
func GetClassDetailHandler(c *gin.Context) {
	classID, err := strconv.Atoi(c.Param("id"))
	if err != nil || classID <= 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid class ID"})
		return
	}

	class, err := GetClassDetail(classID)
	if err != nil {
		if err.Error() == "class not found" {
			c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch class detail"})
		}
		return
	}

	c.JSON(http.StatusOK, gin.H{"class": class})
}
