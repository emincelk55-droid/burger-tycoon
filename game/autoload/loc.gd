extends Node
## Basit çeviri sistemi. Arayüz metinleri data/i18n/<dil>.json dosyalarında durur.
## Hikaye metinleri ise doğrudan {"tr": "...", "en": "..."} sözlükleri olarak yazılır.

signal changed

var lang := "tr"
var _strings: Dictionary = {}


func _ready() -> void:
	load_language(str(GameState.settings.get("lang", "tr")))
	GameState.language_changed.connect(load_language)


func load_language(new_lang: String) -> void:
	lang = new_lang
	_strings = read_table(new_lang)
	changed.emit()


static func read_table(table_lang: String) -> Dictionary:
	var path := "res://data/i18n/%s.json" % table_lang
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("Dil dosyası bulunamadı: " + path)
		return {}
	var data: Variant = JSON.parse_string(f.get_as_text())
	return data if typeof(data) == TYPE_DICTIONARY else {}


## Arayüz metni. Örnek: Loc.t("term.connected", {"host": "x"})
func t(key: String, args: Dictionary = {}) -> String:
	var s := str(_strings.get(key, key))
	return s.format(args) if not args.is_empty() else s


## Hikaye metni: {"tr": "...", "en": "..."} ya da düz metin.
func pick(value: Variant) -> String:
	if value is Dictionary:
		return str(value.get(lang, value.get("tr", "")))
	return "" if value == null else str(value)
