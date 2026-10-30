extends RefCounted

# Scaffolding for following a sentence, not evidence that a meaning was earned.
# Particles and prepositions retain their ambiguity instead of promising a
# one-to-one translation in every sentence.
const WORDS := {
	"german": {
		"ich":"I", "icke":"I (Berlin speech)", "mich":"me", "mir":"to me / for me",
		"du":"you (one person, familiar)", "dir":"to you / for you", "dich":"you",
		"er":"he", "sie":"she / they; polite you when capitalised", "es":"it", "wir":"we", "uns":"us",
		"und":"and", "oder":"or", "aber":"but", "auch":"also / too", "nur":"only",
		"fur":"for", "f\u00fcr":"for", "mit":"with", "ohne":"without", "von":"from / of",
		"zu":"to / at", "auf":"on / onto", "in":"in / into", "im":"in the", "am":"at the / on the",
		"der":"the; its form depends on the noun and sentence", "die":"the / those; sometimes they",
		"das":"the / that", "den":"the (one of its forms)", "dem":"the (one of its forms)",
		"ein":"a / one", "eine":"a / one", "ist":"is", "bin":"am", "sind":"are",
		"nicht":"not", "kein":"no / not a", "keine":"no / not any", "ja":"yes", "nein":"no",
		"mein":"my", "dein":"your", "da":"there / here, depending on the gesture", "dann":"then",
		"wenn":"if / when", "weil":"because", "noch":"still / another", "schon":"already",
		# Kerstin and Emil speak Berlinerisch. These are the small words as they
		# actually say them, so the dialect does not hide what the hints explain.
		"ick":"I (Berlin speech for ich)", "dit":"this / that (Berlin speech for das)",
		"wat":"what (Berlin speech for was)", "nich":"not (Berlin speech for nicht)",
		"keen":"no / not a (Berlin speech for kein)", "ooch":"also / too (Berlin speech for auch)",
		"is":"is (spoken ist)", "allet":"everything (Berlin speech for alles)",
		"uff":"on / onto (Berlin speech for auf)", "jut":"good / fine (Berlin speech for gut)",
		"ma":"just / for a moment; softens a request (spoken mal)",
		"wa":"right? A tag at the end of a sentence", "na":"well? / so; a nudge or a hello",
		"nee":"no (casual)", "denn":"then (Berlin speech for dann)",
		"ne":"a (short for eine)", "nen":"a (short for einen)", "ner":"a (short for einer)",
		"se":"she / them; with a stranger, polite you (spoken sie / Sie)",
		"hab":"have (short for habe)", "biste":"you are (bist du, run together)",
		"kannste":"can you (kannst du, run together)", "weeß":"know (Berlin speech for weiß)",
		"weeßte":"you know (weißt du, run together)", "rin":"in, inside (Berlin speech for herein)",
		"hier":"here", "wie":"how / like / as", "so":"so / like this", "erst":"first / not until",
		"her":"towards the speaker; with wo, from where", "aus":"out / from",
		"ihn":"him", "war":"was", "weg":"away / gone", "ach":"oh / ah",
		"mensch":"person; as an exclamation, man! / oh boy"
	},
	"turkish": {
		"ben":"I", "beni":"me", "bana":"to me", "sen":"you (familiar)", "sana":"to you",
		"siz":"you (polite or plural)", "biz":"we", "o":"he / she / it / that", "onlar":"they",
		"ve":"and", "ama":"but", "veya":"or", "icin":"for", "i\u00e7in":"for", "ile":"with",
		"bu":"this", "bir":"a / one", "de":"also / too (as a separate word)", "da":"also / too (as a separate word)",
		"mi":"marks a question", "m\u0131":"marks a question", "mu":"marks a question", "m\u00fc":"marks a question",
		"var":"there is / have", "yok":"there is not / do not have", "degil":"not", "de\u011fil":"not",
		"evet":"yes", "hayir":"no", "hay\u0131r":"no", "cok":"very / much", "\u00e7ok":"very / much",
		"az":"a little / few", "sonra":"after / later", "once":"before", "\u00f6nce":"before",
		# The small words this city’s own story lines use most.
		"olsun":"let it be / may it be", "benimki":"mine (my one)", "benim":"my / mine",
		"tabii":"of course", "misin":"are you / will you? after a verb (ister misin? would you like?)", "mısın":"are you / will you? after a verb",
		"abi":"big brother; a warm, respectful way to address an older man", "tamam":"okay / all right", "böyle":"like this",
		"öyle":"like that / so", "lütfen":"please", "şunu":"that one (the thing pointed at)",
		"bunu":"this one", "sadece":"only / just", "biraz":"a little",
		"kendim":"myself", "ne":"what", "sorun":"problem; sorun değil, no problem",
		"kusura":"in kusura bakma: sorry, excuse me", "bakma":"do not look; in kusura bakma: sorry", "yine":"again"
	},
	"english": {
		"i":"the person speaking", "me":"the speaker as the person affected", "you":"the person being addressed",
		"we":"the speaker and others", "us":"the speaker and others, as people affected", "they":"other people or a person",
		"my":"belonging to me", "your":"belonging to you", "and":"joins two things", "or":"offers alternatives",
		"for":"intended for / because of; depends on the phrase", "to":"towards / introduces an action", "of":"belonging to / part of",
		"with":"together with", "without":"not having", "but":"introduces a contrast", "a":"one, not yet specified",
		"the":"a particular one", "in":"inside / within", "on":"resting on / about", "at":"a place or time",
		"is":"a form of be", "not":"makes a statement negative", "if":"introduces a condition", "then":"after that"
	},
	"french": {
		"je":"I", "j":"I, shortened before a vowel", "moi":"me", "me":"me / to me", "tu":"you (familiar)",
		"toi":"you", "vous":"you (polite or plural)", "nous":"we / us", "il":"he / it", "elle":"she / it",
		"et":"and", "ou":"or", "mais":"but", "pour":"for", "avec":"with", "sans":"without",
		"de":"of / from", "du":"of the / some", "des":"some / of the", "a":"has; with an accent, to / at",
		"\u00e0":"to / at", "au":"to the / at the", "en":"in / some of it", "dans":"in / inside",
		"le":"the / him / it", "la":"the / her / it", "les":"the / them", "un":"a / one", "une":"a / one",
		"est":"is", "sont":"are", "pas":"not, often paired with ne", "ne":"part of a negative expression",
		"ce":"this / that", "oui":"yes", "non":"no", "si":"if / yes in reply to a negative", "aussi":"also / too",
		# The small words this city’s own story lines use most.
		"on":"we / people in general; spoken French often says on for nous", "ça":"that / it", "mon":"my",
		"ma":"my", "mes":"my (several things)", "votre":"your (polite or plural)",
		"ton":"your (familiar)", "lui":"him / to him / to her", "peux":"can (I can / you can)",
		"sil":"if it; in s’il vous plaît, please", "plaît":"pleases; in s’il vous plaît, please", "va":"goes",
		"maintenant":"now", "quoi":"what", "comment":"how",
		"alors":"so / well then", "enfin":"well… / at last", "là":"there / here",
		"cette":"this / that (before a noun)", "te":"you / to you (familiar)", "ses":"his / her (several things)",
		"daccord":"okay, agreed (d’accord)", "ensemble":"together"
	},
	"russian": {
		"ya":"I", "menya":"me / of me", "mne":"to me", "ty":"you (familiar)", "tebe":"to you",
		"vy":"you (polite or plural)", "my":"we", "on":"he", "ona":"she", "oni":"they",
		"i":"and / also", "a":"and / but, marking a contrast", "no":"but", "ili":"or", "dlya":"for",
		"s":"with / from", "bez":"without", "v":"in / into", "na":"on / at / onto", "k":"towards / to",
		"u":"at / in someone's possession", "iz":"out of / from", "eto":"this / that / it is",
		"da":"yes", "net":"no / there is not", "ne":"not", "tozhe":"also / too", "uzhe":"already",
		# The small words this city’s own story lines use most.
		"vot":"here is / this, while pointing", "etu":"this one (as the thing acted on)", "eta":"this (feminine)",
		"etot":"this (masculine)", "etogo":"this / of this", "etom":"this; ob etom, about this",
		"chto":"what / that", "nado":"need to / must", "prosto":"just / simply",
		"zdes":"here", "kak":"how / as", "tak":"so / like this",
		"za":"for / behind", "ob":"about", "tebya":"you (familiar, as the person acted on)",
		"nu":"well…", "by":"would; makes a wish or a maybe", "takoy":"such a",
		"vchera":"yesterday", "khochu":"I want", "bylo":"was"
	},
	"hindi": {
		"main":"I", "mujhe":"to me / me", "mera":"my (one form)", "meri":"my (one form)",
		"aap":"you (respectful)", "tum":"you (familiar)", "hum":"we", "yeh":"this / these", "woh":"that / those",
		"aur":"and / more", "ya":"or", "lekin":"but", "ke":"of / belonging to (one form); part of other phrases",
		"ka":"of / belonging to (one form)", "ki":"of / belonging to; also that in a clause", "liye":"for, in ke liye",
		"ko":"to; also marks a person or thing affected", "se":"from / with / than", "mein":"in",
		"par":"on / at; sometimes but", "bhi":"also / too", "hi":"only / exactly, for emphasis",
		"hai":"is", "hain":"are / polite is", "nahi":"not / no", "nahin":"not / no", "haan":"yes", "ek":"one / a",
		# The small words this city’s own story lines use most.
		"kya":"what; also turns a sentence into a yes/no question", "hoon":"am; main … hoon, I am / I do", "toh":"so / then",
		"bas":"just / enough", "chahiye":"is needed / should", "aaj":"today",
		"kal":"yesterday or tomorrow, from context", "yahin":"right here", "sab":"all / everything",
		"pehle":"first / before", "paas":"near / with", "kaise":"how",
		"kis":"which / whom", "itni":"this much / so much", "zaroori":"necessary",
		"karke":"by doing; ek-ek karke, one by one"
	},
	"japanese": {
		"watashi":"I / me", "boku":"I / me (one way of referring to oneself)", "anata":"you; names are often preferred",
		"kore":"this thing", "sore":"that thing near you", "are":"that thing over there", "kono":"this, before a noun",
		"sono":"that, before a noun", "wa":"marks what the sentence is about", "ga":"marks a subject / focus",
		"o":"marks the thing an action affects", "wo":"marks the thing an action affects", "ni":"to / at; marks a time or destination",
		"de":"at / using / by means of", "to":"with / and; also marks a quotation", "no":"of / belonging to; links nouns",
		"mo":"also / too", "ka":"often marks a question", "ne":"invites agreement or shared attention",
		"yo":"adds emphasis or new information", "kara":"from / because", "made":"until / as far as",
		"desu":"polite sentence ending, often like is", "hai":"yes / I hear you", "iie":"no",
		# The small words this city’s own story lines use most.
		"ii":"good / fine; ii desu ka, is it all right?", "demo":"but", "kudasai":"please (after a verb)",
		"mada":"still / not yet", "koko":"here", "soko":"there (near you)",
		"kocchi":"this one / this way", "docchi":"which one (of two)", "douzo":"please, go ahead / here you are",
		"arimasu":"there is / have (polite)", "wakarimashita":"understood / I see", "dake":"only / just",
		"mou":"more / already; mou sukoshi, a little more", "sukoshi":"a little", "itsu":"when",
		"dou":"how", "nara":"if it is", "nanika":"something / anything",
		"minna":"everyone", "aa":"ah / oh"
	},
	"spanish_mx": {
		"yo":"I", "me":"me / to me", "mi":"my", "m\u00ed":"me after a preposition", "tu":"your; with an accent, you",
		"t\u00fa":"you (familiar)", "te":"you / to you", "usted":"you (polite)", "nos":"us / to us", "nosotros":"we",
		"el":"the; with an accent, he", "\u00e9l":"he", "ella":"she", "ellos":"they", "la":"the / her / it",
		"los":"the / them", "las":"the / them", "un":"a / one", "una":"a / one", "y":"and", "o":"or",
		"pero":"but", "para":"for / in order to", "por":"for / through / because of; depends on the phrase",
		"con":"with", "sin":"without", "de":"of / from", "del":"of the / from the", "a":"to / at",
		"al":"to the / at the", "en":"in / on / at", "es":"is", "son":"are", "no":"no / not",
		"s\u00ed":"yes", "si":"if", "que":"that / which; with an accent, what", "qu\u00e9":"what", "tambien":"also / too", "tambi\u00e9n":"also / too",
		# The small words this city’s own story lines use most.
		"se":"oneself / itself; se ve, it looks", "así":"like this / so", "lo":"it / him",
		"le":"to him / to her", "ni":"nor / not even", "entonces":"so / then",
		"esta":"this (before a noun)", "este":"this", "esto":"this (thing)",
		"está":"is (where or how something is)", "ahí":"there", "aquí":"here",
		"allá":"over there", "junto":"next to (junto a)", "todavía":"still / yet",
		"claro":"of course", "cómo":"how", "más":"more",
		"hay":"there is / there are", "hoy":"today", "bien":"well / fine",
		"todos":"all / everyone", "quiero":"I want", "quieres":"you want",
		"favor":"favour; por favor, please", "gracias":"thank you", "otra":"another / other",
		"otro":"another / other"
	}
}

static func meaning(language: String, word: String) -> String:
	return String(Dictionary(WORDS.get(language, {})).get(word.to_lower(), ""))
