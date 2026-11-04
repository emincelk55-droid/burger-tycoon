extends Node
## Hikaye motoru. Bölümler data/story/<id>.json dosyalarında "beat" listesi olarak yazılır.
##
## Beat türleri:
##   msg        {from, text, delay?}       Bir kişiden mesaj
##   system     {text}                     Sistem bildirimi (sohbette ortada görünür)
##   choice     {options:[{text, flag?, value?, goto?}]}
##   wait       {event, hint?, fail_event?, fail_goto?}  Oyuncunun bir şey yapmasını bekler
##   flag       {key, value}
##   unlock     {app}
##   goto       {target}
##   if_flag    {key, value, target}
##   end_chapter
## Her beat isteğe bağlı bir "id" alabilir; goto hedefleri bu id'lerdir.

signal message_added(entry: Dictionary)
signal choices_offered(options: Array)
signal choices_cleared
signal waiting_for(event: String, hint: String)
signal typing_changed(contact: String, active: bool)
signal app_unlocked(app: String)
signal chapter_finished(chapter_id: String)

const BEAT_TYPES := ["msg", "system", "choice", "wait", "flag", "unlock", "goto", "if_flag", "end_chapter"]

## Testlerde beklemeleri kapatmak için.
var fast_mode := false
## Mesajlar uygulaması açıkken okunmamış sayısı artmaz.
var viewing_messages := false

var chapter: Dictionary = {}
var beats: Array = []
var _labels: Dictionary = {}
var _running := false
var _pending_choices: Array = []
var _waiting: Dictionary = {}
var _typing_contact := ""
## İlerleme sıfırlanınca artar; yarıda kalmış beklemeler eski duruma yazmasın diye.
var _generation := 0


func _ready() -> void:
	GameState.progress_reset.connect(_on_progress_reset)


func _on_progress_reset() -> void:
	_generation += 1
	_running = false
	_set_typing("", false)
	load_chapter(str(state().get("chapter", "ch00")))


func load_chapter(id: String) -> bool:
	var data := read_chapter(id)
	if data.is_empty():
		return false
	chapter = data
	beats = chapter.get("beats", [])
	_labels = index_labels(beats)
	_pending_choices = []
	_waiting = {}
	return true


static func read_chapter(id: String) -> Dictionary:
	var path := "res://data/story/%s.json" % id
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("Bölüm bulunamadı: " + path)
		return {}
	var data: Variant = JSON.parse_string(f.get_as_text())
	if typeof(data) != TYPE_DICTIONARY:
		push_error("Bölüm dosyası bozuk: " + path)
		return {}
	return data


static func index_labels(list: Array) -> Dictionary:
	var out := {}
	for i in list.size():
		var b: Dictionary = list[i]
		if b.has("id"):
			out[str(b["id"])] = i
	return out


func state() -> Dictionary:
	return GameState.story


func is_done() -> bool:
	return bool(state().get("done", false))


func pending_choices() -> Array:
	return _pending_choices


func current_hint() -> String:
	return Loc.pick(_waiting.get("hint", "")) if not _waiting.is_empty() else ""


func current_wait_event() -> String:
	return str(_waiting.get("event", ""))


func typing_contact() -> String:
	return _typing_contact


func contact_name(id: String) -> String:
	var contacts: Dictionary = chapter.get("contacts", {})
	if contacts.has(id):
		return Loc.pick(contacts[id].get("name", id))
	return id.to_upper()


func is_unlocked(app: String) -> bool:
	return (state().get("unlocked", []) as Array).has(app)


func start() -> void:
	if chapter.is_empty():
		load_chapter(str(state().get("chapter", "ch00")))
	if is_done():
		return
	_run()


## Oyuncu bir seçenek seçti.
func choose(index: int) -> void:
	if index < 0 or index >= _pending_choices.size():
		return
	var opt: Dictionary = _pending_choices[index]
	_pending_choices = []
	choices_cleared.emit()
	_add_log({"kind": "me", "from": "me", "text": opt.get("text", "")})
	if opt.has("flag"):
		state()["flags"][str(opt["flag"])] = opt.get("value", true)
	if opt.has("goto"):
		_jump(str(opt["goto"]))
	else:
		_advance()
	_run()


## Uygulamalar olay gönderir: "cmd:scan", "cmd:connect:host", "minigame:breach:success" gibi.
## Beklenen olaysa hikaye ilerler ve true döner.
func post_event(event: String) -> bool:
	if _waiting.is_empty():
		return false
	if event == str(_waiting.get("event", "")):
		_waiting = {}
		_advance()
		_run()
		return true
	if _waiting.has("fail_event") and event == str(_waiting["fail_event"]):
		var target := str(_waiting.get("fail_goto", ""))
		_waiting = {}
		if target != "":
			_jump(target)
		_run()
		return true
	return false


func _run() -> void:
	if _running:
		return
	_running = true
	var gen := _generation
	while true:
		var i := int(state().get("beat", 0))
		if i >= beats.size():
			break
		var b: Dictionary = beats[i]
		var kind := str(b.get("type", ""))
		match kind:
			"msg", "system":
				var delay := 0.0 if fast_mode else float(b.get("delay", _auto_delay(b)))
				if delay > 0.0:
					_set_typing(str(b.get("from", "")) if kind == "msg" else "", true)
					await get_tree().create_timer(delay).timeout
					if gen != _generation:
						return
					_set_typing("", false)
				_add_log({"kind": kind, "from": str(b.get("from", "")), "text": b.get("text", "")})
				_advance()
			"choice":
				_pending_choices = b.get("options", [])
				GameState.save_game()
				choices_offered.emit(_pending_choices)
				_running = false
				return
			"wait":
				_waiting = b
				GameState.save_game()
				waiting_for.emit(str(b.get("event", "")), current_hint())
				_running = false
				return
			"flag":
				state()["flags"][str(b.get("key", ""))] = b.get("value", true)
				_advance()
			"unlock":
				var app := str(b.get("app", ""))
				var unlocked: Array = state()["unlocked"]
				if not unlocked.has(app):
					unlocked.append(app)
				app_unlocked.emit(app)
				_advance()
			"goto":
				_jump(str(b.get("target", "")))
			"if_flag":
				if state()["flags"].get(str(b.get("key", ""))) == b.get("value"):
					_jump(str(b.get("target", "")))
				else:
					_advance()
			"end_chapter":
				state()["done"] = true
				GameState.save_game()
				_running = false
				chapter_finished.emit(str(chapter.get("id", "")))
				return
			_:
				push_warning("Bilinmeyen beat türü: " + kind)
				_advance()
	_running = false
	GameState.save_game()


func _auto_delay(b: Dictionary) -> float:
	if str(b.get("type", "")) == "system":
		return 0.5
	var length := Loc.pick(b.get("text", "")).length()
	return clampf(0.6 + length * 0.018, 0.8, 2.6)


func _set_typing(contact: String, active: bool) -> void:
	_typing_contact = contact if active else ""
	typing_changed.emit(contact, active)


func _advance() -> void:
	state()["beat"] = int(state().get("beat", 0)) + 1


func _jump(label: String) -> void:
	if _labels.has(label):
		state()["beat"] = int(_labels[label])
	else:
		push_error("goto hedefi bulunamadı: " + label)
		_advance()


func _add_log(entry: Dictionary) -> void:
	state()["log"].append(entry)
	if entry["kind"] == "msg" and not viewing_messages:
		state()["unread"] = int(state().get("unread", 0)) + 1
	message_added.emit(entry)


## Sıradaki bölümün kimliği ("" ise yok).
func next_chapter_id() -> String:
	var nxt := str(chapter.get("next", ""))
	if nxt == "" or not FileAccess.file_exists("res://data/story/%s.json" % nxt):
		return ""
	return nxt


## Bitmiş bölümden sonrakine geçer. Bayraklar, açılan uygulamalar ve sohbet geçmişi korunur.
func advance_chapter() -> bool:
	var nxt := next_chapter_id()
	if nxt == "" or not is_done():
		return false
	var st := state()
	st["chapter"] = nxt
	st["beat"] = 0
	st["done"] = false
	st["network"] = {"known": [], "breached": [], "connected": ""}
	if not load_chapter(nxt):
		return false
	_add_log({"kind": "system", "from": "", "text": chapter.get("title", "")})
	GameState.save_game()
	_run()
	return true


func mark_read() -> void:
	state()["unread"] = 0
