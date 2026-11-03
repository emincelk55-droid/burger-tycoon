class_name SettingsApp
extends AppWindow
## Ayarlar: dil, titreşim, ilerlemeyi sıfırlama.

signal restart_requested

var _reset_btn: Button
var _reset_armed := false


func _title() -> String:
	return Loc.t("app.settings")


func _build(root: VBoxContainer) -> void:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 18)
	root.add_child(UIKit.margin(col, 24, 24, 24, 24))

	col.add_child(UIKit.label(Loc.t("settings.language"), UIKit.FONT_SMALL, UIKit.MUTED))
	var langs := HBoxContainer.new()
	langs.add_theme_constant_override("separation", 12)
	col.add_child(langs)
	for code in GameState.LANGUAGES:
		var b := UIKit.button(Loc.t("lang." + code))
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.toggle_mode = true
		b.button_pressed = GameState.settings.get("lang") == code
		var c := str(code)
		b.pressed.connect(func() -> void: GameState.set_language(c))
		langs.add_child(b)

	var vib := CheckButton.new()
	vib.text = Loc.t("settings.vibration")
	vib.button_pressed = bool(GameState.settings.get("vibration", true))
	vib.custom_minimum_size = Vector2(0, 80)
	vib.focus_mode = Control.FOCUS_NONE
	vib.toggled.connect(_on_vibration)
	col.add_child(vib)

	_reset_btn = UIKit.button(Loc.t("settings.reset"))
	_reset_btn.pressed.connect(_on_reset)
	col.add_child(_reset_btn)

	var ver := str(ProjectSettings.get_setting("application/config/version", "0.0.0"))
	col.add_child(UIKit.label(Loc.t("settings.version", {"v": ver}), UIKit.FONT_SMALL, UIKit.MUTED))
	col.add_child(UIKit.label(Loc.t("settings.fiction"), UIKit.FONT_SMALL, UIKit.MUTED))


func _on_vibration(on: bool) -> void:
	GameState.settings["vibration"] = on
	GameState.save_game()


func _on_reset() -> void:
	if not _reset_armed:
		_reset_armed = true
		_reset_btn.text = Loc.t("settings.reset_confirm")
		_reset_btn.add_theme_color_override("font_color", UIKit.RED)
		return
	GameState.reset_progress()
	restart_requested.emit()
