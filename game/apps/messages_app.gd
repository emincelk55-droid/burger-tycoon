class_name MessagesApp
extends AppWindow
## Şifreli mesajlaşma uygulaması. Hikaye burada ilerler.

const BUBBLE_MAX := 500.0

var _scroll: ScrollContainer
var _list: VBoxContainer
var _choices: VBoxContainer
var _hint: Label


func _title() -> String:
	return Loc.t("app.messages")


func _build(root: VBoxContainer) -> void:
	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(_scroll)

	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 14)
	_scroll.add_child(UIKit.margin(_list, 20, 20, 20, 20))
	(_list.get_parent() as Control).size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var bottom := PanelContainer.new()
	var bb := UIKit.box(UIKit.SURFACE, 0, 18)
	bb.border_color = UIKit.LINE
	bb.border_width_top = 2
	bottom.add_theme_stylebox_override("panel", bb)
	root.add_child(bottom)
	var bcol := VBoxContainer.new()
	bcol.add_theme_constant_override("separation", 12)
	bottom.add_child(bcol)
	_hint = UIKit.label("", UIKit.FONT_SMALL, UIKit.AMBER)
	bcol.add_child(_hint)
	_choices = VBoxContainer.new()
	_choices.add_theme_constant_override("separation", 10)
	bcol.add_child(_choices)

	for entry in Story.state().get("log", []):
		_add_bubble(entry, false)
	_show_choices(Story.pending_choices())
	_update_hint(Story.current_hint())
	_update_status(Story.typing_contact())

	Story.viewing_messages = true
	Story.mark_read()
	Story.message_added.connect(_on_message)
	Story.choices_offered.connect(_show_choices)
	Story.choices_cleared.connect(_clear_choices)
	Story.waiting_for.connect(_on_waiting)
	Story.typing_changed.connect(_on_typing)
	_scroll_to_end()


func _exit_tree() -> void:
	Story.viewing_messages = false


func _on_message(entry: Dictionary) -> void:
	_add_bubble(entry, true)
	Story.mark_read()
	_update_hint("")
	_scroll_to_end()


func _on_waiting(_event: String, hint: String) -> void:
	_update_hint(hint)


func _on_typing(contact: String, active: bool) -> void:
	_update_status(contact if active else "")


func _update_status(contact: String) -> void:
	if contact != "":
		header_status.text = Loc.t("msg.typing", {"name": Story.contact_name(contact)})
		header_status.add_theme_color_override("font_color", UIKit.AMBER)
	else:
		header_status.text = Loc.t("msg.encrypted")
		header_status.add_theme_color_override("font_color", UIKit.MUTED)


func _update_hint(hint: String) -> void:
	_hint.text = ("» " + hint) if hint != "" else ""
	_hint.visible = hint != ""


func _add_bubble(entry: Dictionary, animate: bool) -> void:
	var kind := str(entry.get("kind", "msg"))
	var text := Loc.pick(entry.get("text", ""))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 0)

	if kind == "system":
		var l := UIKit.label(text, UIKit.FONT_SMALL, UIKit.MUTED)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(l)
	else:
		var mine := kind == "me"
		var panel := PanelContainer.new()
		var bg := UIKit.TEAL.darkened(0.62) if mine else UIKit.SURFACE_2
		var sb := UIKit.box(bg, 20, 18)
		if mine:
			sb.corner_radius_bottom_right = 4
		else:
			sb.corner_radius_bottom_left = 4
		panel.add_theme_stylebox_override("panel", sb)

		var inner := VBoxContainer.new()
		inner.add_theme_constant_override("separation", 4)
		panel.add_child(inner)
		if not mine:
			var from := str(entry.get("from", ""))
			var who := UIKit.label(Story.contact_name(from), UIKit.FONT_SMALL, _contact_color(from), false)
			inner.add_child(who)
		var body := UIKit.label(text, UIKit.FONT_BODY, UIKit.TEXT)
		body.custom_minimum_size.x = _text_width(body, text)
		inner.add_child(body)

		var spacer := Control.new()
		spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if mine:
			row.add_child(spacer)
			row.add_child(panel)
		else:
			row.add_child(panel)
			row.add_child(spacer)
	_list.add_child(row)
	if animate:
		row.modulate.a = 0.0
		var tw := create_tween()
		tw.tween_property(row, "modulate:a", 1.0, 0.25)


func _text_width(l: Label, text: String) -> float:
	var font := l.get_theme_font("font")
	var w := 0.0
	for line in text.split("\n"):
		w = maxf(w, font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, UIKit.FONT_BODY).x)
	return clampf(w + 6.0, 40.0, BUBBLE_MAX)


func _contact_color(id: String) -> Color:
	var contacts: Dictionary = Story.chapter.get("contacts", {})
	if contacts.has(id):
		return UIKit.color_hex(str(contacts[id].get("color", "")), UIKit.AMBER)
	return UIKit.AMBER


func _show_choices(options: Array) -> void:
	_clear_choices()
	for i in options.size():
		var opt: Dictionary = options[i]
		var b := UIKit.button(Loc.pick(opt.get("text", "")), 84)
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		var idx := i
		b.pressed.connect(func() -> void: Story.choose(idx))
		_choices.add_child(b)
	if not options.is_empty():
		_update_hint(Loc.t("msg.choose"))
	_scroll_to_end()


func _clear_choices() -> void:
	for c in _choices.get_children():
		c.queue_free()


func _scroll_to_end() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	if is_instance_valid(_scroll):
		_scroll.scroll_vertical = int(_scroll.get_v_scroll_bar().max_value)
