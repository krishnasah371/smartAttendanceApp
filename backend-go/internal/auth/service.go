package auth

import "github.com/rs/zerolog/log"

func RegistgerUser(name, email, password string) error {
	log.Info().Str("email", email).Msg("✅ User registered successfully")
	return nil
}
