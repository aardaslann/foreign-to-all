extends RefCounted

# A deliberately gentle game clock, independent of play-time statistics and
# the computer's date. Fixed city offsets avoid seasonal/calendar promises.
const START := 330.0
const MINUTES_PER_SECOND := 0.6 # Forty active minutes per full day.
const MAX_MINUTES := 10000000.0
const CITIES := {
	"berlin": Vector3(52.5, 13.4, 60), "london": Vector3(51.5, -0.1, 0),
	"paris": Vector3(48.9, 2.4, 60), "istanbul": Vector3(41.0, 29.0, 180),
	"moscow": Vector3(55.8, 37.6, 180), "mumbai": Vector3(19.1, 72.9, 330),
	"tokyo": Vector3(35.7, 139.7, 540), "mexico": Vector3(19.4, -99.1, -360),
	"zurich": Vector3(47.4, 8.5, 60), "hanoi": Vector3(21.0, 105.8, 420),
	"rome": Vector3(41.9, 12.5, 60), "saopaulo": Vector3(-23.6, -46.6, -180),
	"dakar": Vector3(14.7, -17.5, 0), "tbilisi": Vector3(41.7, 44.8, 240),
	"seoul": Vector3(37.6, 127.0, 540), "lapaz": Vector3(-16.5, -68.1, -240),
	"sydney": Vector3(-33.9, 151.2, 600), "honolulu": Vector3(21.3, -157.9, -600),
	"newyork": Vector3(40.7, -74.0, -300), "toronto": Vector3(43.7, -79.4, -300),
}
const HOURS := [0.0, 5.0, 6.0, 8.0, 16.0, 18.0, 20.0, 22.0, 24.0]
const COLORS := [Color("667696"), Color("667696"), Color("bb9eaa"),
	Color.WHITE, Color.WHITE, Color("efc09b"), Color("a285ac"),
	Color("667696"), Color("667696")]


static func offset(city: String) -> float:
	return Vector3(CITIES.get(city, CITIES.berlin)).z - 60.0


static func local_minute(minutes: float, city: String) -> float:
	return fposmod(minutes + offset(city), 1440.0)


static func text_at(minutes: float, city: String) -> String:
	var minute := floori(local_minute(minutes, city) + 0.000001) % 1440
	return "%02d:%02d" % [minute / 60, minute % 60]


static func phase(minutes: float, city: String) -> String:
	var hour := local_minute(minutes, city) / 60.0
	if hour < 5.0 or hour >= 22.0: return "night"
	if hour < 8.0: return "dawn"
	if hour < 17.0: return "day"
	if hour < 20.0: return "sunset"
	return "night"


static func day_part(minutes: float, city: String) -> String:
	var hour := local_minute(minutes, city) / 60.0
	if hour < 6.0 or hour >= 22.0: return "night"
	if hour < 12.0: return "morning"
	if hour < 18.0: return "afternoon"
	return "evening"


static func tint(minutes: float, city: String, indoors: bool = false) -> Color:
	var hour := local_minute(minutes, city) / 60.0
	for i in range(HOURS.size() - 1):
		if hour >= HOURS[i + 1]: continue
		var weight := smoothstep(HOURS[i], HOURS[i + 1], hour)
		var sky: Color = COLORS[i].lerp(COLORS[i + 1], weight)
		# Electric light keeps services and reading comfortably visible.
		return sky.lerp(Color("fff4df"), 0.83) if indoors else sky
	return Color.WHITE


static func night_amount(minutes: float, city: String) -> float:
	return clampf((1.0 - tint(minutes, city).r) / 0.6, 0.0, 1.0)


static func next_hour(minutes: float, city: String, hour: int) -> float:
	var wait := fposmod(float(hour * 60) - local_minute(minutes, city), 1440.0)
	if wait < 0.000001: wait += 1440.0
	return minutes + wait


static func restore(value: Variant, legacy: String, city: String) -> float:
	if (value is float or value is int) and is_finite(float(value)):
		if float(value) >= 0.0 and float(value) <= MAX_MINUTES: return float(value)
	# A broken clock must never make an otherwise good journey unloadable.
	return (480.0 if legacy == "morning" else START) - offset(city) + 1440.0


static func flight_minutes(origin: String, destination: String) -> float:
	if origin == destination: return 0.0
	var a: Vector3 = CITIES.get(origin, CITIES.berlin)
	var b: Vector3 = CITIES.get(destination, CITIES.berlin)
	var lat_a := deg_to_rad(a.x)
	var lat_b := deg_to_rad(b.x)
	var arc := pow(sin((lat_b - lat_a) * 0.5), 2.0) + cos(lat_a) * cos(lat_b) * pow(sin(deg_to_rad(b.y - a.y) * 0.5), 2.0)
	var km := 12742.0 * asin(sqrt(clampf(arc, 0.0, 1.0)))
	# Approximate game travel, not airline schedules. Boarding is included.
	return maxf(90.0, ceilf((km / 800.0 + 1.0) * 2.0) * 30.0)
