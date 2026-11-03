class_name PhoneOS
extends Control
## Deniz'in telefonu: oyunun ana merkezi. Ana menü yerine bu ekran kullanılır.

signal restart_requested

const APPS := [
	{"id": "messages", "color": "ffab4c"},
	{"id": "terminal", "color": "4fd1c5"},
	{"id": "map", "color": "6fe3a0"},
	{"id": "settings", "color": "8f9bb8"},
]
## Bu uygulamalar hikayede açılana kadar kilitlidir.
const STORY_LOCKED := ["terminal", "map"]

var open_app: AppWindow
var _icons: Dictionary = {}
var _clock: Label
var _date: Label
var _status_time: Label
var _banner: PanelContainer
var _banner_text: Label
var _banner_tween: Tween
## Oyun içi saat 02:47'de başlar ve gerçek zamanla ilerler.
var _game_minutes := 2 * 60 + 47.0


func _ready() -> void:
	UIKit.full_rect(self)
	var wall := Skyline.new()
	add_child(UIKit.full_rect(wall))

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	add_child(UIKit.full_rect(col))

	# Durum çubuğu
	var status := HBoxContainer.new()
	_status_time = UIKit.label("", UIKit.FONT_SMALL, UIKit.TEXT, false)
	status.add_child(_status_time)
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status.add_child(sp)
	status.add_child(UIKit.label(Loc.t("os.carrier"), UIKit.FONT_SMALL, UIKit.MUTED, false))
	col.add_child(UIKit.margin(status, 28, 14 + int(UIKit.safe_top(self)), 28, 0))

	# Büyük saat
	var clock_box := VBoxContainer.new()
	clock_box.add_theme_constant_override("separation", 0)
	_clock = UIKit.label("", 120, UIKit.TEXT, false)
	_clock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_date = UIKit.label(Loc.t("os.date"), UIKit.FONT_BODY, UIKit.MUTED, false)
	_date.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	clock_box.add_child(_clock)
	clock_box.add_child(_date)
	col.add_child(UIKit.margin(clock_box, 0, 60, 0, 0))

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(spacer)

	# Uygulama dok'u
	var dock := PanelContainer.new()
	dock.add_theme_stylebox_override("panel", UIKit.box(Color(UIKit.SURFACE, 0.82), 36, 24, UIKit.LINE, 2))
	var grid := GridContainer.new()
	grid.columns = APPS.size()
	grid.add_theme_constant_override("h_separation", 20)
	dock.add_child(grid)
	for a in APPS:
		var icon := AppIcon.new().setup(a["id"], Loc.t("app." + a["id"]), UIKit.color_hex(a["color"]))
		icon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		icon.activated.connect(open)
		grid.add_child(icon)
		_icons[a["id"]] = icon
	col.add_child(UIKit.margin(dock, 22, 0, 22, 48))

	_build_banner()
	_tick_clock()
	_refresh_icons()

	Story.message_added.connect(_on_message)
	Story.app_unlocked.connect(_on_unlocked)

	var t := Timer.new()
	t.wait_time = 1.0
	t.autostart = true
	t.timeout.connect(_on_second)
	add_child(t)


func _build_banner() -> void:
	_banner = PanelContainer.new()
	_banner.add_theme_stylebox_override("panel", UIKit.box(UIKit.SURFACE_2, 22, 20, UIKit.AMBER, 2))
	_banner.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_banner.offset_left = 20
	_banner.offset_right = -20
	_banner.offset_top = 20 + UIKit.safe_top(self)
	_banner.visible = false
	_banner.mouse_filter = Control.MOUSE_FILTER_STOP
	_banner.gui_input.connect(_on_banner_input)
	_banner_text = UIKit.label("", UIKit.FONT_BODY, UIKit.TEXT)
	_banner.add_child(_banner_text)
	add_child(_banner)


func open(app_id: String) -> void:
	if open_app != null:
		return
	if STORY_LOCKED.has(app_id) and not Story.is_unlocked(app_id):
		_show_banner(Loc.t("os.locked"))
		return
	var app: AppWindow
	match app_id:
		"messages":
			app = MessagesApp.new()
		"terminal":
			app = TerminalApp.new()
		"map":
			app = MapApp.new()
		"settings":
			var s := SettingsApp.new()
			s.restart_requested.connect(func() -> void: restart_requested.emit())
			app = s
		_:
			return
	app.close_requested.connect(close_app)
	open_app = app
	add_child(app)
	_banner.move_to_front()
	_hide_banner()


func close_app() -> void:
	if open_app == null:
		return
	open_app.queue_free()
	open_app = null
	_refresh_icons()


func _on_second() -> void:
	_game_minutes += 1.0 / 60.0
	_tick_clock()


func _tick_clock() -> void:
	var m := int(_game_minutes) % (24 * 60)
	var txt := "%02d:%02d" % [m / 60, m % 60]
	_clock.text = txt
	_status_time.text = txt


func _refresh_icons() -> void:
	for id in _icons:
		var icon: AppIcon = _icons[id]
		var locked: bool = STORY_LOCKED.has(id) and not Story.is_unlocked(id)
		var unread := int(Story.state().get("unread", 0)) if id == "messages" else 0
		icon.set_state(locked, unread)


func _on_message(entry: Dictionary) -> void:
	_refresh_icons()
	var viewing_chat := open_app is MessagesApp
	if entry.get("kind") == "msg" and not viewing_chat:
		var who := Story.contact_name(str(entry.get("from", "")))
		var text := Loc.pick(entry.get("text", ""))
		if text.length() > 80:
			text = text.substr(0, 78) + "…"
		_show_banner("%s: %s" % [who, text])


func _on_unlocked(app: String) -> void:
	_refresh_icons()
	_show_banner(Loc.t("os.installed", {"app": Loc.t("app." + app)}))


func _show_banner(text: String) -> void:
	_banner_text.text = text
	_banner.visible = true
	_banner.modulate.a = 1.0
	_banner.move_to_front()
	if _banner_tween != null:
		_banner_tween.kill()
	_banner_tween = create_tween()
	_banner_tween.tween_interval(3.5)
	_banner_tween.tween_property(_banner, "modulate:a", 0.0, 0.4)
	_banner_tween.tween_callback(_hide_banner)
	GameState.vibrate(25)


func _hide_banner() -> void:
	_banner.visible = false


func _on_banner_input(event: InputEvent) -> void:
	var mb := event as InputEventMouseButton
	if mb != null and not mb.pressed:
		_hide_banner()
		if open_app == null:
			open("messages")
