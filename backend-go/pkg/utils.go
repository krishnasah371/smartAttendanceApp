package utils

import "os"

// ParseCommand extracts the main command from the command line.
func ParseCommand() string {
	if len(os.Args) > 1 {
		return os.Args[1]
	}

	return ""
}
