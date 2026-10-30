extends Object

# The words a sentence is actually made of.
#
# The alien's dialogue options are already phrased for how much of the language
# has landed - a gesture at first, a sentence at twenty-two words - but every
# tier of every one of them was in ENGLISH. So the option said "Just a tea,
# please" whether you had learned a word of Turkish or not, and there was
# nothing in it to hover over, nothing to recognise, and no way for saying
# something to feel different from intending it.
#
# This is the vocabulary an option is built out of. Where the player has
# actually learned a word, the option is spoken with it: "Just a cay, please"
# and then "Just a cay, lutfen". The sentence fills in with the language as you
# learn it, which is the only honest picture of what learning a language is
# like, and each substituted word carries the journal's guess on hover exactly
# as the NPC's own speech does.
#
# Latinised throughout, per the 2026-08-30 amendment: a word the player cannot
# sound out is a box, not a word.
#
# ITEM NOUNS ARE NOT HERE. Items.WORDS already holds bread, cheese, the ticket,
# the map and the room card in all sixteen languages, and duplicating them
# would guarantee the two disagreed. local() asks it.

const ITEMS := preload("res://autoload/Items.gd")

# The courtesy and counter vocabulary - the words a request, an apology, a
# refusal or a price is made of. These are the first words anybody picks up in
# a country, and they are what this game's hundred and twenty-eight exchanges
# are written out of.
const PHRASES := {
"please": {
	"german": "bitte", "swissgerman": "bitte", "english": "please",
	"turkish": "lutfen", "french": "s'il vous plait", "italian": "per favore",
	"russian": "pozhaluysta", "spanish_mx": "por favor", "spanish_bo": "por favor",
	"portuguese": "por favor", "japanese": "onegaishimasu", "korean": "juseyo",
	"hindi": "kripya", "vietnamese": "lam on", "wolof": "su la neexee",
	"georgian": "tu sheidzleba",
},
"thanks": {
	"german": "danke", "swissgerman": "merci", "english": "thanks",
	"turkish": "tesekkurler", "french": "merci", "italian": "grazie",
	"russian": "spasibo", "spanish_mx": "gracias", "spanish_bo": "gracias",
	"portuguese": "obrigado", "japanese": "arigatou", "korean": "kamsahamnida",
	"hindi": "dhanyavaad", "vietnamese": "cam on", "wolof": "jerejef",
	"georgian": "madloba",
},
"yes": {
	"german": "ja", "swissgerman": "ja", "english": "yes",
	"turkish": "evet", "french": "oui", "italian": "si",
	"russian": "da", "spanish_mx": "si", "spanish_bo": "si",
	"portuguese": "sim", "japanese": "hai", "korean": "ne",
	"hindi": "haan", "vietnamese": "vang", "wolof": "waaw",
	"georgian": "ki",
},
"no": {
	"german": "nein", "swissgerman": "nei", "english": "no",
	"turkish": "hayir", "french": "non", "italian": "no",
	"russian": "net", "spanish_mx": "no", "spanish_bo": "no",
	"portuguese": "nao", "japanese": "iie", "korean": "aniyo",
	"hindi": "nahin", "vietnamese": "khong", "wolof": "deedeet",
	"georgian": "ara",
},
"hello": {
	"german": "hallo", "swissgerman": "gruezi", "english": "hello",
	"turkish": "merhaba", "french": "bonjour", "italian": "buongiorno",
	"russian": "zdravstvuyte", "spanish_mx": "hola", "spanish_bo": "buenos dias",
	"portuguese": "oi", "japanese": "konnichiwa", "korean": "annyeonghaseyo",
	"hindi": "namaste", "vietnamese": "xin chao", "wolof": "salaam aleekum",
	"georgian": "gamarjoba",
},
"goodbye": {
	"german": "tschuss", "swissgerman": "ade", "english": "goodbye",
	"turkish": "gule gule", "french": "au revoir", "italian": "arrivederci",
	"russian": "do svidaniya", "spanish_mx": "adios", "spanish_bo": "hasta luego",
	"portuguese": "tchau", "japanese": "sayonara", "korean": "annyeonghi gaseyo",
	"hindi": "alvida", "vietnamese": "tam biet", "wolof": "ba beneen",
	"georgian": "nakhvamdis",
},
"sorry": {
	"german": "entschuldigung", "swissgerman": "tschuldigung", "english": "sorry",
	"turkish": "pardon", "french": "pardon", "italian": "scusi",
	"russian": "izvinite", "spanish_mx": "perdon", "spanish_bo": "disculpe",
	"portuguese": "desculpa", "japanese": "sumimasen", "korean": "joesonghamnida",
	"hindi": "maaf kijiye", "vietnamese": "xin loi", "wolof": "baal ma",
	"georgian": "ukatsravad",
},
"how much": {
	"german": "wie viel", "swissgerman": "wie viel", "english": "how much",
	"turkish": "ne kadar", "french": "combien", "italian": "quanto",
	"russian": "skolko", "spanish_mx": "cuanto", "spanish_bo": "cuanto",
	"portuguese": "quanto", "japanese": "ikura", "korean": "eolmayeyo",
	"hindi": "kitna", "vietnamese": "bao nhieu", "wolof": "naata",
	"georgian": "ramdeni",
},
"where": {
	"german": "wo", "swissgerman": "wo", "english": "where",
	"turkish": "nerede", "french": "ou", "italian": "dove",
	"russian": "gde", "spanish_mx": "donde", "spanish_bo": "donde",
	"portuguese": "onde", "japanese": "doko", "korean": "eodi",
	"hindi": "kahan", "vietnamese": "o dau", "wolof": "fan",
	"georgian": "sad",
},
"water": {
	"german": "wasser", "swissgerman": "wasser", "english": "water",
	"turkish": "su", "french": "eau", "italian": "acqua",
	"russian": "voda", "spanish_mx": "agua", "spanish_bo": "agua",
	"portuguese": "agua", "japanese": "mizu", "korean": "mul",
	"hindi": "paani", "vietnamese": "nuoc", "wolof": "ndox",
	"georgian": "tskali",
},
"tea": {
	"german": "tee", "swissgerman": "tee", "english": "tea",
	"turkish": "cay", "french": "the", "italian": "te",
	"russian": "chay", "spanish_mx": "te", "spanish_bo": "mate",
	"portuguese": "cha", "japanese": "ocha", "korean": "cha",
	"hindi": "chai", "vietnamese": "tra", "wolof": "attaaya",
	"georgian": "chai",
},
"coffee": {
	"german": "kaffee", "swissgerman": "kafi", "english": "coffee",
	"turkish": "kahve", "french": "cafe", "italian": "caffe",
	"russian": "kofe", "spanish_mx": "cafe", "spanish_bo": "cafe",
	"portuguese": "cafe", "japanese": "koohii", "korean": "keopi",
	"hindi": "kaafi", "vietnamese": "ca phe", "wolof": "kafe",
	"georgian": "qava",
},
"one": {
	"german": "eins", "swissgerman": "eis", "english": "one",
	"turkish": "bir", "french": "un", "italian": "uno",
	"russian": "odin", "spanish_mx": "uno", "spanish_bo": "uno",
	"portuguese": "um", "japanese": "ichi", "korean": "hana",
	"hindi": "ek", "vietnamese": "mot", "wolof": "benn",
	"georgian": "erti",
},
"two": {
	"german": "zwei", "swissgerman": "zwoi", "english": "two",
	"turkish": "iki", "french": "deux", "italian": "due",
	"russian": "dva", "spanish_mx": "dos", "spanish_bo": "dos",
	"portuguese": "dois", "japanese": "ni", "korean": "dul",
	"hindi": "do", "vietnamese": "hai", "wolof": "naar",
	"georgian": "ori",
},
"good": {
	"german": "gut", "swissgerman": "guet", "english": "good",
	"turkish": "iyi", "french": "bon", "italian": "buono",
	"russian": "khorosho", "spanish_mx": "bueno", "spanish_bo": "bueno",
	"portuguese": "bom", "japanese": "ii", "korean": "joayo",
	"hindi": "accha", "vietnamese": "tot", "wolof": "baax",
	"georgian": "kargi",
},
"help": {
	"german": "hilfe", "swissgerman": "hilf", "english": "help",
	"turkish": "yardim", "french": "aide", "italian": "aiuto",
	"russian": "pomogite", "spanish_mx": "ayuda", "spanish_bo": "ayuda",
	"portuguese": "ajuda", "japanese": "tasukete", "korean": "dowajuseyo",
	"hindi": "madad", "vietnamese": "giup", "wolof": "dimbali",
	"georgian": "damekhmaret",
},
}

# What the alien might have written, mapped to the entry above. Matched longest
# first, so "thank you" wins over "you" and "how much" over "much".
const SPOKEN := {
	"thank you very much": "thanks", "thank you": "thanks", "thanks": "thanks",
	"ta": "thanks", "cheers": "thanks",
	"how much": "how much", "excuse me": "sorry", "i'm sorry": "sorry",
	"sorry": "sorry", "please": "please", "hello": "hello", "hi": "hello",
	"goodbye": "goodbye", "bye": "goodbye", "yes": "yes", "no": "no",
	"where": "where", "water": "water", "tea": "tea", "coffee": "coffee",
	"one": "one", "two": "two", "good": "good", "help": "help",
	# Items.WORDS owns these; the value is the item id it files them under.
	"bread": "@bread", "cheese": "@cheese", "ticket": "@ticket_ubahn",
	"map": "@karte", "room card": "@zimmerkarte",
}


# The local word for something the alien means to say, or "" where this game
# has no word for it in that language.
static func local(meaning: String, language: String) -> String:
	if meaning.begins_with("@"):
		var row: Dictionary = ITEMS.WORDS.get(meaning.substr(1), {})
		return String(row.get(language, ""))
	var have: Dictionary = PHRASES.get(meaning, {})
	return String(have.get(language, ""))


# Every phrase in an English sentence that this game has a local word for,
# longest first so "thank you" wins over "you".
#
# Returns [[start, length, meaning, local_word], ...] in the order they appear,
# with no two overlapping.
static func found(text: String, language: String) -> Array:
	var lower: String = text.to_lower()
	var keys: Array = SPOKEN.keys()
	keys.sort_custom(func(a, b): return String(a).length() > String(b).length())
	var out: Array = []
	var taken: Array = []
	for k: String in keys:
		var word: String = local(String(SPOKEN[k]), language)
		if word.is_empty():
			continue
		var from: int = 0
		while true:
			var at: int = lower.find(k, from)
			if at < 0:
				break
			from = at + 1
			# Whole words only: "no" must not fire inside "nothing".
			if at > 0 and _wordish(lower.substr(at - 1, 1)):
				continue
			var after: int = at + k.length()
			if after < lower.length() and _wordish(lower.substr(after, 1)):
				continue
			var clash: bool = false
			for t: Array in taken:
				if at < int(t[1]) and after > int(t[0]):
					clash = true
					break
			if clash:
				continue
			taken.append([at, after])
			out.append([at, k.length(), String(SPOKEN[k]), word])
	out.sort_custom(func(a, b): return int(a[0]) < int(b[0]))
	return out


static func _wordish(c: String) -> bool:
	if c.length() != 1:
		return false
	if c == "'":
		return true
	if c >= "0" and c <= "9":
		return true
	return c.to_lower() != c.to_upper()


# The sentence broken into pieces, ready to be drawn.
#
# Each piece is {"text": String, "word": String, "meaning": String}. `word` is
# empty for the parts still in English. A phrase is only spoken in the local
# language once the player has actually learned that word - below `at_tier` it
# stays English, because the alien cannot say what it does not know.
static func pieces(text: String, language: String, at_tier: int) -> Array:
	var whole: Array = [{"text": text, "word": "", "meaning": ""}]
	if language.is_empty() or language == "english" or text.is_empty():
		return whole
	var out: Array = []
	var cut: int = 0
	for hit: Array in found(text, language):
		var at: int = int(hit[0])
		var n: int = int(hit[1])
		var word: String = String(hit[3])
		if GameState.get_tier(language, word) < at_tier:
			continue
		if at > cut:
			out.append({"text": text.substr(cut, at - cut), "word": "", "meaning": ""})
		# Keep the alien's capitalisation: a sentence opening with "Please"
		# should open with "Lutfen", not with "lutfen".
		var was: String = text.substr(at, n)
		var head: String = was.substr(0, 1)
		var shown: String = word
		if head == head.to_upper() and head != head.to_lower():
			shown = word.substr(0, 1).to_upper() + word.substr(1)
		out.append({"text": shown, "word": word, "meaning": String(hit[2])})
		cut = at + n
	if out.is_empty():
		return whole
	if cut < text.length():
		out.append({"text": text.substr(cut), "word": "", "meaning": ""})
	return out


# Every word of `language` that is WRITTEN IN a line - as opposed to found()
# above, which finds the English a line could be spoken with.
#
# Half the game's dialogue options were authored with the local language
# already in them: "Bir ekmek alabilir miyim, abla?", "Nan desu ka?", "Kac
# lira?". Those are not translations the game performs, they are words the
# author put in the alien's mouth, and nothing ever checked he had heard one of
# them. This is what checks.
#
# The notebook is the authority on what counts as a word of a language: if
# Guesses has an entry for it, it is a word this game teaches and can therefore
# withhold. A name, a place, an English word or a noise is not in there and is
# never gated - "Ba Dinh", "Wiesn", "Maslenitsa" and "okay" all pass through.
#
# Latinised and accented spellings both appear in the tables, so the lookup is
# on the token exactly as written, lowercased. The two multi-word entries the
# notebook holds ("bao nhieu", "juroom-benn") are matched as pairs first, so
# neither half is reported as an unknown word on its own.
static func vocabulary_in(text: String, language: String) -> Array:
	if text.is_empty() or language.is_empty():
		return []
	var book: Dictionary = GameState.guesses_for(language)
	if book.is_empty():
		return []
	var toks: PackedStringArray = _tokens(text)
	var out: Array = []
	var i: int = 0
	while i < toks.size():
		var pair: String = ""
		if i + 1 < toks.size():
			pair = toks[i] + " " + toks[i + 1]
		if not pair.is_empty() and book.has(pair):
			if not out.has(pair):
				out.append(pair)
			i += 2
			continue
		if book.has(toks[i]) and not out.has(toks[i]):
			out.append(toks[i])
		i += 1
	return out


# The same line broken into pieces, but for the local words ALREADY WRITTEN in
# it rather than the English ones that could be swapped out. An option authored
# as "Bir ekmek, lutfen" is three words out of the notebook and a comma, and
# each of them should carry its guess on hover exactly as the NPC's own speech
# does - otherwise the one place the player says a word is the one place they
# cannot check what they think it means.
static func local_pieces(text: String, language: String) -> Array:
	var found_words: Array = vocabulary_in(text, language)
	if found_words.is_empty():
		return [{"text": text, "word": "", "meaning": ""}]
	var out: Array = []
	var lower: String = text.to_lower()
	var cut: int = 0
	var at: int = 0
	while at < text.length():
		var best: String = ""
		var best_len: int = 0
		for w: String in found_words:
			var n: int = w.length()
			if n <= best_len or at + n > lower.length():
				continue
			if lower.substr(at, n) != w:
				continue
			if at > 0 and _wordish(lower.substr(at - 1, 1)):
				continue
			if at + n < lower.length() and _wordish(lower.substr(at + n, 1)):
				continue
			best = w
			best_len = n
		if best_len == 0:
			at += 1
			continue
		if at > cut:
			out.append({"text": text.substr(cut, at - cut), "word": "",
				"meaning": ""})
		out.append({"text": text.substr(at, best_len), "word": best,
			"meaning": ""})
		at += best_len
		cut = at
	if cut < text.length():
		out.append({"text": text.substr(cut), "word": "", "meaning": ""})
	return out


# The words of a line, lowercased, keeping the marks a language is spelled
# with. A hyphen stays inside a token ("juroom-benn") and so does an apostrophe
# ("s'il"); everything else separates.
static func _tokens(text: String) -> PackedStringArray:
	var out: PackedStringArray = []
	var cur: String = ""
	for i in range(text.length()):
		var c: String = text[i]
		var letterish: bool = (c.to_lower() != c.to_upper()) or c == "'" or c == "-"
		if letterish:
			cur += c
		elif not cur.is_empty():
			out.append(cur.to_lower())
			cur = ""
	if not cur.is_empty():
		out.append(cur.to_lower())
	return out


# Every local word an option would be spoken with if the player knew them all.
# Saying something is the strongest way to learn it, so choosing an option
# teaches its words whether or not it managed to say them out loud.
static func words_in(text: String, language: String) -> Array:
	var out: Array = []
	for hit: Array in found(text, language):
		out.append(String(hit[3]))
	return out
