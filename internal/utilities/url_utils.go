package utilities

import (
	"fmt"
	"net/url"
	"strings"
)

// SanitizeDatabaseURL properly encodes special characters in the database URL
func SanitizeDatabaseURL(rawURL string) string {
	// First check if the URL has the standard format
	if !strings.Contains(rawURL, "://") {
		return rawURL
	}

	// Split the URL into scheme and the rest to handle the parsing separately
	parts := strings.SplitN(rawURL, "://", 2)
	if len(parts) != 2 {
		return rawURL
	}

	scheme := parts[0]
	rest := parts[1]

	// Split the rest into credentials and host parts
	credentialsAndRest := strings.SplitN(rest, "@", 2)
	if len(credentialsAndRest) != 2 {
		return rawURL // No credentials part
	}

	credentials := credentialsAndRest[0]
	hostPart := credentialsAndRest[1]

	// Split credentials into username and password
	userAndPass := strings.SplitN(credentials, ":", 2)
	if len(userAndPass) != 2 {
		return rawURL // No password part
	}

	username := userAndPass[0]
	password := userAndPass[1]

	// URL encode the password while preserving special URL characters
	encodedPassword := url.QueryEscape(password)

	// Reconstruct the URL with encoded password
	return fmt.Sprintf("%s://%s:%s@%s", scheme, username, encodedPassword, hostPart)
}
