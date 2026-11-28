extends SceneTree
## G4 R101 AUCTION CLOSED OFFLINE TEST — chay headless, khong can trinh duyet:
##   godot --headless --path src/godot -s res://tests/g4_r101_auction_pending_test.gd
## Kiem tra vong 101 (G4 §122 — auction_closed phai toi tay nguoi
## ban / nguoi thang du ho offline luc phien dong):
## (a) cleaners _clean_auction_pending (giu du, loc sai, cap 10);
## (b) B thang phien khi A (nguoi ban) offline -> B nhan closed ngay
## va ap dung; server xep closed vao hang doi _auction_pending cho
## A (khong chi broadcast cho nguoi online), A hello lai nhan dung
## 1 lan, ap dung dung vai nguoi ban, khong trung;
## (c) hang doi persist qua restart (stop + restart -> state file
## giu auction_pending, A hello lai van nhan duoc);
## (d) phien khong ai dau gia dong luc nguoi ban offline -> chi
## xep cho nguoi ban, hello lai nhan 1 lan, khong ap (khong co
## nguoi thang), giu nguyen mon + tien;
## (e) file cu v100 (khong co khoa auction_pending) van nap duoc.
## In "G4 R101 AUCTION CLOSED OFFLINE TEST: n/n PASS".

const TEST_PORT := 18900
const STATE_PATH := "/tmp/pxb-r101-state.json"
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
var _ca: PxbOnline = null
var _cb: PxbOnline = null
var _inv_a: PxbInventory = null
var _inv_b: PxbInventory = null
var _eco_a: PxbEconomy = null
var _eco_b: PxbEconomy = null
var _auction_id_1 := ""
var _auction_id_2 := ""
var _closed_a := 0
var _last_closed_a := {}
var _closed_b := 0
var _last_closed_b := {}
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
	if _ca != null and is_instance_valid(_ca):
		_ca.queue_free()
	if _cb != null and is_instance_valid(_cb):
		_cb.queue_free()
	if _server != null and is_instance_valid(_server):
		if _server.running:
			_server.stop_server()
		_server.queue_free()
	print("G4 R101 AUCTION CLOSED OFFLINE TEST: %d/%d PASS" % [_pass, _pass + _fail])
	quit(0 if _fail == 0 else 1)


func _on_a_closed(auction: Dictionary) -> void:
	_closed_a += 1
	_last_closed_a = auction


func _on_b_closed(auction: Dictionary) -> void:
	_closed_b += 1
	_last_closed_b = auction


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


# A: com-tam x1 + ao-mua x1, vi 0. B: vi 2 trieu, tui trong.
func _new_client_a() -> void:
	if _ca != null:
		_ca.free()
		_ca = null
	_closed_a = 0
	_last_closed_a = {}
	_inv_a = PxbInventory.new()
	_eco_a = PxbEconomy.new()
	_inv_a.add("com-tam", 1)
	_inv_a.add("ao-mua", 1)
	_ca = PxbOnline.new()
	root.add_child(_ca)
	_ca.trade_inventory = _inv_a
	_ca.trade_economy = _eco_a
	_ca.ws_auction_closed.connect(_on_a_closed)


func _new_client_b() -> void:
	if _cb != null:
		_cb.free()
		_cb = null
	_closed_b = 0
	_last_closed_b = {}
	_inv_b = PxbInventory.new()
	_eco_b = PxbEconomy.new()
	_eco_b.money = 2000000
	_cb = PxbOnline.new()
	root.add_child(_cb)
	_cb.trade_inventory = _inv_b
	_cb.trade_economy = _eco_b
	_cb.ws_auction_closed.connect(_on_b_closed)


func _good_pending_msg() -> Dictionary:
	return {"type": "auction_closed", "auction_id": "auc-9",
		"seller_player_id": "player-a", "item_id": "com-tam",
		"start_price": 1000000, "current_bid": 1000000,
		"current_bidder_player_id": "player-b",
		"created_at_ms": 1000, "ends_at_ms": 2000,
		"winner_player_id": "player-b", "hammer_price": 1000000,
		"fee_vnd": 50000, "seller_receives_vnd": 950000,
		"closed_at_ms": 3000}


func _init() -> void:
	_started_ms = Time.get_ticks_msec()
	_delete_state_file()
	# --- Unit thuan (khong can mang): cleaner _clean_auction_pending.
	var probe := PxbServer.new()
	probe.state_file_path = STATE_PATH
	var good := [_good_pending_msg()]
	var cleaned := probe._clean_auction_pending(good)
	_check("clean auction pending hop le giu du 1", cleaned.size() == 1, str(cleaned))
	var bad := _good_pending_msg()
	bad["type"] = "auction_created"
	_check("clean auction pending type la -> bo", probe._clean_auction_pending([bad]).is_empty())
	bad = _good_pending_msg()
	bad["auction_id"] = ""
	_check("clean auction pending thieu auction_id -> bo", probe._clean_auction_pending([bad]).is_empty())
	bad = _good_pending_msg()
	bad["seller_player_id"] = ""
	_check("clean auction pending thieu seller -> bo", probe._clean_auction_pending([bad]).is_empty())
	_check("clean auction pending khong phai Array -> []",
		probe._clean_auction_pending({}).is_empty())
	var many: Array = []
	for i in range(12):
		var m := _good_pending_msg()
		m["auction_id"] = "auc-%d" % i
		many.append(m)
	_check("clean auction pending cap 10 / nguoi", probe._clean_auction_pending(many).size() == 10,
		str(probe._clean_auction_pending(many).size()))
	_check("clean auction pending giu dung thu tu (moi nhat cuoi)",
		String((probe._clean_auction_pending(many)[9] as Dictionary).get("auction_id", "")) == "auc-9")
	probe.free()
	# --- Mo server that.
	_server = PxbServer.new()
	_server.state_file_path = STATE_PATH
	root.add_child(_server)
	var r: Dictionary = _server.start_server(TEST_PORT)
	_check("server mo cong 18900", bool(r.get("ok", false)), str(r))
	_phase_deadline_ms = Time.get_ticks_msec() + PHASE_TIMEOUT_MS
	process_frame.connect(_on_frame)


func _on_frame() -> void:
	if _finished:
		return
	_frame += 1
	if _server != null:
		_server.poll()
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


# (0) Noi A + B.
func _phase0(now: int) -> void:
	match _step:
		0:
			_new_client_a()
			var ra: Dictionary = _ca.connect_ws("ws://127.0.0.1:%d" % _port, "player-a", "An")
			_check("client A noi cong 18900", bool(ra.get("ok", false)), str(ra))
			_new_client_b()
			var rb: Dictionary = _cb.connect_ws("ws://127.0.0.1:%d" % _port, "player-b", "Bình")
			_check("client B noi cong 18900", bool(rb.get("ok", false)), str(rb))
			_step = 1
		1:
			if not _ca.is_ws_connected() or not _cb.is_ws_connected():
				return
			_check("A + B deu da noi WS", true)
			_phase = 1
			_step = 0
			_phase_deadline_ms = now + PHASE_TIMEOUT_MS


# (1) A mo phien com-tam 1 trieu / 30s; B dau gia 1 trieu.
func _phase1(now: int) -> void:
	match _step:
		0:
			var res: Dictionary = _ca.send_ws_auction_create("com-tam", 1000000, 30)
			_check("A mo phien com-tam 1.000.000 / 30s ok", bool(res.get("ok", false)), str(res))
			_step = 1
		1:
			if _ca.ws_auctions.is_empty() or _cb.ws_auctions.is_empty():
				return
			_auction_id_1 = String((_ca.ws_auctions[0] as Dictionary).get("auction_id", ""))
			_check("phien com-tam mo, chua ai dau gia", int((_ca.ws_auctions[0] as Dictionary).get("current_bid", -1)) == 0)
			var res: Dictionary = _cb.send_ws_auction_bid(_auction_id_1, 1000000)
			_check("B dau gia 1.000.000 ok", bool(res.get("ok", false)), str(res))
			_step = 2
		2:
			if int((_cb.ws_auctions[0] as Dictionary).get("current_bid", -1)) != 1000000:
				return
			_check("B la nguoi dan dau 1.000.000",
				String((_cb.ws_auctions[0] as Dictionary).get("current_bidder_player_id", "")) == "player-b")
			_check("server giu 1 phien mo", _server.auctions.size() == 1)
			_check("data auction_undelivered 0 truoc khi dong",
				int(_server.data().get("auction_undelivered", -1)) == 0, str(_server.data()))
			_phase = 2
			_step = 0
			_phase_deadline_ms = now + PHASE_TIMEOUT_MS


# (2) Stop + restart 18901 (phien con trong file); A van offline;
# B hello truoc; doi han ve qua khu -> phien dong: B (online)
# nhan closed ngay + ap dung; A (offline) duoc xep hang doi.
func _phase2(now: int) -> void:
	match _step:
		0:
			_server.stop_server()
			var st := _read_state_file()
			_check("state file co phien #1 sau stop", (st.get("auctions", {}) as Dictionary).has(_auction_id_1),
				str((st.get("auctions", {}) as Dictionary).keys()))
			if _ca != null:
				_ca.free()
				_ca = null
			if _cb != null:
				_cb.free()
				_cb = null
			var r: Dictionary = _restart_server(18901)
			_check("server restart mo cong 18901", bool(r.get("ok", false)), str(r))
			_new_client_b()
			var rb: Dictionary = _cb.connect_ws("ws://127.0.0.1:%d" % _port, "player-b", "Bình")
			_check("client B noi lai cong 18901 (truoc A)", bool(rb.get("ok", false)), str(rb))
			_step = 1
		1:
			if not _cb.is_ws_connected():
				return
			# Phien dang mo KHONG gui lai luc hello — client tu xin
			# auction_list (thiet ke vong 83, giu nguyen o vong 101).
			var lr: Dictionary = _cb.request_ws_auction_list()
			_check("B xin auction_list sau khi hello lai", bool(lr.get("ok", false)), str(lr))
			_step = 2
		2:
			if _cb.ws_auctions.is_empty():
				return
			var stored: Dictionary = _server.auctions[_auction_id_1]
			stored["ends_at_ms"] = PxbServer._now_ms() - 1000
			_step = 3
		3:
			if _closed_b < 1:
				return
			_check("B nhan auction_closed #1 (online)", _closed_b == 1, str(_closed_b))
			_check("B nhan dung auction_id #1",
				String(_last_closed_b.get("auction_id", "")) == _auction_id_1)
			_check("B thang phien #1",
				String(_last_closed_b.get("winner_player_id", "")) == "player-b")
			_check("B ap closed: tra 1.000.000, vi con 1.000.000", _eco_b.money == 1000000,
				str(_eco_b.money))
			_check("B ap closed: nhan com-tam x1", _inv_b.count("com-tam") == 1)
			_check("server het phien mo sau khi dong", _server.auctions.is_empty())
			_check("server dem 1 phien da dong", int(_server.data().get("auction_closed_count", -1)) == 1,
				str(_server.data()))
			_check("data auction_undelivered 1 (no cho A)",
				int(_server.data().get("auction_undelivered", -1)) == 1, str(_server.data()))
			# White-box o step 2 da doi ends_at_ms ve qua khu de
			# kich hoat dong phien — tra lai gia tri hop le
			# (created + 30s) cho muc log truoc khi stop server;
			# neu khong cleaner luc nap file se bo muc log vi
			# ends <= created (dinh dang log yeu cau ends > created
			# — trong that ends = created + duration nen luon dung).
			var logged: Dictionary = _server.auction_log[_server.auction_log.size() - 1]
			logged["ends_at_ms"] = int(logged.get("created_at_ms", 0)) + 30000
			_seen_at_ms = now
			_step = 4
		4:
			# Cho them 1,5s: neu server gui lap thi B se nhan them.
			if now < _seen_at_ms + 1500:
				return
			_check("B chi nhan auction_closed #1 dung 1 lan (khong gui lap)",
				_closed_b == 1, str(_closed_b))
			_phase = 3
			_step = 0
			_phase_deadline_ms = now + PHASE_TIMEOUT_MS


# (3) Stop + restart 18902 — hang doi phai persist trong file.
func _phase3(now: int) -> void:
	if _step == 0:
		_server.stop_server()
		var st := _read_state_file()
		var pend: Dictionary = st.get("auction_pending", {})
		_check("state file giu auction_pending sau stop", pend.has("player-a"), str(pend.keys()))
		var arr: Array = pend.get("player-a", [])
		_check("auction_pending player-a 1 thong bao", arr.size() == 1, str(arr))
		if arr.size() == 1:
			_check("thong bao cho la auction_closed #1",
				String((arr[0] as Dictionary).get("type", "")) == "auction_closed"
				and String((arr[0] as Dictionary).get("auction_id", "")) == _auction_id_1,
				str(arr[0]))
		if _cb != null:
			_cb.free()
			_cb = null
		var r: Dictionary = _restart_server(18902)
		_check("server restart mo cong 18902", bool(r.get("ok", false)), str(r))
		_check("restart: auction_pending van 1 nguoi no",
			int(_server.data().get("auction_undelivered", -1)) == 1, str(_server.data()))
		_check("restart: auction_log van 1 phien da dong", _server.auction_log.size() == 1,
			str(_server.auction_log.size()))
		_phase = 4
		_step = 0
		_phase_deadline_ms = now + PHASE_TIMEOUT_MS


# (4) A hello lai sau restart -> nhan auction_closed #1 dung 1 lan
# tu hang doi da persist; ap dung vai nguoi ban; hang doi sach.
func _phase4(now: int) -> void:
	match _step:
		0:
			_new_client_a()
			var ra: Dictionary = _ca.connect_ws("ws://127.0.0.1:%d" % _port, "player-a", "An")
			_check("client A noi lai cong 18902", bool(ra.get("ok", false)), str(ra))
			_step = 1
		1:
			if not _ca.is_ws_connected():
				return
			if _closed_a < 1:
				return
			_check("A hello lai nhan auction_closed #1", _closed_a == 1, str(_closed_a))
			_check("A nhan dung auction_id #1",
				String(_last_closed_a.get("auction_id", "")) == _auction_id_1)
			_check("A ap closed vai nguoi ban: com-tam ve 0", _inv_a.count("com-tam") == 0,
				str(_inv_a.count("com-tam")))
			_check("A ap closed vai nguoi ban: nhan 950.000 (tru phi 5%)", _eco_a.money == 950000,
				str(_eco_a.money))
			_check("A van giu ao-mua x1", _inv_a.count("ao-mua") == 1)
			_check("data auction_undelivered 0 sau khi A hello",
				int(_server.data().get("auction_undelivered", -1)) == 0, str(_server.data()))
			_seen_at_ms = now
			_step = 2
		2:
			if now < _seen_at_ms + 1500:
				return
			_check("A chi nhan auction_closed #1 dung 1 lan (khong gui lap)",
				_closed_a == 1, str(_closed_a))
			_phase = 5
			_step = 0
			_phase_deadline_ms = now + PHASE_TIMEOUT_MS


# (5) Phien khong ai dau gia: A mo phien ao-mua; stop + restart
# 18903 (ca A + B offline); doi han ve qua khu -> phien dong:
# chi xep hang doi cho A (nguoi ban); A hello lai nhan 1 lan,
# khong ap (khong co nguoi thang), giu nguyen mon + tien.
func _phase5(now: int) -> void:
	match _step:
		0:
			# B van offline tu phase 3 (da free) — noi B lai
			# truoc de A mo phien khong bi loi (khong can B).
			var res: Dictionary = _ca.send_ws_auction_create("ao-mua", 500000, 30)
			_check("A mo phien ao-mua 500.000 / 30s ok", bool(res.get("ok", false)), str(res))
			_step = 1
		1:
			if _ca.ws_auctions.is_empty():
				return
			_auction_id_2 = String((_ca.ws_auctions[0] as Dictionary).get("auction_id", ""))
			_check("phien ao-mua mo", not _auction_id_2.is_empty() and _auction_id_2 != _auction_id_1,
				_auction_id_2)
			_server.stop_server()
			if _ca != null:
				_ca.free()
				_ca = null
			var r: Dictionary = _restart_server(18903)
			_check("server restart mo cong 18903 (khong ai noi)", bool(r.get("ok", false)), str(r))
			var stored: Dictionary = _server.auctions[_auction_id_2]
			stored["ends_at_ms"] = PxbServer._now_ms() - 1000
			_step = 2
		2:
			# Cho poll dong phien (khong co client nao de dem).
			if not _server.auctions.is_empty():
				return
			_check("phien #2 da dong khi khong ai online", true)
			_check("server dem 2 phien da dong", int(_server.data().get("auction_closed_count", -1)) == 2,
				str(_server.data()))
			_check("data auction_undelivered 1 (chi no cho A)",
				int(_server.data().get("auction_undelivered", -1)) == 1, str(_server.data()))
			# Tra lai ends_at_ms hop le cho muc log #2 (ly do nhu
			# phase 2 — white-box da doi ve qua khu).
			var logged2: Dictionary = _server.auction_log[_server.auction_log.size() - 1]
			logged2["ends_at_ms"] = int(logged2.get("created_at_ms", 0)) + 30000
			_seen_at_ms = now
			_step = 3
		3:
			if now < _seen_at_ms + 1000:
				return
			_new_client_a()
			# Client A moi tao lai tu dau (tui/vi tuoi) — dat lai
			# dung trang thai sau phase 4 (da ban com-tam o phien
			# #1, nhan 950.000) de kiem tra phien #2 khong nguoi
			# thang khong doi tien/mon.
			_inv_a.remove("com-tam", 1)
			_eco_a.money = 950000
			var ra: Dictionary = _ca.connect_ws("ws://127.0.0.1:%d" % _port, "player-a", "An")
			_check("client A noi lai cong 18903", bool(ra.get("ok", false)), str(ra))
			_step = 4
		4:
			if not _ca.is_ws_connected():
				return
			if _closed_a < 1:
				return
			_check("A hello lai nhan auction_closed #2", _closed_a == 1, str(_closed_a))
			_check("A nhan dung auction_id #2",
				String(_last_closed_a.get("auction_id", "")) == _auction_id_2)
			_check("phien #2 khong co nguoi thang",
				String(_last_closed_a.get("winner_player_id", "x")).is_empty())
			var apply_a: Dictionary = {}
			if not _ca.ws_auction_log.is_empty():
				apply_a = (_ca.ws_auction_log[_ca.ws_auction_log.size() - 1] as Dictionary).get("apply", {})
			_check("phien khong nguoi thang thi khong ap",
				not bool(apply_a.get("applied", true))
				and String(apply_a.get("reason", "")) == "khong-co-nguoi-thang", str(apply_a))
			_check("A van giu ao-mua x1 (khong ban duoc)", _inv_a.count("ao-mua") == 1)
			_check("A khong nhan them tien", _eco_a.money == 950000, str(_eco_a.money))
			_check("data auction_undelivered 0 sau khi A hello (#2)",
				int(_server.data().get("auction_undelivered", -1)) == 0, str(_server.data()))
			_seen_at_ms = now
			_step = 5
		5:
			if now < _seen_at_ms + 1500:
				return
			_check("A chi nhan auction_closed #2 dung 1 lan (khong gui lap)",
				_closed_a == 1, str(_closed_a))
			_phase = 6
			_step = 0
			_phase_deadline_ms = now + PHASE_TIMEOUT_MS


# (6) File cu v100 (khong co khoa auction_pending) van nap duoc.
func _phase6(now: int) -> void:
	if _step == 0:
		_server.stop_server()
		var st := _read_state_file()
		st.erase("auction_pending")
		var f := FileAccess.open(STATE_PATH, FileAccess.WRITE)
		f.store_string(JSON.stringify(st))
		f.close()
		var r: Dictionary = _restart_server(18904)
		_check("server restart mo cong 18904 (file cu khong auction_pending)",
			bool(r.get("ok", false)), str(r))
		_check("file cu: auction_pending rong", int(_server.data().get("auction_undelivered", -1)) == 0,
			str(_server.data()))
		_check("file cu: auction_log van 2 phien", _server.auction_log.size() == 2,
			str(_server.auction_log.size()))
		_phase = 7
		_step = 0
		_phase_deadline_ms = now + PHASE_TIMEOUT_MS


# (7) Ket thuc.
func _phase7(now: int) -> void:
	_check("hoan tat vong 101", true)
	_finish()
