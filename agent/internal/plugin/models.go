package plugin

// Manifest represents the structure of manifest.json for a plugin
type Manifest struct {
	ID          string   `json:"id"`
	Name        string   `json:"name"`
	Version     string   `json:"version"`
	Author      string   `json:"author"`
	Description string   `json:"description"`
	Entrypoint  string   `json:"entrypoint"`
	Permissions []string `json:"permissions"`
}

// Plugin holds the runtime state of a loaded plugin
type Plugin struct {
	Manifest Manifest `json:"manifest"`
	Dir      string   `json:"-"`
	IsActive bool     `json:"is_active"`
	Status   string   `json:"status"` // "loaded", "error"
}
