extends Object

# What people say as they go past - the other nine languages.
#
# Split from Chatter.gd only because one file of both is past the size this
# project allows. Same two tables, same snippet shape, same rule: a greeting
# belongs to an hour, and everything else does not.
#
# Where a language does not divide the day the way European ones do, the table
# says so rather than inventing a translation of "good afternoon". Wolof greets
# with the salaam and then with health; Hindi's namaste does not move with the
# clock; Vietnamese greets by WHO you are - the pronoun is the greeting - and
# the same fragment is polite at any hour.

const GREET := {

"japanese": {
	"night": [[["Konbanwa.", "konbanwa"]],
		[["Osaki", "osaki"], ["ni.", "ni"]]],
	"morning": [[["Ohayou", "ohayou"], ["gozaimasu.", "gozaimasu"]],
		[["Ohayou.", "ohayou"]]],
	"afternoon": [[["Konnichiwa.", "konnichiwa"]],
		[["Doumo.", "doumo"]]],
	"evening": [[["Konbanwa.", "konbanwa"]],
		[["Otsukaresama", "otsukaresama"], ["desu.", "desu"]]],
},

"korean": {
	"night": [[["Annyeong", "annyeong"], ["hi", "hi"], ["jumuseyo.", "jumuseyo"]],
		[["Deureogaseyo.", "deureogaseyo"]]],
	"morning": [[["Annyeong", "annyeong"], ["haseyo.", "haseyo"]],
		[["Joeun", "joeun"], ["achim.", "achim"]]],
	"afternoon": [[["Annyeong", "annyeong"], ["haseyo.", "haseyo"]],
		[["Siksa", "siksa"], ["haesseoyo?", "haesseoyo"]]],
	"evening": [[["Annyeong", "annyeong"], ["haseyo.", "haseyo"]],
		[["Sugo", "sugo"], ["haseyo.", "haseyo"]]],
},

"hindi": {
	# Namaste does not move with the clock. What moves is how much of the
	# sentence there is.
	"night": [[["Namaste.", "namaste"]],
		[["Shubh", "shubh"], ["ratri.", "ratri"]]],
	"morning": [[["Namaste,", "namaste"], ["bhai.", "bhai"]],
		[["Kya", "kya"], ["haal", "haal"], ["hai?", "hai"]]],
	"afternoon": [[["Namaste.", "namaste"]],
		[["Arre", "arre"], ["yaar!", "yaar"]]],
	"evening": [[["Namaste.", "namaste"]],
		[["Chalta", "chalta"], ["hai.", "hai"]]],
},

"vietnamese": {
	# The pronoun IS the greeting: chao plus who you are to the speaker.
	"night": [[["Chao", "chao"], ["anh.", "anh"]],
		[["Ngu", "ngu"], ["ngon.", "ngon"]]],
	"morning": [[["Xin", "xin"], ["chao.", "chao"]],
		[["Chao", "chao"], ["chi.", "chi"]]],
	"afternoon": [[["Chao", "chao"], ["anh.", "anh"]],
		[["Xin", "xin"], ["chao.", "chao"]]],
	"evening": [[["Chao", "chao"], ["chi.", "chi"]],
		[["Tam", "tam"], ["biet.", "biet"]]],
},

"wolof": {
	"night": [[["Salaam", "salaam"], ["aleekum.", "aleekum"]],
		[["Fanaanal", "fanaanal"], ["jamm.", "jamm"]]],
	"morning": [[["Salaam", "salaam"], ["aleekum.", "aleekum"]],
		[["Naka", "naka"], ["suba?", "suba"]]],
	"afternoon": [[["Nanga", "nanga"], ["def?", "def"]],
		[["Mangi", "mangifi"], ["fi.", "fi"]]],
	"evening": [[["Naka", "naka"], ["ngoon?", "ngoon"]],
		[["Jerejef.", "jerejef"]]],
},

"georgian": {
	"night": [[["Ghame", "ghame"], ["mshvidobisa.", "mshvidoba"]],
		[["Kargad.", "kargad"]]],
	"morning": [[["Gamarjoba.", "gamarjoba"]],
		[["Dila", "dila"], ["mshvidobisa.", "mshvidoba"]]],
	"afternoon": [[["Gamarjoba.", "gamarjoba"]],
		[["Rogor", "rogor"], ["khar?", "khar"]]],
	"evening": [[["Sagamo", "sagamo"], ["mshvidobisa.", "mshvidoba"]],
		[["Nakhvamdis.", "nakhvamdis"]]],
},

"spanish_mx": {
	"night": [[["Buenas", "buenas"], ["noches.", "noches"]],
		[["Que", "que"], ["descanse.", "descanse"]]],
	"morning": [[["Buenos", "buenos"], ["dias.", "dias"]],
		[["Buenos", "buenos"], ["dias,", "dias"], ["joven.", "joven"]]],
	"afternoon": [[["Buenas", "buenas"], ["tardes.", "tardes"]],
		[["Que", "que"], ["onda?", "onda"]]],
	"evening": [[["Buenas", "buenas"], ["noches.", "noches"]],
		[["Ahi", "ahi"], ["nos", "nos"], ["vemos.", "vemos"]]],
},

"spanish_bo": {
	"night": [[["Buenas", "buenas"], ["noches.", "noches"]],
		[["Hasta", "hasta"], ["manana.", "manana"]]],
	"morning": [[["Buenos", "buenos"], ["dias,", "dias"], ["casera.", "casera"]],
		[["Buenos", "buenos"], ["dias.", "dias"]]],
	"afternoon": [[["Buenas", "buenas"], ["tardes.", "tardes"]],
		[["Como", "como"], ["esta?", "esta"]]],
	"evening": [[["Buenas", "buenas"], ["noches.", "noches"]],
		[["Ya", "ya"], ["pues.", "pues"]]],
},

"portuguese": {
	"night": [[["Boa", "boa"], ["noite.", "noite"]],
		[["Ate", "ate"], ["amanha.", "amanha"]]],
	"morning": [[["Bom", "bom"], ["dia.", "dia"]],
		[["Oi,", "oi"], ["tudo", "tudo"], ["bem?", "bem"]]],
	"afternoon": [[["Boa", "boa"], ["tarde.", "tarde"]],
		[["Tudo", "tudo"], ["bem?", "bem"]]],
	"evening": [[["Boa", "boa"], ["noite.", "noite"]],
		[["Falou.", "falou"]]],
},
}


const TALK := {

"japanese": [
	[["Sumimasen.", "sumimasen"]],
	[["Atsui", "atsui"], ["ne.", "ne"]],
	[["Ikura", "ikura"], ["desu", "desu"], ["ka?", "ka"]],
	[["Chotto", "chotto"], ["muzukashii", "muzukashii"], ["ne.", "ne"]],
	[["Yasui", "yasui"], ["yo.", "yo"]],
	[["Kore", "kore"], ["kudasai.", "kudasai"]],
	[["Daijoubu", "daijoubu"], ["desu.", "desu"]],
	[["Isogashii", "isogashii"], ["ne.", "ne"]],
	[["Arigatou", "arigatou"], ["gozaimasu.", "gozaimasu"]],
	[["Mata", "mata"], ["ashita.", "ashita"]],
],

"korean": [
	[["Eolmayeyo?", "eolmayeyo"]],
	[["Chuwoyo.", "chuwoyo"]],
	[["Mashisseoyo.", "mashisseoyo"]],
	[["Igeon", "igeon"], ["mwoyeyo?", "mwoyeyo"]],
	[["Bappayo.", "bappayo"]],
	[["Gamsahamnida.", "gamsahamnida"]],
	[["Jamkkanman", "jamkkanman"], ["yo.", "yo"]],
	[["Bissayo.", "bissayo"]],
	[["Ppalli", "ppalli"], ["ppalli.", "ppalli"]],
],

"hindi": [
	[["Kitne", "kitne"], ["ka?", "ka"]],
	[["Arre", "arre"], ["yaar.", "yaar"]],
	[["Bahut", "bahut"], ["mehenga", "mehenga"], ["hai.", "hai"]],
	[["Chalo,", "chalo"], ["chalo.", "chalo"]],
	[["Kya", "kya"], ["scene", "scene"], ["hai?", "hai"]],
	[["Ek", "ek"], ["minute", "minute"], ["bhai.", "bhai"]],
	[["Bindaas", "bindaas"], ["hai.", "hai"]],
	[["Paani", "paani"], ["chahiye.", "chahiye"]],
	[["Chalta", "chalta"], ["hai.", "hai"]],
	[["Theek", "theek"], ["hai", "hai"], ["na?", "na"]],
],

"vietnamese": [
	[["Bao", "bao"], ["nhieu?", "nhieu"]],
	[["Nong", "nong"], ["qua.", "qua"]],
	[["Dat", "dat"], ["qua!", "qua"]],
	[["Cho", "cho"], ["toi", "toi"], ["mot.", "mot"]],
	[["Khong", "khong"], ["sao.", "sao"]],
	[["Cam", "cam"], ["on.", "on"]],
	[["Di", "di"], ["dau", "dau"], ["day?", "day"]],
	[["Cho", "cho"], ["mot", "mot"], ["chut.", "chut"]],
	[["Ngon", "ngon"], ["lam.", "lam"]],
],

"wolof": [
	[["Naata", "ñaata"], ["la?", "la"]],
	[["Jerejef.", "jerejef"]],
	[["Dafa", "dafa"], ["tang.", "tang"]],
	[["Dafa", "dafa"], ["seer.", "seer"]],
	[["Ndank", "ndank"], ["ndank.", "ndank"]],
	[["Sant", "sant"], ["wi?", "wi"]],
	[["Waaw,", "waaw"], ["waaw.", "waaw"]],
	[["Ba", "ba"], ["beneen.", "beneen"]],
],

"georgian": [
	[["Ramdeni", "ramdeni"], ["girs?", "girs"]],
	[["Madloba.", "madloba"]],
	[["Dzalian", "dzalian"], ["dzviria.", "dzviria"]],
	[["Ra", "ra"], ["aris", "aris"], ["es?", "es"]],
	[["Ki,", "ki"], ["ki.", "ki"]],
	[["Ar", "ar"], ["vici.", "vici"]],
	[["Modi", "modi"], ["aq.", "aq"]],
	[["Kargia.", "kargia"]],
],

"spanish_mx": [
	[["Cuanto", "cuanto"], ["es?", "es"]],
	[["Ahorita", "ahorita"], ["voy.", "voy"]],
	[["Mande?", "mande"]],
	[["Esta", "esta"], ["muy", "muy"], ["caro.", "caro"]],
	[["Aguas!", "aguas"]],
	[["Orale.", "orale"]],
	[["No", "no"], ["manches.", "manches"]],
	[["Un", "un"], ["poquito", "poquito"], ["mas.", "mas"]],
	[["Gracias,", "gracias"], ["joven.", "joven"]],
	[["Ahi", "ahi"], ["se", "se"], ["ve.", "ve"]],
],

"spanish_bo": [
	[["Cuanto", "cuanto"], ["cuesta?", "cuesta"]],
	[["Ya", "ya"], ["pues.", "pues"]],
	[["Casera,", "casera"], ["la", "la"], ["yapa.", "yapa"]],
	[["Esta", "esta"], ["caro,", "caro"], ["pues.", "pues"]],
	[["Una", "una"], ["libra", "libra"], ["nomas.", "nomas"]],
	[["Gracias,", "gracias"], ["casera.", "casera"]],
	[["De", "de"], ["donde", "donde"], ["eres?", "eres"]],
	[["Hace", "hace"], ["frio.", "frio"]],
],

"portuguese": [
	[["Quanto", "quanto"], ["e?", "e"]],
	[["Ta", "ta"], ["bom.", "bom"]],
	[["Muito", "muito"], ["caro,", "caro"], ["mano.", "mano"]],
	[["Relaxa.", "relaxa"]],
	[["Obrigado.", "obrigado"]],
	[["Ta", "ta"], ["quente", "quente"], ["hoje.", "hoje"]],
	[["Nossa,", "nossa"], ["demais!", "demais"]],
	[["Fica", "fica"], ["longe?", "longe"]],
	[["Vamos", "vamos"], ["la.", "la"]],
],
}


static func has_language(language: String) -> bool:
	return GREET.has(language) or TALK.has(language)


static func greetings(language: String, part: String) -> Array:
	var per: Dictionary = GREET.get(language, {})
	return per.get(part, per.get("morning", []))


static func talk(language: String) -> Array:
	return TALK.get(language, [])
