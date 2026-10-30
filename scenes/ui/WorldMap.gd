extends CanvasLayer

# The departures board, as a map.
#
# Every counter in this game hands the player a list. The airport is the one
# place where the thing being chosen is a PLACE, and a list of place names is
# exactly the wrong object — it is the alien reading words again. So the desk
# turns the board round and it is a map, and the player picks by pointing,
# which is how they have been communicating since the first scene.
#
# Drawn, not textured, in the same line-work language as the Karte in
# MapView.gd: dim fill, bright edges, one accent for you. It is a stylised
# world rather than an accurate one on purpose — the alien has never seen this
# planet from above, and this is the shape it has put together from airport
# walls and the backs of tickets.
#
# Opened by Services._airport_desk(). Emits `chosen` with a city id, or with
# "" when the player backs out, so the desk can `await` it exactly the way it
# already awaits a ChoicePanel.

signal chosen(city_id: String)

const BG_COLOR := Color(0.055, 0.048, 0.118, 0.98)
const BDR_CLR  := Color(0.30, 0.28, 0.50, 0.55)

const C_SEA    := Color(0.075, 0.068, 0.150)          # the ground of the map
const C_LAND   := Color(0.180, 0.170, 0.320, 0.55)
const C_COAST  := Color(0.62, 0.60, 0.92, 0.60)
const C_GRID   := Color(0.40, 0.38, 0.66, 0.13)
const C_LABEL  := Color(0.72, 0.70, 0.95, 0.72)
const C_DIM    := Color(0.50, 0.48, 0.72, 0.45)
const C_OPEN   := Color(0.24, 0.96, 0.80)             # a seat you can buy
const C_HERE   := Color(0.98, 0.82, 0.36)             # where you are standing
const C_SHUT   := Color(0.58, 0.40, 0.52)             # somewhere that will not have you yet
# The eight the game is actually about. Warm gold, the alien's own accent, so
# it cannot be confused with the teal that means "you can buy a seat".
const C_MUST   := Color(0.937, 0.749, 0.376)
const C_MUST_D := Color(0.502, 0.404, 0.204)          # one already finished

const MARKER_R := 5.0
const HIT_R    := 16.0

# Where each city is, in degrees. The projection is crude; these are not.
const CITY_POS := {
	"berlin":   Vector2(13.4, 52.5),
	"zurich":   Vector2(8.5, 47.4),
	"hanoi":    Vector2(105.9, 21.0),
	"london":   Vector2(-0.1, 51.5),
	"tokyo":    Vector2(139.7, 35.7),
	"rome":     Vector2(12.5, 41.9),
	"moscow":   Vector2(37.6, 55.8),
	"mexico":   Vector2(-99.1, 19.4),
	"saopaulo": Vector2(-46.6, -23.6),
	"dakar":    Vector2(-17.5, 14.7),
	"tbilisi":  Vector2(44.8, 41.7),
	"seoul":    Vector2(127.0, 37.6),
	"mumbai":   Vector2(72.9, 19.1),
	"istanbul": Vector2(29.0, 41.0),
	"lapaz":    Vector2(-68.2, -16.5),
	"paris":    Vector2(2.4, 48.9),    "sydney":   Vector2(151.2, -33.9),
	"honolulu": Vector2(-157.9, 21.3), "newyork":  Vector2(-74.0, 40.7),
	"toronto":  Vector2(-79.4, 43.7),
}

# The coastlines, in degrees of longitude and latitude, traced through
# named capes and river mouths. Simplified, but simplified from the real
# thing - the shape of a continent is how a player finds the city they
# are standing in without reading a word, which is the whole point of
# putting a map on the wall of an airport in a game about not being able
# to read.
#
# Every polygon here is verified free of self-intersection by
# .build/worldmap.py. Godot will not triangulate a crossed polygon.
const LANDS := [
	# Africa
	[Vector2(-5.9, 35.8), Vector2(-2, 35.2), Vector2(1, 36.5), 
		Vector2(5, 36.8), Vector2(8.2, 37.1), Vector2(10.2, 37), 
		Vector2(11, 35.5), Vector2(10.5, 34), Vector2(11.5, 33.2), 
		Vector2(15.2, 32.4), Vector2(18.5, 30.5), Vector2(20, 31), 
		Vector2(21.5, 32.9), Vector2(25, 32), Vector2(29, 31.2), 
		Vector2(32.3, 31.3), Vector2(34.2, 31.3), Vector2(34.5, 29.5), 
		Vector2(34.25, 27.7), Vector2(32.6, 29.95), Vector2(33.8, 27.25), 
		Vector2(35.5, 24), Vector2(37.2, 21), Vector2(38.6, 18), 
		Vector2(39.7, 15.6), Vector2(41.8, 13.5), Vector2(43.3, 12.7), 
		Vector2(44.5, 11.7), Vector2(47, 11), Vector2(51.3, 12), 
		Vector2(51, 10.5), Vector2(49.5, 8), Vector2(47.5, 5.5), Vector2(45, 3), 
		Vector2(43.2, 0.5), Vector2(41.5, -2), Vector2(40.2, -3.5), 
		Vector2(39.8, -6.5), Vector2(39.5, -8), Vector2(40.5, -10.5), 
		Vector2(40.7, -14.5), Vector2(40, -16.5), Vector2(36.9, -17.8), 
		Vector2(35, -20), Vector2(35.5, -22), Vector2(32.9, -25.9), 
		Vector2(31, -29.9), Vector2(28, -32.5), Vector2(25.7, -34), 
		Vector2(22, -34.1), Vector2(18.5, -34.4), Vector2(17.5, -32.5), 
		Vector2(15, -27), Vector2(14.5, -22.5), Vector2(11.8, -18), 
		Vector2(11.7, -17.3), Vector2(12.2, -15.2), Vector2(13.4, -12.6), 
		Vector2(13.2, -8.8), Vector2(12.3, -6), Vector2(9.4, 0.4), 
		Vector2(9.8, 1.9), Vector2(9.7, 4), Vector2(8.3, 4.8), Vector2(6, 4.3), 
		Vector2(3.4, 6.4), Vector2(2.4, 6.35), Vector2(-0.2, 5.5), 
		Vector2(-2.1, 4.75), Vector2(-4, 5.3), Vector2(-6.1, 4.95), 
		Vector2(-7.7, 4.4), Vector2(-10.8, 6.3), Vector2(-13.2, 8.5), 
		Vector2(-13.7, 9.5), Vector2(-15.6, 11.9), Vector2(-16.6, 13.5), 
		Vector2(-17.5, 14.7), Vector2(-16, 18.1), Vector2(-17, 21), 
		Vector2(-16, 23.7), Vector2(-13, 27.9), Vector2(-9.6, 30.4), 
		Vector2(-7.6, 33.6)],
	# Eurasia
	[Vector2(-5.6, 36), Vector2(-2.1, 36.7), Vector2(-0.5, 38.3), 
		Vector2(0.9, 40.7), Vector2(3.2, 41.9), Vector2(4.8, 43.4), 
		Vector2(7.5, 43.5), Vector2(8.9, 44.4), Vector2(10.3, 43.9), 
		Vector2(11.2, 42.4), Vector2(12.2, 41.7), Vector2(13.5, 41.2), 
		Vector2(14.3, 40.8), Vector2(15.3, 40), Vector2(15.9, 38.9), 
		Vector2(15.6, 38), Vector2(16.5, 38.9), Vector2(17.1, 39.4), 
		Vector2(16.6, 39.9), Vector2(17.3, 40.5), Vector2(18, 40.4), 
		Vector2(18.5, 40.1), Vector2(18.4, 41), Vector2(16.2, 41.9), 
		Vector2(15, 42), Vector2(14, 42.4), Vector2(13.5, 43.6), 
		Vector2(12.3, 44.5), Vector2(12.3, 45.4), Vector2(13.6, 45.7), 
		Vector2(14.5, 45.3), Vector2(15.2, 44.1), Vector2(16.4, 43.5), 
		Vector2(18.1, 42.6), Vector2(19.2, 42.1), Vector2(19.4, 41.3), 
		Vector2(20, 39.6), Vector2(20.8, 38.8), Vector2(21.3, 38.3), 
		Vector2(21.4, 37.6), Vector2(21.7, 36.8), Vector2(22.5, 36.4), 
		Vector2(23.2, 36.4), Vector2(23.1, 37.5), Vector2(23.7, 38), 
		Vector2(22.9, 39), Vector2(22.9, 40.6), Vector2(24.4, 40.9), 
		Vector2(25.9, 40.8), Vector2(26.4, 40.6), Vector2(26.7, 40.4), 
		Vector2(27.5, 40.6), Vector2(28.7, 40.9), Vector2(28.95, 41.02), 
		Vector2(29.1, 41.2), Vector2(28, 41.8), Vector2(27.5, 42.5), 
		Vector2(27.9, 43.2), Vector2(28.6, 44.2), Vector2(29.7, 45.2), 
		Vector2(30.7, 46.5), Vector2(31.9, 46.6), Vector2(32.5, 45.5), 
		Vector2(33.4, 45.4), Vector2(32.5, 45.3), Vector2(33.5, 44.6), 
		Vector2(34.2, 44.5), Vector2(35.4, 45), Vector2(36.6, 45.35), 
		Vector2(37.8, 44.7), Vector2(39.7, 43.6), Vector2(41, 43), 
		Vector2(41.7, 42.2), Vector2(41.6, 41.6), Vector2(40, 41.1), 
		Vector2(36.3, 41.3), Vector2(35.2, 42), Vector2(33, 41.9), 
		Vector2(31.4, 41.2), Vector2(29.9, 41.2), Vector2(29.15, 41.2), 
		Vector2(29.03, 40.99), Vector2(28.9, 40.7), Vector2(27.9, 40.4), 
		Vector2(27, 40.4), Vector2(26.7, 40.2), Vector2(26.2, 39.9), 
		Vector2(26.6, 39.3), Vector2(26.7, 38.8), Vector2(27, 38.4), 
		Vector2(26.7, 37.7), Vector2(27.4, 37), Vector2(28.2, 36.6), 
		Vector2(29.1, 36.2), Vector2(30.5, 36.3), Vector2(30.7, 36.9), 
		Vector2(32.8, 36.1), Vector2(34, 36.3), Vector2(36.2, 36.6), 
		Vector2(35.9, 35.9), Vector2(35.8, 35.5), Vector2(35.5, 34.4), 
		Vector2(35.5, 33.9), Vector2(35.1, 33.1), Vector2(34.8, 32.1), 
		Vector2(34.5, 31.6), Vector2(34.25, 31.3), Vector2(35, 29.55), 
		Vector2(34.9, 28), Vector2(38, 24.1), Vector2(39.2, 21.5), 
		Vector2(42.6, 16.9), Vector2(43.4, 12.6), Vector2(45, 12.8), 
		Vector2(49.1, 14.5), Vector2(54, 17), Vector2(59.8, 22.5), 
		Vector2(58.6, 23.6), Vector2(56.4, 25.5), Vector2(56.35, 26.4), 
		Vector2(55.3, 25.3), Vector2(54.4, 24.5), Vector2(51.6, 25.5), 
		Vector2(51.5, 24.6), Vector2(50.8, 25.5), Vector2(48.2, 29.3), 
		Vector2(48.6, 30), Vector2(50.8, 28.9), Vector2(54.9, 26.6), 
		Vector2(56.4, 27.15), Vector2(57, 26.7), Vector2(57.8, 25.6), 
		Vector2(60.6, 25.3), Vector2(62.3, 25.1), Vector2(67, 24.9), 
		Vector2(67.4, 24), Vector2(69.5, 22.5), Vector2(70, 21.5), 
		Vector2(70.9, 20.7), Vector2(72.6, 21), Vector2(72.8, 19.1), 
		Vector2(73.8, 15.5), Vector2(74.8, 12.9), Vector2(75.8, 11.2), 
		Vector2(76.3, 9.9), Vector2(77.5, 8.1), Vector2(79, 9.3), 
		Vector2(79.8, 10.3), Vector2(80.3, 13.1), Vector2(80.2, 15.9), 
		Vector2(83.3, 17.7), Vector2(85.8, 19.8), Vector2(87, 21.6), 
		Vector2(88.9, 21.7), Vector2(90.6, 22.2), Vector2(91.8, 22.3), 
		Vector2(92.3, 20.8), Vector2(94.2, 18), Vector2(94.5, 16), 
		Vector2(96.3, 16), Vector2(97.6, 16.5), Vector2(98, 14.8), 
		Vector2(98.6, 12), Vector2(98.8, 9), Vector2(98.3, 8), 
		Vector2(100.2, 6.5), Vector2(100.4, 5.4), Vector2(101, 2.8), 
		Vector2(103.8, 1.3), Vector2(104.2, 1.4), Vector2(103.5, 3.5), 
		Vector2(103, 5.5), Vector2(101.5, 6.4), Vector2(100.5, 7.2), 
		Vector2(100, 9.5), Vector2(100, 12.6), Vector2(100.6, 13.5), 
		Vector2(101.5, 12.6), Vector2(102.5, 12), Vector2(103.5, 10.6), 
		Vector2(104.8, 10.5), Vector2(104.8, 8.6), Vector2(106.6, 9.6), 
		Vector2(107.1, 10.4), Vector2(109.2, 12.2), Vector2(109.5, 13.8), 
		Vector2(108.2, 16.1), Vector2(107.1, 17), Vector2(106.5, 18.5), 
		Vector2(105.8, 19.8), Vector2(106.5, 20.5), Vector2(106.8, 20.8), 
		Vector2(108.1, 21.5), Vector2(109.5, 21.4), Vector2(110, 21.2), 
		Vector2(113.2, 22.2), Vector2(114.2, 22.3), Vector2(116.7, 23.4), 
		Vector2(119.3, 26.1), Vector2(121.6, 29.9), Vector2(121.9, 31.4), 
		Vector2(120.3, 34), Vector2(119.2, 35), Vector2(120.4, 36.1), 
		Vector2(122.7, 37.4), Vector2(121.4, 37.6), Vector2(119.1, 37.3), 
		Vector2(118, 38.2), Vector2(117.8, 39), Vector2(119, 39.3), 
		Vector2(121.3, 40.8), Vector2(122.2, 40.7), Vector2(121.6, 38.9), 
		Vector2(123.4, 39.7), Vector2(124.3, 39.9), Vector2(125.4, 39.6), 
		Vector2(126.4, 37.8), Vector2(126.5, 36.7), Vector2(126.3, 34.4), 
		Vector2(128, 34.8), Vector2(129.1, 35.1), Vector2(129.4, 36), 
		Vector2(129.4, 37.5), Vector2(128.4, 38.6), Vector2(127.5, 39.7), 
		Vector2(129.7, 40.7), Vector2(130.4, 42.4), Vector2(131.9, 43.1), 
		Vector2(137.5, 47), Vector2(140.5, 48.8), Vector2(141.4, 53), 
		Vector2(140.5, 54.5), Vector2(138.5, 55), Vector2(137, 56.5), 
		Vector2(142.5, 59), Vector2(150.8, 59.6), Vector2(154.5, 59.2), 
		Vector2(155.6, 57), Vector2(156.4, 54), Vector2(156.5, 51.3), 
		Vector2(158.6, 52.9), Vector2(162.5, 56.2), Vector2(163.3, 58), 
		Vector2(162, 60), Vector2(170, 60.6), Vector2(179.1, 62.3), 
		Vector2(177.5, 64.7), Vector2(180, 65.5), Vector2(180, 68.5), 
		Vector2(176, 69.5), Vector2(170, 70), Vector2(162, 69.7), 
		Vector2(152, 70.8), Vector2(141, 73), Vector2(130, 71.5), 
		Vector2(127, 73.5), Vector2(124, 73), Vector2(113, 73.5), 
		Vector2(112, 76), Vector2(105, 76.5), Vector2(104.3, 77.6), 
		Vector2(99, 76), Vector2(92, 75.5), Vector2(86, 73.5), Vector2(79, 73.5), 
		Vector2(73.5, 71.5), Vector2(68.5, 73), Vector2(66.5, 71), 
		Vector2(60, 69.5), Vector2(57, 68.5), Vector2(52, 68.6), 
		Vector2(43.3, 68.6), Vector2(40, 66.3), Vector2(40.5, 64.6), 
		Vector2(35, 64.5), Vector2(34.5, 66.5), Vector2(32.8, 67.1), 
		Vector2(33, 69), Vector2(31, 70), Vector2(25.8, 71.2), Vector2(19, 69.7), 
		Vector2(16, 68.8), Vector2(14.4, 67.3), Vector2(11, 64.5), 
		Vector2(8, 63.5), Vector2(5.3, 62), Vector2(5, 60.4), Vector2(5.7, 58.9), 
		Vector2(8, 58), Vector2(10.7, 59.9), Vector2(11.9, 57.7), 
		Vector2(12.8, 55.4), Vector2(13.9, 55.4), Vector2(15.6, 56.1), 
		Vector2(16.5, 56.7), Vector2(16.7, 57.8), Vector2(18.3, 59.4), 
		Vector2(17.2, 60.7), Vector2(20.3, 63.8), Vector2(22.2, 65.7), 
		Vector2(24.6, 65.7), Vector2(25.4, 65), Vector2(21.5, 63.1), 
		Vector2(21.5, 61.6), Vector2(22.2, 60.4), Vector2(25, 60.2), 
		Vector2(28.7, 60.7), Vector2(30.3, 59.9), Vector2(28, 59.4), 
		Vector2(24.7, 59.5), Vector2(24.5, 58.4), Vector2(24, 57), 
		Vector2(21, 56.5), Vector2(21.1, 55.7), Vector2(20.5, 54.7), 
		Vector2(18.7, 54.4), Vector2(14.3, 54), Vector2(12.1, 54.2), 
		Vector2(10.2, 54.4), Vector2(9.5, 54.8), Vector2(10.3, 56.2), 
		Vector2(10.6, 57.7), Vector2(8.2, 56.7), Vector2(8.4, 55.5), 
		Vector2(8.5, 54.9), Vector2(8.7, 53.9), Vector2(6.5, 53.4), 
		Vector2(4.7, 52.9), Vector2(4, 52), Vector2(3.5, 51.4), 
		Vector2(2.9, 51.2), Vector2(1.9, 51), Vector2(1, 49.9), 
		Vector2(0.2, 49.5), Vector2(-1.6, 49.7), Vector2(-2, 48.6), 
		Vector2(-4.8, 48.4), Vector2(-3.1, 47.5), Vector2(-2.2, 47.2), 
		Vector2(-1.2, 46.2), Vector2(-1.1, 45.6), Vector2(-1.2, 44.6), 
		Vector2(-1.6, 43.4), Vector2(-3, 43.4), Vector2(-5.7, 43.6), 
		Vector2(-8.4, 43.4), Vector2(-9.3, 42.9), Vector2(-8.7, 41.2), 
		Vector2(-9.4, 38.7), Vector2(-9, 37), Vector2(-7.9, 37), 
		Vector2(-6.9, 37.2), Vector2(-6.3, 36.5)],
	# North America
	[Vector2(-77.5, 8.5), Vector2(-79.5, 9), Vector2(-80.5, 8.3), 
		Vector2(-81.5, 8), Vector2(-83, 8.5), Vector2(-84, 9.6), 
		Vector2(-85.8, 11), Vector2(-87.5, 13), Vector2(-89.5, 13.5), 
		Vector2(-92, 14.5), Vector2(-95, 16), Vector2(-97.5, 16), 
		Vector2(-99.9, 16.8), Vector2(-103.5, 18.5), Vector2(-105.7, 20.5), 
		Vector2(-105.7, 22.5), Vector2(-106.4, 23.2), Vector2(-109, 25.6), 
		Vector2(-110.9, 27), Vector2(-113, 31), Vector2(-114.8, 31.8), 
		Vector2(-114.7, 31), Vector2(-113.5, 29), Vector2(-112, 27), 
		Vector2(-110.6, 24.5), Vector2(-109.4, 23.1), Vector2(-112, 24.5), 
		Vector2(-114.5, 27.5), Vector2(-115.9, 30.4), Vector2(-117.1, 32.5), 
		Vector2(-118.2, 33.7), Vector2(-120.6, 34.5), Vector2(-121.9, 36.6), 
		Vector2(-122.5, 37.8), Vector2(-124, 40.4), Vector2(-124.2, 43.3), 
		Vector2(-124, 46.3), Vector2(-124.7, 48.4), Vector2(-125.5, 50), 
		Vector2(-128, 52.5), Vector2(-131, 54.5), Vector2(-133, 56.5), 
		Vector2(-136, 58.5), Vector2(-140, 60), Vector2(-145, 60.2), 
		Vector2(-149.5, 60.5), Vector2(-152.5, 59), Vector2(-155, 58), 
		Vector2(-158, 56.5), Vector2(-162, 55), Vector2(-165, 54.5), 
		Vector2(-162, 58), Vector2(-161.8, 60.5), Vector2(-165, 61), 
		Vector2(-164, 63.5), Vector2(-160, 64.5), Vector2(-165.5, 65.5), 
		Vector2(-168, 65.7), Vector2(-166.8, 68.4), Vector2(-161, 70.5), 
		Vector2(-156.5, 71.4), Vector2(-148, 70.3), Vector2(-141, 69.6), 
		Vector2(-135, 69.5), Vector2(-128, 70), Vector2(-124.5, 69.5), 
		Vector2(-115, 68.5), Vector2(-108, 68), Vector2(-100, 68.5), 
		Vector2(-95, 68.5), Vector2(-93, 66), Vector2(-88, 65.5), 
		Vector2(-87, 65), Vector2(-93, 62.5), Vector2(-94.5, 59), 
		Vector2(-93, 57), Vector2(-88, 55.5), Vector2(-85, 55.3), 
		Vector2(-82.5, 55.2), Vector2(-82.3, 52.5), Vector2(-79.5, 51.5), 
		Vector2(-79, 53.5), Vector2(-78.5, 56.5), Vector2(-77.5, 59.5), 
		Vector2(-77.7, 62), Vector2(-74, 62.5), Vector2(-70, 61.8), 
		Vector2(-69.7, 60), Vector2(-68, 58.5), Vector2(-65.5, 59.5), 
		Vector2(-64.5, 60.4), Vector2(-64, 58.5), Vector2(-61.5, 57), 
		Vector2(-60, 55), Vector2(-57, 54), Vector2(-56.6, 51.4), 
		Vector2(-61, 50.2), Vector2(-66, 49.5), Vector2(-68.5, 48.6), 
		Vector2(-65.5, 48), Vector2(-65, 47), Vector2(-64, 46.2), 
		Vector2(-61, 45.6), Vector2(-59.9, 45.6), Vector2(-62, 44.5), 
		Vector2(-64.5, 43.5), Vector2(-66.1, 43.7), Vector2(-66.9, 44.8), 
		Vector2(-67.8, 44.9), Vector2(-69, 44), Vector2(-70.2, 43.6), 
		Vector2(-70, 41.8), Vector2(-72, 41.3), Vector2(-74, 40.6), 
		Vector2(-74.9, 38.9), Vector2(-75.4, 38), Vector2(-75.9, 37.1), 
		Vector2(-75.5, 35.2), Vector2(-78.9, 33.7), Vector2(-80.9, 32.1), 
		Vector2(-81.4, 30.3), Vector2(-80.1, 26.7), Vector2(-80.2, 25.2), 
		Vector2(-81.2, 25.2), Vector2(-82.7, 27.7), Vector2(-83.7, 29.7), 
		Vector2(-85, 29.7), Vector2(-88, 30.3), Vector2(-89.4, 29.1), 
		Vector2(-91.5, 29.3), Vector2(-94.8, 29.4), Vector2(-97.2, 26), 
		Vector2(-97.5, 22.5), Vector2(-96, 19.2), Vector2(-94.5, 18.2), 
		Vector2(-91.5, 18.6), Vector2(-90.5, 21), Vector2(-87, 21.6), 
		Vector2(-87, 18.5), Vector2(-88.2, 15.9), Vector2(-83.2, 15), 
		Vector2(-83.5, 12.5), Vector2(-82.8, 9.5), Vector2(-79, 9.4)],
	# South America
	[Vector2(-77.4, 8.5), Vector2(-76.9, 8), Vector2(-75.5, 9.4), 
		Vector2(-74.9, 11), Vector2(-72.2, 11.8), Vector2(-71.3, 12.4), 
		Vector2(-71.6, 10.9), Vector2(-70.2, 11.5), Vector2(-68, 10.5), 
		Vector2(-66, 10.6), Vector2(-63, 10.6), Vector2(-61.5, 10.7), 
		Vector2(-60.5, 9), Vector2(-58, 7), Vector2(-56, 5.8), 
		Vector2(-52.5, 4.9), Vector2(-51, 4), Vector2(-50, 0.5), 
		Vector2(-47.5, -0.6), Vector2(-44.3, -2.5), Vector2(-41.5, -2.8), 
		Vector2(-38.5, -3.7), Vector2(-35.5, -5.2), Vector2(-34.8, -7.1), 
		Vector2(-35, -8.1), Vector2(-37, -10.9), Vector2(-38.5, -13), 
		Vector2(-39, -16), Vector2(-40.3, -20.3), Vector2(-42, -22.9), 
		Vector2(-43.2, -23), Vector2(-45.5, -23.8), Vector2(-46.4, -24), 
		Vector2(-48.5, -25.5), Vector2(-50, -28.5), Vector2(-51.2, -30), 
		Vector2(-52.5, -32.5), Vector2(-53.5, -34), Vector2(-56.2, -34.9), 
		Vector2(-58.4, -34.6), Vector2(-57.5, -36), Vector2(-56.7, -38.5), 
		Vector2(-62, -39), Vector2(-62.3, -40.9), Vector2(-65, -41), 
		Vector2(-63.8, -42.5), Vector2(-65.3, -45), Vector2(-67.5, -46), 
		Vector2(-67.6, -49.3), Vector2(-68.8, -52.3), Vector2(-68.5, -54.9), 
		Vector2(-70.5, -54.9), Vector2(-71.5, -53.8), Vector2(-74.5, -50), 
		Vector2(-75.5, -47), Vector2(-73.8, -42), Vector2(-73.5, -37), 
		Vector2(-71.6, -33), Vector2(-70.7, -30), Vector2(-70.4, -23.5), 
		Vector2(-70.2, -18.5), Vector2(-71.3, -17.6), Vector2(-72, -17), 
		Vector2(-75.2, -15.2), Vector2(-76.2, -13.8), Vector2(-77.1, -12), 
		Vector2(-78.6, -9.1), Vector2(-79, -8.1), Vector2(-81, -5.2), 
		Vector2(-81.3, -4.7), Vector2(-80.4, -3.5), Vector2(-80.9, -2.2), 
		Vector2(-80.7, -1), Vector2(-79.7, 1), Vector2(-78.8, 1.8), 
		Vector2(-77.1, 3.9), Vector2(-77.4, 6)],
	# Greenland
	[Vector2(-45, 60), Vector2(-52.5, 65), Vector2(-53.5, 68.5), 
		Vector2(-55.5, 70.5), Vector2(-55, 73.5), Vector2(-58, 75.5), 
		Vector2(-63, 76.5), Vector2(-68, 77), Vector2(-70, 78.5), 
		Vector2(-66, 80.5), Vector2(-60, 82), Vector2(-45, 83.5), 
		Vector2(-30, 83), Vector2(-20, 81.5), Vector2(-18, 79), Vector2(-21, 76), 
		Vector2(-20, 74), Vector2(-22, 71.5), Vector2(-24.5, 70), 
		Vector2(-28, 68), Vector2(-32, 67), Vector2(-38, 65.5), Vector2(-42, 62.5)],
	# Iceland
	[Vector2(-22.5, 64), Vector2(-24.5, 65.5), Vector2(-22, 66.5), 
		Vector2(-18, 66.2), Vector2(-15, 66.4), Vector2(-13.6, 65.5), 
		Vector2(-14.5, 64.3), Vector2(-18, 63.4), Vector2(-20.5, 63.4), 
		Vector2(-22.7, 63.8)],
	# Great Britain
	[Vector2(-5.7, 50.1), Vector2(-3.5, 50.6), Vector2(-1.4, 50.7), 
		Vector2(0.7, 50.8), Vector2(1.7, 52.8), Vector2(0.3, 53.5), 
		Vector2(-1.2, 54.6), Vector2(-1.4, 55), Vector2(-2, 55.8), 
		Vector2(-3, 56.1), Vector2(-2.1, 57.1), Vector2(-3.5, 57.7), 
		Vector2(-3, 58.6), Vector2(-5, 58.6), Vector2(-5.8, 57.5), 
		Vector2(-5.6, 56.6), Vector2(-5.6, 55.3), Vector2(-4.5, 54.8), 
		Vector2(-3, 53.4), Vector2(-4.1, 53.3), Vector2(-4.7, 52.8), 
		Vector2(-5.3, 51.9), Vector2(-4.2, 51.6), Vector2(-3, 51.4), 
		Vector2(-4.2, 51.1), Vector2(-5.2, 51)],
	# Ireland
	[Vector2(-6.3, 52.3), Vector2(-8.5, 51.6), Vector2(-10.4, 52.1), 
		Vector2(-9.7, 52.6), Vector2(-9.9, 53.2), Vector2(-10.1, 54), 
		Vector2(-8.4, 54.5), Vector2(-7.4, 55.4), Vector2(-5.8, 54.9), 
		Vector2(-5.5, 54.5), Vector2(-6.3, 54), Vector2(-6.1, 53.4), 
		Vector2(-6, 52.8)],
	# Newfoundland
	[Vector2(-59.4, 47.6), Vector2(-56.8, 46.7), Vector2(-52.7, 47.5), 
		Vector2(-52.6, 48.5), Vector2(-55.5, 51.5), Vector2(-56.8, 51.4), 
		Vector2(-58.8, 49.5)],
	# Cuba
	[Vector2(-84.95, 21.9), Vector2(-82.4, 23.2), Vector2(-80.5, 23.2), 
		Vector2(-77.2, 21.6), Vector2(-74.5, 20.4), Vector2(-75.2, 19.9), 
		Vector2(-77.7, 19.85), Vector2(-80.4, 22.15), Vector2(-83, 22.2)],
	# Hispaniola
	[Vector2(-74.5, 18.5), Vector2(-71.7, 19.9), Vector2(-68.3, 19), 
		Vector2(-68.4, 18.2), Vector2(-71.7, 18.2)],
	# Japan
	[Vector2(130.2, 32.6), Vector2(130.9, 31), Vector2(131.5, 31.4), 
		Vector2(132, 33.3), Vector2(133.5, 33.3), Vector2(134.6, 33.5), 
		Vector2(135.9, 33.5), Vector2(136.9, 34.7), Vector2(138.3, 34.6), 
		Vector2(139.6, 35), Vector2(140.8, 35.7), Vector2(140.9, 38.3), 
		Vector2(141.5, 40.5), Vector2(141.5, 41.4), Vector2(140.4, 41.2), 
		Vector2(140, 39.9), Vector2(139.7, 38.9), Vector2(139, 37.9), 
		Vector2(137.2, 37.5), Vector2(136.6, 36.6), Vector2(135.5, 35.6), 
		Vector2(133, 35.5), Vector2(131, 34.4), Vector2(130.9, 33.9)],
	# Hokkaido
	[Vector2(140.8, 41.8), Vector2(143.2, 41.9), Vector2(144.4, 43), 
		Vector2(145.6, 43.3), Vector2(145.3, 44.3), Vector2(144.3, 44), 
		Vector2(141.7, 45.5), Vector2(141.7, 44), Vector2(141, 43.2), 
		Vector2(140.1, 42.3)],
	# Sakhalin
	[Vector2(142, 46), Vector2(143.5, 46.5), Vector2(143.3, 49.5), 
		Vector2(144.7, 51.5), Vector2(142.8, 54.4), Vector2(141.7, 53.3), 
		Vector2(142.1, 51), Vector2(141.8, 48)],
	# Taiwan
	[Vector2(120.1, 23), Vector2(120.9, 21.9), Vector2(121.5, 22.6), 
		Vector2(121.9, 24.5), Vector2(121.6, 25.3), Vector2(120.6, 24.3)],
	# Hainan
	[Vector2(108.6, 19.9), Vector2(110.1, 20.1), Vector2(111, 19.6), 
		Vector2(110.5, 18.2), Vector2(108.9, 18.5)],
	# Sri Lanka
	[Vector2(79.8, 9.4), Vector2(81.2, 8.5), Vector2(81.9, 7.2), 
		Vector2(81.7, 6), Vector2(80.2, 5.9), Vector2(79.7, 7.5)],
	# Sumatra
	[Vector2(95.3, 5.6), Vector2(98.7, 3.8), Vector2(100.4, 2.1), 
		Vector2(103.5, 1), Vector2(104.6, -1), Vector2(106, -2.5), 
		Vector2(105.9, -5.9), Vector2(104.6, -5.9), Vector2(102.3, -4.3), 
		Vector2(100.3, -2.3), Vector2(98.5, 0.2)],
	# Java
	[Vector2(105.2, -6), Vector2(108.5, -6.2), Vector2(112.7, -6.9), 
		Vector2(114.4, -8.2), Vector2(112.5, -8.4), Vector2(108, -7.7), 
		Vector2(105.5, -6.9)],
	# Borneo
	[Vector2(109, 1.6), Vector2(109.3, 0), Vector2(110, -1.7), 
		Vector2(112.9, -3.4), Vector2(114.6, -3.9), Vector2(116.3, -3.6), 
		Vector2(117.5, -1), Vector2(118.6, 0.9), Vector2(117.6, 4.2), 
		Vector2(117, 6.9), Vector2(116.1, 6), Vector2(113, 4.5), 
		Vector2(111, 2.8), Vector2(110.3, 1.6)],
	# Sulawesi
	[Vector2(119.4, -5.4), Vector2(120.4, -5.4), Vector2(120.8, -3), 
		Vector2(122.6, -3.2), Vector2(123.2, -4.6), Vector2(124, -4.4), 
		Vector2(122.9, -2.9), Vector2(121.5, -1.9), Vector2(123, -0.7), 
		Vector2(125.2, 1.5), Vector2(124, 1), Vector2(121.3, -0.9), 
		Vector2(120.2, -0.4), Vector2(120, 1), Vector2(119.8, 0.8), 
		Vector2(119.4, -1), Vector2(118.9, -3.5)],
	# New Guinea
	[Vector2(130.9, -1.5), Vector2(132.5, -0.4), Vector2(134.5, -0.9), 
		Vector2(136, -2), Vector2(138, -1.8), Vector2(141, -2.6), 
		Vector2(143.5, -3.5), Vector2(145.8, -4.9), Vector2(147.5, -6), 
		Vector2(150.8, -10.2), Vector2(148, -9.5), Vector2(145, -8), 
		Vector2(143.5, -8.5), Vector2(141, -8), Vector2(138, -8.3), 
		Vector2(135.5, -5.5), Vector2(133.5, -4), Vector2(132.5, -2.8)],
	# Luzon
	[Vector2(119.8, 16.3), Vector2(120.6, 18.5), Vector2(122.2, 18.5), 
		Vector2(122.3, 17), Vector2(122, 14.5), Vector2(121.6, 13.8), 
		Vector2(120.6, 13.8), Vector2(120, 14.8)],
	# Mindanao
	[Vector2(121.9, 8.2), Vector2(123, 9.9), Vector2(124.8, 9), 
		Vector2(126.6, 9.3), Vector2(126.2, 7), Vector2(125.7, 5.6), 
		Vector2(124.2, 6.2), Vector2(123.3, 7.3)],
	# Australia
	[Vector2(114, -22), Vector2(113.2, -25.5), Vector2(114.6, -28.8), 
		Vector2(115.7, -32), Vector2(115, -34.4), Vector2(117.9, -35.1), 
		Vector2(123, -34), Vector2(129, -31.7), Vector2(134, -32.5), 
		Vector2(136, -35), Vector2(137.8, -35), Vector2(138.5, -35.6), 
		Vector2(140, -38), Vector2(143.5, -38.9), Vector2(146.4, -39.1), 
		Vector2(150, -37.5), Vector2(151.3, -33.9), Vector2(153, -30.5), 
		Vector2(153.5, -28.2), Vector2(152.5, -24.9), Vector2(149.5, -22.5), 
		Vector2(147, -19.2), Vector2(145.8, -17), Vector2(142.5, -10.7), 
		Vector2(141.6, -12.5), Vector2(139.5, -17), Vector2(136.5, -16), 
		Vector2(135.5, -12), Vector2(132.5, -12), Vector2(130.8, -12.4), 
		Vector2(129, -15), Vector2(127, -14), Vector2(123.5, -16.5), 
		Vector2(121, -19.5), Vector2(117, -20.6)],
	# Tasmania
	[Vector2(145, -40.7), Vector2(148.3, -40.8), Vector2(148.3, -42.6), 
		Vector2(146.9, -43.6), Vector2(145.4, -43), Vector2(144.7, -41.2)],
	# New Zealand north
	[Vector2(172.7, -34.5), Vector2(174.3, -36.9), Vector2(174.8, -38), 
		Vector2(174, -39.2), Vector2(175, -40), Vector2(174.8, -41.3), 
		Vector2(175.3, -41.6), Vector2(176.9, -39.5), Vector2(178.5, -37.7), 
		Vector2(176.5, -37.5), Vector2(175.5, -36.5), Vector2(174.6, -35.5), 
		Vector2(173, -34.4)],
	# New Zealand south
	[Vector2(172.7, -40.5), Vector2(174.3, -41.3), Vector2(173.7, -42.4), 
		Vector2(172.8, -43.5), Vector2(173.1, -43.9), Vector2(171.2, -44.9), 
		Vector2(170.6, -45.9), Vector2(168.4, -46.6), Vector2(166.5, -45.9), 
		Vector2(166.5, -45), Vector2(168.5, -43.9), Vector2(170.9, -42.8), 
		Vector2(171.6, -41.8)],
	# Madagascar
	[Vector2(49.5, -12.3), Vector2(50.5, -15.5), Vector2(49.8, -17), 
		Vector2(47.5, -24.9), Vector2(45.2, -25.6), Vector2(43.3, -22.3), 
		Vector2(43.5, -19), Vector2(46.3, -15.7), Vector2(48.3, -13.5)],
]


# Water that sits inside a landmass. A Godot polygon cannot have a hole
# in it, so these are painted back over the land afterwards - which is
# also how you would do it with ink.
const SEAS := [
	# Caspian
	[Vector2(46.7, 44.5), Vector2(49, 44.7), Vector2(51.3, 44.5), 
		Vector2(52.5, 42), Vector2(54, 41.5), Vector2(53.5, 39.5), 
		Vector2(52.5, 38), Vector2(50, 37), Vector2(48.5, 37.5), 
		Vector2(49.5, 40), Vector2(51, 41.5), Vector2(48, 42.5), 
		Vector2(47.5, 43.5)],
	# Superior
	[Vector2(-92, 46.7), Vector2(-90.5, 46.6), Vector2(-87, 46.5), 
		Vector2(-84.5, 46.5), Vector2(-84.8, 47), Vector2(-88, 48.5), 
		Vector2(-91, 48.1)],
	# Michigan
	[Vector2(-87.9, 41.6), Vector2(-86.2, 41.7), Vector2(-86.2, 44), 
		Vector2(-85, 45.8), Vector2(-85.5, 46), Vector2(-87.8, 45.4), 
		Vector2(-88, 43)],
	# Huron
	[Vector2(-84.5, 43.5), Vector2(-82.5, 43), Vector2(-81.7, 45), 
		Vector2(-80, 46), Vector2(-83, 46.1), Vector2(-84.5, 45.6)],
	# Erie and Ontario
	[Vector2(-83.4, 41.7), Vector2(-79, 42.4), Vector2(-76.2, 43.3), 
		Vector2(-76.5, 44.1), Vector2(-79.5, 43.9), Vector2(-82.5, 42.9)],
]


var _ui_root:    Control
var _panel_root: Control
var _canvas:     Control
var _title:      Label
var _sub:        Label
var _t:          float = 0.0
var _hover:      String = ""
var _open:       bool = false

# city id -> {"ok": bool, "note": String}. Handed in by the desk, so the map
# never has to know a rule — it draws what it is told.
var _routes: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("world_map")
	_ui_root = $UIRoot
	_build_ui()


func _process(delta: float) -> void:
	if _open:
		_t += delta
		_canvas.queue_redraw()


# ── The one call the desk makes ───────────────────────────────────────────────

func open(routes: Dictionary, fare_text: String) -> void:
	_routes = routes
	_hover = ""
	_open = true
	# The board has to say what the gold means. A colour nobody explains is a
	# colour that means nothing, and eight of twenty cities being load-bearing
	# is not something a player should have to infer.
	var left: int = Story.MANDATORY.size() - Story.holidays_done()
	var note: String = ""
	if left > 0:
		note = "
●  the eight ringed in gold are the ones you have to " 			+ "understand.  %d to go." % left
	else:
		note = "
●  all eight understood.  there is a field outside Berlin."
	_sub.text = fare_text + note
	_panel_root.show()
	get_tree().paused = true
	_canvas.queue_redraw()


func _close(pick: String) -> void:
	_open = false
	_panel_root.hide()
	get_tree().paused = false
	chosen.emit(pick)


func _unhandled_input(event: InputEvent) -> void:
	if not _open:
		return
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close("")
	elif event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right") or event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down"):
		get_viewport().set_input_as_handled()
		var available: Array = []
		for city: String in Story.MANDATORY:
			if bool(_routes.get(city, {}).get("ok", false)):
				available.append(city)
		if not available.is_empty():
			var direction: int = -1 if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_up") else 1
			_hover = available[posmod(available.find(_hover) + direction, available.size())]
			_canvas.queue_redraw()
	elif event.is_action_pressed("ui_accept") and bool(_routes.get(_hover, {}).get("ok", false)):
		get_viewport().set_input_as_handled()
		_close(_hover)


# ── Projection ────────────────────────────────────────────────────────────────
# Equirectangular, cropped to the band the cities actually live in so the map
# is not four fifths empty ocean. Antarctica is not on the itinerary.

const LON_MIN := -170.0
const LON_MAX := 180.0
const LAT_MIN := -56.0
const LAT_MAX := 78.0


func _project(deg: Vector2) -> Vector2:
	var s: Vector2 = _canvas.size
	var u: float = (deg.x - LON_MIN) / (LON_MAX - LON_MIN)
	var v: float = (LAT_MAX - deg.y) / (LAT_MAX - LAT_MIN)
	return Vector2(u * s.x, v * s.y)


# ── Drawing ───────────────────────────────────────────────────────────────────

func _draw_world() -> void:
	var s: Vector2 = _canvas.size
	_canvas.draw_rect(Rect2(Vector2.ZERO, s), C_SEA)

	# A real graticule — meridians every 30°, parallels every 20°, with the
	# equator picked out. Lines that stand for something are worth more on a
	# map than lines that only cut the paper into equal pieces.
	for lon in range(-180, 181, 30):
		var dx: float = float(lon)
		if dx < LON_MIN or dx > LON_MAX:
			continue
		var x: float = _project(Vector2(dx, 0.0)).x
		_canvas.draw_line(Vector2(x, 0.0), Vector2(x, s.y), C_GRID, 1.0)
	for lat in range(-40, 81, 20):
		var dy: float = float(lat)
		if dy < LAT_MIN or dy > LAT_MAX:
			continue
		var y: float = _project(Vector2(0.0, dy)).y
		var c: Color = C_GRID
		if lat == 0:
			c = Color(C_GRID.r, C_GRID.g, C_GRID.b, C_GRID.a * 2.4)
		_canvas.draw_line(Vector2(0.0, y), Vector2(s.x, y), c, 1.0)

	for land in LANDS:
		_ink(land, C_LAND)
	# Inland water goes on last, over the land it sits inside.
	for sea in SEAS:
		_ink(sea, C_SEA)


# One polygon: filled, then walked round again in its own coastline.
func _ink(poly: Array, fill: Color) -> void:
	var pts := PackedVector2Array()
	for d: Vector2 in poly:
		pts.append(_project(d))
	if pts.size() < 3:
		return
	_canvas.draw_colored_polygon(pts, fill)
	var closed := pts.duplicate()
	closed.append(pts[0])
	_canvas.draw_polyline(closed, C_COAST, 1.4, true)


func _draw_map() -> void:
	_draw_world()
	# Routes first, so a marker never sits under a line.
	var here: String = GameState.city
	if CITY_POS.has(here):
		var origin: Vector2 = _project(CITY_POS[here])
		for id: String in _routes.keys():
			if not CITY_POS.has(id):
				continue
			var row: Dictionary = _routes[id]
			if not bool(row.get("ok", false)):
				continue
			_draw_route(origin, _project(CITY_POS[id]))

	for id: String in CITY_POS.keys():
		_draw_marker(String(id))
	_draw_tooltip()


# A flight path, bowed the way every seat-back screen draws one.
func _draw_route(a: Vector2, b: Vector2) -> void:
	var mid: Vector2 = (a + b) * 0.5
	var away: Vector2 = (b - a).orthogonal().normalized()
	if away.y > 0.0:
		away = -away
	mid += away * (a.distance_to(b) * 0.16)
	var pts := PackedVector2Array()
	for i in range(17):
		var u: float = float(i) / 16.0
		pts.append(a.lerp(mid, u).lerp(mid.lerp(b, u), u))
	var pulse: float = 0.10 + 0.06 * sin(_t * 2.0)
	_canvas.draw_polyline(pts, Color(C_OPEN.r, C_OPEN.g, C_OPEN.b, pulse), 1.6, true)


func _draw_marker(id: String) -> void:
	var p: Vector2 = _project(CITY_POS[id])
	var here: bool = (id == GameState.city)
	var row: Dictionary = _routes.get(id, {})
	var ok: bool = bool(row.get("ok", false))

	var must: bool = Story.is_mandatory(id)
	var done: bool = must and Story.holiday_seen(id)

	var col: Color = C_SHUT
	if here:
		col = C_HERE
	elif ok:
		col = C_OPEN
	elif row.is_empty():
		col = C_DIM
	# One of the eight, and not finished: it says so before anything else
	# does. A city you have already been let into goes back to being a place.
	if must and not here:
		col = C_MUST_D if done else C_MUST

	# A ring standing off the marker, so the eight are findable at a glance
	# on a map of twenty.
	if must and not done:
		var halo: float = 0.34 + 0.20 * sin(_t * 1.9 + p.x * 0.04)
		_canvas.draw_arc(p, MARKER_R + 8.0, 0, TAU, 26,
			Color(C_MUST.r, C_MUST.g, C_MUST.b, halo), 2.0)

	if here:
		# You are not a destination. You are the dot the lines come out of.
		var pulse: float = 5.0 + sin(_t * 2.6) * 1.8
		_canvas.draw_arc(p, pulse + 5.0, 0, TAU, 22,
			Color(col.r, col.g, col.b, 0.40), 1.5)
	elif ok:
		var breathe: float = 0.30 + 0.22 * sin(_t * 2.2 + p.x * 0.05)
		_canvas.draw_arc(p, MARKER_R + 5.0, 0, TAU, 20,
			Color(col.r, col.g, col.b, breathe), 1.4)

	if _hover == id:
		_canvas.draw_arc(p, MARKER_R + 9.0, 0, TAU, 24, col, 1.8)
	_canvas.draw_circle(p, MARKER_R + 1.6, Color(0.05, 0.045, 0.10, 0.9))
	_canvas.draw_circle(p, MARKER_R, col)
	if not ok and not here:
		# A shut route reads as a crossed-through dot, not merely a dim one.
		_canvas.draw_line(p + Vector2(-3.4, -3.4), p + Vector2(3.4, 3.4),
			Color(0.05, 0.045, 0.10, 0.85), 1.6)


# What the player is pointing at, and where they stand with it.
func _draw_tooltip() -> void:
	if _hover.is_empty() or not CITY_POS.has(_hover):
		return
	var font: Font = ThemeDB.fallback_font
	var info: Dictionary = GameState.CITIES.get(_hover, {})
	var title: String = "%s, %s" % [String(info.get("name", "Somewhere")),
		String(info.get("country", ""))]
	var standing: String = "you have never been"
	if _visited(_hover):
		standing = "there, you are %s" % GameState.city_rep_level(_hover)
	var row: Dictionary = _routes.get(_hover, {})
	var note: String = String(row.get("note", ""))

	var lines: Array = [title, standing]
	if not note.is_empty():
		lines.append(note)
	var w: float = 0.0
	for i in range(lines.size()):
		var fs: int = 15 if i == 0 else 12
		var sz: Vector2 = font.get_string_size(String(lines[i]),
			HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
		w = maxf(w, sz.x)
	w += 24.0
	var h: float = 30.0 + float(lines.size() - 1) * 17.0

	var p: Vector2 = _project(CITY_POS[_hover])
	var box := Rect2(p + Vector2(14.0, -h * 0.5), Vector2(w, h))
	# Keep it on the canvas rather than half off the eastern edge.
	if box.end.x > _canvas.size.x - 6.0:
		box.position.x = p.x - w - 14.0
	box.position.y = clampf(box.position.y, 4.0, maxf(4.0, _canvas.size.y - h - 4.0))

	_canvas.draw_rect(box.grow(3.0), Color(0.05, 0.045, 0.10, 0.92))
	_canvas.draw_rect(box, Color(0.10, 0.09, 0.19, 0.96))
	_canvas.draw_rect(box, C_COAST, false, 1.2)
	_canvas.draw_string(font, box.position + Vector2(12.0, 19.0), title,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(0.96, 0.94, 1.0))
	for i in range(1, lines.size()):
		_canvas.draw_string(font,
			box.position + Vector2(12.0, 19.0 + float(i) * 17.0),
			String(lines[i]), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, C_LABEL)


# Berlin counts as visited from the first frame, because the player woke up in
# a field outside it.
func _visited(id: String) -> bool:
	if id == GameState.city:
		return true
	return bool(GameState.world_flags.get("visited_" + id, false))


# ── Pointing ──────────────────────────────────────────────────────────────────

func _on_canvas_input(event: InputEvent) -> void:
	if not _open:
		return
	if event is InputEventMouseMotion:
		var was: String = _hover
		_hover = _nearest((event as InputEventMouseMotion).position)
		if _hover != was:
			_canvas.queue_redraw()
		return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if not mb.pressed or mb.button_index != MOUSE_BUTTON_LEFT:
			return
		var id: String = _nearest(mb.position)
		if id.is_empty() or id == GameState.city:
			return
		if not bool(_routes.get(id, {}).get("ok", false)):
			return
		_close(id)


func _nearest(local: Vector2) -> String:
	var best: String = ""
	var best_d: float = HIT_R
	for id: String in CITY_POS.keys():
		var d: float = _project(CITY_POS[id]).distance_to(local)
		if d < best_d:
			best_d = d
			best = String(id)
	return best


# ── Panel ─────────────────────────────────────────────────────────────────────

func _build_ui() -> void:
	_panel_root = Control.new()
	_panel_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui_root.add_child(_panel_root)

	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.58)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_panel_root.add_child(overlay)

	var panel := Panel.new()
	panel.anchor_left = 0.06
	panel.anchor_right = 0.94
	panel.anchor_top = 0.08
	panel.anchor_bottom = 0.92
	var sb := StyleBoxFlat.new()
	sb.bg_color     = BG_COLOR
	sb.border_color = BDR_CLR
	sb.border_width_left = 1
	sb.border_width_right = 1
	sb.border_width_top = 1
	sb.border_width_bottom = 1
	sb.set_corner_radius_all(16)
	sb.shadow_color = Color(0, 0, 0, 0.50)
	sb.shadow_size  = 22
	panel.add_theme_stylebox_override("panel", sb)
	_panel_root.add_child(panel)

	var outer := MarginContainer.new()
	outer.set_anchors_preset(Control.PRESET_FULL_RECT)
	for k in ["left", "right"]:
		outer.add_theme_constant_override("margin_" + k, 34)
	outer.add_theme_constant_override("margin_top", 26)
	outer.add_theme_constant_override("margin_bottom", 20)
	panel.add_child(outer)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	outer.add_child(vbox)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	var deco := Label.new()
	deco.text = "✈  "
	deco.add_theme_font_size_override("font_size", 20)
	deco.add_theme_color_override("font_color", Color(0.55, 0.52, 0.85, 0.55))
	deco.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	header.add_child(deco)
	_title = Label.new()
	_title.text = "Where to"
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title.add_theme_font_size_override("font_size", 28)
	_title.add_theme_color_override("font_color", Color(0.96, 0.94, 1.00))
	header.add_child(_title)
	var close_btn := Button.new()
	close_btn.text = "×  not today"
	close_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	UIStyles.style_menu_btn(close_btn)
	close_btn.pressed.connect(func(): _close(""))
	header.add_child(close_btn)
	vbox.add_child(header)

	_sub = Label.new()
	_sub.add_theme_font_size_override("font_size", 14)
	_sub.add_theme_color_override("font_color", Color(0.44, 0.42, 0.68, 0.85))
	vbox.add_child(_sub)

	var div := MarginContainer.new()
	div.add_theme_constant_override("margin_top", 8)
	div.add_theme_constant_override("margin_bottom", 6)
	var line := ColorRect.new()
	line.color = Color(0.28, 0.26, 0.46, 0.40)
	line.custom_minimum_size = Vector2(0, 1)
	div.add_child(line)
	vbox.add_child(div)

	_canvas = Control.new()
	_canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	# Greenland and the Arctic run off the top of the sheet. Crop them at
	# the frame the way any wall map does, rather than letting the coast
	# spill over the panel around it.
	_canvas.clip_contents = true
	_canvas.mouse_filter = Control.MOUSE_FILTER_STOP
	_canvas.draw.connect(_draw_map)
	_canvas.gui_input.connect(_on_canvas_input)
	vbox.add_child(_canvas)

	var foot := Label.new()
	foot.text = "point at a mark to see what it is   ·   click to fly   ·   Esc — stay"
	foot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	foot.add_theme_font_size_override("font_size", 12)
	foot.add_theme_color_override("font_color", Color(0.36, 0.34, 0.58, 0.60))
	vbox.add_child(foot)

	_panel_root.hide()
