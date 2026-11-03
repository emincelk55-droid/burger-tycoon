class_name ChapterEnd
extends Control
## Bölüm sonu kartı: seçilen yol, iz seviyesi ve sıradaki bölüm.

signal closed


func _ready() -> void:
	UIKit.full_rect(self)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var bg := ColorRect.new()
	bg.color = Color(UIKit.BG_DEEP, 0.96)
	add_child(UIKit.full_rect(bg))

	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 22)
	add_child(UIKit.full_rect(UIKit.margin(col, 48, 0, 48, 0)))

	col.add_child(UIKit.label(Loc.t("end.complete"), UIKit.FONT_SMALL, UIKit.TEAL))
	col.add_child(UIKit.label(Loc.pick(Story.chapter.get("title", "")), 52, UIKit.AMBER))

	var approach := str(Story.state()["flags"].get("approach", ""))
	if approach != "":
		col.add_child(UIKit.label(Loc.t("end.approach", {"value": Loc.t("approach." + approach)}), UIKit.FONT_BODY, UIKit.TEXT))
	col.add_child(UIKit.label(Loc.t("end.trace", {"value": int(GameState.trace)}), UIKit.FONT_BODY, UIKit.TEXT))
	col.add_child(UIKit.label(Loc.t("end.next"), UIKit.FONT_BODY, UIKit.MUTED))

	var b := UIKit.button(Loc.t("end.continue"))
	b.pressed.connect(func() -> void: closed.emit())
	col.add_child(b)
