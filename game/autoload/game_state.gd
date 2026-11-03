extends Node
## Kalıcı oyun durumu: ayarlar, hikaye ilerlemesi ve "iz" seviyesi.
## Her şey tek bir JSON dosyasında (user://save.json) tutulur.

signal language_changed(lang: String)
signal trace_changed(value: float)
signal progress_reset

const SAVE_VERSION := 1
const LANGUAGES := ["tr", "en"]

var save_path := "user://save.json"
var settings := {"lang": "tr", "vibration": true}
var story := {}
## 0-100 arası. ARGOS'un seni ne kadar fark ettiğini gösterir.
var trace := 0.0


func _ready() -> void:
	load_game()


static func default_story_state() -> Dictionary:
	return {
		"chapter": "ch00",
		"beat": 0,
		"flags": {},
		"log": [],
		"unlocked": [],
		"network": {"known": [], "breached": [], "connected": ""},
		"unread": 0,
		"done": false,
	}


func load_game() -> void:
	story = default_story_state()
	trace = 0.0
	if not FileAccess.file_exists(save_path):
		return
	var f := FileAccess.open(save_path, FileAccess.READ)
	if f == null:
		return
	var data: Variant = JSON.parse_string(f.get_as_text())
	if typeof(data) != TYPE_DICTIONARY:
		push_warning("Kayıt dosyası okunamadı, sıfırdan başlanıyor.")
		return
	if int(data.get("version", 0)) != SAVE_VERSION:
		return
	settings.merge(data.get("settings", {}), true)
	story.merge(data.get("story", {}), true)
	trace = float(data.get("trace", 0.0))
	if not LANGUAGES.has(settings.get("lang", "tr")):
		settings["lang"] = "tr"


func save_game() -> void:
	var f := FileAccess.open(save_path, FileAccess.WRITE)
	if f == null:
		push_warning("Kayıt yazılamadı: %s" % FileAccess.get_open_error())
		return
	f.store_string(JSON.stringify({
		"version": SAVE_VERSION,
		"settings": settings,
		"story": story,
		"trace": trace,
	}))


func reset_progress() -> void:
	story = default_story_state()
	trace = 0.0
	save_game()
	trace_changed.emit(trace)
	progress_reset.emit()


func set_language(lang: String) -> void:
	if not LANGUAGES.has(lang) or settings.get("lang") == lang:
		return
	settings["lang"] = lang
	save_game()
	language_changed.emit(lang)


func add_trace(amount: float) -> void:
	trace = clampf(trace + amount, 0.0, 100.0)
	trace_changed.emit(trace)


func vibrate(ms: int = 40) -> void:
	if settings.get("vibration", true) and OS.has_feature("mobile"):
		Input.vibrate_handheld(ms)
