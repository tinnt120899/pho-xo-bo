extends Node2D
## Main.gd — Dieu khien game G1 (slice parity Map001-002 voi ban MV)
## + G2 UI wiring phan 1 (20/11 ~02:45): Jobs / Hotspot / Crafting /
## Stats da noi vao scene that.
## + G2 UI wiring phan 2 (20/11 ~04:00): PhoneHub (phim P + panel 9
## tab) + SaveCloud (luu/tai slot 1-3) + Economy (ngan hang + cho) +
## Education (dang ky hoc) + Social / Titles / Story (hien thi + len
## chuong) + Tools (xem bac + nang cap trong tab Viec lam) + Online
## (trang thai + kiem tra mang trong tab Cai dat).
## + G4 vong 74: UI trade / dau gia trong dien thoai — nut gui de
## nghi doi do cho nguoi online, chap nhan/tu choi/huy de nghi (tab
## Tin nhan) + dat gia / mo phien / huy phien / lam moi (tab Cho).
## + G4 vong 75: o nhap so trong dien thoai — so tien muon lay khi
## doi do, gia khoi diem + thoi gian phien, gia dau; het so mau co
## dinh 100.000d / 60 giay o vong 74 (chi con lam mac dinh khi o
## trong hoac go sai).
## Vi: MỘT vi duy nhat la jobs.gold; economy.money chi la ban dong bo
## tam truoc moi giao dich mua/gui/rut (xem _wallet_to_economy).
## Danh vong: bien fame cua Main (PxbStats chua co fame); tot nghiep
## cong EXP vao jobs.exp_total + Danh vong vao fame, roi xoa pending.
##
## He thoi gian kieu C (da chot, TimeSystem.cs / PXB_Time.js): 1 ngay game =
## 30 phut that, 3 khung Sang/Chieu/Toi, moi khung 10 phut that, miss khung
## khong phat. Phim F (nut "Doi khung") doi khung ngay de test — chi de test.
## G2: khung + do dai khung lay tu PxbBalance / PxbTime (autoload PXB_Time),
## khong hardcode so trong file nay nua.
## Hotspot: nhan 1 lan/ngay game, chi co do dung khung (PXB_Hotspot.js).
## NPC: doi thoai lua chon [Hoi goi y / Tam biet] — goi y lay tu Actors.js.
## Co Tu day che Xe Day, Anh Hai day che Den Soi (dung unlock note cua
## PxbBalance.RECIPES).
## Tui nguyen lieu: MỘT Dictionary duy nhat — hotspot.materials, bind
## sang crafting (bind_materials) + bien inventory cua Main tro toi
## cung Dictionary do (gán theo tham chiếu), nen nhat -> che dung chung.

const MATERIAL_NAMES := {
	"chai-nhua": "Chai Nhựa", "la-chuoi": "Lá Chuối", "sat-vun": "Sắt Vụn",
	"van-go": "Ván Gỗ", "vai-vun": "Vải Vụn", "khung-sat": "Khung Sắt",
	"banh-xe": "Bánh Xe",
}

# Camera nhin lech len 265 world units + zoom 1.25 (vong 7, thay
# -320/1.4): o 1.4, day map (xe dap/hoa o y 686) nam duoi mep duoi
# luc spawn (tam nhin doc 914, day hien toi y 599) — desktop bi
# cat day ~200px. O 1.25 tam nhin doc 1024, tam y 197: thay du tu
# dinh mat tien (-308) toi day dat + xe dap (702), khong cat day.
const CAMERA_LOOK_UP := Vector2(0, -265)
const CAMERA_ZOOM := 1.25
# Meo dien thoai xoay theo ngay — lap khoang trong duoi panel
# (art pass Nadia 20/11: panel 1100 cao hon noi dung ~450px).
const PHONE_TIPS := [
	"Nói chuyện với Bạn thân mỗi khung tăng thân thiết +5.",
	"Hotspot xanh là đồ thường, cam là đồ hiếm — nhặt trước khi đổi khung.",
	"Góc Chế Tạo: gom đủ nguyên liệu rồi bấm Chế tạo.",
	"Đổi khung (F) để sang Sáng/Chiều/Tối — mỗi khung có việc khác nhau.",
	"Cửa ra Chợ Đầu Mối dẫn sang khu chợ — đi bộ tới cửa rồi bấm vào.",
]
# Ten ending hien thi cho nguoi choi — suggest_ending() tra ve ID
# noi bo (TuDo/GiamDoc/...), hien thi phai dich sang tieng Viet
# (loi "Ending gợi ý hiện tại: TuDo" o dien thoai, vong 3 art pass).
const ENDING_NAMES := {
	"GiamDoc": "Giám đốc", "HocGia": "Học giả", "GiaDinh": "Gia đình",
	"TuDo": "Tự do", "SieuGiau": "Siêu giàu", "ChuaMo": "Chưa mở",
}
# Map ten hien thi cua su kien "craft" trong data/maps.json -> recipe_id
# trong PxbBalance.RECIPES. Ten su kien do map data quyet dinh; recipe_id
# do Balance quyet dinh — anh xa o day de khong sua map data.
const CRAFT_RECIPE_BY_NAME := {
	"Xe Đẩy Hàng": "che-xe-day",
	"Đèn Soi": "che-den-soi",
}
# Vong 74 (G4 §95.5): UI trade / dau gia trong dien thoai — de nghi
# mau + phien mau dung so mac dinh, nguoi choi go so tay o vong 75.
# De nghi: cho mon dau tien trong tui, lay so tien o nhap (mac dinh
# 100.000d). Phien: ban mon dau tien trong tui, gia khoi diem + thoi
# gian o nhap (mac dinh 100.000d, 60 giay). Dat gia: o nhap, de
# trong thi lay gia tiep theo (gia hien tai + 1.000d).
const TRADE_OFFER_WANT_MONEY_VND := 100000
const AUCTION_CREATE_START_PRICE_VND := 100000
const AUCTION_CREATE_DURATION_S := 60
# Vòng 87: tên hiển thị 4 chỉ số phụ (khóa ngắn hạn tốt nghiệp).
const SUB_STAT_NAMES := {"ky": "Kỷ", "dung": "Dũng", "sang": "Sáng", "an-yen": "An Yên"}

var font: Font
var font_bold: Font
var maps_data: Dictionary = {}
var current_map_id := 1
var iso_map: IsoMap = null
var player: Player = null
var day := 1
var frame_idx := 0
var _frame_timer := 0.0
var _toast_timer := 0.0
# Tui nguyen lieu — sau _ready() tro toi hotspot.materials (cung
# Dictionary, gán theo tham chiếu); truoc _ready() la Dictionary rong.
var inventory := {}
var dialogue_open := false

# He G2 noi vao scene (tao trong _create_systems, truoc load_map).
var stats: PxbStats = null
var jobs: PxbJobs = null
var hotspot: PxbHotspot = null
var crafting: PxbCrafting = null
# He G2 phan 2 (PhoneHub / SaveCloud / Economy / Education / Social /
# Titles / Story / Tools / Online).
var phonehub: PxbPhoneHub = null
var savecloud: PxbSaveCloud = null
var economy: PxbEconomy = null
# Túi đồ slice (PxbInventory: com-tam / ca-phe / sach / ao-mua) —
# khác `inventory` (Dictionary nguyên liệu chế đồ của hotspot).
# G4 bước 11: bag là túi để áp trade WS vào.
var bag: PxbInventory = null
var education: PxbEducation = null
var social: PxbSocial = null
var titles: PxbTitles = null
var story: PxbStory = null
var tools: PxbTools = null
var online: PxbOnline = null
## Vong 77: lan mua o cho dang cho server xac nhan (chi 1 lan
## cho — nut mua an trong luc cho, xem TAB_CHO): {req_id,
## item_id, discount_percent, money_at_send} (money_at_send =
## jobs.gold luc gui — ack ve thi ap jobs.gold = ack.money +
## (jobs.gold - money_at_send) de khong mat tien kiem/tieu local
## trong luc cho ack; rong = khong co lan mua nao dang cho).
var _pending_shop_buy: Dictionary = {}
# Vong 86: lan ban lai cho cho dang cho server xac nhan
# shop_sell_ack — {req_id, item_id, money_at_send} (money_at_send =
# jobs.gold luc gui — ack ve thi ap jobs.gold = ack.money +
# (jobs.gold - money_at_send); rong = khong co lan ban nao dang cho).
var _pending_shop_sell: Dictionary = {}
# Danh vong (PxbStats chua co fame) + trang thai dien thoai.
var fame := 0
var phone_open := false
# Scene tran Bui Doi Cho Ca (G4 §4): mo bang phim B (demo 3v3).
var battle_mb: PxbMarketBattle = null
var battle_scene: BattleScene = null
var _battle_layer: CanvasLayer = null
var battle_open := false
## G4 buoc 5: giu sap + lich su tran (PxbMarketBattle.data) — song
## theo save slot, khoi phuc o _apply_save_data, don het han theo
## ngay game o _advance_frame. Chi ghi khi tran ket thuc that.
var battle_state: Dictionary = {}
var _battle_saved := false

var _hud_map: Label
var _hud_day: Label
var _hud_bag: Label
var _hud_gold: Label
var _hud_stats: Label
var _hud_substats: Label # Vong 88: dong chi so phu (Ky/Dung/Sang/An Yen).
var _toast: Label
var _dpad: Control = null  # Vong 10: nut mui ten tren man hinh (di bang cham).
var _dpad_press_count := 0  # Vong 10b: dem button_down (chan doan click lap).
var _dbg_label: Label = null  # Vong 10: hien o + input cuoi (kiem chung di chuyen).
var _debug_labels_visible := true  # Vong 12: nhan debug mac dinh HIEN
	# tro lai (cong cu chan doan duy nhat cua checker) — F9 an/hien.
	# Truoc day mac dinh an (§29.3) nhung ban deploy a87a871d van
	# hien (xuat tu source cu) va checker 12:56 khong biet bam F9
	# nen mat cong cu doc o. Tu nay mac dinh hien, chi an sau khi
	# di chuyen da qua kiem live (luat AGENTS.md 21/11).
var _last_input := ""  # Vong 10: mo ta input di chuyen gan nhat (vd "D", "cham (9,7)").
var _camera: Camera2D
var _ground_sprite: Sprite2D = null  # Vong 17: nen dat (doi texture theo map).
var _daynight: ColorRect
var _overlay_layer: CanvasLayer
var _glow_canvas: GlowCanvas = null  # Vong 19: anh sang ADD tren lop MUL.
var _ambient: AmbientLife = null  # Vong 19: la roi + dom dom.
var _ui_layer: CanvasLayer
var _title_panel: PanelContainer
var _label_layer: CanvasLayer  # Lop nhan tren the gioi (duoi HUD).
var _phone_notch: Panel  # Notch + thanh home cua khung dien thoai.
var _phone_homebar: Panel
var _js_poll := 0.0  # Poll window.__pxb_start (nut DOM "Bat dau").
var _npc_patrol_wait := {}  # Vong 22: instance_id Marker -> so giay con lai truoc quyet dinh patrol ke.
var _npc_patrol_tick := 0.0  # Vong 22: tich luy delta, quyet dinh patrol moi 0.5s.
var title_open := true
var _dlg_panel: PanelContainer
var _dlg_name: Label
var _dlg_text: Label
var _dlg_choices: VBoxContainer
# UI dien thoai (phan 2).
var _phone_btn: Button
var _phone_dim: ColorRect
var _phone_panel: PanelContainer
var _phone_title: Label
var _phone_content: Label
var _phone_hint: Label
var _phone_tip: Label
var _phone_footer: Label
var _phone_actions: VBoxContainer
var _phone_act_scroll: ScrollContainer
var _phone_content_scroll: ScrollContainer  # Vong 4: cao 224 de hien tron dong Chi Le.
var _phone_chat_input: LineEdit = null  # G4 buoc 7: o nhap chat WS (tab Tin nhan).
var _phone_trade_money_input: LineEdit = null  # Vong 75: o nhap so tien muon lay khi doi do.
var _phone_auction_price_input: LineEdit = null  # Vong 75: o nhap gia khoi diem.
var _phone_auction_duration_input: LineEdit = null  # Vong 75: o nhap thoi gian phien (giay).
var _phone_bid_input: LineEdit = null  # Vong 75: o nhap gia dau.
var _trade_want_money_vnd := TRADE_OFFER_WANT_MONEY_VND  # Vong 75: giu so da go qua moi lan ve lai dien thoai.
var _auction_start_price_vnd := AUCTION_CREATE_START_PRICE_VND
var _auction_duration_s := AUCTION_CREATE_DURATION_S
var _bid_amount_vnd := 0  # Vong 75: 0 = de trong, tu lay gia tiep theo.
var _phone_today: Label  # Khoi "Hom nay" lap khoang trong dien thoai.
var _phone_tab_buttons := {}

# Ten tieng Viet cho loai quan he / giai doan (khong hien ma noi bo
# nhu "BestFriend" / "QuenBiet" cho nguoi choi — loi 20/11 10:30).
const KIND_NAMES := {
	"Lover": "Người yêu", "Spouse": "Vợ/Chồng", "BestFriend": "Bạn thân",
	"FriendGroup": "Hội bạn", "Parent": "Bố/Mẹ", "Child": "Con",
	"CompanyPartner": "Đối tác công ty",
}
const STAGE_NAMES := {
	"QuenBiet": "Quen biết", "ThanThiet": "Thân thiết", "HenHo": "Hẹn hò",
	"DinhHon": "Đính hôn", "Cuoi": "Đã cưới", "TanRa": "Đã tan rã",
}

func _ready() -> void:
	font = load("res://DejaVuSans.ttf")
	font_bold = load("res://DejaVuSans-Bold.ttf")
	var raw := FileAccess.get_file_as_string("res://data/maps.json")
	maps_data = JSON.parse_string(raw)
	_build_ui()
	_create_systems()
	load_map(int(maps_data["start"]["map"]),
		Vector2i(int(maps_data["start"]["x"]), int(maps_data["start"]["y"])))
	# Man hinh title mo san: khoa input cho toi khi bam "Bat dau".
	if player != null:
		player.input_blocked = true
	# Vong 93: khoi phuc player_id WS ben tu kho luu (file user:// /
	# localStorage) ngay tu luc mo game, de vi server khong mat khi
	# F5 — khong doi id neu da co (xem PxbOnline.ensure_ws_player_id).
	online.ensure_ws_player_id()


# Tao cac he G2 lam node con cua Main. Stats uu tien dung autoload
# PXB_Stats (giu 1 bo chi so duy nhat cua nguoi choi); chay headless
# bang script -s ma autoload chua kip dang ky thi tao node rieng de
# scene van chay duoc (fallback nay chi dung khi khong co autoload).
func _create_systems() -> void:
	stats = get_node_or_null("/root/PXB_Stats") as PxbStats
	if stats == null:
		stats = PxbStats.new()
		add_child(stats)
	jobs = PxbJobs.new()
	jobs.stats = stats
	jobs.set_day_number(day)
	add_child(jobs)
	hotspot = PxbHotspot.new()
	add_child(hotspot)
	crafting = PxbCrafting.new()
	crafting.bind_materials(hotspot.materials)
	add_child(crafting)
	inventory = hotspot.materials
	phonehub = PxbPhoneHub.new()
	add_child(phonehub)
	savecloud = PxbSaveCloud.new()
	add_child(savecloud)
	economy = PxbEconomy.new()
	add_child(economy)
	bag = PxbInventory.new()
	add_child(bag)
	education = PxbEducation.new()
	education.day_number = day
	add_child(education)
	social = PxbSocial.new()
	social.seed_slice(1)
	add_child(social)
	titles = PxbTitles.new()
	add_child(titles)
	story = PxbStory.new()
	add_child(story)
	tools = PxbTools.new()
	tools.bind_materials(hotspot.materials)
	tools.bind_crafting(crafting)
	tools.bind_hotspot(hotspot)
	add_child(tools)
	online = PxbOnline.new()
	add_child(online)
	# G4 buoc 7: chat WS — tin/presence moi thi lam tuoi dien
	# thoai neu dang mo tab Tin nhan, khong thi bao so chua doc.
	online.ws_chat_received.connect(_on_ws_chat_received)
	# Vong 85: lich su chat ve sau khi hello lai — noi de lam tuoi
	# tab Tin nhan ngay khi lich su ve (welcome den truoc nen
	# _refresh_phone o _on_ws_status_changed chay luc log con trong).
	online.ws_chat_history_received.connect(_on_ws_chat_history_received)
	online.ws_presence_changed.connect(_on_ws_presence_changed)
	online.ws_status_changed.connect(_on_ws_status_changed)
	# G4 bước 11: nối túi + ví cho trade WS — bag là túi đồ slice,
	# economy.money là bản đồng bộ của ví chung jobs.gold.
	online.trade_inventory = bag
	online.trade_economy = economy
	online.ws_trade_completed.connect(_on_ws_trade_completed)
	online.ws_auction_closed.connect(_on_ws_auction_closed)
	# Vong 74: UI trade / dau gia trong dien thoai — de nghi den,
	# de nghi da gui / bi tu choi / huy, phien mo / dau gia / dong.
	online.ws_trade_offer_received.connect(_on_ws_trade_offer_received)
	online.ws_trade_offered_sent.connect(_on_ws_trade_offered_sent)
	online.ws_trade_declined.connect(_on_ws_trade_declined)
	online.ws_trade_cancelled.connect(_on_ws_trade_cancelled)
	online.ws_trade_error.connect(_on_ws_trade_error)
	online.ws_auction_created.connect(_on_ws_auction_created)
	online.ws_auction_bid.connect(_on_ws_auction_bid)
	# Vong 102: tin rieng khi minh bi vuot gia (ke ca nhan lai
	# luc hello sau khi offline).
	online.ws_auction_outbid.connect(_on_ws_auction_outbid)
	online.ws_auction_list.connect(_on_ws_auction_list)
	online.ws_auction_cancelled.connect(_on_ws_auction_cancelled)
	online.ws_auction_error.connect(_on_ws_auction_error)
	# Vong 76: ack so cai server — so lech thi ap vao vi/tui.
	online.ws_ledger_sync_acked.connect(_on_ws_ledger_sync_acked)
	# Vong 77: ack mua o cho qua server — ap vao vi + owned +
	# Danh vong khi ok (xem _on_ws_shop_buy_acked).
	online.ws_shop_buy_acked.connect(_on_ws_shop_buy_acked)
	# Vong 86: ack ban lai cho cho qua server — ap vao vi +
	# owned khi ok (xem _on_ws_shop_sell_acked).
	online.ws_shop_sell_acked.connect(_on_ws_shop_sell_acked)
	# Vong 80: ack dong bo giu sap — bao khi server tu choi hold
	# (xem _on_ws_stall_hold_synced); ngay game cho server xet han.
	online.ws_stall_hold_synced.connect(_on_ws_stall_hold_synced)
	# Vong 81: ngay server doi thi dong bo lai hold dang giu
	# theo ngay moi (xem _on_ws_server_day_changed).
	online.ws_server_day_changed.connect(_on_ws_server_day_changed)
	online.ws_game_day = day

func _map_by_id(map_id: int) -> Dictionary:
	for m in maps_data["maps"]:
		if int(m["id"]) == map_id:
			return m
	return {}

func load_map(map_id: int, spawn_tile: Vector2i) -> void:
	current_map_id = map_id
	if iso_map != null:
		iso_map.queue_free()
	if player != null:
		player.queue_free()
	iso_map = IsoMap.new()
	add_child(iso_map)
	iso_map.build(_map_by_id(map_id), Marker, font, _label_layer)
	player = Player.new()
	add_child(player)
	player.place(iso_map, spawn_tile)
	player.moved_to.connect(_on_player_moved_to)
	if iso_map.skyfx != null:
		iso_map.skyfx.player = player
	if _camera != null:
		_camera.position = player.position + CAMERA_LOOK_UP
		_camera.reset_smoothing()
	_hud_map.text = "Phố Xô Bồ — " + String(_map_by_id(map_id)["name"])
	_fit_hud_map()
	# Vong 53: lo map hien tai ra window.__pxb_map de script
	# browser-verify xac nhan dung map sau moi chan (bai hoc vong 52:
	# anh lech +1 map ma ten file khong phat hien). Chi tren web.
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.__pxb_map = %d" % map_id)
		# Vong 56: lo them o hien tai cua player ra window.__pxb_tile
		# de script browser-verify lai chinh xac toi cua — giu phim 400ms
		# doi luc di 2 o (bai hoc vong 55) nen dem so phim co dinh
		# khong tin duoc; doc tile that sau moi phim roi tinh lai.
		JavaScriptBridge.eval("window.__pxb_tile = [%d, %d]" % [spawn_tile.x, spawn_tile.y])
	_update_hud()
	_update_ground(map_id)  # Vong 17: Map001 dung dat ve tay rieng.
	_update_daynight()  # Ap khung hien tai cho map moi (anh dem/tint/mat troi).

## Vong 17: nen dat theo map — Map001 dung ground_map001.png ve tay
## (khop mat tien nha ong ve tay); vong 20: Map002 dung
## ground_map002.png ve tay (san cho dau moi); map khac giu
## ground_wide.jpg.
## Ca 3 anh deu 1440x900 nen scale giu nguyen. Neu thieu file (clone
## moi chua co art nhi phan — chi co local + trong pck) thi giu anh cu.
## Vong 62: khung Toi (frame 2) tren Map001-002 doi sang anh dat dem
## rieng ground_map00N_night.png (cung 1440x900, toi + lanh hon,
## den vang sang) neu co file; thieu file thi giu anh ngay + lop MUL
## nhu cu (khong crash). Anh dem da toi san (~0.6) nen sau lop MUL
## dem (0.7,0.78,0.95) dat dat ~0.42 — gan bang anh nen dem
## (0.41 x MUL), khong con dat sang hon troi nhu truoc.
func _night_ground_path(map_id: int) -> String:
	if map_id == 1 and ResourceLoader.exists("res://art/ground_map001_night.png"):
		return "res://art/ground_map001_night.png"
	if map_id == 2 and ResourceLoader.exists("res://art/ground_map002_night.png"):
		return "res://art/ground_map002_night.png"
	return ""

func _update_ground(map_id: int) -> void:
	if _ground_sprite == null:
		return
	if frame_idx == 2:
		var night_path := _night_ground_path(map_id)
		if night_path != "":
			_ground_sprite.texture = load(night_path) as Texture2D
			return
	if map_id == 1 and ResourceLoader.exists("res://art/ground_map001.png"):
		_ground_sprite.texture = load("res://art/ground_map001.png") as Texture2D
	elif map_id == 2 and ResourceLoader.exists("res://art/ground_map002.png"):
		_ground_sprite.texture = load("res://art/ground_map002.png") as Texture2D
	elif ResourceLoader.exists("res://art/ground_wide.jpg"):
		_ground_sprite.texture = load("res://art/ground_wide.jpg") as Texture2D

func _on_player_moved_to(tile: Vector2i) -> void:
	_update_dbg()
	# Vong 56: cap nhat o player ra window.__pxb_tile (xem load_map).
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.__pxb_tile = [%d, %d]" % [tile.x, tile.y])
	_refresh_hotspot_player_flags()
	var ev := iso_map.event_at(tile)
	if not ev.is_empty() and String(ev.get("kind", "")) == "door":
		_transfer(int(ev["to_map"]))

func _transfer(to_map: int) -> void:
	var dest := _map_by_id(to_map)
	if dest.is_empty():
		# G3 port theo tung buoc: cua di khu chua co data (vd Map005 -> Map006)
		# thi bao chu chua crash — nguoi choi dung yen o cua.
		show_toast("Khu này chưa mở trong bản Godot — đang làm (G3).")
		return
	var door_tile := Vector2i(5, 4)
	for e in dest["events"]:
		if String(e.get("kind", "")) == "door":
			door_tile = Vector2i(e["tile"][0], e["tile"][1])
			break  # Cua VE (5,4) la cua dau tien — dung break, neu khong
			# vong lap se lay cua CUOI (5,8) lam diem spawn (loi lo ra khi
			# Map002 co them cua di Map003 o G3 buoc 1).
	load_map(to_map, door_tile)
	show_toast("Đã sang " + String(dest["name"]))

# Ten map dai (vd "Khu Công Nhân", "Phố Đi Bộ – Chợ Đêm") bi cat o mep
# panel 452px khi co 30 (loi 20/11 13:20): co chu nho dan toi khi vua
# long panel (412px = 452 - 2x18 content margin), toi thieu 20.
func _fit_hud_map() -> void:
	var size := 30
	while size > 20:
		var w := font_bold.get_string_size(_hud_map.text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
		if w <= 412.0:
			break
		size -= 2
	_hud_map.add_theme_font_size_override("font_size", size)


# Vong 88: dong chi so phu co 18, vua long panel 412px; neu so
# lon (bonus cong don) lam dong rong qua 412px thi co xuong 16
# (nhu _fit_hud_map) thay vi de tran panel.
func _fit_hud_substats() -> void:
	var size := 18
	while size > 16:
		var w := font.get_string_size(_hud_substats.text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
		if w <= 412.0:
			break
		size -= 2
	_hud_substats.add_theme_font_size_override("font_size", size)

# --- Thoi gian ---
func _process(delta: float) -> void:
	# G4 bước 11: ví chung jobs.gold là nguồn sự thật duy nhất,
	# economy.money chỉ là bản đồng bộ. Trade WS áp tiền vào
	# economy.money lúc poll (cha _process chạy trước con — xem ghi
	# chú vòng 4) nên đồng bộ trước mỗi frame để lúc áp không lấy
	# nhầm số dư cũ (vd vừa làm ca: lương mới chỉ vào jobs.gold).
	# Sau khi áp xong, _on_ws_trade_completed đồng bộ ngược về
	# jobs.gold. Giao dịch mua/bán trong Main vẫn theo cặp
	# _wallet_to_economy/_wallet_from_economy như cũ (đồng bộ trong
	# cùng 1 lượt gọi nên không bị _process chen giữa).
	_wallet_to_economy()
	# Camera bam theo nguoi choi (zoom CAMERA_ZOOM: thay het map luc spawn).
	if _camera != null and player != null:
		_camera.position = player.position + CAMERA_LOOK_UP
	# Vong 10: D-pad chi hien khi dang choi (an khi title / dien
	# thoai / hoi thoai / tran dau mo — tranh de len panel).
	if _dpad != null:
		_dpad.visible = not title_open and not phone_open and not dialogue_open and not battle_open
	if _dbg_label != null:
		# Vong 12: nhan debug mac dinh HIEN (xem _debug_labels_visible).
		# Vong 14: an khi dien thoai/tran mo — nhan o (24,200) de
		# len tieu de "Dien thoai" cua panel (panel y=216) (loi
		# live 21/11 14:55). Sua o day vi _process dat lai
		# visible moi frame (sua trong _open_phone se bi ghi de).
		_dbg_label.visible = not title_open and _debug_labels_visible and not phone_open and not battle_open
	# Vong 11: cap nhat nhan debug MOI FRAME (ke ca khi an) —
	# _update_dbg() truoc day chi goi tu moved_to, ma moved_to chay
	# TRUOC khi queue pop / auto-target clear trong player._process
	# nen A:/Q: cu hien stale sau khi toi dich (vd A:(10,6) mai sau
	# khi da toi (10,6)), lam kiem live 21/11 tuong tap-to-move ket.
	_update_dbg()
	# Chong-chong nhan o khong gian man hinh (vong 4): chay truoc
	# _process cua Marker (cha chay truoc con) nen override kip dung
	# ngay trong frame nay. Cap nhat gan/xa cua nhan NPC truoc
	# resolver (vong 15) de placed co rect NPC dung trang thai moi.
	_update_npc_labels()
	_update_npc_patrol(delta)
	_resolve_label_overlaps()
	# Nut DOM "Bat dau" tren web (web_shell.html): nut HTML dat
	# window.__pxb_start = true; poll 4 lan/giay (khong dung signal
	# vi JavaScriptBridge chi co eval, khong co callback tu JS).
	if title_open and OS.has_feature("web"):
		_js_poll += delta
		if _js_poll > 0.25:
			_js_poll = 0.0
			if JavaScriptBridge.eval("window.__pxb_start === true"):
				_on_start_pressed()
	_frame_timer += delta
	if _frame_timer >= float(PxbBalance.FRAME_MINUTES) * 60.0:
		_frame_timer = 0.0
		_advance_frame()
	if _toast_timer > 0.0:
		_toast_timer -= delta
		if _toast_timer <= 0.0:
			_toast.visible = false

func _advance_frame() -> void:
	frame_idx += 1
	var hold_fame_today := 0
	if frame_idx >= 3:
		frame_idx = 0
		day += 1
		# Vong 80: ngay game moi thi bao cho PxbOnline de cac goi
		# len server (ledger_sync / shop_buy / stall_hold_sync)
		# kem ngay moi nhat, server moi xet han giu sap dung.
		if online != null:
			online.ws_game_day = day
		# G4 buoc 5: sang ngay moi thi don sap tran da het han giu.
		# Vong 95: xet theo ngay neo giu sap — hold neo theo ngay
		# server chi het han khi ngay server qua until, khong theo
		# ngay local (client moi ngay local 1 khong bao gio toi 24).
		PxbMarketBattle.expire_holds(battle_state, _hold_anchor_day())
		# G4 buoc 8: giu sap thi +Danh vong moi ngay game (sau khi
		# expire — sap het han ngay hom nay khong cong nua).
		var ben_day := PxbMarketBattle.hold_benefits(battle_state, "doi-ban", _hold_anchor_day())
		if not ben_day.is_empty():
			hold_fame_today = int(ben_day.get("famePerDay", 0))
			fame += hold_fame_today
		jobs.set_day_number(day)
		education.day_number = day
		social.apply_neglect_all(day)
		if day > 1 and (day - 1) % 30 == 0:
			# Sang thang game moi: lai 0,5% tren so tiet kiem hien co.
			var interest := economy.apply_monthly_interest(30)
			if interest > 0:
				show_toast("Lãi tiết kiệm tháng mới: +%sđ" % _fmt_vnd(interest))
	_update_hud()
	_update_daynight()
	var frame_toast := "Ngày %d • Khung %s" % [day, _frame_name()]
	if hold_fame_today > 0:
		frame_toast += " • Giữ sạp +%d Danh vọng" % hold_fame_today
	show_toast(frame_toast)
	# Tot nghiep / khoa ngan han kiem tra sau toast ngay de toast
	# tot nghiep khong bi toast ngay de mat.
	if frame_idx == 0 and day > 1:
		_check_graduations()


# Kiem tra tot nghiep moi ngay game moi (goi 1 lan/ngay): tot nghiep
# bang chinh cong EXP vao jobs.exp_total + Danh vong vao fame roi xoa
# pending (dung hop dong PxbEducation: event tu ap pending); khoa
# ngan han ap +10 chi so phu qua PxbStats (Vong 87) roi xoa pending.
func _check_graduations() -> void:
	# Vong 98: HUD phai refresh ngay khi tot nghiep — _advance_frame
	# goi _update_hud() TRUOC _check_graduations() nen truoc day Sang
	# van 100 toi khi mo dien thoai moi thay 110 (r97, anh 149/150).
	# Moi thay doi (tot nghiep bang chinh / ap pending chi so phu)
	# deu goi lai _update_hud() o cuoi ham nay.
	var changed := false
	var g := education.check_graduation()
	if bool(g.get("graduated", false)):
		changed = true
		jobs.exp_total += int(g.get("exp", 0))
		fame += int(g.get("fame", 0))
		education.pending_exp = 0
		education.pending_fame = 0
		phonehub.notify(PxbPhoneHub.TAB_HOC_TAP)
		show_toast("Tốt nghiệp %s! +%d EXP, +%d Danh vọng" % [
			String((g.get("degree", {}) as Dictionary).get("name", "")),
			int(g.get("exp", 0)), int(g.get("fame", 0))])
	var sc := education.check_short_course_graduation()
	var applied := _apply_pending_stat_gains()
	if not applied.is_empty():
		changed = true
	if bool(sc.get("graduated", false)):
		changed = true
		phonehub.notify(PxbPhoneHub.TAB_HOC_TAP)
		if not applied.is_empty():
			show_toast("Xong khóa ngắn hạn: " + _format_stat_gains(applied))
		else:
			show_toast("Xong khóa ngắn hạn: +%d %s (chờ áp vào chỉ số phụ)" % [
				int(sc.get("gain", 0)), String(sc.get("sub_stat", ""))])
	if changed:
		_update_hud()


# Vong 87: ap het +chi so phu dang cho (education.pending_stat_gain)
# vao PxbStats roi xoa pending. Goi moi ngay game moi — ca khi khong
# co tot nghiep moi — de save cu (r86 tro ve truoc) con pending cung
# duoc ap o ngay doi dau tien. Muc rac (khoa la / gain <= 0) bi xoa
# luon vi khong bao gio ap duoc; chi muc ap thanh cong moi tra ve.
func _apply_pending_stat_gains() -> Dictionary:
	var applied := {}
	if education == null or stats == null:
		return applied
	for sub in (education.pending_stat_gain.duplicate() as Dictionary):
		var gain := int(education.pending_stat_gain[sub])
		if stats.apply_stat_gain(String(sub), gain):
			applied[String(sub)] = gain
		education.pending_stat_gain.erase(sub)
	return applied


# Dinh dang {chi-so-phu: +gain} thanh "Sáng +10 • Kỷ +10" (theo thu
# tu co dinh ky/dung/sang/an-yen, de toast + tab Hoc tap on dinh).
func _format_stat_gains(applied: Dictionary) -> String:
	var parts: Array[String] = []
	for sub in PxbStats.SUB_STATS:
		if applied.has(sub):
			parts.append("%s +%d" % [String(SUB_STAT_NAMES.get(sub, sub)), int(applied[sub])])
	return " • ".join(parts)

func _unhandled_input(event: InputEvent) -> void:
	if title_open:
		return
	if event is InputEventKey:
		# Di chuyen bang EVENT (vong 7): poll Input trong _process
		# lo phim nhan nhanh o FPS thap; event thi khong lo.
		# physical_keycode truoc (D hoa = Shift+D van la KEY_D vat
		# ly; ban phim khac layout van dung), keycode sau.
		var mdir := _key_to_dir(event)
		if mdir != Vector2i.ZERO and player != null and not battle_open:
			if event.pressed and not event.echo:
				# Vong 10: ghi input cuoi cho nhan debug (kiem chung).
				_last_input = {Vector2i(0, -1): "W", Vector2i(0, 1): "S", Vector2i(-1, 0): "A", Vector2i(1, 0): "D"}.get(mdir, "?")
				player.press_dir(mdir)
				_update_dbg()
			elif not event.pressed:
				player.release_dir(mdir)
			return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_B and not dialogue_open and not phone_open:
			if battle_open:
				_close_battle()
			else:
				_start_battle_demo()
			return
		if battle_open:
			return
		if event.keycode == PxbPhoneHub.PHONE_KEY_CODE:
			if not dialogue_open:
				_toggle_phone()
		elif event.keycode == KEY_F:
			_frame_timer = 0.0
			_advance_frame()
		elif event.keycode == KEY_E:
			_try_interact()
		elif event.keycode == KEY_F9:
			# §29.3: F9 bat/tat nhan debug (mac dinh an). Khong mo
			# tran/dien thoai — chi doi co hien nhan.
			set_debug_labels_visible(not _debug_labels_visible)
		return
	var click_pos := Vector2.INF
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		click_pos = event.position
	elif event is InputEventScreenTouch and event.pressed:
		click_pos = event.position
	if click_pos == Vector2.INF or dialogue_open or phone_open or battle_open or iso_map == null:
		return
	# Doi toa do man hinh -> toa do the gioi (camera zoom/follow).
	var world_pos: Vector2 = get_viewport().get_canvas_transform().affine_inverse() * click_pos
	var tile := iso_map.world_to_tile(world_pos)
	if not iso_map.in_bounds(tile):
		# Vong 14 — cham NGOAI hinh thoi dat (troi/mat tien) truoc
		# day im lang (kiem live 21/11 15:20: (200,750)/(500,700)
		# khong dang ky gi, A van (-1,-1)). Nay kep ve o trong
		# bien gan nhat roi di toi o di duoc gan nhat — cham vao
		# mat tien thi di toi truoc cua hang do; neu khong co o
		# di duoc nao thi toast thay vi im lang.
		var clamped := Vector2i(clampi(tile.x, 0, 11), clampi(tile.y, 0, 8))
		var wt_out := _nearest_walkable(clamped)
		if wt_out != Vector2i(-1, -1):
			_last_input = "chạm (%d,%d)" % [wt_out.x, wt_out.y]
			player.set_auto_target(wt_out)
			_update_dbg()
		else:
			show_toast("Chỗ đó không đi được.")
		return
	var ev := iso_map.event_at(tile)
	if not ev.is_empty() and _tile_dist(tile, player.tile) <= 1:
		_interact(ev)
	else:
		# Tap vao o khong di duoc (tuong bien/mat tien) thi di toi
		# o di duoc GAN NHAT thay vi dung yen (loi live 22:05
		# 20/11: tap dat trong phia phai khong nhuc nhich vi diem
		# cham anh xa toi o bien bi chan).
		var wt := _nearest_walkable(tile)
		if wt != Vector2i(-1, -1):
			_last_input = "chạm (%d,%d)" % [wt.x, wt.y]
			player.set_auto_target(wt)
			_update_dbg()
		else:
			show_toast("Chỗ đó không đi được.")

## Tim o di duoc gan nhat tu t (BFS tren luoi 12x9) — dung cho
## tap-to-move khi diem cham roi vao o bi chan (tuong/mat tien).
func _nearest_walkable(t: Vector2i) -> Vector2i:
	if iso_map.is_walkable(t):
		return t
	var seen := {t: true}
	var frontier: Array[Vector2i] = [t]
	while not frontier.is_empty():
		var nxt: Array[Vector2i] = []
		for c: Vector2i in frontier:
			for d: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var n: Vector2i = c + d
				if seen.has(n) or not iso_map.in_bounds(n):
					continue
				seen[n] = true
				if iso_map.is_walkable(n):
					return n
				nxt.append(n)
		frontier = nxt
	return Vector2i(-1, -1)

func _tile_dist(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)

## Phim di chuyen -> huong o (vong 7): physical_keycode truoc
## (Shift+D van la KEY_D vat ly; mui ten cung co physical), roi
## keycode (phong khi event chi co keycode). Tra ZERO neu khong
## phai phim di chuyen.
func _key_to_dir(event: InputEventKey) -> Vector2i:
	var k := int(event.physical_keycode)
	if k == 0:
		k = int(event.keycode)
	match k:
		KEY_W, KEY_UP:
			return Vector2i(0, -1)
		KEY_S, KEY_DOWN:
			return Vector2i(0, 1)
		KEY_A, KEY_LEFT:
			return Vector2i(-1, 0)
		KEY_D, KEY_RIGHT:
			return Vector2i(1, 0)
	return Vector2i.ZERO

func _try_interact() -> void:
	if dialogue_open or iso_map == null:
		return
	var best := {}
	var best_d := 99
	for d in [Vector2i.ZERO, Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]:
		var ev := iso_map.event_at(player.tile + d)
		if not ev.is_empty() and d.length() < best_d:
			best = ev
			best_d = d.length()
	if best.is_empty():
		return
	_interact(best)

func _interact(ev: Dictionary) -> void:
	match String(ev.get("kind", "")):
		"npc":
			var choices: Array = [
				["Hỏi gợi ý", func() -> void: show_dialogue(String(ev["name"]), String(ev["hint"]), [["Đóng", close_dialogue]])],
				["Tạm biệt", close_dialogue],
			]
			# Co Tu day che Xe Day, Anh Hai day che Den Soi — dung unlock
			# note cua PxbBalance.RECIPES, khong tu dat luat hoc moi.
			if String(ev.get("id", "")) == "co-tu" and not crafting.has_learned("che-xe-day"):
				choices.insert(1, ["Nhờ Cô Tư dạy chế Xe Đẩy", func() -> void: _learn_recipe("che-xe-day")])
			if String(ev.get("id", "")) == "anh-hai" and not crafting.has_learned("che-den-soi"):
				choices.insert(1, ["Nhờ Anh Hải dạy chế Đèn Soi", func() -> void: _learn_recipe("che-den-soi")])
			show_dialogue(String(ev["name"]), String(ev["greet"]), choices)
		"hotspot":
			_collect_hotspot(ev)
		"craft":
			_show_craft_dialogue(ev)
		"door":
			_transfer(int(ev["to_map"]))


func _frame_name() -> String:
	return PxbTime.frame_name(float(frame_idx) * float(PxbBalance.FRAME_MINUTES))


func _learn_recipe(recipe_id: String) -> void:
	if crafting.learn_recipe(recipe_id):
		var r := PxbCrafting.get_recipe(recipe_id)
		show_toast("Đã học công thức: %s!" % String(r.get("name", recipe_id)))
	else:
		show_toast("Không học được công thức này.")
	close_dialogue()


func _recipe_id_for_craft_name(craft_name: String) -> String:
	return String(CRAFT_RECIPE_BY_NAME.get(craft_name, ""))


func _needs_text(recipe: Dictionary) -> String:
	var parts: Array[String] = []
	for mat in (recipe.get("needs", {}) as Dictionary).keys():
		var have := int(inventory.get(String(mat), 0))
		var need := int((recipe["needs"] as Dictionary)[mat])
		parts.append("%s %d/%d" % [String(MATERIAL_NAMES.get(String(mat), String(mat))), have, need])
	return " • ".join(parts)


func _show_craft_dialogue(ev: Dictionary) -> void:
	var recipe_id := _recipe_id_for_craft_name(String(ev["recipe"]))
	if recipe_id == "":
		show_dialogue(String(ev["name"]),
			"Chế %s ở đây. Cần: %s. (Chưa có công thức này trong Balance.)" % [String(ev["recipe"]), String(ev["needs"])],
			[["Đóng", close_dialogue]])
		return
	var recipe := PxbCrafting.get_recipe(recipe_id)
	var learned := crafting.has_learned(recipe_id)
	var text := "%s\nCần: %s" % [String(recipe.get("name", "")), _needs_text(recipe)]
	if not learned:
		text += "\nChưa học công thức — %s" % String(recipe.get("unlock", ""))
	show_dialogue(String(ev["name"]), text, [
		["Chế tạo", func() -> void: craft_recipe(recipe_id)],
		["Đóng", close_dialogue],
	])


# Che 1 mon theo cong thuc; tra Dictionary ket qua cua
# PxbCrafting.craft_current() de test goi truc tiep duoc.
func craft_recipe(recipe_id: String) -> Dictionary:
	var res := crafting.craft_current(recipe_id)
	if bool(res.get("ok", false)):
		_update_hud()
		show_toast("Chế xong %s!" % String(res.get("result_name", recipe_id)))
	else:
		match String(res.get("reason", "")):
			"chua-hoc-cong-thuc":
				show_toast("Chưa học công thức — %s" % String(res.get("unlock_note", "")))
			"thieu-nguyen-lieu":
				var miss: Array[String] = []
				for mat in (res.get("missing", {}) as Dictionary).keys():
					miss.append("%s ×%d" % [String(MATERIAL_NAMES.get(String(mat), String(mat))), int((res["missing"] as Dictionary)[mat])])
				show_toast("Thiếu nguyên liệu: %s" % " • ".join(miss))
			"khong-co-cong-thuc":
				show_toast("Không có công thức này.")
			_:
				show_toast("Không chế được.")
	close_dialogue()
	return res


# Lam 1 ca nghe job_id o khung hien tai; tra Dictionary ket qua cua
# PxbJobs.work_shift() de test goi truc tiep duoc.
func work_job(job_id: String) -> Dictionary:
	var res := jobs.work_shift(job_id, _frame_name(), stats)
	if bool(res.get("ok", false)):
		_update_hud()
		var job := PxbJobs.get_job(job_id)
		show_toast("Làm ca %s: +%sđ (còn %d ca/tuần)" % [
			String(job.get("name", job_id)), _fmt_vnd(int(res.get("pay", 0))),
			int(res.get("shifts_left", 0))])
	else:
		match String(res.get("reason", "")):
			"het-quota":
				show_toast("Hết quota tuần của nghề này (14 ca/tuần).")
			"khong-co-nghe":
				show_toast("Không có nghề này.")
			_:
				show_toast("Không làm được ca này.")
	close_dialogue()
	return res


func _show_jobs_dialogue() -> void:
	var lines: Array[String] = []
	for job in PxbBalance.JOBS:
		var j := job as Dictionary
		var jid := String(j["id"])
		var pay := PxbJobs.pay_per_shift(jid, stats, _frame_name(), jobs.get_demand(jid))
		lines.append("%s — %sđ/ca (khung tốt: %s, còn %d ca/tuần)" % [
			String(j["name"]), _fmt_vnd(pay), String(j["good_frame"]),
			jobs.shifts_left(jid)])
	show_dialogue("Việc làm", "\n".join(lines), [
		["Bán rong", func() -> void: work_job("ban-rong")],
		["Shipper", func() -> void: work_job("shipper")],
		["Nhân viên quán", func() -> void: work_job("nhan-vien-quan")],
		["Đóng", close_dialogue],
	])


func _collect_hotspot(ev: Dictionary) -> void:
	var res := hotspot.explore(String(ev["id"]), day, _frame_name())
	if bool(res.get("ok", false)):
		_update_hud()
		show_toast("Nhặt được %s ×%d!" % [
			String(MATERIAL_NAMES.get(String(res.get("material_id", "")), String(res.get("material_id", "")))),
			int(res.get("amount", 0))])
		return
	match String(res.get("reason", "")):
		"already":
			show_toast("%s: đã nhặt hôm nay rồi." % String(ev["name"]))
		"wrong-frame":
			var want := String(ev["best_frame"])
			show_toast("%s: chỉ có đồ vào khung %s — giờ đang %s." % [String(ev["name"]), want, _frame_name()])
		"unknown":
			show_toast("%s: hotspot này chưa có trong bảng slice." % String(ev["name"]))
		_:
			show_toast("%s: không nhặt được." % String(ev["name"]))

# --- G2 UI wiring phan 2: vi chung, dien thoai, cho, hoc, save ---

# Vi chung: jobs.gold la nguon su that duy nhat. Truoc moi giao dich
# dung economy (mua / gui / rut) thi dong bo tien vao economy.money;
# xong thi dong bo nguoc ve jobs.gold + cap nhat HUD.
func _wallet_to_economy() -> void:
	economy.money = jobs.gold


func _wallet_from_economy() -> void:
	jobs.gold = economy.money
	_update_hud()


# --- Dien thoai (PxbPhoneHub: 9 tab, mo bang phim P / nut) ---

## --- Tran Bui Doi Cho Ca (G4 §4, demo 3v3) ---
## Mo scene tran tren CanvasLayer rieng (layer 2, tren HUD), khoa
## input map + an HUD trong luc danh; dong thi tra lai nhu cu.
## Doi ban: 3 dau si theo chi so nguoi choi (Do/Xanh/Vang); doi cho:
## seed NPC; tranh sap "sap-cho-dau-moi", doi cho dang giu sap (B thu).
func _start_battle_demo() -> void:
	if battle_open:
		return
	battle_mb = PxbMarketBattle.new()
	add_child(battle_mb)
	# G4 buoc 5: khoi phuc giu sap + lich su tu save truoc (neu co),
	# don sap het han theo ngay neo giu sap truoc khi nap vao tran
	# (vong 95: ngay server khi dang noi — hold cu [1,8) het han
	# theo ngay server thi don, khong chan tran moi).
	PxbMarketBattle.expire_holds(battle_state, _hold_anchor_day())
	battle_mb.from_data(battle_state)
	_battle_saved = false
	# G4 buoc 9 (vong 68): kiem tra can_challenge TRUOC khi mo tran —
	# doi dang giu sap thi khong mo tran tranh sap moi; bao bang tieng
	# Viet, khong mo tran (create_battle ben duoi cung chan lai).
	# Vong 95: chan theo ngay neo giu sap (cung moc voi hold).
	var chk: Dictionary = battle_mb.can_challenge_now("doi-ban", "sap-cho-dau-moi", _hold_anchor_day())
	if not bool(chk.get("ok", false)):
		show_toast(_battle_block_text(str(chk.get("reason", "")), str(chk.get("holdingStallId", ""))))
		battle_mb.queue_free()
		battle_mb = null
		return
	var team_a := {"id": "doi-ban", "name": "Đội Bạn", "fighters": [
		PxbMarketBattle.create_fighter("ban-1", "Bạn", "Do", "Chao",
			{"the": 80, "tri": 40, "tam": 50}, []),
		PxbMarketBattle.create_fighter("ban-2", "Bạn Thân", "Xanh", "CaKho",
			{"the": 40, "tri": 80, "tam": 50}, []),
		PxbMarketBattle.create_fighter("ban-3", "Cô Tư", "Vang", "Loa",
			{"the": 40, "tri": 50, "tam": 80}, []),
	]}
	var team_b: Dictionary = PxbMarketBattle.seed_npc_team("doi-cho", "Đội Chợ Đầu Mối", 3)
	var res: Dictionary = battle_mb.create_battle({
		"teamA": team_a, "teamB": team_b,
		"stallId": "sap-cho-dau-moi", "gameDay": day, "defenderTeam": "B",
	})
	if not bool(res.get("ok", false)):
		show_toast(_battle_block_text(str(res.get("reason", "")), str(res.get("holdingStallId", ""))))
		battle_mb.queue_free()
		battle_mb = null
		return
	battle_mb.set_current_battle(res["battle"])
	var layer := CanvasLayer.new()
	layer.layer = 2
	add_child(layer)
	_battle_layer = layer
	battle_scene = BattleScene.new()
	layer.add_child(battle_scene)
	battle_scene.setup(battle_mb, res["battle"], font, font_bold)
	# G4 bước 2: đội Chợ (B) do AI cầm — tự di chuyển/đánh/hỗ trợ.
	battle_scene.ai_enabled = true
	battle_scene.close_requested.connect(_close_battle)
	# G4 buoc 5: tran xong -> ghi giu sap + Danh vong vao save.
	battle_scene.battle_finished.connect(_on_battle_finished)
	battle_open = true
	if player != null:
		player.input_blocked = true
	_ui_layer.visible = false


## G4 buoc 5: tran ket thuc -> ghi giu sap + lich su vao battle_state
## (di theo save slot), cong Danh vong doi ban (thang +50 / hoa +20 /
## thua +10 — dung luat PxbMarketBattle) vao fame. Chi ap 1 lan/tran.
func _on_battle_finished(_winner: String) -> void:
	if battle_mb == null or _battle_saved:
		return
	_battle_saved = true
	battle_state = battle_mb.data()
	var fame_gain := 0
	var hold: Dictionary = {}
	if battle_scene != null:
		var result: Dictionary = battle_scene.battle.get("result", {})
		var rewards: Dictionary = result.get("rewards", {})
		var team_a: Dictionary = rewards.get("teamA", {})
		fame_gain = int(team_a.get("famePerFighter", 0))
		hold = battle_scene.battle.get("hold", {})
	# Vong 95: thang tran khi dang noi server thi neo cua so hold
	# theo ngay server (start=server_day, until=server_day+7) thay
	# vi ngay local — neu khong server tu choi vi cua so [1,8) da
	# het han theo ngay cua no (xem §115.3). Chi neo khi dang noi
	# + da biet ngay server; choi offline giu nguyen ngay local.
	# Ghi de ca 2 cho: battle_state (di theo save) + battle cua
	# scene (toast ben duoi doc until moi).
	if not hold.is_empty() and str(hold.get("teamId", "")) == "doi-ban" \
			and online != null and online.is_ws_connected() and online.ws_server_day > 0:
		var anchored: Dictionary = PxbMarketBattle.reanchor_hold_window(hold, online.ws_server_day)
		if not anchored.is_empty():
			hold = anchored
			battle_scene.battle["hold"] = anchored
			PxbMarketBattle.apply_hold_win(battle_state, anchored)
			# Vong 99: scene da chup _last_action = result_text() voi
			# cua so local TRUOC khi neo — dong bo lai cho khop ngay
			# server (panel duoi khong lech panel giua).
			battle_scene.refresh_last_action()
	if fame_gain > 0:
		fame += fame_gain
		_update_hud()
	var msg := "Trận kết thúc — Danh vọng +%d." % fame_gain
	if not hold.is_empty() and str(hold.get("teamId", "")) == "doi-ban":
		msg += " Giữ sạp %s đến ngày %d." % [str(hold.get("stallId", "")), int(hold.get("untilGameDay", 0))]
	show_toast(msg)
	# Vong 80: thang tran tranh sap thi dong bo hold len server
	# ngay (server moi validate gia si / phi dau gia duoc).
	_sync_hold_to_server()


func _close_battle() -> void:
	if battle_scene != null:
		battle_scene.queue_free()
		battle_scene = null
	if _battle_layer != null:
		_battle_layer.queue_free()
		_battle_layer = null
	if battle_mb != null:
		battle_mb.queue_free()
		battle_mb = null
	battle_open = false
	# Vòng 92: xóa cầu nối trận để script browser-verify không đọc
	# nhầm trạng thái trận cũ sau khi đóng (mở trận mới mà bị chặn
	# thì bridge vẫn null — phân biệt được với trận đang mở).
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.__pxb_battle = null")
	if player != null:
		player.input_blocked = false
	_ui_layer.visible = true


func _toggle_phone() -> void:
	if phonehub.is_open:
		_close_phone()
	else:
		_open_phone(phonehub.current_tab)


func _open_phone(tab_id: String = "") -> void:
	phonehub.open(tab_id if tab_id != "" else PxbPhoneHub.DEFAULT_TAB)
	phone_open = true
	if player != null:
		player.input_blocked = true
	_phone_dim.visible = true
	_phone_panel.visible = true
	_phone_notch.visible = true
	_phone_homebar.visible = true
	# Toast doi khung (y=200) de len tieu de "Dien thoai" cua panel
	# (panel y=190) neu mo dien thoai ngay sau khi doi khung — an
	# toast khi mo dien thoai (loi 20/11 12:30).
	_toast.visible = false
	_refresh_phone()
	_update_hud()


func _close_phone() -> void:
	phonehub.close()
	phone_open = false
	if player != null:
		player.input_blocked = false
	_phone_dim.visible = false
	_phone_panel.visible = false
	_phone_notch.visible = false
	_phone_homebar.visible = false
	_update_hud()


func _phone_action(text: String, call: Callable) -> void:
	var b := Button.new()
	b.text = text
	_style_button(b, 24)
	b.custom_minimum_size = Vector2(580, 56)
	b.pressed.connect(call)
	_phone_actions.add_child(b)


func _clear_phone_actions() -> void:
	for c in _phone_actions.get_children():
		c.queue_free()


func _refresh_phone() -> void:
	if not phone_open:
		return
	for tab_id in _phone_tab_buttons:
		var unread := phonehub.unread_count(String(tab_id))
		var base := PxbPhoneHub.tab_name(String(tab_id))
		(_phone_tab_buttons[tab_id] as Button).text = \
			("%s (%d)" % [base, unread]) if unread > 0 else base
	_phone_title.text = "Điện thoại — " + PxbPhoneHub.tab_name(phonehub.current_tab)
	_phone_footer.text = "Ngày %d • Ví %sđ • Danh vọng %d • Chương %d" % [
		day, _fmt_vnd(jobs.gold), fame, story.chapter]
	var sl := _story_text().split("\n")
	_phone_hint.text = "Tiến trình — %s\n%s" % [sl[0], sl[2]] if sl.size() > 2 else "Tiến trình — " + sl[0]
	_phone_tip.text = "Mẹo: " + String(PHONE_TIPS[day % PHONE_TIPS.size()])
	_phone_today.text = _today_text()
	_clear_phone_actions()
	match phonehub.current_tab:
		PxbPhoneHub.TAB_DANH_BA_TIN_NHAN:
			_phone_content.text = _social_text() + "\n\n" + online.ws_phone_text()
			for rel in social.all_relations():
				var pid := String((rel as Dictionary).get("person_id", ""))
				var label := "Trò chuyện: %s" % String((rel as Dictionary).get("display_name", pid))
				_phone_action(label, _on_interact_pressed.bind(pid))
			# G4 buoc 7: chat online qua server Godot (WS) — nut
			# noi/ngat + o nhap + nut gui, nam trong tab Tin nhan.
			if online.is_ws_connected():
				_phone_chat_input = LineEdit.new()
				_phone_chat_input.placeholder_text = "Nhắn chat online…"
				_phone_chat_input.custom_minimum_size = Vector2(580, 56)
				_phone_chat_input.max_length = PxbOnline.WS_MAX_CHAT_LEN
				_phone_actions.add_child(_phone_chat_input)
				_phone_action("Gửi chat", _on_ws_send_pressed)
				_phone_action("Ngắt kết nối chat", _on_ws_disconnect_pressed)
			else:
				_phone_chat_input = null
				_phone_action("Kết nối chat online (server local)", _on_ws_connect_pressed)
			# Vong 74: UI doi do — de nghi den (chap nhan/tu choi),
			# de nghi da gui (huy), nut gui de nghi cho tung nguoi
			# online. Chi khi da noi WS; chua noi thi chi co nut
			# ket noi chat o tren. De nghi hien ca trong noi dung
			# (de doc lai) lan tren nut (de bam).
			if online.is_ws_connected():
				if not online.ws_trade_offers.is_empty() or not online.ws_my_offers.is_empty():
					var olines: Array[String] = ["", "Đề nghị đổi đồ:"]
					for offer in online.ws_trade_offers:
						olines.append("• Đến: " + _trade_offer_text(offer as Dictionary))
					for sent in online.ws_my_offers:
						olines.append("• Đã gửi: " + _trade_offer_text(sent as Dictionary))
					_phone_content.text += "\n".join(olines)
				for offer in online.ws_trade_offers:
					var od := offer as Dictionary
					_phone_action("Chấp nhận: " + _trade_offer_text(od),
						_on_ws_trade_accept_pressed.bind(String(od.get("trade_id", ""))))
					_phone_action("Từ chối: " + _trade_offer_text(od),
						_on_ws_trade_decline_pressed.bind(String(od.get("trade_id", ""))))
				for sent in online.ws_my_offers:
					var sd := sent as Dictionary
					_phone_action("Hủy đề nghị: " + _trade_offer_text(sd),
						_on_ws_trade_cancel_pressed.bind(String(sd.get("trade_id", ""))))
				# Vong 75: o nhap so tien muon lay khi doi do (mac
				# dinh 100.000d; go sai thi handler dung mac dinh).
				_phone_trade_money_input = _phone_number_input(
					"Số tiền muốn lấy khi đổi đồ (đ) — mặc định 100.000",
					_trade_want_money_vnd)
				for p in online.ws_players:
					var pd := p as Dictionary
					var pid := String(pd.get("player_id", ""))
					if pid.is_empty() or pid == online.ws_player_id:
						continue
					_phone_action("Đổi đồ với %s" % _ws_player_name(pid),
						_on_ws_trade_offer_pressed.bind(pid))
		PxbPhoneHub.TAB_NGAN_HANG:
			_wallet_to_economy()
			_phone_content.text = "Tiền mặt: %sđ\nTiết kiệm: %sđ (lãi 0,5%%/tháng game)\nĐiểm tín dụng: %d" % [
				_fmt_vnd(economy.money), _fmt_vnd(economy.savings), economy.credit_score]
			_phone_action("Gửi tiết kiệm 100.000đ", _on_deposit_pressed.bind(100000))
			_phone_action("Rút tiết kiệm 100.000đ", _on_withdraw_pressed.bind(100000))
		PxbPhoneHub.TAB_BAN_DO:
			var lines: Array[String] = ["Khu đã mở (chạm để đi nhanh):"]
			for m in maps_data["maps"]:
				var mid := int((m as Dictionary)["id"])
				if hotspot.can_fast_travel(mid):
					lines.append("• %s" % String((m as Dictionary)["name"]))
					_phone_action("Về %s" % String((m as Dictionary)["name"]), _on_travel_pressed.bind(mid))
			_phone_content.text = "\n".join(lines)
		PxbPhoneHub.TAB_VIEC_LAM:
			_phone_content.text = _jobs_text() + "\n\n" + _tools_text()
			_phone_action("Mở bảng việc làm", _on_open_jobs_pressed)
			for tool_id in PxbTools.TOOL_IDS:
				var tier := tools.tool_tier(String(tool_id))
				if tier == 0 and (String(tool_id) == "SoTay" or String(tool_id) == "Xeng"):
					_phone_action("Nhận %s (bậc 1)" % PxbTools.tool_name(String(tool_id)),
						_on_tool_acquire_pressed.bind(String(tool_id)))
				elif tier >= 1 and tier < 3:
					_phone_action("Nâng %s lên bậc %d" % [
						PxbTools.tool_name(String(tool_id)), tier + 1],
						_on_tool_upgrade_pressed.bind(String(tool_id)))
		PxbPhoneHub.TAB_CHO:
			_phone_content.text = "Chợ — mua bằng ví (tiền mặt %sđ).\nĐã sở hữu: %s" % [
				_fmt_vnd(jobs.gold), _owned_text()]
			# Vong 74: UI dau gia — danh sach phien trong noi dung
			# (ws_auctions_text, ke ca khi chua noi — bao ngoai
			# tuyen) + nut dat gia / mo phien / huy phien / lam
			# moi. Chi khi da noi WS.
			_phone_content.text += "\n\n" + online.ws_auctions_text()
			# Vong 77: dang cho server xac nhan 1 lan mua thi an
			# nut mua (chi 1 lan cho — tranh xep hang ack lech
			# so) + bao ro dang cho, khong de bam mua chong.
			if not _pending_shop_buy.is_empty():
				_phone_content.text += "\n\nĐang chờ máy chủ xác nhận mua hàng…"
			else:
				for it in _cheapest_shop_items(4):
					var iid := String((it as Dictionary)["id"])
					_phone_action("Mua %s — %sđ" % [
						String((it as Dictionary)["name"]), _fmt_vnd(int((it as Dictionary)["price_vnd"]))],
						_on_buy_pressed.bind(iid))
			# Vong 86: nut ban lai cho mon dang so huu (nhan 50%
			# gia catalog); dang cho server xac nhan 1 lan ban thi
			# an nut ban + bao ro, khong de bam ban chong.
			if not _pending_shop_sell.is_empty():
				_phone_content.text += "\n\nĐang chờ máy chủ xác nhận bán hàng…"
			else:
				for it in _sellable_owned_items(4):
					var iid := String((it as Dictionary)["id"])
					_phone_action("Bán %s — nhận %sđ" % [
						String((it as Dictionary)["name"]),
						_fmt_vnd(PxbEconomy.shop_sellback_price(int((it as Dictionary)["price_vnd"])))],
						_on_sell_pressed.bind(iid))
			if online.is_ws_connected():
				# Vong 75: o nhap gia dau (de trong = gia tiep theo).
				_phone_bid_input = _phone_number_input(
					"Giá đấu của bạn (đ) — để trống = giá tiếp theo",
					_bid_amount_vnd)
				for a in online.ws_auctions:
					var ad := a as Dictionary
					var aid := String(ad.get("auction_id", ""))
					var iname := _trade_item_name(String(ad.get("item_id", "")))
					if iname.is_empty():
						iname = String(ad.get("item_id", "?"))
					if String(ad.get("seller_player_id", "")) == online.ws_player_id:
						if int(ad.get("current_bid", 0)) == 0:
							_phone_action("Hủy phiên: %s" % iname,
								_on_ws_auction_cancel_pressed.bind(aid))
					else:
						_phone_action("Đặt giá %sđ: %s" % [
							_fmt_vnd(_ws_auction_next_bid(ad)), iname],
							_on_ws_auction_bid_pressed.bind(aid))
				if not _has_my_auction_open():
					# Vong 75: o nhap gia khoi diem + thoi gian phien.
					_phone_auction_price_input = _phone_number_input(
						"Giá khởi điểm (đ) — mặc định 100.000",
						_auction_start_price_vnd)
					_phone_auction_duration_input = _phone_number_input(
						"Thời gian phiên (giây, 30–3600) — mặc định 60",
						_auction_duration_s)
					var first_name := _first_owned_item_name()
					if first_name.is_empty():
						_phone_action("Mở phiên đấu giá", _on_ws_auction_create_pressed)
					else:
						_phone_action("Mở phiên: bán %s — %sđ, %d giây" % [
							first_name, _fmt_vnd(_auction_start_price_vnd),
							_auction_duration_s],
							_on_ws_auction_create_pressed)
				_phone_action("Làm mới danh sách đấu giá", _on_ws_auction_list_pressed)
		PxbPhoneHub.TAB_HOC_TAP:
			_phone_content.text = _education_text()
			for i in PxbEducation.degree_list().size():
				var d := PxbEducation.get_degree(i)
				_phone_action("Đăng ký %s — %sđ, %d ngày" % [
					String(d["name"]), _fmt_vnd(int(d["fee_vnd"])), int(d["days"])],
					_on_enroll_pressed.bind(i))
			_phone_action("Khóa ngắn: Sáng tạo 3 ngày — 2.000.000đ",
				_on_enroll_short_pressed)
		PxbPhoneHub.TAB_SUC_KHOE:
			_phone_content.text = "Thể %d • Trí %d • Tâm %d (tổng %d, trần %d)\nLuyện tập đổi chỉ số (tổng không đổi):" % [
				stats.the, stats.tri, stats.tam, stats.total(), PxbBalance.TOTAL_STAT_CAP]
			_phone_action("Luyện Thể +5 (Trí −5)", _on_train_pressed.bind(["the", "tri"]))
			_phone_action("Luyện Trí +5 (Thể −5)", _on_train_pressed.bind(["tri", "the"]))
			_phone_action("Luyện Tâm +5 (Thể −5)", _on_train_pressed.bind(["tam", "the"]))
		PxbPhoneHub.TAB_XA_HOI:
			_phone_content.text = _story_text()
			_phone_action("Lên chương tiếp", _on_advance_chapter_pressed)
			if titles.can_redeem():
				_phone_action("Đổi phe: bỏ danh hiệu phe Tà", _on_redeem_pressed)
		PxbPhoneHub.TAB_CAI_DAT:
			_phone_content.text = "Cài đặt — %s" % _online_text()
			for slot in [1, 2, 3]:
				_phone_action("Lưu vào slot %d" % slot, _on_save_pressed.bind(slot))
				_phone_action("Tải slot %d" % slot, _on_load_pressed.bind(slot))
			_phone_action("Kiểm tra mạng (server local)", _on_check_online_pressed)
			_phone_action("Đồng bộ slot 1 lên server", _on_upload_pressed.bind(1))
		_:
			_phone_content.text = "Tab này chưa có nội dung."
	# Chieu cao vung nut theo so nut that (toi da 240): nut it thi
	# vung thu lai, goi y + chan trang noi ngay sau — khong de khoang
	# trong 140-180px nhu truoc (loi 20/11 12:30).
	var n_act := _phone_actions.get_child_count() + 1  # + nut Dong.
	_phone_act_scroll.custom_minimum_size = Vector2(580, clampi(64 * n_act - 8, 64, 240))
	_phone_action("Đóng điện thoại", _close_phone)


func _today_text() -> String:
	# Khoi "Hom nay" trong dien thoai: thong tin that cua khu dang
	# dung + muc tieu truyen — lap khoang trong giua nut bam va khoi
	# Tien trinh (loi 20/11 12:30).
	var npcs := 0
	var total := 0
	if iso_map != null:
		for mk in iso_map.markers:
			total += 1
			if String(mk.event_data.get("kind", "")) == "npc":
				npcs += 1
	var sl := _story_text().split("\n")
	var goal := sl[0] if not sl.is_empty() else ""
	return "Hôm nay — Ngày %d • Khung %s • %s: %d người, %d điểm tương tác\n%s" % [
		day, _frame_name(), String(_map_by_id(current_map_id).get("name", "")), npcs, total, goal]

func _social_text() -> String:
	var lines: Array[String] = ["Danh bạ — trò chuyện tăng thân thiết (+5/lần). Chưa quen thì nói ở ngoài đời:"]
	# Vong 88: 4 chi so phu len DAU tab (kem bonus khoa ngan han)
	# — de o cuoi danh ba 38 dong thi nguoi choi phai cuon het
	# moi thay (§109.6 muc 4: thay duoc ket qua khoa hoc ngay).
	lines.append("Chỉ số phụ — Kỷ %d • Dũng %d • Sáng %d • An Yên %d" % [
		stats.ky(), stats.dung(), stats.sang(), stats.an_yen()])
	if not stats.stat_bonus.is_empty():
		lines.append("Bonus khóa ngắn hạn: " + _format_stat_gains(stats.stat_bonus))
	var known: Dictionary = {}
	for rel in social.all_relations():
		var r := rel as Dictionary
		known[String(r.get("person_id", ""))] = true
		var kind_name := String(KIND_NAMES.get(String(r.get("kind", "")), String(r.get("kind", ""))))
		var name := String(r.get("display_name", ""))
		# Bo lap "Bạn thân — Bạn thân": ten hien thi trung ten loai
		# quan he thi chi in 1 lan (loi 20/11 11:40).
		if name == kind_name:
			lines.append("• %s, thân thiết %d/100 (%s)" % [
				name,
				int(r.get("closeness", 0)),
				String(STAGE_NAMES.get(String(r.get("stage", "")), String(r.get("stage", ""))))])
		else:
			lines.append("• %s — %s, thân thiết %d/100 (%s)" % [
				name,
				kind_name,
				int(r.get("closeness", 0)),
				String(STAGE_NAMES.get(String(r.get("stage", "")), String(r.get("stage", ""))))])
	# Lap khoang trong 1/3 bang: liet ke ca NPC chua quen (toan bo
	# 18 khu) — nguoi choi thay ngay ai co the lam quen.
	var seen_npc: Dictionary = {}
	for m in maps_data["maps"]:
		for e in (m as Dictionary).get("events", []):
			var ev := e as Dictionary
			if String(ev.get("kind", "")) != "npc":
				continue
			var pid := String(ev.get("id", ""))
			if pid == "" or seen_npc.has(pid) or known.has(pid):
				continue
			seen_npc[pid] = true
			# Gon 1 dong (ten NPC dai nhat 20 ky tu + "— chưa quen"
			# = 34 ky tu, vua 1 dong 620px): khong go xuong 2 dong
			# nua — dong 2 bi cat o mep duoi viewport la loi "Chi
			# Le" 20/11 13:53/14:15. Goi y noi chuyen chuyen len
			# dong tieu de.
			lines.append("• %s — chưa quen" % String(ev.get("name", pid)))
	if social.all_relations().is_empty() and seen_npc.is_empty():
		lines.append("(chưa có quan hệ nào)")
	# Dong trong cuoi: khi cuon het xuong, dong that cuoi khong bi
	# cat doi o mep duoi viewport (loi "Chi Le" 20/11 13:53).
	return "\n".join(lines) + "\n "


func _jobs_text() -> String:
	var lines: Array[String] = ["Việc làm — lương ca hiện tại:"]
	for job in PxbBalance.JOBS:
		var j := job as Dictionary
		var jid := String(j["id"])
		lines.append("• %s: %sđ/ca (còn %d ca/tuần)" % [
			String(j["name"]),
			_fmt_vnd(PxbJobs.pay_per_shift(jid, stats, _frame_name(), jobs.get_demand(jid))),
			jobs.shifts_left(jid)])
	return "\n".join(lines)


func _tools_text() -> String:
	var lines: Array[String] = ["Công cụ:"]
	for tool_id in PxbTools.TOOL_IDS:
		var tier := tools.tool_tier(String(tool_id))
		lines.append("• %s: %s" % [PxbTools.tool_name(String(tool_id)),
			("chưa có" if tier == 0 else "bậc %d (%s)" % [tier, String(PxbTools.TIER_NAMES[tier])])])
		if tier >= 1:
			lines.append("  %s" % tools.tool_behaviour_current(String(tool_id)))
	return "\n".join(lines)


func _owned_text() -> String:
	if economy.owned.is_empty():
		return "chưa có"
	var names: Array[String] = []
	for oid in economy.owned:
		var it := PxbEconomy.get_item(String(oid))
		names.append(String(it.get("name", oid)) if not it.is_empty() else String(oid))
	return " • ".join(names)


func _cheapest_shop_items(count: int) -> Array:
	var all: Array = []
	for group in [PxbEconomy.houses(), PxbEconomy.cars(), PxbEconomy.phones(), PxbEconomy.clothes()]:
		all.append_array(group)
	all.sort_custom(func(a, b) -> bool: return int(a["price_vnd"]) < int(b["price_vnd"]))
	return all.slice(0, mini(count, all.size()))


# Mon dang so huu ban lai duoc (vong 86): co trong catalog +
# khong phai phong tro (thue thang, khong ban lai duoc), sap theo
# gia tang dan de nut ban hien mon re truoc nhu nut mua.
func _sellable_owned_items(count: int) -> Array:
	var all: Array = []
	for group in [PxbEconomy.houses(), PxbEconomy.cars(), PxbEconomy.phones(), PxbEconomy.clothes()]:
		for it in group:
			var iid := String((it as Dictionary)["id"])
			if iid != "phong-tro" and economy.owned.has(iid):
				all.append(it)
	all.sort_custom(func(a, b) -> bool: return int(a["price_vnd"]) < int(b["price_vnd"]))
	return all.slice(0, mini(count, all.size()))


func _education_text() -> String:
	var lines: Array[String] = ["Học tập — 5 bậc (học phí trả 1 lần lúc đăng ký):"]
	for i in PxbEducation.degree_list().size():
		var d := PxbEducation.get_degree(i)
		var owned := "✓ đã có" if education.has_degree_or_higher(i) else ""
		lines.append("• %s: %sđ, %d ngày, Trí ≥ %d, +%d EXP %s" % [
			String(d["name"]), _fmt_vnd(int(d["fee_vnd"])), int(d["days"]),
			int(d["tri"]), int(d["exp"]), owned])
	var prog := education.study_progress()
	if not (prog["enrolled"] as Dictionary).is_empty():
		var e := prog["enrolled"] as Dictionary
		lines.append("Đang học: %s, còn %d ngày (tốt nghiệp ngày %d)" % [
			String(PxbEducation.get_degree(int(e["degree_index"]))["name"]),
			int(prog["days_left"]), int(e["end_day"])])
	if education.pending_exp > 0 or education.pending_fame > 0:
		lines.append("Chờ nhận: +%d EXP, +%d Danh vọng" % [education.pending_exp, education.pending_fame])
	if not education.pending_stat_gain.is_empty():
		lines.append("Chờ nhận chỉ số phụ: " + _format_stat_gains(education.pending_stat_gain))
	return "\n".join(lines)


func _story_text() -> String:
	_wallet_to_economy()
	var assets := economy.total_assets()
	var ending := PxbStory.suggest_ending(assets, stats.tri, fame, stats.an_yen(), social.is_married_to("ban-than"))
	var lines: Array[String] = [
		"Chương %d: %s" % [story.chapter, story.chapter_name()],
		"Danh vọng: %d • Tài sản: %sđ • An Yên: %d" % [fame, _fmt_vnd(assets), stats.an_yen()],
		"Ending gợi ý hiện tại: %s" % String(ENDING_NAMES.get(ending, ending)),
		"Danh hiệu (%s): %s" % [titles.alignment,
			(" • ".join(titles.all_titles()) if not titles.all_titles().is_empty() else "chưa có")],
		"Quest giúp NPC: %d/3 (cần cho chương 4)" % story.help_quests_done,
	]
	return "\n".join(lines)


func _online_text() -> String:
	var st := savecloud.sync_status()
	return "Online: %s • Đồng bộ: %s (%s) • Chat: %s" % [
		("có mạng" if online.is_online() else "ngoại tuyến"),
		String(st["status"]), String(st["detail"]), online.ws_status_text()]


# --- Hanh dong tu dien thoai (tra Dictionary de test goi truc tiep) ---

## Vong 95: ngay lam moc cho moi tinh toan giu sap — ngay server khi
## dang noi WS (da biet ngay), khong thi ngay local. Client moi luon
## bat dau ngay local 1 trong khi server co the da ngay 17+ (state
## ton tai, 30 phut/ngay) nen moi phep tinh giu sap (quyen loi / het
## han / chan mo tran / dong bo) phai dung chung moc nay thi moi
## khop voi server.
func _hold_anchor_day() -> int:
	if online != null and online.is_ws_connected() and online.ws_server_day > 0:
		return online.ws_server_day
	return day


## G4 buoc 8: quyen loi giu sap cua doi-ban hien tai ({} neu khong
## giu sap nao). Dung chung cho gia si khi mua + Danh vong/ngay.
## Vong 95: xet theo ngay neo giu sap (_hold_anchor_day), khong
## theo ngay local — hold [17,24) van co quyen loi khi ngay local 1.
func _hold_benefits_now() -> Dictionary:
	return PxbMarketBattle.hold_benefits(battle_state, "doi-ban", _hold_anchor_day())


## Vong 80: dong bo hold dang giu len server (goi sau khi thang
## tran tranh sap + khi WS (re)connect + khi ngay server doi).
## Khong co hold cua doi-ban / chua noi WS thi khong lam gi; gui
## that bai thi lan sau gui lai (khong toast — tranh spam khi
## offline). Tra {} khi khong gui.
## Vong 95: GUI CA KHI hold da het han theo ngay neo — chi can
## battle_state con hold cua doi-ban la gui, de SERVER xet han
## (het-han-giu-sap) va bao cho nguoi choi biet gia si da het.
## Chan theo quyen loi (nhu ban truoc) lam mat ack het-han +
## toast o vong 81 phase 8: ngay neo 15 ngoai [8,15) thi khong
## gui, ack thu 3 khong bao gio ve. Gui game_day theo ngay neo
## giu sap (ngay server khi dang noi).
func _sync_hold_to_server() -> Dictionary:
	if online == null or not online.is_ws_connected():
		return {}
	var holds: Dictionary = battle_state.get("holds", {}) as Dictionary
	var stall_id := ""
	var hold: Dictionary = {}
	for sid in holds.keys():
		var h: Dictionary = holds[sid]
		if str(h.get("teamId", "")) == "doi-ban":
			stall_id = str(sid)
			hold = h
			break
	if stall_id.is_empty() or hold.is_empty():
		return {}
	return online.send_ws_stall_hold_sync(stall_id,
		int(hold.get("startGameDay", day)), int(hold.get("untilGameDay", day + 1)), _hold_anchor_day())


## G4 buoc 9 (vong 68): ngay het han giu sap (0 neu khong giu sap do).
func _hold_until_day(stall_id: String) -> int:
	var holds: Dictionary = battle_state.get("holds", {}) as Dictionary
	if holds.has(stall_id):
		return int((holds[stall_id] as Dictionary).get("untilGameDay", 0))
	return 0


## G4 buoc 9 (vong 68): cau tieng Viet giai thich vi sao khong mo
## duoc tran tranh sap (thay ma reason tho nhu "dang-giu-sap-khac").
func _battle_block_text(reason: String, holding_stall_id: String) -> String:
	match reason:
		"dang-giu-sap-khac":
			return "Đội Bạn đang giữ sạp %s đến ngày %d — không thách đấu sạp khác được." % [holding_stall_id, _hold_until_day(holding_stall_id)]
		"da-giu-sap-nay":
			return "Đội Bạn đã giữ sạp này đến ngày %d rồi." % _hold_until_day(holding_stall_id)
		"doi-thieu-nguoi":
			return "Đội thiếu người, không mở được trận."
		"doi-khong-bang-nhau":
			return "Hai đội không bằng nhau, không mở được trận."
		"co-doi-khong-hop-le":
			return "Cỡ đội không hợp lệ, không mở được trận."
	return "Không mở được trận: " + reason


# Tien giu ho dau gia/trade co bi cham vao khong (vong 76):
# chi chan khi da noi WS + server dang giu ho + khoan chi nay
# lam vi xuong duoi so giu ho. Chua noi WS / khong giu ho thi
# khong chan (choi offline nhu cu). economy.money phai la so
# moi nhat — cac ham goi deu _wallet_to_economy() truoc.
func _reserve_blocked(amount: int) -> bool:
	if online == null or not online.is_ws_connected():
		return false
	if online.ws_reserved_money <= 0:
		return false
	return economy.money - amount < online.ws_reserved_money


func buy_item(item_id: String) -> Dictionary:
	_wallet_to_economy()
	# G4 buoc 8: dang giu sap thi mua gia si -10% (tru tien thue
	# phong tro thang — khong phai gia si, economy tu bo qua).
	var ben := _hold_benefits_now()
	var disc := 0
	if not ben.is_empty() and item_id != "phong-tro":
		disc = int(ben.get("wholesaleDiscountPercent", 0))
	# Vong 76: chan tieu tien dang giu ho dau gia/trade — gia
	# tinh dung nhu economy.buy (gia si chi khi co disc va khong
	# phai phong tro); mon la thi gia 0, khong chan, de economy
	# tra khong-co-mon nhu cu.
	var price := 0
	var it := PxbEconomy.get_item(item_id)
	if not it.is_empty():
		price = int(it.get("price_vnd", 0))
		if disc > 0 and item_id != "phong-tro":
			price = price * (100 - disc) / 100
	if price > 0 and _reserve_blocked(price):
		show_toast("Tiền đang giữ hộ đấu giá/trade, không dùng để mua được.")
		_refresh_phone()
		return {"ok": false, "fame_gained": 0, "reason": "tien-dang-giu-ho", "price_paid": 0}
	# Vong 77: da noi WS thi mua qua server validate (kinh te
	# server-authoritative) — chi 1 lan mua cho ack (nut mua an
	# trong luc cho, xem TAB_CHO); gui that bai (mat ket noi
	# giua chung) thi roi ve mua local nhu cu. Tien/mon chi ap
	# khi ack ok ve (xem _on_ws_shop_buy_acked).
	if online != null and online.is_ws_connected():
		if not _pending_shop_buy.is_empty():
			show_toast("Đang chờ máy chủ xác nhận lần mua trước.")
			_refresh_phone()
			return {"ok": false, "fame_gained": 0, "reason": "dang-cho-may-chu", "price_paid": 0}
		var sent := online.send_ws_shop_buy(item_id, disc)
		if bool(sent.get("ok", false)):
			_pending_shop_buy = {"req_id": int(sent.get("req_id", 0)),
				"item_id": item_id, "discount_percent": disc,
				"money_at_send": jobs.gold}
			show_toast("Đang chờ máy chủ xác nhận mua %s…" % String(PxbEconomy.get_item(item_id).get("name", item_id)))
			_refresh_phone()
			return {"ok": false, "fame_gained": 0, "reason": "cho-may-chu", "pending": true, "price_paid": 0}
	var res := economy.buy(item_id, disc)
	if bool(res.get("ok", false)):
		fame += int(res.get("fame_gained", 0))
		_wallet_from_economy()
		if disc > 0:
			show_toast("Đã mua %s (giá sỉ −%d%%)." % [
				String(PxbEconomy.get_item(item_id).get("name", item_id)), disc])
		else:
			show_toast("Đã mua %s." % String(PxbEconomy.get_item(item_id).get("name", item_id)))
	else:
		match String(res.get("reason", "")):
			"khong-du-tien":
				show_toast("Không đủ tiền mua món này.")
			"khong-co-mon":
				show_toast("Không có món này trong chợ.")
			_:
				show_toast("Không mua được.")
	_refresh_phone()
	return res


# Bán lại 1 món đang sở hữu cho chợ (vòng 86 — đối xứng
# buy_item): bán thì CỘNG tiền nên không cần chặn tiền giữ hộ
# như mua (vòng 76). Đường WS thì bán qua server validate (chỉ
# 1 lần bán chờ ack, nút bán ẩn trong lúc chờ); gửi thất bại
# (mất kết nối giữa chừng) thì rơi về bán local như cũ.
# Tiền/món chỉ áp khi ack ok về (xem _on_ws_shop_sell_acked).
func sell_item(item_id: String) -> Dictionary:
	_wallet_to_economy()
	if online != null and online.is_ws_connected():
		if not _pending_shop_sell.is_empty():
			show_toast("Đang chờ máy chủ xác nhận lần bán trước.")
			_refresh_phone()
			return {"ok": false, "reason": "dang-cho-may-chu", "price_received": 0}
		var sent := online.send_ws_shop_sell(item_id)
		if bool(sent.get("ok", false)):
			_pending_shop_sell = {"req_id": int(sent.get("req_id", 0)),
				"item_id": item_id,
				"money_at_send": jobs.gold}
			show_toast("Đang chờ máy chủ xác nhận bán %s…" % String(PxbEconomy.get_item(item_id).get("name", item_id)))
			_refresh_phone()
			return {"ok": false, "reason": "cho-may-chu", "pending": true, "price_received": 0}
	var res := economy.sell(item_id)
	if bool(res.get("ok", false)):
		_wallet_from_economy()
		show_toast("Đã bán %s (nhận %sđ)." % [
			String(PxbEconomy.get_item(item_id).get("name", item_id)),
			_fmt_vnd(int(res.get("price_received", 0)))])
	else:
		match String(res.get("reason", "")):
			"khong-so-huu":
				show_toast("Bạn chưa sở hữu món này.")
			"khong-ban-duoc":
				show_toast("Món này không bán lại được.")
			"khong-co-mon":
				show_toast("Không có món này trong chợ.")
			_:
				show_toast("Không bán được.")
	_refresh_phone()
	return res


func deposit_savings(amount: int) -> bool:
	_wallet_to_economy()
	# Vong 76: chan gui tiet kiem bang tien dang giu ho.
	if amount > 0 and _reserve_blocked(amount):
		show_toast("Tiền đang giữ hộ đấu giá/trade, không gửi tiết kiệm được.")
		_refresh_phone()
		return false
	var ok := economy.deposit_savings(amount)
	_wallet_from_economy()
	show_toast("Đã gửi tiết kiệm %sđ." % _fmt_vnd(amount) if ok else "Không gửi được (vượt tiền mặt).")
	_refresh_phone()
	return ok


func withdraw_savings(amount: int) -> bool:
	_wallet_to_economy()
	var ok := economy.withdraw_savings(amount)
	_wallet_from_economy()
	show_toast("Đã rút tiết kiệm %sđ." % _fmt_vnd(amount) if ok else "Không rút được (vượt tiết kiệm).")
	_refresh_phone()
	return ok


func enroll_degree(idx: int) -> Dictionary:
	# Vong 76: chan dong hoc phi bang tien dang giu ho — kiem tra
	# TRUOC khi goi enroll (fee biet truoc qua get_degree; enroll
	# thanh cong thi khong hoan tac duoc nen khong doi toi khi
	# biet fee_paid). Bang chua co / idx sai thi fee 0, khong
	# chan, de enroll tra ly do cu.
	_wallet_to_economy()
	var fee_pre := int(PxbEducation.get_degree(idx).get("fee_vnd", 0))
	if fee_pre > 0 and _reserve_blocked(fee_pre):
		show_toast("Tiền đang giữ hộ đấu giá/trade, không đóng học phí được.")
		_refresh_phone()
		return {"ok": false, "reason": "tien-dang-giu-ho"}
	var res := education.enroll(idx, stats.tri, -1, jobs.gold)
	if bool(res.get("ok", false)):
		var fee := int(res.get("fee_paid", 0))
		if fee > 0:
			jobs.gold -= fee
			_wallet_to_economy()
		_update_hud()
		show_toast("Đã đăng ký %s — tốt nghiệp ngày %d." % [
			String(PxbEducation.get_degree(idx).get("name", "")),
			int(res.get("end_day", 0))])
	else:
		match String(res.get("reason", "")):
			"khong-du-tien":
				show_toast("Không đủ tiền đóng học phí.")
			"chua-du-tri":
				show_toast("Chưa đủ Trí để đăng ký bậc này.")
			"can-mentor":
				show_toast("Bậc này cần người hướng dẫn (mentor).")
			"dang-hoc":
				show_toast("Đang học một bằng khác rồi.")
			"da-co-bang":
				show_toast("Đã có bằng này hoặc cao hơn.")
			_:
				show_toast("Không đăng ký được.")
	_refresh_phone()
	return res


# Khoa ngan han mau cua UI (PROVISIONAL): Sang tao, 3 ngay, 2 trieu.
func enroll_short_course() -> Dictionary:
	# Vong 76: chan dong phi khoa ngan bang tien dang giu ho —
	# phi 2 trieu biet truoc nen kiem tra truoc khi enroll.
	_wallet_to_economy()
	if _reserve_blocked(2000000):
		show_toast("Tiền đang giữ hộ đấu giá/trade, không đóng học phí được.")
		_refresh_phone()
		return {"ok": false, "reason": "tien-dang-giu-ho"}
	var res := education.enroll_short_course("sang", 3, 2000000, jobs.gold)
	if bool(res.get("ok", false)):
		var fee := int(res.get("fee_paid", 0))
		if fee > 0:
			jobs.gold -= fee
			_wallet_to_economy()
		_update_hud()
		show_toast("Đã đăng ký khóa ngắn Sáng tạo — xong ngày %d." % int(res.get("end_day", 0)))
	else:
		match String(res.get("reason", "")):
			"khong-du-tien":
				show_toast("Không đủ tiền đóng phí khóa ngắn.")
			"dang-hoc-khoa-ngan":
				show_toast("Đang học một khóa ngắn khác rồi.")
			_:
				show_toast("Không đăng ký được khóa ngắn.")
	_refresh_phone()
	return res


func train_stat(up: String, down: String) -> bool:
	var ok := stats.train(up, down, 5)
	if ok:
		_update_hud()
		show_toast("Luyện tập: %s +5, %s −5." % [up, down])
	else:
		show_toast("Không luyện được (chỉ số đã chạm trần/sàn).")
	_refresh_phone()
	return ok


func interact_friend(person_id: String) -> bool:
	var rel := social.get_rel(person_id)
	if rel.is_empty():
		show_toast("Không tìm thấy người này.")
		return false
	var ok := PxbSocial.interact(rel, day)
	if ok:
		_update_hud()
		show_toast("Trò chuyện xong — thân thiết %d/100." % int(rel.get("closeness", 0)))
	_refresh_phone()
	return ok


func travel_to(map_id: int) -> bool:
	if not hotspot.can_fast_travel(map_id):
		show_toast("Khu này chưa mở.")
		return false
	var dest := _map_by_id(map_id)
	if dest.is_empty():
		show_toast("Chưa có dữ liệu map cho khu này.")
		return false
	_close_phone()
	var door_tile := Vector2i(5, 4)
	for e in dest["events"]:
		if String(e.get("kind", "")) == "door":
			door_tile = Vector2i(e["tile"][0], e["tile"][1])
			break  # Lay cua dau tien (cua ve (5,4)) — xem ghi chu o _transfer.
	load_map(map_id, door_tile)
	show_toast("Đã về " + String(dest["name"]))
	return true


func advance_story_chapter() -> bool:
	_wallet_to_economy()
	var ok := story.advance_chapter(stats.tri, fame, economy.total_assets(),
		social.has_supporter())
	if ok:
		_update_hud()
		show_toast("Lên chương %d: %s!" % [story.chapter, story.chapter_name()])
	else:
		show_toast("Chưa đủ điều kiện lên chương tiếp (xem yêu cầu ở tab Xã hội).")
	_refresh_phone()
	return ok


func redeem_titles() -> bool:
	var ok := titles.redeem()
	show_toast("Đã bỏ danh hiệu phe Tà." if ok else "Chỉ đổi phe được khi đang ở phe Tà.")
	_refresh_phone()
	return ok


func upgrade_tool(tool_id: String) -> Dictionary:
	var res := tools.upgrade(tool_id)
	if bool(res.get("ok", false)):
		_update_hud()
		show_toast("%s lên bậc %d!" % [PxbTools.tool_name(tool_id), int(res.get("to_tier", 0))])
	else:
		match String(res.get("reason", "")):
			"thieu-nguyen-lieu":
				show_toast("Thiếu nguyên liệu để nâng cấp.")
			"da-max":
				show_toast("Công cụ đã bậc tối đa.")
			"chua-co-cong-cu":
				show_toast("Chưa có công cụ này.")
			_:
				show_toast("Không nâng cấp được.")
	_refresh_phone()
	return res


func acquire_tool(tool_id: String) -> Dictionary:
	var res := tools.acquire(tool_id)
	if bool(res.get("ok", false)):
		_update_hud()
		show_toast("Đã nhận %s (bậc 1)!" % PxbTools.tool_name(tool_id))
	else:
		match String(res.get("reason", "")):
			"thieu-nguyen-lieu":
				show_toast("Thiếu nguyên liệu để nhận công cụ.")
			"dung-che-tao":
				show_toast("Công cụ này phải chế tạo, không nhận trực tiếp.")
			_:
				show_toast("Không nhận được công cụ.")
	_refresh_phone()
	return res


# --- Save / Load (PxbSaveCloud, slot 1-3, file user://) ---

func _collect_system_data() -> Dictionary:
	return {
		"game_day": day, "day": day, "frame": frame_idx, "fame": fame,
		"pxb_time": {"game_day": day},
		"pxb_stats": stats.data(), "pxb_jobs": jobs.data(),
		"pxb_hotspot": hotspot.data(), "pxb_crafting": crafting.data(),
		"pxb_economy": economy.data(), "pxb_education": education.data(),
		"pxb_inventory": bag.data(), "pxb_social": social.data(), "pxb_titles": titles.data(),
		"pxb_story": story.data(), "pxb_tools": tools.data(),
		"pxb_phonehub": phonehub.data(), "pxb_savecloud": savecloud.data(),
		"pxb_online": online.data(), "pxb_marketbattle": battle_state,
	}


func save_game(slot: int) -> Dictionary:
	var res := savecloud.save_to_local(slot, _collect_system_data())
	if bool(res.get("ok", false)):
		show_toast("Đã lưu vào slot %d (%s)." % [slot, String(res.get("where", ""))])
	else:
		show_toast("Lưu thất bại: %s" % String(res.get("reason", "")))
	_refresh_phone()
	return res


func load_game(slot: int) -> Dictionary:
	var res := savecloud.load_from_local(slot)
	if not bool(res.get("ok", false)):
		show_toast("Không tải được: %s" % String(res.get("reason", "")))
		_refresh_phone()
		return res
	var save: Dictionary = res.get("save", {})
	_apply_save_data(save.get("gameSystem", {}))
	_update_hud()
	_update_daynight()
	_refresh_phone()
	show_toast("Đã tải save slot %d." % slot)
	return {"ok": true, "slot": slot}


# Khoi phuc toan bo state tu dict gameSystem cua save. Stats khoi phuc
# tai cho (autoload-safe); cac he khac tao moi qua from_data() tinh roi
# thay node cu + bind lai (tui chung / crafting / stats).
func _apply_save_data(gs: Dictionary) -> void:
	if gs.is_empty():
		return
	day = maxi(int(gs.get("day", gs.get("game_day", 1))), 1)
	# Vong 80: tai save doi ngay thi bao cho PxbOnline (xem _ready).
	if online != null:
		online.ws_game_day = day
	frame_idx = clampi(int(gs.get("frame", 0)), 0, 2)
	fame = maxi(int(gs.get("fame", 0)), 0)
	var sd: Dictionary = gs.get("pxb_stats", {})
	if not sd.is_empty():
		stats.set_stat("the", int(sd.get("the", stats.the)))
		stats.set_stat("tri", int(sd.get("tri", stats.tri)))
		stats.set_stat("tam", int(sd.get("tam", stats.tam)))
		# Vòng 87: khôi phục bonus chỉ số phụ qua from_data (lọc khóa
		# lạ / số âm như MarketBattle ở dưới); save cũ không có khóa
		# này thì bonus rỗng.
		stats.stat_bonus = PxbStats.from_data(sd).stat_bonus.duplicate()
	_replace_system("jobs", PxbJobs.from_data(gs.get("pxb_jobs", {})))
	jobs.stats = stats
	jobs.set_day_number(day)
	_replace_system("hotspot", PxbHotspot.from_data(gs.get("pxb_hotspot", {})))
	_replace_system("crafting", PxbCrafting.from_data(gs.get("pxb_crafting", {})))
	crafting.bind_materials(hotspot.materials)
	inventory = hotspot.materials
	_replace_system("economy", PxbEconomy.from_data(gs.get("pxb_economy", {})))
	# G4 bước 11: túi đồ slice — save cũ không có khóa này thì
	# from_data({}) trả túi rỗng (tương thích ngược).
	_replace_system("inventory", PxbInventory.from_data(gs.get("pxb_inventory", {})))
	_replace_system("education", PxbEducation.from_data(gs.get("pxb_education", {})))
	education.day_number = day
	_replace_system("social", PxbSocial.from_data(gs.get("pxb_social", {})))
	_replace_system("titles", PxbTitles.from_data(gs.get("pxb_titles", {})))
	_replace_system("story", PxbStory.from_data(gs.get("pxb_story", {})))
	_replace_system("tools", PxbTools.from_data(gs.get("pxb_tools", {})))
	tools.bind_materials(hotspot.materials)
	tools.bind_crafting(crafting)
	tools.bind_hotspot(hotspot)
	phonehub.from_data(gs.get("pxb_phonehub", {}))
	savecloud.from_data(gs.get("pxb_savecloud", {}))
	online.from_data(gs.get("pxb_online", {}))
	# G4 buoc 5: khoi phuc giu sap + lich su tran (loc qua from_data
	# de loai hold rac), don sap het han theo ngay game vua tai.
	var _mb_tmp := PxbMarketBattle.new()
	_mb_tmp.from_data(gs.get("pxb_marketbattle", {}))
	battle_state = _mb_tmp.data()
	_mb_tmp.free()
	PxbMarketBattle.expire_holds(battle_state, day)
	_wallet_to_economy()
	# G4 bước 11: _replace_system đã tạo bag/economy mới — nối lại
	# túi/ví cho trade WS (nối cũ trỏ node đã queue_free).
	online.trade_inventory = bag
	online.trade_economy = economy


func _replace_system(kind: String, node: Node) -> void:
	match kind:
		"jobs":
			jobs.queue_free()
			jobs = node as PxbJobs
		"hotspot":
			hotspot.queue_free()
			hotspot = node as PxbHotspot
		"crafting":
			crafting.queue_free()
			crafting = node as PxbCrafting
		"economy":
			economy.queue_free()
			economy = node as PxbEconomy
		"inventory":
			bag.queue_free()
			bag = node as PxbInventory
		"education":
			education.queue_free()
			education = node as PxbEducation
		"social":
			social.queue_free()
			social = node as PxbSocial
		"titles":
			titles.queue_free()
			titles = node as PxbTitles
		"story":
			story.queue_free()
			story = node as PxbStory
		"tools":
			tools.queue_free()
			tools = node as PxbTools
	add_child(node)


# Kiem tra mang (PxbOnline la async — can await; chay nen, ket qua
# hien lai khi mo tab Cai dat). Server .NET chua chay tren VM nen
# du kien offline — bao dung that, khong gia vo online.
func _check_online() -> void:
	var res: Dictionary = await online.health_check()
	phonehub.notify(PxbPhoneHub.TAB_CAI_DAT)
	if bool(res.get("ok", false)):
		show_toast("Đã nối server: %s" % String(res.get("status", "")))
	else:
		show_toast("Không tới được server (%s) — chơi ngoại tuyến." % String(res.get("reason", "")))
	_refresh_phone()


# --- Nut bam cua panel dien thoai (goi ham tren, de test goi truc tiep) ---

func _on_phone_tab_pressed(tab_id: String) -> void:
	phonehub.select_tab(tab_id)
	_refresh_phone()


func _on_buy_pressed(item_id: String) -> void:
	buy_item(item_id)


func _on_sell_pressed(item_id: String) -> void:
	sell_item(item_id)


func _on_deposit_pressed(amount: int) -> void:
	deposit_savings(amount)


func _on_withdraw_pressed(amount: int) -> void:
	withdraw_savings(amount)


func _on_enroll_pressed(idx: int) -> void:
	enroll_degree(idx)


func _on_enroll_short_pressed() -> void:
	enroll_short_course()


func _on_train_pressed(pair: Array) -> void:
	train_stat(String(pair[0]), String(pair[1]))


func _on_interact_pressed(person_id: String) -> void:
	interact_friend(person_id)


func _on_travel_pressed(map_id: int) -> void:
	travel_to(map_id)


func _on_advance_chapter_pressed() -> void:
	advance_story_chapter()


func _on_redeem_pressed() -> void:
	redeem_titles()


func _on_tool_upgrade_pressed(tool_id: String) -> void:
	upgrade_tool(tool_id)


func _on_tool_acquire_pressed(tool_id: String) -> void:
	acquire_tool(tool_id)


func _on_save_pressed(slot: int) -> void:
	save_game(slot)


func _on_load_pressed(slot: int) -> void:
	load_game(slot)


func _on_check_online_pressed() -> void:
	_check_online()


# --- Chat online WS (G4 buoc 7) ---

# Tin chat moi: dang mo tab Tin nhan thi lam tuoi ngay (tin hien
# trong _phone_content), khong thi bao so chua doc o tab.
func _on_ws_chat_received(_msg: Dictionary) -> void:
	if phone_open and phonehub.current_tab == PxbPhoneHub.TAB_DANH_BA_TIN_NHAN:
		_refresh_phone()
	else:
		phonehub.notify(PxbPhoneHub.TAB_DANH_BA_TIN_NHAN)


# Lich su chat ve sau khi hello lai (vong 85): PxbOnline da them
# cac tin vao ws_chat_log truoc khi phat signal (vong 83) nen o
# day chi can lam tuoi / bao chua doc giong tin chat moi — KHONG
# them tin vao log nua (tranh nhan doi). Ly do can handler rieng:
# welcome den truoc lich su, _on_ws_status_changed lam tuoi dien
# thoai luc log con trong nen noi dung tab Tin nhan van cu cho
# toi khi co tin moi / doi tab.
func _on_ws_chat_history_received(_messages: Array) -> void:
	if phone_open and phonehub.current_tab == PxbPhoneHub.TAB_DANH_BA_TIN_NHAN:
		_refresh_phone()
	else:
		phonehub.notify(PxbPhoneHub.TAB_DANH_BA_TIN_NHAN)


# Presence doi: lam tuoi nhu tin chat (danh sach online trong
# _phone_content thay doi).
func _on_ws_presence_changed(_players: Array) -> void:
	if phone_open and phonehub.current_tab == PxbPhoneHub.TAB_DANH_BA_TIN_NHAN:
		_refresh_phone()
	else:
		phonehub.notify(PxbPhoneHub.TAB_DANH_BA_TIN_NHAN)


# Trang thai WS doi: chi bao khi vua noi xong (ngat thi im — nut
# "Ngat ket noi chat" nguoi choi tu bam da ro).
func _on_ws_status_changed(connected: bool) -> void:
	if connected:
		show_toast("Đã nối chat online (%d người)." % online.ws_players.size())
		# Vong 80: (re)connect thi gui lai hold dang giu (neu co)
		# de server biet ma validate gia si / phi dau gia.
		_sync_hold_to_server()
	elif not _pending_shop_buy.is_empty() or not _pending_shop_sell.is_empty():
		# Vong 77 + 86: mat ket noi trong luc cho ack mua/ban o
		# cho — server chua chac da tru/cong tien, lan mua/ban nay
		# huy; xoa pending de nut mua/ban hien lai, nguoi choi
		# mua/ban lai sau.
		var was_buy := not _pending_shop_buy.is_empty()
		var was_sell := not _pending_shop_sell.is_empty()
		_pending_shop_buy = {}
		_pending_shop_sell = {}
		if was_buy and was_sell:
			show_toast("Mất kết nối, lần mua/bán chưa được xác nhận — thử lại.")
		elif was_buy:
			show_toast("Mất kết nối, lần mua chưa được xác nhận — thử mua lại.")
		else:
			show_toast("Mất kết nối, lần bán chưa được xác nhận — thử bán lại.")
	_refresh_phone()


# Giao dịch đổi đồ đã chốt (G4 bước 11): PxbOnline đã áp thỏa
# thuận vào bag + economy.money lúc nhận trade_completed — ở đây
# chỉ đồng bộ ngược về ví chung jobs.gold + báo cho người chơi.
# trade["apply"] ghi kết quả áp (applied / missing_item /
# receive_failed / short_money) — thiếu món/tiền thì báo rõ phần
# thiếu, không giả vờ đủ.
func _on_ws_trade_completed(trade: Dictionary) -> void:
	var res: Dictionary = trade.get("apply", {})
	if bool(res.get("applied", false)):
		_wallet_from_economy()
		var give_name := _trade_item_name(String(res.get("give_item_id", "")))
		var want_name := _trade_item_name(String(res.get("want_item_id", "")))
		var parts: Array[String] = []
		if not give_name.is_empty():
			parts.append("đã cho %s" % give_name)
		if int(res.get("money_given", 0)) > 0:
			parts.append("đã cho %sđ" % _fmt_vnd(int(res.get("money_given", 0))))
		if not want_name.is_empty():
			parts.append("nhận %s" % want_name)
		if int(res.get("money_received", 0)) > 0:
			parts.append("nhận %sđ" % _fmt_vnd(int(res.get("money_received", 0))))
		var msg := "Đã đổi đồ xong"
		if not parts.is_empty():
			msg += ": " + " • ".join(parts)
		if bool(res.get("missing_item", false)):
			msg += " (thiếu món cho đi — túi không đủ)"
		if bool(res.get("receive_failed", false)):
			msg += " (món nhận về không vào túi được)"
		if int(res.get("short_money", 0)) > 0:
			msg += " (thiếu %sđ tiền cho)" % _fmt_vnd(int(res.get("short_money", 0)))
		show_toast(msg + ".")
	else:
		# Vòng 73 (sổ cái): giao dịch bị HỦY ở server (1 bên đã
		# đồng bộ không đủ tiền/món lúc chốt) thì báo rõ lý do,
		# không giả vờ đã đổi xong.
		if bool(res.get("voided", false)):
			var why := String(res.get("reason", ""))
			var why_text := "đối phương không đủ tiền/đồ lúc chốt"
			match why:
				"thieu-tien-nguoi-gui":
					why_text = "người gửi không đủ tiền lúc chốt"
				"thieu-do-nguoi-gui":
					why_text = "người gửi không còn món cho đi lúc chốt"
				"thieu-tien-nguoi-nhan":
					why_text = "người nhận không đủ tiền lúc chốt"
				"thieu-do-nguoi-nhan":
					why_text = "người nhận không còn món cho đi lúc chốt"
			show_toast("Đổi đồ bị hủy: %s." % why_text)
		else:
			show_toast("Đổi đồ đã chốt nhưng chưa áp vào túi/ví (%s)." % String(res.get("reason", "khong-ro")))
	_refresh_phone()


# Tên hiển thị của 1 mã món slice (PxbBalance.ITEMS); mã rỗng/lạ
# thì trả "" (toast bỏ phần đó) — không bịa tên.
func _trade_item_name(item_id: String) -> String:
	if item_id.is_empty():
		return ""
	return String(PxbInventory.get_item(item_id).get("name", ""))


# Phiên đấu giá đã đóng (G4 bước 12): PxbOnline đã áp kết quả vào
# bag + economy.money lúc nhận auction_closed — ở đây chỉ đồng bộ
# ngược về ví chung jobs.gold + báo cho người chơi. auction["apply"]
# ghi kết quả áp (applied / missing_item / receive_failed /
# short_money) — thiếu món/tiền thì báo rõ phần thiếu, không giả
# vờ đủ. Không phải người bán / người thắng thì chỉ báo kết quả
# chung (ai thắng, giá chốt) để người xem chợ biết.
func _on_ws_auction_closed(auction: Dictionary) -> void:
	var res: Dictionary = auction.get("apply", {})
	var item_name := _trade_item_name(String(auction.get("item_id", "")))
	if item_name.is_empty():
		item_name = String(auction.get("item_id", ""))
	var winner := String(auction.get("winner_player_id", ""))
	var hammer := int(auction.get("hammer_price", 0))
	if winner.is_empty():
		show_toast("Đấu giá %s đã đóng — không ai đấu giá." % item_name)
		_refresh_phone()
		return
	if bool(res.get("applied", false)):
		_wallet_from_economy()
		var role := String(res.get("role", ""))
		if role == "seller":
			var msg := "Đã bán %s giá %sđ (phí sàn %sđ)." % [
				item_name, _fmt_vnd(hammer),
				_fmt_vnd(int(res.get("fee_vnd", 0)))]
			if bool(res.get("missing_item", false)):
				msg += " (món đã không còn trong túi — chỉ nhận tiền)"
			show_toast(msg)
		elif role == "winner":
			var msg2 := "Đã thắng đấu giá %s giá %sđ." % [
				item_name, _fmt_vnd(hammer)]
			if bool(res.get("receive_failed", false)):
				msg2 += " (món không vào túi được)"
			if int(res.get("short_money", 0)) > 0:
				msg2 += " (thiếu %sđ tiền trả)" % _fmt_vnd(int(res.get("short_money", 0)))
			show_toast(msg2)
		else:
			show_toast("Đấu giá %s đã đóng — %s thắng giá %sđ." % [
				item_name, winner, _fmt_vnd(hammer)])
	else:
		var reason := String(res.get("reason", "khong-ro"))
		if reason == "khong-lien-quan":
			show_toast("Đấu giá %s đã đóng — %s thắng giá %sđ." % [
				item_name, winner, _fmt_vnd(hammer)])
		else:
			show_toast("Đấu giá %s đã đóng nhưng chưa áp vào túi/ví (%s)." % [
				item_name, reason])
	_refresh_phone()


# Ack so cai server (vong 76): PxbOnline da dat baseline theo
# ack; neu ack stale HOAC so server lech vi/tui local thi ap so
# server — vi ve ack money, tui dong bo theo ack items (them/bot
# chenh lech tung mon; mon local ma ack khong co thi bot het; mon
# ack co ma local thieu thi them du). Ack binh thuong (khong
# stale, so khop) thi khong lam gi. Chi toast khi that su co
# thay doi so — tranh spam toast moi lan sync.
# Vong 77: neu ack kem sent_money (tien local luc gui sync nay)
# thi ap vi theo delta (ack.money + (vi hien tai - sent_money))
# de khong nuot tien kiem/tieu local trong luc cho ack (vd
# pre-sync mua o cho gui 200 trieu, kiem them 100k thi vi ve
# 200 trieu + 100k); khong co sent_money (sync gui tho / server
# cu) thi ap tuyet doi nhu vong 76.
# Ap owned server tra ve lam chuan (vong 78): dung lai
# economy.owned tu dict {item_id: count} (sap id theo alphabet
# cho on dinh, lap lai theo count). Tra true khi owned doi.
# An toan khi ap ack (khong mat mon mua local offline): mua
# local chi xay ra khi WS da ngat (khong co ack nao dang bay);
# khi da noi WS thi owned chi doi qua ack server, va moi sync
# deu gui owned local len truoc de server hop nhat.
func _apply_server_owned(owned: Dictionary) -> bool:
	var want: Array[String] = []
	var ids: Array[String] = []
	for k in owned.keys():
		ids.append(String(k))
	ids.sort()
	for item_id in ids:
		var n := maxi(int(owned.get(item_id, 0)), 0)
		for i in range(n):
			want.append(item_id)
	var changed := false
	if economy.owned.size() != want.size():
		changed = true
	else:
		for i in range(want.size()):
			if String(economy.owned[i]) != want[i]:
				changed = true
				break
	if changed:
		economy.owned.clear()
		for item_id in want:
			economy.owned.append(item_id)
	return changed


func _on_ws_ledger_sync_acked(ack: Dictionary) -> void:
	var ack_money := int(ack.get("money", -1))
	if ack_money < 0:
		return
	var ack_items: Variant = ack.get("items", {})
	if not (ack_items is Dictionary):
		return
	var new_gold := ack_money
	var sent_money := int(ack.get("sent_money", -1))
	if sent_money >= 0:
		new_gold = maxi(ack_money + (jobs.gold - sent_money), 0)
	var money_changed := new_gold != jobs.gold
	var items_changed := false
	var seen := {}
	for item_id in (ack_items as Dictionary).keys():
		seen[String(item_id)] = true
		if bag.count(String(item_id)) != int((ack_items as Dictionary)[item_id]):
			items_changed = true
	var local_items: Dictionary = (bag.data() as Dictionary).get("items", {})
	for item_id in local_items.keys():
		if not seen.has(String(item_id)) and bag.count(String(item_id)) != 0:
			items_changed = true
	# Vong 78: ack co owned thi ap owned server lam chuan (server
	# cu khong gui owned thi giu owned local nhu cu).
	var owned_changed := false
	if bool(ack.get("owned_present", false)):
		owned_changed = _apply_server_owned(ack.get("owned", {}))
	if not bool(ack.get("stale", false)) and not money_changed and not items_changed \
			and not owned_changed:
		return
	jobs.gold = new_gold
	_wallet_to_economy()
	for item_id in (ack_items as Dictionary).keys():
		var want := int((ack_items as Dictionary)[item_id])
		var have := bag.count(String(item_id))
		if have < want:
			# Them tung cai de khong vo voi mon khong xep chong
			# (add tra false khi da co — chi them duoc toi da 1).
			var added := 0
			while added < want - have and bag.add(String(item_id), 1):
				added += 1
			if added > 0:
				items_changed = true
	for item_id in local_items.keys():
		var want2 := int((ack_items as Dictionary).get(item_id, 0))
		var have2 := bag.count(String(item_id))
		if have2 > want2 and bag.remove(String(item_id), have2 - want2):
			items_changed = true
	if money_changed or items_changed or owned_changed:
		_update_hud()
		_refresh_phone()
		if money_changed or items_changed:
			show_toast("Máy chủ đã đồng bộ lại ví/túi (đã trừ tiền đấu giá/trade đã chốt).")


# Ack mua o cho qua server (vong 77): chi nhan khi req_id khop
# lan mua dang cho (ack la thi PxbOnline da bo). ok=true thi ap:
# vi = tien server sau khi tru + chenh lech tien local kiem/tieu
# trong luc cho ack (money_at_send — vd lam them ca kiem them,
# gui tiet kiem rut ra — de khong mat/nhan doi so do); owned ap
# theo ack.owned khi server moi gui kem (vong 78 — server lam
# chuan), server cu khong gui thi append local nhu cu; Danh vong
# theo ack (nha/xe-sang +50).
# ok=false thi khong tru/cong gi, chi bao ly do bang tieng Viet.
# Chi 1 lan mua cho tai 1 thoi diem (nut mua an trong luc cho)
# nen money_at_send luon tuoi, khong bi ack truoc lam lech nhu
# khi xep hang nhieu lan mua.
## Vong 80: server tra loi dong bo giu sap. Ok thi khong lam gi
## (gia si / phi dau gia lan mua ke se dung so server); bi tu
## choi thi bao de nguoi choi biet vi sao lan mua ke khong con
## gia si — chi 2 ly do can bao, ly do khac thi im (tranh spam).
func _on_ws_stall_hold_synced(ack: Dictionary) -> void:
	if bool(ack.get("ok", false)):
		return
	match String(ack.get("reason", "")):
		"het-han-giu-sap":
			show_toast("Giữ sạp đã hết hạn theo máy chủ, lần mua sau không còn giá sỉ.")
			# Vong 95: hold het han theo ngay server thi don khoi
			# battle_state luon — khong gui lai + bao lai o moi lan
			# doi ngay / (re)connect sau nay.
			PxbMarketBattle.expire_holds(battle_state, _hold_anchor_day())
		"dang-giu-sap-khac":
			show_toast("Máy chủ báo đội đang giữ sạp khác.")
		"ngay-server-khong-khop":
			show_toast("Ngày game lệch với máy chủ — thử đồng bộ lại sau.")
		_:
			pass


# Vong 81: ngay server doi — dong bo lai hold dang giu de server
# xet lai han theo ngay moi (het han thi ack het-han-giu-sap,
# _on_ws_stall_hold_synced bao toast). Khong doi ngay local `day`
# (dong ho offline) — chi dong bo hold online theo ngay server.
func _on_ws_server_day_changed(_server_day: int) -> void:
	_sync_hold_to_server()


func _on_ws_shop_buy_acked(ack: Dictionary) -> void:
	if _pending_shop_buy.is_empty():
		return
	var req_id := int(ack.get("req_id", 0))
	if req_id != int(_pending_shop_buy.get("req_id", -1)):
		return
	var pending := _pending_shop_buy
	_pending_shop_buy = {}
	var item_id := String(pending.get("item_id", ""))
	var disc := int(pending.get("discount_percent", 0))
	var item_name := String(PxbEconomy.get_item(item_id).get("name", item_id))
	if not bool(ack.get("ok", false)):
		match String(ack.get("reason", "")):
			"khong-du-tien":
				show_toast("Máy chủ báo không đủ tiền mua %s." % item_name)
			"khong-co-mon":
				show_toast("Máy chủ báo không có món %s." % item_name)
			"chua-dong-bo-so-cai":
				show_toast("Chưa đồng bộ ví với máy chủ, thử mua lại.")
			"gia-khong-hop-le":
				show_toast("Giá mua không hợp lệ, thử mua lại.")
			"chua-hello":
				show_toast("Chưa nối máy chủ, thử mua lại.")
			_:
				show_toast("Không mua được %s (%s)." % [item_name, String(ack.get("reason", "khong-ro"))])
		_refresh_phone()
		return
	var delta := jobs.gold - int(pending.get("money_at_send", 0))
	jobs.gold = maxi(int(ack.get("money", 0)) + delta, 0)
	_wallet_to_economy()
	if bool(ack.get("owned_present", false)):
		_apply_server_owned(ack.get("owned", {}))
	else:
		economy.owned.append(item_id)
	fame += int(ack.get("fame_gained", 0))
	_wallet_from_economy()
	# Vong 80: gia si ap dung la so SERVER tra ve (discount_applied),
	# khong phai so da khai luc gui — server co the sua ve 0 khi
	# hold het han / chua dong bo; ack cu khong co khoa nay (-1)
	# thi dung so pending nhu cu.
	var applied := int(ack.get("discount_applied", -1))
	if applied < 0:
		applied = disc
	if applied > 0:
		show_toast("Đã mua %s (máy chủ đã trừ %sđ, giá sỉ −%d%%)." % [
			item_name, _fmt_vnd(int(ack.get("price_paid", 0))), applied])
	elif disc > 0:
		show_toast("Đã mua %s (máy chủ đã trừ %sđ — không còn giá sỉ)." % [
			item_name, _fmt_vnd(int(ack.get("price_paid", 0)))])
	else:
		show_toast("Đã mua %s (máy chủ đã trừ %sđ)." % [
			item_name, _fmt_vnd(int(ack.get("price_paid", 0)))])
	_refresh_phone()


# Ack bán lại cho chợ qua server (vòng 86 — đối xứng
# _on_ws_shop_buy_acked, nhưng bán thì CỘNG tiền + không Danh
# vọng): chỉ nhận ack khớp lần bán đang chờ; ack lỗi thì báo lý
# do tiếng Việt, không đổi ví/túi; ack ok thì áp ví theo delta
# (tiền kiếm/tiêu local trong lúc chờ ack) + owned server làm
# chuẩn rồi báo số tiền đã nhận.
func _on_ws_shop_sell_acked(ack: Dictionary) -> void:
	if _pending_shop_sell.is_empty():
		return
	var req_id := int(ack.get("req_id", 0))
	if req_id != int(_pending_shop_sell.get("req_id", -1)):
		return
	var pending := _pending_shop_sell
	_pending_shop_sell = {}
	var item_id := String(pending.get("item_id", ""))
	var item_name := String(PxbEconomy.get_item(item_id).get("name", item_id))
	if not bool(ack.get("ok", false)):
		match String(ack.get("reason", "")):
			"khong-so-huu":
				show_toast("Máy chủ báo bạn chưa sở hữu %s." % item_name)
			"khong-ban-duoc":
				show_toast("Máy chủ báo %s không bán lại được." % item_name)
			"khong-co-mon":
				show_toast("Máy chủ báo không có món %s." % item_name)
			"chua-dong-bo-so-cai":
				show_toast("Chưa đồng bộ ví với máy chủ, thử bán lại.")
			"chua-hello":
				show_toast("Chưa nối máy chủ, thử bán lại.")
			_:
				show_toast("Không bán được %s (%s)." % [item_name, String(ack.get("reason", "khong-ro"))])
		_refresh_phone()
		return
	var delta := jobs.gold - int(pending.get("money_at_send", 0))
	jobs.gold = maxi(int(ack.get("money", 0)) + delta, 0)
	_wallet_to_economy()
	if bool(ack.get("owned_present", false)):
		_apply_server_owned(ack.get("owned", {}))
	else:
		economy.owned.erase(item_id)
	_wallet_from_economy()
	show_toast("Đã bán %s (máy chủ đã cộng %sđ)." % [
		item_name, _fmt_vnd(int(ack.get("price_received", 0)))])
	_refresh_phone()


func _on_ws_connect_pressed() -> void:
	var res: Dictionary = online.connect_ws()
	if bool(res.get("ok", false)):
		show_toast("Đang nối chat online…")
	else:
		show_toast("Không nối được chat (%s)." % String(res.get("reason", "")))
	_refresh_phone()


func _on_ws_disconnect_pressed() -> void:
	online.disconnect_ws()
	show_toast("Đã ngắt chat online.")
	_refresh_phone()


func _on_ws_send_pressed() -> void:
	if _phone_chat_input == null:
		return
	var text := _phone_chat_input.text
	var res: Dictionary = online.send_ws_chat(text)
	if bool(res.get("ok", false)):
		_phone_chat_input.text = ""
	else:
		match String(res.get("reason", "")):
			"chua-ket-noi-ws":
				show_toast("Chưa nối chat online.")
			"chat-trong":
				show_toast("Chưa nhập gì để gửi.")
			"chat-qua-dai":
				show_toast("Tin nhắn quá dài (tối đa 500 ký tự).")
			_:
				show_toast("Không gửi được chat.")
	_refresh_phone()


# --- UI trade / dau gia trong dien thoai (G4 vong 74 + 75) ---
# De nghi: cho mon dau tien trong tui, lay so tien o nhap (vong 75;
# mac dinh 100.000d). Mon dau tien = id nho nhat theo thu tu
# alphabet (on dinh giua cac lan mo, khong phu thuoc thu tu chen
# cua Dictionary).

func _first_owned_item_id() -> String:
	if bag == null:
		return ""
	var items: Dictionary = (bag.data() as Dictionary).get("items", {})
	var ids: Array[String] = []
	for k in items:
		if int(items[k]) > 0:
			ids.append(String(k))
	ids.sort()
	return ids[0] if not ids.is_empty() else ""


func _first_owned_item_name() -> String:
	return _trade_item_name(_first_owned_item_id())


func _ws_player_name(player_id: String) -> String:
	for p in online.ws_players:
		var pd := p as Dictionary
		if String(pd.get("player_id", "")) == player_id:
			var n := String(pd.get("name", ""))
			if not n.is_empty():
				return n
	return player_id


# "Bình cho Cà Phê, muốn Cơm Tấm + 100.000đ" — ten mon lay tu
# catalog, ma la thi in ma tho (khong bia ten); phan trong thi bo.
func _trade_offer_text(offer: Dictionary) -> String:
	var from_name := _ws_player_name(String(offer.get("from_player_id", "")))
	var give_name := _trade_item_name(String(offer.get("give_item_id", "")))
	if give_name.is_empty():
		give_name = String(offer.get("give_item_id", ""))
	var want_name := _trade_item_name(String(offer.get("want_item_id", "")))
	if want_name.is_empty():
		want_name = String(offer.get("want_item_id", ""))
	var give_parts: Array[String] = []
	if not give_name.is_empty():
		give_parts.append(give_name)
	if int(offer.get("give_money", 0)) > 0:
		give_parts.append("%sđ" % _fmt_vnd(int(offer.get("give_money", 0))))
	var want_parts: Array[String] = []
	if not want_name.is_empty():
		want_parts.append(want_name)
	if int(offer.get("want_money", 0)) > 0:
		want_parts.append("%sđ" % _fmt_vnd(int(offer.get("want_money", 0))))
	var give_text := " + ".join(give_parts) if not give_parts.is_empty() else "(không có gì)"
	var want_text := " + ".join(want_parts) if not want_parts.is_empty() else "(không có gì)"
	return "%s cho %s, muốn %s" % [from_name, give_text, want_text]


# Gia dat tiep theo cho 1 phien: chua ai dau thi gia khoi diem,
# co roi thi gia hien tai + buoc toi thieu 1.000d (luat PxbOnline).
func _ws_auction_next_bid(auction: Dictionary) -> int:
	var cur := int(auction.get("current_bid", 0))
	if cur > 0:
		return cur + PxbOnline.WS_MIN_BID_INCREMENT_VND
	return int(auction.get("start_price", 0))


# Vong 75: doc so nguoi choi go trong o nhap dien thoai. Bo dau
# cham/phay/khoang trang (nguoi choi go "100.000" hay "100000" deu
# duoc); trong / sai dinh dang / am -> mac dinh; vuot tran -> kep
# ve min/max. LineEdit da bi xoa (doi tab) thi tra mac dinh.
func _parse_vnd_input(le: LineEdit, default_vnd: int, min_vnd: int, max_vnd: int) -> int:
	if le == null or not is_instance_valid(le):
		return default_vnd
	var t := (le.text as String).strip_edges().replace(".", "").replace(",", "").replace(" ", "").replace("_", "")
	if t.is_empty() or not t.is_valid_int():
		return default_vnd
	return clampi(t.to_int(), min_vnd, max_vnd)


# Vong 75: gia dau hieu luc cho 1 phien — o nhap trong thi gia tiep
# theo; go so thi phai >= gia tiep theo (thap hon thi bao loi, tra
# -1 de handler khong gui); vuot tran thi kep ve max.
func _ws_auction_bid_amount(auction: Dictionary) -> int:
	var next_bid := _ws_auction_next_bid(auction)
	if _phone_bid_input == null or not is_instance_valid(_phone_bid_input):
		return next_bid
	var t := (_phone_bid_input.text as String).strip_edges().replace(".", "").replace(",", "").replace(" ", "").replace("_", "")
	if t.is_empty() or not t.is_valid_int():
		return next_bid
	var raw := t.to_int()
	if raw < next_bid:
		return -1
	return mini(raw, PxbOnline.WS_MAX_AUCTION_MONEY_VND)


# Vong 75: tao 1 o nhap so trong dien thoai (cung kho voi nut hanh
# dong, nhu o chat WS). text hien tai lay tu gia tri da luu de
# khong mat so da go khi dien thoai ve lai.
func _phone_number_input(placeholder: String, current_value: int) -> LineEdit:
	var le := LineEdit.new()
	le.placeholder_text = placeholder
	le.custom_minimum_size = Vector2(580, 56)
	le.max_length = 15
	if current_value > 0:
		le.text = str(current_value)
	_phone_actions.add_child(le)
	return le


func _has_my_auction_open() -> bool:
	for a in online.ws_auctions:
		if String((a as Dictionary).get("seller_player_id", "")) == online.ws_player_id:
			return true
	return false


# Dich ma loi trade / dau gia cua PxbOnline sang tieng Viet de bao
# tren toast (khong de ma tho lo ra man hinh).
func _ws_trade_reason_text(reason: String) -> String:
	match reason:
		"chua-ket-noi-ws":
			return "Chưa nối chat online."
		"thieu-nguoi-nhan":
			return "Chưa chọn người để đổi đồ."
		"khong-doi-voi-chinh-minh":
			return "Không đổi đồ với chính mình được."
		"de-nghi-trong":
			return "Đề nghị trống — chưa có gì để cho / muốn."
		"da-co-de-nghi-cho":
			return "Đang có 1 đề nghị chờ — hủy đề nghị cũ rồi gửi lại."
		"khong-du-do-cho":
			return "Không đủ món để cho đi."
		"khong-du-tien-cho":
			return "Không đủ tiền để cho đi."
		"khong-tim-thay-de-nghi":
			return "Không tìm thấy đề nghị đó nữa."
		"thieu-trade-id":
			return "Thiếu mã đề nghị."
		_:
			return "Không làm được (%s)." % reason


func _ws_auction_reason_text(reason: String) -> String:
	match reason:
		"chua-ket-noi-ws":
			return "Chưa nối chat online."
		"thieu-item-id":
			return "Chưa chọn món để bán."
		"gia-khoi-diem-khong-hop-le":
			return "Giá khởi điểm không hợp lệ."
		"thoi-gian-khong-hop-le":
			return "Thời gian đấu giá không hợp lệ."
		"da-co-dau-gia-mo":
			return "Đang có 1 phiên đấu giá mở rồi."
		"khong-du-do-cho":
			return "Không còn món đó trong túi."
		"khong-tim-thay-dau-gia":
			return "Không tìm thấy phiên đó nữa."
		"nguoi-ban-khong-duoc-dau-gia":
			return "Người bán không được đấu giá của mình."
		"gia-dau-khong-hop-le":
			return "Giá đấu không hợp lệ."
		"gia-dau-thap-hon-gia-hien-tai":
			return "Giá đấu thấp hơn giá hiện tại."
		"khong-du-tien-cho":
			return "Không đủ tiền để đấu giá."
		"khong-phai-nguoi-ban":
			return "Chỉ người bán mới hủy được phiên này."
		"da-co-gia-khong-huy-duoc":
			return "Đã có người đấu giá nên không hủy được."
		"thieu-auction-id":
			return "Thiếu mã phiên đấu giá."
		_:
			return "Không làm được (%s)." % reason


func _on_ws_trade_offer_pressed(to_player_id: String) -> void:
	var item_id := _first_owned_item_id()
	if item_id.is_empty():
		show_toast("Túi đang trống — nhặt món rồi mới đổi đồ được.")
		return
	# Vong 75: so tien muon lay lay tu o nhap (mac dinh 100.000d
	# khi o trong / go sai); giu lai de lan sau mo dien thoai van
	# thay so vua go.
	_trade_want_money_vnd = _parse_vnd_input(_phone_trade_money_input,
		TRADE_OFFER_WANT_MONEY_VND, 0, PxbOnline.WS_MAX_TRADE_MONEY_VND)
	var res: Dictionary = online.send_ws_trade_offer(to_player_id, item_id, 0,
		"", _trade_want_money_vnd)
	if bool(res.get("ok", false)):
		show_toast("Đã gửi đề nghị đổi đồ: cho %s, lấy %sđ." % [
			_trade_item_name(item_id), _fmt_vnd(_trade_want_money_vnd)])
	else:
		show_toast(_ws_trade_reason_text(String(res.get("reason", ""))))
	_refresh_phone()


func _on_ws_trade_accept_pressed(trade_id: String) -> void:
	var res: Dictionary = online.send_ws_trade_accept(trade_id)
	if bool(res.get("ok", false)):
		show_toast("Đã chấp nhận — chờ server chốt giao dịch…")
	else:
		show_toast(_ws_trade_reason_text(String(res.get("reason", ""))))
	_refresh_phone()


func _on_ws_trade_decline_pressed(trade_id: String) -> void:
	var res: Dictionary = online.send_ws_trade_decline(trade_id)
	if bool(res.get("ok", false)):
		show_toast("Đã từ chối đề nghị đổi đồ.")
	else:
		show_toast(_ws_trade_reason_text(String(res.get("reason", ""))))
	_refresh_phone()


func _on_ws_trade_cancel_pressed(trade_id: String) -> void:
	var res: Dictionary = online.send_ws_trade_cancel(trade_id)
	if bool(res.get("ok", false)):
		show_toast("Đã hủy đề nghị đổi đồ.")
	else:
		show_toast(_ws_trade_reason_text(String(res.get("reason", ""))))
	_refresh_phone()


func _on_ws_auction_create_pressed() -> void:
	var item_id := _first_owned_item_id()
	if item_id.is_empty():
		show_toast("Túi đang trống — nhặt món rồi mới mở phiên được.")
		return
	# Vong 75: gia khoi diem + thoi gian lay tu o nhap (mac dinh
	# 100.000d / 60 giay khi o trong / go sai; gia < 1.000d kep len
	# 1.000d, thoi gian kep 30..3600 giay theo luat PxbOnline).
	_auction_start_price_vnd = _parse_vnd_input(_phone_auction_price_input,
		AUCTION_CREATE_START_PRICE_VND, PxbOnline.WS_MIN_AUCTION_START_PRICE_VND,
		PxbOnline.WS_MAX_AUCTION_MONEY_VND)
	_auction_duration_s = _parse_vnd_input(_phone_auction_duration_input,
		AUCTION_CREATE_DURATION_S, PxbOnline.WS_MIN_AUCTION_DURATION_S,
		PxbOnline.WS_MAX_AUCTION_DURATION_S)
	var res: Dictionary = online.send_ws_auction_create(item_id,
		_auction_start_price_vnd, _auction_duration_s)
	if bool(res.get("ok", false)):
		show_toast("Đã mở phiên đấu giá: %s — %sđ, %d giây." % [
			_trade_item_name(item_id), _fmt_vnd(_auction_start_price_vnd),
			_auction_duration_s])
	else:
		show_toast(_ws_auction_reason_text(String(res.get("reason", ""))))
	_refresh_phone()


func _on_ws_auction_bid_pressed(auction_id: String) -> void:
	var auction := {}
	for a in online.ws_auctions:
		if String((a as Dictionary).get("auction_id", "")) == auction_id:
			auction = a
			break
	if (auction as Dictionary).is_empty():
		show_toast("Không tìm thấy phiên đó nữa.")
		_refresh_phone()
		return
	# Vong 75: gia dau lay tu o nhap (de trong = gia tiep theo);
	# go thap hon gia tiep theo thi bao loi, khong gui.
	var amount := _ws_auction_bid_amount(auction)
	if amount < 0:
		show_toast("Giá đấu phải từ %sđ trở lên." % _fmt_vnd(_ws_auction_next_bid(auction)))
		return
	_bid_amount_vnd = amount
	var res: Dictionary = online.send_ws_auction_bid(auction_id, amount)
	if bool(res.get("ok", false)):
		show_toast("Đã đặt giá %sđ." % _fmt_vnd(amount))
	else:
		show_toast(_ws_auction_reason_text(String(res.get("reason", ""))))
	_refresh_phone()


func _on_ws_auction_cancel_pressed(auction_id: String) -> void:
	var res: Dictionary = online.send_ws_auction_cancel(auction_id)
	if bool(res.get("ok", false)):
		show_toast("Đã gửi yêu cầu hủy phiên đấu giá.")
	else:
		show_toast(_ws_auction_reason_text(String(res.get("reason", ""))))
	_refresh_phone()


func _on_ws_auction_list_pressed() -> void:
	var res: Dictionary = online.request_ws_auction_list()
	if not bool(res.get("ok", false)):
		show_toast(_ws_auction_reason_text(String(res.get("reason", ""))))
	_refresh_phone()


# De nghi den: dang mo tab Tin nhan thi lam tuoi ngay (nut Chap
# nhan / Tu choi hien trong dien thoai), khong thi bao so chua doc.
func _on_ws_trade_offer_received(offer: Dictionary) -> void:
	if phone_open and phonehub.current_tab == PxbPhoneHub.TAB_DANH_BA_TIN_NHAN:
		_refresh_phone()
	else:
		phonehub.notify(PxbPhoneHub.TAB_DANH_BA_TIN_NHAN)
	show_toast("Có đề nghị đổi đồ mới từ %s." % _ws_player_name(String(offer.get("from_player_id", ""))))


func _on_ws_trade_offered_sent(_trade: Dictionary) -> void:
	_refresh_phone()


func _on_ws_trade_declined(_trade_id: String, _reason: String) -> void:
	show_toast("Đề nghị đổi đồ bị từ chối.")
	_refresh_phone()


func _on_ws_trade_cancelled(_trade_id: String, _reason: String) -> void:
	show_toast("Đề nghị đổi đồ đã bị hủy.")
	_refresh_phone()


func _on_ws_trade_error(reason: String) -> void:
	show_toast(_ws_trade_reason_text(reason))
	_refresh_phone()


# Phien moi / co gia moi: dang mo tab Cho thi lam tuoi ngay, khong
# thi bao so chua doc o tab Cho.
func _on_ws_auction_created(auction: Dictionary) -> void:
	if phone_open and phonehub.current_tab == PxbPhoneHub.TAB_CHO:
		_refresh_phone()
	else:
		phonehub.notify(PxbPhoneHub.TAB_CHO)
	show_toast("Đã mở phiên đấu giá %s." % _trade_item_name(String(auction.get("item_id", ""))))


func _on_ws_auction_bid(_auction: Dictionary) -> void:
	if phone_open and phonehub.current_tab == PxbPhoneHub.TAB_CHO:
		_refresh_phone()
	else:
		phonehub.notify(PxbPhoneHub.TAB_CHO)


# Vong 102: minh vua bi vuot gia (chi server gui cho minh) —
# bao ro gia cu / gia moi; tien giu ho cua gia cu da duoc server
# giai phong, vi se cap nhat khi ack ledger_sync ve (client tu
# sync o PxbOnline). Khong bao khi tin khong phai cho minh.
func _on_ws_auction_outbid(auction: Dictionary, old_bid: int, old_bidder_player_id: String) -> void:
	if old_bidder_player_id != online.ws_player_id:
		return
	var item_name := _trade_item_name(String(auction.get("item_id", "")))
	if item_name.is_empty():
		item_name = String(auction.get("item_id", ""))
	show_toast("Bạn đã bị vượt giá %s — giá mới %sđ (giá cũ của bạn %sđ)." % [
		item_name, _fmt_vnd(int(auction.get("current_bid", 0))), _fmt_vnd(old_bid)])
	_refresh_phone()


func _on_ws_auction_list(_auctions: Array) -> void:
	if phone_open and phonehub.current_tab == PxbPhoneHub.TAB_CHO:
		_refresh_phone()


func _on_ws_auction_cancelled(_auction_id: String, _reason: String) -> void:
	show_toast("Phiên đấu giá đã bị hủy.")
	_refresh_phone()


func _on_ws_auction_error(reason: String) -> void:
	show_toast(_ws_auction_reason_text(reason))
	_refresh_phone()


func _on_upload_pressed(slot: int) -> void:
	var res := savecloud.upload_save(slot)
	match String(res.get("reason", "")):
		"server-chua-co-endpoint":
			show_toast("Server chưa có endpoint save — chưa đồng bộ lên cloud.")
		"chua-dang-nhap":
			show_toast("Chưa đăng nhập nên chưa đồng bộ được.")
		_:
			show_toast("Đồng bộ: %s" % String(res.get("reason", "")))
	_refresh_phone()


func _on_open_jobs_pressed() -> void:
	_close_phone()
	_show_jobs_dialogue()

# --- UI ---
# Theme chung kieu Nadia: giay vang am + vien go nau + bong mem — 1 theme
# dung cho ca game (HUD / dien thoai / doi thoai / title). Dien thoai
# la hub gon nhu Nadia: khung go dam hon, goc bo tron lon.
func _panel_style(bg: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.corner_radius_top_left = 12
	s.corner_radius_top_right = 12
	s.corner_radius_bottom_left = 12
	s.corner_radius_bottom_right = 12
	s.border_color = Color(0.45, 0.30, 0.16, 1)
	s.set_border_width_all(3)
	s.shadow_color = Color(0, 0, 0, 0.25)
	s.shadow_size = 5
	s.shadow_offset = Vector2(0, 3)
	s.content_margin_left = 18
	s.content_margin_right = 18
	s.content_margin_top = 14
	s.content_margin_bottom = 14
	return s

# Khung dien thoai: vo go dam + goc bo tron lon — nhin nhu 1 thiet bi
# trong the gioi (hub cua Nadia), khong phai panel menu thuong.
func _phone_panel_style() -> StyleBoxFlat:
	var s := _panel_style(Color(0.99, 0.97, 0.92, 1.0))
	s.set_corner_radius_all(18)
	s.set_border_width_all(4)
	s.border_color = Color(0.38, 0.24, 0.12, 1)
	return s

func _style_button(b: Button, font_size: int = 26) -> void:
	# Vong 13: moi nut qua day deu FOCUS_NONE — nut giu focus ban
	# phim thi phim mui ten (ui_*) bi he focus navigation an mat
	# truoc khi toi _unhandled_input (loi that live 12:56 21/11).
	# Tat ca 8 cho Button.new() trong main.gd deu goi _style_button
	# nen 1 dong nay bao phu het, ke ca nut them sau nay.
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", font_size)
	b.add_theme_font_override("font", font)
	b.add_theme_color_override("font_color", Color(1.0, 0.96, 0.88, 1))
	b.add_theme_color_override("font_hover_color", Color(1.0, 0.98, 0.92, 1))
	b.add_theme_color_override("font_pressed_color", Color(0.95, 0.90, 0.80, 1))
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.62, 0.42, 0.22, 1)
	normal.set_corner_radius_all(10)
	normal.border_color = Color(0.42, 0.27, 0.13, 1)
	normal.set_border_width_all(2)
	normal.content_margin_left = 12
	normal.content_margin_right = 12
	normal.content_margin_top = 8
	normal.content_margin_bottom = 8
	normal.shadow_color = Color(0, 0, 0, 0.25)
	normal.shadow_size = 3
	normal.shadow_offset = Vector2(0, 2)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.72, 0.50, 0.28, 1)
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.50, 0.33, 0.16, 1)
	pressed.shadow_size = 0
	pressed.shadow_offset = Vector2.ZERO
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", pressed)
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

# --- Anh sang ngay/dem theo khung (art pass 20/11 buoi 2) ---
# Overlay mau phu len the gioi: Sang trong suot, Chieu vang cam
# golden-hour, Toi xanh dem dam.
# Vong 5 (20/11 14:40) — LOI GOC: overlay cu o CanvasLayer layer 0
# (cung lop voi canvas mac dinh): thu tu ve giua lop overlay va
# IsoMap/player phu thuoc thu tu cay — lop phu chi chac chan ap
# cho phan them truoc no, phan them sau (nen/nhan vat) co the thoat
# khoi lop phu -> khung Toi/Chieu chia doi sang/toi theo vung
# (kiem live 14:34: 1/3 phai TAP HOA van sang). Sua tan goc:
# overlay vao CanvasLayer layer 1 RIENG, tao TRUOC lop nhan + lop
# HUD (cung layer 1, ve sau) -> lop phu phu DEU len TOAN BO the
# gioi (nen + dat + nhan vat + dom sang) duoi HUD, khong con
# duong chia. Lop phu la nguon duy nhat doi mau theo khung —
# khong tint rieng nhan vat nua (tint rieng + lop MUL nhan doi
# lam nhan vat thanh bong den, kiem live 14:34).
func _daynight_color(f: int) -> Color:
	# Overlay dung che do NHAN (CanvasItemMaterial BLEND_MODE_MUL):
	# toi di ca anh nhung giu tuong phan — nha/cua van nhin thay,
	# khong bi lop alpha dac nuot (loi khung Toi van sang, 20/11 10:30).
	# Sang = trang (khong doi); Chieu = vang cam; Toi = xanh dem.
	# Toi voi anh nen dem rieng (1-2): anh dem da toi san (~0.65)
	# nen MUL nhe (0.7 thay 0.55): nhan vat (khong tint rieng nua)
	# con ~0.7 do sang — thay ro mat/quan ao, hoa vao canh dem
	# chu khong thanh bong den (loi 20/11 14:34).
	match f:
		1:
			return Color(1.0, 0.82, 0.55, 1.0)
		2:
			if iso_map != null and iso_map.has_night_bg:
				return Color(0.7, 0.78, 0.95, 1.0)
			return Color(0.55, 0.62, 0.9, 1.0)
	return Color(1.0, 1.0, 1.0, 1.0)

## Chong-chong nhan (vong 4, 20/11 14:00, sua lan 2; vong 5 tang khe
## ho: LABEL_GAP 4 -> 12, vat can cao hon de nhan khong cham toc
## nhan vat — kiem live 14:34: "Goc Che Tao" gan cham toc, mep nhan
## cham mep nhau khong co khe ho).
const LABEL_GAP := 12.0
# Nhan duoc dich doc toi da 120px khoi vi tri muon (vong 12, truoc
# 60): 120px ~ 3 chieu cao nhan — van gan neo, doc duoc la cua ai.
# Qua 120px thi GIU y muon thay vi bay den khoang trong xa (loi
# Map002 21/11: "Sap rau" bay 212px len troi, "Cua di" bay 606px).
# 120 du de "Goc Che Tao" (want 978 -> cho trong 1067, cach 89px)
# tach khoi "Goc phe lieu cho" ma khong bay xa.
const LABEL_MAX_DRIFT := 120.0
# Vong 12b: gioi han nhay xa de thoat nhan vat / D-pad — nhan
# chi duoc nhay toi da 200px (~5 chieu cao nhan) de thoat dau
# nhan vat / nut D-pad; xa hon thi GIU NEO (nhan o yen, du co
# che nhan vat 1 chut) vi nhay 200-600px moi la loi "nhan bay
# len troi" ma kiem live bao. So do thuc te 21/11: thoat D-pad
# 121px, "Goc Che Tao" Map001 165px, "Hem tro" (11,8) 135px
# (duoc nhay); "Sap rau" Map002 spawn 249px (KHONG nhay).
const LABEL_ESCAPE_MAX_DRIFT := 200.0
# Vong 12: hinh chu nhat nut D-pad (toa do game) — dung chung cho
# vat can resolver va luat thoat khi nhan de len nut.
const DPAD_RECT := Rect2(Vector2(48, 880), Vector2(160, 160))
# Nhan khong xuong qua y=1200 man hinh (truoc 1264): "Cua ra Cho
# Dau Moi" sat mep duoi gan bi cat (kiem live 14:34); de 80px
# thoang o day man hinh.
const LABEL_BOTTOM_MAX := 1200.0

func _sprite_obstacle_rect(screen_pos: Vector2) -> Rect2:
	# Vong 64: tinh tu CharacterSprite.TEX_HEIGHT (128, vong 63)
	# x zoom camera hien tai — khong hard-code so thoi 104/zoom 1.4
	# nua. Ti le giu nguyen nhu ban cu (104 world, zoom 1.4, rect
	# (-48,-165,96,115)): rong 96/(104*1.4), nguc -50/(104*1.4)
	# theo TEX_HEIGHT; dinh = -(TEX_HEIGHT*zoom + 15) — toc + bien
	# toc 15px man hinh (vong 5). O zoom 1.25: (-52.7,-175,105.4,
	# 120.1): dinh cao hon dinh dau that (-157px) 18px, day o nguc
	# -55px, rong phu NPC rong nhat (83 world -> 104px).
	var z := CAMERA_ZOOM
	var cam := get_viewport().get_camera_2d()
	if cam != null:
		z = cam.zoom.y
	var top := -(CharacterSprite.TEX_HEIGHT * z + 15.0)
	var chest := -(50.0 / (104.0 * 1.4)) * CharacterSprite.TEX_HEIGHT * z
	var w := (96.0 / (104.0 * 1.4)) * CharacterSprite.TEX_HEIGHT * z
	return Rect2(screen_pos + Vector2(-w / 2.0, top), Vector2(w, chest - top))

## Vong 66: hinh chu nhat DAU NPC (mat/toc) tu vat can sprite:
## cung dinh + rong voi _sprite_obstacle_rect, cao 32 world
## (dau) x zoom + 15px bien toc — khop _head_rect trong test
## r64/r66 (dau = 32 world tren dinh anh that).
func _npc_head_rect(screen_pos: Vector2) -> Rect2:
	var ob := _sprite_obstacle_rect(screen_pos)
	var z := CAMERA_ZOOM
	var cam := get_viewport().get_camera_2d()
	if cam != null:
		z = cam.zoom.y
	return Rect2(ob.position, Vector2(ob.size.x, 32.0 * z + 15.0))

## Vong 12b: nhan co DE LEN nhan vat chinh / nut D-pad khong?
## Giao nhau phai >= 10px CA 2 chieu moi tinh — quet nhe vai px
## thi khong dang ke. Chi xet 2 thu "khong duoc che": dau/than
## nhan vat chinh (tam man hinh) va nut D-pad (nut bam). De len
## sprite NPC hay icon thi CHAP NHAN — neo quan trong hon, va
## nhay xa 200-600px de tranh NPC moi la loi (nhan bay len troi,
## mat neo). NGOAI LE vong 66: chi DAU NPC (mat/toc) thi khong
## chap nhan — xem _label_hits_other_npc_head (phat hien §87.3).
func _label_hits_player_or_dpad(r: Rect2, player_rect: Rect2) -> bool:
	if player_rect.size != Vector2.ZERO:
		var inter := r.intersection(player_rect)
		if inter.size.x >= 10.0 and inter.size.y >= 10.0:
			return true
	if _dpad != null and _dpad.visible:
		var inter2 := r.intersection(DPAD_RECT)
		if inter2.size.x >= 10.0 and inter2.size.y >= 10.0:
			return true
	return false

## Vong 66: nhan co DE LEN DAU NPC KHAC dang ke khong? (mat/toc
## — 32 world tren dinh anh + 15px bien toc, lay tu
## _npc_head_rect.) Giao nhau >= 10px ca 2 chieu moi tinh (nhu
## luat thoat nhan vat chinh). Chi xet NPC (nhan dang xet la
## hotspot/craft/door — khong phai NPC; nhan NPC co dinh, khong
## dich). Than/nguc NPC khong tinh: nhan de than 1 chut van doc
## duoc, chi mat moi khong duoc che (phat hien §87.3: "Sap rau
## buoi toi" che mat Chi Le o camera (9,2) Toi, giao 63.8x34.3px,
## best_y cach 157px — trong 200px nhung vuot 120px nen vong
## chinh giu neo; mo rong thoat cho dau NPC thi nhan nhay len
## best_y ma van trong luat neo).
func _label_hits_other_npc_head(r: Rect2) -> bool:
	if iso_map == null:
		return false
	var ct := get_viewport().get_canvas_transform()
	for mk in iso_map.markers:
		if String(mk.event_data.get("kind", "")) != "npc":
			continue
		var hr := _npc_head_rect(ct * mk.global_position)
		var inter := r.intersection(hr)
		if inter.size.x >= 10.0 and inter.size.y >= 10.0:
			return true
	return false

## Nhan NPC trong the gioi (vong 15, Claude (b)): chi hien khi
## nguoi choi o gan (Manhattan <= Marker.LABEL_NEAR_TILES o).
## Chay truoc _resolve_label_overlaps de rect NPC trong placed la
## trang thai moi nhat trong frame nay.
func _update_npc_labels() -> void:
	if iso_map == null or player == null:
		return
	for mk in iso_map.markers:
		if String(mk.event_data.get("kind", "")) != "npc":
			continue
		var mt: Vector2i = (mk as Marker).tile()
		var d := absi(mt.x - player.tile.x) + absi(mt.y - player.tile.y)
		(mk as Marker).set_label_near(d <= Marker.LABEL_NEAR_TILES)

## Vong 22 — NPC di lang thang (patrol): moi NPC, khi nguoi choi
## o xa (>5 o, cung nguong hien nhan) va khong mo UI/hoi thoai,
## thi thoang buoc sang 1 o dat trong ke ben (khong event, khong
## phai o nguoi choi / NPC khac) roi quay ve nha sau 2-5s. NPC
## luon ve nha truoc khi nguoi choi lai gan — vi event_at /
## is_walkable dung data tinh theo o nha (xem iso_map.gd), nen
## tuong tac E chi dung khi NPC dung dung o nha; di lang thang
## chi de ban do co suc song khi nhin tu xa. Dung yen khi
## title/dien thoai/hoi thoai/tran dau mo (tra ve nha neu dang
## o ngoai). Quyet dinh moi 0.5s, moi NPC nghi ngaunhien 4-9s.
const NPC_PATROL_NEAR := 5
const NPC_PATROL_IDLE_MIN := 4.0
const NPC_PATROL_IDLE_MAX := 9.0
const NPC_PATROL_AWAY_MIN := 2.0
const NPC_PATROL_AWAY_MAX := 5.0

func _update_npc_patrol(delta: float) -> void:
	if iso_map == null or player == null:
		return
	_npc_patrol_tick += delta
	if _npc_patrol_tick < 0.5:
		return
	_npc_patrol_tick = 0.0
	var blocked := dialogue_open or phone_open or battle_open or title_open
	for mk in iso_map.markers:
		if String(mk.event_data.get("kind", "")) != "npc":
			continue
		var m := mk as Marker
		if m.patrol_moving():
			continue  # Cho tween xong moi lenh tiep.
		var mid := m.get_instance_id()
		if not _npc_patrol_wait.has(mid):
			# Lan gap dau: nghi ngau nhien 4-9s truoc khi buoc
			# (khong cho ca 2 NPC cung buoc ra ngay tick dau).
			_npc_patrol_wait[mid] = randf_range(NPC_PATROL_IDLE_MIN, NPC_PATROL_IDLE_MAX)
			continue
		var wait: float = float(_npc_patrol_wait.get(mid, 0.0))
		var home := m.home_tile
		var cur := m.patrol_tile()
		if home.x < 0:
			continue  # Marker cu / chua co home (vd test dung le).
		var near_player := _tile_dist(player.tile, home) <= NPC_PATROL_NEAR
		if blocked or near_player:
			if cur != home:
				m.patrol_walk_to(home, iso_map.tile_center(home))
			_npc_patrol_wait[mid] = randf_range(NPC_PATROL_IDLE_MIN, NPC_PATROL_IDLE_MAX)
			continue
		if wait > 0.0:
			_npc_patrol_wait[mid] = wait - 0.5
			continue
		if cur == home:
			var dest := _npc_patrol_pick(home)
			if dest.x < -100:
				_npc_patrol_wait[mid] = randf_range(NPC_PATROL_IDLE_MIN, NPC_PATROL_IDLE_MAX)
			elif m.patrol_walk_to(dest, iso_map.tile_center(dest)):
				_npc_patrol_wait[mid] = randf_range(NPC_PATROL_AWAY_MIN, NPC_PATROL_AWAY_MAX)
			else:
				_npc_patrol_wait[mid] = randf_range(NPC_PATROL_IDLE_MIN, NPC_PATROL_IDLE_MAX)
		else:
			m.patrol_walk_to(home, iso_map.tile_center(home))
			_npc_patrol_wait[mid] = randf_range(NPC_PATROL_IDLE_MIN, NPC_PATROL_IDLE_MAX)

## Chon 1 o dat trong ke ben o nha cho NPC buoc sang: di duoc
## (lop 1 trong + khong NPC tinh) + khong co event nao (khong
## dung len sao/cua/ban che tao) + khong phai o nguoi choi +
## khong phai o hien tai cua NPC khac. Het o thi (-999,-999).
func _npc_patrol_pick(home: Vector2i) -> Vector2i:
	var cands: Array[Vector2i] = []
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var t: Vector2i = home + d
		if not iso_map.is_walkable(t):
			continue
		if not iso_map.event_at(t).is_empty():
			continue
		if t == player.tile:
			continue
		var busy := false
		for mk in iso_map.markers:
			if String(mk.event_data.get("kind", "")) != "npc":
				continue
			if (mk as Marker).patrol_tile() == t:
				busy = true
				break
		if busy:
			continue
		cands.append(t)
	if cands.is_empty():
		return Vector2i(-999, -999)
	return cands[randi() % cands.size()]

func _resolve_label_overlaps() -> void:
	if iso_map == null:
		return
	var ct := get_viewport().get_canvas_transform()
	var obstacles: Array[Rect2] = []
	# Vat can CUNG cho luot tach sau vong chinh: chi nhan vat
	# chinh + nut D-pad + sprite NPC — KHONG tinh bieu tuong
	# icon (sao/ban/cua 48px): nhan tach ra duoc phep che icon
	# vai px (vd "Goc Che Tao" o 1062 che chan icon cua no
	# 13px) chu khong duoc che dau nhan vat / nut bam. Vong
	# chinh van tranh ca icon (obstacles day du).
	var hard_obstacles: Array[Rect2] = []
	if player != null:
		obstacles.append(_sprite_obstacle_rect(ct * player.position))
		hard_obstacles.append(_sprite_obstacle_rect(ct * player.position))
	# Vong 12: nut D-pad (man hinh, x 48..208, y 880..1040) la vat
	# can — nhan (vd "Cua ra Cho Dau Moi" khi nguoi choi di xuong
	# cuoi map, nhan troi len dung hang nut) khong duoc de len nut.
	# D-pad ve tren lop UI (tren nhan) nen nut van bam duoc, nhung
	# nhan chui duoi nut thi khong doc duoc.
	if _dpad != null and _dpad.visible:
		obstacles.append(DPAD_RECT)
		hard_obstacles.append(DPAD_RECT)
	for mk in iso_map.markers:
		var sp: Vector2 = ct * mk.global_position
		if String(mk.event_data.get("kind", "")) == "npc":
			obstacles.append(_sprite_obstacle_rect(sp))
			hard_obstacles.append(_sprite_obstacle_rect(sp))
		elif String(mk.event_data.get("kind", "")) in ["hotspot", "craft", "door"]:
			# Bieu tuong sao/ban/cua (~48x48px man hinh): nhan "Hem
			# tro buoi toi" khong duoc che mui ten xanh / sao
			# (kiem live 14:34). Vat can nho, chi bao ve tam bieu
			# tuong, khong day nhan di xa.
			obstacles.append(Rect2(sp + Vector2(-24, -24), Vector2(48, 48)))
	# Vong 45: bien sap (NadiaScene) la vat can vong chinh — nhan
	# hotspot/craft/door tranh bien nhu tranh icon ("Goc Che Tao"
	# Map002 de bien "GIA VI", "Sap rau buoi sang" de bien hang
	# sap; anh that r45-01). KHONG dua vao hard_obstacles (bien
	# khong phai nut bam / dau nhan vat — neu khong con khoang
	# trong gan thi nhan duoc phep che bien 1 chut chu khong bay
	# xa mat neo). Nhan NPC khong dich duoc nen bien khong cuu
	# duoc "Anh Hai" (xem docs/godot-g4.md §67.4).
	if iso_map.nadia_scene != null:
		obstacles.append_array(iso_map.nadia_scene.stall_sign_screen_rects())
	# Nhan NPC trong the gioi (vong 15): co dinh tren dau NPC,
	# resolver KHONG dich duoc (dich la roi neo) — chi ghi rect
	# cua chung vao placed truoc de nhan khac (hotspot/cua/che
	# tao) tranh; khong dat label_override cho NPC.
	var placed: Array[Rect2] = []
	var entries: Array = []
	for mk in iso_map.markers:
		var r: Rect2 = mk.label_screen_rect()
		if r.size == Vector2.ZERO:
			mk.label_override = Rect2()
			continue
		if String(mk.event_data.get("kind", "")) == "npc":
			placed.append(r)
			mk.label_override = Rect2()
		else:
			entries.append({"mk": mk, "rect": r})
	# Nhan tren truoc (y tang dan) — vong 12b: thu tu nay giu nhan
	# tren neo dung y muon (vd "Sap rau" Map002 o 818); thu tu nguoc
	# (y giam dan, thu vong 12b) lam nhan cua day nhan tren xuong
	# toi 556px vi vat can cua cua che mat khoang trong gan 978.
	# Nhan cua cham nhau 7px o cuoi map thi xu ly rieng bang luot
	# tach sau vong chinh (day nhan tren len 19px) chu khong doi
	# thu tu.
	entries.sort_custom(func(a, b):
		return a["rect"].position.y < b["rect"].position.y)
	for e in entries:
		var r: Rect2 = e["rect"]
		var want_y := r.position.y
		var best_y := _nearest_free_y(r, obstacles, placed)
		if best_y < 0.0 or absf(best_y - want_y) > LABEL_MAX_DRIFT:
			# Khoang doc gan nhat qua xa — thu dich ngang giu
			# nguyen y (uu tien dich phai, roi dich trai). Dich
			# ngang cung phai giu khe LABEL_GAP voi vat can /
			# nhan da dat (grow 12px roi moi intersects): chi
			# kiem intersects() tho se chap nhan vi tri chi cach
			# 4px (vd "Goc Che Tao" sat "Co Tu", kiem live
			# 14:34) — khong du khe ho nhin.
			var shifted := false
			for dx in [40.0, 80.0, 120.0, 160.0, -40.0, -80.0, -120.0, -160.0]:
				var cand := Rect2(r.position + Vector2(dx, 0), r.size)
				cand.position.x = clampf(cand.position.x, 16.0, 704.0 - r.size.x)
				if cand.position.x == r.position.x:
					continue
				var hit := false
				var grown := cand.grow(LABEL_GAP)
				for o in obstacles:
					if grown.intersects(o):
						hit = true
						break
				if not hit:
					for p in placed:
						if grown.intersects(p):
							hit = true
							break
				if not hit:
					r.position = cand.position
					shifted = true
					break
			# Vong 12 (loi Map002 21/11): dich ngang that bai thi
			# GIU NGUYEN y muon — KHONG ap best_y o xa. Truoc day
			# fallback ap best_y ke ca khi cach want_y 200-600px
			# nen "Sap rau buoi sang" (want 818) bi day len 606
			# va "Cua di Khu Cong Nhan" (want 1162) bi day len
			# 556 — nhan troi thanh cot o vung troi, mat neo.
			# Chong len sprite 1 chut van doc duoc; bay xa thi
			# khong con biet nhan cua ai. (best_y < 0: khong co
			# khoang trong nao — cung giu y muon nhu cu.)
			# NGOAI LE vong 12b: neu nhan o y muon DE LEN nhan
			# vat chinh / nut D-pad dang ke (vd "Goc Che Tao"
			# Map001 de len dau nhan vat 96x38px; "Cua ra Cho
			# Dau Moi" o (11,8) de len nut D-pad 97x38px) thi
			# CHAP NHAN best_y xa — nhung TOI DA 200px
			# (LABEL_ESCAPE_MAX_DRIFT). Xa hon thi giu neo
			# (vd "Sap rau" Map002 spawn: best_y 1067 cach
			# 249px — nhay thi mat neo, dung yen thi chi che
			# nhan vat tam thoi khi nguoi choi dung o spawn).
			# De len than NPC/icon thi khong tinh (giu neo; xem
			# _label_hits_player_or_dpad). Vong 66: de len DAU
			# NPC khac dang ke (>= 10px ca 2 chieu) thi thoat nhu
			# nhan vat chinh (toi da 200px) — xem
			# _label_hits_other_npc_head.
			# Vong 45: da thu mo rong ngoai le cho BIEN SAP
			# (de bien dang ke thi nhay toi da 200px) nhung
			# PHAI BO — nhay xa pha vo bat buoc neo <=120px
			# (artpass12: "Sap rau" roi neo -161px; artpass4/5:
			# "Hem tro buoi toi" nhay len de dau nhan vat).
			# Bien che nhe thi chap nhan (xem test g4_polish:
			# ngoai le "Sap rau" de THIT HEO 15x20px); chi
			# truong hop nao co khoang trong trong vong 120px
			# thi resolver tu dich qua _nearest_free_y vi bien
			# da nam trong obstacles.
			if not shifted:
				var p_rect := Rect2()
				if player != null:
					p_rect = _sprite_obstacle_rect(ct * player.position)
				if best_y >= 0.0 and absf(best_y - want_y) <= LABEL_ESCAPE_MAX_DRIFT and (_label_hits_player_or_dpad(r, p_rect) or _label_hits_other_npc_head(r)):
					r.position.y = best_y
		else:
			r.position.y = best_y
		r.position.x = clampf(r.position.x, 16.0, 704.0 - r.size.x)
		r.position.y = clampf(r.position.y, 190.0, LABEL_BOTTOM_MAX - r.size.y)
		placed.append(r)
		e["mk"].label_override = r
	# Vong 65: bien sap de luot tach tranh — xem _nudge_clear_of_signs.
	var sign_rects: Array[Rect2] = []
	if iso_map.nadia_scene != null:
		sign_rects = iso_map.nadia_scene.stall_sign_screen_rects()
	# Vong 12b — luot tach nhan con chong nhau: sau vong chinh
	# van co the con cap nhan chong nhau (vd 2 nhan cua Map002
	# cham nhau 7px o spawn, 20px o (4,4): nhan duoi kep o day
	# 1162 khong dich xuong duoc, nhan tren thi vong chinh khong
	# biet nhan duoi se toi). Day nhan TREN len tren vua du
	# (chong + LABEL_GAP), mien la khong vuot top 190 va khong
	# de len vat can CUNG / nhan khac; neu bi 1 nhan khac chan
	# thi day luon nhan do len 1 nac (cascade 1 cap — vd "Cua
	# ve" muon len 1112 nhung "Goc Che Tao" o 1081 chan, thi
	# day "Goc Che Tao" len 1062 truoc); neu khong day len duoc
	# thi day nhan DUOI xuong (mien khong vuot day 1200). Lap
	# toi da 3 luot vi 1 lan day co the tao chong moi voi nhan
	# phia tren.
	for _pass in range(3):
		var moved := false
		for i in range(entries.size()):
			for j in range(i + 1, entries.size()):
				var ri: Rect2 = entries[i]["mk"].label_override
				var rj: Rect2 = entries[j]["mk"].label_override
				if ri.size == Vector2.ZERO or rj.size == Vector2.ZERO:
					continue
				var inter := ri.intersection(rj)
				if inter.size.x <= 0.0 or inter.size.y <= 0.0:
					continue
				var up_i := i if ri.position.y <= rj.position.y else j
				var dn_i := j if ri.position.y <= rj.position.y else i
				var up_r: Rect2 = entries[up_i]["mk"].label_override
				var dn_r: Rect2 = entries[dn_i]["mk"].label_override
				# Thu day nhan tren len (co cascade 1 cap).
				var cand_up := Rect2(Vector2(up_r.position.x, dn_r.position.y - up_r.size.y - LABEL_GAP), up_r.size)
				cand_up = _nudge_clear_of_signs(cand_up, sign_rects, hard_obstacles)
				if cand_up.position.y >= 190.0 and _try_move_up(up_i, cand_up, hard_obstacles, entries, sign_rects):
					moved = true
					continue
				# Khong len duoc: day nhan duoi xuong.
				var cand_dn := Rect2(Vector2(dn_r.position.x, up_r.end.y + LABEL_GAP), dn_r.size)
				cand_dn = _nudge_clear_of_signs(cand_dn, sign_rects, hard_obstacles)
				if cand_dn.end.y <= LABEL_BOTTOM_MAX and not _rect_hits_any(cand_dn, hard_obstacles, entries, dn_i):
					entries[dn_i]["mk"].label_override = cand_dn
					moved = true
		if not moved:
			break

## Day nhan o idx len vi tri cand (da tinh san): cho phep neu
## cand khong de len vat can cung / nhan khac; neu chi bi 1
## nhan khac chan thi day luon nhan do len 1 nac nua (cascade
## 1 cap) roi moi day nhan nay. Tra false neu khong day duoc.
## Vong 65: nhan bi day len (cascade) cung khong duoc de len
## bien sap — neu khong, luot tach lai tao ra chong bien moi.
func _try_move_up(idx: int, cand: Rect2, hard_obstacles: Array[Rect2], entries: Array, signs: Array[Rect2] = []) -> bool:
	var blocker_idx := -1
	for o in hard_obstacles:
		if cand.intersects(o):
			return false
	for k in range(entries.size()):
		if k == idx:
			continue
		var ov: Rect2 = entries[k]["mk"].label_override
		if ov.size != Vector2.ZERO and cand.intersects(ov):
			if blocker_idx >= 0:
				return false
			blocker_idx = k
	if blocker_idx < 0:
		entries[idx]["mk"].label_override = cand
		return true
	# Bi 1 nhan chan: day nhan do len truoc (len tren cand).
	var blk: Rect2 = entries[blocker_idx]["mk"].label_override
	var cand_blk := Rect2(Vector2(blk.position.x, cand.position.y - blk.size.y - LABEL_GAP), blk.size)
	if cand_blk.position.y < 190.0:
		return false
	for s in signs:
		if cand_blk.intersects(s):
			return false
	if _rect_hits_any(cand_blk, hard_obstacles, entries, blocker_idx, idx):
		return false
	entries[blocker_idx]["mk"].label_override = cand_blk
	entries[idx]["mk"].label_override = cand
	return true

## Kiem tra hinh chu nhat co de len vat can (tho, khong grow)
## hay nhan da dat nao khac (tru nhan o skip_idx / skip_idx2) khong.
func _rect_hits_any(r: Rect2, obstacles: Array[Rect2], entries: Array, skip_idx: int, skip_idx2: int = -1) -> bool:
	for o in obstacles:
		if r.intersects(o):
			return true
	for k in range(entries.size()):
		if k == skip_idx or k == skip_idx2:
			continue
		var ov: Rect2 = entries[k]["mk"].label_override
		if ov.size != Vector2.ZERO and r.intersects(ov):
			return true
	return false

## Vong 65 — dich ngang ung vien tach de tranh bien sap: luot tach
## truoc day chi kiem vat can CUNG (nhan vat/D-pad/NPC) nen day
## "Cua ve Xom Tro Cu" len 1112 dung ngay bien GIA VI (35x15px,
## camera (5,2)) — vong chinh tranh bien, luot tach lai day vao.
## Neu ung vien de len bien thi thu dich ngang giu nguyen y
## (+-40/80/120/160, thu tu gan truoc — nhu vong chinh), lay cai
## dau tien sach bien + vat can cung (kiem bang rect grow
## LABEL_GAP cho bien, tho cho vat can cung); khong co thi tra
## ve ung vien goc (giu hanh vi cu, khong bay xa). Chi dich khi
## ung vien de bien — 99% truong hop khong doi gi.
## CO TINH KHONG kiem nhan khac o day: nhan chan dich ngang
## (vd "Goc Che Tao" dang o 1107.25) se duoc luot tach day len
## bang cascade ngay sau do — kiem no o day se chan het moi
## dich ngang (probe vong 65). Chong nhan van do _try_move_up
## (co kiem cascade khong de bien) + luot tach xu ly.
func _nudge_clear_of_signs(cand: Rect2, signs: Array[Rect2], hard_obstacles: Array[Rect2]) -> Rect2:
	var hits := false
	for s in signs:
		if cand.intersects(s):
			hits = true
			break
	if not hits:
		return cand
	for dx in [40.0, -40.0, 80.0, -80.0, 120.0, -120.0, 160.0, -160.0]:
		var shifted := Rect2(cand.position + Vector2(dx, 0.0), cand.size)
		shifted.position.x = clampf(shifted.position.x, 16.0, 704.0 - cand.size.x)
		if shifted.position.x == cand.position.x:
			continue
		var grown := shifted.grow(LABEL_GAP)
		var bad := false
		for s2 in signs:
			if grown.intersects(s2):
				bad = true
				break
		if bad:
			continue
		for o in hard_obstacles:
			if shifted.intersects(o):
				bad = true
				break
		if bad:
			continue
		return shifted
	return cand

## Top gan nhat trong khoang doc trong (khong de len vat can / nhan
## da dat, cach LABEL_GAP). Tra -1 neu khong co khoang trong nao.
func _nearest_free_y(r: Rect2, obstacles: Array[Rect2], placed: Array[Rect2]) -> float:
	var blockers: Array[Rect2] = []
	# Vong 14: chi tinh vat can / nhan da dat khi chong nhau theo
	# X >= 10px — truoc day chong 1px cung tinh (vd mep nhan
	# "Anh Hai" cham mep vat can sprite "Chi Le" dung 1px) lam
	# cat het khoang doc gan neo, day nhan bay -100px len troi
	# (probe 21/11). Chong < 10px thi bo qua — nhan lech nhau
	# vai px van doc duoc, khong dang bay xa.
	for o in obstacles:
		if minf(o.end.x, r.end.x) - maxf(o.position.x, r.position.x) >= 10.0:
			blockers.append(o)
	for p in placed:
		if minf(p.end.x, r.end.x) - maxf(p.position.x, r.position.x) >= 10.0:
			blockers.append(p)
	var top_min := 190.0
	var top_max := LABEL_BOTTOM_MAX - r.size.y
	var intervals: Array = [[top_min, top_max]]
	for b in blockers:
		var next_iv: Array = []
		for iv in intervals:
			var lo: float = iv[0]
			var hi: float = iv[1]
			var b_lo: float = b.position.y - r.size.y - LABEL_GAP
			var b_hi: float = b.end.y + LABEL_GAP
			if b_hi <= lo or b_lo >= hi:
				next_iv.append(iv)
			else:
				if b_lo > lo:
					# Vong 12: chi them khoang CON LAI hop le
					# (lo < hi) — cu them ca khoang rong/dao
					# ([lo, x] voi x <= lo) lam clampf() tra gia
					# tri vo nghia o _nearest_free_y.
					var up := minf(hi, b_lo)
					if up > lo:
						next_iv.append([lo, up])
				if b_hi < hi:
					var dn := maxf(lo, b_hi)
					if dn < hi:
						next_iv.append([dn, hi])
		intervals = next_iv
	var best_y := -1.0
	var best_dist := 1.0e9
	for iv in intervals:
		var y := clampf(r.position.y, iv[0], iv[1])
		var d := absf(y - r.position.y)
		if d < best_dist:
			best_dist = d
			best_y = y
	return best_y

func _update_daynight() -> void:
	# Vong 62: doi dat ngay/dem theo khung (F) — _update_ground chi
	# goi o load_map thi bam F khong doi dat (dat ngay giu sang
	# trong khi nen dem da toi). Goi o day la idempotent.
	_update_ground(current_map_id)
	if _daynight != null:
		_daynight.color = _daynight_color(frame_idx)
	if iso_map != null and iso_map.night_glow != null:
		iso_map.night_glow.set_lit(frame_idx == 2)
	# Vong 19: anh sang ADD (chi khung Toi, nguon = den + cua so cua
	# NightGlow) + su song nho theo khung (la roi ca ngay, dom dom
	# chi dem). Goi moi lan doi khung/doi map — nguon doi theo map.
	if _glow_canvas != null:
		_glow_canvas.set_lit(frame_idx == 2)
		_glow_canvas.set_sources(_glow_sources())
	if _ambient != null:
		_ambient.set_frame(frame_idx)
	if iso_map != null:
		iso_map.set_frame(frame_idx)
		_update_character_tint()
		# Nhan hotspot doi tu "buoi" theo khung (vong 7) + bong do
		# nhan vat theo khung (vong 7).
		var fname := _frame_name()
		if player != null and player.has_method("set_frame"):
			player.set_frame(frame_idx)
		for mk in iso_map.markers:
			if mk.has_method("set_frame_name"):
				mk.set_frame_name(fname)
			if mk.has_method("set_frame"):
				mk.set_frame(frame_idx)
		_refresh_hotspot_player_flags()

## Vong 19: nguon sang cho GlowCanvas — den long + cua so sang cua
## NightGlow (toa do the gioi). Map001-002: spots rong (cua so da
## sang trong anh dem), chi 1 den long; Map003+: them cua so sang.
func _glow_sources() -> Array[Vector2]:
	var out: Array[Vector2] = []
	if iso_map != null and iso_map.night_glow != null:
		out.append_array(iso_map.night_glow.lamps)
		out.append_array(iso_map.night_glow.spots)
	return out

## Hotspot nao dang co nguoi choi dung tren o do thi tat quang
## sang duoi dat (vong 7). Goi khi doi khung, load map, moi buoc di.
func _refresh_hotspot_player_flags() -> void:
	if iso_map == null or player == null:
		return
	for mk in iso_map.markers:
		if String(mk.event_data.get("kind", "")) != "hotspot":
			continue
		if not mk.has_method("set_player_on"):
			continue
		var t: Array = mk.event_data.get("tile", [])
		var on := t.size() == 2 and Vector2i(int(t[0]), int(t[1])) == player.tile
		mk.set_player_on(on)

## Tint nhan vat theo khung: Vong 5 BO tint rieng — lop overlay MUL
## thong nhat (CanvasLayer layer 1, tren toan bo the gioi) da toi
## nhan vat cung muc voi nen. Tint rieng truoc day nhan them 1 nac
## (overlay 0.55 x tint 0.42 = 0.23) lam nhan vat thanh bong den
## chi con mat trang (kiem live 14:34).
## Vong 62 — NGOAI LE co dieu kien cho Map001-002: tu khi dat co
## ban dem rieng (ground_map00N_night.png, toi san ~0.6), dat dem
## sau MUL ve ~0.42 trong khi nhan vat chi co MUL (0.7) nen "dan"
## tren dat toi (anh dem r61: nhan vat sang hon ca nen). Tint dem
## (0.60,0.62,0.70) x MUL (0.7,0.78,0.95) = ~(0.42,0.48,0.67),
## gan bang dat dem — nhan vat hoa vao canh dem chu khong thanh
## bong den (khac loi 20/11: luc do dat KHONG co ban dem, tint
## rieng la nac thu 2 khong co co so). Chi ap khi map co dat dem
## (frame 2 + _night_ground_path != ""); map khac giu trang.
func _update_character_tint() -> void:
	var tint := Color(1, 1, 1, 1)
	if frame_idx == 2 and _night_ground_path(current_map_id) != "":
		tint = Color(0.60, 0.62, 0.70, 1)
	if player != null:
		player.set_tint(tint)
	if iso_map != null:
		for mk in iso_map.markers:
			if mk.has_method("set_tint"):
				mk.set_tint(tint)

func _build_ui() -> void:
	# Nen dat ve tay: mac dinh ground_wide.jpg (anh chup, dung cho
	# moi map); Map001 doi sang ground_map001.png, Map002 doi sang
	# ground_map002.png ve tay khi co (_update_ground goi trong
	# load_map) — het lech phong cach voi mat tien ve tay (nit
	# §38.4 vong 16; vong 20 cho Map002). Them o index 0 cua Main
	# (duoi iso_map/player) de khong che vat; vi tri co dinh vi moi
	# map 12x9 deu cung offset.
	if ResourceLoader.exists("res://art/ground_wide.jpg"):
		var gtex := load("res://art/ground_wide.jpg") as Texture2D
		var g := Sprite2D.new()
		g.texture = gtex
		g.scale = Vector2(1400.0 / float(gtex.get_width()), 900.0 / float(gtex.get_height()))
		g.position = Vector2(360, 700)  # Vong 12: mep tren o y=250
			# (truoc 280) — chong len day anh troi (world y 252),
			# kin khe ho 28px giua anh troi va anh dat gay ra dai
			# toi ngang man hinh o Map002 (kiem live 12:56 21/11).
			# Day anh xuong toi y=1150, van du sau tam nhin sau
			# nhat (day map world y ~869).
		add_child(g)
		move_child(g, 0)
		_ground_sprite = g
	# Camera bam nguoi choi, zoom CAMERA_ZOOM de thay het map luc
	# spawn (dinh mat tien toi day dat + xe dap, vong 7).
	_camera = Camera2D.new()
	_camera.zoom = Vector2(CAMERA_ZOOM, CAMERA_ZOOM)
	_camera.position_smoothing_enabled = true
	_camera.position_smoothing_speed = 10.0
	add_child(_camera)
	_camera.make_current()
	# Lop overlay ngay/dem: CanvasLayer RIENG, layer 1, tao TRUOC lop
	# nhan + lop HUD (cung layer 1, ve sau) — phu DEU len toan bo
	# the gioi (nen + dat + nhan vat + dom sang), duoi nhan/HUD.
	# Vong 5 (20/11 14:40): layer 0 cu cung lop voi canvas mac
	# dinh, thu tu ve phu thuoc thu tu cay -> khung Toi/Chieu chia
	# doi sang/toi theo vung (1/3 phai TAP HOA van sang, kiem live
	# 14:34). Layer 1 chac chan o tren canvas mac dinh (lop 0) nen
	# khong con truong hop nao thoat khoi lop phu.
	# Vong 6 (20/11 16:xx): LOI GOC THU 2 — follow_viewport_enabled
	# = true khien lop nay BAM THEO CAMERA: ColorRect (0,0)-(720,1280)
	# thanh hinh chu nhat THE GIOI x 0..720, khong phai man hinh.
	# Luc spawn camera x=280, lop phu man hinh -32..976 (du) nen
	# khong thay loi; camera sang phai cuoi map x=600 thi lop chi
	# phu toi man hinh x=528, phan phai x>528 thoat lop phu -> dai
	# doc sang nhu ban ngay, cat doi cua so TAP HOA (do pixel:
	# ran gioi dung x=527 ca Chieu lan Toi, khop (720-600)*1.4+360).
	# SUA: follow_viewport PHAI false (mac dinh) — CanvasLayer
	# khong theo viewport thi o khong gian man hinh, ColorRect
	# 720x1280 phu kin man hinh bat ke camera o dau. KHONG BAO GIO
	# bat follow_viewport cho lop overlay toan man hinh.
	_overlay_layer = CanvasLayer.new()
	_overlay_layer.layer = 1
	add_child(_overlay_layer)
	_daynight = ColorRect.new()
	_daynight.position = Vector2.ZERO
	_daynight.size = Vector2(720, 1280)
	_daynight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_daynight.color = _daynight_color(frame_idx)
	# Che do NHAN: toi ca anh nhung giu tuong phan (xem _daynight_color).
	var mul := CanvasItemMaterial.new()
	mul.blend_mode = CanvasItemMaterial.BLEND_MODE_MUL
	_daynight.material = mul
	_overlay_layer.add_child(_daynight)
	# Vong 19: anh sang cong don that (ADD) tren lop MUL — GlowCanvas
	# la con cua _overlay_layer, them SAU _daynight (ve tren lop nhan)
	# nhung truoc _label_layer/_ui_layer (them sau, cung layer 1)
	# nen van duoi nhan/HUD.
	_glow_canvas = GlowCanvas.new()
	_overlay_layer.add_child(_glow_canvas)
	# Vong 19: su song nho — la roi + dom dom, Node2D the gioi,
	# z_index 10 nhu SkyEffects/NightGlow (tren IsoMap, duoi lop MUL).
	_ambient = AmbientLife.new()
	add_child(_ambient)
	# Lop nhan: CanvasLayer rieng, layer 1, tao TRUOC lop HUD nen ve
	# duoi HUD — nhan luon tren nhan vat + nha (Node2D the gioi o
	# layer 0), khong bi y-sort che mat nua, khong de len panel dien
	# thoai / hop thoai (lop HUD ve sau, tren cung).
	_label_layer = CanvasLayer.new()
	_label_layer.layer = 1
	add_child(_label_layer)
	var layer := CanvasLayer.new()
	_ui_layer = layer
	layer.layer = 1
	add_child(layer)
	# HUD GON 5 dong (Vong 88: them dong chi so phu — panel cao
	# thuc te ~163px, cao nhat ~168px khi ten map vua co 30, van
	# <= 170 cua artpass3). 3 dong noi dung thu tu 24 ve 20 de
	# nhuong cho dong phu co 18 (co nho xuong 16 neu rong qua
	# 412px, xem _fit_hud_substats). HUD cu 4 dong chiem het dai
	# troi tren cung nen troi khong bao gio thay duoc luc spawn
	# (loi 20/11 12:30). Gop: tui vao dong ngay, vi+EXP vao dong
	# rieng; dong tui rieng (_hud_bag) an di.
	var hud_panel := PanelContainer.new()
	hud_panel.position = Vector2(16, 16)
	hud_panel.size = Vector2(452, 124)
	hud_panel.add_theme_stylebox_override("panel", _panel_style(Color(1.0, 0.97, 0.88, 0.94)))
	layer.add_child(hud_panel)
	var hvb := VBoxContainer.new()
	hvb.add_theme_constant_override("separation", 2)
	hud_panel.add_child(hvb)
	_hud_map = _mk_label(hvb, font_bold, 30, Vector2.ZERO, "Phố Xô Bồ")
	_hud_day = _mk_label(hvb, font, 20, Vector2.ZERO, "")
	_hud_bag = _mk_label(hvb, font, 20, Vector2.ZERO, "")
	_hud_bag.visible = false
	_hud_gold = _mk_label(hvb, font, 20, Vector2.ZERO, "")
	_hud_stats = _mk_label(hvb, font, 20, Vector2.ZERO, "")
	_hud_substats = _mk_label(hvb, font, 18, Vector2.ZERO, "")
	var frame_btn := Button.new()
	frame_btn.text = "Đổi khung (F)"
	_style_button(frame_btn)
	frame_btn.position = Vector2(720 - 224, 24)
	frame_btn.size = Vector2(200, 56)
	frame_btn.pressed.connect(func() -> void: _frame_timer = 0.0; _advance_frame())
	layer.add_child(frame_btn)
	var jobs_btn := Button.new()
	jobs_btn.text = "Việc làm"
	_style_button(jobs_btn)
	jobs_btn.position = Vector2(720 - 224, 88)
	jobs_btn.size = Vector2(200, 56)
	jobs_btn.pressed.connect(_show_jobs_dialogue)
	layer.add_child(jobs_btn)
	_phone_btn = Button.new()
	_phone_btn.text = "Điện thoại (P)"
	_style_button(_phone_btn)
	_phone_btn.position = Vector2(720 - 224, 152)
	_phone_btn.size = Vector2(200, 56)
	_phone_btn.pressed.connect(_toggle_phone)
	layer.add_child(_phone_btn)
	# Panel dien thoai: KHUNG RIENG 640x1100 (khong full man hinh),
	# tren lop mo toi — map khong xuyen qua, khong con ~60% dien
	# tich trong o duoi (loi 20/11 10:30).
	_phone_dim = ColorRect.new()
	_phone_dim.position = Vector2(0, 0)
	_phone_dim.size = Vector2(720, 1280)
	_phone_dim.color = Color(0, 0, 0, 0.55)
	_phone_dim.visible = false
	layer.add_child(_phone_dim)
	_phone_panel = PanelContainer.new()
	# Panel dien thoai GON (680x900, can giua doc) thay vi 680x1100
	# — noi dung that chi ~720px, panel cu thua ~450px trong
	# (art pass Nadia 20/11, loi goc 20/11 10:30).
	# y=216: duoi day nut "Dien thoai (P)" (nut o y 152-208) + 8px
	# cach — y=190 cu de len nua duoi nut (kiem live 13:53). Panel
	# cu o y=156 de len day HUD (loi 20/11 12:30, do min-size day
	# panel len 157px thay vi 124px dat truoc).
	_phone_panel.position = Vector2(20, 216)
	_phone_panel.size = Vector2(680, 900)
	_phone_panel.add_theme_stylebox_override("panel", _phone_panel_style())
	_phone_panel.visible = false
	layer.add_child(_phone_panel)
	# Khung dien thoai that: notch tren + thanh home duoi (chi hien
	# khi mo dien thoai) — thay cho hinh chu nhat tron tron.
	# y=216 (khong phai 190): mep tren panel cu cat ngang nut
	# "Dien thoai (P)" cua HUD (nut o y 152-208, chi thay nua duoi
	# — kiem live 13:53). Notch o 209 (ngay tren panel), homebar o
	# 1104 (day panel 1116 tru 12).
	_phone_notch = _mk_phone_bar(Vector2(300, 209), Vector2(120, 14))
	layer.add_child(_phone_notch)
	_phone_homebar = _mk_phone_bar(Vector2(290, 1104), Vector2(140, 10))
	layer.add_child(_phone_homebar)
	var pvb := VBoxContainer.new()
	# Separation 8 (khong phai 10): tong chieu cao toi thieu cua VBox
	# (tieu de 36 + luoi tab 172 + 2 scroll 200/240 + hom nay 60 +
	# goi y/meo 57/57 + chan trang 27 + khoang cach) phai <= 896 de
	# panel giu dung 680x900 — separation 10 day panel len 907
	# (loi 20/11 12:00).
	pvb.add_theme_constant_override("separation", 8)
	_phone_panel.add_child(pvb)
	_phone_title = _mk_label(pvb, font_bold, 30, Vector2.ZERO, "Điện thoại")
	var tab_grid := GridContainer.new()
	tab_grid.columns = 3
	tab_grid.add_theme_constant_override("h_separation", 8)
	tab_grid.add_theme_constant_override("v_separation", 8)
	pvb.add_child(tab_grid)
	for t in PxbPhoneHub.tab_list():
		var tb := Button.new()
		tb.text = String(t["name"])
		_style_button(tb, 22)
		tb.custom_minimum_size = Vector2(190, 52)
		tb.pressed.connect(_on_phone_tab_pressed.bind(String(t["id"])))
		tab_grid.add_child(tb)
		_phone_tab_buttons[String(t["id"])] = tb
	_phone_content = _mk_label(pvb, font, 26, Vector2.ZERO, "")
	_phone_content.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_phone_content.size = Vector2(580, 200)
	# Chieu rong toi thieu 580: Label trong ScrollContainer mac dinh
	# bi ep ve chieu rong toi thieu 1px (autowrap) nen chu xep doc
	# 1 ky tu/dong (loi 20/11 12:10) — dat min width = be rong scroll.
	_phone_content.custom_minimum_size = Vector2(580, 0)
	# Noi dung dai (vd danh ba 16 NPC) phai CUON, khong tran khoi
	# panel: label trong ScrollContainer, chieu cao tu noi dung.
	# Cao 238px (khong phai 224): 7 dong x ~34px — hien tron dong
	# cuoi "Anh Ba" o vi tri cuon mac dinh (224px cat doi dong thu
	# 7, kiem live 14:34: dong cuoi bi cat nua + nut "Tro chuyen"
	# o ngay duoi trong nhu de len no). Bu lai bang actions scroll
	# 216 -> 192 de tong chieu cao VBox khong doi.
	var content_scroll := ScrollContainer.new()
	_phone_content_scroll = content_scroll
	content_scroll.custom_minimum_size = Vector2(580, 238)
	pvb.add_child(content_scroll)
	_phone_content.get_parent().remove_child(_phone_content)
	content_scroll.add_child(_phone_content)
	_phone_act_scroll = ScrollContainer.new()
	_phone_act_scroll.custom_minimum_size = Vector2(580, 192)
	pvb.add_child(_phone_act_scroll)
	_phone_actions = VBoxContainer.new()
	_phone_actions.add_theme_constant_override("separation", 8)
	_phone_act_scroll.add_child(_phone_actions)
	# Khoi "Hom nay" — noi dung that lap khoang trong giua nut bam
	# va khoi Tien trinh (loi 20/11 12:30: khoang trong 140-180px).
	_phone_today = _mk_label(pvb, font, 22, Vector2.ZERO, "")
	_phone_today.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_phone_today.size = Vector2(580, 60)
	# KHONG dung spacer day goi y + chan trang xuong day panel nua:
	# spacer chinh la khoang trong 140-180px giua nut "Dong dien
	# thoai" va khoi Tien trinh (loi 20/11 12:30). Bo spacer di, goi y
	# + chan trang noi ngay sau noi dung; phan trong (neu co) nam o
	# DAY panel — nhu man hinh dien thoai that, khong phai giua chung.
	_phone_hint = _mk_label(pvb, font, 22, Vector2.ZERO, "")
	_phone_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_phone_hint.size = Vector2(580, 90)
	_phone_tip = _mk_label(pvb, font, 22, Vector2.ZERO, "")
	_phone_tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_phone_tip.size = Vector2(580, 60)
	# Chan trang dien thoai: ngay + vi + danh vong + chuong — lap
	# phan trong o duoi panel (loi 20/11 10:30).
	_phone_footer = _mk_label(pvb, font, 22, Vector2.ZERO, "")
	_phone_footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# Toast doi khung o GOC DUOI-TRAI (24,1216), chu nho 24: y=720
	# cu che cua/cua so giua man hinh vai giay sau khi bam F
	# (kiem live 13:53); goc duoi khong de mat troi/trang, nhan
	# cua ra da kep toi da y=1200 nen toast o 1216 khong chong
	# nhan nao (kiem live 14:34 yeu cau doi xuong goc duoi).
	_toast = _mk_label(layer, font_bold, 24, Vector2(24, 1216), "")
	_toast.size = Vector2(440, 40)
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.add_theme_color_override("font_outline_color", Color(1, 1, 1, 0.95))
	_toast.add_theme_constant_override("outline_size", 8)
	_toast.visible = false
	# Vong 10 — D-pad tren man hinh + nhan debug o/tile:
	# 3 lan kiem live cloud (16:52, 22:05, 23:14) deu thay nhan vat
	# dung yen du phim/tap van chay tot tren Chromium local (ca
	# press nhanh, giu phim, tap, synthetic dispatchEvent) — khong
	# tai hien duoc loi live bang moi cach nhan tren ban live that.
	# Goc co the la duong input ban phim cua trinh duyet cloud (focus
	# / physical_keycode / event tong hop) — khong doan them, them
	# DUONG INPUT THU 2 khong phu thuoc ban phim: 4 nut mui ten
	# (button_down -> press_dir, button_up -> release_dir) + nhan
	# debug hien o hien tai + input cuoi, de lan kiem live sau doc
	# duoc ngay input co toi game khong (ke ca khi camera bam theo
	# lam vi tri nhan vat tren man hinh gan nhu khong doi).
	# Vong 11: nhan debug DOI LEN GOC TREN-TRAI (24,200), duoi panel
	# HUD — truoc day o (24,1172) cuoi canvas, bi nhan cua Map002
	# ("Cua ve Xom Tro Cu" / "Cua di Khu Cong Nhan", kep y<=1200)
	# che mat (kiem live 21/11). Nen toi + chu sang de doc tren
	# moi nen (troi/mat tien).
	_dbg_label = _mk_label(layer, font, 20, Vector2(24, 200), "")
	_dbg_label.size = Vector2(440, 64)
	_dbg_label.add_theme_color_override("font_color", Color(1.0, 0.97, 0.88, 1))
	_dbg_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	_dbg_label.add_theme_constant_override("outline_size", 6)
	var _dbg_bg := StyleBoxFlat.new()
	_dbg_bg.bg_color = Color(0.10, 0.10, 0.12, 0.72)
	_dbg_bg.set_corner_radius_all(6)
	_dbg_bg.content_margin_left = 10
	_dbg_bg.content_margin_right = 10
	_dbg_bg.content_margin_top = 4
	_dbg_bg.content_margin_bottom = 4
	_dbg_label.add_theme_stylebox_override("normal", _dbg_bg)
	_dpad = Control.new()
	_dpad.position = Vector2.ZERO
	_dpad.size = Vector2(720, 1280)
	_dpad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_dpad)
	# Vong 10 — D-pad BEN TRAI (x 48-208, y 880-1040, nut 52px):
	# ban dau dat ben phai thi nut ◀ de len nhan "Hem tro buoi
	# sang" + nut ▼ de len sao hotspot (kiem Chromium 20/11) —
	# ben trai chi de len co/cay trang tri, khong de nhan nao,
	# khong de hotspot, cach toast (y 1216); nhan debug vong 11
	# doi len (24,200) nen khong nam o day nua.
	_mk_dpad_btn("▲", Vector2(102, 880), Vector2i(0, -1))
	_mk_dpad_btn("◀", Vector2(48, 934), Vector2i(-1, 0))
	_mk_dpad_btn("▶", Vector2(156, 934), Vector2i(1, 0))
	_mk_dpad_btn("▼", Vector2(102, 988), Vector2i(0, 1))
	_update_dbg()
	_dlg_panel = PanelContainer.new()
	_dlg_panel.position = Vector2(40, 1280 - 330)
	_dlg_panel.size = Vector2(640, 300)
	_dlg_panel.add_theme_stylebox_override("panel", _panel_style(Color(1.0, 0.97, 0.88, 1.0)))
	_dlg_panel.visible = false
	layer.add_child(_dlg_panel)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 12)
	_dlg_panel.add_child(vb)
	_dlg_name = _mk_label(vb, font_bold, 30, Vector2.ZERO, "")
	_dlg_text = _mk_label(vb, font, 28, Vector2.ZERO, "")
	_dlg_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dlg_text.size = Vector2(600, 120)
	_dlg_choices = VBoxContainer.new()
	_dlg_choices.add_theme_constant_override("separation", 8)
	vb.add_child(_dlg_choices)
	# Man hinh title: tieu de + nut Bat dau (mo san khi vao game).
	_title_panel = PanelContainer.new()
	_title_panel.position = Vector2(0, 0)
	_title_panel.size = Vector2(720, 1280)
	_title_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.99, 0.93, 0.78, 0.55)))
	layer.add_child(_title_panel)
	# Anh nen title (crop giua anh mat tien): len tren panel, duoi chu.
	if ResourceLoader.exists("res://art/title_bg.png"):
		var tbg := TextureRect.new()
		tbg.texture = load("res://art/title_bg.png")
		tbg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tbg.stretch_mode = TextureRect.STRETCH_SCALE
		_title_panel.add_child(tbg)
	var tvb := VBoxContainer.new()
	tvb.add_theme_constant_override("separation", 18)
	tvb.alignment = BoxContainer.ALIGNMENT_CENTER
	_title_panel.add_child(tvb)
	var title := _mk_label(tvb, font_bold, 72, Vector2.ZERO, "PHỐ XÔ BỒ")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var sub := _mk_label(tvb, font, 30, Vector2.ZERO, "Game xã hội 2.5D Việt Nam")
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var sub2 := _mk_label(tvb, font, 26, Vector2.ZERO, "18 khu phố • Làm việc • Buôn bán • Kết bạn")
	sub2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var start_btn := Button.new()
	start_btn.text = "▶  Bắt đầu chơi"
	_style_button(start_btn, 40)
	# Nut LON (620x110) de bam tren desktop + mobile; tren web con
	# co nut DOM that ngoai canvas (web_shell.html, __pxb_start).
	start_btn.custom_minimum_size = Vector2(620, 110)
	start_btn.pressed.connect(_on_start_pressed)
	var center := CenterContainer.new()
	center.add_child(start_btn)
	tvb.add_child(center)
	var hint := _mk_label(tvb, font, 22, Vector2.ZERO,
		"Di chuyển: WASD / mũi tên / chạm\nE: tương tác • P: điện thoại • F: đổi khung • B: đấu trận chợ (demo)\nGame dọc — chơi trên điện thoại là đẹp nhất")
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func _on_start_pressed() -> void:
	title_open = false
	_title_panel.visible = false
	if player != null:
		player.input_blocked = false

func _mk_phone_bar(pos: Vector2, size: Vector2) -> Panel:
	# Thanh notch / home cua khung dien thoai: hinh chu nhat bo tron,
	# mau nau dam — giong vien dien thoai that.
	var p := Panel.new()
	p.position = pos
	p.size = size
	var st := StyleBoxFlat.new()
	st.bg_color = Color(0.15, 0.10, 0.06, 1)
	st.corner_radius_top_left = 7
	st.corner_radius_top_right = 7
	st.corner_radius_bottom_left = 7
	st.corner_radius_bottom_right = 7
	p.add_theme_stylebox_override("panel", st)
	p.visible = false
	return p

func _mk_label(parent: Node, f: Font, size: int, pos: Vector2, text: String) -> Label:
	var l := Label.new()
	l.add_theme_font_override("font", f)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", Color(0.15, 0.12, 0.08, 1))
	l.position = pos
	l.text = text
	parent.add_child(l)
	return l

func _fmt_vnd(n: int) -> String:
	# 150000 -> "150.000". Khong dung locale — dinh dang tay cho chac.
	var s := str(absi(n))
	var out := ""
	while s.length() > 3:
		out = "." + s.right(3) + out
		s = s.left(s.length() - 3)
	out = s + out
	return ("-" + out) if n < 0 else out


## Vong 10 — D-pad tren man hinh: nut mui ten goi thang
## player.press_dir/release_dir (khong qua ban phim / focus DOM),
## nut giu thi di lien tuc (button_down giu), cham nhanh thi di 1 o
## (press_dir buoc ngay). focus_mode NONE de nut khong giu focus
## ban phim cua canvas.
func _mk_dpad_btn(text: String, pos: Vector2, dir: Vector2i) -> void:
	var b := Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	_style_button(b, 34)
	b.position = pos
	b.size = Vector2(52, 52)
	b.modulate = Color(1, 1, 1, 0.88)
	b.button_down.connect(func() -> void: _dpad_press(dir))
	b.button_up.connect(func() -> void: _dpad_release(dir))
	_dpad.add_child(b)

func _dpad_press(dir: Vector2i) -> void:
	# Vong 10b: dem so lan button_down (chan doan: 1 click chuot
	# tren Chromium co the kich nhieu lan — thay nhan vat di
	# 4-7 o sau 1 click ma H/Q/A/MR deu rong).
	_dpad_press_count += 1
	# Vong 10b: CHI buoc 1 o (step_dir, khong press_dir) — xem
	# player.step_dir: button_up / mouseup tren web export khong
	# dang tin (nhan vat di lien tuc den tuong), nen D-pad khong
	# giu huong. Bam lap lai de di nhieu o; giu de di lien tuc
	# chi co tren ban phim.
	_last_input = {Vector2i(0, -1): "▲", Vector2i(0, 1): "▼", Vector2i(-1, 0): "◀", Vector2i(1, 0): "▶"}.get(dir, "?")
	if player != null:
		player.step_dir(dir)
	_update_dbg()

func _dpad_release(dir: Vector2i) -> void:
	# Vong 10b: khong con huong giu de nha (step_dir khong ghi
	# _held_dirs); giu ham de signal button_up van noi duoc.
	if player != null:
		player.release_dir(dir)

## §29.3 — Bat/tat nhan debug. Mac dinh an (cua kiem live 21/11
## da qua); bat len khi can chan doan di chuyen. Text van duoc
## _update_dbg() cap nhat ke ca khi an, nen bat len la thay ngay
## o hien tai + input cuoi, khong can di them buoc nao.
func set_debug_labels_visible(v: bool) -> void:
	_debug_labels_visible = v
	if _dbg_label != null:
		_dbg_label.visible = v and not title_open and not phone_open and not battle_open

## Vong 10 — Nhan debug: o hien tai + input di chuyen cuoi + co
## dang khoa input khong. De kiem live doc duoc ngay input co toi
## game khong, ke ca khi camera bam theo lam nhan vat gan nhu dung
## yen tren man hinh.
func _update_dbg() -> void:
	if _dbg_label == null:
		return
	if player == null:
		_dbg_label.text = ""
		return
	var lock := " • KHÓA" if player.input_blocked else ""
	_dbg_label.text = "Ô (%d,%d)%s%s" % [player.tile.x, player.tile.y,
		(" • " + _last_input) if _last_input != "" else "", lock]
	# Vong 10b — Dong 2 chan doan (tam): luc nao giu (H), queue (Q),
	# dich tap (A), phim move_right co dang nhan khong (MR). De
	# phan biet di lien tuc do giu / queue / tap / action ket.
	var held := ""
	for k in player._held_dirs.keys():
		held += str(k) + " "
	var auto := str(player._auto_target)
	var mr := "1" if Input.is_action_pressed("move_right") else "0"
	_dbg_label.text += "\nH:[%s] Q:%d A:%s MR:%s P:%d" % [held, player._queued_dirs.size(), auto, mr, _dpad_press_count]

func _update_hud() -> void:
	_update_dbg()  # Vong 10: o hien tai luon moi (load_map goi _update_hud).
	var parts: Array[String] = []
	for k in inventory.keys():
		if int(inventory[k]) > 0:
			parts.append("%s ×%d" % [String(MATERIAL_NAMES.get(k, k)), int(inventory[k])])
	# HUD gon 4 dong: tui gop vao dong ngay (chi dem so loai de khong
	# tran panel 452px); dong tui rieng (_hud_bag) da an trong _build_ui.
	_hud_day.text = "Ngày %d • Khung %s • Túi: %s" % [day, _frame_name(),
		("%d loại" % parts.size()) if not parts.is_empty() else "trống"]
	_hud_gold.text = "Ví: %sđ • EXP %d" % [_fmt_vnd(jobs.gold), jobs.exp_total]
	_hud_stats.text = "Thể %d • Trí %d • Tâm %d" % [stats.the, stats.tri, stats.tam]
	# Vong 88: 4 chi so phu xem thuong truc tren HUD (truoc day
	# chi thay qua toast tot nghiep roi mat, §109.6 muc 4).
	_hud_substats.text = "Kỷ %d • Dũng %d • Sáng %d • An Yên %d" % [
		stats.ky(), stats.dung(), stats.sang(), stats.an_yen()]
	_fit_hud_substats()
	var unread := phonehub.total_unread() if phonehub != null else 0
	_phone_btn.text = ("Điện thoại (%d)" % unread) if unread > 0 else "Điện thoại (P)"
	# Vong 98: lo HUD ra window.__pxb_hud de script browser-verify
	# doc so lieu that (ngay/khung/vi/chi so phu) ma khong can mo
	# dien thoai — theo mau window.__pxb_map/__pxb_tile. Chi tren web.
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.__pxb_hud = " + JSON.stringify({
			"day": day, "frame": _frame_name(), "gold": jobs.gold,
			"exp": jobs.exp_total,
			"substats": String(_hud_substats.text)}))

func show_toast(text: String) -> void:
	_toast.text = text
	_toast.visible = true
	_toast_timer = 3.0

func show_dialogue(who: String, text: String, choices: Array) -> void:
	dialogue_open = true
	if player != null:
		player.input_blocked = true
	_dlg_name.text = who
	_dlg_text.text = text
	for c in _dlg_choices.get_children():
		c.queue_free()
	for ch in choices:
		var b := Button.new()
		b.text = String(ch[0])
		_style_button(b, 28)
		b.custom_minimum_size = Vector2(600, 56)
		var act: Callable = ch[1]
		b.pressed.connect(act)
		_dlg_choices.add_child(b)
	_dlg_panel.visible = true

func close_dialogue() -> void:
	dialogue_open = false
	if player != null:
		player.input_blocked = false
	_dlg_panel.visible = false
