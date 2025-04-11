package auth

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/rs/zerolog/log"
)

// LoginHandler authenticates a user and returns a JWT token and user details.
//
// It expects a JSON request body containing:
//   - email: The user's email address (required).
//   - password: The user's password (required).
//
// Responds with:
//   - token: JWT token string
//   - user: Basic user info (id, name, email, role, created_at)
//   - success: true/false
//   - message or error
func LoginHandler(c *gin.Context) {
	var req LoginRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"error":   err.Error(),
		})
		return
	}

	// Authenticate and retrieve token + user
	token, user, err := AuthenticateUserService(req.Email, req.Password)
	if err != nil {
		log.Warn().Str("email", req.Email).Msg("⚠️ Login failed: Invalid credentials")
		c.JSON(http.StatusUnauthorized, gin.H{
			"success": false,
			"error":   "invalid credentials",
		})
		return
	}

	// Return token + user
	c.JSON(http.StatusOK, gin.H{
		"token":   token,
		"success": true,
		"user": gin.H{
			"id":         user.ID,
			"name":       user.Name,
			"email":      user.Email,
			"role":       user.Role,
			"created_at": user.CreatedAt,
		},
		"message": "Login successful",
	})
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
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"error":   err.Error(),
		})
		return
	}

	user, err := RegistgerUserService(req.Name, req.Email, req.Password, req.Role)
	if err != nil {
		log.Error().Err(err).Msg("❌ Failed to register user")
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"error":   err.Error(),
		})
		return
	}

	log.Info().
		Str("email", user.Email).
		Int("id", user.ID).
		Msg("✅ User registered successfully")

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "User registered successfully",
		"user": gin.H{
			"id":         user.ID,
			"name":       user.Name,
			"email":      user.Email,
			"role":       user.Role,
			"created_at": user.CreatedAt,
		},
	})
}

// GetCurrentUserHandler returns the currently authenticated user's information.
//
// It uses the user ID extracted from the JWT in middleware to fetch the user from the database.
// Responds with the user object or an error message.
func GetCurrentUserHandler(c *gin.Context) {
	userID := c.GetInt("user_id")

	user, err := GetUserByID(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "User not found or DB error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"user": user})
}
