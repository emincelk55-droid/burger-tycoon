class_name SignalGame
extends MinigameBase
## "Sinyal kilidi": kameranın sinyal dalgasını (turuncu) kendi dalganla (yeşil) eşleştir.
## Frekans ve faz sürgülerini kullan. Eşleşme yüksekken kilit dolar.
## Hedef dalga yavaşça kayar, bu yüzden sürekli düzeltmen gerekir.

const LOCK_NEEDED := 2.2      # saniye
const MATCH_THRESHOLD := 0.86

var target_freq := 2.0
var target_phase := 0.0
var lock := 0.0
var _t := 0.0
var _drift_seed := 0.0
var _scope: Control
var _freq: HSlider
var _phase: HSlider
var _lock_bar: ProgressBar
var _match_label: Label


## 0..1 arası benzerlik. Frekans farkı fazdan daha önemlidir.
static func match_score(f1: float, p1: float, f2: float, p2: float) -> float:
	var df := absf(f1 - f2) / 2.0
	var dp := absf(wrapf(p1 - p2, -PI, PI)) / PI
	return clampf(1.0 - (df * 0.7 + dp * 0.45), 0.0, 1.0)


func _title_text() -> String:
	return Loc.t("game.signal.title")


func _subtitle_text() -> String:
	return Loc.t("game.signal.help")


func _time_limit() -> float:
	return 28.0


func _build_board(holder: VBoxContainer) -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	target_freq = rng.randf_range(1.4, 3.6)
	target_phase = rng.randf_range(-PI, PI)
	_drift_seed = rng.randf() * 10.0

	_scope = Control.new()
	_scope.custom_minimum_size = Vector2(0, 360)
	_scope.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scope.draw.connect(_draw_scope)
	holder.add_child(_scope)

	_match_label = UIKit.label("", UIKit.FONT_BODY, UIKit.TEXT)
	holder.add_child(_match_label)
	_lock_bar = ProgressBar.new()
	_lock_bar.custom_minimum_size = Vector2(0, 26)
	_lock_bar.show_percentage = false
	_lock_bar.max_value = LOCK_NEEDED
	_lock_bar.add_theme_stylebox_override("fill", UIKit.box(UIKit.GREEN, 8, 0))
	holder.add_child(_lock_bar)

	_freq = _slider(holder, Loc.t("game.signal.freq"), 1.0, 4.0, 1.0)
	_phase = _slider(holder, Loc.t("game.signal.phase"), -PI, PI, PI * 0.9)


func _slider(holder: VBoxContainer, text: String, lo: float, hi: float, start: float) -> HSlider:
	holder.add_child(UIKit.label(text, UIKit.FONT_SMALL, UIKit.MUTED))
	var s := HSlider.new()
	s.min_value = lo
	s.max_value = hi
	s.step = 0.0
	s.value = start
	s.custom_minimum_size = Vector2(0, 72)
	s.focus_mode = Control.FOCUS_NONE
	holder.add_child(s)
	return s


func current_match() -> float:
	return match_score(_freq.value, _phase.value, target_freq, target_phase)


func _tick(delta: float) -> void:
	_t += delta
	# Hedef dalga yavaşça kayar.
	target_freq = clampf(target_freq + sin(_t * 0.7 + _drift_seed) * 0.12 * delta, 1.0, 4.0)
	target_phase = wrapf(target_phase + cos(_t * 0.5 + _drift_seed) * 0.35 * delta, -PI, PI)
	var m := current_match()
	if m >= MATCH_THRESHOLD:
		lock += delta
	else:
		lock = maxf(0.0, lock - delta * 0.6)
	_lock_bar.value = lock
	_match_label.text = Loc.t("game.signal.match", {"value": int(round(m * 100.0))})
	_match_label.add_theme_color_override("font_color", UIKit.GREEN if m >= MATCH_THRESHOLD else UIKit.TEXT)
	_scope.queue_redraw()
	if lock >= LOCK_NEEDED:
		end_game(true)


func _draw_scope() -> void:
	var s := _scope.size
	_scope.draw_rect(Rect2(Vector2.ZERO, s), UIKit.BG)
	for i in range(1, 6):
		var y := s.y * float(i) / 6.0
		_scope.draw_line(Vector2(0, y), Vector2(s.x, y), Color(UIKit.LINE, 0.6), 1.0)
	_draw_wave(target_freq, target_phase, UIKit.AMBER, 5.0)
	if _freq != null:
		_draw_wave(_freq.value, _phase.value, UIKit.GREEN, 3.0)


func _draw_wave(freq: float, phase: float, color: Color, width: float) -> void:
	var s := _scope.size
	var pts := PackedVector2Array()
	var steps := 90
	for i in steps + 1:
		var x := float(i) / steps
		var y := sin(x * TAU * freq * 0.5 + phase + _t * 2.0)
		pts.append(Vector2(x * s.x, s.y * 0.5 - y * s.y * 0.36))
	_scope.draw_polyline(pts, color, width, true)
