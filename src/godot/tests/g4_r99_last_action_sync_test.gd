extends SceneTree
## G4 R99 LAST ACTION SYNC TEST — chay headless, khong can trinh duyet:
##   godot --headless --path src/godot -s res://tests/g4_r99_last_action_sync_test.gd
## Kiem tra: BattleScene.refresh_last_action() (Vong 99) — Main neo lai
## hold theo ngay server SAU khi scene da chup _last_action =
## result_text() voi cua so local (gameDay 4 -> giu den ngay 11),
## nen panel duoi (doc _last_action) lech panel giua (doc
## result_text() truc tiep, da neo ve ngay 8). refresh_last_action()
## phai dong bo lai _last_action cho khop hold da neo.
## In "G4 R99 LAST ACTION SYNC TEST: n/n PASS".

var _pass := 0
var _fail := 0
var _scenes: Array = []
var _mbs: Array = []


func _check(test_name: String, cond: bool, detail: String = "") -> void:
	if cond:
		_pass += 1
		print("  PASS ", test_name)
	else:
		_fail += 1
		print("  FAIL ", test_name, " ", detail)


func _init() -> void:
	var scene := _test_end_battle_day4()
	_test_reanchor_and_refresh(scene)
	_test_refresh_without_reanchor()
	_test_empty_scene()
	print("G4 R99 LAST ACTION SYNC TEST: %d/%d PASS" % [_pass, _pass + _fail])
	for s in _scenes:
		s.free()
	for m in _mbs:
		m.free()
	quit(0 if _fail == 0 else 1)


func _new_mb() -> PxbMarketBattle:
	var mb := PxbMarketBattle.new()
	_mbs.append(mb)
	return mb


func _mk_team_a() -> Dictionary:
	return {"id": "doi-ban", "name": "Đội Bạn", "fighters": [
		PxbMarketBattle.create_fighter("ban-1", "Bạn", "Do", "Chao",
			{"the": 80, "tri": 40, "tam": 50}, []),
		PxbMarketBattle.create_fighter("ban-2", "Bạn Thân", "Xanh", "CaKho",
			{"the": 40, "tri": 80, "tam": 50}, []),
		PxbMarketBattle.create_fighter("ban-3", "Cô Tư", "Vang", "Loa",
			{"the": 40, "tri": 50, "tam": 80}, []),
	]}


func _new_scene(mb: PxbMarketBattle, game_day: int) -> BattleScene:
	var res: Dictionary = mb.create_battle({
		"teamA": _mk_team_a(),
		"teamB": PxbMarketBattle.seed_npc_team("doi-cho", "Đội Chợ Đầu Mối", 3),
		"stallId": "sap-cho-dau-moi", "gameDay": game_day, "defenderTeam": "B",
	})
	_check("tao tran gameDay %d: ok" % game_day, bool(res.get("ok", false)),
		"reason=%s" % str(res.get("reason", "")))
	var scene := BattleScene.new()
	if bool(res.get("ok", false)):
		scene.setup(mb, res["battle"], load("res://DejaVuSans.ttf"), load("res://DejaVuSans-Bold.ttf"))
	_scenes.append(scene)
	return scene


## Giet het doi B roi goi _check_end nhu Main/test cu.
func _kill_team_b(scene: BattleScene) -> void:
	for f in ((scene.battle.get("teamB", {}) as Dictionary).get("fighters", []) as Array):
		(f as Dictionary)["hp"] = 0
		(f as Dictionary)["alive"] = false


func _test_end_battle_day4() -> BattleScene:
	var mb := _new_mb()
	var scene := _new_scene(mb, 4)
	_kill_team_b(scene)
	mb._check_end(scene.battle)
	var st := scene.battle_status()
	_check("het tran: over=true", st.get("over") == true)
	_check("het tran: winner=A (doi-ban)", str(st.get("winner", "")) == "A",
		"winner=%s" % str(st.get("winner", "")))
	var hold: Dictionary = scene.battle.get("hold", {})
	_check("hold local: den ngay game 11 (4+7)", int(hold.get("untilGameDay", -1)) == 11,
		"until=%s" % str(hold.get("untilGameDay", "")))
	_check("last_action chup ngay 11",
		str(st.get("last_action", "")).contains("ngày game 11"),
		"last_action=%s" % str(st.get("last_action", "")))
	_check("result_text ngay 11",
		scene.result_text().contains("ngày game 11"),
		"result=%s" % scene.result_text())
	return scene


func _test_reanchor_and_refresh(scene: BattleScene) -> void:
	# Mo phong Main neo hold theo ngay server = 1 (Vong 95):
	# cua so [4,11) -> [1,8).
	scene.battle["hold"] = PxbMarketBattle.reanchor_hold_window(scene.battle["hold"], 1)
	var hold: Dictionary = scene.battle.get("hold", {})
	_check("neo: startGameDay=1", int(hold.get("startGameDay", -1)) == 1,
		"start=%s" % str(hold.get("startGameDay", "")))
	_check("neo: untilGameDay=8 (1+7)", int(hold.get("untilGameDay", -1)) == 8,
		"until=%s" % str(hold.get("untilGameDay", "")))
	# TRUOC refresh: tai hien bug r98 — panel duoi lech panel giua.
	var before := scene.battle_status()
	_check("truoc refresh: last_action VAN ngay 11 (bug r98)",
		str(before.get("last_action", "")).contains("ngày game 11"),
		"last_action=%s" % str(before.get("last_action", "")))
	_check("truoc refresh: result_text DA ngay 8",
		scene.result_text().contains("ngày game 8"),
		"result=%s" % scene.result_text())
	_check("truoc refresh: result_text KHONG con ngay 11",
		not scene.result_text().contains("ngày game 11"),
		"result=%s" % scene.result_text())
	# SAU refresh: dong bo.
	scene.refresh_last_action()
	var after := scene.battle_status()
	_check("sau refresh: last_action ngay 8",
		str(after.get("last_action", "")).contains("ngày game 8"),
		"last_action=%s" % str(after.get("last_action", "")))
	_check("sau refresh: last_action KHONG con ngay 11",
		not str(after.get("last_action", "")).contains("ngày game 11"),
		"last_action=%s" % str(after.get("last_action", "")))
	_check("sau refresh: last_action == result_text()",
		str(after.get("last_action", "")) == scene.result_text(),
		"last=%s | result=%s" % [str(after.get("last_action", "")), scene.result_text()])
	_check("sau refresh: bridge result_text == last_action",
		str(after.get("result_text", "")) == str(after.get("last_action", "")))


func _test_refresh_without_reanchor() -> void:
	var mb := _new_mb()
	var scene := _new_scene(mb, 4)
	_kill_team_b(scene)
	mb._check_end(scene.battle)
	var before := str(scene.battle_status().get("last_action", ""))
	_check("chua neo: last_action ngay 11", before.contains("ngày game 11"),
		"last_action=%s" % before)
	scene.refresh_last_action()
	var after := str(scene.battle_status().get("last_action", ""))
	_check("chua neo: refresh khong doi noi dung", after == before,
		"truoc=%s | sau=%s" % [before, after])


func _test_empty_scene() -> void:
	var scene := BattleScene.new()
	_scenes.append(scene)
	scene.refresh_last_action()
	_check("rong: refresh khong crash", true)
	_check("rong: result_text() rong", scene.result_text() == "")
	_check("rong: last_action rong",
		str(scene.battle_status().get("last_action", "")) == "")
