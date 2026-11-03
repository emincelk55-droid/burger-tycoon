extends Node
## Otomatik testler. Çalıştırma:  godot --headless -- --run-tests
## Başarısız olursa çıkış kodu 1 olur (GitHub Actions bunu yakalar).

var _failures: Array[String] = []
var _count := 0


func _ready() -> void:
	GameState.save_path = "user://test_save.json"
	GameState.reset_progress()
	await _run_all()
	if FileAccess.file_exists(GameState.save_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(GameState.save_path))
	print("")
	if _failures.is_empty():
		print("TESTLER GEÇTİ: %d kontrol" % _count)
		get_tree().quit(0)
	else:
		for f in _failures:
			printerr("BAŞARISIZ: " + f)
		printerr("TESTLER BAŞARISIZ: %d / %d" % [_failures.size(), _count])
		get_tree().quit(1)


func check(cond: bool, what: String) -> void:
	_count += 1
	if not cond:
		_failures.append(what)


func _run_all() -> void:
	_test_scripts_load()
	_test_translations()
	_test_chapter_data()
	_test_shell()
	_test_minigame_math()
	_test_save_roundtrip()
	await _test_full_prologue()
	await _test_screens()


func _test_scripts_load() -> void:
	for path in _find_files("res://", ".gd"):
		var s: Variant = load(path)
		check(s is GDScript and (s as GDScript).can_instantiate(), "betik yüklenemedi: " + path)


func _test_translations() -> void:
	var tr := Loc.read_table("tr")
	var en := Loc.read_table("en")
	check(tr.size() > 50, "tr.json boş görünüyor")
	for k in tr:
		check(en.has(k), "en.json içinde eksik anahtar: " + k)
	for k in en:
		check(tr.has(k), "tr.json içinde eksik anahtar: " + k)


func _test_chapter_data() -> void:
	var ch := Story.read_chapter("ch00")
	check(not ch.is_empty(), "ch00 yüklenemedi")
	var beats: Array = ch.get("beats", [])
	var labels := Story.index_labels(beats)
	check(beats.size() > 10, "ch00 çok kısa")
	var has_end := false
	for b in beats:
		var kind := str(b.get("type", ""))
		check(Story.BEAT_TYPES.has(kind), "bilinmeyen beat türü: " + kind)
		if kind == "end_chapter":
			has_end = true
		if b.has("text"):
			_check_lang(b["text"], "beat metni")
		if b.has("hint"):
			_check_lang(b["hint"], "ipucu")
		for key in ["target", "fail_goto"]:
			if b.has(key):
				check(labels.has(str(b[key])), "goto hedefi yok: " + str(b[key]))
		for opt in b.get("options", []):
			_check_lang(opt.get("text"), "seçenek")
			if opt.has("goto"):
				check(labels.has(str(opt["goto"])), "seçenek hedefi yok: " + str(opt["goto"]))
	check(has_end, "ch00 end_chapter ile bitmiyor")
	var hosts: Dictionary = ch.get("network", {}).get("hosts", {})
	for h in ch.get("network", {}).get("scan_order", []):
		check(hosts.has(h), "scan_order içindeki cihaz tanımlı değil: " + str(h))
	for h in hosts:
		_check_lang(hosts[h].get("desc"), "cihaz açıklaması " + str(h))
		for f in hosts[h].get("files", {}):
			_check_lang(hosts[h]["files"][f], "dosya " + str(f))


func _check_lang(v: Variant, what: String) -> void:
	check(v is Dictionary and v.has("tr") and v.has("en") and str(v["tr"]) != "" and str(v["en"]) != "", what + ": tr/en eksik")


func _test_shell() -> void:
	var ch := Story.read_chapter("ch00")
	var net := {}
	var sh := TerminalShell.new(ch["network"], net)
	check(TerminalShell.normalize("BAĞLAN") == "baglan", "normalize Türkçe karakterleri çevirmiyor")
	check(TerminalShell.normalize("Kır") == "kir", "normalize 'Kır' hatası")
	var r := sh.execute("bağlan argos-relay-07")
	check(r["event"] == "", "taramadan bağlanılabiliyor")
	r = sh.execute("tara")
	check(r["event"] == "cmd:scan", "tara olayı yok")
	check((net["known"] as Array).size() == 3, "tara cihazları bulmadı")
	r = sh.execute("ls")
	check(r["event"] == "", "bağlı değilken ls çalıştı")
	r = sh.execute("connect ARGOS-relay-07")
	check(r["event"] == "cmd:connect:argos-relay-07", "connect olayı yanlış: " + str(r["event"]))
	r = sh.execute("ls")
	check(r["event"] == "", "duvar kırılmadan ls çalıştı")
	r = sh.execute("kır")
	check(r["minigame"] == "breach", "kır mini oyun başlatmadı")
	r = sh.on_minigame_result("breach", true)
	check(r["event"] == "minigame:breach:success", "mini oyun olayı yanlış")
	check(sh.is_breached("argos-relay-07"), "cihaz açılmadı")
	r = sh.execute("oku basin_bulteni_taslak.txt")
	check(r["event"] == "cmd:cat:basin_bulteni_taslak.txt", "oku olayı yanlış")
	check(sh.suggestions().size() >= 3, "öneri listesi kısa")
	r = sh.execute("asdf")
	check((r["lines"] as Array).size() == 1, "bilinmeyen komut mesajı yok")


func _test_minigame_math() -> void:
	check(BreachGame.is_hit(0.5, 0.5, 0.2), "is_hit merkez")
	check(not BreachGame.is_hit(0.8, 0.5, 0.2), "is_hit dışarısı")
	check(SignalGame.match_score(2.0, 0.0, 2.0, 0.0) > 0.99, "match_score aynı dalga")
	check(SignalGame.match_score(1.0, PI, 4.0, 0.0) < 0.3, "match_score farklı dalga")


func _test_save_roundtrip() -> void:
	GameState.reset_progress()
	GameState.story["flags"]["test"] = "ok"
	GameState.trace = 42.0
	GameState.save_game()
	GameState.load_game()
	check(GameState.story["flags"].get("test") == "ok", "kayıt bayrağı kayboldu")
	check(is_equal_approx(GameState.trace, 42.0), "iz kaydedilmedi")
	GameState.reset_progress()


## Prologu baştan sona oynar: seçimler, komutlar, bir başarısız ve bir başarılı mini oyun.
func _test_full_prologue() -> void:
	GameState.reset_progress()
	Story.fast_mode = true
	var finished := [false]
	var cb := func(_id: String) -> void: finished[0] = true
	Story.chapter_finished.connect(cb)
	check(Story.load_chapter("ch00"), "ch00 yüklenemedi")
	Story.start()
	check(Story.pending_choices().size() == 3, "ilk seçim gelmedi")
	Story.choose(2)
	check(Story.is_unlocked("terminal"), "terminal açılmadı")
	check(Story.current_wait_event() == "cmd:scan", "tara beklenmiyor: " + Story.current_wait_event())

	var sh := TerminalShell.new(Story.chapter["network"], Story.state()["network"])
	for cmd in ["tara", "bağlan argos-relay-07", "kır"]:
		var r := sh.execute(cmd)
		if r["event"] != "":
			Story.post_event(r["event"])
	check(Story.post_event(sh.on_minigame_result("breach", false)["event"]), "başarısız mini oyun işlenmedi")
	check(Story.current_wait_event() == "minigame:breach:success", "başarısızlıktan sonra tekrar beklenmiyor")
	sh.execute("kır")
	Story.post_event(sh.on_minigame_result("breach", true)["event"])
	Story.post_event(sh.execute("oku basin_bulteni_taslak.txt")["event"])
	check(Story.pending_choices().size() == 3, "yol seçimi gelmedi")
	Story.choose(1)
	check(Story.state()["flags"].get("approach") == "leak", "yol bayrağı kaydedilmedi")
	sh.execute("kes")
	for cmd in ["bağlan kamera-tarlabasi-12", "kır"]:
		var r := sh.execute(cmd)
		if r["event"] != "":
			Story.post_event(r["event"])
	Story.post_event(sh.on_minigame_result("signal", true)["event"])
	await get_tree().process_frame
	check(Story.is_done(), "prolog bitmedi, kalan beat: %d" % int(Story.state()["beat"]))
	check(finished[0], "chapter_finished sinyali gelmedi")
	Story.chapter_finished.disconnect(cb)

	# Kayıttan devam: bitmiş durum geri yüklenmeli.
	GameState.load_game()
	check(Story.is_done(), "bitmiş bölüm kayıttan yüklenmedi")


## Bütün ekranları gerçekten oluşturur ve birkaç kare çalıştırır.
func _test_screens() -> void:
	GameState.reset_progress()
	Story.load_chapter("ch00")
	Story.start()
	var host := Control.new()
	host.theme = UIKit.make_theme()
	add_child(UIKit.full_rect(host))

	var boot := BootScreen.new()
	host.add_child(boot)
	await _frames(3)
	boot.queue_free()

	var phone := PhoneOS.new()
	host.add_child(phone)
	await _frames(3)
	phone.open("terminal")
	check(phone.open_app == null, "kilitli terminal açıldı")
	for app in ["messages", "map", "settings"]:
		phone.open(app)
		check(phone.open_app != null, "uygulama açılmadı: " + app)
		await _frames(3)
		phone.close_app()
		await _frames(1)
	Story.choose(0)
	await _frames(2)
	phone.open("terminal")
	check(phone.open_app is TerminalApp, "terminal açılmadı")
	await _frames(2)
	var term := phone.open_app as TerminalApp
	term.run_command("tara")
	term.run_command("bağlan argos-relay-07")
	term.run_command("kır")
	await _frames(5)
	phone.close_app()
	await _frames(2)

	for game in [BreachGame.new(), SignalGame.new()]:
		host.add_child(game)
		await _frames(5)
		game.queue_free()

	var end := ChapterEnd.new()
	host.add_child(end)
	await _frames(2)
	host.queue_free()
	await _frames(1)
	check(true, "ekranlar")


func _frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _find_files(dir: String, ext: String) -> Array[String]:
	var out: Array[String] = []
	var d := DirAccess.open(dir)
	if d == null:
		return out
	for f in d.get_files():
		if f.ends_with(ext):
			out.append(dir.path_join(f))
	for sub in d.get_directories():
		if sub.begins_with("."):
			continue
		out.append_array(_find_files(dir.path_join(sub), ext))
	return out
