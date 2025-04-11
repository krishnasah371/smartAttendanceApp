package classes

import (
	"fmt"
	"net/http"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/rs/zerolog/log"
)

// GetAllClassesHandler handles the public endpoint to list all classes.
//
// @Summary Get all classes (public)
// @Description Returns basic class info (public access).
// @Tags Classes
// @Produce json
// @Success 200 {object} map[string][]ClassResponse
// @Failure 500 {object} map[string]string
// @Router /classes/public [get]
func GetAllClassesHandler(c *gin.Context) {
	classes, err := GetAllPublicClasses()
	if err != nil {
		log.Error().Err(err).Msg("❌ Failed to fetch all public classes")
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch classes"})
		return
	}

	log.Info().Int("count", len(classes)).Msg("✅ Public classes fetched")
	c.JSON(http.StatusOK, gin.H{"classes": classes})
}

// CreateClassHandler handles the creation of a new class.
//
// @Summary Create a class
// @Description Teachers or admins can create a class with BLE ID and schedule info.
// @Tags Classes
// @Accept json
// @Produce json
// @Param Authorization header string true "Bearer token"
// @Param class body CreateClassRequest true "Class data"
// @Success 200 {object} map[string]string "Class created successfully"
// @Failure 400,403,500 {object} map[string]string
// @Router /classes [post]
// @Security Bearer
func CreateClassHandler(c *gin.Context) {

	headers := map[string]string{}
	for k, v := range c.Request.Header {
		headers[k] = strings.Join(v, ", ")
	}

	log.Info().
		Str("method", c.Request.Method).
		Str("url", c.Request.URL.String()).
		Str("remote_addr", c.Request.RemoteAddr).
		Interface("headers", headers).
		Msg("📥 Incoming request to create class")

	var req CreateClassRequest
	fmt.Print(c.Request)

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userID := c.GetInt("user_id")
	role := c.GetString("role")
	fmt.Print(c.Request)
	if err := CreateClassWithValidation(userID, role, req); err != nil {
		switch err.Error() {
		case "unauthorized":
			c.JSON(http.StatusForbidden, gin.H{"error": "Only teachers or admins can create classes"})
		default:
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not create class"})
		}
		return
	}

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
	fmt.Printf("📦 reached here: %+v\n", c.Request) // logs with field names

	log.Info().
		Str("method", c.Request.Method).
		Str("url", c.Request.URL.String()).
		Str("remote_addr", c.Request.RemoteAddr).
		Str("user_agent", c.Request.UserAgent()).
		Interface("headers", c.Request.Header).
		Msg("📥 Incoming request")

	userID := c.GetInt("user_id")
	role := c.GetString("role")

	log.Info().
		Int("user_id", userID).
		Str("role", role).
		Msg("📦 Fetching classes for user")

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
	if classes == nil {
		classes = []ClassResponse{}
	}
	fmt.Printf("📦 classes: %+v\n", classes) // logs with field names
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

// UpdateBLEIDHandler allows a teacher to update the BLE ID of a class they own.
//
// @Summary Update BLE ID
// @Description Allows a teacher to reconfigure the Bluetooth beacon for a class.
// @Tags Classes
// @Accept json
// @Produce json
// @Param id path int true "Class ID"
// @Param Authorization header string true "Bearer token"
// @Param body body UpdateBLEIDRequest true "New BLE ID"
// @Success 200 {object} map[string]string "BLE ID updated successfully"
// @Failure 400 {object} map[string]string "Invalid input"
// @Failure 403 {object} map[string]string "Unauthorized"
// @Failure 500 {object} map[string]string "Failed to update BLE ID"
// @Router /classes/{id}/ble [put]
// @Security Bearer
func UpdateBLEIDHandler(c *gin.Context) {
	classID, err := strconv.Atoi(c.Param("id"))
	if err != nil || classID <= 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid class ID"})
		return
	}

	var req UpdateBLEIDRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userID := c.GetInt("user_id")
	role := c.GetString("role")

	if role != "teacher" {
		c.JSON(http.StatusForbidden, gin.H{"error": "Only teachers can update BLE ID"})
		return
	}

	if err := UpdateClassBLEID(userID, classID, req.BLEID); err != nil {
		if err.Error() == "unauthorized: you do not own this class" {
			c.JSON(http.StatusForbidden, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update BLE ID"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "BLE ID updated successfully"})
}
