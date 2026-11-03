class_name TerminalShell
extends RefCounted
## Terminalin komut mantığı. Arayüzden bağımsızdır, böylece test edilebilir.
## Hacklemenin tamamı kurgusaldır: komutlar oyun içindeki hayali ağda çalışır.
##
## execute() bir sonuç sözlüğü döndürür:
##   lines:    [[metin, renk_anahtarı], ...]   renk: "out", "ok", "warn", "err", "dim"
##   event:    hikayeye gönderilecek olay ("" olabilir)
##   minigame: başlatılacak mini oyun ("breach", "signal" ya da "")
##   clear:    ekran temizlensin mi

## Türkçe ve İngilizce komut adları -> tek bir kanonik ad.
const ALIASES := {
	"yardim": "help", "help": "help", "?": "help",
	"tara": "scan", "scan": "scan",
	"baglan": "connect", "connect": "connect", "ssh": "connect",
	"kir": "crack", "crack": "crack",
	"ls": "ls", "listele": "ls",
	"oku": "cat", "cat": "cat",
	"kes": "disconnect", "disconnect": "disconnect", "exit": "disconnect",
	"temizle": "clear", "clear": "clear",
	"iz": "trace", "trace": "trace",
}

var network: Dictionary = {}
## {known: [], breached: [], connected: ""} — GameState.story.network ile aynı sözlük.
var net_state: Dictionary = {}
var _pending_minigame_host := ""


func _init(chapter_network: Dictionary, state: Dictionary) -> void:
	network = chapter_network
	net_state = state
	for key in ["known", "breached"]:
		if not net_state.has(key):
			net_state[key] = []
	if not net_state.has("connected"):
		net_state["connected"] = ""


static func normalize(s: String) -> String:
	var out := s.strip_edges().to_lower()
	var map := {"ı": "i", "İ": "i", "i̇": "i", "ğ": "g", "ş": "s", "ç": "c", "ö": "o", "ü": "u"}
	for k in map:
		out = out.replace(k, map[k])
	return out


func hosts() -> Dictionary:
	return network.get("hosts", {})


func connected() -> String:
	return str(net_state.get("connected", ""))


func is_known(host: String) -> bool:
	return (net_state["known"] as Array).has(host)


func is_breached(host: String) -> bool:
	return (net_state["breached"] as Array).has(host)


func needs_crack(host: String) -> bool:
	var h: Dictionary = hosts().get(host, {})
	return h.get("firewall") != null and str(h.get("firewall", "")) != "" and not is_breached(host)


func execute(raw: String) -> Dictionary:
	var res := {"lines": [], "event": "", "minigame": "", "clear": false}
	var parts := raw.strip_edges().split(" ", false)
	if parts.is_empty():
		return res
	var cmd := str(ALIASES.get(normalize(parts[0]), ""))
	var arg := parts[1].strip_edges().to_lower() if parts.size() > 1 else ""
	match cmd:
		"help":
			for key in ["term.help.scan", "term.help.connect", "term.help.crack", "term.help.ls", "term.help.cat", "term.help.disconnect", "term.help.trace", "term.help.clear"]:
				_line(res, Loc.t(key), "out")
		"scan":
			_line(res, Loc.t("term.scanning"), "dim")
			for host in network.get("scan_order", hosts().keys()):
				var h: Dictionary = hosts().get(host, {})
				if not is_known(host):
					(net_state["known"] as Array).append(host)
				var lock := Loc.t("term.locked") if needs_crack(host) else Loc.t("term.open")
				_line(res, "  %s  %s  — %s" % [host, lock, Loc.pick(h.get("desc", ""))], "ok" if not needs_crack(host) else "warn")
			res["event"] = "cmd:scan"
		"connect":
			if arg == "":
				_line(res, Loc.t("term.usage.connect"), "err")
			elif not hosts().has(arg):
				_line(res, Loc.t("term.no_host", {"host": arg}), "err")
			elif not is_known(arg):
				_line(res, Loc.t("term.unknown_host"), "err")
			else:
				net_state["connected"] = arg
				_line(res, Loc.t("term.connected", {"host": arg}), "ok")
				if needs_crack(arg):
					_line(res, Loc.t("term.firewall"), "warn")
				res["event"] = "cmd:connect:" + arg
		"crack":
			var host := connected()
			if host == "":
				_line(res, Loc.t("term.not_connected"), "err")
			elif not needs_crack(host):
				_line(res, Loc.t("term.already_open"), "dim")
			else:
				_pending_minigame_host = host
				res["minigame"] = str(hosts()[host].get("firewall", "breach"))
				_line(res, Loc.t("term.crack_start"), "warn")
		"ls":
			var host := connected()
			if host == "":
				_line(res, Loc.t("term.not_connected"), "err")
			elif needs_crack(host):
				_line(res, Loc.t("term.denied"), "err")
			else:
				var files: Dictionary = hosts()[host].get("files", {})
				if files.is_empty():
					_line(res, Loc.t("term.empty"), "dim")
				for name in files.keys():
					_line(res, "  " + str(name), "out")
				res["event"] = "cmd:ls"
		"cat":
			var host := connected()
			if host == "":
				_line(res, Loc.t("term.not_connected"), "err")
			elif needs_crack(host):
				_line(res, Loc.t("term.denied"), "err")
			elif arg == "":
				_line(res, Loc.t("term.usage.cat"), "err")
			else:
				var files: Dictionary = hosts()[host].get("files", {})
				if not files.has(arg):
					_line(res, Loc.t("term.no_file", {"file": arg}), "err")
				else:
					_line(res, "── %s ──" % arg, "dim")
					for l in Loc.pick(files[arg]).split("\n"):
						_line(res, l, "out")
					res["event"] = "cmd:cat:" + arg
		"disconnect":
			if connected() == "":
				_line(res, Loc.t("term.not_connected"), "dim")
			else:
				_line(res, Loc.t("term.disconnected", {"host": connected()}), "dim")
				net_state["connected"] = ""
				res["event"] = "cmd:disconnect"
		"trace":
			_line(res, Loc.t("term.trace", {"value": int(GameState.trace)}), "warn" if GameState.trace >= 50 else "out")
		"clear":
			res["clear"] = true
		_:
			_line(res, Loc.t("term.unknown_cmd", {"cmd": parts[0]}), "err")
	return res


## Mini oyun bittiğinde terminal çağırır.
func on_minigame_result(kind: String, success: bool) -> Dictionary:
	var res := {"lines": [], "event": "minigame:%s:%s" % [kind, "success" if success else "fail"], "minigame": "", "clear": false}
	var host := _pending_minigame_host
	_pending_minigame_host = ""
	if success and host != "":
		if not is_breached(host):
			(net_state["breached"] as Array).append(host)
		_line(res, Loc.t("term.crack_ok", {"host": host}), "ok")
	else:
		_line(res, Loc.t("term.crack_fail"), "err")
	return res


## Ekranın altındaki hızlı komut düğmeleri. Telefonda yazmak zor, bu yüzden önemli.
func suggestions() -> Array:
	var out: Array = []
	var host := connected()
	if host == "":
		out.append(Loc.t("cmd.scan"))
		for h in net_state["known"]:
			out.append("%s %s" % [Loc.t("cmd.connect"), h])
	else:
		if needs_crack(host):
			out.append(Loc.t("cmd.crack"))
		else:
			out.append("ls")
			for f in (hosts()[host].get("files", {}) as Dictionary).keys():
				out.append("%s %s" % [Loc.t("cmd.cat"), f])
		out.append(Loc.t("cmd.disconnect"))
	out.append(Loc.t("cmd.help"))
	return out


func _line(res: Dictionary, text: String, color: String) -> void:
	(res["lines"] as Array).append([text, color])
