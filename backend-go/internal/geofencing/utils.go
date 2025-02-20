package geogencing

import "math"

// HaversineDistance calculates the great-circle distance between two GPS coordinates
func HaversineDistance(lat1, lon1, lat2, lon2 float64) float64 {
	// Earth radius in meters
	const earthRadius = 6371000

	// Converts degree to randians
	lat1Rad := lat1 * (math.Pi / 180)
	lon1Rad := lon1 * (math.Pi / 180)
	lat2Rad := lat2 * (math.Pi / 180)
	lon2Rad := lon2 * (math.Pi / 180)

	dLat := lat2Rad - lat1Rad
	dLon := lon2Rad - lon1Rad

	a := math.Sin(dLat/2)*math.Sin(dLat/2) + math.Cos(lat1Rad)*math.Cos(lat2Rad)*math.Sin(dLon/2)*math.Sin(dLon/2)
	c := 2 * math.Atan2(math.Sqrt(a), math.Sqrt(1-a))

	distance := earthRadius * c
	return distance
}

// IsPointerInPolygon checks if a point (lat, lon) is inside a polygon using the Ray-Casting Algorithm.
func IsPointInPolygon(lat, lon float64, polygon [][]float64) bool {
	n := len(polygon)
	inside := false

	j := n - 1
	for i := 0; i < n; i++ {
		lat1, lon1 := polygon[i][0], polygon[i][1]
		lat2, lon2 := polygon[j][0], polygon[j][1]

		if ((lon1 > lon) != (lon2 > lon)) && (lat < (lat2-lat1)*(lon-lon1)/(lon2-lon1)+lat1) {
			inside = !inside
		}

		j = i
	}

	return inside
}
