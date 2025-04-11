package auth

// RegisterRequest represents the JSON structure for registering a user
type RegisterRequest struct {
	Name     string `json:"name" binding:"required"`
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=6"`
}

// RegisterResponse represents the JSON response for user registration
type RegisterResponse struct {
	Message string `json:"message"`
}

// LoginRequest represents the expected JSON body for user login
type LoginRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required"`
}

// LoginResponse represents the JSON response for successful login
type LoginResponse struct {
	Token   string `json:"token"`
	Success bool   `json:"success"`
	User    any    `json:"user"`
	Message string `json:"message,omitempty"`
}
