class_name TerminalApp
extends AppWindow
## Terminal: komut yaz ya da alttaki hızlı komut düğmelerine dokun.

const COLORS := {
	"out": UIKit.TEXT,
	"ok": UIKit.GREEN,
	"warn": UIKit.AMBER,
	"err": UIKit.RED,
	"dim": UIKit.MUTED,
	"cmd": UIKit.TEAL,
}

var shell: TerminalShell
var _out: RichTextLabel
var _input: LineEdit
var _chips: HFlowContainer
var _hint: Label
var _trace_bar: ProgressBar
var _minigame: MinigameBase


func _title() -> String:
	return Loc.t("app.terminal")


func _background() -> Color:
	return UIKit.BG_DEEP


func _build(root: VBoxContainer) -> void:
	shell = TerminalShell.new(Story.chapter.get("network", {}), Story.state()["network"])

	var trace_row := HBoxContainer.new()
	trace_row.add_theme_constant_override("separation", 12)
	var trace_lbl := UIKit.label(Loc.t("term.trace_label"), UIKit.FONT_SMALL, UIKit.MUTED, false)
	trace_row.add_child(trace_lbl)
	_trace_bar = ProgressBar.new()
	_trace_bar.show_percentage = false
	_trace_bar.max_value = 100.0
	_trace_bar.custom_minimum_size = Vector2(0, 14)
	_trace_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_trace_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_trace_bar.add_theme_stylebox_override("fill", UIKit.box(UIKit.RED, 6, 0))
	trace_row.add_child(_trace_bar)
	root.add_child(UIKit.margin(trace_row, 20, 12, 20, 4))

	_out = RichTextLabel.new()
	_out.bbcode_enabled = true
	_out.scroll_following = true
	_out.selection_enabled = false
	_out.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_out.add_theme_font_override("normal_font", UIKit.mono_font())
	_out.add_theme_font_size_override("normal_font_size", 27)
	_out.add_theme_constant_override("line_separation", 6)
	_out.add_theme_color_override("default_color", UIKit.TEXT)
	var out_m := UIKit.margin(_out, 20, 8, 20, 8)
	out_m.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(out_m)

	var bottom := PanelContainer.new()
	var bb := UIKit.box(UIKit.SURFACE, 0, 16)
	bb.border_color = UIKit.LINE
	bb.border_width_top = 2
	bottom.add_theme_stylebox_override("panel", bb)
	root.add_child(bottom)
	var bcol := VBoxContainer.new()
	bcol.add_theme_constant_override("separation", 12)
	bottom.add_child(bcol)

	_hint = UIKit.label("", UIKit.FONT_SMALL, UIKit.AMBER)
	bcol.add_child(_hint)
	_chips = HFlowContainer.new()
	_chips.add_theme_constant_override("h_separation", 10)
	_chips.add_theme_constant_override("v_separation", 10)
	bcol.add_child(_chips)

	_input = LineEdit.new()
	_input.placeholder_text = Loc.t("term.placeholder")
	_input.custom_minimum_size = Vector2(0, 80)
	_input.add_theme_font_override("font", UIKit.mono_font())
	_input.add_theme_font_size_override("font_size", 28)
	_input.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_URL
	if "keep_editing_on_text_submit" in _input:
		_input.set("keep_editing_on_text_submit", true)
	_input.text_submitted.connect(_on_submit)
	bcol.add_child(_input)

	_print_line(Loc.t("term.banner"), "dim")
	_print_line(Loc.t("term.banner2"), "dim")
	_on_trace(GameState.trace)
	_refresh()
	GameState.trace_changed.connect(_on_trace)
	Story.waiting_for.connect(_on_story_wait)


func _on_story_wait(_event: String, _hint: String) -> void:
	_refresh()


func _on_submit(text: String) -> void:
	_input.clear()
	run_command(text)


func run_command(text: String) -> void:
	if text.strip_edges() == "" or _minigame != null:
		return
	_print_line("%s $ %s" % [_prompt(), text], "cmd")
	_apply(shell.execute(text))


func _apply(res: Dictionary) -> void:
	if res.get("clear", false):
		_out.clear()
	for l in res.get("lines", []):
		_print_line(str(l[0]), str(l[1]))
	var ev := str(res.get("event", ""))
	if ev != "":
		Story.post_event(ev)
	var mg := str(res.get("minigame", ""))
	if mg != "":
		_start_minigame(mg)
	_refresh()


func _start_minigame(kind: String) -> void:
	_minigame = make_minigame(kind)
	add_child(_minigame)
	var success: bool = await _minigame.finished
	_minigame.queue_free()
	_minigame = null
	_apply(shell.on_minigame_result(kind, success))


## "breach", "signal" ya da "patch:<bulmaca_id>"
static func make_minigame(kind: String) -> MinigameBase:
	if kind.begins_with("patch:"):
		var g := CodePatchGame.new()
		var puzzles: Dictionary = Story.chapter.get("puzzles", {})
		g.puzzle = puzzles.get(kind.substr(6), {})
		return g
	if kind == "signal":
		return SignalGame.new()
	return BreachGame.new()


func _prompt() -> String:
	var host := shell.connected()
	return "deniz@" + (host if host != "" else "telefon")


func _refresh() -> void:
	for c in _chips.get_children():
		c.queue_free()
	for cmd in shell.suggestions():
		var b := UIKit.button(str(cmd), 64)
		b.add_theme_font_override("font", UIKit.mono_font())
		b.add_theme_font_size_override("font_size", 22)
		var command := str(cmd)
		b.pressed.connect(func() -> void: run_command(command))
		_chips.add_child(b)
	var hint := Story.current_hint()
	_hint.text = ("» " + hint) if hint != "" else ""
	_hint.visible = hint != ""
	header_status.text = Loc.t("term.status_host", {"host": shell.connected()}) if shell.connected() != "" else Loc.t("term.status_local")


func _on_trace(value: float) -> void:
	_trace_bar.value = value


func _print_line(text: String, color: String) -> void:
	var c: Color = COLORS.get(color, UIKit.TEXT)
	_out.append_text("[color=#%s]%s[/color]\n" % [c.to_html(false), _escape(text)])


static func _escape(text: String) -> String:
	return text.replace("[", "[lb]")


func _on_keyboard_changed(height: float) -> void:
	# Klavye açıkken ipucunu gizle, çıktıya yer kalsın; en alttaki satıra kaydır.
	_hint.visible = height <= 0.0 and _hint.text != ""
	_out.scroll_to_line(maxi(_out.get_line_count() - 1, 0))
