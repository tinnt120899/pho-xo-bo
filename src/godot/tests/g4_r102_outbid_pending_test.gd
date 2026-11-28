extends SceneTree
## G4 R102 AUCTION OUTBID OFFLINE TEST — chay headless, khong can trinh duyet:
##   godot --headless --path src/godot -s res://tests/g4_r102_outbid_pending_test.gd
## Kiem tra vong 102 (G4 §123 — auction_outbid phai toi tay nguoi
## vua bi vuot gia du ho offline luc co gia cao hon):
## (a) cleaners _clean_outbid_pending (giu du, loc sai, cap 10);
## (b) A dan dau 1.000.000 roi offline, B dau 1.001.000 -> server
## giai phong tien giu ho cua A, xep outbid vao hang doi
## _outbid_pending cho A (khong chi broadcast auction_bid cho
## nguoi online), A hello lai nhan dung 1 lan, khong trung;
## (c) hang doi persist qua restart (stop + restart -> state file
## giu outbid_pending, A hello lai van nhan duoc);
## (d) online: A dau lai khi B dang online -> B nhan outbid ngay,
## hang doi rong; tu nang gia cua chinh minh thi khong ai nhan
## outbid;
## (e) file cu v101 (khong co khoa outbid_pending) van nap duoc.
## In "G4 R102 AUCTION OUTBID OFFLINE TEST: n/n PASS".

const TEST_PORT := 18910
const STATE_PATH := "/tmp/pxb-r102-state.json"
const PHASE_TIMEOUT_MS := 20000
const GLOBAL_TIMEOUT_MS := 180000

var _pass := 0
var _fail := 0
var _frame := 0
var _started_ms := 0
var _phase := 0
var _step := 0
var _phase_deadline_ms := 0
var _finished := false
var _server: PxbServer = null
var _port := TEST_PORT
var _cs: PxbOnline = null
var _ca: PxbOnline = null
var _cb: PxbOnline = null
var _inv_s: PxbInventory = null
var _inv_a: PxbInventory = null
var _inv_b: PxbInventory = null
var _eco_s: PxbEconomy = null
var _eco_a: PxbEconomy = null
var _eco_b: PxbEconomy = null
var _auction_id := ""
var _outbid_a := 0
var _last_outbid_a := {}
var _last_outbid_a_old_bid := -1
var _last_outbid_a_old_bidder := ""
var _outbid_b := 0
var _last_outbid_b := {}
var _last_outbid_b_old_bid := -1
var _last_outbid_b_old_bidder := ""
var _seen_at_ms := 0


func _check(test_name: String, cond: bool, detail: String = "") -> void:
	if cond:
		_pass += 1
		print("  PASS ", test_name)
	else:
		_fail += 1
		print("  FAIL ", test_name, " ", detail)


func _finish() -> void:
	if _finished:
		return
	_finished = true
	if _cs != null and is_instance_valid(_cs):
		_cs.queue_free()
	if _ca != null and is_instance_valid(_ca):
		_ca.queue_free()
	if _cb != null and is_instance_valid(_cb):
		_cb.queue_free()
	if _server != null and is_instance_valid(_server):
		if _server.running:
			_server.stop_server()
		_server.queue_free()
	print("G4 R102 AUCTION OUTBID OFFLINE TEST: %d/%d PASS" % [_pass, _pass + _fail])
	quit(0 if _fail == 0 else 1)


func _on_a_outbid(auction: Dictionary, old_bid: int, old_bidder: String) -> void:
	_outbid_a += 1
	_last_outbid_a = auction
	_last_outbid_a_old_bid = old_bid
	_last_outbid_a_old_bidder = old_bidder


func _on_b_outbid(auction: Dictionary, old_bid: int, old_bidder: String) -> void:
	_outbid_b += 1
	_last_outbid_b = auction
	_last_outbid_b_old_bid = old_bid
	_last_outbid_b_old_bidder = old_bidder


func _delete_state_file() -> void:
	if FileAccess.file_exists(STATE_PATH):
		DirAccess.remove_absolute(STATE_PATH)


func _read_state_file() -> Dictionary:
	if not FileAccess.file_exists(STATE_PATH):
		return {}
	var f := FileAccess.open(STATE_PATH, FileAccess.READ)
	if f == null:
		return {}
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if parsed is Dictionary:
		return parsed
	return {}


func _restart_server(new_port: int) -> Dictionary:
	if _server != null:
		if _server.running:
			_server.stop_server()
		_server.free()
		_server = null
	_port = new_port
	_server = PxbServer.new()
	_server.state_file_path = STATE_PATH
	root.add_child(_server)
	return _server.start_server(_port)


# S: nguoi ban — com-tam x1, vi 0.
func _new_client_s() -> void:
	if _cs != null:
		_cs.free()
		_cs = null
	_inv_s = PxbInventory.new()
	_eco_s = PxbEconomy.new()
	_inv_s.add("com-tam", 1)
	_cs = PxbOnline.new()
	root.add_child(_cs)
	_cs.trade_inventory = _inv_s
	_cs.trade_economy = _eco_s


# A: nguoi dau gia dau — vi 2 trieu, tui trong.
func _new_client_a() -> void:
	if _ca != null:
		_ca.free()
		_ca = null
	_outbid_a = 0
	_last_outbid_a = {}
	_last_outbid_a_old_bid = -1
	_last_outbid_a_old_bidder = ""
	_inv_a = PxbInventory.new()
	_eco_a = PxbEconomy.new()
	_eco_a.money = 2000000
	_ca = PxbOnline.new()
	root.add_child(_ca)
	_ca.trade_inventory = _inv_a
	_ca.trade_economy = _eco_a
	_ca.ws_auction_outbid.connect(_on_a_outbid)


# B: nguoi dau gia sau — vi 2 trieu, tui trong.
func _new_client_b() -> void:
	if _cb != null:
		_cb.free()
		_cb = null
	_outbid_b = 0
	_last_outbid_b = {}
	_last_outbid_b_old_bid = -1
	_last_outbid_b_old_bidder = ""
	_inv_b = PxbInventory.new()
	_eco_b = PxbEconomy.new()
	_eco_b.money = 2000000
	_cb = PxbOnline.new()
	root.add_child(_cb)
	_cb.trade_inventory = _inv_b
	_cb.trade_economy = _eco_b
	_cb.ws_auction_outbid.connect(_on_b_outbid)


func _good_pending_msg() -> Dictionary:
	return {"type": "auction_outbid", "auction_id": "auc-9",
		"seller_player_id": "player-s", "item_id": "com-tam",
		"start_price": 1000000, "current_bid": 1001000,
		"current_bidder_player_id": "player-b",
		"created_at_ms": 1000, "ends_at_ms": 3600000,
		"old_bid": 1000000, "old_bidder_player_id": "player-a",
		"new_bid": 1001000, "new_bidder_player_id": "player-b"}


func _init() -> void:
	_started_ms = Time.get_ticks_msec()
	_delete_state_file()
	# --- Unit thuan (khong can mang): cleaner _clean_outbid_pending.
	var probe := PxbServer.new()
	probe.state_file_path = STATE_PATH
	var good := [_good_pending_msg()]
	var cleaned := probe._clean_outbid_pending(good)
	_check("clean outbid pending hop le giu du 1", cleaned.size() == 1, str(cleaned))
	var bad := _good_pending_msg()
	bad["type"] = "auction_bid"
	_check("clean outbid pending type la -> bo", probe._clean_outbid_pending([bad]).is_empty())
	bad = _good_pending_msg()
	bad["auction_id"] = ""
	_check("clean outbid pending thieu auction_id -> bo", probe._clean_outbid_pending([bad]).is_empty())
	bad = _good_pending_msg()
	bad["old_bidder_player_id"] = ""
	_check("clean outbid pending thieu old_bidder -> bo", probe._clean_outbid_pending([bad]).is_empty())
	bad = _good_pending_msg()
	bad["old_bid"] = -5
	_check("clean outbid pending old_bid am -> bo", probe._clean_outbid_pending([bad]).is_empty())
	_check("clean outbid pending khong phai Array -> []",
		probe._clean_outbid_pending({}).is_empty())
	var many: Array = []
	for i in range(12):
		var m := _good_pending_msg()
		m["auction_id"] = "auc-%d" % i
		many.append(m)
	_check("clean outbid pending cap 10 / nguoi", probe._clean_outbid_pending(many).size() == 10,
		str(probe._clean_outbid_pending(many).size()))
	_check("clean outbid pending giu dung thu tu (moi nhat cuoi)",
		String((probe._clean_outbid_pending(many)[9] as Dictionary).get("auction_id", "")) == "auc-9")
	probe.free()
	# --- Mo server that.
	_server = PxbServer.new()
	_server.state_file_path = STATE_PATH
	root.add_child(_server)
	var r: Dictionary = _server.start_server(TEST_PORT)
	_check("server mo cong 18910", bool(r.get("ok", false)), str(r))
	_phase_deadline_ms = Time.get_ticks_msec() + PHASE_TIMEOUT_MS
	process_frame.connect(_on_frame)


func _on_frame() -> void:
	if _finished:
		return
	_frame += 1
	if _server != null:
		_server.poll()
	if _cs != null:
		_cs.poll_ws()
	if _ca != null:
		_ca.poll_ws()
	if _cb != null:
		_cb.poll_ws()
	var now := Time.get_ticks_msec()
	if now > _started_ms + GLOBAL_TIMEOUT_MS:
		_check("global timeout 180s (khong treo)", false, "phase=%d step=%d" % [_phase, _step])
		_finish()
		return
	if _frame > 3 and now > _phase_deadline_ms and _phase_deadline_ms > 0:
		_check("phase %d xong truoc deadline" % _phase, false, "step=%d" % _step)
		_finish()
		return
	match _phase:
		0:
			_phase0(now)
		1:
			_phase1(now)
		2:
			_phase2(now)
		3:
			_phase3(now)
		4:
			_phase4(now)
		5:
			_phase5(now)
		6:
			_phase6(now)
		7:
			_phase7(now)


# (0) Noi S + A + B; A + B dong bo so cai de server theo doi reserved.
func _phase0(now: int) -> void:
	match _step:
		0:
			_new_client_s()
			var rs: Dictionary = _cs.connect_ws("ws://127.0.0.1:%d" % _port, "player-s", "Sáu")
			_check("client S noi cong 18910", bool(rs.get("ok", false)), str(rs))
			_new_client_a()
			var ra: Dictionary = _ca.connect_ws("ws://127.0.0.1:%d" % _port, "player-a", "An")
			_check("client A noi cong 18910", bool(ra.get("ok", false)), str(ra))
			_new_client_b()
			var rb: Dictionary = _cb.connect_ws("ws://127.0.0.1:%d" % _port, "player-b", "Bình")
			_check("client B noi cong 18910", bool(rb.get("ok", false)), str(rb))
			_step = 1
		1:
			if not _cs.is_ws_connected() or not _ca.is_ws_connected() or not _cb.is_ws_connected():
				return
			_check("S + A + B deu da noi WS", true)
			var sa: Dictionary = _ca.send_ws_ledger_sync()
			_check("A dong bo so cai", bool(sa.get("ok", false)), str(sa))
			var sb: Dictionary = _cb.send_ws_ledger_sync()
			_check("B dong bo so cai", bool(sb.get("ok", false)), str(sb))
			_step = 2
		2:
			if not _server.ledger.has("player-a") or not _server.ledger.has("player-b"):
				return
			_check("server co ledger A + B", true)
			_phase = 1
			_step = 0
			_phase_deadline_ms = now + PHASE_TIMEOUT_MS


# (1) S mo phien com-tam 1 trieu / 3600s; A dau gia 1 trieu -> dan dau.
func _phase1(now: int) -> void:
	match _step:
		0:
			var res: Dictionary = _cs.send_ws_auction_create("com-tam", 1000000, 3600)
			_check("S mo phien com-tam 1.000.000 / 3600s ok", bool(res.get("ok", false)), str(res))
			_step = 1
		1:
			if _cs.ws_auctions.is_empty() or _ca.ws_auctions.is_empty() or _cb.ws_auctions.is_empty():
				return
			_auction_id = String((_cs.ws_auctions[0] as Dictionary).get("auction_id", ""))
			_check("phien com-tam mo, chua ai dau gia", int((_cs.ws_auctions[0] as Dictionary).get("current_bid", -1)) == 0)
			var res: Dictionary = _ca.send_ws_auction_bid(_auction_id, 1000000)
			_check("A dau gia 1.000.000 ok", bool(res.get("ok", false)), str(res))
			_step = 2
		2:
			if int((_ca.ws_auctions[0] as Dictionary).get("current_bid", -1)) != 1000000:
				return
			_check("A la nguoi dan dau 1.000.000",
				String((_ca.ws_auctions[0] as Dictionary).get("current_bidder_player_id", "")) == "player-a")
			var entry_a: Dictionary = _server.ledger.get("player-a", {})
			_check("server giu ho 1.000.000 cua A",
				int(entry_a.get("reserved", -1)) == 1000000, str(entry_a))
			_check("data outbid_undelivered 0 truoc khi vuot gia",
				int(_server.data().get("outbid_undelivered", -1)) == 0, str(_server.data()))
			_check("A chua nhan outbid nao", _outbid_a == 0)
			_phase = 2
			_step = 0
			_phase_deadline_ms = now + PHASE_TIMEOUT_MS


# (2) A offline; B dau 1.001.000 -> vuot gia A: server giai phong
# tien giu ho cua A + xep outbid vao hang doi cho A.
func _phase2(now: int) -> void:
	match _step:
		0:
			if _ca != null:
				_ca.free()
				_ca = null
			_step = 1
		1:
			# Doi server nhan ra A da mat ket noi — neu B dau ngay
			# khi peer A van con trong players thi tin outbid se
			# gui vao peer chet thay vi xep hang doi.
			if _server._find_peer_by_player_id("player-a") != -1:
				return
			_check("server da xoa A khoi presence", true)
			var res: Dictionary = _cb.send_ws_auction_bid(_auction_id, 1001000)
			_check("B dau gia 1.001.000 ok", bool(res.get("ok", false)), str(res))
			_step = 2
		2:
			if int((_cb.ws_auctions[0] as Dictionary).get("current_bid", -1)) != 1001000:
				return
			_check("B la nguoi dan dau 1.001.000",
				String((_cb.ws_auctions[0] as Dictionary).get("current_bidder_player_id", "")) == "player-b")
			var entry_a2: Dictionary = _server.ledger.get("player-a", {})
			_check("server giai phong tien giu ho cua A ve 0",
				int(entry_a2.get("reserved", -1)) == 0, str(entry_a2))
			_check("server giu ho 1.001.000 cua B",
				int((_server.ledger.get("player-b", {}) as Dictionary).get("reserved", -1)) == 1001000,
				str(_server.ledger.get("player-b", {})))
			_check("data outbid_undelivered 1 (no cho A)",
				int(_server.data().get("outbid_undelivered", -1)) == 1, str(_server.data()))
			var pend: Dictionary = _server._outbid_pending
			_check("hang doi _outbid_pending co player-a", pend.has("player-a"), str(pend.keys()))
			if pend.has("player-a"):
				var arr: Array = pend["player-a"]
				_check("hang doi player-a 1 thong bao", arr.size() == 1, str(arr))
				if arr.size() == 1:
					var m: Dictionary = arr[0]
					_check("thong bao cho la auction_outbid",
						String(m.get("type", "")) == "auction_outbid"
						and String(m.get("auction_id", "")) == _auction_id
						and int(m.get("old_bid", -1)) == 1000000
						and String(m.get("old_bidder_player_id", "")) == "player-a"
						and int(m.get("new_bid", -1)) == 1001000
						and String(m.get("new_bidder_player_id", "")) == "player-b",
						str(m))
			_check("B khong nhan outbid (B chua tung dan dau)", _outbid_b == 0)
			_phase = 3
			_step = 0
			_phase_deadline_ms = now + PHASE_TIMEOUT_MS


# (3) Stop + restart 18911 — hang doi phai persist trong file.
func _phase3(now: int) -> void:
	if _step == 0:
		_server.stop_server()
		var st := _read_state_file()
		var pend: Dictionary = st.get("outbid_pending", {})
		_check("state file giu outbid_pending sau stop", pend.has("player-a"), str(pend.keys()))
		var arr: Array = pend.get("player-a", [])
		_check("outbid_pending player-a 1 thong bao", arr.size() == 1, str(arr))
		if _cb != null:
			_cb.free()
			_cb = null
		if _cs != null:
			_cs.free()
			_cs = null
		var r: Dictionary = _restart_server(18911)
		_check("server restart mo cong 18911", bool(r.get("ok", false)), str(r))
		_check("restart: outbid_pending van 1 nguoi no",
			int(_server.data().get("outbid_undelivered", -1)) == 1, str(_server.data()))
		_check("restart: phien van mo", _server.auctions.size() == 1,
			str(_server.auctions.size()))
		# B noi lai truoc (quen so cai + phien mo).
		_new_client_b()
		var rb: Dictionary = _cb.connect_ws("ws://127.0.0.1:%d" % _port, "player-b", "Bình")
		_check("client B noi lai cong 18911 (truoc A)", bool(rb.get("ok", false)), str(rb))
		_step = 1
	elif _step == 1:
		if not _cb.is_ws_connected():
			return
		var lr: Dictionary = _cb.request_ws_auction_list()
		_check("B xin auction_list sau khi hello lai", bool(lr.get("ok", false)), str(lr))
		_step = 2
	elif _step == 2:
		if _cb.ws_auctions.is_empty():
			return
		_check("B thay lai phien mo sau restart",
			String((_cb.ws_auctions[0] as Dictionary).get("auction_id", "")) == _auction_id)
		_phase = 4
		_step = 0
		_phase_deadline_ms = now + PHASE_TIMEOUT_MS


# (4) A hello lai sau restart -> nhan auction_outbid dung 1 lan
# tu hang doi da persist; hang doi sach.
func _phase4(now: int) -> void:
	match _step:
		0:
			_new_client_a()
			var ra: Dictionary = _ca.connect_ws("ws://127.0.0.1:%d" % _port, "player-a", "An")
			_check("client A noi lai cong 18911", bool(ra.get("ok", false)), str(ra))
			_step = 1
		1:
			if not _ca.is_ws_connected():
				return
			if _outbid_a < 1:
				return
			_check("A hello lai nhan auction_outbid", _outbid_a == 1, str(_outbid_a))
			_check("A nhan dung auction_id",
				String(_last_outbid_a.get("auction_id", "")) == _auction_id)
			_check("outbid: gia cu 1.000.000 cua A", _last_outbid_a_old_bid == 1000000,
				str(_last_outbid_a_old_bid))
			_check("outbid: old_bidder la player-a", _last_outbid_a_old_bidder == "player-a",
				_last_outbid_a_old_bidder)
			_check("outbid: gia moi 1.001.000 cua B",
				int(_last_outbid_a.get("current_bid", -1)) == 1001000
				and String(_last_outbid_a.get("current_bidder_player_id", "")) == "player-b",
				str(_last_outbid_a))
			_check("A cap nhat phien tu outbid (current_bid 1.001.000)",
				not _ca.ws_auctions.is_empty()
				and int((_ca.ws_auctions[0] as Dictionary).get("current_bid", -1)) == 1001000,
				str(_ca.ws_auctions))
			_check("data outbid_undelivered 0 sau khi A hello",
				int(_server.data().get("outbid_undelivered", -1)) == 0, str(_server.data()))
			_seen_at_ms = now
			_step = 2
		2:
			if now < _seen_at_ms + 1500:
				return
			_check("A chi nhan auction_outbid dung 1 lan (khong gui lap)",
				_outbid_a == 1, str(_outbid_a))
			_phase = 5
			_step = 0
			_phase_deadline_ms = now + PHASE_TIMEOUT_MS


# (5) Online: A dau 1.002.000 khi B dang online -> B nhan outbid
# ngay, hang doi rong; A tu nang gia len 1.003.000 -> khong ai
# nhan outbid.
func _phase5(now: int) -> void:
	match _step:
		0:
			var res: Dictionary = _ca.send_ws_auction_bid(_auction_id, 1002000)
			_check("A dau gia 1.002.000 ok", bool(res.get("ok", false)), str(res))
			_step = 1
		1:
			if int((_ca.ws_auctions[0] as Dictionary).get("current_bid", -1)) != 1002000:
				return
			_check("A dan dau lai 1.002.000",
				String((_ca.ws_auctions[0] as Dictionary).get("current_bidder_player_id", "")) == "player-a")
			if _outbid_b < 1:
				return
			_check("B online nhan outbid ngay", _outbid_b == 1, str(_outbid_b))
			_check("outbid B: gia cu 1.001.000", _last_outbid_b_old_bid == 1001000,
				str(_last_outbid_b_old_bid))
			_check("outbid B: old_bidder la player-b", _last_outbid_b_old_bidder == "player-b",
				_last_outbid_b_old_bidder)
			_check("outbid B: gia moi 1.002.000 cua A",
				int(_last_outbid_b.get("current_bid", -1)) == 1002000
				and String(_last_outbid_b.get("current_bidder_player_id", "")) == "player-a",
				str(_last_outbid_b))
			_check("data outbid_undelivered 0 (online khong xep doi)",
				int(_server.data().get("outbid_undelivered", -1)) == 0, str(_server.data()))
			_seen_at_ms = now
			_step = 2
		2:
			if now < _seen_at_ms + 800:
				return
			var res2: Dictionary = _ca.send_ws_auction_bid(_auction_id, 1003000)
			_check("A tu nang gia len 1.003.000 ok", bool(res2.get("ok", false)), str(res2))
			_step = 3
		3:
			if int((_ca.ws_auctions[0] as Dictionary).get("current_bid", -1)) != 1003000:
				return
			_seen_at_ms = now
			_step = 4
		4:
			if now < _seen_at_ms + 1500:
				return
			_check("tu nang gia: B khong nhan them outbid", _outbid_b == 1, str(_outbid_b))
			_check("tu nang gia: A khong nhan outbid", _outbid_a == 1, str(_outbid_a))
			_check("data outbid_undelivered van 0",
				int(_server.data().get("outbid_undelivered", -1)) == 0, str(_server.data()))
			_phase = 6
			_step = 0
			_phase_deadline_ms = now + PHASE_TIMEOUT_MS


# (6) File cu v101 (khong co khoa outbid_pending) van nap duoc.
func _phase6(now: int) -> void:
	if _step == 0:
		_server.stop_server()
		var st := _read_state_file()
		st.erase("outbid_pending")
		var f := FileAccess.open(STATE_PATH, FileAccess.WRITE)
		f.store_string(JSON.stringify(st))
		f.close()
		var r: Dictionary = _restart_server(18912)
		_check("server restart mo cong 18912 (file cu khong outbid_pending)",
			bool(r.get("ok", false)), str(r))
		_check("file cu: outbid_pending rong", int(_server.data().get("outbid_undelivered", -1)) == 0,
			str(_server.data()))
		_check("file cu: phien van mo", _server.auctions.size() == 1,
			str(_server.auctions.size()))
		_phase = 7
		_step = 0
		_phase_deadline_ms = now + PHASE_TIMEOUT_MS


# (7) Ket thuc.
func _phase7(now: int) -> void:
	_check("hoan tat vong 102", true)
	_finish()
