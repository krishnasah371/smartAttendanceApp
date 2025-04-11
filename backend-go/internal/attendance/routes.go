package attendance

import (
	"github.com/gin-gonic/gin"
	middleware "github.com/krishnasah371/smartAttendanceApp/backend/pkg/middlewares"
	"github.com/rs/zerolog/log"
)

// RegisterRoutes sets up attendance-related endpoints.
//
// It registers the following routes under the "/attendance" and "/classes/:id/attendance" groups:
//   - POST /classes/:id/attendance/mark  → Student marks attendance
func RegisterRoutes(router *gin.RouterGroup) {
	attendanceGroup := router.Group("/classes/:id/attendance")

	attendanceGroup.GET("/session", GetCurrentBLEIDHandler)

	// Protected routes
	attendanceGroup.Use(middleware.AuthMiddleware())
	{
		attendanceGroup.POST("/mark", MarkAttendanceHandler)
		attendanceGroup.PUT("/:attendance_id", UpdateAttendanceHandler)
		
		attendanceGroup.GET("", GetClassAttendanceHandler)
		attendanceGroup.GET("/by-date", GetAttendanceForDateHandler)
		attendanceGroup.GET("/previous", GetPreviousAttendanceHandler)

		attendanceGroup.POST("/start", StartAttendanceBroadcastHandler)
	}

	log.Info().Msg("✅ Attendance module initialized!")
}
