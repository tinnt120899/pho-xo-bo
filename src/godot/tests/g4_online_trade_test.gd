extends SceneTree
## G4 ONLINE TRADE selftest — chay headless, khong can trinh duyet:
##   godot --headless --path src/godot -s res://tests/g4_online_trade_test.gd
## Kiem tra: trade doi do qua WebSocket giua PxbOnline (G4 buoc 10)
## va PxbServer that qua loopback 127.0.0.1 — de nghi doi do, chap
## nhan (chi nguoi nhan), tu choi, huy, validate o ca client +
## server, huy de nghi khi 1 ben mat ket noi, data()/from_data()
## giu log giao dich da chot, reset_state xoa trade. Socket la that
## (khong stub), server la PxbServer that.
## In "G4 ONLINE TRADE TEST: n/n PASS".

const TEST_PORT := 18769
const PHASE_TIMEOUT_MS := 8000
const GLOBAL_TIMEOUT_MS := 90000

var _pass := 0
var _fail := 0
var _server: PxbServer = null
var _ca: PxbOnline = null
var _cb: PxbOnline = null
var _phase := 0
var _step := 0
var _phase_deadline_ms := 0
var _wait_until_ms := 0
var _started_ms := 0
var _finished := false
var _trade_id := ""
var _offered_a := 0
var _last_offered_a := {}
var _last_declined_id := ""
var _last_cancelled_a_id := ""
var _last_cancelled_a_reason := ""
var _last_cancelled_b_id := ""
var _last_cancelled_b_reason := ""


func _check(test_name: String, cond: bool, detail: String = "") -> void:
	if cond:
		_pass += 1
		print("  PASS ", test_name)
	else:
		_fail += 1
		print("  FAIL ", test_name, " ", detail)


func _on_a_offered(trade: Dictionary) -> void:
	_offered_a += 1
	_last_offered_a = trade


func _on_a_declined(trade_id: String, _reason: String) -> void:
	_last_declined_id = trade_id


func _on_a_cancelled(trade_id: String, reason: String) -> void:
	_last_cancelled_a_id = trade_id
	_last_cancelled_a_reason = reason


func _on_b_cancelled(trade_id: String, reason: String) -> void:
	_last_cancelled_b_id = trade_id
	_last_cancelled_b_reason = reason


func _init() -> void:
	_started_ms = Time.get_ticks_msec()
	_check("const: trade tien toi da 100 ti", PxbOnline.WS_MAX_TRADE_MONEY_VND == 100000000000)
	_check("const: server trade tien toi da 100 ti", PxbServer.MAX_TRADE_MONEY_VND == 100000000000)
	_check("const: trade item id toi da 64", PxbOnline.WS_MAX_ITEM_ID_LEN == 64)
	_check("const: log trade giu 50", PxbOnline.WS_TRADES_MAX == 50)
	_server = PxbServer.new()
	root.add_child(_server)
	var r: Dictionary = _server.start_server(TEST_PORT)
	_check("server mo cong 18769", bool(r.get("ok", false)), str(r))
	_check("server luc dau 0 de nghi cho", int(_server.data().get("trade_pending", -1)) == 0)
	_ca = PxbOnline.new()
	root.add_child(_ca)
	_cb = PxbOnline.new()
	root.add_child(_cb)
	_ca.ws_trade_declined.connect(_on_a_declined)
	_ca.ws_trade_offered_sent.connect(_on_a_offered)
	_ca.ws_trade_cancelled.connect(_on_a_cancelled)
	_cb.ws_trade_cancelled.connect(_on_b_cancelled)
	var ra: Dictionary = _ca.connect_ws("ws://127.0.0.1:%d" % TEST_PORT, "player-a", "An")
	_check("client A connect_ws tao socket", bool(ra.get("ok", false)), str(ra))
	var rb: Dictionary = _cb.connect_ws("ws://127.0.0.1:%d" % TEST_PORT, "player-b", "Bình")
	_check("client B connect_ws tao socket", bool(rb.get("ok", false)), str(rb))
	_check("luc dau A chua co de nghi cho", _ca.ws_trade_offers.is_empty() and _ca.ws_my_offers.is_empty())
	_check("gui trade khi chua noi thi loi", String(_ca.send_ws_trade_offer("player-b", "com-tam", 0, "ca-phe", 0).get("reason", "")) == "chua-ket-noi-ws")
	_phase = 0
	_phase_deadline_ms = _started_ms + PHASE_TIMEOUT_MS


func _process(_delta: float) -> bool:
	if _finished:
		return true
	_server.poll()
	_ca.poll_ws()
	_cb.poll_ws()
	var now := Time.get_ticks_msec()
	if now > _started_ms + GLOBAL_TIMEOUT_MS:
		_check("global timeout 90s (khong treo)", false,
			"phase=%d step=%d" % [_phase, _step])
		_finish()
		return true
	if now > _phase_deadline_ms:
		_check("phase %d xong truoc deadline" % _phase, false,
			"step=%d" % _step)
		_finish()
		return true
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
	return false


func _phase0(now: int) -> void:
	if not (_ca.is_ws_connected() and _cb.is_ws_connected()):
		return
	var res: Dictionary = _ca.send_ws_trade_offer("player-b", "com-tam", 0, "ca-phe", 0)
	_check("A gui de nghi doi do ok", bool(res.get("ok", false)), str(res))
	_phase = 1
	_phase_deadline_ms = now + PHASE_TIMEOUT_MS


func _phase1(now: int) -> void:
	if _cb.ws_trade_offers.is_empty() or _ca.ws_my_offers.is_empty():
		return
	var offer: Dictionary = _cb.ws_trade_offers[0]
	var mine: Dictionary = _ca.ws_my_offers[0]
	_trade_id = String(offer.get("trade_id", ""))
	_check("B nhan de nghi cua A", true)
	_check("de nghi co trade_id", not _trade_id.is_empty())
	_check("de nghi ghi dung nguoi gui", String(offer.get("from_player_id", "")) == "player-a")
	_check("de nghi ghi dung nguoi nhan", String(offer.get("to_player_id", "")) == "player-b")
	_check("de nghi cho com-tam", String(offer.get("give_item_id", "")) == "com-tam")
	_check("de nghi muon ca-phe", String(offer.get("want_item_id", "")) == "ca-phe")
	_check("A thay de nghi da gui cung trade_id", String(mine.get("trade_id", "")) == _trade_id)
	_check("server dem 1 de nghi cho", int(_server.data().get("trade_pending", -1)) == 1)
	# Chap nhan sai id / sai nguoi thi bi chan (client chan truoc khi gui).
	_check("B chap nhan sai id thi loi", String(_cb.send_ws_trade_accept("trade-khong-co").get("reason", "")) == "khong-tim-thay-de-nghi")
	_check("A chap nhan de nghi cua chinh minh thi loi", String(_ca.send_ws_trade_accept(_trade_id).get("reason", "")) == "khong-tim-thay-de-nghi")
	# De nghi thu 2 khi dang co de nghi cho thi bi chan o client.
	_check("A gui de nghi thu 2 thi loi", String(_ca.send_ws_trade_offer("player-b", "ao-mua", 0, "ca-phe", 0).get("reason", "")) == "da-co-de-nghi-cho")
	var res: Dictionary = _cb.send_ws_trade_accept(_trade_id)
	_check("B chap nhan dung id thi ok", bool(res.get("ok", false)), str(res))
	_phase = 2
	_phase_deadline_ms = now + PHASE_TIMEOUT_MS


func _phase2(now: int) -> void:
	if _ca.ws_trades_completed.is_empty() or _cb.ws_trades_completed.is_empty():
		return
	var done_a: Dictionary = _ca.ws_trades_completed[0]
	var done_b: Dictionary = _cb.ws_trades_completed[0]
	_check("A nhan trade_completed", true)
	_check("B nhan trade_completed", true)
	_check("2 ben cung trade_id", String(done_a.get("trade_id", "")) == _trade_id and String(done_b.get("trade_id", "")) == _trade_id)
	_check("trade_completed giu dung dieu khoan", String(done_a.get("give_item_id", "")) == "com-tam" and String(done_a.get("want_item_id", "")) == "ca-phe")
	_check("trade_completed co moc chot", int(done_a.get("completed_at_ms", 0)) > 0)
	_check("server het de nghi cho", int(_server.data().get("trade_pending", -1)) == 0)
	_check("server dem 1 giao dich da chot", int(_server.data().get("trade_completed_count", -1)) == 1)
	_check("A het de nghi da gui", _ca.ws_my_offers.is_empty())
	_check("B het de nghi cho", _cb.ws_trade_offers.is_empty())
	# Vong 2: de nghi tien bu — B tu choi.
	var res: Dictionary = _ca.send_ws_trade_offer("player-b", "", 1000000, "ca-phe", 0)
	_check("A gui de nghi tien bu ok", bool(res.get("ok", false)), str(res))
	_phase = 3
	_phase_deadline_ms = now + PHASE_TIMEOUT_MS


func _phase3(now: int) -> void:
	match _step:
		0:
			if _cb.ws_trade_offers.is_empty():
				return
			_trade_id = String((_cb.ws_trade_offers[0] as Dictionary).get("trade_id", ""))
			_check("B nhan de nghi tien bu", true)
			_check("de nghi tien bu dung 1 trieu", int((_cb.ws_trade_offers[0] as Dictionary).get("give_money", -1)) == 1000000)
			var res: Dictionary = _cb.send_ws_trade_decline(_trade_id)
			_check("B tu choi ok", bool(res.get("ok", false)), str(res))
			_check("B tu xoa de nghi sau khi tu choi", _cb.ws_trade_offers.is_empty())
			_step = 1
		1:
			if _last_declined_id != _trade_id:
				return
			_check("A nhan trade_declined", true)
			_check("server het de nghi cho sau tu choi", int(_server.data().get("trade_pending", -1)) == 0)
			_check("A het de nghi da gui sau tu choi", _ca.ws_my_offers.is_empty())
			# Vong 3: de nghi roi nguoi gui huy.
			var res: Dictionary = _ca.send_ws_trade_offer("player-b", "ao-mua", 0, "ca-phe", 0)
			_check("A gui de nghi vong 3 ok", bool(res.get("ok", false)), str(res))
			_step = 2
		2:
			if _cb.ws_trade_offers.is_empty():
				return
			_trade_id = String((_cb.ws_trade_offers[0] as Dictionary).get("trade_id", ""))
			var res: Dictionary = _ca.send_ws_trade_cancel(_trade_id)
			_check("A huy de nghi ok", bool(res.get("ok", false)), str(res))
			_check("A tu xoa de nghi sau khi huy", _ca.ws_my_offers.is_empty())
			_step = 3
		3:
			if _last_cancelled_b_id != _trade_id:
				return
			_check("B nhan trade_cancelled", true)
			_check("ly do huy la nguoi-gui-da-huy", _last_cancelled_b_reason == "nguoi-gui-da-huy")
			_check("server het de nghi cho sau huy", int(_server.data().get("trade_pending", -1)) == 0)
			_step = 0
			_phase = 4
			_phase_deadline_ms = now + PHASE_TIMEOUT_MS


func _phase4(now: int) -> void:
	match _step:
		0:
			# Validate o client: khong can server — loi ngay.
			_check("doi voi chinh minh thi loi", String(_ca.send_ws_trade_offer("player-a", "com-tam", 0, "ca-phe", 0).get("reason", "")) == "khong-doi-voi-chinh-minh")
			_check("de nghi trong thi loi", String(_ca.send_ws_trade_offer("player-b", "", 0, "", 0).get("reason", "")) == "de-nghi-trong")
			_check("tien am thi loi", String(_ca.send_ws_trade_offer("player-b", "", -1, "ca-phe", 0).get("reason", "")) == "tien-trade-khong-hop-le")
			_check("tien qua 100 ti thi loi", String(_ca.send_ws_trade_offer("player-b", "", 100000000001, "ca-phe", 0).get("reason", "")) == "tien-trade-khong-hop-le")
			var long_item := "x".repeat(65)
			_check("ma mon 65 ky tu thi loi", String(_ca.send_ws_trade_offer("player-b", long_item, 0, "ca-phe", 0).get("reason", "")) == "item-id-qua-dai")
			_check("server khong nhan de nghi loi client", int(_server.data().get("trade_pending", -1)) == 0)
			# Vong 103: de nghi cho nguoi khong online KHONG con bi
			# tu choi "khong-tim-thay-nguoi-choi" nua — server tao
			# trade voi to_peer -1, gui lai trade_offer luc nguoi
			# nhan hello sau. Test cu assert loi cu da doi theo.
			_ca.ws_last_trade_error = ""
			_offered_a = 0
			_last_offered_a = {}
			var res: Dictionary = _ca.send_ws_trade_offer("player-khong-co", "com-tam", 0, "ca-phe", 0)
			_check("gui de nghi cho nguoi khong co van di duoc", bool(res.get("ok", false)), str(res))
			_step = 1
			_wait_until_ms = now + 1500
		1:
			if now < _wait_until_ms and _offered_a == 0:
				return
			_check("A nhan trade_offered dung 1 lan (nguoi nhan offline)", _offered_a == 1, str(_offered_a))
			_check("trade_offered to_peer -1 (nguoi nhan offline)",
				int(_last_offered_a.get("to_peer", 0)) == -1, str(_last_offered_a))
			_check("khong co trade_error nua (vong 103)", _ca.ws_last_trade_error.is_empty(), _ca.ws_last_trade_error)
			_check("server giu 1 de nghi cho (cho nguoi offline)",
				int(_server.data().get("trade_pending", -1)) == 1, str(_server.data()))
			_check("trade_error khong ngat ket noi", _ca.is_ws_connected())
			# Huy de nghi nay de phase 5 gui duoc de nghi moi
			# (moi nguoi gui chi co 1 de nghi cho).
			var tid := String(_last_offered_a.get("trade_id", ""))
			var rc: Dictionary = _ca.send_ws_trade_cancel(tid)
			_check("A huy de nghi cho nguoi offline ok", bool(rc.get("ok", false)), str(rc))
			_step = 2
		2:
			if int(_server.data().get("trade_pending", -1)) != 0 or not _ca.ws_my_offers.is_empty():
				return
			_check("server het de nghi cho sau khi huy", true)
			_check("A het de nghi da gui sau khi huy", true)
			_step = 0
			_phase = 5
			_phase_deadline_ms = now + PHASE_TIMEOUT_MS


func _phase5(now: int) -> void:
	match _step:
		0:
			var res: Dictionary = _ca.send_ws_trade_offer("player-b", "com-tam", 0, "ca-phe", 0)
			_check("A gui de nghi vong 4 ok", bool(res.get("ok", false)), str(res))
			_step = 1
		1:
			if _cb.ws_trade_offers.is_empty():
				return
			_trade_id = String((_cb.ws_trade_offers[0] as Dictionary).get("trade_id", ""))
			_cb.disconnect_ws()
			_step = 2
		2:
			if _last_cancelled_a_id != _trade_id:
				return
			_check("A nhan trade_cancelled khi B mat ket noi", true)
			_check("ly do huy la doi-phuong-mat-ket-noi", _last_cancelled_a_reason == "doi-phuong-mat-ket-noi")
			_check("server het de nghi cho sau khi B roi", int(_server.data().get("trade_pending", -1)) == 0)
			_check("server dem 1 nguoi choi (chi A)", _server.player_count() == 1)
			_check("A het de nghi da gui sau khi B roi", _ca.ws_my_offers.is_empty())
			_step = 0
			_phase = 6
			_phase_deadline_ms = now + PHASE_TIMEOUT_MS


func _phase6(now: int) -> void:
	match _step:
		0:
			# data()/from_data(): giu log giao dich da chot.
			var d := _ca.data()
			_check("data giu log trade da chot", (d.get("ws_trades_completed", []) as Array).size() == 1)
			var d2 := PxbOnline.new()
			d2.from_data(d)
			_check("from_data khoi phuc log trade", d2.ws_trades_completed.size() == 1)
			_check("from_data khoi phuc dung trade_id", String((d2.ws_trades_completed[0] as Dictionary).get("trade_id", "")) == String((_ca.ws_trades_completed[0] as Dictionary).get("trade_id", "")))
			# Du lieu ban: thieu trade_id / tien qua 100 ti -> bo.
			var d3 := PxbOnline.new()
			d3.from_data({
				"ws_trades_completed": [
					{"trade_id": "trade-ok", "from_player_id": "a", "to_player_id": "b",
						"give_item_id": "com-tam", "give_money": 0,
						"want_item_id": "ca-phe", "want_money": 0},
					{"from_player_id": "a", "to_player_id": "b",
						"give_item_id": "com-tam", "give_money": 0,
						"want_item_id": "ca-phe", "want_money": 0},
					{"trade_id": "trade-xau", "from_player_id": "a", "to_player_id": "b",
						"give_item_id": "com-tam", "give_money": 100000000001,
						"want_item_id": "ca-phe", "want_money": 0},
				],
			})
			_check("from_data chi giu trade hop le", d3.ws_trades_completed.size() == 1)
			d2.free()
			d3.free()
			_step = 1
			_wait_until_ms = now + 200
		1:
			if now < _wait_until_ms:
				return
			_ca.reset_state()
			_check("reset_state ngat WS", not _ca.is_ws_connected())
			_check("reset_state xoa log trade", _ca.ws_trades_completed.is_empty())
			_check("reset_state xoa loi trade", _ca.ws_last_trade_error.is_empty())
			_step = 2
			_wait_until_ms = now + 800
		2:
			_check("server chi con 0 nguoi (A reset)", _server.player_count() == 0)
			_finish()


func _finish() -> void:
	if _finished:
		return
	_finished = true
	print("G4 ONLINE TRADE TEST: %d/%d PASS" % [_pass, _pass + _fail])
	_server.stop_server()
	quit(0 if _fail == 0 else 1)
