extends SceneTree
## G4 R100 TRADE COMPLETED REBIND TEST — chay headless, khong can trinh duyet:
##   godot --headless --path src/godot -s res://tests/g4_r100_trade_completed_rebind_test.gd
## Kiem tra vong 100 (G4 §121 — trade_completed phai toi tay nguoi
## gui du nguoi gui chua hello lai khi nguoi nhan accept):
## (a) cleaners _clean_trade_pending (giui du, loc sai, cap 10);
## (b) B accept khi A offline (chua hello lai sau restart) -> server
## xep trade_completed vao hang doi _trade_pending (khong gui vao
## peer -1), A hello lai nhan dung 1 lan, khong trung;
## (c) hang doi persist qua restart (stop + restart -> state file
## giu trade_pending, A hello lai van nhan duoc);
## (d) duong decline tuong tu: B tu choi khi A offline -> A hello
## lai nhan trade_declined dung 1 lan.
## In "G4 R100 TRADE COMPLETED REBIND TEST: n/n PASS".

const TEST_PORT := 18800
const STATE_PATH := "/tmp/pxb-r100-state.json"
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
var _trade_id_1 := ""
var _trade_id_2 := ""
var _trade_id_3 := ""
var _offer_b := 0
var _last_offer_b := {}
var _offered_a := 0
var _last_offered_a := {}
var _completed_a := 0
var _last_completed_a := {}
var _completed_b := 0
var _last_completed_b := {}
var _declined_a := 0
var _last_declined_a := {}
var _trade_err_a := 0
var _trade_err_b := 0
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
	print("G4 R100 TRADE COMPLETED REBIND TEST: %d/%d PASS" % [_pass, _pass + _fail])
	quit(0 if _fail == 0 else 1)


func _on_a_offered(trade: Dictionary) -> void:
	_offered_a += 1
	_last_offered_a = trade


func _on_a_completed(trade: Dictionary) -> void:
	_completed_a += 1
	_last_completed_a = trade


func _on_a_declined(trade_id: String, reason: String) -> void:
	_declined_a += 1
	_last_declined_a = {"trade_id": trade_id, "reason": reason}


func _on_a_trade_error(_reason: String) -> void:
	_trade_err_a += 1


func _on_b_offer(offer: Dictionary) -> void:
	_offer_b += 1
	_last_offer_b = offer


func _on_b_completed(trade: Dictionary) -> void:
	_completed_b += 1
	_last_completed_b = trade


func _on_b_trade_error(_reason: String) -> void:
	_trade_err_b += 1


func _send_raw(c: PxbOnline, payload: Dictionary) -> bool:
	if c == null or c.ws_peer == null:
		return false
	return c.ws_peer.put_packet(JSON.stringify(payload).to_utf8_buffer()) == OK


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


# Client KHONG noi tui/vi (trade_inventory/trade_economy de null)
# de welcome khong gui ledger_sync tao entry gia — chi dem goi
# trade_completed/declined nhan duoc, khong ap vao tui/vi.
func _new_client_a() -> void:
	if _ca != null:
		_ca.free()
		_ca = null
	_offered_a = 0
	_last_offered_a = {}
	_completed_a = 0
	_last_completed_a = {}
	_declined_a = 0
	_last_declined_a = {}
	_trade_err_a = 0
	_ca = PxbOnline.new()
	root.add_child(_ca)
	_ca.ws_ledger_auto_sync = false
	_ca.ws_trade_offered_sent.connect(_on_a_offered)
	_ca.ws_trade_completed.connect(_on_a_completed)
	_ca.ws_trade_declined.connect(_on_a_declined)
	_ca.ws_trade_error.connect(_on_a_trade_error)


func _new_client_b() -> void:
	if _cb != null:
		_cb.free()
		_cb = null
	_offer_b = 0
	_last_offer_b = {}
	_completed_b = 0
	_last_completed_b = {}
	_trade_err_b = 0
	_cb = PxbOnline.new()
	root.add_child(_cb)
	_cb.ws_ledger_auto_sync = false
	_cb.ws_trade_offer_received.connect(_on_b_offer)
	_cb.ws_trade_completed.connect(_on_b_completed)
	_cb.ws_trade_error.connect(_on_b_trade_error)


func _good_pending_msg() -> Dictionary:
	return {"type": "trade_completed", "trade_id": "trade-9",
		"from_player_id": "player-a", "to_player_id": "player-b",
		"give_item_id": "", "give_money": 50000,
		"want_item_id": "com-tam", "want_money": 0,
		"created_at_ms": 1000, "completed_at_ms": 2000}


func _init() -> void:
	_started_ms = Time.get_ticks_msec()
	_delete_state_file()
	# --- Unit thuan (khong can mang): cleaner _clean_trade_pending.
	var probe := PxbServer.new()
	probe.state_file_path = STATE_PATH
	var good := [_good_pending_msg(),
		{"type": "trade_declined", "trade_id": "trade-8", "reason": "nguoi-nhan-tu-choi"},
		{"type": "trade_cancelled", "trade_id": "trade-7", "reason": "nguoi-gui-da-huy"}]
	var cleaned := probe._clean_trade_pending(good)
	_check("clean pending hop le giu du 3", cleaned.size() == 3, str(cleaned))
	var bad := _good_pending_msg()
	bad["type"] = "chat"
	_check("clean pending type la -> bo", probe._clean_trade_pending([bad]).is_empty())
	bad = _good_pending_msg()
	bad["trade_id"] = ""
	_check("clean pending thieu trade_id -> bo", probe._clean_trade_pending([bad]).is_empty())
	bad = _good_pending_msg()
	bad["from_player_id"] = ""
	_check("clean pending completed thieu from -> bo",
		probe._clean_trade_pending([bad]).is_empty())
	bad = {"type": "trade_declined", "trade_id": "", "reason": "x"}
	_check("clean pending declined thieu id -> bo",
		probe._clean_trade_pending([bad]).is_empty())
	_check("clean pending khong phai Array -> []",
		probe._clean_trade_pending({}).is_empty())
	var many: Array = []
	for i in range(12):
		var m := _good_pending_msg()
		m["trade_id"] = "trade-%d" % i
		many.append(m)
	_check("clean pending cap 10 / nguoi", probe._clean_trade_pending(many).size() == 10,
		str(probe._clean_trade_pending(many).size()))
	_check("clean pending giu dung thu tu (moi nhat cuoi)",
		String((probe._clean_trade_pending(many)[9] as Dictionary).get("trade_id", "")) == "trade-9")
	probe.free()
	# --- Mo server that.
	_server = PxbServer.new()
	_server.state_file_path = STATE_PATH
	root.add_child(_server)
	var r: Dictionary = _server.start_server(TEST_PORT)
	_check("server mo cong 18800", bool(r.get("ok", false)), str(r))
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
		8:
			_phase8(now)
		9:
			_phase9(now)


# (0) Noi A + B.
func _phase0(now: int) -> void:
	match _step:
		0:
			_new_client_a()
			var ra: Dictionary = _ca.connect_ws("ws://127.0.0.1:%d" % _port, "player-a", "An")
			_check("client A noi cong 18800", bool(ra.get("ok", false)), str(ra))
			_new_client_b()
			var rb: Dictionary = _cb.connect_ws("ws://127.0.0.1:%d" % _port, "player-b", "Bình")
			_check("client B noi cong 18800", bool(rb.get("ok", false)), str(rb))
			_step = 1
		1:
			if not _ca.is_ws_connected() or not _cb.is_ws_connected():
				return
			_check("A + B deu da noi WS", true)
			_phase = 1
			_step = 0
			_phase_deadline_ms = now + PHASE_TIMEOUT_MS


# (1) A gui de nghi #1 cho B; doi B nhan offer.
func _phase1(now: int) -> void:
	match _step:
		0:
			var res: Dictionary = _ca.send_ws_trade_offer("player-b", "", 50000, "com-tam", 0)
			_check("A gui trade_offer #1 cho B -> ok", bool(res.get("ok", false)), str(res))
			_step = 1
		1:
			if _offer_b < 1 or _offered_a < 1:
				return
			_trade_id_1 = String(_last_offer_b.get("trade_id", ""))
			_check("B nhan trade_offer #1 dung 1 lan", _offer_b == 1, str(_offer_b))
			_check("A nhan trade_offered #1 dung 1 lan", _offered_a == 1, str(_offered_a))
			_check("trade_id #1 khop 2 ben",
				not _trade_id_1.is_empty() and _trade_id_1 == String(_last_offered_a.get("trade_id", "")),
				_trade_id_1)
			_check("server giu 1 trade dang cho", _server.trades.size() == 1)
			_check("data trade_undelivered 0 truoc accept",
				int(_server.data().get("trade_undelivered", -1)) == 0, str(_server.data()))
			_phase = 2
			_step = 0
			_phase_deadline_ms = now + PHASE_TIMEOUT_MS


# (2) Stop + restart 18801 (trade #1 con trong file); B hello
# TRUOC, A van offline; B nhan lai trade_offer.
func _phase2(now: int) -> void:
	if _step == 0:
		_server.stop_server()
		var st := _read_state_file()
		_check("state file co trade #1 sau stop", (st.get("trades", {}) as Dictionary).has(_trade_id_1),
			str((st.get("trades", {}) as Dictionary).keys()))
		if _ca != null:
			_ca.free()
			_ca = null
		if _cb != null:
			_cb.free()
			_cb = null
		var r: Dictionary = _restart_server(18801)
		_check("server restart mo cong 18801", bool(r.get("ok", false)), str(r))
		var tr: Dictionary = _server.trades.get(_trade_id_1, {})
		_check("restart: trade #1 from_peer -1", int(tr.get("from_peer", 0)) == -1, str(tr))
		_check("restart: trade #1 to_peer -1", int(tr.get("to_peer", 0)) == -1, str(tr))
		_new_client_b()
		var rb: Dictionary = _cb.connect_ws("ws://127.0.0.1:%d" % _port, "player-b", "Bình")
		_check("client B noi lai cong 18801 (truoc A)", bool(rb.get("ok", false)), str(rb))
		_step = 1
	elif _step == 1:
		if not _cb.is_ws_connected():
			return
		if _offer_b < 1:
			return
		_check("B hello lai nhan trade_offer #1 dung 1 lan", _offer_b == 1, str(_offer_b))
		_check("B hello lai trade_offer dung trade_id",
			String(_last_offer_b.get("trade_id", "")) == _trade_id_1)
		_phase = 3
		_step = 0
		_phase_deadline_ms = now + PHASE_TIMEOUT_MS


# (3) B accept #1 khi A van offline -> B nhan completed ngay;
# server xep completed vao hang doi cho A (khong gui vao -1).
func _phase3(now: int) -> void:
	match _step:
		0:
			_check("B accept trade #1 raw -> ok",
				_send_raw(_cb, {"type": "trade_accept", "trade_id": _trade_id_1}))
			_step = 1
		1:
			if _completed_b < 1:
				return
			_check("B nhan trade_completed #1", _completed_b == 1, str(_completed_b))
			_check("trade_completed #1 dung trade_id",
				String(_last_completed_b.get("trade_id", "")) == _trade_id_1)
			_check("server trades rong sau accept", _server.trades.is_empty())
			_check("server trade_log 1 muc", _server.trade_log.size() == 1,
				str(_server.trade_log.size()))
			_check("data trade_undelivered 1 (no cho A)",
				int(_server.data().get("trade_undelivered", -1)) == 1, str(_server.data()))
			_check("khong co trade_error khi accept luc A offline",
				_trade_err_b == 0, str(_trade_err_b))
			_seen_at_ms = now
			_step = 2
		2:
			# Cho them 1,5s: neu server gui lap thi B se nhan them.
			if now < _seen_at_ms + 1500:
				return
			_check("B chi nhan trade_completed #1 dung 1 lan (khong gui lap)",
				_completed_b == 1, str(_completed_b))
			_phase = 4
			_step = 0
			_phase_deadline_ms = now + PHASE_TIMEOUT_MS


# (4) A hello lai -> nhan trade_completed #1 dung 1 lan tu hang
# doi; hang doi sach; khong co ban sao thu 2 sau 1,5s.
func _phase4(now: int) -> void:
	match _step:
		0:
			_new_client_a()
			var ra: Dictionary = _ca.connect_ws("ws://127.0.0.1:%d" % _port, "player-a", "An")
			_check("client A noi lai cong 18801", bool(ra.get("ok", false)), str(ra))
			_step = 1
		1:
			if not _ca.is_ws_connected():
				return
			if _completed_a < 1:
				return
			_check("A hello lai nhan trade_completed #1", _completed_a == 1, str(_completed_a))
			_check("A nhan dung trade_id #1",
				String(_last_completed_a.get("trade_id", "")) == _trade_id_1)
			_check("data trade_undelivered 0 sau khi A hello",
				int(_server.data().get("trade_undelivered", -1)) == 0, str(_server.data()))
			_seen_at_ms = now
			_step = 2
		2:
			if now < _seen_at_ms + 1500:
				return
			_check("A chi nhan trade_completed #1 dung 1 lan (khong gui lap)",
				_completed_a == 1, str(_completed_a))
			_check("khong co trade_error ben A", _trade_err_a == 0, str(_trade_err_a))
			_phase = 5
			_step = 0
			_phase_deadline_ms = now + PHASE_TIMEOUT_MS


# (5) Trade #2: A gui lai; stop + restart 18802; B hello truoc
# + accept khi A offline; stop + restart 18803 (hang doi phai
# persist trong file) — kiem tra file giua 2 lan restart.
func _phase5(now: int) -> void:
	match _step:
		0:
			_offer_b = 0
			_offered_a = 0
			var res: Dictionary = _ca.send_ws_trade_offer("player-b", "", 30000, "ca-phe", 0)
			_check("A gui trade_offer #2 cho B -> ok", bool(res.get("ok", false)), str(res))
			_step = 1
		1:
			if _offer_b < 1:
				return
			_trade_id_2 = String(_last_offer_b.get("trade_id", ""))
			_check("B nhan trade_offer #2", not _trade_id_2.is_empty()
				and _trade_id_2 != _trade_id_1, _trade_id_2)
			_server.stop_server()
			var st := _read_state_file()
			_check("state file co trade #2 sau stop",
				(st.get("trades", {}) as Dictionary).has(_trade_id_2))
			if _ca != null:
				_ca.free()
				_ca = null
			if _cb != null:
				_cb.free()
				_cb = null
			var r: Dictionary = _restart_server(18802)
			_check("server restart mo cong 18802", bool(r.get("ok", false)), str(r))
			_new_client_b()
			var rb: Dictionary = _cb.connect_ws("ws://127.0.0.1:%d" % _port, "player-b", "Bình")
			_check("client B noi lai cong 18802 (truoc A)", bool(rb.get("ok", false)), str(rb))
			_step = 2
		2:
			if not _cb.is_ws_connected():
				return
			if _offer_b < 1:
				return
			_check("B hello lai nhan trade_offer #2 dung 1 lan", _offer_b == 1, str(_offer_b))
			_check("B accept trade #2 raw -> ok",
				_send_raw(_cb, {"type": "trade_accept", "trade_id": _trade_id_2}))
			_step = 3
		3:
			if _completed_b < 1:
				return
			_check("B nhan trade_completed #2", _completed_b == 1, str(_completed_b))
			_check("data trade_undelivered 1 (no cho A, truoc restart 2)",
				int(_server.data().get("trade_undelivered", -1)) == 1, str(_server.data()))
			_server.stop_server()
			var st2 := _read_state_file()
			var pend: Dictionary = st2.get("trade_pending", {})
			_check("state file giu trade_pending sau stop", pend.has("player-a"), str(pend.keys()))
			var arr: Array = pend.get("player-a", [])
			_check("trade_pending player-a 1 thong bao", arr.size() == 1, str(arr))
			if arr.size() == 1:
				_check("thong bao cho la trade_completed #2",
					String((arr[0] as Dictionary).get("type", "")) == "trade_completed"
					and String((arr[0] as Dictionary).get("trade_id", "")) == _trade_id_2,
					str(arr[0]))
			if _cb != null:
				_cb.free()
				_cb = null
			var r2: Dictionary = _restart_server(18803)
			_check("server restart mo cong 18803", bool(r2.get("ok", false)), str(r2))
			_check("restart 2: trade_pending van 1 nguoi no",
				int(_server.data().get("trade_undelivered", -1)) == 1, str(_server.data()))
			_phase = 6
			_step = 0
			_phase_deadline_ms = now + PHASE_TIMEOUT_MS


# (6) A hello lai sau restart thu 2 -> nhan trade_completed #2
# dung 1 lan tu hang doi da persist; hang doi sach.
func _phase6(now: int) -> void:
	match _step:
		0:
			_new_client_a()
			var ra: Dictionary = _ca.connect_ws("ws://127.0.0.1:%d" % _port, "player-a", "An")
			_check("client A noi lai cong 18803", bool(ra.get("ok", false)), str(ra))
			_step = 1
		1:
			if not _ca.is_ws_connected():
				return
			if _completed_a < 1:
				return
			_check("A nhan trade_completed #2 sau restart thu 2",
				_completed_a == 1, str(_completed_a))
			_check("A nhan dung trade_id #2",
				String(_last_completed_a.get("trade_id", "")) == _trade_id_2)
			_check("data trade_undelivered 0 sau khi A hello (lan 2)",
				int(_server.data().get("trade_undelivered", -1)) == 0, str(_server.data()))
			_seen_at_ms = now
			_step = 2
		2:
			if now < _seen_at_ms + 1500:
				return
			_check("A chi nhan trade_completed #2 dung 1 lan (khong gui lap)",
				_completed_a == 1, str(_completed_a))
			_phase = 7
			_step = 0
			_phase_deadline_ms = now + PHASE_TIMEOUT_MS


# (7) Trade #3: B phai online TRUOC khi A gui (server tu choi
# offer cho nguoi offline); B hello truoc sau restart 18804;
# B TU CHOI khi A offline -> A hello lai nhan trade_declined 1 lan.
func _phase7(now: int) -> void:
	match _step:
		0:
			# B van offline tu phase 5 (da free) — noi B lai
			# tren cong hien tai 18803 truoc khi A gui #3.
			_new_client_b()
			var rb0: Dictionary = _cb.connect_ws("ws://127.0.0.1:%d" % _port, "player-b", "Bình")
			_check("client B noi lai cong 18803 (truoc khi A gui #3)",
				bool(rb0.get("ok", false)), str(rb0))
			_step = 1
		1:
			if not _cb.is_ws_connected() or not _ca.is_ws_connected():
				return
			_offer_b = 0
			_offered_a = 0
			var res: Dictionary = _ca.send_ws_trade_offer("player-b", "", 10000, "", 20000)
			_check("A gui trade_offer #3 cho B -> ok", bool(res.get("ok", false)), str(res))
			_step = 2
		2:
			if _offer_b < 1:
				return
			_trade_id_3 = String(_last_offer_b.get("trade_id", ""))
			_check("B nhan trade_offer #3", not _trade_id_3.is_empty()
				and _trade_id_3 != _trade_id_2, _trade_id_3)
			_server.stop_server()
			if _ca != null:
				_ca.free()
				_ca = null
			if _cb != null:
				_cb.free()
				_cb = null
			var r: Dictionary = _restart_server(18804)
			_check("server restart mo cong 18804", bool(r.get("ok", false)), str(r))
			_new_client_b()
			var rb: Dictionary = _cb.connect_ws("ws://127.0.0.1:%d" % _port, "player-b", "Bình")
			_check("client B noi lai cong 18804 (truoc A)", bool(rb.get("ok", false)), str(rb))
			_step = 3
		3:
			if not _cb.is_ws_connected():
				return
			if _offer_b < 1:
				return
			_check("B hello lai nhan trade_offer #3 dung 1 lan", _offer_b == 1, str(_offer_b))
			_check("B decline trade #3 raw -> ok",
				_send_raw(_cb, {"type": "trade_decline", "trade_id": _trade_id_3}))
			_step = 4
		4:
			# Decline khong co ack rieng cho B — kiem truc tiep
			# server: trade da xoa + hang doi co 1 declined cho A.
			if not _server.trades.is_empty():
				return
			_check("server trades rong sau decline", true)
			_check("data trade_undelivered 1 (declined no cho A)",
				int(_server.data().get("trade_undelivered", -1)) == 1, str(_server.data()))
			_seen_at_ms = now
			_step = 5
		5:
			if now < _seen_at_ms + 1000:
				return
			_new_client_a()
			var ra: Dictionary = _ca.connect_ws("ws://127.0.0.1:%d" % _port, "player-a", "An")
			_check("client A noi lai cong 18804", bool(ra.get("ok", false)), str(ra))
			_step = 6
		6:
			if not _ca.is_ws_connected():
				return
			if _declined_a < 1:
				return
			_check("A hello lai nhan trade_declined #3", _declined_a == 1, str(_declined_a))
			_check("A nhan dung trade_id #3",
				String(_last_declined_a.get("trade_id", "")) == _trade_id_3)
			_check("ly do declined nguoi-nhan-tu-choi",
				String(_last_declined_a.get("reason", "")) == "nguoi-nhan-tu-choi",
				str(_last_declined_a))
			_check("data trade_undelivered 0 sau khi A hello (decline)",
				int(_server.data().get("trade_undelivered", -1)) == 0, str(_server.data()))
			_seen_at_ms = now
			_step = 7
		7:
			if now < _seen_at_ms + 1500:
				return
			_check("A chi nhan trade_declined #3 dung 1 lan (khong gui lap)",
				_declined_a == 1, str(_declined_a))
			_phase = 8
			_step = 0
			_phase_deadline_ms = now + PHASE_TIMEOUT_MS


# (8) File cu v99 (khong co khoa trade_pending) van nap duoc.
func _phase8(now: int) -> void:
	if _step == 0:
		_server.stop_server()
		var st := _read_state_file()
		st.erase("trade_pending")
		var f := FileAccess.open(STATE_PATH, FileAccess.WRITE)
		f.store_string(JSON.stringify(st))
		f.close()
		var r: Dictionary = _restart_server(18805)
		_check("server restart mo cong 18805 (file cu khong trade_pending)",
			bool(r.get("ok", false)), str(r))
		_check("file cu: trade_pending rong", int(_server.data().get("trade_undelivered", -1)) == 0,
			str(_server.data()))
		_check("file cu: trade_log van 2 muc", _server.trade_log.size() == 2,
			str(_server.trade_log.size()))
		_phase = 9
		_step = 0
		_phase_deadline_ms = now + PHASE_TIMEOUT_MS


# (9) Ket thuc.
func _phase9(now: int) -> void:
	_check("hoan tat vong 100", true)
	_finish()
