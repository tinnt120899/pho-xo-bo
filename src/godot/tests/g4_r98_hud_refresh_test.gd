extends SceneTree
## G4 R98 HUD REFRESH TEST — chay headless, khong can trinh duyet:
##   godot --headless --path src/godot -s res://tests/g4_r98_hud_refresh_test.gd
## Kiem tra vong 98 (G4 — HUD refresh ngay khi tot nghiep): truoc day
## _advance_frame goi _update_hud() TRUOC _check_graduations() nen
## chi so phu moi (+10) chi hien khi mo dien thoai (r97: HUD van
## "Sang 100" ngay sau toast tot nghiep, anh 149/150). Nay
## _check_graduations() goi lai _update_hud() khi co thay doi nen
## nhan HUD len ngay, khong can mo dien thoai. Kiem tra ca 3 duong:
## khoa ngan (+10 chi so phu), pending cu (don o ngay doi), tot
## nghiep bang chinh (+EXP/Danh vong). Khong server, khong cong.
## In "G4 R98 HUD REFRESH TEST: n/n PASS".

var _frame := 0
var _state := 0
var _pass := 0
var _fail := 0
var _main: Node = null


func _check(test_name: String, cond: bool) -> void:
	if cond:
		_pass += 1
		print("  PASS ", test_name)
	else:
		_fail += 1
		print("  FAIL ", test_name)


func _finish() -> void:
	print("G4 R98 HUD REFRESH TEST: %d/%d PASS" % [_pass, _pass + _fail])
	quit(0 if _fail == 0 else 1)


func _init() -> void:
	process_frame.connect(_on_frame)
	var ps: PackedScene = load("res://Main.tscn")
	_main = ps.instantiate()
	root.add_child(_main)


func _on_frame() -> void:
	_frame += 1
	if _frame > 900:
		print("G4 R98 HUD REFRESH TEST: TIMEOUT")
		quit(1)
		return
	match _state:
		0:
			if _frame < 3:
				return
			# HUD ban dau: Sang 100, EXP 0 (khong goi _update_hud tay).
			_check("hud ban dau: Sang 100",
				String(_main._hud_substats.text).contains("Sáng 100"))
			_check("hud ban dau: EXP 0",
				String(_main._hud_gold.text).contains("EXP 0"))
			# Khoa ngan Sang, 3 ngay, 2tr — goc 100.
			_main.jobs.gold = 5000000
			var r1: Dictionary = _main.enroll_short_course()
			_check("dang ky khoa ngan ok", bool(r1.get("ok", false)))
			_main.education.day_number = 4
			# CHI goi _check_graduations() nhu _advance_frame lam —
			# khong goi _update_hud() tay, khong mo dien thoai.
			_main._check_graduations()
			_check("tot nghiep: stats Sang 110", _main.stats.sang() == 110)
			_check("tot nghiep: HUD Sang 110 NGAY (khong can mo dien thoai)",
				String(_main._hud_substats.text).contains("Sáng 110"))
			_check("tot nghiep: toast bao Sang +10",
				String(_main._toast.text).contains("Sáng +10"))
			_check("tot nghiep: chi so khac khong doi tren HUD",
				String(_main._hud_substats.text).contains("Kỷ 100")
				and String(_main._hud_substats.text).contains("Dũng 100"))
			_state = 1
		1:
			# Khoa thu 2 cong don: Sang 110 -> 120, HUD theo ngay.
			var r2: Dictionary = _main.enroll_short_course()
			_check("dang ky khoa 2 ok", bool(r2.get("ok", false)))
			_main.education.day_number = 7
			_main._check_graduations()
			_check("khoa 2: HUD Sang 120 ngay",
				String(_main._hud_substats.text).contains("Sáng 120"))
			_state = 2
		2:
			# Pending cu (save r86) ap o ngay doi: Ky +10, HUD len ngay,
			# khong toast moi (giong r87 state 2, them kiem HUD).
			var ky_before: int = _main.stats.ky()
			var toast_before := String(_main._toast.text)
			var hud_before := String(_main._hud_substats.text)
			_main.education.pending_stat_gain = {"ky": 10, "la": 5}
			_main._check_graduations()
			_check("pending cu: Ky +10", _main.stats.ky() == ky_before + 10)
			_check("pending cu: HUD Ky len ngay",
				String(_main._hud_substats.text).contains("Kỷ %d" % (ky_before + 10)))
			_check("pending cu: HUD cu khong con",
				not String(_main._hud_substats.text) == hud_before)
			_check("pending cu: khong toast moi",
				String(_main._toast.text) == toast_before)
			_state = 3
		3:
			# Tot nghiep bang chinh Cao dang: +500 EXP, HUD EXP len ngay.
			# Dang ky bang 1 (Cao dang, 60 ngay, 20tr, Tri 40).
			_main.jobs.gold = 30000000
			var re: Dictionary = _main.education.enroll(1, 100, -1, 30000000)
			_check("dang ky Cao dang ok", bool(re.get("ok", false)))
			_main.education.day_number = int(re["end_day"])
			_main._check_graduations()
			_check("tot nghiep CD: EXP 500", _main.jobs.exp_total == 500)
			_check("tot nghiep CD: HUD EXP 500 ngay",
				String(_main._hud_gold.text).contains("EXP 500"))
			_check("tot nghiep CD: toast bao tot nghiep",
				String(_main._toast.text).contains("Tốt nghiệp"))
			_state = 4
		4:
			# Khong co tot nghiep/pending: HUD khong doi (khong refresh thua).
			var hud_before := String(_main._hud_substats.text)
			var gold_before := String(_main._hud_gold.text)
			_main.education.day_number = 999
			_main._check_graduations()
			_check("khong tot nghiep: HUD substats khong doi",
				String(_main._hud_substats.text) == hud_before)
			_check("khong tot nghiep: HUD gold khong doi",
				String(_main._hud_gold.text) == gold_before)
			_finish()
