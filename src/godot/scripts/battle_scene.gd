class_name BattleScene
extends Node2D
## Scene trận Bụi Đời Chợ Cá (Godot G4 §4 — code lớn tiếp theo sau G3).
## Vẽ lưới 12×9 isometric + đấu sĩ + HUD trận, nối thẳng logic lõi
## PxbMarketBattle (luật ĐÃ CHỐT 20/11 06:06 — không sửa luật ở đây).
##
## Cách chơi (chuột/chạm): chạm đấu sĩ của mình để xem; chạm ô xanh
## lá để di chuyển (tối đa tầm di chuyển, 1 lần/lượt); chạm địch
## trong tầm vũ khí để đánh; đấu sĩ Vàng chạm đồng đội kề bên để hỗ
## trợ (+12 HP); nút "Kết thúc lượt" hoặc hết 10s thì chuyển lượt.
## Đồng hồ trận 180s — hết giờ thắng bằng tổng % HP (đúng luật).
## Phím B (Main xử lý) đóng scene, trở lại map.
##
## Scene chạy trên CanvasLayer riêng (layer 2, trên HUD) nên vẽ theo
## tọa độ màn hình 720×1280, không bị camera zoom 1.6 kéo theo.
## Mọi hàm hành động đều trả kết quả chữ để test headless gọi trực
## tiếp được (xem tests/g4_battle_scene_test.gd).

signal close_requested
## G4 buoc 5: Main nghe de ghi giu sap + Danh vong vao save khi tran xong.
signal battle_finished(winner: String)

const VIEW_W := 720
const VIEW_H := 1280
const TILE_W := 64
const TILE_H := 32
# Lưới 12×9: chiều rộng thô (12+9-1)*32 = 704, cao (12+9-1)*16+32.
# Tâm lưới đặt ở (360, 560): trên là HUD trận, dưới là panel hành động.
const GRID_CENTER := Vector2(360, 560)

# Màu vai (đúng docs/stats.md): Đỏ Thể, Xanh Trí, Vàng Tâm,
# Tím Kỷ, Cam Dũng, Lục Sáng.
const ROLE_COLORS := {
	"Do": Color(0.84, 0.27, 0.27),
	"Xanh": Color(0.24, 0.49, 0.84),
	"Vang": Color(0.91, 0.73, 0.24),
	"Tim": Color(0.54, 0.37, 0.84),
	"Cam": Color(0.91, 0.48, 0.17),
	"Luc": Color(0.30, 0.69, 0.43),
}
const TEAM_A_COLOR := Color(0.35, 0.62, 0.95)
const TEAM_B_COLOR := Color(0.95, 0.62, 0.25)

var mb: PxbMarketBattle = null
var battle: Dictionary = {}
var font: Font = null
var font_bold: Font = null

## AI lượt địch (G4 bước 2): Main bật khi mở trận demo thật
## (ai_enabled = true); test mặc định tắt để lượt địch đứng yên
## như trước. ai_team = đội do AI cầm (mặc định "B" = Đội Chợ).
## AI_ACT_DELAY: đợi 1,2s đầu lượt địch rồi mới đi — người chơi
## kịp thấy lượt chuyển sang ai.
const AI_ACT_DELAY := 1.2
var ai_enabled := false
var ai_team := "B"

var _offset := Vector2.ZERO
var _selected_id := ""
var _turn_elapsed := 0.0
var _match_acc := 0.0
var _last_action := ""
var _ai_wait := 0.0
var _ai_done_this_turn := false
var _end_rect := Rect2(16, 1120, 330, 70)
var _close_rect := Rect2(374, 1120, 330, 70)

## Cầu nối trạng thái trận ra JS (Vòng 92) — xem battle_status().
var _bridge_dirty := false

## V93: chống click kép do emulate_touch_from_mouse=true — 1 click
## chuột sinh CẢ InputEventMouseButton LẪN InputEventScreenTouch, nên
## _unhandled_input gọi click_screen 2 lần: click "Kết thúc lượt" thứ
## 2 bỏ qua luôn lượt địch vừa tới (A -> B -> A kế trong cùng 1
## khung, B đứng yên cả trận — probe r93b). Chặn click thứ 2 cùng vị
## trí trong 300ms; click khác vị trí / sau 300ms vẫn qua bình thường.
var _last_click_msec := -100000
var _last_click_pos := Vector2.INF

## Animation trận (G4 — chỉ lớp vẽ, KHÔNG sửa luật PxbMarketBattle).
## Đấu sĩ trước đây nhảy ô tức thì; nay vị trí VẼ (_visual_pos) trượt
## về ô logic với tốc độ MOVE_ANIM_SPEED, đánh thì lao tới + chớp
## sáng mục tiêu, hỗ trợ thì vòng xanh lan ra + "+N HP". Mọi fx chỉ
## đọc battle dict, không ghi vào đó.
const MOVE_ANIM_SPEED := 420.0
const ATTACK_ANIM_SECONDS := 0.45
const SUPPORT_ANIM_SECONDS := 0.6
var _visual_pos := {}
var _attack_fx := {}
var _support_fx := {}


## Gắn logic trận + trận đã tạo (create_battle trả về). Tính offset
## lưới từ tâm GRID_CENTER (cùng công thức IsoMap.build).
func setup(p_mb: PxbMarketBattle, p_battle: Dictionary, p_font: Font, p_font_bold: Font) -> void:
	mb = p_mb
	battle = p_battle
	font = p_font
	font_bold = p_font_bold
	var corners: Array[Vector2] = [
		tile_center_raw(Vector2i(0, 0)), tile_center_raw(Vector2i(11, 0)),
		tile_center_raw(Vector2i(0, 8)), tile_center_raw(Vector2i(11, 8)),
	]
	var min_p := corners[0]
	var max_p := corners[0]
	for p in corners:
		min_p = Vector2(minf(min_p.x, p.x), minf(min_p.y, p.y))
		max_p = Vector2(maxf(max_p.x, p.x), maxf(max_p.y, p.y))
	_offset = GRID_CENTER - (min_p + max_p) * 0.5
	_selected_id = str(battle.get("activeFighterId", ""))
	_turn_elapsed = 0.0
	_match_acc = 0.0
	_last_action = "Trận bắt đầu — chạm ô xanh lá để di chuyển."
	_ai_wait = 0.0
	_ai_done_this_turn = false
	_attack_fx = {}
	_support_fx = {}
	_sync_visual_pos()
	_bridge_dirty = true
	if mb != null:
		mb.turn_changed.connect(_on_turn_changed)
		mb.battle_finished.connect(_on_battle_finished)


func _on_turn_changed(_fighter_id: String) -> void:
	_turn_elapsed = 0.0
	_selected_id = str(battle.get("activeFighterId", ""))
	_ai_wait = 0.0
	_ai_done_this_turn = false
	_bridge_dirty = true
	queue_redraw()


func _on_battle_finished(_winner: String) -> void:
	_last_action = result_text()
	_bridge_dirty = true
	queue_redraw()
	battle_finished.emit(_winner)


## Vong 99: Main neo lai hold theo ngay server SAU khi scene chup
## _last_action = result_text() (cua so local, vd den ngay 11) — dong
## bo lai _last_action cho khop hold da neo (vd ngay 8) de panel duoi
## khong lech panel giua (panel giua doc result_text() truc tiep nen
## tu thay ngay moi). Chi goi khi tran da xong va hold da doi.
func refresh_last_action() -> void:
	_last_action = result_text()
	_bridge_dirty = true
	queue_redraw()


## --- Cầu nối trạng thái trận ra JS (Vòng 92) ---
## Bài học V91: replay mù 34 lượt không trúng đòn nào — click rơi
## vào lượt địch (đợi 3s sau Kết thúc lượt, trong khi AI cần 1,2s
## game ≈ 5,5s wall mới đi) và click Kết thúc lượt bỏ qua lượt địch
## trước khi AI kịp hành động. Script browser-verify từ nay đọc
## window.__pxb_battle để đồng bộ từng lượt (đợi đúng đấu sĩ, kiểm
## chứng đòn đã trúng rồi mới Kết thúc lượt), thay vì bấm mù theo
## thời gian. Chỉ đẩy trên web (OS.has_feature("web")), theo đúng
## mẫu window.__pxb_map/__pxb_tile của Main; headless/test không
## gọi JavaScriptBridge — battle_status() thuần, test gọi trực tiếp.
func battle_status() -> Dictionary:
	var fighters: Array = []
	if mb != null and not battle.is_empty():
		for f in mb.all_fighters(battle):
			fighters.append({
				"id": str(f.get("id", "")),
				"team": mb.team_of(battle, f),
				"name": str(f.get("name", "")),
				"x": int(f.get("x", -1)), "y": int(f.get("y", -1)),
				"hp": int(f.get("hp", 0)), "maxHp": int(f.get("maxHp", 0)),
				"alive": bool(f.get("alive", false)),
				"moved": bool(f.get("movedThisTurn", false)),
				"acted": bool(f.get("actedThisTurn", false)),
			})
	var reach: Array = []
	for t in reachable_tiles():
		reach.append([t.x, t.y])
	var atk: Array = []
	for e in attackable_targets():
		atk.append([int(e.get("x", -1)), int(e.get("y", -1))])
	var act := active_fighter()
	var over := not battle.is_empty() and not is_fighting()
	var winner := ""
	if over:
		winner = str((battle.get("result", {}) as Dictionary).get("winner", ""))
	return {
		"open": not battle.is_empty(),
		"over": over,
		"winner": winner,
		"round": int(battle.get("round", 0)),
		"turn_fighter": str(act.get("id", "")),
		"turn_team": ("" if act.is_empty() else mb.team_of(battle, act)),
		"hp_a_pct": (mb.team_hp_percent(battle, "A") if mb != null else 0.0),
		"hp_b_pct": (mb.team_hp_percent(battle, "B") if mb != null else 0.0),
		"last_action": _last_action,
		"result_text": (result_text() if over else ""),
		"reachable": reach,
		"attackable": atk,
		"fighters": fighters,
	}


func _push_bridge() -> void:
	if not OS.has_feature("web"):
		return
	JavaScriptBridge.eval("window.__pxb_battle = " + JSON.stringify(battle_status()))


## --- Toán lưới (cùng công thức IsoMap) ---

static func tile_center_raw(tile: Vector2i) -> Vector2:
	return Vector2((tile.x - tile.y) * (TILE_W / 2), (tile.x + tile.y) * (TILE_H / 2) + TILE_H / 2)

func tile_center(tile: Vector2i) -> Vector2:
	return _offset + tile_center_raw(tile)

func screen_to_tile(pos: Vector2) -> Vector2i:
	var local := pos - _offset
	var dx := local.x / (TILE_W / 2.0)
	var dy := (local.y - TILE_H / 2.0) / (TILE_H / 2.0)
	return Vector2i(int(round((dx + dy) / 2.0)), int(round((dy - dx) / 2.0)))


## --- Trạng thái trận (đọc từ PxbMarketBattle) ---

func is_fighting() -> bool:
	return not battle.is_empty() and str(battle.get("status", "")) == PxbMarketBattle.STATUS_FIGHTING

func active_fighter() -> Dictionary:
	if battle.is_empty() or mb == null:
		return {}
	return mb.active_fighter(battle)

func turn_seconds_left() -> float:
	return maxf(0.0, float(PxbMarketBattle.TURN_SECONDS) - _turn_elapsed)

func match_seconds_left() -> int:
	if battle.is_empty():
		return 0
	return maxi(0, PxbMarketBattle.BATTLE_SECONDS - int(battle.get("elapsedSeconds", 0)))

func selected_fighter() -> Dictionary:
	if battle.is_empty() or mb == null or _selected_id == "":
		return {}
	return mb.find_fighter(battle, _selected_id)


## Ô di chuyển được của đấu sĩ đang tới lượt (chưa di chuyển lượt này).
func reachable_tiles() -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var f := active_fighter()
	if f.is_empty() or not is_fighting():
		return out
	if bool(f.get("movedThisTurn", false)):
		return out
	var rng := PxbMarketBattle.move_range_of(f)
	var fx := int(f["x"])
	var fy := int(f["y"])
	for y in range(PxbMarketBattle.GRID_H):
		for x in range(PxbMarketBattle.GRID_W):
			if PxbMarketBattle.manhattan(fx, fy, x, y) > rng:
				continue
			if not mb.fighter_at(battle, x, y).is_empty():
				continue
			out.append(Vector2i(x, y))
	return out


## Địch còn đứng trong tầm vũ khí của đấu sĩ đang tới lượt.
func attackable_targets() -> Array:
	var out: Array = []
	var f := active_fighter()
	if f.is_empty() or not is_fighting():
		return out
	if bool(f.get("actedThisTurn", false)):
		return out
	var w: Dictionary = PxbMarketBattle.WEAPONS.get(str(f.get("weapon", "Chao")), PxbMarketBattle.WEAPONS["Chao"])
	var rng := int(w["range"])
	var my_team := mb.team_of(battle, f)
	for e in mb.all_fighters(battle):
		if not bool(e.get("alive", false)):
			continue
		if mb.team_of(battle, e) == my_team:
			continue
		if PxbMarketBattle.manhattan(int(f["x"]), int(f["y"]), int(e["x"]), int(e["y"])) <= rng:
			out.append(e)
	return out


## Đồng đội kề bên mà đấu sĩ Vàng đang tới lượt có thể hỗ trợ.
func supportable_allies() -> Array:
	var out: Array = []
	var f := active_fighter()
	if f.is_empty() or not is_fighting():
		return out
	if str(f.get("role", "")) != "Vang" or bool(f.get("actedThisTurn", false)):
		return out
	var my_team := mb.team_of(battle, f)
	for e in mb.all_fighters(battle):
		if str(e.get("id", "")) == str(f.get("id", "")):
			continue
		if not bool(e.get("alive", false)):
			continue
		if mb.team_of(battle, e) != my_team:
			continue
		if PxbMarketBattle.manhattan(int(f["x"]), int(f["y"]), int(e["x"]), int(e["y"])) <= 1:
			out.append(e)
	return out


## --- Animation trận (chỉ lớp vẽ) ---

## Vị trí vẽ hiện tại của 1 đấu sĩ (trượt về ô logic, không nhảy).
func visual_pos_of(fighter_id: String) -> Vector2:
	var f := mb.find_fighter(battle, fighter_id) if mb != null and not battle.is_empty() else {}
	if f.is_empty():
		return Vector2.ZERO
	return _visual_pos.get(fighter_id, tile_center(Vector2i(int(f["x"]), int(f["y"]))) + Vector2(0, -4))

## Vị trí vẽ để _draw dùng: vị trí trượt + lao tới/rung khi có fx đánh.
func fighter_draw_pos(f: Dictionary) -> Vector2:
	var base := visual_pos_of(str(f.get("id", "")))
	if _attack_fx.is_empty():
		return base
	var phase := clampf(float(_attack_fx.get("t", 0.0)) / ATTACK_ANIM_SECONDS, 0.0, 1.0)
	if str(f.get("id", "")) == str(_attack_fx.get("attacker_id", "")):
		var target_pos := visual_pos_of(str(_attack_fx.get("target_id", "")))
		var to := target_pos - base
		if to.length() > 1.0:
			return base + to.normalized() * sin(PI * phase) * minf(28.0, to.length() * 0.45)
		return base
	if str(f.get("id", "")) == str(_attack_fx.get("target_id", "")):
		return base + Vector2(sin(float(_attack_fx.get("t", 0.0)) * 55.0) * 3.0 * (1.0 - phase), 0)
	return base

## Fx đánh đang chạy ({} nếu không có) — test đọc.
func attack_fx() -> Dictionary:
	return _attack_fx

## Fx hỗ trợ đang chạy ({} nếu không có) — test đọc.
func support_fx() -> Dictionary:
	return _support_fx

func _start_attack_fx(attacker_id: String, target_id: String, res: Dictionary) -> void:
	_attack_fx = {
		"attacker_id": attacker_id, "target_id": target_id, "t": 0.0,
		"damage": int(res.get("damage", 0)), "dodged": bool(res.get("dodged", false)),
		"ko": bool(res.get("ko", false)),
	}

func _start_support_fx(target_id: String, healed: int) -> void:
	_support_fx = {"target_id": target_id, "t": 0.0, "healed": healed}

## Khởi tạo vị trí vẽ cho đấu sĩ chưa có (về đúng ô logic).
func _sync_visual_pos() -> void:
	if mb == null or battle.is_empty():
		return
	for f in mb.all_fighters(battle):
		var fid := str(f.get("id", ""))
		if not _visual_pos.has(fid):
			_visual_pos[fid] = tile_center(Vector2i(int(f["x"]), int(f["y"]))) + Vector2(0, -4)

## Đặt ngay vị trí vẽ về ô logic (dùng sau khi dời đấu sĩ bằng tay
## trong test, hoặc khi cần bỏ qua animation).
func snap_visual_pos() -> void:
	if mb == null or battle.is_empty():
		return
	for f in mb.all_fighters(battle):
		_visual_pos[str(f.get("id", ""))] = tile_center(Vector2i(int(f["x"]), int(f["y"]))) + Vector2(0, -4)

## Trượt vị trí vẽ về ô logic + đẩy đồng hồ fx. Gọi mỗi frame và
## trong simulate_seconds (test headless).
func _update_visual_pos(delta: float) -> void:
	_sync_visual_pos()
	if mb == null or battle.is_empty():
		return
	for f in mb.all_fighters(battle):
		var fid := str(f.get("id", ""))
		var goal: Vector2 = tile_center(Vector2i(int(f["x"]), int(f["y"]))) + Vector2(0, -4)
		var cur: Vector2 = _visual_pos.get(fid, goal)
		var d := goal - cur
		if d.length() <= 0.5:
			_visual_pos[fid] = goal
		else:
			_visual_pos[fid] = cur + d.normalized() * minf(d.length(), MOVE_ANIM_SPEED * delta)
	if not _attack_fx.is_empty():
		_attack_fx["t"] = float(_attack_fx["t"]) + delta
		if float(_attack_fx["t"]) >= ATTACK_ANIM_SECONDS:
			_attack_fx = {}
	if not _support_fx.is_empty():
		_support_fx["t"] = float(_support_fx["t"]) + delta
		if float(_support_fx["t"]) >= SUPPORT_ANIM_SECONDS:
			_support_fx = {}


## --- Hành động (gọi từ click/chạm hoặc test) ---
## Trả: "moved" | "attacked" | "supported" | "selected" | "ended" |
## "close" | "none".

func click_tile(tile: Vector2i) -> String:
	if not is_fighting() or mb == null:
		return "none"
	_bridge_dirty = true
	var f := active_fighter()
	if f.is_empty():
		return "none"
	var target: Dictionary = mb.fighter_at(battle, tile.x, tile.y)
	if not target.is_empty():
		var my_team := mb.team_of(battle, f)
		if mb.team_of(battle, target) == my_team:
			if str(target.get("id", "")) == str(f.get("id", "")):
				_selected_id = str(f["id"])
				return "selected"
			# Đồng đội: Vàng kề bên thì hỗ trợ, còn lại chỉ xem.
			for a in supportable_allies():
				if str(a.get("id", "")) == str(target.get("id", "")):
					var res: Dictionary = mb.support(battle, str(f["id"]), str(target["id"]))
					if bool(res.get("ok", false)):
						_last_action = "%s hỗ trợ %s +%d HP." % [str(f["name"]), str(target["name"]), int(res["healed"])]
						_selected_id = str(target["id"])
						_start_support_fx(str(target["id"]), int(res["healed"]))
						queue_redraw()
						return "supported"
			_selected_id = str(target["id"])
			queue_redraw()
			return "selected"
		# Địch: trong tầm thì đánh, ngoài tầm chỉ xem.
		for e in attackable_targets():
			if str(e.get("id", "")) == str(target.get("id", "")):
				var res: Dictionary = mb.attack(battle, str(f["id"]), str(target["id"]))
				if bool(res.get("ok", false)):
					if bool(res.get("dodged", false)):
						_last_action = "%s né đòn của %s!" % [str(target["name"]), str(f["name"])]
					elif bool(res.get("ko", false)):
						_last_action = "%s đánh ngã %s (−%d HP)!" % [str(f["name"]), str(target["name"]), int(res["damage"])]
					else:
						_last_action = "%s đánh %s −%d HP." % [str(f["name"]), str(target["name"]), int(res["damage"])]
					_selected_id = str(target["id"])
					_start_attack_fx(str(f["id"]), str(target["id"]), res)
					queue_redraw()
					return "attacked"
		_selected_id = str(target["id"])
		queue_redraw()
		return "selected"
	# Ô trống: trong tầm di chuyển thì đi.
	for t in reachable_tiles():
		if t == tile:
			if mb.move_fighter(battle, str(f["id"]), tile.x, tile.y):
				_last_action = "%s di chuyển tới (%d,%d)." % [str(f["name"]), tile.x, tile.y]
				queue_redraw()
				return "moved"
	return "none"


func end_turn_now() -> bool:
	if not is_fighting() or mb == null:
		return false
	var ok := mb.end_turn(battle)
	if ok:
		_bridge_dirty = true
		_last_action = "Hết lượt — tới %s." % str(active_fighter().get("name", ""))
		queue_redraw()
	return ok


## Chạm màn hình: nút trước, lưới sau.
func click_screen(pos: Vector2) -> String:
	if _end_rect.has_point(pos) and is_fighting():
		return "ended" if end_turn_now() else "none"
	if _close_rect.has_point(pos):
		return "close"
	if pos.y < 980.0:
		return click_tile(screen_to_tile(pos))
	return "none"


func _unhandled_input(event: InputEvent) -> void:
	var click_pos := Vector2.INF
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		click_pos = event.position
	elif event is InputEventScreenTouch and event.pressed:
		click_pos = event.position
	if click_pos == Vector2.INF:
		return
	# V93: bỏ click lặp cùng vị trí trong 300ms (chuột + touch giả lập
	# của cùng 1 lần bấm — xem _last_click_msec ở trên).
	var now_msec := Time.get_ticks_msec()
	if now_msec - _last_click_msec < 300 and click_pos.distance_to(_last_click_pos) < 12.0:
		return
	_last_click_msec = now_msec
	_last_click_pos = click_pos
	if click_screen(click_pos) == "close":
		close_requested.emit()


## --- Đồng hồ (gọi mỗi khung; test gọi simulate_seconds) ---

func _process(delta: float) -> void:
	if _bridge_dirty:
		_bridge_dirty = false
		_push_bridge()
	_update_visual_pos(delta)
	_advance_timers(delta)
	queue_redraw()


## Đang chờ AI đi: lượt của đội AI và AI chưa đi xong lượt này.
## _advance_timers dùng để không hết giờ lượt khi đang chờ AI (V93).
func _ai_pending() -> bool:
	if not ai_enabled or _ai_done_this_turn or mb == null:
		return false
	var act := active_fighter()
	return not act.is_empty() and mb.team_of(battle, act) == ai_team


func _advance_timers(seconds: float) -> void:
	if not is_fighting() or mb == null:
		return
	_turn_elapsed += seconds
	_match_acc += seconds
	while _match_acc >= 1.0:
		_match_acc -= 1.0
		mb.tick(battle, 1.0)
		if not is_fighting():
			return
	# V93: cho AI đi TRƯỚC khi xét hết giờ lượt. Trước đây hết giờ
	# chạy trước khối AI nên một khung hình giật (delta lớn đẩy
	# _turn_elapsed qua 10s trong lúc _ai_wait còn < 1,2s) nuốt trọn
	# lượt địch: expire_turn chuyển lượt trước khi AI kịp đi — trên
	# trình duyệt thật đội B đứng rải rác, không đánh như sim (V92).
	# AI lượt địch: tới lượt đội AI thì đợi AI_ACT_DELAY rồi đi 1
	# lượt (di chuyển/đánh/hỗ trợ + kết thúc lượt) qua
	# PxbMarketBattle.ai_take_turn.
	if _ai_pending():
		_ai_wait += seconds
		if _ai_wait >= AI_ACT_DELAY:
			_ai_done_this_turn = true
			_run_ai_turn()
			if not is_fighting():
				return
	# Không hết giờ lượt khi đang chờ AI: đồng hồ lượt của đấu sĩ AI
	# dừng ở mốc chờ, AI đi xong mới tính lượt mới (turn_changed
	# reset _turn_elapsed về 0 nên khung giật không ăn mất lượt kế
	# tiếp). Lượt người chơi vẫn hết giờ đúng 10s như luật.
	if _turn_elapsed >= float(PxbMarketBattle.TURN_SECONDS) and not _ai_pending():
		_turn_elapsed = 0.0
		mb.expire_turn(battle)


## Chạy 1 lượt AI cho đấu sĩ đang tới lượt; ghi hành động vào
## dòng log dưới panel để người chơi thấy địch vừa làm gì.
func _run_ai_turn() -> void:
	if mb == null or battle.is_empty():
		return
	var f := active_fighter()
	if f.is_empty():
		return
	# Chụp HP trước lượt AI để suy ra fx từ chênh lệch (đánh/hỗ trợ):
	# ai_take_turn chỉ trả chuỗi mô tả, không trả id mục tiêu.
	var hp_before := {}
	for e in mb.all_fighters(battle):
		hp_before[str(e.get("id", ""))] = int(e.get("hp", 0))
	var actor_id := str(f["id"])
	var res: Dictionary = mb.ai_take_turn(battle, actor_id)
	for e in mb.all_fighters(battle):
		var eid := str(e.get("id", ""))
		var hp_now := int(e.get("hp", 0))
		var hp_old: int = hp_before.get(eid, hp_now)
		if hp_now < hp_old:
			_start_attack_fx(actor_id, eid, {"damage": hp_old - hp_now})
		elif hp_now > hp_old:
			_start_support_fx(eid, hp_now - hp_old)
	var parts := PackedStringArray()
	for a in (res.get("actions", []) as Array):
		parts.append(str(a))
	if parts.is_empty():
		_last_action = "%s hết lượt." % str(f["name"])
	else:
		_last_action = " ".join(parts)
	_selected_id = str(battle.get("activeFighterId", ""))
	_bridge_dirty = true
	queue_redraw()


## Test headless: chạy đồng hồ N giây mà không cần _process.
func simulate_seconds(seconds: float) -> void:
	var left := seconds
	while left > 0.0:
		var step := minf(left, 0.5)
		_update_visual_pos(step)
		_advance_timers(step)
		left -= step
		if not is_fighting():
			return


## --- Kết quả ---

func result_text() -> String:
	if battle.is_empty():
		return ""
	if is_fighting():
		return ""
	var r: Dictionary = battle.get("result", {})
	var winner := str(r.get("winner", ""))
	var line := ""
	if winner == "hoa":
		line = "Hòa! Không đội nào giữ sạp."
	else:
		line = "%s thắng trận!" % str(r.get("winnerTeamName", ""))
	var rewards: Dictionary = r.get("rewards", {})
	var fa := int((rewards.get("teamA", {}) as Dictionary).get("famePerFighter", 0))
	var fb := int((rewards.get("teamB", {}) as Dictionary).get("famePerFighter", 0))
	line += " Danh vọng: %s +%d, %s +%d." % [str(battle["teamA"]["name"]), fa, str(battle["teamB"]["name"]), fb]
	var hold: Dictionary = battle.get("hold", {})
	if not hold.is_empty():
		line += " Giữ sạp %s đến ngày game %d." % [str(hold["stallId"]), int(hold["untilGameDay"])]
	return line


## --- Vẽ ---

func _role_color(role: String) -> Color:
	return ROLE_COLORS.get(role, Color(0.6, 0.6, 0.6))

func _text(f: Font, pos: Vector2, s: String, size: int, color: Color, align := HORIZONTAL_ALIGNMENT_LEFT, width := -1) -> void:
	if f == null:
		return
	draw_string_outline(f, pos, s, align, width, size, 6, Color(0, 0, 0, 0.9))
	draw_string(f, pos, s, align, width, size, color)

func _fmt_clock(total_s: int) -> String:
	return "%d:%02d" % [total_s / 60, total_s % 60]

func _draw() -> void:
	if font == null or battle.is_empty():
		return
	# Nền tối phủ map phía sau.
	draw_rect(Rect2(0, 0, VIEW_W, VIEW_H), Color(0.05, 0.06, 0.09, 0.94))
	# Tiêu đề + tỉ số HP 2 đội.
	_text(font_bold, Vector2(24, 52), "BỤI ĐỜI CHỢ CÁ", 36, Color(1, 0.85, 0.3))
	var hp_a := mb.team_hp_percent(battle, "A")
	var hp_b := mb.team_hp_percent(battle, "B")
	_text(font, Vector2(24, 90), "%s %.0f%%  —  %s %.0f%%" % [
		str(battle["teamA"]["name"]), hp_a * 100.0,
		str(battle["teamB"]["name"]), hp_b * 100.0], 24, Color(0.95, 0.95, 0.9))
	# Vòng + đồng hồ lượt/trận (lượt ≤3s thì đỏ).
	var turn_c := Color(1, 0.35, 0.3) if turn_seconds_left() <= 3.0 and is_fighting() else Color(0.95, 0.95, 0.9)
	_text(font, Vector2(24, 126), "Vòng %d/12  •  Lượt còn %ds  •  Trận còn %s" % [
		int(battle.get("round", 1)), int(ceil(turn_seconds_left())), _fmt_clock(match_seconds_left())],
		26, turn_c)
	_draw_grid()
	_draw_fighters()
	_draw_bottom()
	if not is_fighting():
		_draw_result()

func _draw_grid() -> void:
	var reach := reachable_tiles()
	var targets := attackable_targets()
	var target_tiles: Array[Vector2i] = []
	for e in targets:
		target_tiles.append(Vector2i(int(e["x"]), int(e["y"])))
	for y in range(PxbMarketBattle.GRID_H):
		for x in range(PxbMarketBattle.GRID_W):
			var t := Vector2i(x, y)
			var c := tile_center(t)
			var half_w := TILE_W / 2.0
			var half_h := TILE_H / 2.0
			var diamond := PackedVector2Array([
				c + Vector2(0, -half_h), c + Vector2(half_w, 0),
				c + Vector2(0, half_h), c + Vector2(-half_w, 0),
			])
			var tone := Color(0.17, 0.19, 0.24) if (x + y) % 2 == 0 else Color(0.13, 0.15, 0.2)
			if x <= 1:
				tone = tone.lerp(TEAM_A_COLOR, 0.25)
			elif x >= 10:
				tone = tone.lerp(TEAM_B_COLOR, 0.25)
			if reach.has(t):
				tone = Color(0.2, 0.65, 0.3, 0.85)
			draw_colored_polygon(diamond, tone)
			draw_polyline(PackedVector2Array([diamond[0], diamond[1], diamond[2], diamond[3], diamond[0]]),
				Color(0.5, 0.55, 0.65, 0.7), 1.0)
			if target_tiles.has(t):
				draw_polyline(PackedVector2Array([diamond[0], diamond[1], diamond[2], diamond[3], diamond[0]]),
					Color(1, 0.3, 0.25), 3.0)
			var sel := selected_fighter()
			if not sel.is_empty() and int(sel["x"]) == x and int(sel["y"]) == y:
				draw_polyline(PackedVector2Array([diamond[0], diamond[1], diamond[2], diamond[3], diamond[0]]),
					Color(1, 0.85, 0.2), 3.0)

## --- Nhãn tên đấu sĩ chống chồng (G4 bước 9) ---
## Tên rộng tới 120px, 2 đấu sĩ kề nhau (cách 32px ngang) vẫn đè nhau
## dù đã lệch theo chẵn/lẻ x — thấy trên ảnh browser-verify 13
## ("Cô Tư"/"Bạn Thân"). Tính rect từng tên theo độ rộng chữ thật,
## rồi đẩy xuống (khe 4px) theo thứ tự y; kẹp đáy ≤ 980 (trên panel
## hành động y=1000). Trả về Array Dictionary {id, name, rect}.
const FIGHTER_NAME_GAP := 4.0
const FIGHTER_NAME_MAX_Y := 980.0

func fighter_name_rects() -> Array:
	var out: Array = []
	if font == null or battle.is_empty() or mb == null:
		return out
	for f in mb.all_fighters(battle):
		var c := tile_center(Vector2i(int(f["x"]), int(f["y"]))) + Vector2(0, -4)
		var nm := str(f.get("name", ""))
		var w := minf(120.0, font.get_string_size(nm, HORIZONTAL_ALIGNMENT_LEFT, -1, 18).x + 8.0)
		var name_dy := 44.0 if int(f["x"]) % 2 == 0 else 64.0
		var r := Rect2(c.x - w / 2.0, c.y + name_dy - 20.0, w, 24.0)
		out.append({"id": str(f.get("id", "")), "name": nm, "rect": r})
	# Sắp theo y rồi x; đẩy rect chồng xuống dưới rect đã đặt.
	var order: Array = []
	for i in range(out.size()):
		order.append(i)
	order.sort_custom(func(a: int, b: int) -> bool:
		var ra: Rect2 = out[a]["rect"]
		var rb: Rect2 = out[b]["rect"]
		if absf(ra.position.y - rb.position.y) > 0.01:
			return ra.position.y < rb.position.y
		return ra.position.x < rb.position.x)
	var placed: Array[Rect2] = []
	for idx in order:
		var r: Rect2 = out[idx]["rect"]
		var guard := 0
		while guard < 24:
			guard += 1
			var hit := -1
			for j in range(placed.size()):
				if r.grow(FIGHTER_NAME_GAP / 2.0).intersects(placed[j]):
					hit = j
					break
			if hit < 0:
				break
			r.position.y = placed[hit].end.y + FIGHTER_NAME_GAP
			if r.end.y > FIGHTER_NAME_MAX_Y:
				# Hết chỗ dưới: đặt lên trên rect đang chặn.
				r.position.y = placed[hit].position.y - r.size.y - FIGHTER_NAME_GAP
				break
		out[idx]["rect"] = r
		placed.append(r)
	return out

func _draw_fighters() -> void:
	var act := active_fighter()
	# 2 lượt vẽ: vòng tròn trước, thanh HP + tên sau — để tên của
	# đấu sĩ này không bị vòng tròn của đấu sĩ khác đè lên.
	for f in mb.all_fighters(battle):
		var c := fighter_draw_pos(f)
		var alive := bool(f.get("alive", false))
		var col: Color = _role_color(str(f.get("role", "")))
		if not alive:
			col = Color(0.45, 0.45, 0.48)
		# Vòng vàng = đang tới lượt.
		if not act.is_empty() and str(act.get("id", "")) == str(f.get("id", "")) and is_fighting():
			draw_circle(c, 26, Color(1, 0.85, 0.2, 0.9))
			draw_circle(c, 26, Color(1, 0.85, 0.2, 0.25))
			draw_colored_polygon(PackedVector2Array([
				c + Vector2(-10, -34), c + Vector2(10, -34), c + Vector2(0, -22)]),
				Color(1, 0.85, 0.2))
		draw_circle(c, 20, col)
		draw_arc(c, 20, 0, TAU, 32, Color(1, 1, 1, 0.9), 2.0)
		# Chớp sáng khi bị đánh: trắng, ngã thì đỏ, mờ dần theo fx.
		if not _attack_fx.is_empty() and str(f.get("id", "")) == str(_attack_fx.get("target_id", "")):
			var aphase := clampf(float(_attack_fx.get("t", 0.0)) / ATTACK_ANIM_SECONDS, 0.0, 1.0)
			var flash_c := Color(1, 0.3, 0.25) if bool(_attack_fx.get("ko", false)) else Color(1, 1, 1)
			draw_circle(c, 22, Color(flash_c, (1.0 - aphase) * 0.45))
		if not alive:
			_text(font, c + Vector2(-60, 8), "ngã", 18, Color(1, 1, 1), HORIZONTAL_ALIGNMENT_CENTER, 120)
	var name_rects := fighter_name_rects()
	var rect_by_id := {}
	for nr in name_rects:
		rect_by_id[str(nr["id"])] = nr["rect"]
	for f in mb.all_fighters(battle):
		var c := fighter_draw_pos(f)
		var alive := bool(f.get("alive", false))
		# Thanh HP + tên. Tên lấy rect đã chống chồng (xem
		# fighter_name_rects) — fallback giữ hành vi cũ nếu thiếu.
		var pct := float(int(f.get("hp", 0))) / maxf(1.0, float(int(f.get("maxHp", 1))))
		var bar := Rect2(c.x - 22, c.y - 40, 44, 7)
		draw_rect(bar, Color(0, 0, 0, 0.7))
		var hp_c := Color(0.3, 0.85, 0.35) if pct > 0.5 else (Color(1, 0.75, 0.2) if pct > 0.25 else Color(1, 0.3, 0.25))
		draw_rect(Rect2(bar.position, Vector2(44.0 * pct, 7)), hp_c)
		var name_dy := 44.0 if int(f["x"]) % 2 == 0 else 64.0
		var nr: Rect2 = rect_by_id.get(str(f.get("id", "")),
			Rect2(c.x - 60, c.y + name_dy - 20.0, 120, 24))
		_text(font, Vector2(nr.position.x, nr.position.y + 20.0), str(f["name"]), 18,
			Color(1, 1, 1), HORIZONTAL_ALIGNMENT_CENTER, int(nr.size.x))
		# Vòng xanh lan ra + "+N HP" khi được hỗ trợ.
		if not _support_fx.is_empty() and str(f.get("id", "")) == str(_support_fx.get("target_id", "")):
			var sphase := clampf(float(_support_fx.get("t", 0.0)) / SUPPORT_ANIM_SECONDS, 0.0, 1.0)
			draw_arc(c, 22.0 + sphase * 18.0, 0, TAU, 32, Color(0.4, 1.0, 0.5, (1.0 - sphase) * 0.8), 3.0)
			_text(font, c + Vector2(-60, -72 - sphase * 20.0), "+%d HP" % int(_support_fx.get("healed", 0)),
				20, Color(0.4, 1.0, 0.5, 1.0 - sphase), HORIZONTAL_ALIGNMENT_CENTER, 120)

func _draw_bottom() -> void:
	draw_rect(Rect2(16, 1000, 688, 200), Color(0.1, 0.11, 0.15, 0.97))
	draw_rect(Rect2(16, 1000, 688, 200), Color(0.5, 0.55, 0.65, 0.6), false, 2.0)
	var act := active_fighter()
	if not act.is_empty() and is_fighting():
		var w: Dictionary = PxbMarketBattle.WEAPONS.get(str(act.get("weapon", "Chao")), PxbMarketBattle.WEAPONS["Chao"])
		_text(font_bold, Vector2(32, 1036), "Lượt: %s (%s — %s, tầm %d)" % [
			str(act["name"]), str(PxbMarketBattle.ROLES[str(act["role"])]["name"]),
			str(w["name"]), int(w["range"])], 26, Color(1, 0.9, 0.4))
		if ai_enabled and mb.team_of(battle, act) == ai_team:
			_text(font, Vector2(32, 1070), "Đội Chợ đang đi…", 20, Color(0.9, 0.9, 0.85))
		else:
			_text(font, Vector2(32, 1070), "Ô xanh: đi  •  Viền đỏ: đánh  •  Vàng chạm đồng đội kề: +12 HP", 20, Color(0.9, 0.9, 0.85))
	else:
		_text(font_bold, Vector2(32, 1036), "Trận đã kết thúc.", 26, Color(1, 0.9, 0.4))
	var over := not battle.is_empty() and not is_fighting()
	if over and not _last_action.is_empty():
		# V97: _last_action khi het tran = result_text() dai hon 656px
		# o co 22 nen bi cat mep phai (anh 122-r96b). Wrap toi da 2 dong
		# co 20, dong 1 o y=1078, cach nhau 28px de dong cuoi khong
		# cham nut (nut bat dau y=1120).
		var bw: Dictionary = bottom_action_lines(_last_action)
		var y := BOTTOM_TEXT_FIRST_Y
		for line in (bw["lines"] as PackedStringArray):
			_text(font, Vector2(32, y), line, int(bw["size"]), Color(0.85, 0.9, 0.85))
			y += BOTTOM_TEXT_LINE_H
	else:
		_text(font, Vector2(32, 1104), _last_action, 22, Color(0.85, 0.9, 0.85))
	# Nút Kết thúc lượt / Đóng.
	draw_rect(_end_rect, Color(0.2, 0.45, 0.75) if is_fighting() else Color(0.3, 0.3, 0.32))
	draw_rect(_end_rect, Color(1, 1, 1, 0.7), false, 2.0)
	_text(font_bold, _end_rect.position + Vector2(0, 46), "Kết thúc lượt", 26, Color(1, 1, 1), HORIZONTAL_ALIGNMENT_CENTER, 330)
	draw_rect(_close_rect, Color(0.45, 0.45, 0.48))
	draw_rect(_close_rect, Color(1, 1, 1, 0.7), false, 2.0)
	_text(font_bold, _close_rect.position + Vector2(0, 46), "Đóng (B)", 26, Color(1, 1, 1), HORIZONTAL_ALIGNMENT_CENTER, 330)

func _draw_result() -> void:
	var panel := Rect2(60, 430, 600, 300)
	draw_rect(panel, Color(0.08, 0.09, 0.13, 0.98))
	draw_rect(panel, Color(1, 0.85, 0.3), false, 3.0)
	_text(font_bold, panel.position + Vector2(0, 60), "KẾT THÚC TRẬN", 34, Color(1, 0.85, 0.3), HORIZONTAL_ALIGNMENT_CENTER, 600)
	# V96: result_text() dai hon 560px o co 24 (ten doi + danh vong +
	# giu sap) nen ve 1 dong bi cat o mep phai (anh 96-r95). Wrap theo
	# do rong that cua font, co co chu neu qua 4 dong.
	var wrapped: Dictionary = result_text_lines()
	var lines: PackedStringArray = wrapped["lines"]
	var size: int = int(wrapped["size"])
	var y := panel.position.y + 120.0
	for line in lines:
		_text(font, Vector2(panel.position.x + 20, y), line, size, Color(1, 1, 1), HORIZONTAL_ALIGNMENT_LEFT, 560)
		y += RESULT_LINE_H
	_text(font, panel.position + Vector2(0, 260), "Thua không bị phạt — hết trận hồi đầy HP.", 22, Color(0.85, 0.9, 0.85), HORIZONTAL_ALIGNMENT_CENTER, 600)


## --- Wrap ket qua (V96) ---
## result_text() 1 dong o co 24 vuot 560px nen bi cat mep phai.
## Wrap tham lam theo tu, do bang font that; neu qua
## RESULT_MAX_LINES dong thi co co chu xuong (24 -> 20 -> 18).
const RESULT_TEXT_MAX_W := 560.0
const RESULT_TEXT_SIZE := 24
const RESULT_LINE_H := 32.0
const RESULT_MAX_LINES := 4


func wrap_text(text: String, size: int, max_w: float) -> PackedStringArray:
	var lines := PackedStringArray()
	if font == null or text.is_empty():
		if not text.is_empty():
			lines.append(text)
		return lines
	var cur := ""
	for word in text.split(" "):
		if word.is_empty():
			continue
		var trial := word if cur.is_empty() else cur + " " + word
		if font.get_string_size(trial, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x <= max_w:
			cur = trial
		else:
			if not cur.is_empty():
				lines.append(cur)
				cur = ""
			# Tu don dai hon max_w: cat cung theo ky tu.
			var rest := word
			while font.get_string_size(rest, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > max_w and rest.length() > 1:
				var cut := 1
				while cut < rest.length() and font.get_string_size(rest.substr(0, cut + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, size).x <= max_w:
					cut += 1
				lines.append(rest.substr(0, cut))
				rest = rest.substr(cut)
			cur = rest
	if not cur.is_empty():
		lines.append(cur)
	return lines


func result_text_lines() -> Dictionary:
	var size := RESULT_TEXT_SIZE
	var lines := wrap_text(result_text(), size, RESULT_TEXT_MAX_W)
	while lines.size() > RESULT_MAX_LINES and size > 18:
		size -= 4
		lines = wrap_text(result_text(), size, RESULT_TEXT_MAX_W)
	return {"lines": lines, "size": size}


## --- Wrap dong hanh dong o panel duoi (V97) ---
## Khi het tran, _last_action = result_text() dai hon 656px o co 22
## nen bi cat mep phai (anh 122-r96b). Wrap toi da 2 dong co 20
## (xuong 18 neu van thua), dong 1 o y=1078, cach nhau 28px de dong
## cuoi khong cham nut (nut bat dau y=1120).
const BOTTOM_TEXT_MAX_W := 656.0
const BOTTOM_TEXT_SIZE := 20
const BOTTOM_TEXT_FIRST_Y := 1078.0
const BOTTOM_TEXT_LINE_H := 28.0
const BOTTOM_MAX_LINES := 2


func bottom_action_lines(text: String) -> Dictionary:
	var size := BOTTOM_TEXT_SIZE
	var lines := wrap_text(text, size, BOTTOM_TEXT_MAX_W)
	while lines.size() > BOTTOM_MAX_LINES and size > 18:
		size -= 2
		lines = wrap_text(text, size, BOTTOM_TEXT_MAX_W)
	if lines.size() > BOTTOM_MAX_LINES:
		# Ten doi cuc dai (khong co that) van thua 2 dong o co 18:
		# giu 2 dong dau, cat phan con lai co dau "…" — chu day du
		# da co o panel ket qua giua (_draw_result), day chi la
		# dong log trang thai nen khong duoc tran xuong nut.
		var head: PackedStringArray = [lines[0]]
		var rest := " ".join(lines.slice(1))
		var cut := rest
		while not cut.is_empty() and font != null and font.get_string_size(cut + "…", HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > BOTTOM_TEXT_MAX_W:
			cut = cut.substr(0, cut.length() - 1)
		head.append(cut + "…")
		lines = head
	return {"lines": lines, "size": size}
