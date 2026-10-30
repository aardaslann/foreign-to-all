extends Object

# What people say as they go past.
#
# ── What was wrong ───────────────────────────────────────────────────────────
#
# Three fragments per language, and one of them was a greeting fixed at
# "morning". So the two friends on the street in Berlin said *Guten Morgen* to
# each other at five in the morning under a black sky, and went on saying it
# at every hour the game has. Istanbul had *Hadi gel* and *Kac lira?* and
# nothing else, forever, on the busiest street in the game.
#
# A street is the single largest source of vocabulary here - a crowd teaches by
# repetition, which is how anybody actually learns a word - and it was teaching
# about eight words per city.
#
# ── What a snippet is ────────────────────────────────────────────────────────
#
# [[what it looks like, the word it is], ...]. CharacterArt.snippet_text turns
# it into glyphs until the player has heard the word enough to read it, which
# is the mechanic in miniature.
#
# ── Two tables ───────────────────────────────────────────────────────────────
#
#   GREET   what you say TO somebody, and it depends on the hour
#   TALK    everything else - prices, weather, the bus, a complaint
#
# Only greetings are time-bound. "How much is it" is the same at any hour, and
# splitting those by hour as well would quadruple the file for nothing.
#
# Day parts are the four GameState.day_part() returns: night, morning,
# afternoon, evening. Cultures divide the day differently and the tables say
# so - German has a greeting per part, English mostly refuses to use them at
# all, and Turkish greets with health as often as with the hour.

const GREET := {

"german": {
	"night": [
		[["Na?", "na"]],
		[["Noch", "noch"], ["wach?", "wach"]],
		[["Nacht.", "nacht"]],
	],
	"morning": [
		[["Guten", "guten"], ["Morgen!", "morgen"]],
		[["Morgen.", "morgen"]],
		[["Na,", "na"], ["alles", "alles"], ["gut?", "gut"]],
	],
	"afternoon": [
		[["Guten", "guten"], ["Tag.", "tag"]],
		[["Tach.", "tag"]],
		[["Alles", "alles"], ["klar?", "klar"]],
	],
	"evening": [
		[["Guten", "guten"], ["Abend.", "abend"]],
		[["Schönen", "schöner"], ["Abend", "abend"], ["noch.", "noch"]],
		[["Feierabend!", "feierabend"]],
	],
},

"swissgerman": {
	"night": [[["Guet", "guet"], ["Nacht.", "nacht"]],
		[["No", "no"], ["wach?", "wach"]]],
	"morning": [[["Gruezi.", "gruezi"]],
		[["Guete", "guet"], ["Morge.", "morge"]]],
	"afternoon": [[["Gruezi", "gruezi"], ["mitenand.", "mitenand"]],
		[["Sali.", "sali"]]],
	"evening": [[["Guete", "guet"], ["Abig.", "abig"]],
		[["Schöne", "schöner"], ["Abig.", "abig"]]],
},

"english": {
	# The whole point of English in this game: the greeting is not a greeting.
	"night": [
		[["You", "you"], ["alright?", "alright"]],
		[["Night,", "night"], ["mate.", "mate"]],
		[["Freezing", "freezing"], ["innit.", "innit"]],
	],
	"morning": [
		[["Morning.", "morning"]],
		[["You", "you"], ["alright?", "alright"]],
		[["Alright,", "alright"], ["love?", "love"]],
	],
	"afternoon": [
		[["You", "you"], ["alright?", "alright"]],
		[["Alright,", "alright"], ["mate?", "mate"]],
		[["Y'alright?", "alright"]],
	],
	"evening": [
		[["Evening.", "evening"]],
		[["Night,", "night"], ["yeah?", "yeah"]],
		[["Safe,", "safe"], ["yeah.", "yeah"]],
	],
},

"french": {
	"night": [[["Bonsoir,", "bonsoir"], ["monsieur.", "monsieur"]],
		[["Bonne", "bonne"], ["nuit.", "nuit"]]],
	"morning": [[["Bonjour,", "bonjour"], ["madame.", "madame"]],
		[["Bonjour.", "bonjour"]]],
	"afternoon": [[["Bonjour,", "bonjour"], ["monsieur.", "monsieur"]],
		[["Bonjour.", "bonjour"]]],
	"evening": [[["Bonsoir.", "bonsoir"]],
		[["Bonne", "bonne"], ["soiree.", "soir"]]],
},

"italian": {
	"night": [[["Buonanotte.", "buonanotte"]], [["Notte.", "notte"]]],
	"morning": [[["Buongiorno!", "buongiorno"]],
		[["Ciao,", "ciao"], ["bella.", "bella"]]],
	"afternoon": [[["Buongiorno.", "buongiorno"]], [["Salve.", "salve"]]],
	"evening": [[["Buonasera.", "buonasera"]], [["Sera.", "sera"]]],
},

"russian": {
	"night": [[["Dobroy", "dobroy"], ["nochi.", "nochi"]],
		[["Pozdno", "pozdno"], ["uzhe.", "uzhe"]]],
	"morning": [[["Dobroe", "dobroe"], ["utro.", "utro"]],
		[["Zdravstvuyte.", "zdravstvuyte"]]],
	"afternoon": [[["Dobryy", "dobryy"], ["den.", "den"]],
		[["Zdravstvuyte.", "zdravstvuyte"]]],
	"evening": [[["Dobryy", "dobryy"], ["vecher.", "vecher"]],
		[["Do", "do"], ["svidaniya.", "svidaniya"]]],
},

"turkish": {
	# Turkish greets by the hour like German does, and then keeps going: the
	# health question is doing most of the work in every one of them.
	"night": [
		[["İyi", "iyi"], ["geceler.", "geceler"]],
		[["Hayırlı", "hayirli"], ["geceler.", "geceler"]],
		[["Nasılsın", "nasilsin"], ["abi?", "abi"]],
	],
	"morning": [
		[["Günaydın", "gunaydin"], ["abi.", "abi"]],
		[["Günaydın.", "gunaydin"]],
		[["Nasılsın?", "nasilsin"]],
	],
	"afternoon": [
		[["İyi", "iyi"], ["günler.", "gunler"]],
		[["Merhaba", "merhaba"], ["abla.", "abla"]],
		[["Ne", "ne"], ["haber?", "haber"]],
	],
	"evening": [
		[["İyi", "iyi"], ["akşamlar.", "aksamlar"]],
		[["Kolay", "kolay"], ["gelsin.", "gelsin"]],
		[["Görüşürüz.", "gorusuruz"]],
	],
},
}


# ── Everything that is not a greeting ────────────────────────────────────────
#
# Prices, weather, the traffic, a complaint about a bus. These are the ones a
# player hears four times and starts to recognise, which is the whole reason
# the crowd exists.
const TALK := {

"german": [
	[["Wie", "wie"], ["geht's?", "geht"]],
	[["Kalt", "kalt"], ["heute.", "heute"]],
	[["Der", "der"], ["Bus", "bus"], ["kommt", "kommen"], ["nicht.", "nicht"]],
	[["Was", "was"], ["kostet", "kostet"], ["das?", "das"]],
	[["Zwei", "zwei"], ["Euro,", "euro"], ["bitte.", "bitte"]],
	[["Ist", "ist"], ["das", "das"], ["frisch?", "frisch"]],
	[["Ich", "ich"], ["habe", "habe"], ["keine", "keine"], ["Zeit.", "zeit"]],
	[["Danke", "danke"], ["schön.", "schöner"]],
	[["Wo", "wo"], ["ist", "ist"], ["der", "der"], ["Markt?", "markt"]],
	[["Später,", "später"], ["ja?", "ja"]],
	[["Das", "das"], ["ist", "ist"], ["zu", "zu"], ["teuer.", "teuer"]],
	[["Bis", "bis"], ["morgen.", "morgen"]],
],

"swissgerman": [
	[["Merci", "merci"], ["vielmal.", "vielmal"]],
	[["Chumm", "chumm"], ["jetzt.", "jetzt"]],
	[["Was", "was"], ["choschtet", "choschtet"], ["das?", "das"]],
	[["Es", "es"], ["isch", "isch"], ["chalt.", "chalt"]],
	[["Gaht", "gaht"], ["das?", "das"]],
	[["Ich", "ich"], ["ha", "ha"], ["kei", "keine"], ["Zyt.", "zyt"]],
	[["Wottsch", "wottsch"], ["au?", "au"]],
	[["Bis", "bis"], ["spöter.", "spöter"]],
],

"english": [
	[["Cheers,", "cheers"], ["mate.", "mate"]],
	[["How", "how"], ["much", "much"], ["is", "is"], ["that?", "that"]],
	[["Sorry,", "sorry"], ["sorry.", "sorry"]],
	[["It's", "it"], ["a", "a"], ["bit", "bit"], ["cold.", "cold"]],
	[["Bus", "bus"], ["is", "is"], ["late", "late"], ["again.", "again"]],
	[["That's", "that"], ["bare", "bare"], ["long.", "long"]],
	[["Allow", "allow"], ["it.", "it"]],
	[["You", "you"], ["dun", "dun"], ["know.", "know"]],
	[["Two", "two"], ["quid,", "quid"], ["yeah?", "yeah"]],
	[["Lovely,", "lovely"], ["that.", "that"]],
	[["No", "no"], ["worries,", "worries"], ["mate.", "mate"]],
	[["Where", "where"], ["you", "you"], ["going?", "going"]],
],

"french": [
	[["Il", "il"], ["pleut.", "pleut"]],
	[["Merci,", "merci"], ["au revoir.", "revoir"]],
	[["C'est", "cest"], ["combien?", "combien"]],
	[["Excusez-moi,", "excusez"], ["monsieur.", "monsieur"]],
	[["C'est", "cest"], ["complique.", "complique"]],
	[["Je", "je"], ["ne", "ne"], ["sais", "sais"], ["pas.", "pas"]],
	[["Voila.", "voila"]],
	[["Ecoute,", "ecoute"], ["hein.", "hein"]],
	[["C'est", "cest"], ["trop", "trop"], ["cher.", "cher"]],
	[["A", "a"], ["demain.", "demain"]],
],

"italian": [
	[["Allora,", "allora"], ["dimmi.", "dimmi"]],
	[["Quanto", "quanto"], ["costa?", "costa"]],
	[["Che", "che"], ["caldo!", "caldo"]],
	[["Un", "un"], ["caffe,", "caffe"], ["grazie.", "grazie"]],
	[["Non", "non"], ["e", "e"], ["possibile.", "possibile"]],
	[["Ecco", "ecco"], ["fatto.", "fatto"]],
	[["Sei", "sei"], ["bravo.", "bravo"]],
	[["Ci", "ci"], ["vediamo.", "vediamo"]],
	[["E", "e"], ["troppo", "troppo"], ["caro.", "caro"]],
],

"russian": [
	[["Skolko", "skolko"], ["stoit?", "stoit"]],
	[["Kholodno", "kholodno"], ["segodnya.", "segodnya"]],
	[["Normalno.", "normalno"]],
	[["Spasibo", "spasibo"], ["bolshoe.", "bolshoe"]],
	[["Eto", "eto"], ["dorogo.", "dorogo"]],
	[["Nu", "nu"], ["chto", "chto"], ["ty.", "ty"]],
	[["Davay,", "davay"], ["idyom.", "idyom"]],
	[["Ya", "ya"], ["ne", "ne"], ["znayu.", "znayu"]],
	[["Opyat", "opyat"], ["ochered.", "ochered"]],
	[["Do", "do"], ["svidaniya.", "svidaniya"]],
],

"turkish": [
	[["Kaç", "kac"], ["lira?", "lira"]],
	[["Hadi", "hadi"], ["gel.", "gel"]],
	[["Bir", "bir"], ["çay", "çay"], ["lütfen.", "lütfen"]],
	[["Çok", "cok"], ["pahalı", "pahali"], ["abi.", "abi"]],
	[["Buyur", "buyur"], ["abla.", "abla"]],
	[["Vapur", "vapur"], ["geliyor.", "geliyor"]],
	[["Ekmek", "ekmek"], ["var", "var"], ["mı?", "mı"]],
	[["Yok", "yok"], ["abi,", "abi"], ["yok.", "yok"]],
	[["Bak", "bak"], ["şuna!", "suna"]],
	[["Soğuk", "soğuk"], ["bugün.", "bugun"]],
	[["Teşekkür", "teşekkür"], ["ederim.", "ederim"]],
	[["İnşallah", "insallah"], ["yarın.", "yarin"]],
	[["Trafik", "trafik"], ["çok", "cok"], ["kötü.", "kotu"]],
	[["Kedi", "kedi"], ["aç.", "aç"]],
],
}


# The nine languages of the back half live in ChatterWorld.gd; callers ask
# here and never have to know which file somebody's language is in.
const WORLD := preload("res://scenes/npc/ChatterWorld.gd")


static func has_language(language: String) -> bool:
	return GREET.has(language) or WORLD.has_language(language)


static func greetings(language: String, part: String) -> Array:
	if GREET.has(language):
		var per: Dictionary = GREET[language]
		return per.get(part, per.get("morning", []))
	return WORLD.greetings(language, part)


static func talk(language: String) -> Array:
	if TALK.has(language):
		return TALK[language]
	return WORLD.talk(language)


# Everything somebody might say right now: the greetings for this hour plus
# all the small talk. One pool, so a passer-by is as likely to complain about
# the bus as to say hello, which is what a street sounds like.
static func lines(language: String, part: String) -> Array:
	var out: Array = []
	out.append_array(greetings(language, part))
	out.append_array(talk(language))
	return out
