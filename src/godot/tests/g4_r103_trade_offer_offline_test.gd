extends SceneTree
## G4 R103 TRADE OFFER OFFLINE TEST — chay headless, khong can trinh duyet:
##   godot --headless --path src/godot -s res://tests/g4_r103_trade_offer_offline_test.gd
## Kiem tra vong 103 (G4 §124 — de nghi trade phai toi tay nguoi
## nhan du ho offline luc gui):
## (a) _clean_trade giu to_peer (-1 / so duong / thieu -> -1);
## (b) B offline (chua tung hello): A gui de nghi -> A nhan
## trade_offered dung 1 lan, to_peer -1, khong trade_error;
## server tao trade (to_peer -1), data trade_pending 1;
## (c) B hello lai -> nhan trade_offer dung 1 lan, dung trade_id /
## cho / muon; khong trung;
## (d) hang doi trade persist qua restart (stop + restart -> state
## file giu trades, A + B hello lai nhan lai offered/offer dung
## 1 lan; B chap nhan -> ca 2 nhan trade_completed, so cai tru
## 50.000 cua A);
## (e) online van nhu cu: A gui cho B dang online -> B nhan offer
## ngay, offered cua A co to_peer > 0;
## (f) B ngat -> server tu huy de nghi dang mo + bao A (hanh vi
## cu); A gui lai cho B offline roi huy truoc khi B hello ->
## server xep trade_cancelled vao hang doi (vong 100); B hello
## lai nhan trade_cancelled dung 1 lan, KHONG nhan trade_offer nua.
## In "G4 R103 TRADE OFFER OFFLINE TEST: n/n PASS".

const TEST_PORT := 18913
const STATE_PATH := "/tmp/pxb-r103-state.json"
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
var _trade_id := ""
var _offered_a := 0
var _last_offered_a := {}
var _error_a := 0
var _last_error_a := ""
var _offer_b := 0
var _last_offer_b := {}
var _completed_a := 0
var _completed_b := 0
var _cancelled_a := 0
var _cancelled_b := 0
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
	print("G4 R103 TRADE OFFER OFFLINE TEST: %d/%d PASS" % [_pass, _pass + _fail])
	quit(0 if _fail == 0 else 1)


func _on_a_offered(trade: Dictionary) -> void:
	_offered_a += 1
	_last_offered_a = trade


func _on_a_error(reason: String) -> void:
	_error_a += 1
	_last_error_a = reason


func _on_b_offer(offer: Dictionary) -> void:
	_offer_b += 1
	_last_offer_b = offer


func _on_a_completed(_trade: Dictionary) -> void:
	_completed_a += 1


func _on_b_completed(_trade: Dictionary) -> void:
	_completed_b += 1


func _on_b_cancelled(_trade_id: String, _reason: String) -> void:
	_cancelled_b += 1


func _on_a_cancelled(_trade_id: String, _reason: String) -> void:
	_cancelled_a += 1


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


# A: nguoi gui — vi 100.000, tui trong.
func _new_client_a() -> void:
	if _ca != null:
		_ca.free()
		_ca = null
	_offered_a = 0
	_last_offered_a = {}
	_error_a = 0
	_last_error_a = ""
	_completed_a = 0
	_cancelled_a = 0
	_inv_a = PxbInventory.new()
	_eco_a = PxbEconomy.new()
	_eco_a.money = 100000
	_ca = PxbOnline.new()
	root.add_child(_ca)
	_ca.trade_inventory = _inv_a
	_ca.trade_economy = _eco_a
	_ca.ws_trade_offered_sent.connect(_on_a_offered)
	_ca.ws_trade_error.connect(_on_a_error)
	_ca.ws_trade_completed.connect(_on_a_completed)
	_ca.ws_trade_cancelled.connect(_on_a_cancelled)


# B: nguoi nhan — vi 0, tui co com-tam x1 (de chap nhan de nghi
# doi com-tam lay 50.000 o phase 3: client kiem tra ben nhan du
# do muon truoc khi gui accept).
func _new_client_b() -> void:
	if _cb != null:
		_cb.free()
		_cb = null
	_offer_b = 0
	_last_offer_b = {}
	_completed_b = 0
	_cancelled_b = 0
	_inv_b = PxbInventory.new()
	_inv_b.add("com-tam", 1)
	_eco_b = PxbEconomy.new()
	_cb = PxbOnline.new()
	root.add_child(_cb)
	_cb.trade_inventory = _inv_b
	_cb.trade_economy = _eco_b
	_cb.ws_trade_offer_received.connect(_on_b_offer)
	_cb.ws_trade_completed.connect(_on_b_completed)
	_cb.ws_trade_cancelled.connect(_on_b_cancelled)


func _init() -> void:
	_started_ms = Time.get_ticks_msec()
	_delete_state_file()
	# --- Unit thuan (khong can mang): _clean_trade giu to_peer.
	var m_off := {"trade_id": "trade-1", "from_player_id": "player-a",
		"to_player_id": "player-b", "give_item_id": "", "give_money": 50000,
		"want_item_id": "com-tam", "want_money": 0, "created_at_ms": 1000,
		"to_peer": -1}
	var c_off := PxbOnline._clean_trade(m_off)
	_check("clean trade giu to_peer -1 (nguoi nhan offline)",
		int(c_off.get("to_peer", 0)) == -1, str(c_off))
	var m_on := m_off.duplicate()
	m_on["to_peer"] = 7
	var c_on := PxbOnline._clean_trade(m_on)
	_check("clean trade giu to_peer duong (nguoi nhan online)",
		int(c_on.get("to_peer", -1)) == 7, str(c_on))
	var m_no := m_off.duplicate()
	m_no.erase("to_peer")
	var c_no := PxbOnline._clean_trade(m_no)
	_check("clean trade thieu to_peer -> -1",
		int(c_no.get("to_peer", 0)) == -1, str(c_no))
	# --- Mo server that.
	_server = PxbServer.new()
	_server.state_file_path = STATE_PATH
	root.add_child(_server)
	var r: Dictionary = _server.start_server(TEST_PORT)
	_check("server mo cong 18913", bool(r.get("ok", false)), str(r))
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


# (0) Chi noi A; A dong bo so cai (vi 100.000) de server validate
# tien cho. B chua tung hello — dang offline.
func _phase0(now: int) -> void:
	match _step:
		0:
			_new_client_a()
			var ra: Dictionary = _ca.connect_ws("ws://127.0.0.1:%d" % _port, "player-a", "An")
			_check("client A noi cong 18913", bool(ra.get("ok", false)), str(ra))
			_step = 1
		1:
			if not _ca.is_ws_connected():
				return
			_check("A da noi WS", true)
			var sa: Dictionary = _ca.send_ws_ledger_sync()
			_check("A dong bo so cai", bool(sa.get("ok", false)), str(sa))
			_step = 2
		2:
			if not _server.ledger.has("player-a"):
				return
			_check("server co ledger A 100.000",
				int((_server.ledger.get("player-a", {}) as Dictionary).get("money", -1)) == 100000,
				str(_server.ledger.get("player-a", {})))
			_check("server chua biet player-b (offline)",
				_server._find_peer_by_player_id("player-b") == -1)
			_phase = 1
			_step = 0
			_phase_deadline_ms = now + PHASE_TIMEOUT_MS


# (1) A gui de nghi cho B dang offline: phai tao duoc trade, A
# nhan trade_offered to_peer -1, khong trade_error.
func _phase1(now: int) -> void:
	match _step:
		0:
			var res: Dictionary = _ca.send_ws_trade_offer("player-b", "", 50000, "com-tam", 0)
			_check("A gui de nghi cho B offline ok (client)", bool(res.get("ok", false)), str(res))
			_step = 1
		1:
			if _offered_a == 0 and _error_a == 0:
				return
			_check("A nhan trade_offered dung 1 lan", _offered_a == 1, str(_offered_a))
			_check("A khong nhan trade_error", _error_a == 0, _last_error_a)
			if _offered_a == 1:
				_trade_id = String(_last_offered_a.get("trade_id", ""))
				_check("trade_offered co trade_id", not _trade_id.is_empty(), str(_last_offered_a))
				_check("trade_offered to_peer -1 (B offline)",
					int(_last_offered_a.get("to_peer", 0)) == -1, str(_last_offered_a))
				_check("trade_offered dung nguoi nhan / cho / muon",
					String(_last_offered_a.get("to_player_id", "")) == "player-b"
					and int(_last_offered_a.get("give_money", -1)) == 50000
					and String(_last_offered_a.get("want_item_id", "")) == "com-tam",
					str(_last_offered_a))
			_check("server giu 1 trade dang mo", _server.trades.size() == 1,
				str(_server.trades.size()))
			if _server.trades.has(_trade_id):
				var tr: Dictionary = _server.trades[_trade_id]
				_check("trade tren server to_peer -1",
					int(tr.get("to_peer", 0)) == -1, str(tr))
			_check("data trade_pending 1",
				int(_server.data().get("trade_pending", -1)) == 1, str(_server.data()))
			_check("B chua nhan offer nao (chua hello)", _offer_b == 0)
			_phase = 2
			_step = 0
			_phase_deadline_ms = now + PHASE_TIMEOUT_MS


# (2) B hello lai -> nhan trade_offer dung 1 lan, khong trung.
func _phase2(now: int) -> void:
	match _step:
		0:
			_new_client_b()
			var rb: Dictionary = _cb.connect_ws("ws://127.0.0.1:%d" % _port, "player-b", "Bình")
			_check("client B noi cong 18913", bool(rb.get("ok", false)), str(rb))
			_step = 1
		1:
			if not _cb.is_ws_connected():
				return
			if _offer_b == 0:
				return
			_check("B nhan trade_offer dung 1 lan", _offer_b == 1, str(_offer_b))
			_check("B nhan dung trade_id",
				String(_last_offer_b.get("trade_id", "")) == _trade_id, str(_last_offer_b))
			_check("B nhan dung nguoi gui / cho / muon",
				String(_last_offer_b.get("from_player_id", "")) == "player-a"
				and int(_last_offer_b.get("give_money", -1)) == 50000
				and String(_last_offer_b.get("want_item_id", "")) == "com-tam",
				str(_last_offer_b))
			_check("B co 1 offer trong ws_trade_offers", _cb.ws_trade_offers.size() == 1,
				str(_cb.ws_trade_offers.size()))
			_seen_at_ms = now
			_step = 2
		2:
			if now - _seen_at_ms < 500:
				return
			_check("B khong nhan trung offer sau 500ms", _offer_b == 1, str(_offer_b))
			_phase = 3
			_step = 0
			_phase_deadline_ms = now + PHASE_TIMEOUT_MS


# (3) Stop + restart 18914 — trade phai persist trong file; A + B
# hello lai nhan lai offered/offer; B chap nhan -> ca 2 completed.
func _phase3(now: int) -> void:
	match _step:
		0:
			_server.stop_server()
			var st := _read_state_file()
			var trs: Dictionary = st.get("trades", {})
			_check("state file giu trades sau stop", trs.has(_trade_id), str(trs.keys()))
			if trs.has(_trade_id):
				var trf: Dictionary = trs[_trade_id]
				# Luc stop, B da hello o phase 2 nen to_peer trong
				# file la peer that cua B (rebind da gan); chi
				# kiem dung noi dung de nghi, khong doi -1 o day
				# (ve -1 la viec cua _clean_trade_entry luc nap).
				_check("trade trong file dung cho / muon",
					int(trf.get("give_money", -1)) == 50000
					and String(trf.get("want_item_id", "")) == "com-tam",
					str(trf))
			if _cb != null:
				_cb.free()
				_cb = null
			if _ca != null:
				_ca.free()
				_ca = null
			var r: Dictionary = _restart_server(18914)
			_check("server restart mo cong 18914", bool(r.get("ok", false)), str(r))
			_check("restart: server van giu 1 trade", _server.trades.size() == 1,
				str(_server.trades.size()))
			if _server.trades.has(_trade_id):
				var trl: Dictionary = _server.trades[_trade_id]
				_check("restart: trade nap tu file ve to_peer -1",
					int(trl.get("to_peer", 0)) == -1, str(trl))
			_new_client_a()
			var ra: Dictionary = _ca.connect_ws("ws://127.0.0.1:%d" % _port, "player-a", "An")
			_check("client A noi lai cong 18914", bool(ra.get("ok", false)), str(ra))
			_new_client_b()
			var rb: Dictionary = _cb.connect_ws("ws://127.0.0.1:%d" % _port, "player-b", "Bình")
			_check("client B noi lai cong 18914", bool(rb.get("ok", false)), str(rb))
			_step = 1
		1:
			if not _ca.is_ws_connected() or not _cb.is_ws_connected():
				return
			if _offered_a == 0 or _offer_b == 0:
				return
			_check("A hello lai nhan trade_offered dung 1 lan", _offered_a == 1, str(_offered_a))
			_check("B hello lai nhan trade_offer dung 1 lan", _offer_b == 1, str(_offer_b))
			_check("B hello lai nhan dung trade_id",
				String(_last_offer_b.get("trade_id", "")) == _trade_id, str(_last_offer_b))
			_seen_at_ms = now
			_step = 2
		2:
			if now - _seen_at_ms < 500:
				return
			_check("A + B khong nhan trung sau 500ms", _offered_a == 1 and _offer_b == 1,
				"offered=%d offer=%d" % [_offered_a, _offer_b])
			var res: Dictionary = _cb.send_ws_trade_accept(_trade_id)
			_check("B chap nhan de nghi ok", bool(res.get("ok", false)), str(res))
			_step = 3
		3:
			if _completed_a == 0 or _completed_b == 0:
				return
			_check("A nhan trade_completed dung 1 lan", _completed_a == 1, str(_completed_a))
			_check("B nhan trade_completed dung 1 lan", _completed_b == 1, str(_completed_b))
			_check("server het trade dang mo", _server.trades.is_empty())
			_check("server ghi 1 trade_log", _server.trade_log.size() == 1,
				str(_server.trade_log.size()))
			_check("server tru 50.000 cua A (100.000 -> 50.000)",
				int((_server.ledger.get("player-a", {}) as Dictionary).get("money", -1)) == 50000,
				str(_server.ledger.get("player-a", {})))
			_check("client A ap vi con 50.000", _eco_a.money == 50000, str(_eco_a.money))
			_phase = 4
			_step = 0
			_phase_deadline_ms = now + PHASE_TIMEOUT_MS


# (4) Online van nhu cu: A gui cho B dang online -> B nhan offer
# ngay, offered cua A co to_peer > 0.
func _phase4(now: int) -> void:
	match _step:
		0:
			_offered_a = 0
			_offer_b = 0
			var res: Dictionary = _ca.send_ws_trade_offer("player-b", "", 10000, "", 20000)
			_check("A gui de nghi moi cho B online ok", bool(res.get("ok", false)), str(res))
			_step = 1
		1:
			if _offered_a == 0 or _offer_b == 0:
				return
			_check("A nhan trade_offered dung 1 lan", _offered_a == 1, str(_offered_a))
			_check("trade_offered moi to_peer > 0 (B online)",
				int(_last_offered_a.get("to_peer", -1)) > 0, str(_last_offered_a))
			_trade_id = String(_last_offered_a.get("trade_id", ""))
			_check("B nhan trade_offer dung 1 lan (online)", _offer_b == 1, str(_offer_b))
			_check("B nhan dung trade_id moi",
				String(_last_offer_b.get("trade_id", "")) == _trade_id, str(_last_offer_b))
			_phase = 5
			_step = 0
			_phase_deadline_ms = now + PHASE_TIMEOUT_MS


# (5) B offline -> server TU HUY de nghi dang mo (hanh vi cu
# _cancel_trades_for_peer) + bao A; A gui lai de nghi cho B
# offline roi huy truoc khi B hello -> trade_cancelled xep hang
# doi (vong 100); B hello lai nhan cancelled dung 1 lan, KHONG
# nhan trade_offer nua.
func _phase5(now: int) -> void:
	match _step:
		0:
			# B ngat: server tu huy de nghi phase 4 + bao A.
			_offered_a = 0
			_cancelled_a = 0
			_offer_b = 0
			if _cb != null:
				_cb.free()
				_cb = null
			_step = 1
		1:
			# Doi server nhan ra B da mat ket noi — huy de nghi
			# cua B chi dung sau khi peer B khoi presence.
			if _server._find_peer_by_player_id("player-b") != -1:
				return
			_check("server da xoa B khoi presence", true)
			if _cancelled_a == 0:
				return
			_check("A nhan trade_cancelled khi B ngat (tu huy)",
				_cancelled_a == 1, str(_cancelled_a))
			_check("server het trade dang mo sau khi B ngat", _server.trades.is_empty())
			# A gui lai de nghi moi cho B dang offline.
			_offered_a = 0
			var res: Dictionary = _ca.send_ws_trade_offer("player-b", "", 10000, "", 20000)
			_check("A gui lai de nghi cho B offline ok", bool(res.get("ok", false)), str(res))
			_step = 2
		2:
			if _offered_a == 0:
				return
			_check("A nhan trade_offered moi dung 1 lan", _offered_a == 1, str(_offered_a))
			_check("trade_offered moi to_peer -1 (B offline)",
				int(_last_offered_a.get("to_peer", 0)) == -1, str(_last_offered_a))
			_trade_id = String(_last_offered_a.get("trade_id", ""))
			var res: Dictionary = _ca.send_ws_trade_cancel(_trade_id)
			_check("A huy de nghi luc B offline ok", bool(res.get("ok", false)), str(res))
			_step = 3
		3:
			_check("server het trade dang mo sau khi huy", _server.trades.is_empty())
			_check("data trade_undelivered 1 (no cancelled cho B)",
				int(_server.data().get("trade_undelivered", -1)) == 1, str(_server.data()))
			_check("hang doi _trade_pending co player-b",
				_server._trade_pending.has("player-b"), str(_server._trade_pending.keys()))
			_new_client_b()
			var rb: Dictionary = _cb.connect_ws("ws://127.0.0.1:%d" % _port, "player-b", "Bình")
			_check("client B noi lai cong 18914", bool(rb.get("ok", false)), str(rb))
			_step = 4
		4:
			if not _cb.is_ws_connected():
				return
			if _cancelled_b == 0:
				return
			_check("B nhan trade_cancelled dung 1 lan", _cancelled_b == 1, str(_cancelled_b))
			_check("B khong nhan trade_offer (de nghi da huy)", _offer_b == 0, str(_offer_b))
			_check("B khong con offer nao", _cb.ws_trade_offers.is_empty())
			_seen_at_ms = now
			_step = 5
		5:
			if now - _seen_at_ms < 500:
				return
			_check("B khong nhan trung cancelled sau 500ms", _cancelled_b == 1,
				str(_cancelled_b))
			_check("data trade_undelivered 0 sau khi giao",
				int(_server.data().get("trade_undelivered", -1)) == 0, str(_server.data()))
			_finish()
