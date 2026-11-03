class_name BootScreen
extends Control
## Açılış: telefonun "önyükleme" satırları ve oyun adı. Dokununca geçilir.

signal finished

var _lines: Label
var _title: Label
var _tap: Label
var _done := false
var _skip := false


func _ready() -> void:
	UIKit.full_rect(self)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var bg := ColorRect.new()
	bg.color = UIKit.BG_DEEP
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(UIKit.full_rect(bg))

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 24)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(UIKit.full_rect(UIKit.margin(col, 48, 0, 48, 0)))

	_lines = UIKit.label("", UIKit.FONT_SMALL, UIKit.TEAL)
	_lines.add_theme_font_override("font", UIKit.mono_font())
	col.add_child(_lines)
	_title = UIKit.label(Loc.t("game.title"), 84, UIKit.AMBER, false)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.modulate.a = 0.0
	col.add_child(_title)
	_tap = UIKit.label(Loc.t("boot.tap"), UIKit.FONT_BODY, UIKit.MUTED, false)
	_tap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tap.modulate.a = 0.0
	col.add_child(_tap)
	_play()


func _play() -> void:
	for key in ["boot.1", "boot.2", "boot.3", "boot.4"]:
		_lines.text += Loc.t(key) + "\n"
		if not _skip:
			await get_tree().create_timer(0.45).timeout
	var tw := create_tween()
	tw.tween_property(_title, "modulate:a", 1.0, 0.1 if _skip else 0.8)
	tw.tween_property(_tap, "modulate:a", 1.0, 0.1 if _skip else 0.5)
	_done = true


func _gui_input(event: InputEvent) -> void:
	var mb := event as InputEventMouseButton
	if mb == null or mb.pressed:
		return
	if _done:
		finished.emit()
	else:
		_skip = true
