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
	_test_patch_logic()
	await _test_full_prologue()
	await _test_chapter1()
	await _test_screens()


func _test_scripts_load() -> void:
	for path in _find_files("res://", ".gd"):
		var s: Variant = load(path)
		check(s is GDScript and (s as GDScript).can_instantiate(), "betik yüklenemedi: " + path)


func _test_translations() -> void:
	var tr_table := Loc.read_table("tr")
	var en_table := Loc.read_table("en")
	check(tr_table.size() > 50, "tr.json boş görünüyor")
	for k in tr_table:
		check(en_table.has(k), "en.json içinde eksik anahtar: " + k)
	for k in en_table:
		check(tr_table.has(k), "tr.json içinde eksik anahtar: " + k)


func _test_chapter_data() -> void:
	for id in ["ch00", "ch01"]:
		_check_chapter(id)
	check(Story.read_chapter("ch00").get("next") == "ch01", "ch00 -> ch01 bağlantısı yok")


func _check_chapter(id: String) -> void:
	var ch := Story.read_chapter(id)
	check(not ch.is_empty(), id + " yüklenemedi")
	var beats: Array = ch.get("beats", [])
	var labels := Story.index_labels(beats)
	check(beats.size() > 10, id + " çok kısa")
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
	check(has_end, id + " end_chapter ile bitmiyor")
	var puzzles: Dictionary = ch.get("puzzles", {})
	for pid in puzzles:
		var p: Dictionary = puzzles[pid]
		_check_lang(p.get("title"), "bulmaca başlığı " + str(pid))
		_check_lang(p.get("goal"), "bulmaca amacı " + str(pid))
		var lines: Array = p.get("lines", [])
		var blank := int(p.get("blank", -1))
		check(blank >= 0 and blank < lines.size() and str(lines[blank]).contains("???"), "bulmaca boşluğu yanlış: " + str(pid))
		check(CodePatchGame.is_correct(p, str(p.get("answer", ""))), "bulmaca cevabı kendini kabul etmiyor: " + str(pid))
		var opts: Array = p.get("options", [])
		check(opts.has(p.get("answer")), "doğru cevap seçeneklerde yok: " + str(pid))
	var hosts: Dictionary = ch.get("network", {}).get("hosts", {})
	for h in ch.get("network", {}).get("scan_order", []):
		check(hosts.has(h), "scan_order içindeki cihaz tanımlı değil: " + str(h))
	for h in hosts:
		_check_lang(hosts[h].get("desc"), "cihaz açıklaması " + str(h))
		var fw := str(hosts[h].get("firewall", "")) if hosts[h].get("firewall") != null else ""
		if fw.begins_with("patch:"):
			check(puzzles.has(fw.substr(6)), "cihazın bulmacası tanımlı değil: " + fw)
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


func _test_patch_logic() -> void:
	var p := {"answer": "OFF", "accept": ["0"]}
	check(CodePatchGame.is_correct(p, " off "), "küçük harf cevap kabul edilmedi")
	check(CodePatchGame.is_correct(p, "\"OFF\""), "tırnaklı cevap kabul edilmedi")
	check(CodePatchGame.is_correct(p, "0"), "alternatif cevap kabul edilmedi")
	check(not CodePatchGame.is_correct(p, "ON"), "yanlış cevap kabul edildi")
	check(not CodePatchGame.is_correct(p, ""), "boş cevap kabul edildi")


## Prolog bitince bölüm 1'e geçer ve bölüm 1'i sonuna kadar oynar.
func _test_chapter1() -> void:
	check(Story.is_done() and Story.next_chapter_id() == "ch01", "prologdan sonra ch01 yok")
	check(Story.advance_chapter(), "ch01'e geçilemedi")
	check(str(Story.state()["chapter"]) == "ch01", "bölüm kimliği değişmedi")
	check(Story.state()["flags"].get("approach") == "leak", "bayraklar bölüm geçişinde kayboldu")
	check(Story.is_unlocked("terminal"), "terminal bölüm geçişinde kilitlendi")
	var sh := TerminalShell.new(Story.chapter["network"], Story.state()["network"])
	_run_cmds(sh, ["tara", "bağlan apartman-yonetim", "ls", "oku kapici_notu.txt", "kes", "bağlan arka-kapi-kilit"])
	var r := sh.execute("kır")
	check(r["minigame"] == "patch:back_door", "kapı bulmacası başlamadı: " + str(r["minigame"]))
	var g := TerminalApp.make_minigame(r["minigame"]) as CodePatchGame
	check(g != null and str(g.puzzle.get("answer")) == "KAPICI-0412", "bulmaca verisi yüklenmedi")
	g.free()
	Story.post_event(sh.on_minigame_result(r["minigame"], false)["event"])
	check(Story.current_wait_event() == "minigame:patch:back_door:success", "kapı hatasından sonra tekrar beklenmiyor")
	sh.execute("kır")
	Story.post_event(sh.on_minigame_result("patch:back_door", true)["event"])
	check(Story.pending_choices().size() == 2, "sokak seçimi gelmedi")
	Story.choose(0)
	sh.execute("kes")
	_run_cmds(sh, ["bağlan kurdele-sk-lambalar"])
	sh.execute("kır")
	Story.post_event(sh.on_minigame_result("patch:lamps", true)["event"])
	sh.execute("kes")
	_run_cmds(sh, ["bağlan argos-drone-3"])
	sh.execute("kır")
	Story.post_event(sh.on_minigame_result("signal", true)["event"])
	_run_cmds(sh, ["oku devriye_plani.txt", "kes", "bağlan tophane-turnike"])
	sh.execute("kır")
	Story.post_event(sh.on_minigame_result("patch:gate", true)["event"])
	check(Story.pending_choices().size() == 2, "tramvay seçimi gelmedi")
	Story.choose(1)
	await get_tree().process_frame
	check(Story.is_done(), "bölüm 1 bitmedi, beat: %d" % int(Story.state()["beat"]))
	check(Story.next_chapter_id() == "", "bölüm 1'den sonra beklenmeyen bölüm")


func _run_cmds(sh: TerminalShell, cmds: Array) -> void:
	for c in cmds:
		var r := sh.execute(str(c))
		if r["event"] != "":
			Story.post_event(r["event"])


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
	for locked_app in ["terminal", "map"]:
		phone.open(locked_app)
		check(phone.open_app == null, "kilitli uygulama açıldı: " + locked_app)
	for app in ["messages", "settings"]:
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

	Story.load_chapter("ch01")
	var patch := TerminalApp.make_minigame("patch:back_door") as CodePatchGame
	host.add_child(patch)
	await _frames(3)
	patch._answer.text = "yanlış"
	patch.submit()
	patch._answer.text = "kapici-0412"
	patch.submit()
	check(not patch.running, "doğru cevapla bulmaca bitmedi")
	await _frames(2)
	patch.queue_free()
	Story.load_chapter("ch00")

	for game in [BreachGame.new(), SignalGame.new()]:
		host.add_child(game)
		await _frames(5)
		game.queue_free()

	var map_app := MapApp.new()
	host.add_child(map_app)
	await _frames(2)
	map_app.queue_free()

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
