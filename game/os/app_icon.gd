class_name AppIcon
extends VBoxContainer
## Ana ekrandaki uygulama simgesi. Şekiller kodla çizilir.

signal activated(app_id: String)

var app_id := ""
var title := ""
var tint := UIKit.AMBER
var locked := false
var badge := 0
var _tile: Control
var _label: Label


func setup(id: String, text: String, color: Color) -> AppIcon:
	app_id = id
	title = text
	tint = color
	return self


func _ready() -> void:
	add_theme_constant_override("separation", 8)
	_tile = Control.new()
	_tile.custom_minimum_size = Vector2(124, 124)
	_tile.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_tile.mouse_filter = Control.MOUSE_FILTER_STOP
	_tile.draw.connect(_draw_tile)
	_tile.gui_input.connect(_on_input)
	add_child(_tile)
	_label = UIKit.label(title, UIKit.FONT_SMALL, UIKit.TEXT, false)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_label)
	refresh()


func set_state(is_locked: bool, unread: int) -> void:
	locked = is_locked
	badge = unread
	refresh()


func refresh() -> void:
	if _tile == null:
		return
	_label.add_theme_color_override("font_color", UIKit.MUTED if locked else UIKit.TEXT)
	_tile.queue_redraw()


func _on_input(event: InputEvent) -> void:
	var mb := event as InputEventMouseButton
	if mb != null and mb.button_index == MOUSE_BUTTON_LEFT and not mb.pressed:
		if Rect2(Vector2.ZERO, _tile.size).has_point(mb.position):
			activated.emit(app_id)


func _draw_tile() -> void:
	var s := _tile.size
	var c := s * 0.5
	var col := UIKit.MUTED if locked else tint
	var sb := UIKit.box(UIKit.SURFACE_2, 30, 0, Color(col, 0.6), 2)
	_tile.draw_style_box(sb, Rect2(Vector2.ZERO, s))
	match app_id:
		"messages":
			var r := Rect2(c.x - 34, c.y - 26, 68, 46)
			_tile.draw_style_box(UIKit.box(col, 14, 0), r)
			_tile.draw_colored_polygon(PackedVector2Array([Vector2(c.x - 18, c.y + 18), Vector2(c.x - 4, c.y + 18), Vector2(c.x - 22, c.y + 34)]), col)
			for i in 3:
				_tile.draw_circle(Vector2(c.x - 16 + i * 16, c.y - 3), 4.5, UIKit.SURFACE_2)
		"terminal":
			_tile.draw_polyline(PackedVector2Array([Vector2(c.x - 30, c.y - 20), Vector2(c.x - 10, c.y), Vector2(c.x - 30, c.y + 20)]), col, 7.0, true)
			_tile.draw_line(Vector2(c.x - 2, c.y + 22), Vector2(c.x + 30, c.y + 22), col, 7.0, true)
		"map":
			_tile.draw_circle(Vector2(c.x, c.y - 8), 24, col)
			_tile.draw_colored_polygon(PackedVector2Array([Vector2(c.x - 20, c.y + 4), Vector2(c.x + 20, c.y + 4), Vector2(c.x, c.y + 38)]), col)
			_tile.draw_circle(Vector2(c.x, c.y - 8), 9, UIKit.SURFACE_2)
		"settings":
			for i in 8:
				var a := TAU * i / 8.0
				var d := Vector2(cos(a), sin(a))
				_tile.draw_line(c + d * 18, c + d * 36, col, 10.0)
			_tile.draw_circle(c, 24, col)
			_tile.draw_circle(c, 10, UIKit.SURFACE_2)
	if locked:
		var lc := Vector2(s.x - 26, 26)
		_tile.draw_circle(lc, 16, UIKit.BG_DEEP)
		_tile.draw_rect(Rect2(lc.x - 8, lc.y - 2, 16, 12), UIKit.MUTED)
		_tile.draw_arc(Vector2(lc.x, lc.y - 3), 6, PI, TAU, 10, UIKit.MUTED, 3.0)
	elif badge > 0:
		var bc := Vector2(s.x - 18, 18)
		_tile.draw_circle(bc, 18, UIKit.RED)
		var font := get_theme_default_font()
		var txt := str(min(badge, 9))
		var ts := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 22)
		_tile.draw_string(font, Vector2(bc.x - ts.x * 0.5, bc.y + 8), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, UIKit.TEXT)
