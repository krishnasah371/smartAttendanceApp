package auth

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/rs/zerolog/log"
)

// LoginHandler authenticates a user and returns a JWT token if credentials are valid.
//
// It expects a JSON request body containing:
//   - email: The user's email address (required).
//   - password: The user's password (required).
//
// If authentication is successful, it responds with a JSON object containing the JWT token.
// Otherwise, it returns an error message indicating invalid credentials.
func LoginHandler(c *gin.Context) {
	var req LoginRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Authenticate user
	token, err := AuthenticateUserService(req.Email, req.Password)
	if err != nil {
		log.Warn().Str("email", req.Email).Msg("⚠️ Login failed: Ivalid credentials")
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid credentials"})
		return
	}

	// Return JWT token in reponse
	c.JSON(http.StatusOK, LoginResponse{Token: token})
}

// RegisterHandler registers a new user and stores the details in the database.
//
// It expects a JSON request body containing:
//   - name: The user's full name (required).
//   - email: The user's email address (required, unique).
//   - password: The user's password (required, minimum length).
//   - role: The user's role (required, e.g., "student", "teacher", "admin").
//
// If registration is successful, it responds with a success message.
// If any error occurs, it returns an appropriate error message.
func RegisterHandler(c *gin.Context) {
	var req RegisterRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err := RegistgerUserService(req.Name, req.Email, req.Password)
	if err != nil {
		log.Error().Err(err).Msg("❌ Failed to register user")
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, RegisterResponse{Message: "User registered successfully"})
}
