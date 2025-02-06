package auth

import (
	"github.com/gin-gonic/gin"
	"github.com/rs/zerolog/log"
)

func RegisterRoutes(router *gin.RouterGroup) {
	authGroup := router.Group("/auth")
	{
		authGroup.POST("/register", RegisterHandler)
	}

	// Debuging logs --> TODO: To be removed
	log.Info().Msg("✅ Auth module initialized!")
}
