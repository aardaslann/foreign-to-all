extends RefCounted

# Short service encounters keep the practical reason for using a language.
# The allowance covers the price; it does not answer the person at the desk.
# [room question, room word, one-night question, ticket question, ticket word]
const LINES := {
	"berlin": ["Ein Zimmer?", "zimmer", "Eine Nacht?", "Eine Fahrkarte?", "fahrkarte"],
	"london": ["A room?", "room", "Just the one night?", "A single?", "single"],
	"paris": ["Une chambre ?", "chambre", "Une nuit ?", "Un ticket ?", "ticket"],
	"moscow": ["Номер?", "nomer", "На одну ночь?", "Билет?", "bilet"],
	"istanbul": ["Bir oda?", "oda", "Bir gece?", "Bir bilet?", "bilet"],
	"mumbai": ["एक कमरा?", "kamra", "एक रात?", "एक टिकट?", "tikat"],
	"tokyo": ["お部屋ですか？", "heya", "一泊ですか？", "切符ですか？", "kippu"],
	"mexico": ["¿Una habitación?", "habitacion", "¿Una noche?", "¿Un boleto?", "boleto"],
}
const NIGHTS := {"berlin": "nacht", "london": "night", "paris": "nuit", "moscow": "noch",
	"istanbul": "gece", "mumbai": "raat", "tokyo": "ippaku", "mexico": "noche"}


static func request(kind: String) -> bool:
	var tree := Engine.get_main_loop() as SceneTree
	var dialogue := tree.get_first_node_in_group("dialogue_box")
	if dialogue == null or not LINES.has(GameState.city):
		return false
	var room: bool = kind == "room"
	var line: Array = LINES[GameState.city]
	var phrase: String = String(line[0 if room else 3])
	var word: String = String(line[1 if room else 4])
	var language: String = GameState.local_language()
	var id: String = "counter_" + GameState.city + "_" + kind
	var first: bool = not bool(GameState.world_flags.get(id + "_heard", false))
	GameState.world_flags[id + "_heard"] = true
	var who: Dictionary = {"name": "Reception" if room else "At the ticket machine",
		"relationship": "A practical conversation", "region": GameState.current_region,
		"grant": first, "person": {"build": "adult"}}
	var entry: Dictionary = {"keep": true, "silent": true,
		"voice": "counter_" + GameState.city,
		"stage": "The receptionist holds up a key, points upstairs, then waits for your answer." if room else "A traveller beside the machine points at its route diagram, then at a small paper ticket. They hold up one finger.",
		"words": [{"text": phrase, "word": word, "language": language}],
		"responses": [
			{"gesture": "Mime sleeping, then point to yourself" if room else "Point to one journey on the diagram",
				"words": phrase, "style": "gesture", "rep": 0, "choice": "one"},
			{"gesture": "Hold up several fingers. Perhaps they are asking how long you have travelled" if room else "Point at the return arrow. Perhaps it means the train is coming back",
				"style": "gesture", "rep": 0, "choice": "repair"},
			{"gesture": "Step away for now", "style": "gesture", "rep": 0, "choice": "leave"},
		]}
	var answer: Dictionary = await dialogue.ask(entry, who)
	SaveManager.checkpoint()
	if answer.is_empty() or answer.get("choice", "leave") == "leave":
		return false
	if answer.get("choice", "") == "repair":
		GameState.misunderstand(language, word, "I answered a different question at the counter")
		who["grant"] = false
		entry["stage"] = "They mark several nights on a little calendar. Then they point to tonight, hold up one finger, and wait." if room else "They trace the line out and back. Two journeys. Then they cover the return arrow and point at you: just one?"
		entry["words"] = [{"text": String(line[2]) if room else phrase,
			"word": NIGHTS[GameState.city] if room else word, "language": language}]
		entry["responses"] = [
			{"gesture": "Point to tonight. One night" if room else "Trace only the outward journey",
				"style": "gesture", "rep": 0, "choice": "one"},
			{"gesture": "Step away for now", "style": "gesture", "rep": 0, "choice": "leave"},
		]
		answer = await dialogue.ask(entry, who)
		if answer.is_empty() or answer.get("choice", "leave") != "one":
			return false
	return true


static func received(kind: String) -> void:
	var line: Array = LINES[GameState.city]
	var room: bool = kind == "room"
	var word: String = String(line[1 if room else 4])
	var meaning: String = "room — the key they gave me opens one upstairs" if room else "ticket — the thing I needed for this journey"
	if GameState.city == "london" and not room:
		meaning = "single — one journey, not a question about whether I have a partner"
	GameState.understand(GameState.local_language(), word, meaning,
		"At reception" if room else "At the ticket machine")
	Journey.record("A key" if room else "A ticket", meaning)
	SaveManager.checkpoint()
