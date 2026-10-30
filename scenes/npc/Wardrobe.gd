extends Object

# What a person is WEARING, as rows on the same 16x26 grid CharacterArt draws.
#
# ── Why this exists ──────────────────────────────────────────────────────────
#
# CharacterArt had seven haircuts and no clothes. Every person in twenty cities
# was the same coat in a different colour, so a Kappabashi shopkeeper in a work
# apron, a Moscow cobbler in a quilted jacket and a sixth-former in a puffer
# were one silhouette wearing three swatches. At this size a garment is the
# only thing besides a head that can tell you what somebody DOES, and what
# somebody does is most of who they are on a street you cannot read.
#
# ── The rows, once ───────────────────────────────────────────────────────────
#
# Restated for the design-canvas figure - see the long note on
# CharacterArt.HUMAN. The head gained four rows and the coat lost one, so every
# entry below has moved and most have been redrawn: the coat is a
# straight-sided rectangle with an X outline now, not the alien's flaring bell
# with an O one.
#
#   1-3      above the crown, for anything that sits on top of a head
#   3        the crown outline
#   4-8      hair, and the temples
#   9        the brow
#   10-11    eyes
#   12       cheeks, and where an ear is
#   13       mouth
#   14       jaw
#   15       neck
#   16       shoulders - a narrow row, X at columns 2 and 13
#   17-22    the garment - X at columns 1 and 14, twelve units of cloth between
#   23       two stub legs
#   24-25    shoes
#
# ── The rule this file exists to keep ────────────────────────────────────────
#
# A garment is assigned to a PERSON, never to a category. An elder in a
# headscarf because she is an elder is a stereotype with a sprite on it; Meryem
# wears one because she is a woman of her generation working in a han, and
# Sevim, fifty-one and running a fish stall by the Kadikoy ferry, does not,
# because Kadikoy is not Carsi. That distinction is the whole point of the
# file, and it only survives if every entry is written per person.

# ── Colour letters this file adds ────────────────────────────────────────────
#
#   P   headwear / garment accent          (already used by cap, wrap, scarf)
#   p   its shadow
#   a   a second garment accent            apron ties, a hi-vis stripe, a print
#   n   what is under the garment          a shirt collar, sleeve guards
#   j   metal                              hoops, a chain, a loupe, a badge
#
# Anything not in a person's palette is simply not drawn, so a garment that
# names `j` on somebody with no jewellery colour costs nothing.

# ── Hair and headwear ────────────────────────────────────────────────────────
#
# CharacterArt.CUTS holds the seven the crowd is drawn from. These are the ones
# a named person gets, and each is somebody's actual head.
const CUTS := {
	# A bun pulled tight with the edges laid. Sits ABOVE the crown, so the head
	# keeps its full height and the hairline stays where it is.
	"bun": {
		1: '......RRRR......', 2: '.....XRRRRX.....',
		3: '....XRRRRRRX....',
	},
	# Setsuko's perm. Wider than the head, which is the whole read of it, and
	# the only cut in the game allowed outside the fourteen-wide silhouette.
	"perm": {
		2: '...XXXXXXXXXX...', 3: '.XXRRRRRRRRRRXX.',
		4: 'XRRRRRRRRRRRRRRX', 5: 'XRRRRRRRRRRRRRRX',
		6: '.XRRRRRRRRRRRRX.',
	},
	# A long plait, worn forward over one shoulder. It leaves the head at the
	# temple and lands on the coat, which is why it needs rows past the neck.
	"plait": {
		9: '.XSSSSSSSSSSSRX.', 10: '.XSSWESSSSEWSRX.',
		11: '.XSSWESSSSEWSRX.', 12: '.XSSSSSSSSSSSRX.',
		13: '.XSSSSSMMSSSSRX.', 14: '..XSSSSSSSSSRX..',
		17: '.XCCCCggggCCRRX.', 18: '.XCCCCCCCCCCRRX.',
	},
	# A wool hat kept on indoors, with the flaps down. Not a category: Viktor
	# is the one who never takes his off, and it is a fact about him.
	"woolhat": {
		3: '....XPPPPPPX....', 4: '..XXPPPPPPPPXX..',
		5: '.XPPPPPPPPPPPPX.', 6: '.XPPPPPPPPPPPPX.',
		7: '.XPPPPPPPPPPPPX.', 8: '.XppSSSSSSSSppX.',
	},
	# Two weeks past a fade: hair only on the top, and the sides are skin.
	"fade": {
		4: '..XXRRRRRRRRXX..', 5: '.XRRRRRRRRRRRRX.',
		6: '.XSRRRRRRRRRRSX.', 7: '.XSSSSSSSSSSSSX.',
		8: '.XSSSSSSSSSSSSX.',
	},
	# A basortu tied under the chin, covering the hair and the neck. Meryem's.
	"basortu": {
		3: '....XPPPPPPX....', 4: '..XXPPPPPPPPXX..',
		5: '.XPPPPPPPPPPPPX.', 6: '.XPPPPPPPPPPPPX.',
		7: '.XPPSSSSSSSSPPX.', 8: '.XPSSSSSSSSSSPX.',
		9: '.XPSSSSSSSSSSPX.', 10: '.XPSWESSSSEWSPX.',
		11: '.XPSWESSSSEWSPX.', 12: '.XPSSSSSSSSSSPX.',
		13: '.XPSSSSMMSSSSPX.', 14: '..XPSSSSSSSSPX..',
		15: '...XXPPPPPPXX...', 16: '..XPPPPPPPPPPX..',
	},
	# A dupatta over the head, loose, so hair shows at the front. Sunita's, and
	# it is a different object from a basortu in every way that shows.
	"dupatta": {
		3: '....XPPPPPPX....', 4: '..XXPRRRRRRPXX..',
		5: '.XPPRRRRRRRRPPX.', 6: '.XPPRRRRRRRRPPX.',
		7: '.XPPSSSSSSSSPPX.', 8: '.XPSSSSSSSSSSPX.',
		14: '..XPSSSSSSSSPX..', 15: '...XXPPPPPPXX...',
	},
	# A flat cap, worn back. Older men in half the cities on this itinerary.
	"flatcap": {
		3: '....XPPPPPPX....', 4: '..XXPPPPPPPPXX..',
		5: '.XPPPPPPPPPPPPX.', 6: '.XppppppppppppX.',
	},
	# A baseball cap with the peak forward, so the peak crosses the brow.
	"peakcap": {
		3: '....XPPPPPPX....', 4: '..XXPPPPPPPPXX..',
		5: '.XPPPPPPPPPPPPX.', 6: '.XPPPPPPPPPPPPX.',
		7: 'XppppppppppppppX', 8: '.XSSSSSSSSSSSSX.',
	},
	# A hard hat, and a hairnet. Both are jobs rather than people, and both
	# come off at the end of a shift.
	"hardhat": {
		2: '.....XXXXXX.....', 3: '...XPPPPPPPPX...',
		4: '..XPPPPPPPPPPX..', 5: '.XPPPPPPPPPPPPX.',
		6: 'XPPPPPPPPPPPPPPX', 7: '.XSSSSSSSSSSSSX.',
		8: '.XSSSSSSSSSSSSX.',
	},
	"hairnet": {
		4: '..XXPRPRPRPRXX..', 5: '.XPRPRPRPRPRPRX.',
		6: '.XRPRPRPRPRPRPX.',
	},
	# A topknot. Baek's, and it is his own rather than his trade's.
	"topknot": {
		1: '.......RR.......', 2: '......XRRX......',
		3: '....XRRRRRRX....',
	},
	# Locs, gathered back. Marcus has had the same head since the shop opened.
	"locs": {
		9: '.XRSSSSSSSSSSRX.', 10: '.XRSWESSSSEWSRX.',
		11: '.XRSWESSSSEWSRX.', 12: '.XRSSSSSSSSSSRX.',
		13: '.XRSSSSMMSSSSRX.', 14: '..XRSSSSSSSSRX..',
	},
	# A shaved head. Not bald - shaved, which is a decision, and the stubble
	# line is what says so.
	"shaved": {
		4: '..XXRRRRRRRRXX..', 5: '.XRSSSSSSSSSSRX.',
		6: '.XSSSSSSSSSSSSX.', 7: '.XSSSSSSSSSSSSX.',
		8: '.XSSSSSSSSSSSSX.',
	},
	# Thinning, combed back off a high forehead. Fifty and honest about it.
	"thinning": {
		4: '..XXRRRRRRRRXX..', 5: '.XRRRRRRRRRRRRX.',
		6: '.XRSSSSSSSSSSRX.', 7: '.XSSSSSSSSSSSSX.',
		8: '.XSSSSSSSSSSSSX.',
	},
	# A non la: a cone, wider than the shoulders, tied under the chin. Half of
	# Hanoi's street trade is under one and it is nothing like a hat.
	"nonla": {
		1: '.......XX.......', 2: '.....XXPPXX.....',
		3: '...XPPPPPPPPX...', 4: '.XPPPPPPPPPPPPX.',
		5: 'XppppppppppppppX', 6: '.XRRRRRRRRRRRRX.',
		14: '..XPSSSSSSSSPX..', 15: '...XXPPPPPPXX...',
	},
	# An open-face helmet with the strap down. A xe om rider does not take it
	# off between fares, which is the fact about him worth drawing.
	"helmet": {
		2: '.....XXXXXX.....', 3: '...XPPPPPPPPX...',
		4: '..XPPPPPPPPPPX..', 5: '.XPPPPPPPPPPPPX.',
		6: '.XPPPPPPPPPPPPX.', 7: '.XPPPPPPPPPPPPX.',
		8: '.XPSSSSSSSSSSPX.', 9: '.XPSSSSSSSSSSPX.',
		14: '..XPSSSSSSSSPX..',
	},
	# A wide-brimmed straw hat, and a bowler. Both are specific places: one is
	# a market stall in the sun, the other is El Alto.
	"straw": {
		2: '....XXXXXXXX....', 3: '..XPPPPPPPPPPX..',
		4: 'XPPPPPPPPPPPPPPX', 5: '.XppppppppppppX.',
		6: '.XRRRRRRRRRRRRX.',
	},
	"bowler": {
		1: '.....XXXXXX.....', 2: '....XPPPPPPX....',
		3: '...XPPPPPPPPX...', 4: '.XPPPPPPPPPPPPX.',
		5: '.XRRRRRRRRRRRRX.', 6: '.XRRRRRRRRRRRRX.',
	},
}


# ── What they have on ────────────────────────────────────────────────────────
#
# Rows 16-22. Row 16 is the narrow shoulder row - X at columns 2 and 13, ten
# units of cloth between - and 17 to 22 are the body, X at columns 1 and 14
# with twelve between. `C` is the garment, `D` its cuffs and shading, `g` the
# collar accent, plus the four letters above for the parts a coat has not got.
const GARMENTS := {
	# The default. Left here by name so a person can ask for it explicitly.
	"coat": {},

	# A fleece over a work shirt: the collar shows above it and the zip runs
	# down the middle. Kerstin, and half of Berlin.
	"fleece": {
		16: '..XCCCnnnnCCCX..', 17: '.XCCCCnnnnCCCCX.',
		18: '.XCCCCCaaCCCCCX.', 19: '.XCCCCCaaCCCCCX.',
		20: '.XCCCCCaaCCCCCX.', 21: '.XDDCCCaaCCCDDX.',
		22: '.XDCCCCaaCCCCDX.',
	},

	# A puffer, zipped to the chin. The quilting is two horizontal seams, which
	# at this size is the entire difference between a puffer and a coat.
	"puffer": {
		16: '..XCCCCCCCCCCX..', 17: '.XCCCCggggCCCCX.',
		18: '.XDDDDDDDDDDDDX.', 19: '.XCCCCCCCCCCCCX.',
		20: '.XDDDDDDDDDDDDX.', 21: '.XDDCCCCCCCCDDX.',
		22: '.XDCCCCCCCCCCDX.',
	},

	# A good wool coat kept fifteen years, with a scarf tied - not draped - at
	# the throat. Odile's, and the scarf is the only new colour on her.
	"goodcoat": {
		15: '...XXPPPPPPXX...', 16: '..XPPPPPPPPPPX..',
		17: '.XCCPPPPPPPPCCX.', 18: '.XCCCCCCCCCCCCX.',
		19: '.XCCCCCCCCCCCCX.', 20: '.XCCCCCCCCCCCCX.',
		21: '.XDDCCCCCCCCDDX.', 22: '.XDCCCCCCCCCCDX.',
	},

	# A quilted jacket: vertical seams, and the loupe on its string.
	"quilted": {
		16: '..XCjCCCCCCCCX..', 17: '.XCCjCggggCCCCX.',
		18: '.XCDCCDCCDCCDCX.', 19: '.XCDCCDCCDCCDCX.',
		20: '.XCDCCDCCDCCDCX.', 21: '.XDDCCDCCDCCDDX.',
		22: '.XDCCDCCDCCDCDX.',
	},

	# A printed T-shirt. The print is a block, because a legible logo at twelve
	# units wide is a lie.
	"tee": {
		16: '..XCCCCCCCCCCX..', 17: '.XCCCCCCCCCCCCX.',
		18: '.XCCaaaaaaaaCCX.', 19: '.XCCaaaaaaaaCCX.',
		20: '.XCCaaaaaaaaCCX.', 21: '.XDDCCCCCCCCDDX.',
		22: '.XDCCCCCCCCCCDX.',
	},

	# The same shirt with a thin chain over it, and a thread on the wrist that
	# does not show because there are no wrists. Omkar's.
	"mandaltee": {
		16: '..XCCCjjCCCCCX..', 17: '.XCCCCjjCCCCCCX.',
		18: '.XCCaaaaaaaaCCX.', 19: '.XCCaaaaaaaaCCX.',
		20: '.XCCaaaaaaaaCCX.', 21: '.XDDCCCCCCCCDDX.',
		22: '.XDCCCCCCCCCCDX.',
	},

	# A work apron over a blouse, with sleeve guards. Setsuko's, and Rocio's is
	# the same object doing a different job.
	"apron": {
		16: '..XCCCCggCCCCX..', 17: '.XCCCCggggCCCCX.',
		18: '.XCCCaaaaaaCCCX.', 19: '.XnCCaaaaaaCCnX.',
		20: '.XnCCaaaaaaCCnX.', 21: '.XnDCaaaaaaCDnX.',
		22: '.XDCCaaaaaaCCDX.',
	},

	# The same apron with a heavy front pocket, sagging with coins. Rocio.
	"marketapron": {
		16: '..XCCCCggCCCCX..', 17: '.XCCCaaaaaaCCCX.',
		18: '.XCCaaaaaaaaCCX.', 19: '.XCCaaaaaaaaCCX.',
		20: '.XCCaajjjjaaCCX.', 21: '.XDCaajjjjaaCDX.',
		22: '.XDCaaaaaaaaCDX.',
	},

	# High-visibility, with the two bands that make it one.
	"hivis": {
		16: '..XaaaaaaaaaaX..', 17: '.XaaaaaaaaaaaaX.',
		18: '.XnnnnnnnnnnnnX.', 19: '.XaaaaaaaaaaaaX.',
		20: '.XnnnnnnnnnnnnX.', 21: '.XaaaaaaaaaaaaX.',
		22: '.XaaaaaaaaaaaaX.',
	},

	# A shop coat: a plain overall, buttoned, worn over everything.
	"shopcoat": {
		16: '..XCCCnnnnCCCX..', 17: '.XCCCCnnnnCCCCX.',
		18: '.XCCCCCjjCCCCCX.', 19: '.XCCCCCjjCCCCCX.',
		20: '.XCCCCCjjCCCCCX.', 21: '.XDDCCCjjCCCDDX.',
		22: '.XDCCCCjjCCCCDX.',
	},

	# A collar and a tie. Counters, desks, and anybody being official at you.
	"suit": {
		16: '..XCCnnnnnnCCX..', 17: '.XCCCnnaannCCCX.',
		18: '.XCCCCCaaCCCCCX.', 19: '.XCCCCCaaCCCCCX.',
		20: '.XCCCCCaaCCCCCX.', 21: '.XDDCCCCCCCCDDX.',
		22: '.XDCCCCCCCCCCDX.',
	},

	# A hoodie with the hood down, which is a lump behind the neck - so the
	# neck row goes as wide as the shoulders, and that is the whole of it.
	"hoodie": {
		15: '..XCCCCCCCCCCX..', 16: '..XCCCCCCCCCCX..',
		17: '.XCCCCggggCCCCX.', 18: '.XCCCCCCCCCCCCX.',
		19: '.XCCCCCCCCCCCCX.', 20: '.XCCCCCCCCCCCCX.',
		21: '.XDDCCCCCCCCDDX.', 22: '.XDCCCCCCCCCCDX.',
	},

	# A sari, which is a drape across one shoulder and a fall down the other
	# side, and reads at this size only because of the diagonal.
	"sari": {
		16: '..XaaCCCCCCCCX..', 17: '.XCaaaCCCCCCCCX.',
		18: '.XCCaaaCCCCCCCX.', 19: '.XCCCaaaCCCCCCX.',
		20: '.XCCCCaaaCCCCCX.', 21: '.XDDCCaaaCCCDDX.',
		22: '.XaaaaaaaaaaaaX.',
	},

	# A kurta: long, straight, with a slit collar and no waist.
	"kurta": {
		16: '..XCCCCggCCCCX..', 17: '.XCCCCCggCCCCCX.',
		18: '.XCCCCCggCCCCCX.', 19: '.XCCCCCCCCCCCCX.',
		20: '.XCCCCCCCCCCCCX.', 21: '.XCCCCCCCCCCCCX.',
		22: '.XCCCCCCCCCCCCX.',
	},

	# A boubou: wide, printed, and it hangs off the shoulders rather than the
	# body. Dakar, and it is the widest garment in the game.
	"boubou": {
		16: '..XCCCCCCCCCCX..', 17: '.XCCCCCaaCCCCCX.',
		18: '.XCCCaaaaaaCCCX.', 19: '.XCCaaaaaaaaCCX.',
		20: '.XCaaaaaaaaaaCX.', 21: '.XaaaaaaaaaaaaX.',
		22: '.XaaaaaaaaaaaaX.',
	},

	# A pollera and its shawl: La Paz, and the shawl is the part that reads.
	"pollera": {
		16: '..XaaaaaaaaaaX..', 17: '.XaaCCCCCCCCaaX.',
		18: '.XaCCCCCCCCCCaX.', 19: '.XCCCCCCCCCCCCX.',
		20: '.XCCCCCCCCCCCCX.', 21: '.XCCCCCCCCCCCCX.',
		22: '.XCCCCCCCCCCCCX.',
	},

	# A tracksuit top, zipped, with the stripe down each arm - which here is
	# down each side, because there are no arms.
	"tracksuit": {
		16: '..XaCCCCCCCCaX..', 17: '.XaCCCCggggCCaX.',
		18: '.XaCCCCCCCCCCaX.', 19: '.XaCCCCCCCCCCaX.',
		20: '.XaCCCCCCCCCCaX.', 21: '.XaDCCCCCCCCDaX.',
		22: '.XaCCCCCCCCCCaX.',
	},

	# A summer shirt, open, over a vest. Half of Mumbai and all of Honolulu.
	"openshirt": {
		16: '..XCCCnnnnCCCX..', 17: '.XCCCCnnnnCCCCX.',
		18: '.XCCCCnnnnCCCCX.', 19: '.XCCCCnnnnCCCCX.',
		20: '.XCCCCnnnnCCCCX.', 21: '.XDDCCnnnnCCDDX.',
		22: '.XDCCCnnnnCCCDX.',
	},

	# A housecoat, which is a garment nobody chose to be seen in and which is
	# on the street anyway because the shop is four doors down.
	"housecoat": {
		16: '..XCCCCggCCCCX..', 17: '.XCCaaCCCCaaCCX.',
		18: '.XCCCCaaaaCCCCX.', 19: '.XCCaaCCCCaaCCX.',
		20: '.XCCCCaaaaCCCCX.', 21: '.XDDaaCCCCaaDDX.',
		22: '.XDCCCaaaaCCCDX.',
	},

	# A school blazer with the tie loosened to nothing.
	"blazer": {
		16: '..XCCnnnnnnCCX..', 17: '.XCCCnnaannCCCX.',
		18: '.XCCCnnaannCCCX.', 19: '.XCCCCCaaCCCCCX.',
		20: '.XCCCCCaaCCCCCX.', 21: '.XDDCCCCCCCCDDX.',
		22: '.XDCCCCCCCCCCDX.',
	},
}


# ── Extra face marks ─────────────────────────────────────────────────────────
#
# CharacterArt.FACE_ROWS holds glasses, a moustache and a beard. These are the
# ones that belong to one person. Row 9 is the brow, 10-11 the eyes, 12 the
# cheeks, 13 the mouth.
const MARKS := {
	# Reading glasses pushed up into the hair, which is where they live and
	# not where they are used. Kerstin's, and hers are never on her face.
	"readers_up": {6: '.XRjjjjjjjjjjRX.'},
	# Round wire frames, thinner than the heavy pair the crowd wears.
	"wireglasses": {9: '.XSjSjjSSjjSjSX.'},
	# Glasses on a chain, so they hang whether or not they are being used.
	"chainglasses": {9: '.XSjjjjSSjjjjSX.', 14: '..XjSSSSSSSSjX..'},
	# Big gold hoops. They take the outline column at the ear rather than a
	# column outside it: hung clear of the head they read as two gold squares
	# floating in the air beside somebody, which is what the first pass did.
	"hoops": {12: '.jSSSSSSSSSSSSj.', 13: '.jSSSSSMMSSSSSj.'},
	# One stud, on one side, which is the whole of somebody's teenage.
	"stud": {12: '.jSSSSSSSSSSSSX.'},
	# A short grey beard, kept. Different from the crowd's, which is a shape.
	"greybeard": {12: '.XSSMMMMMMMMSSX.', 13: '.XSMMMMMMMMMMSX.',
		14: '..XMMMMMMMMMMX..', 15: '...XXMMMMMMXX...'},
	# A moustache with nothing under it. Viktor, and most of the men his age in
	# the booths either side of his.
	"thickstache": {12: '.XSSSMMMMMMSSSX.', 13: '.XSSSMMMMMMSSSX.'},
	# Laughter, kept in the corners of the eyes. The only mark in the game that
	# is about somebody's temperament rather than their grooming.
	"crowsfeet": {12: '.XHSSSSSSSSSSHX.'},
}


# ── What is on their feet ────────────────────────────────────────────────────
#
# Row 23 is two stub legs and rows 24-25 are the shoes. Worth having: Nadia's
# trainers are immaculate white and she is careful about them on wet pavement,
# which is a fact about her that only exists if her shoes are not the same dark
# block everybody else's are.
const SHOES := {
	# Trainers come up over the ankle, so they take the leg row as well.
	"trainers": {23: '..XKKKX..XKKKX..'},
	# Work boots take the leg AND spread at the sole.
	"boots": {23: '..XKKKX..XKKKX..', 25: '.XKKKKX.XKKKKX..'},
	# Sandals and slippers: a strap and a sole, and skin between them.
	"sandals": {23: '..XSSSX..XSSSX..', 24: '..XSSSX..XSSSX..'},
	"bare": {23: '..XSSSX..XSSSX..', 24: '..XSSSX..XSSSX..',
		25: '..XSSSX..XSSSX..'},
	# A heel is narrower than a foot, which is the only way to say heel here.
	"heels": {25: '...XKX....XKX...'},
}


# Everything a person's `who` dictionary asks for, laid over the base grid in
# the order a person actually puts it on: hair, what they are wearing, then the
# hair that falls OVER what they are wearing, then their face, then their feet.
# Clothes over hair is how a scarf tucks in; a plait worn forward over one
# shoulder lands on the apron rather than under it, which is why `drape` is a
# separate slot and not a second name for `cut`.
static func dress(rows: Array, who: Dictionary, base_cuts: Dictionary,
		base_marks: Dictionary) -> void:
	var cut: String = String(who.get("cut", "crop"))
	_lay(rows, base_cuts, cut)
	_lay(rows, CUTS, cut)
	_lay(rows, GARMENTS, String(who.get("wear", "")))
	var drape: String = String(who.get("drape", ""))
	_lay(rows, base_cuts, drape)
	_lay(rows, CUTS, drape)
	_lay(rows, base_marks, String(who.get("face", "")))
	_lay(rows, MARKS, String(who.get("mark", "")))
	_lay(rows, SHOES, String(who.get("shoes", "")))


static func _lay(rows: Array, table: Dictionary, key: String) -> void:
	if key.is_empty() or not table.has(key):
		return
	var over: Dictionary = table[key]
	for r: int in over.keys():
		if r >= 0 and r < rows.size():
			rows[r] = String(over[r])
