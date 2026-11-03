class_name MapApp
extends AppWindow
## Harita: Bölüm 1'deki saha görevleri burada açılacak. Şimdilik bir önizleme.


func _title() -> String:
	return Loc.t("app.map")


func _build(root: VBoxContainer) -> void:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 20)
	col.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var m := UIKit.margin(col, 24, 24, 24, 24)
	m.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(m)

	var grid := Control.new()
	grid.custom_minimum_size = Vector2(0, 520)
	grid.draw.connect(_draw_grid.bind(grid))
	col.add_child(grid)
	col.add_child(UIKit.label(Loc.t("map.locked_title"), UIKit.FONT_TITLE, UIKit.AMBER))
	col.add_child(UIKit.label(Loc.t("map.locked_body"), UIKit.FONT_BODY, UIKit.MUTED))


func _draw_grid(c: Control) -> void:
	var s := c.size
	c.draw_rect(Rect2(Vector2.ZERO, s), UIKit.SURFACE)
	var step := 48.0
	var x := 0.0
	while x < s.x:
		c.draw_line(Vector2(x, 0), Vector2(x, s.y), Color(UIKit.LINE, 0.5), 1.0)
		x += step
	var y := 0.0
	while y < s.y:
		c.draw_line(Vector2(0, y), Vector2(s.x, y), Color(UIKit.LINE, 0.5), 1.0)
		y += step
	# Haliç ve Boğaz'ı andıran su şeritleri
	var water := Color(UIKit.TEAL, 0.18)
	c.draw_colored_polygon(PackedVector2Array([Vector2(s.x * 0.62, 0), Vector2(s.x * 0.78, 0), Vector2(s.x * 0.70, s.y), Vector2(s.x * 0.52, s.y)]), water)
	c.draw_colored_polygon(PackedVector2Array([Vector2(0, s.y * 0.40), Vector2(s.x * 0.60, s.y * 0.52), Vector2(s.x * 0.58, s.y * 0.60), Vector2(0, s.y * 0.50)]), water)
	# Görev noktaları
	var pins := [Vector2(0.30, 0.32), Vector2(0.42, 0.70), Vector2(0.85, 0.25)]
	for i in pins.size():
		var p: Vector2 = pins[i] * s
		c.draw_circle(p, 16.0, UIKit.AMBER if i == 0 else UIKit.MUTED)
		c.draw_circle(p, 6.0, UIKit.BG)
