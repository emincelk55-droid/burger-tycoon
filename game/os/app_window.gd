class_name AppWindow
extends Control
## Telefondaki her uygulamanın ortak çerçevesi: üstte geri düğmesi ve başlık.
## Alt sınıflar _build(content) içinde arayüzünü kurar.

signal close_requested

var content: VBoxContainer
var header_title: Label
var header_status: Label


func _ready() -> void:
	UIKit.full_rect(self)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var bg := ColorRect.new()
	bg.color = _background()
	add_child(UIKit.full_rect(bg))

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	add_child(UIKit.full_rect(col))

	var header := PanelContainer.new()
	var hb := UIKit.box(UIKit.SURFACE, 0, 0)
	hb.content_margin_top = 18 + UIKit.safe_top(self)
	hb.content_margin_bottom = 14
	hb.content_margin_left = 12
	hb.content_margin_right = 20
	hb.border_color = UIKit.LINE
	hb.border_width_bottom = 2
	header.add_theme_stylebox_override("panel", hb)
	col.add_child(header)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	header.add_child(row)

	var back := UIKit.button("‹", 76)
	back.custom_minimum_size = Vector2(76, 76)
	back.add_theme_font_size_override("font_size", 44)
	back.pressed.connect(func() -> void: close_requested.emit())
	row.add_child(back)

	var titles := VBoxContainer.new()
	titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	titles.add_theme_constant_override("separation", 0)
	header_title = UIKit.label(_title(), 32, UIKit.TEXT, false)
	header_status = UIKit.label("", UIKit.FONT_SMALL, UIKit.MUTED, false)
	titles.add_child(header_title)
	titles.add_child(header_status)
	row.add_child(titles)

	content = VBoxContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 0)
	col.add_child(content)
	_build(content)


func _title() -> String:
	return ""


func _background() -> Color:
	return UIKit.BG


func _build(_root: VBoxContainer) -> void:
	pass
