package auth

// RegisterRequest represents the JSON structure for registering a user
type RegisterRequest struct {
	Name     string `json:"name" binding:"required"`
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=6"`
	Role     string `json:"role" binding:"required"`
}

// RegisterResponse represents the JSON response for user registration
type RegisterResponse struct {
	Message string `json:"message"`
}
