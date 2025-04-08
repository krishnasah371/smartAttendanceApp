package geogencing

// AllowedArea defines a geofence boundary (circle or polygon)
type AllowedArea struct {
	Type   string      `json:"type"`   // "circle" or "polygon"
	Center []float64   `json:"center"` // Only for circles: [lat, lon]
	Radius float64     `json:"radius"` // Only for circles
	Coords [][]float64 `json:"coords"` // Only for polygons
}
