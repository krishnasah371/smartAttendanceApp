package auth

import (
	"github.com/gin-gonic/gin"
	"github.com/rs/zerolog/log"
)

// RegisterRoutes sets up authentication-related endpoints.
//
// It registers the following routes under the "/auth" group:
//   - POST /auth/register -> Handles user registration.
//   - POST /auth/login    -> Handles user login and JWT authentication.
func RegisterRoutes(router *gin.RouterGroup) {
	authGroup := router.Group("/auth")
	{
		authGroup.POST("/register", RegisterHandler)
		authGroup.POST("/login", LoginHandler)
	}

	log.Info().Msg("✅ Auth module initialized!")
}
