package attendance

import (
	"fmt"
	"sync"
	"time"
)

var (
	activeSessions = make(map[string]string) // key: classID:date
	sessionMutex   sync.Mutex
)

// setSession starts a BLE session for a class on a date with expiry
func setSession(classID, date, bleID string, ttl time.Duration) {
	key := fmt.Sprintf("%s:%s", classID, date)

	sessionMutex.Lock()
	activeSessions[key] = bleID
	sessionMutex.Unlock()

	go func() {
		time.Sleep(ttl)
		sessionMutex.Lock()
		delete(activeSessions, key)
		sessionMutex.Unlock()
	}()
}

// getSession retrieves BLE ID for class on a date, or returns "" if none exists
func getSession(classID, date string) string {
	key := fmt.Sprintf("%s:%s", classID, date)

	sessionMutex.Lock()
	defer sessionMutex.Unlock()

	if bleID, exists := activeSessions[key]; exists {
		return bleID
	}
	return ""
}
