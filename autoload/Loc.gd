extends Node

# Twenty selectable interface languages. English is complete for this beta;
# the other tables are previews and newer screens can fall back to English.
#
# Not everybody who plays this speaks English, and a game whose entire subject
# is being unable to read the room should not hand a Turkish player a menu in
# a language they have to decode. The player picks a language the first time
# the game opens. Preview status is shown in the selected language.
#
# ── What is NOT translated, on purpose ───────────────────────────────────────
#
# The words spoken in a city. Brot stays Brot, bilet stays bilet, ekmek stays
# ekmek - those are what he is there to learn, and translating them would
# delete the game. What is translated is everything the game says AS ITSELF:
# menus, the journal, the quest log, what a counter is asking you for.
#
# ── Why the translations live in GDScript ────────────────────────────────────
#
# Godot's usual route is a .csv the editor compiles into .translation
# resources. There is no editor on this machine - every tool here runs
# headless with --script - so the tables are data and the Translation objects
# are built at startup. Same result, no import step, and it can be checked by
# a script.

signal language_changed(locale: String)

const SETTINGS_PATH := "user://language.cfg"

# A class-level const, not a preload inside the function: `var d := preload(x)`
# types d as GDScript, and GDScript has no KEYS on it, so every lookup came
# back empty and every string in the game rendered as its own key. This is how
# the rest of the project reaches a script and it resolves properly.
const TEXT := preload("res://autoload/LocText.gd")

# The twenty most-spoken languages in the world, by total speakers. Each is
# named in ITSELF, because a picker that lists languages in English is the
# exact joke this game is about.
const LANGS := [
	["en",  "English"],
	["zh",  "\u4e2d\u6587"],
	["hi",  "\u0939\u093f\u0928\u094d\u0926\u0940"],
	["es",  "Espa\u00f1ol"],
	["ar",  "\u0627\u0644\u0639\u0631\u0628\u064a\u0629"],
	["fr",  "Fran\u00e7ais"],
	["bn",  "\u09ac\u09be\u0982\u09b2\u09be"],
	["pt",  "Portugu\u00eas"],
	["ru",  "\u0420\u0443\u0441\u0441\u043a\u0438\u0439"],
	["ur",  "\u0627\u0631\u062f\u0648"],
	["id",  "Bahasa Indonesia"],
	["de",  "Deutsch"],
	["ja",  "\u65e5\u672c\u8a9e"],
	["mr",  "\u092e\u0930\u093e\u0920\u0940"],
	["te",  "\u0c24\u0c46\u0c32\u0c41\u0c17\u0c41"],
	["tr",  "T\u00fcrk\u00e7e"],
	["ta",  "\u0ba4\u0bae\u0bbf\u0bb4\u0bcd"],
	["yue", "\u5ee3\u6771\u8a71"],
	["vi",  "Ti\u1ebfng Vi\u1ec7t"],
	["ko",  "\ud55c\uad6d\uc5b4"],
]

# Written right to left, so the interface has to mirror for them.
const RTL := ["ar", "ur"]

const SUPPORT_NOTICES := {
	"en":"English: complete beta interface. Other languages are translation previews.",
	"zh":"测试版：此翻译尚未完成。部分菜单仍为英语。",
	"hi":"बीटा: यह अनुवाद अधूरा है। कुछ मेनू अभी अंग्रेज़ी में हैं।",
	"es":"Beta: traducción incompleta. Algunos menús siguen en inglés.",
	"ar":"نسخة تجريبية: الترجمة غير مكتملة. بعض القوائم لا تزال باللغة الإنجليزية.",
	"fr":"Bêta : traduction incomplète. Certains menus restent en anglais.",
	"bn":"বিটা: এই অনুবাদ অসম্পূর্ণ। কিছু মেনু এখনও ইংরেজিতে আছে।",
	"pt":"Beta: tradução incompleta. Alguns menus continuam em inglês.",
	"ru":"Бета: перевод не завершён. Некоторые меню пока на английском.",
	"ur":"بیٹا: یہ ترجمہ نامکمل ہے۔ کچھ مینیو ابھی انگریزی میں ہیں۔",
	"id":"Beta: terjemahan belum lengkap. Sebagian menu masih berbahasa Inggris.",
	"de":"Beta: unvollständige Übersetzung. Einige Menüs sind noch auf Englisch.",
	"ja":"ベータ版：翻訳は未完成です。一部のメニューは英語のままです。",
	"mr":"बीटा: हे भाषांतर अपूर्ण आहे. काही मेनू अजून इंग्रजीत आहेत.",
	"te":"బీటా: ఈ అనువాదం అసంపూర్ణంగా ఉంది. కొన్ని మెనూలు ఇంకా ఆంగ్లంలో ఉన్నాయి.",
	"tr":"Beta: çeviri henüz tamamlanmadı. Bazı menüler İngilizce olarak kalır.",
	"ta":"பீட்டா: இந்த மொழிபெயர்ப்பு முழுமையடையவில்லை. சில மெனுக்கள் இன்னும் ஆங்கிலத்தில் உள்ளன.",
	"yue":"測試版：翻譯未完成，部分選單仍然係英文。",
	"vi":"Bản beta: bản dịch chưa hoàn chỉnh. Một số menu vẫn bằng tiếng Anh.",
	"ko":"베타: 번역이 아직 완성되지 않았습니다. 일부 메뉴는 영어로 표시됩니다."
}


func support_notice(code: String = "") -> String:
	return SUPPORT_NOTICES.get(locale() if code.is_empty() else code, SUPPORT_NOTICES.en)

var registered: int = 0
var _locale: String = ""
var _picked: bool = false


# _enter_tree, not _ready: a tool that runs as its own SceneTree does its work
# in _initialize(), which happens BEFORE autoload _ready. Registering there
# means every string comes back as its own key in every render and every
# check, which is a thing that would be noticed far too late.
# _init, not _ready and not _enter_tree.
#
# An autoload EXISTS as an object before it enters the tree, and a tool that
# runs as its own SceneTree does all its work in _initialize() - which is
# before both callbacks. Registering in either of them means every render and
# every check sees strings that are still their own keys, which is a fault
# that would be noticed once, late, in a screenshot.
#
# The constructor needs nothing from the tree, so it is the honest place.
func _init() -> void:
	_boot()


func _boot() -> void:
	if registered > 0:
		return
	_load_choice()
	_register()
	if not _locale.is_empty():
		TranslationServer.set_locale(_locale)


func has_picked() -> bool:
	return _picked


func locale() -> String:
	return _locale if not _locale.is_empty() else "en"


func is_rtl() -> bool:
	return RTL.has(locale())


func language_name(code: String) -> String:
	for row: Array in LANGS:
		if String(row[0]) == code:
			return String(row[1])
	return code


func set_language(code: String) -> void:
	_locale = code
	_picked = true
	TranslationServer.set_locale(code)
	_save_choice()
	language_changed.emit(code)


func _load_choice() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) != OK:
		return
	_locale = String(cfg.get_value("language", "locale", ""))
	_picked = not _locale.is_empty()


func _save_choice() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("language", "locale", _locale)
	cfg.save(SETTINGS_PATH)


# Build one Translation per language out of the tables and hand them to the
# engine, so tr() works everywhere with no further ceremony.
func _register() -> void:
	var keys: Array = TEXT.KEYS
	for row: Array in LANGS:
		var code: String = String(row[0])
		var words: Array = TEXT.TABLE.get(code, [])
		if words.is_empty():
			continue
		var t := Translation.new()
		t.locale = code
		for i in range(mini(keys.size(), words.size())):
			t.add_message(String(keys[i]), String(words[i]))
		TranslationServer.add_translation(t)
		registered += 1
