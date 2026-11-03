class_name MinigameBase
extends Control
## Mini oyunların ortak iskeleti: başlık, süre çubuğu, sonuç ekranı.
## Alt sınıflar _build_board(), _tick(delta) ve _time_limit() yazar.

signal finished(success: bool)

var time_left := 0.0
var running := false
var _title: Label
var _subtitle: Label
var _timer_bar: ProgressBar
var _board_holder: VBoxContainer
var _result_label: Label
var _flash := 0.0
var _flash_color := UIKit.RED
var _low_time := false
var _flash_rect: ColorRect


func _ready() -> void:
	UIKit.full_rect(self)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var bg := ColorRect.new()
	bg.color = Color(UIKit.BG_DEEP, 0.97)
	add_child(UIKit.full_rect(bg))

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 18)
	var top := 40 + int(UIKit.safe_top(self))
	var m := UIKit.margin(col, 28, top, 28, 36)
	add_child(UIKit.full_rect(m))

	_title = UIKit.label(_title_text(), UIKit.FONT_TITLE, UIKit.AMBER)
	_subtitle = UIKit.label(_subtitle_text(), UIKit.FONT_SMALL, UIKit.MUTED)
	_timer_bar = ProgressBar.new()
	_timer_bar.custom_minimum_size = Vector2(0, 16)
	_timer_bar.show_percentage = false
	_timer_bar.max_value = _time_limit()
	col.add_child(_title)
	col.add_child(_subtitle)
	col.add_child(_timer_bar)

	_board_holder = VBoxContainer.new()
	_board_holder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_board_holder.add_theme_constant_override("separation", 18)
	col.add_child(_board_holder)
	_build_board(_board_holder)

	_result_label = UIKit.label("", UIKit.FONT_TITLE, UIKit.GREEN)
	_result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result_label.visible = false
	col.add_child(_result_label)

	_flash_rect = ColorRect.new()
	_flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash_rect.color = Color(0, 0, 0, 0)
	add_child(UIKit.full_rect(_flash_rect))

	time_left = _time_limit()
	running = true


func _process(delta: float) -> void:
	if _flash > 0.0:
		_flash = maxf(0.0, _flash - delta * 3.0)
		_flash_rect.color = Color(_flash_color, _flash * 0.22)
	if not running:
		return
	time_left -= delta
	_timer_bar.value = maxf(time_left, 0.0)
	var low := time_left < _time_limit() * 0.25
	if low != _low_time:
		_low_time = low
		_timer_bar.add_theme_stylebox_override("fill", UIKit.box(UIKit.RED if low else UIKit.AMBER, 8, 0))
	_tick(delta)
	if running and time_left <= 0.0:
		end_game(false)


func flash(color: Color) -> void:
	_flash = 1.0
	_flash_color = color


func penalty(seconds: float) -> void:
	time_left -= seconds
	flash(UIKit.RED)
	GameState.vibrate(80)


func end_game(success: bool) -> void:
	if not running:
		return
	running = false
	_result_label.visible = true
	_result_label.text = Loc.t("game.success") if success else Loc.t("game.fail")
	_result_label.add_theme_color_override("font_color", UIKit.GREEN if success else UIKit.RED)
	flash(UIKit.GREEN if success else UIKit.RED)
	GameState.add_trace(3.0 if success else 15.0)
	GameState.vibrate(40 if success else 200)
	var wait := 0.05 if Story.fast_mode else 1.3
	await get_tree().create_timer(wait).timeout
	finished.emit(success)


# --- alt sınıfların yazacağı kısımlar ---

func _title_text() -> String:
	return ""


func _subtitle_text() -> String:
	return ""


func _time_limit() -> float:
	return 20.0


func _build_board(_holder: VBoxContainer) -> void:
	pass


func _tick(_delta: float) -> void:
	pass
