class_name BreachGame
extends MinigameBase
## "Güvenlik duvarı delme": imleç bir şerit üzerinde gidip gelir.
## İmleç açık boşluğun içindeyken DEL'e bas. Her başarıda boşluk daralır ve imleç hızlanır.

const HITS_NEEDED := 4
const MAX_MISSES := 3

var cursor := 0.0          # 0..1
var direction := 1.0
var speed := 0.55          # şerit genişliği / saniye
var gap_center := 0.5
var gap_width := 0.26
var hits := 0
var misses := 0
var _track: Control
var _status: Label
var _rng := RandomNumberGenerator.new()


static func is_hit(cursor_pos: float, center: float, width: float) -> bool:
	return absf(cursor_pos - center) <= width * 0.5


func _title_text() -> String:
	return Loc.t("game.breach.title")


func _subtitle_text() -> String:
	return Loc.t("game.breach.help")


func _time_limit() -> float:
	return 22.0


func _build_board(holder: VBoxContainer) -> void:
	_rng.randomize()
	_new_gap()
	_status = UIKit.label("", UIKit.FONT_BODY, UIKit.TEXT)
	holder.add_child(_status)

	_track = Control.new()
	_track.custom_minimum_size = Vector2(0, 220)
	_track.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_track.draw.connect(_draw_track)
	holder.add_child(_track)

	var btn := UIKit.button(Loc.t("game.breach.button"), 180)
	btn.add_theme_font_size_override("font_size", 44)
	btn.button_down.connect(_on_press)
	holder.add_child(btn)
	_update_status()


func _tick(delta: float) -> void:
	cursor += direction * speed * delta
	if cursor > 1.0:
		cursor = 1.0
		direction = -1.0
	elif cursor < 0.0:
		cursor = 0.0
		direction = 1.0
	_track.queue_redraw()


func _on_press() -> void:
	if not running:
		return
	if is_hit(cursor, gap_center, gap_width):
		hits += 1
		flash(UIKit.GREEN)
		GameState.vibrate(30)
		if hits >= HITS_NEEDED:
			_update_status()
			end_game(true)
			return
		gap_width = maxf(0.09, gap_width * 0.78)
		speed *= 1.18
		_new_gap()
	else:
		misses += 1
		penalty(2.0)
		if misses >= MAX_MISSES:
			_update_status()
			end_game(false)
			return
	_update_status()


func _new_gap() -> void:
	var half := gap_width * 0.5
	var c := _rng.randf_range(half, 1.0 - half)
	# Boşluk imlecin hemen üstünde doğmasın.
	if absf(c - cursor) < 0.2:
		c = fposmod(c + 0.45, 1.0 - gap_width) + half
	gap_center = c


func _update_status() -> void:
	_status.text = Loc.t("game.breach.status", {"hits": hits, "need": HITS_NEEDED, "misses": misses, "max": MAX_MISSES})


func _draw_track() -> void:
	var s := _track.size
	var pad := 8.0
	var lane := Rect2(pad, s.y * 0.35, s.x - pad * 2.0, s.y * 0.3)
	# Duvar blokları
	_track.draw_rect(lane, UIKit.SURFACE_2)
	var cols := 18
	for i in cols:
		var x := lane.position.x + lane.size.x * float(i) / cols
		_track.draw_line(Vector2(x, lane.position.y), Vector2(x, lane.end.y), UIKit.LINE, 2.0)
	# Açık boşluk
	var gx := lane.position.x + lane.size.x * (gap_center - gap_width * 0.5)
	var gap := Rect2(gx, lane.position.y - 6.0, lane.size.x * gap_width, lane.size.y + 12.0)
	_track.draw_rect(gap, Color(UIKit.TEAL, 0.35))
	_track.draw_rect(gap, UIKit.TEAL, false, 3.0)
	# İmleç
	var cx := lane.position.x + lane.size.x * cursor
	var col := UIKit.GREEN if is_hit(cursor, gap_center, gap_width) else UIKit.AMBER
	_track.draw_rect(Rect2(cx - 4.0, lane.position.y - 30.0, 8.0, lane.size.y + 60.0), col)
	# İlerleme noktaları
	for i in HITS_NEEDED:
		var p := Vector2(s.x * 0.5 + (i - (HITS_NEEDED - 1) * 0.5) * 44.0, s.y * 0.88)
		_track.draw_circle(p, 12.0, UIKit.GREEN if i < hits else UIKit.LINE)
