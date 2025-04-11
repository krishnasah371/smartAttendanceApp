package classes

import (
	"fmt"

	"github.com/gin-gonic/gin"
	middleware "github.com/krishnasah371/smartAttendanceApp/backend/pkg/middlewares"
	"github.com/rs/zerolog/log"
)

// RegisterRoutes sets up class-related endpoints.
//
// It registers the following routes under the "/classes" group:
//   - POST /classes         -> Creates a new class (teacher/admin only)
func RegisterRoutes(router *gin.RouterGroup) {
	fmt.Printf("reached here")
	classGroup := router.Group("/classes")

	// ✅ Public route (no auth)
	classGroup.GET("/public", GetAllClassesHandler)

	fmt.Printf("reached here")

	// Protected Routes (requires JWT auth)
	classGroup.Use(middleware.AuthMiddleware())
	{
		fmt.Printf("reached here")
		classGroup.POST("/register", CreateClassHandler)
		classGroup.GET("/", GetClassesHandler)
		classGroup.GET("/:id", GetClassDetailHandler)

		classGroup.PUT("/:id/ble", UpdateBLEIDHandler)

		classGroup.POST("/:id/enroll", EnrollInClassHandler)
		classGroup.DELETE("/:id/unenroll", UnenrollFromClassHandler)

		classGroup.GET("/:id/students", GetStudentsInClassHandler)

	}

	log.Info().Msg("✅ Classes module initialized!")
}
