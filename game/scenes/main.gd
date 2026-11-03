extends Control
## Oyunun kök düğümü: açılış ekranı, telefon ve bölüm sonu arasında geçişi yönetir.
## "--run-tests" argümanıyla açılırsa testleri çalıştırıp çıkar (CI için).

var phone: PhoneOS
var _screen: Control


func _ready() -> void:
	theme = UIKit.make_theme()
	var bg := ColorRect.new()
	bg.color = UIKit.BG
	add_child(UIKit.full_rect(bg))

	if OS.get_cmdline_user_args().has("--run-tests"):
		var runner_script: GDScript = load("res://tests/test_runner.gd")
		var runner: Node = runner_script.new()
		add_child(runner)
		return

	GameState.language_changed.connect(_on_language_changed)
	Story.chapter_finished.connect(_on_chapter_finished)
	Story.load_chapter(str(GameState.story.get("chapter", "ch00")))

	var boot := BootScreen.new()
	boot.finished.connect(_start_phone)
	_set_screen(boot)


func _set_screen(c: Control) -> void:
	if _screen != null:
		_screen.queue_free()
	_screen = c
	add_child(c)


func _start_phone() -> void:
	phone = PhoneOS.new()
	phone.restart_requested.connect(_on_restart)
	_set_screen(phone)
	Story.start()


func _on_language_changed(_lang: String) -> void:
	# Arayüzü yeni dille baştan kur, ayarlar açık kalsın.
	if phone == null:
		return
	_start_phone()
	phone.open("settings")


func _on_restart() -> void:
	_start_phone()


func _on_chapter_finished(_id: String) -> void:
	var end := ChapterEnd.new()
	end.closed.connect(end.queue_free)
	add_child(end)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if phone != null and phone.open_app != null:
			phone.close_app()
		else:
			get_tree().quit()
