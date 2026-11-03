class_name UIKit
extends RefCounted
## Ortak renkler, tema ve küçük arayüz yardımcıları.
## Renk paleti: gece Boğaz'ı. Lacivert zemin, sodyum lamba turuncusu, su yeşili.

const BG := Color("0b1020")
const BG_DEEP := Color("070a14")
const SURFACE := Color("141c33")
const SURFACE_2 := Color("1c2747")
const LINE := Color("2a3760")
const TEXT := Color("e6ebf5")
const MUTED := Color("8f9bb8")
const AMBER := Color("ffab4c")
const TEAL := Color("4fd1c5")
const RED := Color("ff5d6c")
const GREEN := Color("6fe3a0")

const FONT_BODY := 28
const FONT_SMALL := 22
const FONT_TITLE := 36

static var _mono: Font


static func mono_font() -> Font:
	if _mono == null:
		var f := SystemFont.new()
		f.font_names = PackedStringArray(["Roboto Mono", "Droid Sans Mono", "DejaVu Sans Mono", "Consolas", "monospace"])
		_mono = f
	return _mono


static func box(bg: Color, radius: int = 18, pad: int = 16, border: Color = Color(0, 0, 0, 0), border_w: int = 0) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(radius)
	sb.content_margin_left = pad
	sb.content_margin_right = pad
	sb.content_margin_top = pad
	sb.content_margin_bottom = pad
	if border_w > 0:
		sb.border_color = border
		sb.set_border_width_all(border_w)
	return sb


static func make_theme() -> Theme:
	var t := Theme.new()
	t.default_font_size = FONT_BODY

	t.set_color("font_color", "Label", TEXT)

	var normal := box(SURFACE_2, 16, 18, LINE, 2)
	var hover := box(SURFACE_2.lightened(0.08), 16, 18, AMBER, 2)
	var pressed := box(AMBER.darkened(0.55), 16, 18, AMBER, 2)
	var disabled := box(SURFACE, 16, 18, LINE, 1)
	t.set_stylebox("normal", "Button", normal)
	t.set_stylebox("hover", "Button", hover)
	t.set_stylebox("pressed", "Button", pressed)
	t.set_stylebox("hover_pressed", "Button", pressed)
	t.set_stylebox("disabled", "Button", disabled)
	t.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	t.set_color("font_color", "Button", TEXT)
	t.set_color("font_hover_color", "Button", TEXT)
	t.set_color("font_pressed_color", "Button", AMBER)
	t.set_color("font_disabled_color", "Button", MUTED)

	t.set_stylebox("normal", "LineEdit", box(BG_DEEP, 12, 14, LINE, 2))
	t.set_stylebox("focus", "LineEdit", box(BG_DEEP, 12, 14, TEAL, 2))
	t.set_color("font_color", "LineEdit", TEXT)
	t.set_color("font_placeholder_color", "LineEdit", MUTED)
	t.set_color("caret_color", "LineEdit", AMBER)

	t.set_stylebox("panel", "PanelContainer", box(SURFACE, 18, 16))

	var bar_bg := box(BG_DEEP, 8, 0)
	var bar_fill := box(AMBER, 8, 0)
	t.set_stylebox("background", "ProgressBar", bar_bg)
	t.set_stylebox("fill", "ProgressBar", bar_fill)

	t.set_stylebox("slider", "HSlider", box(BG_DEEP, 8, 6))
	t.set_stylebox("grabber_area", "HSlider", box(TEAL.darkened(0.3), 8, 6))
	t.set_stylebox("grabber_area_highlight", "HSlider", box(TEAL, 8, 6))
	return t


static func label(text: String, size: int = FONT_BODY, color: Color = TEXT, wrap: bool = true) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	if wrap:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


static func button(text: String, min_height: int = 88) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, min_height)
	b.focus_mode = Control.FOCUS_NONE
	return b


static func margin(child: Control, left: int, top: int, right: int, bottom: int) -> MarginContainer:
	var m := MarginContainer.new()
	m.add_theme_constant_override("margin_left", left)
	m.add_theme_constant_override("margin_top", top)
	m.add_theme_constant_override("margin_right", right)
	m.add_theme_constant_override("margin_bottom", bottom)
	m.add_child(child)
	return m


static func full_rect(c: Control) -> Control:
	c.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return c


## Çentik / durum çubuğu için üst boşluk (viewport birimiyle).
static func safe_top(node: Node) -> float:
	if not OS.has_feature("mobile"):
		return 0.0
	var safe := DisplayServer.get_display_safe_area()
	var win := DisplayServer.window_get_size()
	if win.y <= 0:
		return 0.0
	var vp := node.get_viewport().get_visible_rect().size
	return safe.position.y * (vp.y / float(win.y))


static func color_hex(hex: String, fallback: Color = TEXT) -> Color:
	return Color.from_string(hex, fallback)
