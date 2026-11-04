class_name CodePatchGame
extends MinigameBase
## "Kod yaması" bulmacası. Ekranda oyunun kendi uydurma betik dilinde kısa bir program çıkar.
## Bir satırdaki değer eksik ya da yanlıştır (???). Oyuncu doğru değeri yazar ya da seçer.
## Değeri çoğu zaman terminalde okuduğu dosyalardan öğrenir. Tamamen kurgusal bir mantık bulmacasıdır.
##
## Bulmaca verisi (bölüm JSON'unda "puzzles" altında):
##   title {tr,en}, goal {tr,en}, file "ad.kd", lines [..], blank satır_no,
##   answer "DEĞER", accept [..]?, options [..], time saniye?

var puzzle: Dictionary = {}
var _code: RichTextLabel
var _answer: LineEdit
var _feedback: Label
var _fixed := false


static func is_correct(p: Dictionary, value: String) -> bool:
	var v := _clean(value)
	if v == "":
		return false
	if v == _clean(str(p.get("answer", ""))):
		return true
	for a in p.get("accept", []):
		if v == _clean(str(a)):
			return true
	return false


static func _clean(s: String) -> String:
	return s.strip_edges().trim_prefix("\"").trim_suffix("\"").strip_edges().to_upper()


func _title_text() -> String:
	return Loc.pick(puzzle.get("title", "")) if not puzzle.is_empty() else Loc.t("game.patch.title")


func _subtitle_text() -> String:
	return Loc.pick(puzzle.get("goal", "")) if not puzzle.is_empty() else Loc.t("game.patch.help")


func _time_limit() -> float:
	return float(puzzle.get("time", 45.0))


func _build_board(holder: VBoxContainer) -> void:
	var file_lbl := UIKit.label("> " + str(puzzle.get("file", "script.kd")), UIKit.FONT_SMALL, UIKit.TEAL, false)
	file_lbl.add_theme_font_override("font", UIKit.mono_font())
	holder.add_child(file_lbl)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UIKit.box(UIKit.BG, 14, 16, UIKit.LINE, 2))
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	holder.add_child(panel)
	_code = RichTextLabel.new()
	_code.bbcode_enabled = true
	_code.fit_content = false
	_code.scroll_active = true
	_code.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_code.custom_minimum_size = Vector2(0, 260)
	_code.add_theme_font_override("normal_font", UIKit.mono_font())
	_code.add_theme_font_size_override("normal_font_size", 25)
	_code.add_theme_constant_override("line_separation", 6)
	panel.add_child(_code)
	_render_code()

	_feedback = UIKit.label(Loc.t("game.patch.help"), UIKit.FONT_SMALL, UIKit.MUTED)
	holder.add_child(_feedback)

	var chips := HFlowContainer.new()
	chips.add_theme_constant_override("h_separation", 10)
	chips.add_theme_constant_override("v_separation", 10)
	holder.add_child(chips)
	for opt in puzzle.get("options", []):
		var b := UIKit.button(str(opt), 64)
		b.add_theme_font_override("font", UIKit.mono_font())
		b.add_theme_font_size_override("font_size", 23)
		var value := str(opt)
		b.pressed.connect(func() -> void: _answer.text = value)
		chips.add_child(b)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	holder.add_child(row)
	_answer = LineEdit.new()
	_answer.placeholder_text = Loc.t("game.patch.placeholder")
	_answer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_answer.custom_minimum_size = Vector2(0, 84)
	_answer.add_theme_font_override("font", UIKit.mono_font())
	_answer.add_theme_font_size_override("font_size", 28)
	_answer.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_URL
	_answer.text_submitted.connect(func(_t: String) -> void: submit())
	row.add_child(_answer)
	var go := UIKit.button(Loc.t("game.patch.button"), 84)
	go.custom_minimum_size.x = 180
	go.pressed.connect(submit)
	row.add_child(go)


func submit() -> void:
	if not running or _fixed:
		return
	if is_correct(puzzle, _answer.text):
		_fixed = true
		_render_code()
		_feedback.text = Loc.t("game.patch.ok")
		_feedback.add_theme_color_override("font_color", UIKit.GREEN)
		end_game(true)
	else:
		penalty(4.0)
		GameState.add_trace(2.0)
		_feedback.text = Loc.t("game.patch.wrong", {"value": _answer.text.strip_edges()})
		_feedback.add_theme_color_override("font_color", UIKit.RED)


func _render_code() -> void:
	var lines: Array = puzzle.get("lines", [])
	var blank := int(puzzle.get("blank", -1))
	var out := ""
	for i in lines.size():
		var text := str(lines[i]).replace("[", "[lb]")
		var num := "[color=#%s]%2d[/color]  " % [UIKit.MUTED.darkened(0.3).to_html(false), i + 1]
		if i == blank:
			if _fixed:
				text = text.replace("???", "[color=#%s]%s[/color]" % [UIKit.GREEN.to_html(false), str(puzzle.get("answer", "")).replace("[", "[lb]")])
				out += num + "[color=#%s]%s[/color]\n" % [UIKit.TEXT.to_html(false), text]
			else:
				text = text.replace("???", "[bgcolor=#%s][color=#%s]???[/color][/bgcolor]" % [UIKit.RED.darkened(0.55).to_html(false), UIKit.AMBER.to_html(false)])
				out += num + "[color=#%s]%s[/color]  [color=#%s]<<[/color]\n" % [UIKit.TEXT.to_html(false), text, UIKit.RED.to_html(false)]
		elif text.strip_edges().begins_with("#"):
			out += num + "[color=#%s]%s[/color]\n" % [UIKit.MUTED.to_html(false), text]
		else:
			out += num + "[color=#%s]%s[/color]\n" % [UIKit.TEAL.lightened(0.25).to_html(false), text]
	_code.text = out
