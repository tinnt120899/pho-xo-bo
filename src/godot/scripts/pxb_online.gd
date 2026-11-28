class_name PxbOnline
extends Node
## Phố Xô Bồ — PXB_Online (Godot G2, bước 6/17 + G4 bước 7).
## Port trung thực PXB_Online.js (src/nadia/www/js/plugins/
## PXB_Online.js) — client online: health check, số dư + tặng tiền
## qua server .NET, hàng đợi outbox khi offline; đấu giá / công
## ty=guild CHƯA có endpoint nên luôn trả server-chua-co-endpoint;
## đổi đồ qua WebSocket server Godot ĐÃ CÓ (G4 bước 10).
##
## G4 bước 7 — CHAT ONLINE QUA SERVER GODOT (protocol v1, xem
## server/pxb_server.gd): client WebSocket trong game này, dùng
## chung giao thức hello/chat/presence với PxbServer. Đường HTTP
## .NET giữ nguyên làm fallback cho tới khi WS ổn định (quyết
## docs/godot-g4.md §12.5). WS chỉ là chat + presence — KHÔNG
## quyết tiền/đồ của ai (sổ cái vẫn qua HTTP .NET như cũ).
##
## G4 bước 10 — ĐỔI ĐỒ QUA WS (protocol v1, xem
## server/pxb_server.gd): send_ws_trade_offer / accept / decline
## / cancel. Server giữ đề nghị + validate + ghi nhận thỏa thuận
## (trade_completed).
##
## G4 bước 12 — ĐẤU GIÁ QUA WS (protocol v1, xem
## server/pxb_server.gd): send_ws_auction_create / bid / cancel +
## request_ws_auction_list. Server giữ phiên + validate giá + tự
## đóng khi hết giờ + tính phí sàn 5% (đã chốt). Khi nhận
## auction_closed, PxbOnline tự áp kết quả vào túi (trade_inventory,
## PxbInventory) + ví (trade_economy.money, PxbEconomy) qua
## apply_auction_closed() rồi mới phát signal ws_auction_closed
## (dict đã chốt kèm thêm khóa "apply" ghi kết quả áp — giống
## trade_completed ở bước 11). Vòng 72 — SỔ CÁI SERVER CHO ĐẤU
## GIÁ: server giữ hộ tiền giá cao nhất (reserved), validate đủ
## tiền/món rồi mới cho đặt giá / mở phiên, quyết toán khi đóng
## phiên; client áp đúng số trong khối "ledger" của
## auction_closed (người thắng trả winner_paid, người bán nhận
## 95% của số thực trả).
##
## G4 bước 11 — ÁP TRADE_COMPLETED VÀO TÚI + VÍ Ở CLIENT:
## khi nhận trade_completed, PxbOnline tự áp thỏa thuận vào túi
## (trade_inventory, PxbInventory) + ví (trade_economy.money,
## PxbEconomy) qua apply_trade_completed() rồi mới phát signal
## ws_trade_completed (dict đã chốt kèm thêm khóa "apply" ghi kết
## quả áp). Áp trùng 1 trade_id thì bỏ lần 2 (ws_trades_applied).
## Vòng 73 — SỔ CÁI SERVER CHO TRADE: server quyết toán từ ledger
## khi chấp nhận (_settle_trade — đủ mới chuyển cả 2 chiều, thiếu
## thì HỦY giao dịch, khối "ledger" kèm trade_completed); client
## áp đúng số server đã quyết toán, giao dịch bị hủy thì không
## trừ/cộng gì + toast báo lý do. Không có khối ledger (server cũ
## / chưa ai đồng bộ) thì áp theo thỏa thuận như cũ: tiền cho thiếu
## thì trừ tới 0 + ghi short_money (không âm ví). Main phải nối
## trade_inventory/trade_economy + đồng bộ ví chung jobs.gold
## (xem Main._process + _on_ws_trade_completed).
##
## Vòng 76 — SỔ CÁI SERVER AUTHORITATIVE (1 PHẦN): server trả
## ledger_sync_ack cho mỗi lần sync (money/items/reserved sau khi
## ghi + clamped_money/clamped_items + stale khi base_money khác
## ledger — sync bằng số local cũ sau quyết toán thì không ghi
## đè); client giữ số server làm chuẩn (ws_ledger_authoritative_*,
## ws_reserved_money, ws_last_ledger_ack, signal
## ws_ledger_sync_acked), tự kẹp tiền gửi đi theo reserved, đặt
## baseline theo ack; Main chặn tiêu tiền giữ hộ (xem
## Main._reserve_blocked) + áp ack vào ví/túi khi số lệch.
## Vòng 77 — MUA Ở CHỢ QUA SERVER (đóng khe hở còn lại của vòng
## 76: mua/bán local trong Main chưa qua server validate):
## send_ws_shop_buy + signal ws_shop_buy_acked; server validate
## giá từ bảng PxbEconomy + trừ tiền trong ledger rồi mới trả ack
## (xem server/pxb_server.gd _handle_shop_buy). Vòng 86 — BÁN LẠI
## CHO CHỢ ĐÃ CÓ: send_ws_shop_sell + signal ws_shop_sell_acked;
## server validate đang sở hữu + trừ 1 món khỏi owned rồi mới
## cộng 50% giá catalog (PxbEconomy.shop_sellback_price) vào
## ledger (xem server/pxb_server.gd _handle_shop_sell); phòng trọ
## thuê tháng không bán lại được.
## Cùng vòng 77 — SỬA RACE CỦA ACK SYNC: mỗi lần gửi ledger_sync
## ghi lại ví local lúc gửi (_ws_ledger_sent_money_queue); ack về
## kèm sent_money để Main áp ví theo delta thay vì áp tuyệt đối
## (không nuốt tiền kiếm/tiêu local trong lúc chờ ack). Sync gửi
## thô (không qua send_ws_ledger_sync) thì ack không có sent_money
## và Main áp tuyệt đối như vòng 76.
## Vòng 78 — OWNED VÀO SỔ CÁI: send_ws_ledger_sync gửi kèm
## "owned" {item_id: count} chụp từ economy.owned; server hợp
## nhất theo max(server, client) rồi trả lại trong
## ledger_sync_ack / shop_buy_ack (khóa "owned" +
## "owned_present"); Main lấy ack.owned làm chuẩn cho
## economy.owned (xem Main._apply_server_owned). Server cũ không
## gửi khóa owned thì owned_present=false, client giữ owned local
## như cũ (không xóa).
##
## - Endpoint THẬT đã có trên server (src/server/src/Program.cs):
##   GET  /health
##   GET  /ledger/balance/{playerId}
##   POST /ledger/gift (body FromPlayerId, ToPlayerId, AmountVnd,
##   GameDay, IdempotencyKey; trùng key → 409, không tặng lần 2).
## - CHƯA có auth: endpoint /ledger/gift hiện tin playerId trong
##   body, chỉ dùng nội bộ cho tới khi server có auth. File này
##   KHÔNG tự thêm auth giả — khi server có auth thì bổ sung sau.
## - Tặng tiền: mỗi lần tặng sinh IdempotencyKey riêng
##   ("pxb-" + epoch-ms + "-" + số ngẫu nhiên); key đã gửi rồi thì
##   KHÔNG gửi lần 2 (trả {ok:false, reason:"trung-idempotency-key"}).
## - Offline: tặng tiền khi không tới được server thì lưu vào hàng
##   đợi outbox trong state và gửi lại khi online (flush_outbox).
##   Server trả 409 (đã có key này) thì coi như đã gửi xong, xóa
##   khỏi outbox — không tặng lần 2.
## - Mọi giao dịch tiền phải qua server, sổ cái EconomyLedger là
##   nguồn sự thật. Client không bao giờ tự quyết tiền/đồ của người
##   khác. Số tiền lấy từ PxbBalance (phí đấu giá, vốn lập công ty…)
##   — file này không hardcode số tiền nào khác. Riêng tặng tiền
##   chưa có giới hạn trong PxbBalance (PROVISIONAL: chưa có cap).
##
## HTTP (Godot dùng HTTPRequest, bất đồng bộ): các hàm mạng là async
## func trả Dictionary. Để test headless được, node có property
## http_transport: Callable — mặc định rỗng (= đường HTTPRequest thật);
## test gán stub Callable(method, url, body) -> Dictionary đồng bộ thì
## await hoàn thành ngay trong frame, không cần server thật. Stub
## phải trả đúng dạng _request(): {ok, status, data, reason}.
## Đường HTTPRequest thật chỉ chạy khi node đã vào cây scene (cần
## get_tree()); ngoài cây thì trả khong-toi-duoc-server — không giả
## vờ đã gọi.
##
## QUIRK / LỆCH ĐÃ GHI NHẬN (theo @help của JS — không bịa số mới):
## - JS lưu state trong $gameSystem.pxbOnline (đi theo save MV);
##   GDScript giữ state trong instance này + data() / from_data()
##   để lưu (save thật là việc SaveCloud, bước sau).
## - Tên hàm/thuộc tính: GDScript không cho trùng tên biến và hàm
##   nên base_url là thuộc tính đọc trực tiếp (node.base_url), còn
##   set_base_url(url) / is_online() là hàm — đúng danh sách state
##   trong task (base_url, online, …).
## - flush_outbox() của JS ghi chú "dừng gửi các món sau" khi gặp
##   lỗi mạng nhưng chuỗi Promise thật ra không kiểm tra cờ dừng nên
##   vẫn thử hết các món còn lại. Bản GDScript dừng thật (break):
##   kết quả {sent, kept, failed} giống hệt nhau (món lỗi mạng nào
##   cũng giữ lại trong outbox), chỉ bớt lần gọi HTTP vô ích.
## - GDScript không có exception — các hàm trả Dictionary
##   {ok, reason, …} thay vì throw; hàm không-endpoint trả
##   Dictionary đồng bộ (không phải async) vì không gọi mạng.
## - Signal online_changed / outbox_changed là thêm mới theo quy
##   ước GDScript của repo (JS không có): chỉ phát khi giá trị đổi
##   (online) / khi outbox đổi (thêm/xóa món), để lớp UI bind.
##
## PROVISIONAL — chưa chốt, đổi thì sửa ở đây + server +
## docs/architecture-nadia.md §7 cùng lúc:
##   - Base URL mặc định http://localhost:5000 (server chạy local;
##     URL deploy thật chưa có).
##   - Timeout mỗi lần gọi API: 5000 ms.
##   - Outbox giữ tối đa 50 món chờ; key đã gửi giữ tối đa 200 key.
##   - Số dư cache trong state chỉ để hiển thị, hết hạn sau 60 giây.

# Base URL mặc định — server .NET chạy local; URL deploy thật chưa có.
const DEFAULT_BASE_URL := "http://localhost:5000"
# Timeout mỗi lần gọi API — PROVISIONAL.
const REQUEST_TIMEOUT_MS := 5000
# Outbox giữ tối đa 50 món chờ — PROVISIONAL.
const OUTBOX_MAX := 50
# Key tặng tiền đã gửi giữ tối đa 200 key — PROVISIONAL.
const SENT_KEYS_MAX := 200
# Số dư cache chỉ để hiển thị, hết hạn sau 60 giây — PROVISIONAL.
const BALANCE_CACHE_MS := 60000
# URL mặc định của server chat Godot (chạy local; URL deploy thật
# chưa có — server chưa có địa chỉ công khai).
const DEFAULT_WS_URL := "ws://localhost:8765"
# Phiên bản giao thức WS — phải khớp PxbServer.PROTOCOL_VERSION.
const WS_PROTOCOL_VERSION := 1
# Chat WS tối đa 500 ký tự — khớp giới hạn server (PxbServer).
const WS_MAX_CHAT_LEN := 500
# Chat log WS giữ 100 tin gần nhất — khớp server (CHAT_LOG_MAX).
const WS_CHAT_LOG_MAX := 100
# Tên hiển thị WS tối đa 30 ký tự — khớp server (cắt ở server).
const WS_MAX_NAME_LEN := 30
# player_id WS tối đa 64 ký tự — khớp server.
const WS_MAX_PLAYER_ID_LEN := 64
# File luu rieng player_id WS — Vong 93: id phai ben qua reload trang
# (save slot chi co tac dung khi nguoi choi da luu + tai save TRUOC
# khi bam noi; file nay ghi ngay luc sinh id nen lan noi dau tien
# da co id ben). Tren web, user:// map sang IndexedDB nen ben qua
# reload nhu file save slot cua PxbSaveCloud.
const PLAYER_ID_FILE := "user://pxb_player_id.txt"
# Khoa localStorage tren web — du phong khi file user:// mat (chi
# doc khi file khong co id hop le; chi ghi kem khi da co id).
const PLAYER_ID_LS_KEY := "pxb_player_id"
# Tiền bù tối đa trong 1 đề nghị đổi đồ qua WS — khớp server
# (PxbServer.MAX_TRADE_MONEY_VND).
const WS_MAX_TRADE_MONEY_VND := 100000000000
# Mã món đồ tối đa 64 ký tự — khớp server.
const WS_MAX_ITEM_ID_LEN := 64
# Log giao dịch đã chốt giữ 50 món gần nhất.
const WS_TRADES_MAX := 50
# Phí sàn đấu giá 5% (đã chốt — khớp PxbBalance.AUCTION_FEE_PERCENT
# + server PxbServer.AUCTION_FEE_PERCENT).
const WS_AUCTION_FEE_PERCENT := 5
# Giá khởi điểm tối thiểu 1.000đ + giá tối đa 100 tỉ — khớp server
# (PxbServer.MIN_AUCTION_START_PRICE_VND / MAX_AUCTION_MONEY_VND).
const WS_MIN_AUCTION_START_PRICE_VND := 1000
const WS_MAX_AUCTION_MONEY_VND := 100000000000
# Giá sau cao hơn giá hiện tại ít nhất 1.000đ — khớp server.
const WS_MIN_BID_INCREMENT_VND := 1000
# Thời gian phiên đấu giá 30 giây .. 1 giờ — khớp server.
const WS_MIN_AUCTION_DURATION_S := 30
const WS_MAX_AUCTION_DURATION_S := 3600
# Phiên đấu giá đã đóng giữ 50 món gần nhất (log + chống áp trùng).
const WS_AUCTIONS_MAX := 50
# Sổ cái server (vòng 72): tự đồng bộ ví + túi lên server khi đổi,
# chậm nhất 500 ms / lần — khớp server (PxbServer.LEDGER_MAX_ITEMS).
const WS_LEDGER_SYNC_DEBOUNCE_MS := 500
const WS_LEDGER_MAX_ITEMS := 512

# Lý do trả về khi server chưa có endpoint — dùng chung cho trade /
# đấu giá / công ty=guild để event / QC bắt được bằng test tĩnh.
const REASON_NO_ENDPOINT := "server-chua-co-endpoint"

## Phát khi trạng thái online đổi (health check / tặng tiền offline).
signal online_changed(is_online: bool)
## Phát khi số món trong outbox đổi (thêm món chờ / gửi xong món).
signal outbox_changed(count: int)
## Phát khi trạng thái kết nối chat WS đổi (G4 bước 7).
signal ws_status_changed(connected: bool)
## Phát khi danh sách người online đổi (welcome / presence).
signal ws_presence_changed(players: Array)
## Phát khi nhận 1 tin chat WS (kể cả echo tin của chính mình).
signal ws_chat_received(msg: Dictionary)
## Phát khi nhận lịch sử chat sau khi hello lại (vòng 83 — server
## gửi lại 100 tin gần nhất đã persist qua restart; Main nối signal
## này từ vòng 85 để làm tươi tab Tin nhắn ngay khi lịch sử về).
signal ws_chat_history_received(messages: Array)
## Phát khi nhận 1 đề nghị đổi đồ (mình là người nhận).
signal ws_trade_offer_received(offer: Dictionary)
## Phát khi đề nghị mình gửi đã tới server (có trade_id).
signal ws_trade_offered_sent(trade: Dictionary)
## Phát khi 1 đề nghị đã chốt (cả 2 bên đều nhận).
signal ws_trade_completed(trade: Dictionary)
## Phát khi đề nghị mình gửi bị từ chối.
signal ws_trade_declined(trade_id: String, reason: String)
## Phát khi 1 đề nghị đang chờ bị hủy.
signal ws_trade_cancelled(trade_id: String, reason: String)
## Phát khi server từ chối 1 lệnh trade (không ngắt kết nối).
signal ws_trade_error(reason: String)
## Phát khi 1 phiên đấu giá mới mở (mình hoặc người khác bán).
signal ws_auction_created(auction: Dictionary)
## Phát khi có người đặt giá mới trong 1 phiên đang mở.
signal ws_auction_bid(auction: Dictionary)
## Phát khi mình vừa bị vượt giá trong 1 phiên đang mở (vòng
## 102 — server gửi riêng cho người bị vượt giá; offline thì
## nhận lại lúc hello sau từ hàng đợi _outbid_pending; kèm
## old_bid / old_bidder_player_id, auction đã cập nhật giá mới).
signal ws_auction_outbid(auction: Dictionary, old_bid: int, old_bidder_player_id: String)
## Phát khi 1 phiên đấu giá đã đóng (hết giờ — kèm "apply" khi
## mình là người bán / người thắng, xem apply_auction_closed).
signal ws_auction_closed(auction: Dictionary)
## Phát khi 1 phiên đấu giá bị hủy (người bán hủy / mất kết nối
## khi chưa có ai đấu giá).
signal ws_auction_cancelled(auction_id: String, reason: String)
## Phát khi server trả danh sách phiên đang mở (sau
## request_ws_auction_list).
signal ws_auction_list(auctions: Array)
## Phát khi server từ chối 1 lệnh đấu giá (không ngắt kết nối).
signal ws_auction_error(reason: String)
## Phát khi server trả ledger_sync_ack (vòng 76): ack đã làm
## sạch, kèm số server sau khi ghi + clamped/stale — Main áp
## vào ví/túi khi số lệch (xem Main._on_ws_ledger_sync_acked).
signal ws_ledger_sync_acked(ack: Dictionary)
## Phát khi server trả shop_buy_ack (vòng 77): ack đã làm sạch,
## chỉ phát khi req_id khớp 1 lần mua đang chờ (ack lạ / trùng
## thì bỏ lặng) — Main áp vào ví + owned + Danh vọng khi ok
## (xem Main._on_ws_shop_buy_acked).
signal ws_shop_buy_acked(ack: Dictionary)
## Phát khi server trả shop_sell_ack (vòng 86): ack đã làm sạch,
## chỉ phát khi req_id khớp 1 lần bán đang chờ (ack lạ / trùng
## thì bỏ lặng) — Main áp vào ví + owned khi ok (xem
## Main._on_ws_shop_sell_acked).
signal ws_shop_sell_acked(ack: Dictionary)
## Phát khi server trả stall_hold_sync_ack (vòng 80): ack đã làm
## sạch, chỉ phát khi req_id khớp 1 lần đồng bộ đang chờ — Main
## biết server đã ghi nhận / từ chối hold (xem
## Main._on_ws_stall_hold_synced).
signal ws_stall_hold_synced(ack: Dictionary)
## Phát khi ngày server đổi (welcome / day_sync_ack / ack kèm
## server_day — vòng 81): Main đồng bộ lại hold đang giữ theo
## ngày mới (xem Main._on_ws_server_day_changed).
signal ws_server_day_changed(server_day: int)

## Đường gọi HTTP có thể thay thế (test headless gán stub Callable
## trả Dictionary đồng bộ). Rỗng = dùng HTTPRequest thật.
var http_transport: Callable = Callable()

var base_url: String = DEFAULT_BASE_URL
var online: bool = false # lần health check gần nhất có tới được server không
var last_health_check_at: int = 0 # epoch-ms lúc health check gần nhất
var last_health_ok: bool = false # health check gần nhất trả ok không
var outbox: Array = [] # món tặng tiền đang chờ gửi lại khi online
var sent_gift_keys: Array = [] # IdempotencyKey đã gửi (chống gửi lần 2)
var last_balance: Dictionary = {} # {player_id, cash_vnd, savings_vnd} cache để hiển thị
var last_balance_at: int = 0 # epoch-ms lúc lấy số dư gần nhất

# --- Chat online qua server Godot (G4 bước 7, protocol v1) ---
var ws_url: String = DEFAULT_WS_URL
var ws_player_id: String = "" # rỗng → ensure_ws_player_id() khôi
# phục từ kho bền (file user:// rồi localStorage web) rồi mới sinh
# mới "pxb-<ms>-<rand>" 1 lần + ghi ngay vào kho bền (Vòng 93)
var ws_display_name: String = "Người chơi"
var ws_connected: bool = false # đã hello + nhận welcome chưa
var ws_peer_id: int = 0 # peer_id server cấp trong welcome (0 = chưa có)
var ws_players: Array = [] # presence hiện tại [{peer_id, player_id, name}]
var ws_chat_log: Array = [] # 100 tin chat gần nhất {player_id, name, text, at_ms}
var ws_last_error: String = "" # lý do lỗi WS gần nhất ("" = chưa lỗi)
var ws_trade_offers: Array = [] # đề nghị đang chờ mình trả lời {trade_id, from_player_id, ...}
var ws_my_offers: Array = [] # đề nghị mình đã gửi, đang chờ {trade_id, to_player_id, ...}
var ws_trades_completed: Array = [] # 50 giao dịch đã chốt gần nhất
var ws_trades_applied: Array = [] # trade_id đã áp vào túi/ví (chống áp trùng, giữ 50)
# Túi + ví để áp trade_completed vào (G4 bước 11): Main nối
# trade_inventory = bag (PxbInventory) + trade_economy = economy.
# null = chưa nối → apply_trade_completed trả chua-noi-tui-vi, chỉ
# ghi log + phát signal, không tự trừ/chuyển gì.
var trade_inventory: PxbInventory = null
var trade_economy: PxbEconomy = null
var ws_last_trade_error: String = "" # lý do trade lỗi gần nhất ("" = chưa lỗi)
# --- Đấu giá qua server Godot (G4 bước 12, protocol v1) ---
var ws_auctions: Array = [] # phiên đang mở {auction_id, seller_player_id, item_id, start_price, current_bid, ...}
var ws_auction_log: Array = [] # 50 phiên đã đóng gần nhất {...+ winner_player_id, hammer_price, fee_vnd, seller_receives_vnd, closed_at_ms, ledger}
var ws_auctions_applied: Array = [] # auction_id đã áp vào túi/ví (chống áp trùng, giữ 50)
var ws_last_auction_error: String = "" # lý do đấu giá lỗi gần nhất ("" = chưa lỗi)
# --- Sổ cái server (vòng 72): đồng bộ ví + túi lên server ---
var ws_ledger_auto_sync: bool = true # tự đồng bộ khi ví/túi đổi (tắt trong test để điều khiển thời điểm sync)
var _ws_ledger_last_money: int = -1 # money đã sync lần cuối (-1 = chưa sync lần nào)
var _ws_ledger_last_items: Dictionary = {} # items đã sync lần cuối
# Vong 78: owned da sync lan cuoi + owned server trong ack gan
# nhat (so server lam chuan cho tai san da mua o cho).
var _ws_ledger_last_owned: Dictionary = {} # owned đã sync lần cuối
var ws_ledger_authoritative_owned: Dictionary = {} # owned server trong ack gần nhất
var _ws_ledger_last_sync_ms: int = 0 # epoch-ms lúc sync lần cuối
# --- Sổ cái server authoritative 1 phần (vòng 76): số server làm chuẩn ---
var ws_reserved_money: int = 0 # tiền đang giữ hộ theo ack gần nhất (0 = không giữ hộ)
var ws_ledger_authoritative_money: int = -1 # money server trong ack gần nhất (-1 = chưa nhận ack nào)
var ws_ledger_authoritative_items: Dictionary = {} # items server trong ack gần nhất
var ws_ledger_clamped_count: int = 0 # số ack server đã kẹp tiền/món (chẩn đoán)
var ws_last_ledger_ack: Dictionary = {} # ack ledger_sync_ack gần nhất (đã làm sạch)
# Hang doi tien local luc gui moi lan ledger_sync (vong 77):
# ack tra ve chi biet so server luc nhan sync — neu giua luc
# gui sync va luc ack ve, vi local doi (kiem them / tieu local)
# thi ap tuyet doi ack.money se nuot mat chenh lech do (vd mua
# o cho: pre-sync gui 200 trieu, kiem them 100k trong luc cho
# ack thi ack 200 trieu ap ve lam mat 100k). Ghi lai tien local
# TRUOC KHI kep theo reserved (khong phai so da kep gui di —
# vd vi 500k giu ho 1,6 trieu thi gui di 1,6 trieu nhung delta
# phai tinh theo 500k, khong thi ack 1,6 trieu ap ve sai) de
# Main ap theo delta (ack.money + (vi hien tai - sent_money)).
# Ack tra theo dung thu tu gui nen pop dau hang doi la dung
# sync vua tra loi; sync gui tho (khong qua send_ws_ledger_sync)
# thi khong co muc trong hang doi -> ack do khong co sent_money
# va Main ap tuyet doi nhu cu (vong 76). Giu toi da 8 muc.
var _ws_ledger_sent_money_queue: Array = []
# --- Mua ở chợ qua server (vòng 77) ---
var ws_shop_req_id: int = 0 # req_id tăng dần cho mỗi lần mua gửi đi (0 = chưa mua lần nào)
var _ws_shop_pending: Dictionary = {} # req_id -> {item_id, discount_percent} lần mua đang chờ ack
# --- Bán lại cho chợ qua server (vòng 86) ---
var ws_shop_sell_req_id: int = 0 # req_id tăng dần cho mỗi lần bán gửi đi (0 = chưa bán lần nào)
var _ws_shop_sell_pending: Dictionary = {} # req_id -> {item_id} lần bán đang chờ ack
# --- Giữ sạp lên server (vòng 80) ---
var ws_hold_req_id: int = 0 # req_id tăng dần cho mỗi lần đồng bộ giữ sạp (0 = chưa gửi lần nào)
var _ws_hold_pending: Dictionary = {} # req_id -> {stall_id, start_day, until_day} lần đồng bộ đang chờ ack
var ws_last_hold_ack: Dictionary = {} # ack stall_hold_sync_ack gần nhất (đã làm sạch)
var ws_game_day: int = 0 # ngày game hiện tại do Main gán (0 = chưa biết) — gửi kèm ledger_sync / shop_buy / stall_hold_sync để server xét hạn hold
var ws_server_day: int = 0 # ngày server báo (0 = chưa biết) — ngày làm chuẩn cho mọi gói online, ưu tiên hơn ws_game_day (vòng 81)
var ws_day_ends_in_ms: int = 0 # ms còn lại tới ranh giới ngày server kế (0 = chưa biết)
var ws_peer: WebSocketMultiplayerPeer = null # null = chưa nối / đã ngắt
var _ws_hello_sent: bool = false # đã gửi hello sau khi socket nối chưa
var _ws_was_connecting: bool = false # đang trong quá trình nối (để báo lỗi)


static func default_data() -> Dictionary:
	return {
		"base_url": DEFAULT_BASE_URL,
		"online": false,
		"last_health_check_at": 0,
		"last_health_ok": false,
		"outbox": [],
		"sent_gift_keys": [],
		"last_balance": {},
		"last_balance_at": 0,
		"ws_url": DEFAULT_WS_URL,
		"ws_player_id": "",
		"ws_display_name": "Người chơi",
		"ws_chat_log": [],
		"ws_trades_completed": [],
		"ws_auction_log": [],
	}


# --- Tiện ích nội bộ ---

# Epoch-ms (tương đương Date.now() của JS).
static func _now_ms() -> int:
	return int(Time.get_unix_time_from_system() * 1000.0)


func _set_online(value: bool) -> void:
	if online == value:
		return
	online = value
	online_changed.emit(value)


# --- Đổi base URL / đọc trạng thái ---

# Đổi base URL lúc chạy (event/test dùng khi server đổi địa chỉ).
# Trả false khi URL rỗng. Ghi PROVISIONAL: URL deploy thật chưa có.
func set_base_url(url: String) -> bool:
	if url.is_empty():
		return false
	var cleaned := url
	while cleaned.ends_with("/") and cleaned.length() > 1:
		cleaned = cleaned.substr(0, cleaned.length() - 1)
	base_url = cleaned
	return true


func is_online() -> bool:
	return online


# --- Lớp gọi HTTP ---

# Gọi HTTP, trả {ok:true, status, data} hoặc
# {ok:false, status, reason, data} — không throw ra ngoài.
# Khi http_transport hợp lệ thì gọi stub đồng bộ (test headless);
# ngược lại dùng HTTPRequest thật (bất đồng bộ).
func _request(method: String, url: String, body: Dictionary = {}) -> Dictionary:
	if http_transport.is_valid():
		var res: Variant = http_transport.call(method, url, body)
		if res is Dictionary:
			return res
		return {"ok": false, "status": 0, "reason": "transport-tra-ve-sai"}
	return await _request_real(method, url, body)


# Đường HTTPRequest thật. Cần node đã vào cây scene để HTTPRequest
# chạy được; ngoài cây thì trả khong-toi-duoc-server.
func _request_real(method: String, url: String, body: Dictionary = {}) -> Dictionary:
	if get_tree() == null:
		return {"ok": false, "status": 0, "reason": "khong-toi-duoc-server"}
	var http := HTTPRequest.new()
	http.timeout = REQUEST_TIMEOUT_MS / 1000.0
	add_child(http)
	var err: Error
	if method == "POST":
		err = http.request(url, ["Content-Type: application/json"],
			HTTPClient.METHOD_POST, JSON.stringify(body))
	else:
		err = http.request(url, [], HTTPClient.METHOD_GET, "")
	if err != OK:
		http.queue_free()
		return {"ok": false, "status": 0, "reason": "khong-toi-duoc-server"}
	var result: Array = await http.request_completed
	var response_code: int = int(result[1])
	var raw_body: PackedByteArray = result[3]
	http.queue_free()
	if int(result[0]) != HTTPRequest.RESULT_SUCCESS:
		return {"ok": false, "status": 0, "reason": "khong-toi-duoc-server"}
	var parsed: Variant = JSON.parse_string(raw_body.get_string_from_utf8())
	var data: Dictionary = parsed if parsed is Dictionary else {}
	if response_code >= 200 and response_code < 300:
		return {"ok": true, "status": response_code, "data": data}
	return {"ok": false, "status": response_code,
		"reason": "http-%d" % response_code, "data": data}


# --- Health check + số dư (endpoint thật) ---

# GET /health — cập nhật online / last_health_check_at /
# last_health_ok. Trả {ok:true, status, game, version} khi server
# trả status "ok", ngược lại {ok:false, reason}.
func health_check() -> Dictionary:
	var res: Dictionary = await _request("GET", base_url + "/health", {})
	last_health_check_at = _now_ms()
	if bool(res.get("ok", false)):
		var data: Dictionary = res.get("data", {})
		if String(data.get("status", "")) == "ok":
			_set_online(true)
			last_health_ok = true
			return {
				"ok": true,
				"status": String(data.get("status", "")),
				"game": String(data.get("game", "")),
				"version": String(data.get("version", "")),
			}
	_set_online(false)
	last_health_ok = false
	return {"ok": false, "reason": String(res.get("reason", "health-khong-ok"))}


# GET /ledger/balance/{playerId} — số dư tiền mặt + tiết kiệm từ
# sổ cái server (nguồn sự thật). Cache vào last_balance để hiển thị;
# cache hết hạn sau 60 giây (PROVISIONAL).
# Trả {ok:true, player_id, cash_vnd, savings_vnd} hoặc {ok:false, reason}.
func balance_of(player_id: String) -> Dictionary:
	if player_id.is_empty():
		return {"ok": false, "reason": "thieu-player-id"}
	var res: Dictionary = await _request("GET",
		base_url + "/ledger/balance/" + player_id.uri_encode(), {})
	if not bool(res.get("ok", false)):
		return {"ok": false, "reason": String(res.get("reason", "khong-lay-duoc-so-du"))}
	var data: Dictionary = res.get("data", {})
	if data.is_empty():
		return {"ok": false, "reason": "khong-lay-duoc-so-du"}
	last_balance = {
		"player_id": String(data.get("playerId", player_id)),
		"cash_vnd": int(data.get("cashVnd", 0)),
		"savings_vnd": int(data.get("savingsVnd", 0)),
	}
	last_balance_at = _now_ms()
	return {
		"ok": true,
		"player_id": String(last_balance["player_id"]),
		"cash_vnd": int(last_balance["cash_vnd"]),
		"savings_vnd": int(last_balance["savings_vnd"]),
	}


# Số dư cache còn hạn không (60 giây, PROVISIONAL) — event dùng để
# quyết có gọi lại server hay hiển thị số cũ.
func cached_balance_fresh() -> bool:
	return not last_balance.is_empty() and (_now_ms() - last_balance_at) < BALANCE_CACHE_MS


# --- Tặng tiền (endpoint thật, có IdempotencyKey + outbox) ---

# Sinh IdempotencyKey mới: "pxb-" + epoch-ms + "-" + số ngẫu nhiên.
# Key duy nhất mỗi lần tặng — server dùng key này để chặn tặng trùng.
func new_idempotency_key() -> String:
	return "pxb-%d-%d" % [_now_ms(), randi_range(0, 999999999)]


func has_sent_key(key: String) -> bool:
	return key in sent_gift_keys


func _remember_sent_key(key: String) -> void:
	if key in sent_gift_keys:
		return
	sent_gift_keys.append(key)
	# Giữ tối đa 200 key (PROVISIONAL) — cắt key cũ nhất.
	while sent_gift_keys.size() > SENT_KEYS_MAX:
		sent_gift_keys.pop_front()


# Xếp 1 món tặng tiền vào outbox (khi offline). Trả true khi xếp
# được, false khi outbox đã đầy 50 món (PROVISIONAL) — món mới bị
# bỏ, không lặng lẽ ghi đè món cũ.
func _enqueue_gift(item: Dictionary) -> bool:
	if outbox.size() >= OUTBOX_MAX:
		return false
	outbox.append(item)
	outbox_changed.emit(outbox.size())
	return true


# Gửi 1 món tặng tiền lên server bằng key của chính món đó (không
# sinh key mới khi gửi lại — server chặn trùng bằng key cũ).
# Trả {ok:true, key} khi server nhận; {ok:false, reason, key} khi
# lỗi. Server trả 409 = key đã có → coi như đã gửi xong.
func _send_gift_once(item: Dictionary) -> Dictionary:
	var res: Dictionary = await _request("POST", base_url + "/ledger/gift", {
		"FromPlayerId": String(item["from_player_id"]),
		"ToPlayerId": String(item["to_player_id"]),
		"AmountVnd": int(item["amount_vnd"]),
		"GameDay": int(item["game_day"]),
		"IdempotencyKey": String(item["key"]),
	})
	if bool(res.get("ok", false)):
		_remember_sent_key(String(item["key"]))
		return {"ok": true, "key": String(item["key"])}
	if int(res.get("status", 0)) == 409:
		# Server đã có key này → đã tặng rồi, không tặng lần 2.
		_remember_sent_key(String(item["key"]))
		return {"ok": true, "key": String(item["key"]), "duplicate": true}
	var data: Dictionary = res.get("data", {})
	var reason := ""
	if data.has("error"):
		reason = String(data["error"])
	elif res.has("reason"):
		reason = String(res["reason"])
	else:
		reason = "gift-that-bai"
	return {"ok": false, "key": String(item["key"]), "reason": reason}


# Tặng tiền trong game (không lãi, không phí — đúng
# EconomyLedger.Gift). amount_vnd phải là số nguyên > 0; chưa có
# giới hạn trên trong PxbBalance (PROVISIONAL: chưa có cap).
# - Key đã gửi rồi → {ok:false, reason:"trung-idempotency-key"},
#   KHÔNG gửi lần 2.
# - Gửi được → {ok:true, key}.
# - Không tới được server → xếp vào outbox, trả
#   {ok:false, reason:"offline-da-luu-outbox", queued:true}.
# - Server từ chối (400: số tiền sai…) → {ok:false, reason}.
# Có thể truyền key riêng (khi gửi lại từ outbox) — event thường
# không truyền, để hàm tự sinh.
func gift(from_player_id: String, to_player_id: String, amount_vnd: Variant,
		game_day: int = 1, key: String = "") -> Dictionary:
	if from_player_id.is_empty() or to_player_id.is_empty():
		return {"ok": false, "reason": "thieu-player-id"}
	if not (amount_vnd is int or amount_vnd is float) \
			or int(amount_vnd) != amount_vnd or int(amount_vnd) <= 0:
		return {"ok": false, "reason": "so-tien-khong-hop-le"}
	var gift_key: String = key if not key.is_empty() else new_idempotency_key()
	if has_sent_key(gift_key):
		return {"ok": false, "key": gift_key, "reason": "trung-idempotency-key"}
	var item := {
		"key": gift_key,
		"from_player_id": from_player_id,
		"to_player_id": to_player_id,
		"amount_vnd": int(amount_vnd),
		"game_day": game_day if game_day > 0 else 1,
		"queued_at": _now_ms(),
	}
	var res: Dictionary = await _send_gift_once(item)
	if bool(res.get("ok", false)):
		return {"ok": true, "key": gift_key}
	if String(res.get("reason", "")) == "khong-toi-duoc-server":
		# Offline: xếp vào outbox để gửi lại khi online. Outbox đầy
		# thì báo rõ, không lặng lẽ mất món tặng.
		if _enqueue_gift(item):
			_set_online(false)
			return {"ok": false, "key": gift_key,
				"reason": "offline-da-luu-outbox", "queued": true}
		return {"ok": false, "key": gift_key, "reason": "outbox-day"}
	return {"ok": false, "key": gift_key, "reason": String(res.get("reason", "gift-that-bai"))}


# Gửi lại toàn bộ outbox khi online. Món gửi được hoặc server báo
# 409 (đã có) thì xóa khỏi outbox; món lỗi mạng thì giữ lại và dừng
# gửi các món sau. Món lỗi không phải do mạng (400…) thì giữ lại
# trong outbox và đếm vào failed.
# Trả {sent, kept, failed} — sent: số món đã gửi xong, kept: số
# món còn chờ, failed: số món lỗi không phải do mạng (400…).
func flush_outbox() -> Dictionary:
	var sent := 0
	var failed := 0
	var before := outbox.size()
	var items: Array = outbox.duplicate()
	for item in items:
		var res: Dictionary = await _send_gift_once(item)
		if bool(res.get("ok", false)):
			outbox.erase(item)
			sent += 1
		elif String(res.get("reason", "")) == "khong-toi-duoc-server":
			_set_online(false)
			# Giữ lại trong outbox, dừng gửi các món sau (xem quirk
			# trong header: JS ghi chú dừng nhưng code không dừng;
			# kết quả {sent, kept, failed} giống hệt nhau).
			break
		else:
			failed += 1
	if outbox.size() != before:
		outbox_changed.emit(outbox.size())
	return {"sent": sent, "kept": outbox.size(), "failed": failed}


# Số món đang chờ trong outbox — event dùng để hiển thị.
func outbox_count() -> int:
	return outbox.size()


# --- Chat online qua server Godot (G4 bước 7, protocol v1) ---
# Client WebSocket dùng WebSocketMultiplayerPeer (đã chứng minh nối
# được PxbServer trong tests/g4_online_server_test.gd). Node này
# thêm _process để tự poll khi đã vào cây scene (Main add_child);
# test headless gọi poll_ws() tay cũng được (poll 2 lần/frame
# không sao — xem PxbServer.poll).
# Trình tự: connect_ws() tạo socket (bất đồng bộ) → poll_ws thấy
# CONNECTED thì gửi hello → server trả welcome → ws_connected=true
# + presence. Gửi chat chỉ sau welcome. Ngắt (bye / mất kết nối /
# server trả error) thì ws_connected=false + xóa presence.
# CHƯA có auth (player_id do client tự khai — chỉ dùng nội bộ,
# giống server); KHÔNG tự reconnect — người chơi bấm nối lại.

func _process(_delta: float) -> void:
	if ws_peer != null:
		poll_ws()
	_maybe_auto_sync_ledger()


# Đặt trạng thái WS + phát signal chỉ khi giá trị đổi (giống
# _set_online của đường HTTP).
func _set_ws_connected(value: bool) -> void:
	if ws_connected == value:
		return
	ws_connected = value
	ws_status_changed.emit(value)


# Cap nhat ngay server khi nhan welcome / day_sync_ack / ack kem
# server_day (vong 81): chi phat signal khi ngay THAT DOI (tranh
# spam moi lan ack ve cung ngay).
func _apply_server_day(day_raw: Variant) -> void:
	if not (day_raw is int or day_raw is float):
		return
	if int(day_raw) != day_raw or int(day_raw) < 1:
		return
	if int(day_raw) == ws_server_day:
		return
	ws_server_day = int(day_raw)
	ws_server_day_changed.emit(ws_server_day)


# Sinh player_id WS mới khi chưa có: "pxb-<epoch-ms>-<rand>".
static func new_ws_player_id() -> String:
	return "pxb-%d-%d" % [_now_ms(), randi_range(0, 999999999)]


# Id hop le: khong rong, khong qua gioi han server (64 ky tu).
static func _valid_player_id(pid: String) -> bool:
	return not pid.is_empty() and pid.length() <= WS_MAX_PLAYER_ID_LEN


# Doc id da luu trong file user:// (ve "" khi chua co / file ban).
# File co the dinh khoang trang / xuong dong cuoi file — cat di.
static func _load_player_id_from_file() -> String:
	if not FileAccess.file_exists(PLAYER_ID_FILE):
		return ""
	var text := FileAccess.get_file_as_string(PLAYER_ID_FILE).strip_edges()
	return text if _valid_player_id(text) else ""


# Doc id da luu trong localStorage tren web (du phong khi file
# user:// mat). Chi chay tren web — headless tra "" ngay, khong
# goi JavaScriptBridge (giong cach Main bao ve window.__pxb_*).
static func _load_player_id_from_localstorage() -> String:
	if not OS.has_feature("web"):
		return ""
	var val = JavaScriptBridge.eval(
		"localStorage.getItem('%s')" % PLAYER_ID_LS_KEY)
	if val is String:
		var text := String(val).strip_edges()
		if _valid_player_id(text):
			return text
	return ""


# Ghi id hien tai vao kho ben: file user:// luon + localStorage
# tren web. Id rong thi khong ghi (tranh ghi de id hop le bang
# rong). JSON.stringify boc id trong dau ngoac kep nen ky tu la
# trong id (neu co) khong pha duoc cau lenh JS.
func _save_persisted_player_id() -> void:
	if ws_player_id.is_empty():
		return
	var file := FileAccess.open(PLAYER_ID_FILE, FileAccess.WRITE)
	if file != null:
		file.store_string(ws_player_id)
		file.close()
	if OS.has_feature("web"):
		JavaScriptBridge.eval("localStorage.setItem('%s', %s)" % [
			PLAYER_ID_LS_KEY, JSON.stringify(ws_player_id)])


# Dam bao co player_id BEN (Vong 93 — sua §114.4 muc 1): id trong
# bo nho hop le thi dung lai y nguyen (dong bo xuong kho ben de
# lan sau van con); chua co thi khoi phuc tu file user://, roi
# localStorage (web), cuoi cung moi sinh moi 1 lan roi ghi ngay
# vao kho ben. Goi o connect_ws() — khong bao gio doi id giua
# chung khi dang noi (connect_ws tra ve som neu da noi / dang
# noi). Id truyen vao qua tham so ma ban (rong / qua dai) thi bo,
# dung lai id da luu (neu co) roi moi sinh moi — giu vi server.
func ensure_ws_player_id() -> String:
	if _valid_player_id(ws_player_id):
		_save_persisted_player_id()
		return ws_player_id
	var from_file := _load_player_id_from_file()
	if not from_file.is_empty():
		ws_player_id = from_file
		_save_persisted_player_id() # dong bo ca localStorage
		return ws_player_id
	var from_ls := _load_player_id_from_localstorage()
	if not from_ls.is_empty():
		ws_player_id = from_ls
		_save_persisted_player_id() # khoi phuc ca file
		return ws_player_id
	ws_player_id = new_ws_player_id()
	_save_persisted_player_id()
	return ws_player_id


# Nối tới server chat WS. url / player_id / tên rỗng thì dùng giá
# trị đã lưu (mặc định ws://localhost:8765, id tự sinh, tên
# "Người chơi"). Trả {ok:true, url, player_id} khi đã tạo socket
# (kết nối bất đồng bộ — hello gửi khi CONNECTED, xem poll_ws),
# {ok:false, reason} khi đã nối rồi / URL sai / tạo socket lỗi.
# Không chặn: gọi xong trả ngay, Main báo "Đang nối…".
func connect_ws(url: String = "", player_id: String = "",
		display_name: String = "") -> Dictionary:
	if ws_peer != null and ws_connected:
		return {"ok": false, "reason": "ws-da-ket-noi"}
	if ws_peer != null:
		return {"ok": false, "reason": "ws-dang-noi"}
	var target_url := url.strip_edges() if not url.is_empty() else ws_url
	if target_url.is_empty():
		return {"ok": false, "reason": "thieu-ws-url"}
	ws_url = target_url
	if not player_id.is_empty():
		ws_player_id = player_id.strip_edges()
	# Vong 93: khong sinh moi mu — khoi phuc id da luu truoc, chi
	# sinh moi khi chua tung co (xem ensure_ws_player_id).
	ws_player_id = ensure_ws_player_id()
	if not display_name.is_empty():
		ws_display_name = display_name.strip_edges()
	if ws_display_name.is_empty():
		ws_display_name = "Người chơi"
	if ws_display_name.length() > WS_MAX_NAME_LEN:
		ws_display_name = ws_display_name.substr(0, WS_MAX_NAME_LEN)
	ws_last_error = ""
	_ws_hello_sent = false
	_ws_was_connecting = true
	var peer := WebSocketMultiplayerPeer.new()
	var err: Error = peer.create_client(ws_url)
	if err != OK:
		ws_last_error = "ws-khong-tao-duoc"
		_ws_was_connecting = false
		return {"ok": false, "reason": "ws-khong-tao-duoc", "error": err}
	ws_peer = peer
	return {"ok": true, "url": ws_url, "player_id": ws_player_id}


# Ngắt chat WS: gửi bye nếu đã hello, đóng socket, xóa presence +
# trạng thái. Gọi khi chưa nối cũng an toàn.
func disconnect_ws() -> void:
	if ws_peer != null:
		if ws_connected and _ws_hello_sent:
			ws_peer.put_packet(JSON.stringify({"type": "bye"}).to_utf8_buffer())
		ws_peer.close()
		ws_peer = null
	_ws_hello_sent = false
	_ws_was_connecting = false
	ws_peer_id = 0
	ws_players = []
	_set_ws_connected(false)
	ws_presence_changed.emit(ws_players)


# Đã nối chat WS (đã hello + nhận welcome) chưa.
func is_ws_connected() -> bool:
	return ws_connected


# Một nhịp mạng WS: poll socket + xử lý hết gói đang chờ + gửi
# hello ngay khi socket vừa CONNECTED. Gọi từ _process (node trong
# cây) hoặc tay trong test.
func poll_ws() -> void:
	if ws_peer == null:
		return
	ws_peer.poll()
	var status := ws_peer.get_connection_status()
	if status == MultiplayerPeer.CONNECTION_CONNECTED:
		if not _ws_hello_sent:
			_ws_hello_sent = true
			_ws_was_connecting = false
			ws_peer.put_packet(JSON.stringify({
				"type": "hello",
				"protocol": WS_PROTOCOL_VERSION,
				"player_id": ws_player_id,
				"name": ws_display_name,
			}).to_utf8_buffer())
		while ws_peer.get_available_packet_count() > 0:
			var raw: PackedByteArray = ws_peer.get_packet()
			_handle_ws_packet(raw)
		return
	if status == MultiplayerPeer.CONNECTION_DISCONNECTED:
		# Nối thất bại (cổng đóng / server sập) hoặc mất kết nối
		# giữa chừng: báo ngoại tuyến, dọn socket để bấm nối lại.
		if _ws_was_connecting:
			ws_last_error = "ws-khong-noi-duoc"
		ws_peer = null
		_ws_hello_sent = false
		_ws_was_connecting = false
		ws_peer_id = 0
		ws_players = []
		_set_ws_connected(false)
		ws_presence_changed.emit(ws_players)


# Nhận 1 gói thô từ server: chặn rác không phải JSON object trước
# khi parse (giống PxbServer — tránh JSON.parse_string in ERROR).
func _handle_ws_packet(raw: PackedByteArray) -> void:
	var text := raw.get_string_from_utf8().strip_edges()
	if not text.begins_with("{") or not text.ends_with("}"):
		return
	var parsed: Variant = JSON.parse_string(text)
	if not (parsed is Dictionary):
		return
	_handle_ws_message(parsed)


# Xử lý 1 gói JSON hợp lệ từ server (welcome / presence / chat /
# trade_* / error). Gói lạ thì bỏ lặng — client độc không phá được phòng.
func _handle_ws_message(msg: Dictionary) -> void:
	match String(msg.get("type", "")):
		"welcome":
			ws_peer_id = int(msg.get("peer_id", 0))
			var plist: Variant = msg.get("players", [])
			ws_players = _clean_presence(plist)
			_set_ws_connected(true)
			ws_presence_changed.emit(ws_players)
			_apply_server_day(msg.get("server_day", 0))
			# Vòng 72 (sổ cái): vừa vào phòng thì đồng bộ ví + túi
			# lên server ngay để server có số mới nhất mà validate
			# đấu giá; chưa nối túi/ví thì bỏ qua, _process sẽ sync
			# lại khi đã nối.
			send_ws_ledger_sync()
		"presence":
			var plist2: Variant = msg.get("players", [])
			ws_players = _clean_presence(plist2)
			ws_presence_changed.emit(ws_players)
		"day_sync_ack":
			# Vong 81: ngay server tra loi (xem send_ws_day_sync).
			_apply_server_day(msg.get("server_day", 0))
			var ends_raw: Variant = msg.get("day_ends_in_ms", 0)
			if (ends_raw is int or ends_raw is float) and int(ends_raw) == ends_raw and int(ends_raw) >= 0:
				ws_day_ends_in_ms = int(ends_raw)
		"chat":
			var chat_msg := _clean_chat_message(msg)
			if chat_msg.is_empty():
				return
			ws_chat_log.append(chat_msg)
			while ws_chat_log.size() > WS_CHAT_LOG_MAX:
				ws_chat_log.pop_front()
			ws_chat_received.emit(chat_msg)
		"chat_history":
			# Vong 83: server gui lai lich su chat khi hello lai
			# sau restart — lam sach tung tin nhu chat thuong,
			# them vao log (cap 100), chi phat 1 signal tong.
			# Client cu (khong co case nay) bo qua goi nay.
			# Vong 90: KHU TRUNG — client van giu log cu khi
			# chi ngat roi noi lai (khong mo lai game) nen lich
			# su server gui lai chua chinh cac tin da nhan truc
			# tiep; append mu lam tab Tin nhan hien moi tin 2
			# lan (phat hien V90 pha 1, anh 66). Bo qua tin nao
			# da co trong log (khop player_id + name + text +
			# at_ms), ke ca trung nhau trong cung 1 goi lich su.
			var raw_hist: Variant = msg.get("messages", [])
			var clean_hist: Array = []
			if raw_hist is Array:
				for raw_item in raw_hist:
					if not (raw_item is Dictionary):
						continue
					var clean_item := _clean_chat_message(raw_item)
					if clean_item.is_empty():
						continue
					if _chat_msg_seen(clean_item):
						continue
					ws_chat_log.append(clean_item)
					while ws_chat_log.size() > WS_CHAT_LOG_MAX:
						ws_chat_log.pop_front()
					clean_hist.append(clean_item)
			if not clean_hist.is_empty():
				ws_chat_history_received.emit(clean_hist)
		"trade_offer":
			var offer := _clean_trade(msg)
			if offer.is_empty():
				return
			ws_trade_offers.append(offer)
			ws_trade_offer_received.emit(offer)
		"trade_offered":
			var sent := _clean_trade(msg)
			if sent.is_empty():
				return
			ws_my_offers.append(sent)
			ws_trade_offered_sent.emit(sent)
		"trade_completed":
			var done := _clean_trade(msg)
			if done.is_empty():
				return
			# G4 bước 11: áp thỏa thuận vào túi/ví đã nối TRƯỚC khi
			# phát signal để Main/toast đọc được kết quả áp trong
			# done["apply"]; log đã chốt giữ luôn kết quả này.
			done["apply"] = apply_trade_completed(done)
			_remove_trade(ws_trade_offers, String(done.get("trade_id", "")))
			_remove_trade(ws_my_offers, String(done.get("trade_id", "")))
			ws_trades_completed.append(done)
			while ws_trades_completed.size() > WS_TRADES_MAX:
				ws_trades_completed.pop_front()
			ws_trade_completed.emit(done)
		"trade_declined":
			var did := String(msg.get("trade_id", ""))
			if did.is_empty():
				return
			_remove_trade(ws_my_offers, did)
			ws_trade_declined.emit(did, String(msg.get("reason", "")))
		"trade_cancelled":
			var cid := String(msg.get("trade_id", ""))
			if cid.is_empty():
				return
			_remove_trade(ws_trade_offers, cid)
			_remove_trade(ws_my_offers, cid)
			ws_trade_cancelled.emit(cid, String(msg.get("reason", "")))
		"trade_error":
			ws_last_trade_error = String(msg.get("reason", "ws-loi-trade"))
			ws_trade_error.emit(ws_last_trade_error)
		"auction_created":
			var created := _clean_auction(msg)
			if created.is_empty():
				return
			_upsert_auction(ws_auctions, created)
			ws_auction_created.emit(created)
		"auction_bid":
			var bid := _clean_auction(msg)
			if bid.is_empty():
				return
			# Vong 76: gia moi co the doi reserved cua minh (minh
			# vua dau dan dau / vua bi vuot gia) — sync ngay de
			# lay ack moi biet reserved, khong doi toi lan doi
			# tien tiep theo (luc do Main moi biet ma chan tieu
			# tien giu ho). Chi sync khi minh lien quan.
			var old_bid := _find_auction(ws_auctions, String(bid.get("auction_id", "")))
			var was_mine := not old_bid.is_empty() and String(old_bid.get("current_bidder_player_id", "")) == ws_player_id
			_upsert_auction(ws_auctions, bid)
			if String(bid.get("current_bidder_player_id", "")) == ws_player_id or was_mine:
				send_ws_ledger_sync()
			ws_auction_bid.emit(bid)
		"auction_outbid":
			# Vong 102: tin rieng cho nguoi vua bi vuot gia —
			# server chi gui cho old_bidder (online gui ngay,
			# offline gui lai luc hello sau). Cap nhat phien
			# nhu auction_bid + phat signal kem gia cu. Minh
			# la old_bidder nen reserved cua minh da duoc giai
			# phong o server — sync ngay de lay ack moi (giong
			# truong hop was_mine o auction_bid).
			var outbid := _clean_auction(msg)
			if outbid.is_empty():
				return
			_upsert_auction(ws_auctions, outbid)
			if String(msg.get("old_bidder_player_id", "")) == ws_player_id:
				send_ws_ledger_sync()
			ws_auction_outbid.emit(outbid,
				_clean_money(msg.get("old_bid", 0)),
				String(msg.get("old_bidder_player_id", "")))
		"auction_cancelled":
			var acid := String(msg.get("auction_id", ""))
			if acid.is_empty():
				return
			_remove_auction(ws_auctions, acid)
			ws_auction_cancelled.emit(acid, String(msg.get("reason", "")))
		"auction_closed":
			var closed := _clean_closed_auction(msg)
			if closed.is_empty():
				return
			# G4 bước 12: áp kết quả vào túi/ví đã nối TRƯỚC khi
			# phát signal để Main/toast đọc được kết quả áp trong
			# closed["apply"]; log đã chốt giữ luôn kết quả này
			# (giống trade_completed ở bước 11).
			closed["apply"] = apply_auction_closed(closed)
			_remove_auction(ws_auctions, String(closed.get("auction_id", "")))
			ws_auction_log.append(closed)
			while ws_auction_log.size() > WS_AUCTIONS_MAX:
				ws_auction_log.pop_front()
			ws_auction_closed.emit(closed)
		"auction_list":
			var raw_list: Variant = msg.get("auctions", [])
			var clean_list: Array = []
			if raw_list is Array:
				for raw_item in raw_list:
					if not (raw_item is Dictionary):
						continue
					var clean_item := _clean_auction(raw_item)
					if not clean_item.is_empty():
						clean_list.append(clean_item)
			ws_auctions = clean_list
			ws_auction_list.emit(ws_auctions)
		"auction_error":
			ws_last_auction_error = String(msg.get("reason", "ws-loi-dau-gia"))
			ws_auction_error.emit(ws_last_auction_error)
		"ledger_sync_ack":
			# Vong 76: ack cho lan sync vua gui — lam sach roi moi
			# nhan (goi ban thi bo lang, khong dem dropped vi day
			# la goi server); luu so server lam chuan + dat
			# baseline theo ack (dong vong ghi de stale) + dem
			# ack bi kep; Main ap vao vi/tui qua signal.
			var ack := _clean_ledger_sync_ack(msg)
			if ack.is_empty():
				return
			_apply_server_day(ack.get("server_day", 0))
			# Vong 77: kem tien local luc gui sync nay (pop dau
			# hang doi — ack tra dung thu tu) de Main ap theo
			# delta thay vi ap tuyet doi; sync gui tho khong co
			# muc trong hang doi thi khong kem (Main ap tuyet doi
			# nhu cu). Chi pop khi ack sach — ack ban khong tieu
			# thu muc nao (le chenh 1 muc neu server gui ack ban,
			# server cua minh khong gui ack ban nen chap nhan).
			if not _ws_ledger_sent_money_queue.is_empty():
				ack["sent_money"] = int(_ws_ledger_sent_money_queue.pop_front())
			ws_ledger_authoritative_money = int(ack.get("money", 0))
			ws_ledger_authoritative_items = (ack.get("items", {}) as Dictionary).duplicate()
			ws_reserved_money = int(ack.get("reserved", 0))
			_ws_ledger_last_money = int(ack.get("money", 0))
			_ws_ledger_last_items = (ack.get("items", {}) as Dictionary).duplicate()
			# Vong 78: ack co owned thi dat baseline theo owned
			# server (server chi hop nhat max, khong bao gio
			# giam); ack cua server cu khong co owned thi giu
			# baseline da gui di (khong xoa ve {}).
			if bool(ack.get("owned_present", false)):
				ws_ledger_authoritative_owned = (ack.get("owned", {}) as Dictionary).duplicate()
				_ws_ledger_last_owned = (ack.get("owned", {}) as Dictionary).duplicate()
			_ws_ledger_last_sync_ms = _now_ms()
			if bool(ack.get("clamped_money", false)) or not (ack.get("clamped_items", {}) as Dictionary).is_empty():
				ws_ledger_clamped_count += 1
			ws_last_ledger_ack = ack.duplicate(true)
			ws_ledger_sync_acked.emit(ack)
		"shop_buy_ack":
			# Vong 77: ack cho 1 lan mua o cho — lam sach roi moi
			# nhan; req_id KHONG khop lan mua nao dang cho thi bo
			# lang (ack muon / trung / gia). Chi cap nhat baseline
			# theo ack khi req_id khop: tien server da doi (mua
			# thanh cong thi tru gia) nen lan sync ke phai lay so
			# moi nay lam base, khong thi server bao stale oan.
			var sack := _clean_shop_buy_ack(msg)
			if sack.is_empty():
				return
			_apply_server_day(sack.get("server_day", 0))
			var sreq := int(sack.get("req_id", 0))
			if not _ws_shop_pending.has(sreq):
				return
			_ws_shop_pending.erase(sreq)
			ws_ledger_authoritative_money = int(sack.get("money", 0))
			ws_reserved_money = int(sack.get("reserved", 0))
			_ws_ledger_last_money = int(sack.get("money", 0))
			# Vong 78: ack mua co owned thi dat baseline theo
			# owned server (tien server da doi + owned da cong
			# mon) de lan sync ke khong ghi de lai so cu.
			if bool(sack.get("owned_present", false)):
				ws_ledger_authoritative_owned = (sack.get("owned", {}) as Dictionary).duplicate()
				_ws_ledger_last_owned = (sack.get("owned", {}) as Dictionary).duplicate()
			_ws_ledger_last_sync_ms = _now_ms()
			# Vong 77: ap tien server vao vi da noi khi mua thanh
			# cong (giong apply_auction_closed) — neu khong, vi
			# local van giu so cu va lan ledger_sync ke se ghi de
			# so server (da tru gia) bang so cu. Main ap lai theo
			# delta (tien kiem/tieu trong luc cho ack) sau khi
			# nhan signal nen khong bi ap trung — xem
			# Main._on_ws_shop_buy_acked.
			if bool(sack.get("ok", false)) and trade_economy != null:
				trade_economy.money = int(sack.get("money", 0))
			ws_shop_buy_acked.emit(sack)
		"shop_sell_ack":
			# Vong 86: ack cho 1 lan ban lai cho cho — lam sach roi
			# moi nhan; req_id KHONG khop lan ban nao dang cho thi
			# bo lang (ack muon / trung / gia). Chi cap nhat
			# baseline theo ack khi req_id khop: tien server da doi
			# (ban thanh cong thi cong gia ban lai) nen lan sync ke
			# phai lay so moi nay lam base, khong thi server bao
			# stale oan. Ap tien server vao vi da noi khi ban thanh
			# cong (giong shop_buy) — Main ap lai theo delta sau
			# khi nhan signal nen khong bi ap trung.
			var sell_ack := _clean_shop_sell_ack(msg)
			if sell_ack.is_empty():
				return
			_apply_server_day(sell_ack.get("server_day", 0))
			var sell_req := int(sell_ack.get("req_id", 0))
			if not _ws_shop_sell_pending.has(sell_req):
				return
			_ws_shop_sell_pending.erase(sell_req)
			ws_ledger_authoritative_money = int(sell_ack.get("money", 0))
			ws_reserved_money = int(sell_ack.get("reserved", 0))
			_ws_ledger_last_money = int(sell_ack.get("money", 0))
			if bool(sell_ack.get("owned_present", false)):
				ws_ledger_authoritative_owned = (sell_ack.get("owned", {}) as Dictionary).duplicate()
				_ws_ledger_last_owned = (sell_ack.get("owned", {}) as Dictionary).duplicate()
			_ws_ledger_last_sync_ms = _now_ms()
			if bool(sell_ack.get("ok", false)) and trade_economy != null:
				trade_economy.money = int(sell_ack.get("money", 0))
			ws_shop_sell_acked.emit(sell_ack)
		"stall_hold_sync_ack":
			# Vong 80: ack cho 1 lan dong bo giu sap — lam sach roi
			# moi nhan; req_id KHONG khop lan dong bo nao dang cho
			# thi bo lang (ack muon / trung / gia).
			var hack := _clean_stall_hold_sync_ack(msg)
			if hack.is_empty():
				return
			_apply_server_day(hack.get("server_day", 0))
			var hreq := int(hack.get("req_id", 0))
			if not _ws_hold_pending.has(hreq):
				return
			_ws_hold_pending.erase(hreq)
			ws_last_hold_ack = hack.duplicate(true)
			ws_stall_hold_synced.emit(hack)
		"error":
			ws_last_error = String(msg.get("reason", "ws-loi-server"))
			disconnect_ws()
		_:
			pass


# Chuẩn hóa presence server gửi: chỉ giữ {peer_id, player_id,
# name} hợp lệ, xếp theo peer_id tăng dần.
static func _clean_presence(raw_list: Variant) -> Array:
	var out: Array = []
	if not (raw_list is Array):
		return out
	for item in raw_list:
		if not (item is Dictionary):
			continue
		var pid := String(item.get("player_id", ""))
		var pname := String(item.get("name", ""))
		if pid.is_empty() or pname.is_empty():
			continue
		out.append({
			"peer_id": int(item.get("peer_id", 0)),
			"player_id": pid,
			"name": pname,
		})
	out.sort_custom(func(a, b) -> bool: return int(a["peer_id"]) < int(b["peer_id"]))
	return out


# Kiểm tra + chuẩn hóa 1 gói trade server gửi: bỏ gói thiếu
# trade_id / thiếu 1 bên, mã món quá dài, tiền quá 100 tỉ.
# Trả {} khi gói bẩn (bỏ). completed_at_ms = 0 khi chưa chốt.
static func _clean_trade(msg: Dictionary) -> Dictionary:
	var trade_id := String(msg.get("trade_id", ""))
	var from_id := String(msg.get("from_player_id", ""))
	var to_id := String(msg.get("to_player_id", ""))
	var give_item := String(msg.get("give_item_id", ""))
	var want_item := String(msg.get("want_item_id", ""))
	if trade_id.is_empty() or from_id.is_empty() or to_id.is_empty():
		return {}
	if give_item.length() > WS_MAX_ITEM_ID_LEN or want_item.length() > WS_MAX_ITEM_ID_LEN:
		return {}
	var give_money := _clean_money(msg.get("give_money", 0))
	var want_money := _clean_money(msg.get("want_money", 0))
	if give_money > WS_MAX_TRADE_MONEY_VND or want_money > WS_MAX_TRADE_MONEY_VND:
		return {}
	var out := {
		"trade_id": trade_id,
		"from_player_id": from_id,
		"to_player_id": to_id,
		"give_item_id": give_item,
		"give_money": give_money,
		"want_item_id": want_item,
		"want_money": want_money,
		"created_at_ms": _clean_ms(msg.get("created_at_ms", 0)),
		"completed_at_ms": _clean_ms(msg.get("completed_at_ms", 0)),
	}
	# Vòng 73 (sổ cái): trade_completed có thể kèm khối "ledger"
	# server đã quyết toán — giữ khi hợp lệ, bỏ khối khi bẩn
	# (giữ nguyên giao dịch, apply dùng đường cũ — xem
	# _clean_trade_ledger_block).
	if msg.has("ledger"):
		var lb := _clean_trade_ledger_block(msg.get("ledger", null), out)
		if not lb.is_empty():
			out["ledger"] = lb
	return out


# Kiểm tra + chuẩn hóa khối "ledger" server gửi kèm trade_completed
# (vòng 73): sender_paid 0..give_money, receiver_paid
# 0..want_money; sender/receiver_item_transferred +
# sender/receiver_missing_item là bool; sender/receiver_money_short
# là số nguyên >= 0; reason là chuỗi. Không voided thì phải trả đủ
# theo thỏa thuận (paid == tiền cho, short == 0, missing == false,
# transferred == (món cho không rỗng), reason rỗng). Voided thì
# paid == 0, transferred == false, reason không rỗng, và phải có
# ít nhất 1 nguyên nhân (short > 0 hoặc missing == true). Trả {}
# khi khối bẩn — chỉ bỏ khối ledger, giữ nguyên giao dịch (apply
# dùng đường cũ v70).
static func _clean_trade_ledger_block(raw: Variant, trade: Dictionary) -> Dictionary:
	if not (raw is Dictionary):
		return {}
	var block: Dictionary = raw
	var give_money := int(trade.get("give_money", 0))
	var want_money := int(trade.get("want_money", 0))
	var give_item := String(trade.get("give_item_id", ""))
	var want_item := String(trade.get("want_item_id", ""))
	var sender_paid := _clean_money(block.get("sender_paid", 0))
	var receiver_paid := _clean_money(block.get("receiver_paid", 0))
	var s_short := _clean_money(block.get("sender_money_short", 0))
	var r_short := _clean_money(block.get("receiver_money_short", 0))
	if sender_paid > give_money or receiver_paid > want_money:
		return {}
	var voided: Variant = block.get("voided", null)
	var s_trans: Variant = block.get("sender_item_transferred", null)
	var r_trans: Variant = block.get("receiver_item_transferred", null)
	var s_miss: Variant = block.get("sender_missing_item", null)
	var r_miss: Variant = block.get("receiver_missing_item", null)
	if not (voided is bool) or not (s_trans is bool) or not (r_trans is bool) \
			or not (s_miss is bool) or not (r_miss is bool):
		return {}
	var reason := String(block.get("reason", ""))
	if bool(voided):
		if sender_paid > 0 or receiver_paid > 0 or bool(s_trans) or bool(r_trans):
			return {}
		if reason.is_empty():
			return {}
		if s_short == 0 and r_short == 0 and not bool(s_miss) and not bool(r_miss):
			return {}
	else:
		if sender_paid != give_money or receiver_paid != want_money:
			return {}
		if s_short != 0 or r_short != 0 or bool(s_miss) or bool(r_miss):
			return {}
		if bool(s_trans) != (not give_item.is_empty()):
			return {}
		if bool(r_trans) != (not want_item.is_empty()):
			return {}
		if not reason.is_empty():
			return {}
	return {
		"voided": bool(voided), "reason": reason,
		"sender_paid": sender_paid, "receiver_paid": receiver_paid,
		"sender_item_transferred": bool(s_trans),
		"receiver_item_transferred": bool(r_trans),
		"sender_money_short": s_short, "receiver_money_short": r_short,
		"sender_missing_item": bool(s_miss),
		"receiver_missing_item": bool(r_miss),
	}


# Tìm 1 đề nghị trong danh sách theo trade_id; {} = không có.
static func _find_trade(list: Array, trade_id: String) -> Dictionary:
	for item in list:
		if item is Dictionary and String(item.get("trade_id", "")) == trade_id:
			return item
	return {}


# Xóa 1 đề nghị khỏi danh sách theo trade_id (không có thì thôi).
static func _remove_trade(list: Array, trade_id: String) -> void:
	for i in range(list.size() - 1, -1, -1):
		var item: Dictionary = list[i]
		if String(item.get("trade_id", "")) == trade_id:
			list.remove_at(i)


# Kiểm tra + chuẩn hóa 1 phiên đấu giá đang mở server gửi: bỏ
# phiên thiếu auction_id / thiếu người bán / thiếu mã món / mã món
# quá dài / giá khởi điểm ngoài 1.000..100 tỉ / giá hiện tại quá
# 100 tỉ / thiếu hạn đóng. Trả {} khi gói bẩn (bỏ). current_bid = 0
# + current_bidder rỗng = chưa ai đấu giá.
static func _clean_auction(msg: Dictionary) -> Dictionary:
	var auction_id := String(msg.get("auction_id", ""))
	var seller_id := String(msg.get("seller_player_id", ""))
	var item_id := String(msg.get("item_id", ""))
	if auction_id.is_empty() or seller_id.is_empty() or item_id.is_empty():
		return {}
	if item_id.length() > WS_MAX_ITEM_ID_LEN:
		return {}
	var start_price := _clean_money(msg.get("start_price", 0))
	var current_bid := _clean_money(msg.get("current_bid", 0))
	if start_price < WS_MIN_AUCTION_START_PRICE_VND \
			or start_price > WS_MAX_AUCTION_MONEY_VND \
			or current_bid > WS_MAX_AUCTION_MONEY_VND:
		return {}
	var ends_at := _clean_ms(msg.get("ends_at_ms", 0))
	if ends_at <= 0:
		return {}
	return {
		"auction_id": auction_id,
		"seller_player_id": seller_id,
		"item_id": item_id,
		"start_price": start_price,
		"current_bid": current_bid,
		"current_bidder_player_id": String(msg.get("current_bidder_player_id", "")),
		"created_at_ms": _clean_ms(msg.get("created_at_ms", 0)),
		"ends_at_ms": ends_at,
	}


# Kiểm tra + chuẩn hóa khối "ledger" server gửi kèm auction_closed
# (vòng 72): winner_paid / seller_received / fee_vnd / short_money
# là số nguyên 0..hammer, fee = paid - received (cắt lẻ theo phép
# chia nguyên như server), short_money = hammer - paid (trừ khi
# giao dịch bị hủy vì thiếu món — khi đó paid = received = fee =
# short = 0, missing_item = true, item_transferred = false).
# Phiên không ai đấu giá (hammer = 0) thì khối toàn 0, không
# chuyển món cũng không thiếu món. Trả {} khi khối bẩn — chỉ bỏ
# khối ledger, giữ nguyên phiên đã đóng (apply dùng đường cũ).
static func _clean_ledger_block(raw: Variant, hammer: int) -> Dictionary:
	if not (raw is Dictionary):
		return {}
	var paid := _clean_money((raw as Dictionary).get("winner_paid", -1))
	var received := _clean_money((raw as Dictionary).get("seller_received", -1))
	var fee := _clean_money((raw as Dictionary).get("fee_vnd", -1))
	var short_money := _clean_money((raw as Dictionary).get("short_money", -1))
	if paid < 0 or received < 0 or fee < 0 or short_money < 0:
		return {}
	if paid > hammer or received > paid or fee != paid - received:
		return {}
	var missing_item: Variant = (raw as Dictionary).get("missing_item", null)
	var transferred: Variant = (raw as Dictionary).get("item_transferred", null)
	if not (missing_item is bool) or not (transferred is bool):
		return {}
	if hammer == 0:
		if paid > 0 or received > 0 or short_money > 0:
			return {}
		return {
			"winner_paid": paid, "seller_received": received,
			"fee_vnd": fee, "short_money": short_money,
			"missing_item": bool(missing_item),
			"item_transferred": bool(transferred),
		}
	if bool(missing_item):
		if paid > 0 or received > 0 or short_money > 0 or bool(transferred):
			return {}
	else:
		if short_money != hammer - paid or not bool(transferred):
			return {}
	return {
		"winner_paid": paid, "seller_received": received,
		"fee_vnd": fee, "short_money": short_money,
		"missing_item": bool(missing_item),
		"item_transferred": bool(transferred),
	}


# Kiểm tra + chuẩn hóa 1 phiên đấu giá ĐÃ ĐÓNG server gửi: như
# _clean_auction + winner / hammer_price / fee_vnd /
# seller_receives_vnd / closed_at_ms + khối "ledger" (vòng 72,
# giữ nguyên khi hợp lệ, bỏ khối khi bẩn — xem
# _clean_ledger_block). Phiên không ai đấu giá thì
# winner rỗng + hammer = fee = seller_receives = 0 (vẫn hợp lệ).
# Trả {} khi gói bẩn (bỏ).
static func _clean_closed_auction(msg: Dictionary) -> Dictionary:
	var open_part := _clean_auction(msg)
	if open_part.is_empty():
		return {}
	var hammer := _clean_money(msg.get("hammer_price", 0))
	var fee := _clean_money(msg.get("fee_vnd", 0))
	var receives := _clean_money(msg.get("seller_receives_vnd", 0))
	var winner := String(msg.get("winner_player_id", ""))
	if hammer > WS_MAX_AUCTION_MONEY_VND \
			or fee > hammer or receives > hammer:
		return {}
	if hammer == 0 and not winner.is_empty():
		return {}
	if hammer > 0 and winner.is_empty():
		return {}
	var closed_at := _clean_ms(msg.get("closed_at_ms", 0))
	if closed_at <= 0:
		return {}
	open_part["winner_player_id"] = winner
	open_part["hammer_price"] = hammer
	open_part["fee_vnd"] = fee
	open_part["seller_receives_vnd"] = receives
	open_part["closed_at_ms"] = closed_at
	var ledger_block := _clean_ledger_block(msg.get("ledger", null), hammer)
	if not ledger_block.is_empty():
		open_part["ledger"] = ledger_block
	return open_part


# Tìm 1 phiên đang mở trong danh sách theo auction_id; {} = không có.
static func _find_auction(list: Array, auction_id: String) -> Dictionary:
	for item in list:
		if item is Dictionary and String(item.get("auction_id", "")) == auction_id:
			return item
	return {}


# Xóa 1 phiên khỏi danh sách theo auction_id (không có thì thôi).
static func _remove_auction(list: Array, auction_id: String) -> void:
	for i in range(list.size() - 1, -1, -1):
		var item: Dictionary = list[i]
		if String(item.get("auction_id", "")) == auction_id:
			list.remove_at(i)


# Thêm mới hoặc cập nhật 1 phiên đang mở trong danh sách (giữ
# tối đa 50 phiên — server chỉ cho 1 phiên / người bán nên danh
# sách ngắn, cắt cũ nhất cho chắc).
static func _upsert_auction(list: Array, auction: Dictionary) -> void:
	_remove_auction(list, String(auction.get("auction_id", "")))
	list.append(auction)
	while list.size() > WS_AUCTIONS_MAX:
		list.pop_front()


# Chuẩn hóa 1 tin chat server gửi: bỏ tin thiếu tên/text hoặc
# text quá dài (server đáng lẽ đã lọc — client lọc lại cho chắc).
static func _clean_chat_message(msg: Dictionary) -> Dictionary:
	var pname := String(msg.get("name", ""))
	var text := String(msg.get("text", ""))
	if pname.is_empty() or text.is_empty() or text.length() > WS_MAX_CHAT_LEN:
		return {}
	return {
		"player_id": String(msg.get("player_id", "")),
		"name": pname,
		"text": text,
		"at_ms": _clean_ms(msg.get("at_ms", 0)),
	}


# Vong 90: tin da co trong ws_chat_log chua (khop ca 4 truong da
# chuan hoa)? Dung khi nhan chat_history de khu trung — tin gui
# trong cung mili-giay, cung nguoi, cung noi dung thi khong phan
# biet duoc voi ban sao nen tinh la trung (an toan hon hien doi).
func _chat_msg_seen(msg: Dictionary) -> bool:
	for old in ws_chat_log:
		var o := old as Dictionary
		if o.is_empty():
			continue
		if String(o.get("player_id", "")) == String(msg.get("player_id", "")) \
			and String(o.get("name", "")) == String(msg.get("name", "")) \
			and String(o.get("text", "")) == String(msg.get("text", "")) \
			and int(o.get("at_ms", 0)) == int(msg.get("at_ms", 0)):
			return true
	return false


# Gửi 1 tin chat lên server (phải đã nối + đã welcome). Trả
# {ok:true} khi đã gửi (server broadcast lại, kể cả cho chính
# mình — tin hiện trong log khi nhận echo), {ok:false, reason}
# khi chưa nối / chat rỗng / chat quá 500 ký tự / socket lỗi.
func send_ws_chat(text: String) -> Dictionary:
	if not ws_connected or ws_peer == null:
		return {"ok": false, "reason": "chua-ket-noi-ws"}
	var clean := text.strip_edges()
	if clean.is_empty():
		return {"ok": false, "reason": "chat-trong"}
	if clean.length() > WS_MAX_CHAT_LEN:
		return {"ok": false, "reason": "chat-qua-dai"}
	var err: Error = ws_peer.put_packet(JSON.stringify(
		{"type": "chat", "text": clean}).to_utf8_buffer())
	if err != OK:
		return {"ok": false, "reason": "ws-gui-that-bai", "error": err}
	return {"ok": true}


# --- Đổi đồ qua server Godot (G4 bước 10, protocol v1) ---
# Server giữ đề nghị + validate + ghi nhận thỏa thuận
# (trade_completed); client áp thỏa thuận vào túi/ví đã nối qua
# apply_trade_completed() (G4 bước 11, xem _handle_ws_message).
# Tiền/đồ chuyển thật ở server cần sổ cái server giữ — chưa có.

# Gửi 1 đề nghị đổi đồ cho người chơi khác (phải đã nối + đã
# welcome). Trả {ok:true} khi đã gửi (server trả trade_offered
# cho mình + trade_offer cho người nhận), {ok:false, reason} khi
# chưa nối / sai luật ở client (đổi với chính mình, đề nghị
# trống, tiền ngoài 0..100 tỉ, mã món quá dài, đã có đề nghị chờ).
func send_ws_trade_offer(to_player_id: String, give_item_id: String,
		give_money: int, want_item_id: String, want_money: int) -> Dictionary:
	if not ws_connected or ws_peer == null:
		return {"ok": false, "reason": "chua-ket-noi-ws"}
	var to_id := to_player_id.strip_edges()
	if to_id.is_empty():
		return {"ok": false, "reason": "thieu-nguoi-nhan"}
	if to_id == ws_player_id:
		return {"ok": false, "reason": "khong-doi-voi-chinh-minh"}
	var give_item := give_item_id.strip_edges()
	var want_item := want_item_id.strip_edges()
	if give_item.length() > WS_MAX_ITEM_ID_LEN or want_item.length() > WS_MAX_ITEM_ID_LEN:
		return {"ok": false, "reason": "item-id-qua-dai"}
	if give_money < 0 or give_money > WS_MAX_TRADE_MONEY_VND \
			or want_money < 0 or want_money > WS_MAX_TRADE_MONEY_VND:
		return {"ok": false, "reason": "tien-trade-khong-hop-le"}
	if (give_item.is_empty() and give_money == 0) \
			or (want_item.is_empty() and want_money == 0):
		return {"ok": false, "reason": "de-nghi-trong"}
	if not ws_my_offers.is_empty():
		return {"ok": false, "reason": "da-co-de-nghi-cho"}
	# G4 bước 11: chỉ gửi đề nghị mình đủ khả năng cho (khi đã nối
	# túi/ví) — tránh chốt xong mới biết thiếu. Chưa nối thì bỏ qua
	# kiểm tra này (không biết số dư). Khe hở còn lại: số dư đổi
	# giữa lúc gửi và lúc chốt — apply_trade_completed ghi short.
	if trade_inventory != null and not give_item.is_empty() \
			and trade_inventory.count(give_item) < 1:
		return {"ok": false, "reason": "khong-du-do-cho"}
	if trade_economy != null and give_money > trade_economy.money:
		return {"ok": false, "reason": "khong-du-tien-cho"}
	# Vòng 73 (sổ cái): đồng bộ số dư lên server trước khi gửi
	# đề nghị để server validate bằng số mới nhất. Sync lỗi
	# (chưa nối túi/ví) thì vẫn gửi — server cho qua như hành vi
	# cũ khi chưa có ledger.
	send_ws_ledger_sync()
	var err: Error = ws_peer.put_packet(JSON.stringify({
		"type": "trade_offer", "to_player_id": to_id,
		"give_item_id": give_item, "give_money": give_money,
		"want_item_id": want_item, "want_money": want_money,
	}).to_utf8_buffer())
	if err != OK:
		return {"ok": false, "reason": "ws-gui-that-bai", "error": err}
	return {"ok": true}


# Chấp nhận 1 đề nghị đang chờ mình trả lời. Chỉ người nhận mới
# chấp nhận được — client kiểm tra đề nghị có trong
# ws_trade_offers trước khi gửi (server kiểm tra lại).
func send_ws_trade_accept(trade_id: String) -> Dictionary:
	if not ws_connected or ws_peer == null:
		return {"ok": false, "reason": "chua-ket-noi-ws"}
	var tid := trade_id.strip_edges()
	if tid.is_empty():
		return {"ok": false, "reason": "thieu-trade-id"}
	var offer := _find_trade(ws_trade_offers, tid)
	if offer.is_empty():
		return {"ok": false, "reason": "khong-tim-thay-de-nghi"}
	# G4 bước 11: người nhận cho đi want_item/want_money — kiểm
	# tra đủ khả năng như bên gửi (xem send_ws_trade_offer).
	if trade_inventory != null \
			and not String(offer.get("want_item_id", "")).is_empty() \
			and trade_inventory.count(String(offer.get("want_item_id", ""))) < 1:
		return {"ok": false, "reason": "khong-du-do-cho"}
	if trade_economy != null and int(offer.get("want_money", 0)) > trade_economy.money:
		return {"ok": false, "reason": "khong-du-tien-cho"}
	# Vòng 73 (sổ cái): đồng bộ số dư lên server trước khi chấp
	# nhận để server quyết toán bằng số mới nhất (xem
	# send_ws_trade_offer).
	send_ws_ledger_sync()
	var err: Error = ws_peer.put_packet(JSON.stringify(
		{"type": "trade_accept", "trade_id": tid}).to_utf8_buffer())
	if err != OK:
		return {"ok": false, "reason": "ws-gui-that-bai", "error": err}
	return {"ok": true}


# Từ chối 1 đề nghị đang chờ mình trả lời (chỉ người nhận).
func send_ws_trade_decline(trade_id: String) -> Dictionary:
	if not ws_connected or ws_peer == null:
		return {"ok": false, "reason": "chua-ket-noi-ws"}
	var tid := trade_id.strip_edges()
	if tid.is_empty():
		return {"ok": false, "reason": "thieu-trade-id"}
	if _find_trade(ws_trade_offers, tid).is_empty():
		return {"ok": false, "reason": "khong-tim-thay-de-nghi"}
	var err: Error = ws_peer.put_packet(JSON.stringify(
		{"type": "trade_decline", "trade_id": tid}).to_utf8_buffer())
	if err != OK:
		return {"ok": false, "reason": "ws-gui-that-bai", "error": err}
	# Server chỉ báo trade_declined cho người gửi — bên từ chối tự
	# xóa đề nghị khỏi danh sách chờ của mình ngay khi gửi xong.
	_remove_trade(ws_trade_offers, tid)
	return {"ok": true}


# Hủy 1 đề nghị mình đã gửi, đang chờ (chỉ người gửi).
func send_ws_trade_cancel(trade_id: String) -> Dictionary:
	if not ws_connected or ws_peer == null:
		return {"ok": false, "reason": "chua-ket-noi-ws"}
	var tid := trade_id.strip_edges()
	if tid.is_empty():
		return {"ok": false, "reason": "thieu-trade-id"}
	if _find_trade(ws_my_offers, tid).is_empty():
		return {"ok": false, "reason": "khong-tim-thay-de-nghi"}
	var err: Error = ws_peer.put_packet(JSON.stringify(
		{"type": "trade_cancel", "trade_id": tid}).to_utf8_buffer())
	if err != OK:
		return {"ok": false, "reason": "ws-gui-that-bai", "error": err}
	# Server chỉ báo trade_cancelled cho người nhận — bên hủy tự
	# xóa đề nghị khỏi danh sách đã gửi của mình ngay khi gửi xong.
	_remove_trade(ws_my_offers, tid)
	return {"ok": true}


# Áp 1 giao dịch đã chốt vào túi + ví của MÌNH (G4 bước 11).
# Gọi tự động trong _handle_ws_message khi nhận trade_completed;
# Main/test cũng gọi trực tiếp được để kiểm tra lại.
# - Vai: người gửi (from_player_id == ws_player_id) cho đi
#   give_item/give_money, nhận lại want_item/want_money; người
#   nhận thì ngược lại. Không phải 1 trong 2 bên thì bỏ
#   (khong-lien-quan) — server đáng lẽ không gửi cho mình.
# - Chống áp trùng: trade_id đã có trong ws_trades_applied thì trả
#   duplicate=true, không trừ/cộng gì lần 2 (giữ 50 id gần nhất).
# - Chưa nối túi/ví (trade_inventory/trade_economy null) thì trả
#   chua-noi-tui-vi, không ghi id đã áp (nối xong áp lại được).
# - Áp từng phần, ghi rõ phần thiếu thay vì bỏ cả giao dịch: món
#   cho không có trong túi → missing_item=true, túi không âm;
#   món nhận trùng đồ không xếp chồng đã có → receive_failed=true;
#   tiền cho thiếu → trừ tới 0, ghi short_money (ví không âm).
#   Tiền/món nhận cộng đủ theo thỏa thuận. Không throw — luôn trả
#   Dictionary.
# - KHE HỞ ĐÃ BIẾT (v1, chưa có sổ cái server): 2 bên áp độc lập
#   theo thỏa thuận, không biết số dư thật của nhau. Bên gửi/chấp
#   nhận đã kiểm đủ khả năng lúc gửi/chấp nhận (khong-du-do-cho /
#   khong-du-tien-cho) nên đường thường không lọt; chỉ khi số dư
#   đổi GIỮA lúc gửi và lúc chốt (vd tiêu tiền / dùng món sau khi
#   gửi đề nghị) thì bên cho áp thiếu (ghi short_money /
#   missing_item vào log) còn bên nhận vẫn nhận đủ theo thỏa thuận
#   — tiền/món chênh lệch đó chỉ ghi trong log. Vòng 73 ĐÃ ĐÓNG
#   khe này ở phía server: _settle_trade kiểm tra sổ cái lúc
#   chấp nhận, đủ mới chuyển cả 2 chiều (nguyên tử), thiếu thì
#   HỦY giao dịch (khối "ledger" kèm trade_completed, voided =
#   true, không bên nào mất gì); client áp đúng số server đã
#   quyết toán. Không có khối ledger (server cũ / chưa ai đồng
#   bộ) thì dùng đường cũ v70.
# Trả {applied, role, duplicate, voided, ledger, give_item_id,
# give_item_ok, missing_item, want_item_id, want_item_ok,
# receive_failed, money_given, money_received, short_money}
# (+ reason khi chưa áp).
func apply_trade_completed(trade: Dictionary) -> Dictionary:
	var clean := _clean_trade(trade)
	if clean.is_empty():
		return {"applied": false, "reason": "goi-trade-khong-hop-le",
			"duplicate": false, "role": ""}
	var tid := String(clean.get("trade_id", ""))
	var role := ""
	if String(clean.get("from_player_id", "")) == ws_player_id and not ws_player_id.is_empty():
		role = "sender"
	elif String(clean.get("to_player_id", "")) == ws_player_id and not ws_player_id.is_empty():
		role = "receiver"
	if role.is_empty():
		return {"applied": false, "reason": "khong-lien-quan",
			"duplicate": false, "role": ""}
	if tid in ws_trades_applied:
		return {"applied": false, "reason": "da-ap-truoc-do",
			"duplicate": true, "role": role}
	if trade_inventory == null or trade_economy == null:
		return {"applied": false, "reason": "chua-noi-tui-vi",
			"duplicate": false, "role": role}
	var give_item := ""
	var want_item := ""
	var give_money := 0
	var want_money := 0
	if role == "sender":
		give_item = String(clean.get("give_item_id", ""))
		want_item = String(clean.get("want_item_id", ""))
		give_money = int(clean.get("give_money", 0))
		want_money = int(clean.get("want_money", 0))
	else:
		give_item = String(clean.get("want_item_id", ""))
		want_item = String(clean.get("give_item_id", ""))
		give_money = int(clean.get("want_money", 0))
		want_money = int(clean.get("give_money", 0))
	# Vòng 73 (sổ cái): có khối "ledger" hợp lệ thì áp đúng số
	# server đã quyết toán — không còn áp theo thỏa thuận mù.
	var ledger_block: Dictionary = clean.get("ledger", {})
	var use_ledger := not ledger_block.is_empty()
	if use_ledger and bool(ledger_block.get("voided", false)):
		# Giao dịch bị HỦY ở server (1 bên đã đồng bộ không đủ
		# khả năng lúc chốt) — không trừ/cộng gì ở local; ghi id
		# đã áp để không áp trùng, trả lý do hủy để Main/toast
		# báo rõ (giống auction_closed bị hủy vì thiếu món).
		ws_trades_applied.append(tid)
		while ws_trades_applied.size() > WS_TRADES_MAX:
			ws_trades_applied.pop_front()
		var v_missing := false
		var v_short := 0
		if role == "sender":
			v_missing = bool(ledger_block.get("sender_missing_item", false))
			v_short = int(ledger_block.get("sender_money_short", 0))
		else:
			v_missing = bool(ledger_block.get("receiver_missing_item", false))
			v_short = int(ledger_block.get("receiver_money_short", 0))
		return {
			"applied": false, "role": role, "duplicate": false,
			"reason": String(ledger_block.get("reason", "giao-dich-bi-huy")),
			"voided": true, "ledger": true,
			"give_item_id": give_item, "give_item_ok": false,
			"missing_item": v_missing,
			"want_item_id": want_item, "want_item_ok": false,
			"receive_failed": false,
			"money_given": 0, "money_received": 0,
			"short_money": v_short,
		}
	if use_ledger:
		# Đã quyết toán: tiền cho = số server ghi (bằng tiền
		# thỏa thuận khi không voided — đã kiểm ở
		# _clean_trade_ledger_block), tiền nhận = số bên kia
		# đã trả theo sổ cái.
		if role == "sender":
			give_money = int(ledger_block.get("sender_paid", give_money))
			want_money = int(ledger_block.get("receiver_paid", want_money))
		else:
			give_money = int(ledger_block.get("receiver_paid", give_money))
			want_money = int(ledger_block.get("sender_paid", want_money))
	var give_item_ok := true
	var missing_item := false
	if not give_item.is_empty():
		if trade_inventory.remove(give_item, 1):
			give_item_ok = true
		else:
			give_item_ok = false
			missing_item = true
	var want_item_ok := true
	var receive_failed := false
	if not want_item.is_empty():
		if trade_inventory.add(want_item, 1):
			want_item_ok = true
		else:
			want_item_ok = false
			receive_failed = true
	var money_given := mini(maxi(trade_economy.money, 0), give_money)
	trade_economy.money = maxi(trade_economy.money, 0) - money_given
	var short_money := give_money - money_given
	trade_economy.money += want_money
	ws_trades_applied.append(tid)
	while ws_trades_applied.size() > WS_TRADES_MAX:
		ws_trades_applied.pop_front()
	# Vong 76: ap xong thi dat lai baseline theo so local moi —
	# server cung vua doi ledger theo cung quyet toan do, lan sync
	# ke gui base_money dung so sau quyet toan (khong bi danh stale
	# oan). Ap tung phan thi baseline co the lech ledger — lan sync
	# ke stale, ack ve roi Main ap lai so server (vong khoi phuc).
	_rebaseline_ledger_after_settlement()
	return {
		"applied": true, "role": role, "duplicate": false,
		"voided": false, "ledger": use_ledger,
		"give_item_id": give_item, "give_item_ok": give_item_ok,
		"missing_item": missing_item,
		"want_item_id": want_item, "want_item_ok": want_item_ok,
		"receive_failed": receive_failed,
		"money_given": money_given, "money_received": want_money,
		"short_money": short_money,
	}


# --- Đấu giá qua server Godot (G4 bước 12, protocol v1) ---
# Server giữ phiên + validate giá + tự đóng khi hết giờ + tính phí
# sàn 5% (đã chốt); client áp kết quả auction_closed vào túi/ví đã
# nối qua apply_auction_closed() (giống trade_completed ở bước 11).
# Tiền/đồ chuyển thật ở server cần sổ cái server giữ — chưa có.

# Mở 1 phiên đấu giá bán 1 món (phải đã nối + đã welcome). Trả
# {ok:true} khi đã gửi (server broadcast auction_created cho mọi
# người), {ok:false, reason} khi chưa nối / sai luật ở client (mã
# món rỗng/quá dài, giá khởi điểm ngoài 1.000..100 tỉ, thời gian
# ngoài 30..3600 giây, đã có phiên đang mở, không có món trong túi
# khi đã nối túi).
func send_ws_auction_create(item_id: String, start_price: int,
		duration_s: int) -> Dictionary:
	if not ws_connected or ws_peer == null:
		return {"ok": false, "reason": "chua-ket-noi-ws"}
	var item := item_id.strip_edges()
	if item.is_empty():
		return {"ok": false, "reason": "thieu-item-id"}
	if item.length() > WS_MAX_ITEM_ID_LEN:
		return {"ok": false, "reason": "item-id-qua-dai"}
	if start_price < WS_MIN_AUCTION_START_PRICE_VND \
			or start_price > WS_MAX_AUCTION_MONEY_VND:
		return {"ok": false, "reason": "gia-khoi-diem-khong-hop-le"}
	if duration_s < WS_MIN_AUCTION_DURATION_S \
			or duration_s > WS_MAX_AUCTION_DURATION_S:
		return {"ok": false, "reason": "thoi-gian-khong-hop-le"}
	for a in ws_auctions:
		if String((a as Dictionary).get("seller_player_id", "")) == ws_player_id:
			return {"ok": false, "reason": "da-co-dau-gia-mo"}
	# G4 bước 12: chỉ mở phiên bán món mình đang có trong túi (khi
	# đã nối túi) — tránh chốt xong mới biết thiếu món. Chưa nối
	# thì bỏ qua kiểm tra này (không biết túi).
	if trade_inventory != null and trade_inventory.count(item) < 1:
		return {"ok": false, "reason": "khong-du-do-cho"}
	# Vòng 72 (sổ cái): đồng bộ số dư lên server trước khi mở
	# phiên để server validate bằng số mới nhất. Sync lỗi (chưa
	# nối túi/ví) thì vẫn gửi lệnh — server cho qua như hành vi cũ
	# khi chưa có ledger.
	send_ws_ledger_sync()
	var err: Error = ws_peer.put_packet(JSON.stringify({
		"type": "auction_create", "item_id": item,
		"start_price": start_price, "duration_s": duration_s,
	}).to_utf8_buffer())
	if err != OK:
		return {"ok": false, "reason": "ws-gui-that-bai", "error": err}
	return {"ok": true}


# Đặt giá trong 1 phiên đang mở (phải đã nối + đã welcome). Giá đầu
# tiên >= giá khởi điểm, các giá sau >= giá hiện tại + 1.000đ.
# Người bán không được đấu giá của mình. Khi đã nối ví thì chỉ đặt
# giá mình đủ tiền trả (khong-du-tien-cho). Server kiểm tra lại.
func send_ws_auction_bid(auction_id: String, amount: int) -> Dictionary:
	if not ws_connected or ws_peer == null:
		return {"ok": false, "reason": "chua-ket-noi-ws"}
	var aid := auction_id.strip_edges()
	if aid.is_empty():
		return {"ok": false, "reason": "thieu-auction-id"}
	var auction := _find_auction(ws_auctions, aid)
	if auction.is_empty():
		return {"ok": false, "reason": "khong-tim-thay-dau-gia"}
	if String(auction.get("seller_player_id", "")) == ws_player_id:
		return {"ok": false, "reason": "nguoi-ban-khong-duoc-dau-gia"}
	if amount < WS_MIN_AUCTION_START_PRICE_VND \
			or amount > WS_MAX_AUCTION_MONEY_VND:
		return {"ok": false, "reason": "gia-dau-khong-hop-le"}
	var min_next: int = int(auction.get("start_price", 0))
	if int(auction.get("current_bid", 0)) > 0:
		min_next = int(auction.get("current_bid", 0)) + WS_MIN_BID_INCREMENT_VND
	if amount < min_next:
		return {"ok": false, "reason": "gia-dau-thap-hon-gia-hien-tai"}
	if trade_economy != null and amount > trade_economy.money:
		return {"ok": false, "reason": "khong-du-tien-cho"}
	# Vòng 72 (sổ cái): đồng bộ số dư lên server trước khi đặt giá
	# để server validate + giữ hộ bằng số mới nhất (xem
	# send_ws_auction_create — cùng lý do).
	send_ws_ledger_sync()
	var err: Error = ws_peer.put_packet(JSON.stringify({
		"type": "auction_bid", "auction_id": aid, "amount": amount,
	}).to_utf8_buffer())
	if err != OK:
		return {"ok": false, "reason": "ws-gui-that-bai", "error": err}
	return {"ok": true}


# Hủy 1 phiên mình đã mở, CHƯA có ai đấu giá (chỉ người bán).
# Có giá rồi thì không hủy được (server cũng chặn).
func send_ws_auction_cancel(auction_id: String) -> Dictionary:
	if not ws_connected or ws_peer == null:
		return {"ok": false, "reason": "chua-ket-noi-ws"}
	var aid := auction_id.strip_edges()
	if aid.is_empty():
		return {"ok": false, "reason": "thieu-auction-id"}
	var auction := _find_auction(ws_auctions, aid)
	if auction.is_empty():
		return {"ok": false, "reason": "khong-tim-thay-dau-gia"}
	if String(auction.get("seller_player_id", "")) != ws_player_id:
		return {"ok": false, "reason": "khong-phai-nguoi-ban"}
	if int(auction.get("current_bid", 0)) > 0:
		return {"ok": false, "reason": "da-co-gia-khong-huy-duoc"}
	var err: Error = ws_peer.put_packet(JSON.stringify(
		{"type": "auction_cancel", "auction_id": aid}).to_utf8_buffer())
	if err != OK:
		return {"ok": false, "reason": "ws-gui-that-bai", "error": err}
	# Server broadcast auction_cancelled cho mọi người (kể cả mình)
	# nên không tự xóa ở đây — đợi gói đó về.
	return {"ok": true}


# Xin danh sách phiên đang mở: server trả auction_list chỉ cho
# mình (ws_auctions được thay bằng danh sách mới).
func request_ws_auction_list() -> Dictionary:
	if not ws_connected or ws_peer == null:
		return {"ok": false, "reason": "chua-ket-noi-ws"}
	var err: Error = ws_peer.put_packet(JSON.stringify(
		{"type": "auction_list"}).to_utf8_buffer())
	if err != OK:
		return {"ok": false, "reason": "ws-gui-that-bai", "error": err}
	return {"ok": true}


# Chụp nhanh túi đồ để đồng bộ sổ cái: chỉ giữ {item_id: count}
# hợp lệ (id ≤ 64 ký tự, count int >= 0, tối đa 512 món) — khớp
# giới hạn server (PxbServer.LEDGER_MAX_ITEMS).
static func _ledger_items_snapshot_from(inv: PxbInventory) -> Dictionary:
	var out := {}
	var raw: Variant = (inv.data() as Dictionary).get("items", {})
	if not (raw is Dictionary):
		return out
	for k in (raw as Dictionary).keys():
		if out.size() >= WS_LEDGER_MAX_ITEMS:
			break
		var item_id := String(k).strip_edges()
		var count: Variant = (raw as Dictionary)[k]
		if item_id.is_empty() or item_id.length() > WS_MAX_ITEM_ID_LEN:
			continue
		if not (count is int or count is float) or int(count) != count or int(count) < 0:
			continue
		out[item_id] = int(count)
	return out


# Chụp nhanh tài sản đã mua ở chợ để đồng bộ sổ cái: đếm
# economy.owned (Array[String], có thể trùng id) thành dict
# {item_id: count} — khớp giới hạn server (count 0..99).
static func _owned_snapshot_from(eco: PxbEconomy) -> Dictionary:
	var out := {}
	if eco == null:
		return out
	for id in eco.owned:
		var item_id := String(id).strip_edges()
		if item_id.is_empty() or item_id.length() > WS_MAX_ITEM_ID_LEN:
			continue
		out[item_id] = int(out.get(item_id, 0)) + 1
	return out


# Làm sạch dict owned trong ack server trả (vòng 78): chỉ giữ
# món có trong bảng giá PxbEconomy, item_id ≤ 64 ký tự, count
# int 0..99; món sai thì bỏ món đó, giữ phần đúng. Trả {} khi
# đầu vào không phải dict.
static func _clean_owned_dict(raw: Variant) -> Dictionary:
	var out := {}
	if not (raw is Dictionary):
		return out
	for k in (raw as Dictionary).keys():
		var item_id := String(k).strip_edges()
		var count: Variant = (raw as Dictionary)[k]
		if item_id.is_empty() or item_id.length() > WS_MAX_ITEM_ID_LEN:
			continue
		if not (count is int or count is float) or int(count) != count \
				or int(count) < 0 or int(count) > 99:
			continue
		if PxbEconomy.get_item(item_id).is_empty():
			continue
		out[item_id] = int(count)
	return out


# Kiểm tra + chuẩn hóa gói ledger_sync_ack server trả (vòng
# 76): money int >= 0, items dict {item_id: count >= 0}, reserved
# int >= 0, clamped_money / stale bool, clamped_items dict
# {item_id: so toi thieu >= 0}. Trả {} khi gói bẩn (bỏ gói, không
# đếm dropped vì đây là gói server); món trong items /
# clamped_items sai thì bỏ món đó, giữ phần đúng; thiếu
# clamped_money / stale thì mặc định false, thiếu clamped_items
# thì mặc định {} (server cũ không gửi các khóa này). Vòng 78:
# "owned" là khóa TÙY CHỌN — có thì làm sạch qua
# _clean_owned_dict + owned_present=true; không có (server cũ)
# thì owned={} + owned_present=false; có nhưng không phải dict
# thì gói bẩn, trả {}.
static func _clean_ledger_sync_ack(msg: Dictionary) -> Dictionary:
	var money: Variant = msg.get("money", -1)
	if not (money is int or money is float) or int(money) != money or int(money) < 0:
		return {}
	var raw_items: Variant = msg.get("items", null)
	if not (raw_items is Dictionary):
		return {}
	var items := {}
	for k in (raw_items as Dictionary).keys():
		var item_id := String(k).strip_edges()
		var count: Variant = (raw_items as Dictionary)[k]
		if item_id.is_empty() or item_id.length() > WS_MAX_ITEM_ID_LEN:
			continue
		if not (count is int or count is float) or int(count) != count or int(count) < 0:
			continue
		items[item_id] = int(count)
	var reserved: Variant = msg.get("reserved", -1)
	if not (reserved is int or reserved is float) or int(reserved) != reserved or int(reserved) < 0:
		return {}
	var clamped_money: Variant = msg.get("clamped_money", false)
	if not (clamped_money is bool):
		return {}
	var stale: Variant = msg.get("stale", false)
	if not (stale is bool):
		return {}
	var raw_clamped: Variant = msg.get("clamped_items", {})
	if not (raw_clamped is Dictionary):
		return {}
	var clamped_items := {}
	for k in (raw_clamped as Dictionary).keys():
		var item_id2 := String(k).strip_edges()
		var need: Variant = (raw_clamped as Dictionary)[k]
		if item_id2.is_empty() or item_id2.length() > WS_MAX_ITEM_ID_LEN:
			continue
		if not (need is int or need is float) or int(need) != need or int(need) < 0:
			continue
		clamped_items[item_id2] = int(need)
	var owned_present := msg.has("owned")
	var owned := {}
	if owned_present:
		var raw_owned: Variant = msg.get("owned", null)
		if not (raw_owned is Dictionary):
			return {}
		owned = _clean_owned_dict(raw_owned)
	# Vong 81: "server_day" la khoa TUY CHON (server moi kem
	# trong moi ack) — co thi phai la int >= 0; khong co thi 0.
	# Sai kieu thi goi ban.
	var server_day := 0
	if msg.has("server_day"):
		var sd: Variant = msg.get("server_day", 0)
		if not (sd is int or sd is float) or int(sd) != sd or int(sd) < 0:
			return {}
		server_day = int(sd)
	return {
		"money": int(money), "items": items,
		"reserved": int(reserved),
		"clamped_money": bool(clamped_money),
		"clamped_items": clamped_items, "stale": bool(stale),
		"owned": owned, "owned_present": owned_present,
		"server_day": server_day,
	}


# Kiểm tra + chuẩn hóa gói shop_buy_ack server trả (vòng 77):
# req_id int >= 1, ok bool, item_id string (rỗng khi lỗi trước
# khi tra món), price_paid / fame_gained / money / reserved int
# >= 0, reason string. Trả {} khi gói bẩn (bỏ gói, không phát
# signal); thiếu reason thì mặc định "" (server mới luôn gửi).
# Vòng 78: "owned" là khóa TÙY CHỌN (chỉ ack ok của server mới
# kèm) — có thì làm sạch + owned_present=true; không có thì
# owned={} + owned_present=false; có nhưng không phải dict thì
# gói bẩn, trả {}.
static func _clean_shop_buy_ack(msg: Dictionary) -> Dictionary:
	var req_raw: Variant = msg.get("req_id", 0)
	if not (req_raw is int or req_raw is float) or int(req_raw) != req_raw or int(req_raw) < 1:
		return {}
	var ok: Variant = msg.get("ok", null)
	if not (ok is bool):
		return {}
	var item_id := String(msg.get("item_id", "")).strip_edges()
	if item_id.length() > WS_MAX_ITEM_ID_LEN:
		return {}
	var price_paid: Variant = msg.get("price_paid", -1)
	if not (price_paid is int or price_paid is float) or int(price_paid) != price_paid or int(price_paid) < 0:
		return {}
	var fame_gained: Variant = msg.get("fame_gained", -1)
	if not (fame_gained is int or fame_gained is float) or int(fame_gained) != fame_gained or int(fame_gained) < 0:
		return {}
	var money: Variant = msg.get("money", -1)
	if not (money is int or money is float) or int(money) != money or int(money) < 0:
		return {}
	var reserved: Variant = msg.get("reserved", -1)
	if not (reserved is int or reserved is float) or int(reserved) != reserved or int(reserved) < 0:
		return {}
	var owned_present := msg.has("owned")
	var owned := {}
	if owned_present:
		var raw_owned: Variant = msg.get("owned", null)
		if not (raw_owned is Dictionary):
			return {}
		owned = _clean_owned_dict(raw_owned)
	# Vong 80: "discount_applied" / "discount_claimed" la khoa
	# TUY CHON (chi ack cua server moi kem) — co thi phai la int
	# 0..50; khong co thi -1 (server khong noi, Main dung so
	# pending). Co nhung sai kieu thi goi ban, tra {}.
	var discount_applied := -1
	if msg.has("discount_applied"):
		var da: Variant = msg.get("discount_applied", -1)
		if not (da is int or da is float) or int(da) != da or int(da) < 0 or int(da) > 50:
			return {}
		discount_applied = int(da)
	var discount_claimed := -1
	if msg.has("discount_claimed"):
		var dc: Variant = msg.get("discount_claimed", -1)
		if not (dc is int or dc is float) or int(dc) != dc or int(dc) < 0 or int(dc) > 50:
			return {}
		discount_claimed = int(dc)
	# Vong 81: "server_day" la khoa TUY CHON (server moi kem
	# trong moi ack) — co thi phai la int >= 0; khong co thi 0
	# (server cu / chua biet ngay). Sai kieu thi goi ban.
	var server_day := 0
	if msg.has("server_day"):
		var sd: Variant = msg.get("server_day", 0)
		if not (sd is int or sd is float) or int(sd) != sd or int(sd) < 0:
			return {}
		server_day = int(sd)
	return {
		"req_id": int(req_raw), "ok": bool(ok), "item_id": item_id,
		"price_paid": int(price_paid), "fame_gained": int(fame_gained),
		"money": int(money), "reserved": int(reserved),
		"reason": String(msg.get("reason", "")),
		"owned": owned, "owned_present": owned_present,
		"discount_applied": discount_applied,
		"discount_claimed": discount_claimed,
		"server_day": server_day,
	}


# Kiểm tra + chuẩn hóa gói shop_sell_ack server trả (vòng 86):
# req_id int >= 1, ok bool, item_id string (rỗng khi lỗi trước
# khi tra món), price_received / money / reserved int >= 0,
# reason string. Trả {} khi gói bẩn (bỏ gói, không phát
# signal); thiếu reason thì mặc định "" (server mới luôn gửi).
# "owned" là khóa TÙY CHỌN (chỉ ack ok của server mới kèm) — có
# thì làm sạch + owned_present=true; không có thì owned={} +
# owned_present=false; có nhưng không phải dict thì gói bẩn.
# "server_day" TÙY CHỌN int >= 0 (không có thì 0).
static func _clean_shop_sell_ack(msg: Dictionary) -> Dictionary:
	var req_raw: Variant = msg.get("req_id", 0)
	if not (req_raw is int or req_raw is float) or int(req_raw) != req_raw or int(req_raw) < 1:
		return {}
	var ok: Variant = msg.get("ok", null)
	if not (ok is bool):
		return {}
	var item_id := String(msg.get("item_id", "")).strip_edges()
	if item_id.length() > WS_MAX_ITEM_ID_LEN:
		return {}
	var price_received: Variant = msg.get("price_received", -1)
	if not (price_received is int or price_received is float) or int(price_received) != price_received or int(price_received) < 0:
		return {}
	var money: Variant = msg.get("money", -1)
	if not (money is int or money is float) or int(money) != money or int(money) < 0:
		return {}
	var reserved: Variant = msg.get("reserved", -1)
	if not (reserved is int or reserved is float) or int(reserved) != reserved or int(reserved) < 0:
		return {}
	var owned_present := msg.has("owned")
	var owned := {}
	if owned_present:
		var raw_owned: Variant = msg.get("owned", null)
		if not (raw_owned is Dictionary):
			return {}
		owned = _clean_owned_dict(raw_owned)
	var server_day := 0
	if msg.has("server_day"):
		var sd: Variant = msg.get("server_day", 0)
		if not (sd is int or sd is float) or int(sd) != sd or int(sd) < 0:
			return {}
		server_day = int(sd)
	return {
		"req_id": int(req_raw), "ok": bool(ok), "item_id": item_id,
		"price_received": int(price_received),
		"money": int(money), "reserved": int(reserved),
		"reason": String(msg.get("reason", "")),
		"owned": owned, "owned_present": owned_present,
		"server_day": server_day,
	}


# Kiểm tra + chuẩn hóa gói stall_hold_sync_ack server trả (vòng 80):
# req_id int >= 1, ok bool, stall_id string (rỗng khi lỗi trước
# khi tra sạp), start_day / until_day int >= 0, discount_percent
# int 0..50, holding_stall_id string, reason string. Trả {} khi
# gói bẩn (bỏ gói, không phát signal); thiếu reason thì mặc định
# "" (server mới luôn gửi).
static func _clean_stall_hold_sync_ack(msg: Dictionary) -> Dictionary:
	var req_raw: Variant = msg.get("req_id", 0)
	if not (req_raw is int or req_raw is float) or int(req_raw) != req_raw or int(req_raw) < 1:
		return {}
	var ok: Variant = msg.get("ok", null)
	if not (ok is bool):
		return {}
	var stall_id := String(msg.get("stall_id", "")).strip_edges()
	if stall_id.length() > WS_MAX_ITEM_ID_LEN:
		return {}
	var start_day: Variant = msg.get("start_day", -1)
	if not (start_day is int or start_day is float) or int(start_day) != start_day or int(start_day) < 0:
		return {}
	var until_day: Variant = msg.get("until_day", -1)
	if not (until_day is int or until_day is float) or int(until_day) != until_day or int(until_day) < 0:
		return {}
	var discount: Variant = msg.get("discount_percent", -1)
	if not (discount is int or discount is float) or int(discount) != discount or int(discount) < 0 or int(discount) > 50:
		return {}
	var holding := String(msg.get("holding_stall_id", ""))
	if holding.length() > WS_MAX_ITEM_ID_LEN:
		return {}
	# Vong 81: "server_day" la khoa TUY CHON (server moi kem
	# trong moi ack) — co thi phai la int >= 0; khong co thi 0.
	# Sai kieu thi goi ban.
	var server_day := 0
	if msg.has("server_day"):
		var sd: Variant = msg.get("server_day", 0)
		if not (sd is int or sd is float) or int(sd) != sd or int(sd) < 0:
			return {}
		server_day = int(sd)
	return {
		"req_id": int(req_raw), "ok": bool(ok), "stall_id": stall_id,
		"start_day": int(start_day), "until_day": int(until_day),
		"discount_percent": int(discount), "holding_stall_id": holding,
		"reason": String(msg.get("reason", "")),
		"server_day": server_day,
	}


# Dat lai baseline sync theo trang thai local HIEN TAI sau khi ap
# 1 quyet toan (vong 76): server da doi ledger theo cung quyet
# toan do nen lan sync ke se gui base_money = so sau quyet toan
# (khong bi danh stale oan nhu khi baseline con giu so truoc
# quyet toan — vd thang trade nhan them 1 trieu o ledger, baseline
# van 2 trieu thi sync ke gui base 2 trieu se stale). Chi goi khi
# ap thanh cong (applied=true); ap tung phan (thieu tien/mon o
# local) thi baseline co the lech ledger — lan sync ke stale, ack
# ve roi Main ap lai so server (dung vong khoi phuc da thiet ke).
# Khong lam gi khi chua noi tui/vi.
func _rebaseline_ledger_after_settlement() -> void:
	if trade_economy == null or trade_inventory == null:
		return
	_ws_ledger_last_money = maxi(int(trade_economy.money), 0)
	_ws_ledger_last_items = _ledger_items_snapshot_from(trade_inventory)
	_ws_ledger_last_owned = _owned_snapshot_from(trade_economy)
	_ws_ledger_last_sync_ms = _now_ms()


# Xin ngay server hien tai (vong 81 — goi sau khi (re)connect
# hoac khi can biet con bao lau thi sang ngay; server tra
# day_sync_ack, xu ly o _handle_ws_message).
# Tra {ok:true} khi da gui; {ok:false, reason} khi chua noi /
# gui that bai.
func send_ws_day_sync() -> Dictionary:
	if not ws_connected or ws_peer == null:
		return {"ok": false, "reason": "chua-ket-noi-ws"}
	var err: Error = ws_peer.put_packet(JSON.stringify({"type": "day_sync"}).to_utf8_buffer())
	if err != OK:
		return {"ok": false, "reason": "ws-gui-that-bai", "error": err}
	return {"ok": true}


# Đồng bộ ví + túi hiện tại lên sổ cái server (vòng 72 — gói
# ledger_sync; vòng 76: gửi kèm base_money + kẹp tiền gửi đi;
# vòng 78: gửi kèm owned chụp từ economy.owned để server hợp
# nhất rồi trả lại làm chuẩn).
# Phải đã nối WS + đã nối túi/ví (trade_inventory /
# trade_economy). Gửi xong thì cập nhật mốc đã sync (để
# _maybe_auto_sync_ledger khỏi gửi trùng). Không throw — luôn trả
# Dictionary.
func send_ws_ledger_sync() -> Dictionary:
	if not ws_connected or ws_peer == null:
		return {"ok": false, "reason": "chua-ket-noi-ws"}
	if trade_economy == null or trade_inventory == null:
		return {"ok": false, "reason": "chua-noi-tui-vi"}
	# Vong 76: khep tien gui di theo reserved (tu chan o client,
	# server kep lai lan nua) + gui base_money la money lan sync
	# truoc de server phat hien sync STALE (lan dau -1).
	var money := maxi(maxi(int(trade_economy.money), 0), ws_reserved_money)
	var items := _ledger_items_snapshot_from(trade_inventory)
	var owned := _owned_snapshot_from(trade_economy)
	# Vong 81: gui kem ngay server (neu da biet — uu tien hon
	# ngay local do Main gan) de server biet client dang o ngay
	# nao; server khong dung so nay de xet han nua (xem
	# PxbServer.server_day), chi de client tu kiem.
	var payload := {"type": "ledger_sync", "money": money, "items": items,
		"base_money": _ws_ledger_last_money, "owned": owned}
	if ws_server_day >= 1:
		payload["game_day"] = ws_server_day
	elif ws_game_day >= 1:
		payload["game_day"] = ws_game_day
	var err: Error = ws_peer.put_packet(JSON.stringify(payload).to_utf8_buffer())
	if err != OK:
		return {"ok": false, "reason": "ws-gui-that-bai", "error": err}
	# Vong 77: ghi tien local TRUOC KHI kep (xem
	# _ws_ledger_sent_money_queue) de ack ve ap theo delta.
	_ws_ledger_sent_money_queue.append(maxi(int(trade_economy.money), 0))
	while _ws_ledger_sent_money_queue.size() > 8:
		_ws_ledger_sent_money_queue.pop_front()
	_ws_ledger_last_money = money
	_ws_ledger_last_items = items
	_ws_ledger_last_owned = owned
	_ws_ledger_last_sync_ms = _now_ms()
	return {"ok": true}


# Mua 1 món ở chợ qua server (vòng 77 — kinh tế
# server-authoritative). Phải đã nối WS. Đồng bộ ledger trước
# khi gửi (giống auction_bid: server validate bằng số mới nhất;
# gói sync + gói mua đi cùng chiều nên server xử lý sync trước)
# — chỉ khi đã nối túi/ví; chưa nối thì vẫn gửi shop_buy (server
# validate bằng ledger của nó, chưa đồng bộ thì trả
# chua-dong-bo-so-cai). discount_percent là % giá sỉ khi đang
# giữ sạp (Main tính từ hold_benefits; 0 = không giảm) — vòng 80
# server KHÔNG tin số này nữa mà tính lại từ sổ holds (xem
# stall_hold_sync), ack trả discount_applied để Main biết số thật;
# game_day là ngày game hiện tại (mặc định lấy ws_server_day khi
# đã biết, nếu không thì ws_game_day do Main gán) — vòng 81 server
# chỉ chấp nhận đúng ngày của nó để xét hold còn hạn không.
# Trả {ok:true, req_id} khi đã gửi (chờ shop_buy_ack, phát qua
# signal ws_shop_buy_acked — tiền/món chỉ áp khi ack ok về);
# {ok:false, reason} khi chưa gửi được (chua-ket-noi-ws /
# thieu-item-id / gia-khong-hop-le / ws-gui-that-bai) — Main rơi
# về mua local như cũ khi gửi thất bại vì chưa nối.
func send_ws_shop_buy(item_id: String, discount_percent: int = 0, game_day: int = -1) -> Dictionary:
	if not ws_connected or ws_peer == null:
		return {"ok": false, "reason": "chua-ket-noi-ws"}
	var iid := item_id.strip_edges()
	if iid.is_empty() or iid.length() > WS_MAX_ITEM_ID_LEN:
		return {"ok": false, "reason": "thieu-item-id"}
	if discount_percent < 0 or discount_percent > 50:
		return {"ok": false, "reason": "gia-khong-hop-le"}
	# Đồng bộ ledger trước để server validate bằng số mới nhất
	# (chỉ khi đã nối túi/ví; chưa nối thì bỏ qua, server sẽ
	# trả chua-dong-bo-so-cai nếu chưa có entry).
	if trade_economy != null and trade_inventory != null:
		send_ws_ledger_sync()
	ws_shop_req_id += 1
	var req_id := ws_shop_req_id
	_ws_shop_pending[req_id] = {"item_id": iid, "discount_percent": discount_percent}
	var payload := {"type": "shop_buy", "item_id": iid,
		"discount_percent": discount_percent, "req_id": req_id}
	# Vong 81: ngay server (neu da biet) thang ngay truyen vao /
	# ngay local — server chi chap nhan dung ngay cua no.
	var day := ws_server_day
	if day < 1:
		day = game_day
	if day < 1:
		day = ws_game_day
	if day >= 1:
		payload["game_day"] = day
	var err: Error = ws_peer.put_packet(JSON.stringify(payload).to_utf8_buffer())
	if err != OK:
		_ws_shop_pending.erase(req_id)
		return {"ok": false, "reason": "ws-gui-that-bai", "error": err}
	return {"ok": true, "req_id": req_id}


# Bán lại 1 món cho chợ qua server (vòng 86 — đối xứng
# send_ws_shop_buy, nhưng KHÔNG có discount: bán lại luôn nhận
# 50% giá catalog do server tính, không giảm giá sỉ). Gửi kèm
# game_day như shop_buy (vòng 81 server chỉ chấp nhận đúng ngày
# của nó). Đồng bộ ledger trước để server validate bằng số mới
# nhất (chỉ khi đã nối túi/ví).
# Trả {ok:true, req_id} khi đã gửi (chờ shop_sell_ack, phát qua
# signal ws_shop_sell_acked — tiền/món chỉ áp khi ack ok về);
# {ok:false, reason} khi chưa gửi được (chua-ket-noi-ws /
# thieu-item-id / ws-gui-that-bai) — Main rơi về bán local như cũ
# khi gửi thất bại vì chưa nối.
func send_ws_shop_sell(item_id: String, game_day: int = -1) -> Dictionary:
	if not ws_connected or ws_peer == null:
		return {"ok": false, "reason": "chua-ket-noi-ws"}
	var iid := item_id.strip_edges()
	if iid.is_empty() or iid.length() > WS_MAX_ITEM_ID_LEN:
		return {"ok": false, "reason": "thieu-item-id"}
	if trade_economy != null and trade_inventory != null:
		send_ws_ledger_sync()
	ws_shop_sell_req_id += 1
	var req_id := ws_shop_sell_req_id
	_ws_shop_sell_pending[req_id] = {"item_id": iid}
	var payload := {"type": "shop_sell", "item_id": iid,
		"req_id": req_id}
	var day := ws_server_day
	if day < 1:
		day = game_day
	if day < 1:
		day = ws_game_day
	if day >= 1:
		payload["game_day"] = day
	var err: Error = ws_peer.put_packet(JSON.stringify(payload).to_utf8_buffer())
	if err != OK:
		_ws_shop_sell_pending.erase(req_id)
		return {"ok": false, "reason": "ws-gui-that-bai", "error": err}
	return {"ok": true, "req_id": req_id}


# Đồng bộ giữ sạp lên server (vòng 80 — Main gọi sau khi thắng
# trận tranh sạp, hoặc gửi lại khi (re)connect). Phải đã nối WS.
# Client tự chặn ngày sai (start < 1, until <= start, giữ quá 7
# ngày — khớp PxbMarketBattle.HOLD_DAYS); server validate lại
# toàn bộ + 1 người tối đa 1 sạp rồi mới ghi sổ. game_day mặc
# định lấy ws_server_day khi đã biết, nếu không thì ws_game_day do Main gán (vòng 81).
# Trả {ok:true, req_id} khi đã gửi (chờ stall_hold_sync_ack,
# phát qua signal ws_stall_hold_synced); {ok:false, reason} khi
# chưa gửi được (chua-ket-noi-ws / thieu-sap-id /
# ngay-giu-sap-sai / chua-biet-ngay-game / ws-gui-that-bai).
func send_ws_stall_hold_sync(stall_id: String, start_day: int, until_day: int, game_day: int = -1) -> Dictionary:
	if not ws_connected or ws_peer == null:
		return {"ok": false, "reason": "chua-ket-noi-ws"}
	var sid := stall_id.strip_edges()
	if sid.is_empty() or sid.length() > WS_MAX_ITEM_ID_LEN:
		return {"ok": false, "reason": "thieu-sap-id"}
	if start_day < 1 or until_day <= start_day or until_day - start_day > PxbMarketBattle.HOLD_DAYS:
		return {"ok": false, "reason": "ngay-giu-sap-sai"}
	# Vong 81: ngay server (neu da biet) thang ngay truyen vao /
	# ngay local — server chi chap nhan dung ngay cua no.
	var day := ws_server_day
	if day < 1:
		day = game_day
	if day < 1:
		day = ws_game_day
	if day < 1:
		return {"ok": false, "reason": "chua-biet-ngay-game"}
	ws_hold_req_id += 1
	var req_id := ws_hold_req_id
	_ws_hold_pending[req_id] = {"stall_id": sid, "start_day": start_day, "until_day": until_day}
	var err: Error = ws_peer.put_packet(JSON.stringify({
		"type": "stall_hold_sync", "stall_id": sid,
		"start_day": start_day, "until_day": until_day,
		"game_day": day, "req_id": req_id,
	}).to_utf8_buffer())
	if err != OK:
		_ws_hold_pending.erase(req_id)
		return {"ok": false, "reason": "ws-gui-that-bai", "error": err}
	return {"ok": true, "req_id": req_id}


# Tiền còn dùng được = ví trừ tiền đang giữ hộ (vòng 76). Chưa nối
# túi/ví thì -1 (không biết). Main dùng để chặn mua/gửi/học phí
# khi khoản chi chạm vào tiền giữ hộ.
func ws_available_money() -> int:
	if trade_economy == null or trade_inventory == null:
		return -1
	return maxi(maxi(int(trade_economy.money), 0) - ws_reserved_money, 0)


# Tự đồng bộ sổ cái khi ví/túi đổi (gọi mỗi frame từ _process):
# chỉ gửi khi đã nối WS + đã nối túi/ví + bật auto-sync + đã qua
# 500 ms từ lần sync trước + số dư thật sự đổi so với lần sync
# trước. Nhờ đó server luôn có số gần mới nhất để validate đấu
# giá / quyết toán, mà không spam gói mỗi frame.
func _maybe_auto_sync_ledger() -> void:
	if not ws_connected or ws_peer == null or not ws_ledger_auto_sync:
		return
	if trade_economy == null or trade_inventory == null:
		return
	var now := _now_ms()
	if now - _ws_ledger_last_sync_ms < WS_LEDGER_SYNC_DEBOUNCE_MS:
		return
	# Vong 76: so sanh theo so SE GUI (tien da kep theo reserved)
	# chu khong phai so tho trong vi — neu khong, vi local duoi
	# reserved se gui trung moi 500ms mai (gui di da kep, ack ve
	# khong doi baseline tho).
	var money := maxi(maxi(int(trade_economy.money), 0), ws_reserved_money)
	var items := _ledger_items_snapshot_from(trade_inventory)
	# Vong 78: owned doi cung kich hoat auto-sync (vd mua local
	# offline xong moi noi WS — owned chua tung len server).
	var owned := _owned_snapshot_from(trade_economy)
	if money == _ws_ledger_last_money and items == _ws_ledger_last_items \
			and owned == _ws_ledger_last_owned:
		return
	send_ws_ledger_sync()


# Áp 1 phiên đấu giá đã đóng vào túi + ví của MÌNH (G4 bước 12).
# Gọi tự động trong _handle_ws_message khi nhận auction_closed;
# Main/test cũng gọi trực tiếp được để kiểm tra lại.
# - Vai: người bán (seller_player_id == ws_player_id) cho đi món,
#   nhận seller_receives_vnd (giá chốt trừ phí sàn 5%); người thắng
#   (winner_player_id == ws_player_id) trả hammer_price, nhận món.
#   Không phải 1 trong 2 bên thì bỏ (khong-lien-quan).
# - Phiên không ai đấu giá (winner rỗng) thì không áp gì
#   (khong-co-nguoi-thang) — món vẫn ở trong túi người bán.
# - Chống áp trùng: auction_id đã có trong ws_auctions_applied thì
#   trả duplicate=true, không trừ/cộng gì lần 2 (giữ 50 id gần nhất).
# - Chưa nối túi/ví (trade_inventory/trade_economy null) thì trả
#   chua-noi-tui-vi, không ghi id đã áp (nối xong áp lại được).
# - Áp từng phần, ghi rõ phần thiếu thay vì bỏ cả kết quả: người
#   bán không còn món trong túi → missing_item=true (vẫn nhận tiền
#   bán); món thắng trùng đồ không xếp chồng đã có →
#   receive_failed=true; tiền thắng thiếu → trừ tới 0, ghi
#   short_money (ví không âm). seller_receives lấy số server gửi
#   (kiểm 0..hammer, bẩn thì tính lại bằng
#   PxbEconomy.auction_seller_receives). Không throw — luôn trả
#   Dictionary.
# - SỔ CÁI SERVER (vòng 72): khi phiên đóng kèm khối "ledger"
#   hợp lệ thì áp đúng số server đã quyết toán — người thắng trả
#   winner_paid (không phải hammer), người bán nhận
#   seller_received (95% của số THỰC TRẢ — không còn nhận đủ
#   theo hammer khi người thắng trả thiếu), phí lấy theo ledger.
#   Giao dịch bị hủy vì thiếu món (missing_item=true) thì không
#   ai trả/nhận gì: người thắng giữ nguyên ví + không nhận món,
#   người bán giữ nguyên túi + không nhận tiền. Không có khối
#   ledger (server cũ) thì dùng đường cũ (v71).
# - KHE HỞ CÒN LẠI (v72, vòng 76 đóng 1 phần): sổ cái tin số
#   client đồng bộ — sync STALE không ghi đè nữa, tiền/món gửi
#   lên bị kẹp theo reserved + món đã hứa, Main chặn tiêu tiền
#   giữ hộ (xem _reserve_blocked). Còn lại: mua/bán local trong
#   Main vẫn chưa qua server validate — cần kinh tế
#   server-authoritative hoàn toàn (xem PxbServer).
# Trả {applied, role, duplicate, item_id, item_ok, missing_item,
# receive_failed, money_given, money_received, short_money,
# fee_vnd, hammer_price} (+ reason khi chưa áp).
func apply_auction_closed(auction: Dictionary) -> Dictionary:
	var clean := _clean_closed_auction(auction)
	if clean.is_empty():
		return {"applied": false, "reason": "goi-dau-gia-khong-hop-le",
			"duplicate": false, "role": ""}
	var aid := String(clean.get("auction_id", ""))
	var winner := String(clean.get("winner_player_id", ""))
	var hammer := int(clean.get("hammer_price", 0))
	var role := ""
	if String(clean.get("seller_player_id", "")) == ws_player_id and not ws_player_id.is_empty():
		role = "seller"
	elif winner == ws_player_id and not ws_player_id.is_empty():
		role = "winner"
	if role.is_empty():
		return {"applied": false, "reason": "khong-lien-quan",
			"duplicate": false, "role": ""}
	if winner.is_empty():
		return {"applied": false, "reason": "khong-co-nguoi-thang",
			"duplicate": false, "role": role}
	if aid in ws_auctions_applied:
		return {"applied": false, "reason": "da-ap-truoc-do",
			"duplicate": true, "role": role}
	if trade_inventory == null or trade_economy == null:
		return {"applied": false, "reason": "chua-noi-tui-vi",
			"duplicate": false, "role": role}
	var item_id := String(clean.get("item_id", ""))
	var fee := int(clean.get("fee_vnd", 0))
	var receives := int(clean.get("seller_receives_vnd", 0))
	if receives < 0 or receives > hammer:
		receives = PxbEconomy.auction_seller_receives(hammer)
		fee = hammer - receives
	# Vòng 72 (sổ cái): có khối ledger hợp lệ thì áp đúng số server
	# đã quyết toán (người thắng trả winner_paid, người bán nhận
	# seller_received = 95% của số thực trả, phí theo ledger).
	var ledger_block: Dictionary = clean.get("ledger", {})
	var use_ledger := not ledger_block.is_empty()
	if use_ledger:
		fee = int(ledger_block.get("fee_vnd", 0))
		receives = int(ledger_block.get("seller_received", 0))
	var item_ok := true
	var missing_item := false
	var receive_failed := false
	var money_given := 0
	var money_received := 0
	var short_money := 0
	if role == "seller":
		if use_ledger and bool(ledger_block.get("missing_item", false)):
			# Giao dịch bị hủy vì người bán không còn món trong sổ
			# cái server — giữ nguyên túi, không nhận tiền.
			item_ok = false
			missing_item = true
			money_received = 0
		else:
			if trade_inventory.remove(item_id, 1):
				item_ok = true
			else:
				item_ok = false
				missing_item = true
			trade_economy.money = maxi(trade_economy.money, 0) + receives
			money_received = receives
	else:
		if use_ledger and not bool(ledger_block.get("item_transferred", true)):
			# Giao dịch bị hủy (thiếu món ở người bán) — không trả
			# tiền, không nhận món; ghi missing_item để Main/toast
			# báo rõ lý do hủy thay vì báo thiếu tiền.
			item_ok = false
			missing_item = true
			money_given = 0
			short_money = 0
		else:
			var to_pay := hammer
			if use_ledger:
				to_pay = int(ledger_block.get("winner_paid", hammer))
			money_given = mini(maxi(trade_economy.money, 0), to_pay)
			trade_economy.money = maxi(trade_economy.money, 0) - money_given
			# short_money = thieu so voi GIA CHOT (hammer - da
			# tra), khop ledger.short_money khi tra du so server
			# yeu cau — giu ngia goc tu v71 (khong phai thieu so
			# voi winner_paid).
			short_money = hammer - money_given
			if trade_inventory.add(item_id, 1):
				item_ok = true
			else:
				item_ok = false
				receive_failed = true
	ws_auctions_applied.append(aid)
	while ws_auctions_applied.size() > WS_AUCTIONS_MAX:
		ws_auctions_applied.pop_front()
	# Vong 76: ap xong thi dat lai baseline theo so local moi —
	# server cung vua doi ledger theo cung quyet toan do (xem
	# apply_trade_completed — cung ly do).
	_rebaseline_ledger_after_settlement()
	return {
		"applied": true, "role": role, "duplicate": false,
		"item_id": item_id, "item_ok": item_ok,
		"missing_item": missing_item, "receive_failed": receive_failed,
		"money_given": money_given, "money_received": money_received,
		"short_money": short_money,
		"fee_vnd": fee, "hammer_price": hammer,
	}


# Khối đấu giá để hiển thị trong tab Chợ: phiên đang mở + 5 phiên
# đã đóng gần nhất (mới nhất cuối). Tiền viết gọn bằng _fmt_vnd ở
# Main — ở đây in số thô (test bắt được).
func ws_auctions_text() -> String:
	var lines: Array[String] = [
		"Đấu giá online — %s" % ws_status_text(),
	]
	if ws_auctions.is_empty():
		lines.append("(chưa có phiên nào đang mở)")
	else:
		for a in ws_auctions:
			var ad: Dictionary = a
			var bid_text := "chưa ai đấu giá"
			if int(ad.get("current_bid", 0)) > 0:
				bid_text = "giá hiện tại %dđ" % int(ad.get("current_bid", 0))
			lines.append("• %s — khởi điểm %dđ, %s (người bán %s)" % [
				String(ad.get("item_id", "?")),
				int(ad.get("start_price", 0)), bid_text,
				String(ad.get("seller_player_id", "?"))])
	if not ws_auction_log.is_empty():
		lines.append("Đã đóng gần đây:")
		for c in ws_auction_log.slice(maxi(0, ws_auction_log.size() - 5)):
			var cd: Dictionary = c
			if String(cd.get("winner_player_id", "")).is_empty():
				lines.append("• %s — không ai đấu giá" % String(cd.get("item_id", "?")))
			else:
				lines.append("• %s — chốt %dđ (phí %dđ)" % [
					String(cd.get("item_id", "?")),
					int(cd.get("hammer_price", 0)),
					int(cd.get("fee_vnd", 0))])
	return "\n".join(lines)


# Trạng thái chat WS để hiển thị (Cài đặt / Tin nhắn).
func ws_status_text() -> String:
	if ws_connected:
		return "đã nối (%d người online)" % ws_players.size()
	if ws_peer != null:
		return "đang nối…"
	if not ws_last_error.is_empty():
		return "ngoại tuyến (%s)" % ws_last_error
	return "ngoại tuyến"


# Danh sách người online để hiển thị (tối đa 10 tên).
func ws_presence_text() -> String:
	if ws_players.is_empty():
		return "(chưa thấy ai online)"
	var names: Array[String] = []
	for p in ws_players.slice(0, 10):
		names.append(String((p as Dictionary).get("name", "")))
	var extra := ""
	if ws_players.size() > 10:
		extra = " +%d người nữa" % (ws_players.size() - 10)
	return " • ".join(names) + extra


# Khối chat online để hiển thị trong tab Tin nhắn: trạng thái +
# người online + 8 tin gần nhất (mới nhất cuối).
func ws_phone_text() -> String:
	var lines: Array[String] = [
		"Chat online — %s" % ws_status_text(),
		"Đang online: %s" % ws_presence_text(),
	]
	if ws_chat_log.is_empty():
		lines.append("(chưa có tin nhắn nào — nối chat rồi nhắn thử)")
	else:
		for m in ws_chat_log.slice(maxi(0, ws_chat_log.size() - 8)):
			lines.append("%s: %s" % [
				String((m as Dictionary).get("name", "?")),
				String((m as Dictionary).get("text", ""))])
	return "\n".join(lines)


# --- Trade / đấu giá / công ty=guild qua HTTP: server CHƯA có endpoint ---
# Mọi hàm dưới đây LUÔN trả {ok:false, reason:"server-chua-co-endpoint"}.
# KHÔNG bịa endpoint, KHÔNG giả vờ thành công, KHÔNG tự quyết
# tiền/đồ của người khác ở client. Đổi đồ qua WebSocket server Godot
# ĐÃ CÓ (G4 bước 10: send_ws_trade_offer / accept / decline / cancel
# ở trên) và đấu giá qua WebSocket ĐÃ CÓ (G4 bước 12:
# send_ws_auction_create / bid / cancel / request_ws_auction_list ở
# trên) — khi server thêm endpoint HTTP thì thay từng hàm bằng lệnh
# gọi thật (giữ nguyên chữ ký trả về). Công ty vẫn chưa có cả 2 đường.

# Đề nghị đổi đồ với người chơi khác (đổi đồ lấy đồ, không dùng
# tiền — xem PxbEconomy.barter cho đổi đồ offline).
func create_trade_offer(from_player_id: String, to_player_id: String,
		give_item_id: String, receive_item_id: String) -> Dictionary:
	return {"ok": false, "reason": REASON_NO_ENDPOINT}


# Chấp nhận 1 đề nghị đổi đồ (trade_id do server cấp sau này).
func accept_trade(trade_id: String, player_id: String) -> Dictionary:
	return {"ok": false, "reason": REASON_NO_ENDPOINT}


# Từ chối / hủy 1 đề nghị đổi đồ.
func decline_trade(trade_id: String, player_id: String) -> Dictionary:
	return {"ok": false, "reason": REASON_NO_ENDPOINT}


# Xem danh sách đấu giá đang mở (server chưa có endpoint HTTP —
# dùng request_ws_auction_list() qua WebSocket, G4 bước 12).
func list_auctions() -> Dictionary:
	return {"ok": false, "reason": REASON_NO_ENDPOINT}


# Đặt giá đấu giá. Phí sàn 5% (PxbBalance.auction_fee_percent, đã
# chốt) do SERVER tính khi có endpoint — client chỉ trả về
# server-chua-co-endpoint, không tự tính tiền người bán ở đây
# (xem PxbEconomy.auction_seller_receives cho bản offline; bản WS
# dùng send_ws_auction_bid(), G4 bước 12).
func place_bid(auction_id: String, player_id: String, amount_vnd: int) -> Dictionary:
	return {"ok": false, "reason": REASON_NO_ENDPOINT}


# Lập công ty (= guild): cần vốn 500 triệu + giấy phép (số ĐÃ
# CHỐT trong PxbBalance.company_capital_vnd) — nhưng server chưa
# có endpoint nên vẫn trả server-chua-co-endpoint, không tự trừ
# tiền hay tạo công ty ở client.
func create_company(founder_player_id: String, company_name: String) -> Dictionary:
	return {"ok": false, "reason": REASON_NO_ENDPOINT}


# Xin vào công ty (guild).
func join_company(player_id: String, company_id: String) -> Dictionary:
	return {"ok": false, "reason": REASON_NO_ENDPOINT}


# Đóng góp điểm / tiền cho công ty — 0 đóng góp 2 tuần thì bị loại
# (luật GDD Mục 6) do server tính khi có endpoint.
func contribute_company(player_id: String, company_id: String, amount_vnd: int) -> Dictionary:
	return {"ok": false, "reason": REASON_NO_ENDPOINT}


# --- Lưu / tải (dữ liệu thuần, JSON-safe) ---

func data() -> Dictionary:
	return {
		"base_url": base_url,
		"online": online,
		"last_health_check_at": last_health_check_at,
		"last_health_ok": last_health_ok,
		"outbox": outbox.duplicate(true),
		"sent_gift_keys": sent_gift_keys.duplicate(),
		"last_balance": last_balance.duplicate(),
		"last_balance_at": last_balance_at,
		"ws_url": ws_url,
		"ws_player_id": ws_player_id,
		"ws_display_name": ws_display_name,
		"ws_chat_log": ws_chat_log.duplicate(true),
		"ws_trades_completed": ws_trades_completed.duplicate(true),
		"ws_auction_log": ws_auction_log.duplicate(true),
	}


# Khôi phục từ data(); dữ liệu bẩn bị bỏ: base_url rỗng / không
# phải chuỗi → mặc định; mốc thời gian âm / không phải số → 0;
# món outbox thiếu key / thiếu người chơi / số tiền <= 0 / không
# phải số → bỏ; key đã gửi rỗng / trùng / không phải chuỗi → bỏ;
# số dư thiếu player_id / tiền không phải số → tiền về 0, thiếu
# player_id thì bỏ cả số dư. Outbox giữ tối đa 50 món, key đã gửi
# giữ tối đa 200 key (cắt cũ nhất).
func from_data(d: Dictionary) -> void:
	# Vong 93: giu id hien co khi du lieu vao khong mang id hop le
	# (save cu / dict rong) — xoa id o day la mat vi server khi
	# tai save cu; id se duoc khoi phuc / sinh moi o
	# ensure_ws_player_id() luc noi.
	var kept_id := ws_player_id
	if d.is_empty():
		reset_state()
		ws_player_id = kept_id
		return
	var raw_url: Variant = d.get("base_url", DEFAULT_BASE_URL)
	if raw_url is String and not String(raw_url).is_empty():
		var cleaned := String(raw_url)
		while cleaned.ends_with("/") and cleaned.length() > 1:
			cleaned = cleaned.substr(0, cleaned.length() - 1)
		base_url = cleaned
	else:
		base_url = DEFAULT_BASE_URL
	online = bool(d.get("online", false))
	last_health_check_at = _clean_ms(d.get("last_health_check_at", 0))
	last_health_ok = bool(d.get("last_health_ok", false))
	outbox = []
	var raw_outbox: Variant = d.get("outbox", [])
	if raw_outbox is Array:
		for raw_item in raw_outbox:
			if outbox.size() >= OUTBOX_MAX:
				break
			var item := _clean_outbox_item(raw_item)
			if not item.is_empty():
				outbox.append(item)
	sent_gift_keys = []
	var raw_keys: Variant = d.get("sent_gift_keys", [])
	if raw_keys is Array:
		for raw_key in raw_keys:
			if raw_key is String and not String(raw_key).is_empty() \
					and not (String(raw_key) in sent_gift_keys):
				sent_gift_keys.append(String(raw_key))
		while sent_gift_keys.size() > SENT_KEYS_MAX:
			sent_gift_keys.pop_front()
	last_balance = {}
	var raw_balance: Variant = d.get("last_balance", {})
	if raw_balance is Dictionary and not raw_balance.is_empty():
		var pid := String(raw_balance.get("player_id", ""))
		if not pid.is_empty():
			last_balance = {
				"player_id": pid,
				"cash_vnd": _clean_money(raw_balance.get("cash_vnd", 0)),
				"savings_vnd": _clean_money(raw_balance.get("savings_vnd", 0)),
			}
	last_balance_at = _clean_ms(d.get("last_balance_at", 0))
	# WS chat (G4 bước 7): dữ liệu bẩn bị bỏ giống HTTP — URL rỗng
	# → mặc định; id hop le thi dung + dong bo kho ben, id rong /
	# quá dài / save cũ không có trường này → GIỮ id hiện có
	# (Vòng 93 — không xóa id khi tải save cũ); tên rỗng →
	# "Người chơi", dài → cắt 30; tin chat thiếu tên/text hoặc quá
	# 500 ký tự → bỏ; log giữ tối đa 100 tin.
	var raw_ws_url: Variant = d.get("ws_url", DEFAULT_WS_URL)
	ws_url = String(raw_ws_url) if raw_ws_url is String \
		and not String(raw_ws_url).is_empty() else DEFAULT_WS_URL
	var raw_ws_id: Variant = d.get("ws_player_id", "")
	if raw_ws_id is String and _valid_player_id(String(raw_ws_id)):
		ws_player_id = String(raw_ws_id)
		# Id trong save la that: dong bo xuong kho ben ngay de
		# lan noi sau van con, ke ca khi nguoi choi khong luu
		# lai game (Vong 93).
		_save_persisted_player_id()
	else:
		# Save cu khong co truong nay / truong ban (rong / qua
		# dai): GIU id hien co (kept_id) thay vi xoa ve "".
		ws_player_id = kept_id
	var raw_ws_name: Variant = d.get("ws_display_name", "Người chơi")
	ws_display_name = String(raw_ws_name) if raw_ws_name is String \
		and not String(raw_ws_name).is_empty() else "Người chơi"
	if ws_display_name.length() > WS_MAX_NAME_LEN:
		ws_display_name = ws_display_name.substr(0, WS_MAX_NAME_LEN)
	ws_chat_log = []
	var raw_log: Variant = d.get("ws_chat_log", [])
	if raw_log is Array:
		for raw_msg in raw_log:
			if ws_chat_log.size() >= WS_CHAT_LOG_MAX:
				break
			if not (raw_msg is Dictionary):
				continue
			var clean_msg := _clean_chat_message(raw_msg)
			if not clean_msg.is_empty():
				ws_chat_log.append(clean_msg)
	# WS trade (G4 bước 10): giao dịch đã chốt bẩn thì bỏ
	# (thiếu trade_id / thiếu 1 bên / tiền quá 100 tỉ); giữ tối
	# đa 50 món. Đề nghị đang chờ KHÔNG lưu — hết phiên là hết.
	ws_trades_completed = []
	var raw_trades: Variant = d.get("ws_trades_completed", [])
	if raw_trades is Array:
		for raw_trade in raw_trades:
			if ws_trades_completed.size() >= WS_TRADES_MAX:
				break
			if not (raw_trade is Dictionary):
				continue
			var clean_trade := _clean_trade(raw_trade)
			if not clean_trade.is_empty():
				ws_trades_completed.append(clean_trade)
	# WS đấu giá (G4 bước 12): phiên đã đóng bẩn thì bỏ (thiếu
	# auction_id / thiếu người bán / giá ngoài 1.000..100 tỉ /
	# phí vượt giá chốt); giữ tối đa 50 món. Phiên đang mở KHÔNG
	# lưu — hết phiên là hết (vào lại thì xin auction_list).
	ws_auction_log = []
	var raw_auctions: Variant = d.get("ws_auction_log", [])
	if raw_auctions is Array:
		for raw_auction in raw_auctions:
			if ws_auction_log.size() >= WS_AUCTIONS_MAX:
				break
			if not (raw_auction is Dictionary):
				continue
			var clean_auction := _clean_closed_auction(raw_auction)
			if not clean_auction.is_empty():
				ws_auction_log.append(clean_auction)


# Mốc thời gian bẩn → 0 (âm / không phải số).
static func _clean_ms(value: Variant) -> int:
	if value is int or value is float:
		return maxi(0, int(value))
	return 0


# Số tiền bẩn → 0 (không phải số / âm — số dư cache chỉ để hiển thị,
# lần balance_of sau sẽ lấy lại số thật từ server).
static func _clean_money(value: Variant) -> int:
	if value is int or value is float:
		return maxi(0, int(value))
	return 0


# Kiểm tra + chuẩn hóa 1 món outbox; trả {} khi món bẩn (bỏ).
static func _clean_outbox_item(raw_item: Variant) -> Dictionary:
	if not (raw_item is Dictionary):
		return {}
	var key := String(raw_item.get("key", ""))
	var from_id := String(raw_item.get("from_player_id", ""))
	var to_id := String(raw_item.get("to_player_id", ""))
	var amount: Variant = raw_item.get("amount_vnd", 0)
	if key.is_empty() or from_id.is_empty() or to_id.is_empty():
		return {}
	if not (amount is int or amount is float) or int(amount) != amount \
			or int(amount) <= 0:
		return {}
	var day: Variant = raw_item.get("game_day", 1)
	var clean_day := 1
	if day is int or day is float:
		clean_day = maxi(1, int(day))
	return {
		"key": key,
		"from_player_id": from_id,
		"to_player_id": to_id,
		"amount_vnd": int(amount),
		"game_day": clean_day,
		"queued_at": _clean_ms(raw_item.get("queued_at", 0)),
	}


# Reset state hiện tại về mặc định (event/test dùng để bắt đầu lại).
# Ngắt WS trước (nếu đang nối) rồi mới xóa trạng thái.
func reset_state() -> bool:
	disconnect_ws()
	var d := default_data()
	base_url = String(d["base_url"])
	online = bool(d["online"])
	last_health_check_at = int(d["last_health_check_at"])
	last_health_ok = bool(d["last_health_ok"])
	outbox = []
	sent_gift_keys = []
	last_balance = {}
	last_balance_at = int(d["last_balance_at"])
	ws_url = String(d["ws_url"])
	ws_player_id = String(d["ws_player_id"])
	ws_display_name = String(d["ws_display_name"])
	ws_chat_log = []
	ws_last_error = ""
	ws_trade_offers = []
	ws_my_offers = []
	ws_trades_completed = []
	ws_trades_applied = []
	ws_last_trade_error = ""
	ws_auctions = []
	ws_auction_log = []
	ws_auctions_applied = []
	ws_last_auction_error = ""
	_ws_ledger_last_money = -1
	_ws_ledger_last_items = {}
	_ws_ledger_last_owned = {}
	_ws_ledger_last_sync_ms = 0
	# Vong 76: xoa ca so server lam chuan + tien giu ho + dem kep.
	ws_reserved_money = 0
	ws_ledger_authoritative_money = -1
	ws_ledger_authoritative_items = {}
	# Vong 78: xoa ca owned server lam chuan.
	ws_ledger_authoritative_owned = {}
	ws_ledger_clamped_count = 0
	ws_last_ledger_ack = {}
	# Vong 77: xoa ca lan mua o cho dang cho ack + dem req_id.
	_ws_shop_pending = {}
	ws_shop_req_id = 0
	# Vong 86: xoa ca lan ban lai cho cho dang cho ack + dem req_id.
	_ws_shop_sell_pending = {}
	ws_shop_sell_req_id = 0
	# Vong 80: xoa ca lan dong bo giu sap dang cho ack + dem req_id + ack gan nhat.
	_ws_hold_pending = {}
	ws_hold_req_id = 0
	ws_last_hold_ack = {}
	# Vong 81: xoa ca ngay server da biet.
	ws_server_day = 0
	ws_day_ends_in_ms = 0
	# Vong 77: xoa ca hang doi tien local luc gui sync.
	_ws_ledger_sent_money_queue = []
	return true
