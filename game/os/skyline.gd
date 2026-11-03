class_name Skyline
extends Control
## Ana ekran duvar kağıdı: gece İstanbul silueti, kubbeler, minareler, bir kule ve Boğaz'da ışık yansımaları.
## Tamamen kodla çizilir, dosya gerektirmez.

var _seed := 4471
var _t := 0.0
var _stars: PackedVector2Array = PackedVector2Array()
var _windows: Array = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(_regen)
	_regen()


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _regen() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = _seed
	_stars = PackedVector2Array()
	for i in 60:
		_stars.append(Vector2(rng.randf(), rng.randf() * 0.45))
	_windows = []
	for i in 70:
		_windows.append([rng.randf(), rng.randf_range(0.0, 1.0), rng.randf() * TAU])


func _draw() -> void:
	var s := size
	if s.x <= 0.0 or s.y <= 0.0:
		return
	# Gökyüzü bantları
	var bands := 14
	for i in bands:
		var k := float(i) / bands
		var c := UIKit.BG_DEEP.lerp(Color("1b2550"), k)
		draw_rect(Rect2(0, s.y * 0.62 * k, s.x, s.y * 0.62 / bands + 1.0), c)
	# Yıldızlar
	for p in _stars:
		var a := 0.35 + 0.35 * sin(_t * 1.3 + p.x * 40.0)
		draw_circle(Vector2(p.x * s.x, p.y * s.y), 1.6, Color(UIKit.TEXT, a))
	var horizon := s.y * 0.62
	var sil := Color("05070e")
	# Arka sıra binalar
	var x := 0.0
	var rng := RandomNumberGenerator.new()
	rng.seed = _seed + 1
	while x < s.x:
		var w := rng.randf_range(30.0, 70.0)
		var h := rng.randf_range(30.0, 90.0)
		draw_rect(Rect2(x, horizon - h, w + 1.0, h), Color("0a0f1f"))
		x += w
	# Cami: kubbe + yarım kubbeler + minareler
	_mosque(Vector2(s.x * 0.30, horizon), s.x * 0.16, sil)
	_mosque(Vector2(s.x * 0.78, horizon), s.x * 0.11, sil)
	# Kule
	var tx := s.x * 0.56
	draw_rect(Rect2(tx - 18.0, horizon - 210.0, 36.0, 210.0), sil)
	draw_colored_polygon(PackedVector2Array([Vector2(tx - 24.0, horizon - 208.0), Vector2(tx + 24.0, horizon - 208.0), Vector2(tx, horizon - 285.0)]), sil)
	draw_rect(Rect2(tx - 10.0, horizon - 196.0, 20.0, 8.0), Color(UIKit.AMBER, 0.7))
	# Pencere ışıkları
	for wdata in _windows:
		var wx: float = wdata[0] * s.x
		var wy: float = horizon - 8.0 - wdata[1] * 70.0
		var on := sin(_t * 0.4 + wdata[2]) > -0.3
		if on:
			draw_rect(Rect2(wx, wy, 4.0, 5.0), Color(UIKit.AMBER, 0.55))
	# Ön sıra (sahil) şeridi
	draw_rect(Rect2(0, horizon - 4.0, s.x, 6.0), sil)
	# Su ve yansımalar
	draw_rect(Rect2(0, horizon + 2.0, s.x, s.y - horizon), Color("070b18"))
	for i in 26:
		var yy := horizon + 10.0 + i * 14.0
		if yy > s.y:
			break
		var off := sin(_t * 0.8 + i * 0.9) * 30.0
		var seg := s.x * (0.08 + 0.05 * sin(i * 1.7))
		var cx := s.x * (0.3 + 0.45 * fposmod(i * 0.37, 1.0)) + off
		var col := UIKit.AMBER if i % 3 != 0 else UIKit.TEAL
		draw_line(Vector2(cx - seg * 0.5, yy), Vector2(cx + seg * 0.5, yy), Color(col, 0.18 - i * 0.005), 2.0)


func _mosque(base: Vector2, r: float, c: Color) -> void:
	# Ana kubbe
	_dome(Vector2(base.x, base.y - r * 0.9), r, c)
	draw_rect(Rect2(base.x - r * 1.25, base.y - r * 0.9, r * 2.5, r * 0.9), c)
	# Yarım kubbeler
	_dome(Vector2(base.x - r * 0.95, base.y - r * 0.55), r * 0.45, c)
	_dome(Vector2(base.x + r * 0.95, base.y - r * 0.55), r * 0.45, c)
	# Alem
	draw_rect(Rect2(base.x - 1.5, base.y - r * 1.9 - 14.0, 3.0, 16.0), c)
	# Minareler
	for side in [-1.0, 1.0]:
		var mx: float = base.x + side * r * 1.7
		var mh := r * 3.0
		draw_rect(Rect2(mx - 5.0, base.y - mh, 10.0, mh), c)
		draw_rect(Rect2(mx - 8.0, base.y - mh * 0.72, 16.0, 5.0), c)
		draw_colored_polygon(PackedVector2Array([Vector2(mx - 6.0, base.y - mh), Vector2(mx + 6.0, base.y - mh), Vector2(mx, base.y - mh - 34.0)]), c)


func _dome(center: Vector2, r: float, c: Color) -> void:
	var pts := PackedVector2Array()
	var n := 24
	for i in n + 1:
		var a := PI + PI * float(i) / n
		pts.append(center + Vector2(cos(a), sin(a)) * r)
	draw_colored_polygon(pts, c)
