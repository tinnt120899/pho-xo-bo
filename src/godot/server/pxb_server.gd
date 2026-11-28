class_name PxbServer
extends Node
## Phố Xô Bồ — PXB_Server (Godot G4, bước 6).
## Dedicated server headless + WebSocket cho bản online thật.
## Quyết Bậc 1 (docs/godot-g4.md §12.5): online dùng Godot headless
## dedicated server thay cho server .NET 8 làm đường chính — web export
## bắt buộc WebSocket (trình duyệt không mở được UDP thô), VM này
## không có dotnet SDK nên server .NET không build/chạy/verify được,
## còn dedicated server chạy + verify được ngay bằng cùng binary 4.7.2.
## Server .NET trong src/server/ giữ lại làm tham chiếu, không xóa.
##
## Giao thức JSON v1 qua WebSocket (mỗi gói là 1 object JSON):
##   Client -> server:
##     {"type":"hello","protocol":1,"player_id":"...","name":"..."}
##       đăng ký presence; server trả welcome + broadcast presence.
##     {"type":"chat","text":"..."}  gửi chat (phải hello trước,
##       text 1..500 ký tự); server broadcast lại cho mọi người.
##     {"type":"bye"}  rời presence (đóng socket cũng rời).
##     {"type":"day_sync"}  xin ngày server hiện tại (vòng 81 —
##       phải hello trước); server trả {"type":"day_sync_ack",
##       "server_day":N,"day_length_ms":N,"day_ends_in_ms":N}.
##     {"type":"trade_offer","to_player_id":"...","give_item_id":"...",
##       "give_money":N,"want_item_id":"...","want_money":N}
##       đề nghị đổi đồ (phải hello trước; tối đa 1 đề nghị đang
##       chờ cho mỗi người gửi; ít nhất 1 món/tiền cho + 1 món/tiền
##       muốn; tiền 0..100 tỉ). Server tạo trade_id, gửi
##       trade_offer cho người nhận + trade_offered cho người gửi.
##     {"type":"trade_accept","trade_id":"..."}  người NHẬN chấp
##       nhận → server quyết toán từ sổ cái (_settle_trade, vòng
##       73) rồi gửi trade_completed cho cả 2 bên (giao dịch
##       chốt, vào trade_log). Chỉ người nhận mới chấp nhận được.
##       Bên nào đã đồng bộ mà không đủ tiền/món lúc chốt thì
##       giao dịch bị HỦY (khối "ledger" kèm theo ghi voided +
##       lý do, không bên nào mất gì); chưa đồng bộ thì coi như
##       đủ, client tự áp như cũ.
##     {"type":"trade_decline","trade_id":"..."}  người nhận từ
##       chối → server báo trade_declined cho người gửi.
##     {"type":"trade_cancel","trade_id":"..."}  người gửi hủy →
##       server báo trade_cancelled cho người nhận.
##     {"type":"auction_create","item_id":"...","start_price":N,
##       "duration_s":N}  mở đấu giá 1 món (phải hello trước; tối
##       đa 1 phiên đang mở cho mỗi người bán; giá khởi điểm
##       1.000..100 tỉ; thời gian 30..3600 giây). Server tạo
##       auction_id, broadcast auction_created cho mọi người.
##     {"type":"auction_bid","auction_id":"...","amount":N}  đặt giá
##       (phải hello trước; giá đầu tiên >= giá khởi điểm, các giá
##       sau >= giá hiện tại + 1.000đ; người bán không được đấu
##       giá của mình). Server broadcast auction_bid cho mọi người.
##     {"type":"auction_cancel","auction_id":"..."}  người bán hủy
##       phiên CHƯA có ai đấu giá → broadcast auction_cancelled.
##     {"type":"auction_list"}  xin danh sách phiên đang mở;
##       server trả auction_list chỉ cho người xin.
##     {"type":"ledger_sync","money":N,"items":{item_id:count}
##       [,"base_money":N][,"owned":{item_id:count}]}  đồng bộ số
##       dư (ví + túi) lên sổ cái server — vòng 72 (phải hello
##       trước; money int >= 0; items tối đa 512 món, mỗi món
##       count int >= 0). Vòng 76 thêm "base_money" (int, -1 =
##       chưa từng nhận ack): money lúc sync lần trước — server
##       so với ledger hiện tại, khác thì sync STALE (đã có
##       quyết toán chen giữa) nên KHÔNG ghi đè, chỉ trả ack với
##       số server. Vòng 78 thêm "owned" (dict {item_id: count},
##       món phải có trong bảng giá PxbEconomy, count 0..99):
##       tài sản đã mua ở chợ (nhà/xe/điện thoại/quần áo, không
##       nằm trong túi slice) — server HỢP NHẤT theo max(server,
##       client) từng món (client có thể mua local offline trước
##       khi sync lần đầu; server không bao giờ quên món nó đã
##       validate qua shop_buy) rồi trả lại trong ack; client
##       lấy ack.owned làm chuẩn. Server giữ lại để validate
##       đấu giá (đủ tiền mới cho đặt giá, đủ món mới cho mở
##       phiên) + quyết toán khi đóng phiên (xem
##       _settle_auction); vòng 73 dùng thêm cho trade: đủ tiền/
##       món mới cho gửi đề nghị + quyết toán khi chấp nhận (xem
##       _settle_trade — đủ mới chuyển, thiếu thì HỦY giao dịch).
##       Gói sai money thì bỏ cả gói (đếm dropped_packets); món
##       sai thì bỏ món đó, giữ phần đúng. Đồng bộ lại thay thế
##       money/items nhưng GIỮ reserved (tiền đang giữ hộ cho
##       giá cao nhất — client không tự xóa khoản giữ hộ bằng
##       1 lần sync) — vòng 76 kẹp thêm: money không xuống dưới
##       reserved, món đã hứa bán/cho (phiên đấu giá đang mở /
##       trade đang chờ) không xuống dưới số phiên/trade đã hứa
##       (cộng dồn nếu nhiều phiên/trade cùng món).
##     Server trả {"type":"ledger_sync_ack","money":N,
##       "items":{...},"reserved":N,"clamped_money":bool,
##       "clamped_items":{item_id: so toi thieu},"stale":bool,
##       "owned":{item_id:count},"server_day":N}  cho đúng peer
##       đã sync (vòng 81: ack kèm ngày server hiện tại).
##       (vòng 76): money/items/reserved là số server sau khi
##       ghi (stale thì là số server hiện tại, không ghi gì);
##       clamped_money = tiền gửi lên đã bị kẹp lên reserved;
##       clamped_items = món đã bị kẹp lên số tối thiểu; stale
##       = true khi base_money khác ledger (sync bằng số local
##       cũ sau khi đã quyết toán); owned (vòng 78) = tài sản
##       đã mua server đang giữ cho người này (sau khi hợp nhất
##       với owned client gửi lên; stale thì là owned server
##       hiện tại).
##     {"type":"shop_buy","item_id":"...","discount_percent":N,
##       "req_id":N[,"game_day":N]}  mua 1 món ở chợ qua server
##       (vòng 77 — phải hello trước; req_id int >= 1 để client
##       khớp ack với lần mua đang chờ; discount_percent 0..50, là
##       % giá sỉ client KHAI khi đang giữ sạp, KHÔNG áp cho
##       "phong-tro" — giống PxbEconomy.buy). Server validate bằng
##       ĐÚNG bảng giá PxbEconomy.get_item (không tin giá client
##       gửi — client không gửi giá), kiểm tra ledger đã đồng bộ
##       chưa + tiền khả dụng (money - reserved) đủ giá, rồi TRỪ
##       TIỀN trong ledger + ghi shop_log + CỘNG MÓN VÀO owned
##       trong ledger (vòng 78 — trước đây owned chỉ có ở client
##       local); server trả ack kèm "owned" đầy đủ sau khi mua để
##       client lấy làm chuẩn. Vòng 80: discount KHÔNG tin số
##       client khai nữa — server tính lại từ sổ holds (xem
##       stall_hold_sync): chỉ 10% khi đang giữ sạp còn hạn ở
##       ngày server hiện tại, 0% khi không giữ / hết hạn /
##       phong-tro; ack kèm "discount_applied" (số server đã áp) +
##       "discount_claimed" (số client khai) để client biết bị sửa.
##       Vòng 81: "game_day" kèm theo PHẢI bằng ngày server —
##       khác thì ack ok=false, reason "ngay-server-khong-khop",
##       không trừ tiền; thiếu thì dùng ngày server. Mọi ack mua
##       đều kèm "server_day" để client đồng bộ ngày.
##       Server trả
##       {"type":"shop_buy_ack","req_id":N,"ok":bool,
##       "item_id":"...","price_paid":N,"fame_gained":N,
##       "money":N,"reserved":N,"owned":{item_id:count},
##       "discount_applied":N,"discount_claimed":N,
##       "server_day":N,"reason":"..."} về đúng peer:
##       ok=true thì money là số server sau khi trừ; ok=false
##       thì money là số server hiện tại, không trừ gì, reason
##       là "chua-hello" / "thieu-item-id" / "gia-khong-hop-le"
##       / "khong-co-mon" / "chua-dong-bo-so-cai" /
##       "khong-du-tien" / "ngay-server-khong-khop" (vòng 81).
##     {"type":"shop_sell","item_id":"...","req_id":N[,"game_day":N]}
##       bán lại 1 món cho chợ qua server (vòng 86 — đối xứng
##       shop_buy; phải hello trước; req_id int >= 1). Server
##       validate bằng bảng giá PxbEconomy.get_item, kiểm tra
##       ledger đã đồng bộ + đang sở hữu món (owned >= 1) +
##       không phải "phong-tro" (thuê tháng, không bán lại
##       được); giá bán lại = PxbEconomy.shop_sellback_price
##       (50% giá catalog, PROVISIONAL — server tính, không tin
##       số client; không giảm giá sỉ khi bán). TRỪ 1 MÓN khỏi
##       owned + CỘNG tiền vào ledger + ghi shop_log kind "sell"
##       (price_received) rồi trả ack kèm owned đầy đủ. Không
##       Danh vọng khi bán. Vòng 81: "game_day" kèm theo PHẢI
##       bằng ngày server, thiếu thì dùng ngày server. Server trả
##       {"type":"shop_sell_ack","req_id":N,"ok":bool,
##       "item_id":"...","price_received":N,"money":N,
##       "reserved":N,"owned":{item_id:count},"server_day":N,
##       "reason":"..."} về đúng peer: ok=true thì money là số
##       server sau khi cộng; ok=false thì money là số server
##       hiện tại, không đổi gì, reason là "chua-hello" /
##       "thieu-item-id" / "khong-co-mon" / "khong-ban-duoc" /
##       "khong-so-huu" / "chua-dong-bo-so-cai" /
##       "ngay-server-khong-khop".
##     {"type":"stall_hold_sync","stall_id":"...","start_day":N,
##       "until_day":N[,"game_day":N],"req_id":N}  đồng bộ giữ sạp
##       lên server (vòng 80 — client gửi sau khi thắng trận
##       tranh sạp, hoặc gửi lại khi (re)connect; phải hello
##       trước; req_id int >= 1; vòng 81: "game_day" là TÙY CHỌN
##       — kèm thì phải bằng ngày server, khác thì ack ok=false
##       reason "ngay-server-khong-khop"; thiếu thì dùng ngày
##       server). Server validate thật rồi mới ghi
##       sổ holds: start_day >= 1, until_day > start_day, giữ tối
##       đa 7 ngày, không giữ từ tương lai, chưa hết hạn lúc đồng
##       bộ, 1 người tối đa 1 sạp (đang giữ sạp khác còn hạn thì
##       từ chối "dang-giu-sap-khac"). Server trả
##       {"type":"stall_hold_sync_ack","req_id":N,"ok":bool,
##       "stall_id":"...","start_day":N,"until_day":N,
##       "discount_percent":N,"holding_stall_id":"...",
##       "reason":"...","server_day":N}: ok=true thì discount_percent = 10
##       (giá sỉ áp dụng khi mua); ok=false thì reason là
##       "chua-hello" / "thieu-sap-id" / "ngay-giu-sap-sai" /
##       "het-han-giu-sap" / "dang-giu-sap-khac".
##   Server -> client:
##     {"type":"auction_created" | "auction_bid",
##       "auction_id":"...","seller_player_id":"...",
##       "item_id":"...","start_price":N,"current_bid":N,
##       "current_bidder_player_id":"...","ends_at_ms":N,
##       "created_at_ms":N}
##     {"type":"auction_outbid","auction_id":"...","seller_player_id":"...",
##       "item_id":"...","start_price":N,"current_bid":N,
##       "current_bidder_player_id":"...","ends_at_ms":N,
##       "created_at_ms":N,"old_bid":N,"old_bidder_player_id":"...",
##       "new_bid":N,"new_bidder_player_id":"..."}  (vòng 102 — chỉ
##       gửi cho người vừa bị vượt giá: online thì gửi ngay,
##       offline thì xếp hàng đợi _outbid_pending, gửi lại lúc
##       hello sau; broadcast auction_bid không tới được người
##       offline nên không thay được tin này).
##     {"type":"auction_cancelled","auction_id":"...","reason":"..."}
##     {"type":"auction_closed","auction_id":"...","seller_player_id":"...",
##       "item_id":"...","winner_player_id":"...","hammer_price":N,
##       "fee_vnd":N,"seller_receives_vnd":N,"closed_at_ms":N,
##       "ledger":{...}}  (vòng 72 — xem _settle_auction:
##       winner_paid / seller_received / fee_vnd / short_money /
##       missing_item / item_transferred; fee + seller_receives
##       ở cấp trên = số đã quyết toán, không còn là số theo
##       hammer khi người thắng trả thiếu; không ai đấu giá thì
##       winner rỗng, hammer = fee = seller_receives = 0).
##     {"type":"auction_list","auctions":[...phiên đang mở...]}
##     {"type":"auction_error","reason":"..."}  lệnh đấu giá sai
##       luật — KHÔNG ngắt kết nối (giống trade_error).
##   Server -> client:
##     {"type":"welcome","peer_id":N,"protocol":1,"players":[...],
##       "server_day":N,"day_length_ms":N}  ngay server hien tai +
##       do dai 1 ngay (vong 81 — client lay lam chuan, xem day_sync).
##     {"type":"presence","players":[{"peer_id","player_id","name"}]}
##     {"type":"chat","from_peer":N,"player_id":"...","name":"...",
##       "text":"...","at_ms":N}
##     {"type":"error","reason":"..."}  hello sai (protocol / thiếu
##       player_id / server đầy) — không đăng ký.
##     {"type":"trade_offer" | "trade_offered" | "trade_completed",
##       "trade_id":"...","from_player_id":"...","to_player_id":"...",
##       "give_item_id":"...","give_money":N,"want_item_id":"...",
##       "want_money":N,"created_at_ms":N[, "completed_at_ms":N]
##       [, "ledger":{...}]}
##       khối "ledger" chỉ có ở trade_completed khi ít nhất 1
##       bên đã đồng bộ (vòng 73 — xem _settle_trade:
##       voided / reason / sender_paid / receiver_paid /
##       sender_item_transferred / receiver_item_transferred /
##       sender_money_short / receiver_money_short /
##       sender_missing_item / receiver_missing_item).
##     {"type":"trade_declined" | "trade_cancelled",
##       "trade_id":"...","reason":"..."}
##     {"type":"trade_error","reason":"..."}  lệnh trade sai
##       (sai người / sai id / sai luật) — KHÔNG ngắt kết nối,
##       khác gói "error" của hello.
##     Lệnh đấu giá sai luật cũng trả auction_error + đếm
##       dropped_packets (giống trade).
## Gói sai JSON / không phải object / type lạ / chat khi chưa hello /
## text rỗng hoặc quá dài đều bị bỏ lặng (đếm dropped_packets),
## server không crash, không broadcast — client độc không phá được
## phòng của người khác. Lệnh trade sai luật cũng bị bỏ + trả
## trade_error cho người gửi (đếm dropped_packets).
##
## Chạy thật:  godot --headless --path src/godot
##               -s res://server/server_main.gd -- --port 8765
## (server_main.gd tự tạo node này; xem file đó). Trong game, node
## này chỉ chạy ở tiến trình server — client Godot KHÔNG tạo nó.
##
## PROVISIONAL — chưa chốt, đổi thì sửa ở đây + docs/godot-g4.md:
##   - Cổng mặc định 8765; tối đa 64 người chơi cùng lúc.
##   - Tên hiển thị tối đa 30 ký tự (dài hơn thì cắt); player_id
##     tối đa 64 ký tự; chat tối đa 500 ký tự.
##   - Chat log giữ 100 tin gần nhất (chỉ để quan sát/log, chưa
##     có endpoint đọc lại lịch sử cho client mới vào).
##   - Ngày game do server làm chủ (vòng 81): 1 ngày = 30 phút
##     thật (đã chốt trong GDD, khớp PxbBalance.GAME_DAY_MINUTES);
##     server bắt đầu ngày 1 lúc mở cổng, ngày chỉ tăng theo đồng
##     hồ thật của server. Persistence (vòng 82): ngày + ledger +
##     holds lưu file JSON, restart thì nạp lại (không về 1 /
##     không mất tiền); trades / auctions đang mở / chat vẫn chỉ
##     nằm trong RAM — restart thì mất.
##   - Trade: tiền bù tối đa 100 tỉ / đề nghị (= giá penthouse/
##     đảo, mức tiền lớn nhất trong GDD); mã món đồ tối đa 64 ký
##     tự; tối đa 1 đề nghị đang chờ cho mỗi người gửi; log giao
##     dịch đã chốt giữ 100 món gần nhất.
##   - CHƯA có auth: player_id do client tự khai, chỉ dùng nội bộ
##     cho tới khi server có auth. Server KHÔNG quyết tiền/đồ của
##     ai ở đường trade — chat + presence chỉ là relay. Trade
##     (vòng 73): server validate + quyết toán từ sổ cái khi chấp
##     nhận (_settle_trade): bên nào đã đồng bộ thì trừ/chuyển
##     tiền/đồ thật trong ledger, đủ mới chuyển cả 2 chiều, thiếu
##     thì HỦY giao dịch (không bên nào mất gì); bên chưa đồng bộ
##     thì coi như đủ, client tự áp như cũ (v70). Client áp đúng
##     số trong khối "ledger" của trade_completed (xem
##     PxbOnline.apply_trade_completed).
##   - Đấu giá (vòng 72): server CÓ sổ cái — client đồng bộ ví +
##     túi qua ledger_sync, server giữ hộ tiền giá cao nhất
##     (reserved), validate đủ tiền/món rồi mới cho đặt giá / mở
##     phiên, và quyết toán khi đóng phiên (_settle_auction):
##     người thắng trả theo số đã đồng bộ, người bán nhận 95%
##     của số THỰC TRẢ (96% khi đang giữ sạp còn hạn — vòng 80;
##     không còn nhận đủ theo hammer khi người thắng trả thiếu);
##     thiếu món ở người bán thì hủy giao dịch,
##     hoàn tiền người thắng. Client áp đúng số trong khối
##     "ledger" của auction_closed (xem
##     PxbOnline.apply_auction_closed). Sổ cái tin số client
##     đồng bộ (chưa có auth, chưa server-authoritative hoàn
##     toàn). Vòng 76 đóng 2 khe hở của vòng 72/73: sync STALE
##     (base_money khác ledger — client mất kết nối đúng lúc
##     chốt phiên rồi sync lại bằng số local cũ) không ghi đè
##     nữa, chỉ trả ack với số server; tiền/món gửi lên bị kẹp
##     theo reserved + món đã hứa (phiên/trade đang mở) nên
##     client không xóa được tiền giữ hộ / món đã hứa bằng 1 lần
##     sync; client chặn tiêu tiền giữ hộ ở Main (xem
##     PxbOnline.ws_reserved_money + Main._reserve_blocked).
##     KHE HỞ CÒN LẠI (vòng 76): mua/bán local trong Main vẫn
##     chưa qua server validate — server chỉ chặn ghi đè ledger
##     sai + chặn tiêu tiền giữ hộ qua sync; mua bằng shop local
##     vẫn là việc sau (cần kinh tế server-authoritative hoàn
##     toàn). Trong 1 lần chấp nhận trade thì quyết toán là
##     nguyên tử — không còn chuyện 1 bên nhận đủ trong khi bên
##     kia trả thiếu.

# Cổng mặc định — PROVISIONAL.
const DEFAULT_PORT := 8765
# Phiên bản giao thức — client gửi khác số này thì bị từ chối.
const PROTOCOL_VERSION := 1
# Tối đa 64 người chơi cùng lúc — PROVISIONAL.
const MAX_PLAYERS := 64
# Tên hiển thị tối đa 30 ký tự — PROVISIONAL.
const MAX_NAME_LEN := 30
# player_id tối đa 64 ký tự — PROVISIONAL.
const MAX_PLAYER_ID_LEN := 64
# Chat tối đa 500 ký tự — PROVISIONAL.
const MAX_CHAT_LEN := 500
# Chat log giữ 100 tin gần nhất — PROVISIONAL.
const CHAT_LOG_MAX := 100
# Tiền bù tối đa trong 1 đề nghị đổi đồ — PROVISIONAL (= giá
# penthouse/đảo, mức tiền lớn nhất trong GDD).
const MAX_TRADE_MONEY_VND := 100000000000
# Mã món đồ tối đa 64 ký tự — khớp player_id.
const MAX_ITEM_ID_LEN := 64
# Log giao dịch đã chốt giữ 100 món gần nhất (chỉ để quan sát).
const TRADE_LOG_MAX := 100
# Phí sàn đấu giá 5% (đã chốt — khớp PxbBalance.AUCTION_FEE_PERCENT
# + PxbEconomy.auction_seller_receives: người bán nhận hammer × 95
# / 100, cắt phần lẻ theo phép chia nguyên).
const AUCTION_FEE_PERCENT := 5
# Giữ sạp — vòng 80: luật KHỚP PxbMarketBattle (HOLD_DAYS 7,
# WHOLESALE_DISCOUNT_PERCENT 10, STALL_TAX_CUT_PERCENT 20) để
# server tự tính discount giá sỉ + phí đấu giá từ sổ holds, không
# tin số client khai. Giữ ở đây (mirror) thay vì dùng thẳng
# constant của MarketBattle để server vẫn chạy độc lập.
const HOLD_DAYS_MAX := 7
const WHOLESALE_DISCOUNT_PERCENT := 10
const STALL_TAX_CUT_PERCENT := 20
# Ngay game do server lam chu (vong 81): 1 ngay game = 30 phut
# that (khop PxbBalance.GAME_DAY_MINUTES, da chot trong GDD —
# khong PROVISIONAL). Server bat dau ngay 1 luc mo cong; ngay chi
# tang theo dong ho that cua server, client bao ngay nao khac thi
# bi tu choi o shop_buy / stall_hold_sync (ly do
# "ngay-server-khong-khop").
const DAY_LENGTH_MS := 1800000
# Persistence (vong 82): ngay + ledger + holds luu xuong file JSON
# (mac dinh user://pxb_server_state.json) — restart server thi
# ngay/ledger/holds duoc nap lai, khong ve 1 / khong mat tien.
# Vong 83: them trades dang cho + auctions dang mo + chat_log
# (100 tin gan nhat) — restart van giu de nghi / phien / lich su
# chat; peer_id trong trade/auction la so socket (doi sau moi lan
# noi lai) nen luc nap dat ve -1 roi REBIND theo player_id khi
# nguoi choi hello lai (xem _rebind_after_hello) — trade moi chap
# nhan/duoc tu choi/huy duoc, auction moi tiep tuc dau gia/huy duoc.
# CHI BAT KHI state_file_path duoc dat tuong minh (opt-in):
# server_main LUON dat (mac dinh hoac --state-file); test nao
# can persistence thi dat duong dan rieng (vd /tmp). Server
# chay trong test ma khong dat thi khoi dong moi sach (ngay 1,
# so trong) — tranh 1 test luu state roi test sau nap nham
# (hoi quy 17:45: trade-ledger 92/100 + trade 33/34 do nap
# ledger cua test truoc tu user://). Luu khi stop_server + tu
# dong moi 5 giay neu co thay doi (co _state_dirty). File
# thieu/hong/sai dinh dang thi bo qua, khoi dong moi tu ngay 1
# (khong crash). Vong 84: trade_log / auction_log / shop_log
# (100 muc gan nhat moi loai) CUNG persist — restart van giu lich
# su giao dich / dau gia / mua cho; entry nao sai thi bo entry do,
# giu phan dung (xem cac cleaner log). Phien dau gia het han
# trong luc server sap duoc dong + quyet toan o lan poll dau sau
# restart — vong 101: auction_closed CON toi duoc tay nguoi choi
# dang offline (hang doi _auction_pending, mau _trade_pending
# vong 100: gui lai luc hello sau, persist qua restart). Vong
# 102: auction_outbid CON toi duoc tay nguoi vua bi vuot gia
# dang offline (hang doi _outbid_pending, mau _auction_pending
# vong 101: broadcast auction_bid chi toi nguoi online).
const STATE_VERSION := 1
const STATE_FILE_DEFAULT := "user://pxb_server_state.json"
const STATE_AUTOSAVE_MS := 5000
# Mã sạp tối đa 64 ký tự — khớp mã món.
const MAX_STALL_ID_LEN := 64
# Sổ giữ sạp tối đa 256 người (khớp LEDGER_MAX_PLAYERS; vượt thì
# xóa hold của người không còn online — xem _prune_holds).
const HOLDS_MAX_PLAYERS := 256
# Giá khởi điểm tối thiểu 1.000đ — PROVISIONAL (tránh phiên giá 0).
const MIN_AUCTION_START_PRICE_VND := 1000
# Giá tối đa trong 1 phiên đấu giá — bằng tiền trade tối đa
# (100 tỉ = giá penthouse/đảo, mức tiền lớn nhất trong GDD).
const MAX_AUCTION_MONEY_VND := 100000000000
# Giá sau phải cao hơn giá hiện tại ít nhất 1.000đ — PROVISIONAL.
const MIN_BID_INCREMENT_VND := 1000
# Thời gian phiên đấu giá: 30 giây .. 1 giờ — PROVISIONAL.
const MIN_AUCTION_DURATION_S := 30
const MAX_AUCTION_DURATION_S := 3600
# Log phiên đấu giá đã đóng giữ 100 món gần nhất (chỉ để quan sát).
const AUCTION_LOG_MAX := 100
# Sổ cái server (vòng 72): tối đa 512 món / lần đồng bộ, tối đa
# 256 người chơi có entry ledger (vượt thì xóa entry của người
# không còn online — xem _prune_ledger).
const LEDGER_MAX_ITEMS := 512
const LEDGER_MAX_PLAYERS := 256

## Phát khi 1 client hello thành công (đã vào presence).
signal peer_joined(peer_id: int, player_id: String)
## Phát khi 1 client đã đăng ký rời đi (bye hoặc mất kết nối).
signal peer_left(peer_id: int, player_id: String)
## Phát khi 1 tin chat đã broadcast.
signal chat_received(msg: Dictionary)
## Phát khi 1 đề nghị đổi đồ đã tạo (đã gửi cho người nhận).
signal trade_offered(trade: Dictionary)
## Phát khi 1 đề nghị đã được chấp nhận (đã gửi trade_completed cho cả 2 bên).
signal trade_completed(trade: Dictionary)
## Phát khi 1 đề nghị bị từ chối (đã báo cho người gửi).
signal trade_declined(trade_id: String, reason: String)
## Phát khi 1 đề nghị bị hủy (người gửi hủy / 1 bên mất kết nối).
signal trade_cancelled(trade_id: String, reason: String)
## Phát khi 1 phiên đấu giá đã mở (đã broadcast cho mọi người).
signal auction_created(auction: Dictionary)
## Phát khi 1 giá đấu đã đặt (đã broadcast cho mọi người).
signal auction_bid_placed(auction: Dictionary)
## Phát khi 1 phiên đấu giá đã đóng (hết giờ — đã broadcast cho
## người online + xếp hàng đợi cho người bán / người thắng đang
## offline, vòng 101).
signal auction_closed(auction: Dictionary)
## Phát khi 1 phiên đấu giá bị hủy (người bán hủy / người bán mất
## kết nối khi chưa có ai đấu giá).
signal auction_cancelled(auction_id: String, reason: String)

var peer: WebSocketMultiplayerPeer = null
var port: int = 0
var running: bool = false
## peer_id (int) -> {peer_id, player_id, name, joined_at_ms}.
var players: Dictionary = {}
## 100 tin chat gần nhất, mỗi tin như gói broadcast.
var chat_log: Array = []
## Số gói bỏ vì sai định dạng / sai luật — để quan sát, không crash.
var dropped_packets: int = 0
## trade_id -> {trade_id, from_peer, from_player_id, to_peer,
## to_player_id, give_item_id, give_money, want_item_id,
## want_money, created_at_ms}. Tối đa 1 đề nghị đang chờ cho mỗi
## người gửi.
var trades: Dictionary = {}
## 100 giao dịch đã chốt gần nhất (dạng trade dict + completed_at_ms).
var trade_log: Array = []
var _trade_seq: int = 0
## Vong 100: thong bao trade chua giao duoc vi ben kia dang offline
## (chap nhan/tu choi/huy luc nguoi kia chua hello lai sau restart):
## player_id -> Array cac message dict (trade_completed /
## trade_declined / trade_cancelled) de gui lai luc hello sau.
## PERSIST qua restart (luu trong state file, xem save/load_state
## + _clean_trade_pending) — giao dich da chot luc ben kia offline
## van toi tay du server restart truoc khi ben do hello lai.
## Toi da 10 thong bao / nguoi choi, cu nhat bi day ra.
const TRADE_PENDING_MAX := 10
var _trade_pending: Dictionary = {}
## Vong 101: thong bao auction_closed chua giao duoc vi nguoi ban
## / nguoi thang dang offline luc phien dong (broadcast chi toi
## nguoi dang online): player_id -> Array cac message dict
## (auction_closed) de gui lai luc hello sau. PERSIST qua restart
## (luu trong state file, xem save/load_state + _clean_auction_pending)
## — phien da chot luc ben kia offline van toi tay du server restart
## truoc khi ben do hello lai. Toi da 10 thong bao / nguoi choi,
## cu nhat bi day ra (giong _trade_pending vong 100).
const AUCTION_PENDING_MAX := 10
var _auction_pending: Dictionary = {}
## Vong 102: thong bao auction_outbid chua giao duoc vi nguoi
## vua bi vuot gia dang offline luc co gia cao hon (broadcast
## auction_bid chi toi nguoi dang online): player_id -> Array cac
## message dict (auction_outbid) de gui lai luc hello sau. PERSIST
## qua restart (luu trong state file, xem save/load_state +
## _clean_outbid_pending) — tin vuot gia van toi tay du server
## restart truoc khi ben do hello lai. Toi da 10 thong bao /
## nguoi choi, cu nhat bi day ra (giong _auction_pending vong 101).
const OUTBID_PENDING_MAX := 10
var _outbid_pending: Dictionary = {}
## auction_id -> {auction_id, seller_peer, seller_player_id,
## item_id, start_price, current_bid, current_bidder_player_id,
## created_at_ms, ends_at_ms}. Tối đa 1 phiên đang mở cho mỗi
## người bán (giống luật 1 đề nghị trade đang chờ / người gửi).
var auctions: Dictionary = {}
## 100 phiên đấu giá đã đóng gần nhất (dạng auction dict +
## winner_player_id / hammer_price / fee_vnd /
## seller_receives_vnd / closed_at_ms / ledger).
var auction_log: Array = []
var _auction_seq: int = 0
## 100 lần mua ở chợ qua server gần nhất (vòng 77): {player_id,
## item_id, price_paid, fame_gained, at_ms} — chỉ ghi khi mua
## thành công; mua bị từ chối thì không ghi (lý do nằm trong ack
## trả về cho client).
var shop_log: Array = []
const SHOP_LOG_MAX := 100
## Sổ cái server (vòng 72): player_id -> {"money": int,
## "items": {item_id: int}, "reserved": int}. "reserved" là tiền
## đang giữ hộ cho các giá cao nhất mà người này đang dẫn đầu
## (cộng dồn nhiều phiên); client đồng bộ qua ledger_sync, server
## validate + quyết toán đấu giá từ đây. Entry tồn tại cả khi
## người chơi đã mất kết nối (phiên có giá vẫn chốt được).
var ledger: Dictionary = {}
## Sổ giữ sạp server (vòng 80): player_id -> {"stall_id": String,
## "start_day": int, "until_day": int, "synced_at_ms": int}. 1 người
## giữ tối đa 1 sạp (khớp luật can_challenge vòng 68 — 1 đội giữ
## tối đa 1 sạp). Server là nơi DUY NHẤT tính discount giá sỉ +
## phí đấu giá từ sổ này (xem _handle_stall_hold_sync +
## _live_hold_for); client chỉ khai, server tính lại. Entry tồn
## tại cả khi người chơi đã mất kết nối (hết hạn theo ngày game
## thì tự xóa khi xét — xem _live_hold_for).
var holds: Dictionary = {}
## Ngay game do server lam chu (vong 81): _server_day_base la ngay
## luc mo cong (mac dinh 1), _server_day_started_ms la moc that
## luc ngay do bat dau. server_day() = base + so ngay 30 phut da
## troi tu moc. day_length_ms CHO TEST dat nho de cho sang ngay
## that (mac dinh DAY_LENGTH_MS); debug_set_server_day() dat lai
## moc ngay (chi dung cho test — giong PxbTime.debug_set_elapsed).
var day_length_ms: int = DAY_LENGTH_MS
var _server_day_base: int = 1
var _server_day_started_ms: int = 0
## Persistence (vong 82): duong dan file trang thai. Rong = KHONG
## bat persistence (server khoi dong moi sach — xem const STATE
## o tren; server_main luon dat, test r82 dat /tmp). _state_dirty
## = co thay doi chua luu; _state_last_save_ms = moc luu gan nhat
## (de autosave 5 giay).
var state_file_path: String = ""
var _state_dirty: bool = false
var _state_last_save_ms: int = 0


static func _now_ms() -> int:
	return int(Time.get_unix_time_from_system() * 1000.0)


# Ngay game hien tai theo dong ho server (vong 81). Chua mo cong
# thi tra _server_day_base (mac dinh 1).
func server_day() -> int:
	if _server_day_started_ms <= 0:
		return maxi(_server_day_base, 1)
	var span := maxi(day_length_ms, 1)
	return maxi(_server_day_base, 1) + int((_now_ms() - _server_day_started_ms) / span)


# So ms con lai toi ranh gioi ngay ke (de client hien dem nguoc).
func day_ends_in_ms() -> int:
	if _server_day_started_ms <= 0:
		return maxi(day_length_ms, 1)
	var span := maxi(day_length_ms, 1)
	var elapsed := _now_ms() - _server_day_started_ms
	return span - int(elapsed % span)


# Thong tin ngay server de gui cho client (welcome / day_sync_ack).
func server_day_info() -> Dictionary:
	return {"server_day": server_day(), "day_length_ms": maxi(day_length_ms, 1),
		"day_ends_in_ms": day_ends_in_ms()}


# CHI DUNG CHO TEST: dat lai moc ngay server (ngay hien tai = day,
# bat dau dem tu bay gio). Khong dung trong game that.
func debug_set_server_day(day: int) -> void:
	_server_day_base = maxi(day, 1)
	_server_day_started_ms = _now_ms()
	_mark_state_dirty()


# --- Persistence ngay + ledger + holds (vong 82) ---

# Duong dan file trang thai that su dung.
func state_file() -> String:
	if state_file_path.strip_edges().is_empty():
		return STATE_FILE_DEFAULT
	return state_file_path


# Persistence co bat khong: chi khi state_file_path duoc dat
# tuong minh. Rong = test / server nhung: khoi dong moi sach,
# khong doc/ghi file nao (xem ghi chu o const STATE_*).
func _persistence_enabled() -> bool:
	return not state_file_path.strip_edges().is_empty()


# Danh dau co thay doi chua luu (autosave 5 giay se ghi).
func _mark_state_dirty() -> void:
	_state_dirty = true


# Luu ngay + ledger + holds + trades dang cho + auctions dang
# mo + chat_log xuong file JSON. Tra {ok, path} hoac
# {ok:false, reason, error}. Ghi truc tiep (khong ghi tam roi
# doi ten — file nho, ghi 1 lan la xong; loi ghi thi bao ro).
func save_state() -> Dictionary:
	var path := state_file()
	var state := {
		"version": STATE_VERSION,
		"saved_at_unix_ms": _now_ms(),
		"server_day_base": maxi(_server_day_base, 1),
		"server_day_started_ms": _server_day_started_ms,
		"day_length_ms": maxi(day_length_ms, 1),
		"ledger": ledger.duplicate(true),
		"holds": holds.duplicate(true),
		"trades": trades.duplicate(true),
		"auctions": auctions.duplicate(true),
		"chat_log": chat_log.duplicate(true),
		"trade_log": trade_log.duplicate(true),
		"auction_log": auction_log.duplicate(true),
		"shop_log": shop_log.duplicate(true),
		"trade_pending": _trade_pending.duplicate(true),
		"auction_pending": _auction_pending.duplicate(true),
		"outbid_pending": _outbid_pending.duplicate(true),
	}
	var text := JSON.stringify(state)
	if text.is_empty():
		return {"ok": false, "reason": "khong-ghi-duoc-json", "path": path}
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return {"ok": false, "reason": "khong-mo-duoc-file",
			"error": FileAccess.get_open_error(), "path": path}
	f.store_string(text)
	f.close()
	_state_dirty = false
	_state_last_save_ms = _now_ms()
	return {"ok": true, "path": path}


# Nap trang thai tu file JSON (goi o start_server). Tra
# {ok:true, loaded:true} khi nap duoc; {ok:false, reason} khi
# file thieu / hong / sai dinh dang — luc do GIU NGUYEN trang
# thai hien tai (ngay 1, so trong), khong crash, khong xoa file.
# Entry ledger/hold nao sai thi bo entry do, giu phan dung.
func load_state() -> Dictionary:
	var path := state_file()
	if not FileAccess.file_exists(path):
		return {"ok": false, "reason": "chua-co-file", "path": path}
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {"ok": false, "reason": "khong-mo-duoc-file",
			"error": FileAccess.get_open_error(), "path": path}
	var text := f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(text)
	if not (parsed is Dictionary):
		return {"ok": false, "reason": "file-hong", "path": path}
	var raw: Dictionary = parsed
	if int(raw.get("version", 0)) != STATE_VERSION:
		return {"ok": false, "reason": "phien-ban-la", "path": path}
	var base_raw: Variant = raw.get("server_day_base", 0)
	var started_raw: Variant = raw.get("server_day_started_ms", 0)
	if not (base_raw is int or base_raw is float) or int(base_raw) != base_raw \
			or int(base_raw) < 1:
		return {"ok": false, "reason": "ngay-sai", "path": path}
	if not (started_raw is int or started_raw is float) or int(started_raw) != started_raw \
			or int(started_raw) <= 0:
		return {"ok": false, "reason": "ngay-sai", "path": path}
	var len_raw: Variant = raw.get("day_length_ms", 0)
	if (len_raw is int or len_raw is float) and int(len_raw) == len_raw and int(len_raw) >= 1:
		day_length_ms = int(len_raw)
	var new_ledger := {}
	var raw_ledger: Variant = raw.get("ledger", {})
	if raw_ledger is Dictionary:
		for pid in (raw_ledger as Dictionary).keys():
			if new_ledger.size() >= LEDGER_MAX_PLAYERS:
				break
			var cleaned := _clean_ledger_entry((raw_ledger as Dictionary)[pid])
			if not cleaned.is_empty():
				new_ledger[String(pid)] = cleaned
	var new_holds := {}
	var raw_holds: Variant = raw.get("holds", {})
	if raw_holds is Dictionary:
		for pid in (raw_holds as Dictionary).keys():
			if new_holds.size() >= HOLDS_MAX_PLAYERS:
				break
			var cleaned_h := _clean_hold_entry((raw_holds as Dictionary)[pid])
			if not cleaned_h.is_empty():
				new_holds[String(pid)] = cleaned_h
	# Vong 83: nap trades dang cho + auctions dang mo + chat_log
	# (khoa cu khong co thi khoi dong sach — file v82 cu van nap
	# duoc). Entry nao sai thi bo entry do, giu phan dung.
	# peer_id trong file la so socket cu (da het han) → cleaner
	# dat ve -1; _rebind_after_hello gan lai khi nguoi choi
	# hello lai. Phien het han trong luc sap van giu — lan poll
	# dau sau restart se dong + quyet toan (xem
	# _close_expired_auctions).
	var new_trades := {}
	var raw_trades: Variant = raw.get("trades", {})
	if raw_trades is Dictionary:
		for tid in (raw_trades as Dictionary).keys():
			if new_trades.size() >= MAX_PLAYERS:
				break
			var cleaned_t := _clean_trade_entry((raw_trades as Dictionary)[tid])
			if not cleaned_t.is_empty():
				new_trades[String(tid)] = cleaned_t
	var new_auctions := {}
	var raw_auctions: Variant = raw.get("auctions", {})
	if raw_auctions is Dictionary:
		for aid in (raw_auctions as Dictionary).keys():
			if new_auctions.size() >= MAX_PLAYERS:
				break
			var cleaned_a := _clean_auction_entry((raw_auctions as Dictionary)[aid])
			if not cleaned_a.is_empty():
				new_auctions[String(aid)] = cleaned_a
	var new_chat: Array = []
	var raw_chat: Variant = raw.get("chat_log", [])
	if raw_chat is Array:
		for item in raw_chat:
			if new_chat.size() >= CHAT_LOG_MAX:
				break
			var cleaned_c := _clean_chat_entry(item)
			if not cleaned_c.is_empty():
				new_chat.append(cleaned_c)
	# Vong 84: nap trade_log + auction_log + shop_log (khoa cu
	# khong co thi khoi dong sach — file v83 cu van nap duoc).
	# Entry nao sai thi bo entry do, giu phan dung. peer trong
	# log la so socket cu (da het han) → cleaner dat ve -1;
	# log chi de quan sat (khong rebind, khong gui lai).
	var new_trade_log: Array = []
	var raw_tlog: Variant = raw.get("trade_log", [])
	if raw_tlog is Array:
		for item in raw_tlog:
			if new_trade_log.size() >= TRADE_LOG_MAX:
				break
			var cleaned_tl := _clean_trade_log_entry(item)
			if not cleaned_tl.is_empty():
				new_trade_log.append(cleaned_tl)
	var new_auction_log: Array = []
	var raw_alog: Variant = raw.get("auction_log", [])
	if raw_alog is Array:
		for item in raw_alog:
			if new_auction_log.size() >= AUCTION_LOG_MAX:
				break
			var cleaned_al := _clean_auction_log_entry(item)
			if not cleaned_al.is_empty():
				new_auction_log.append(cleaned_al)
	var new_shop_log: Array = []
	var raw_slog: Variant = raw.get("shop_log", [])
	if raw_slog is Array:
		for item in raw_slog:
			if new_shop_log.size() >= SHOP_LOG_MAX:
				break
			var cleaned_sl := _clean_shop_log_entry(item)
			if not cleaned_sl.is_empty():
				new_shop_log.append(cleaned_sl)
	# Vong 100: nap hang doi thong bao trade chua giao
	# (trade_pending) — khoa cu khong co thi khoi dong sach
	# (file v99 cu van nap duoc). Entry nao sai thi bo entry do.
	var new_pending := {}
	var raw_pending: Variant = raw.get("trade_pending", {})
	if raw_pending is Dictionary:
		for pid in (raw_pending as Dictionary).keys():
			if new_pending.size() >= MAX_PLAYERS:
				break
			var cleaned_p := _clean_trade_pending((raw_pending as Dictionary)[pid])
			if not cleaned_p.is_empty():
				new_pending[String(pid)] = cleaned_p
	# Vong 101: nap hang doi thong bao auction_closed chua giao
	# (auction_pending) — khoa cu khong co thi khoi dong sach
	# (file v100 cu van nap duoc). Entry nao sai thi bo entry do.
	var new_auction_pending := {}
	var raw_apending: Variant = raw.get("auction_pending", {})
	if raw_apending is Dictionary:
		for pid in (raw_apending as Dictionary).keys():
			if new_auction_pending.size() >= MAX_PLAYERS:
				break
			var cleaned_ap := _clean_auction_pending((raw_apending as Dictionary)[pid])
			if not cleaned_ap.is_empty():
				new_auction_pending[String(pid)] = cleaned_ap
	# Vong 102: nap hang doi thong bao auction_outbid chua giao
	# (outbid_pending) — khoa cu khong co thi khoi dong sach
	# (file v101 cu van nap duoc). Entry nao sai thi bo entry do.
	var new_outbid_pending := {}
	var raw_opending: Variant = raw.get("outbid_pending", {})
	if raw_opending is Dictionary:
		for pid in (raw_opending as Dictionary).keys():
			if new_outbid_pending.size() >= MAX_PLAYERS:
				break
			var cleaned_op := _clean_outbid_pending((raw_opending as Dictionary)[pid])
			if not cleaned_op.is_empty():
				new_outbid_pending[String(pid)] = cleaned_op
	_server_day_base = int(base_raw)
	_server_day_started_ms = int(started_raw)
	ledger = new_ledger
	holds = new_holds
	trades = new_trades
	auctions = new_auctions
	chat_log = new_chat
	trade_log = new_trade_log
	auction_log = new_auction_log
	shop_log = new_shop_log
	_trade_pending = new_pending
	_auction_pending = new_auction_pending
	_outbid_pending = new_outbid_pending
	_state_dirty = false
	_state_last_save_ms = _now_ms()
	return {"ok": true, "loaded": true, "path": path}


# Ghi trang thai neu co thay doi va da qua 5 giay tu lan luu
# truoc (goi tu _process + poll — ca server trong cay lan test
# goi poll tay deu duoc autosave). Chi chay khi persistence bat.
func _maybe_autosave() -> void:
	if not running or not _state_dirty or not _persistence_enabled():
		return
	if _now_ms() - _state_last_save_ms < STATE_AUTOSAVE_MS:
		return
	save_state()


# Loc 1 entry ledger tu file (tra {} neu sai — bo entry do):
# money int >= 0, items dict {id: int >= 0} toi da 512 mon,
# reserved int >= 0, owned loc bang _clean_owned_dict.
func _clean_ledger_entry(raw: Variant) -> Dictionary:
	if not (raw is Dictionary):
		return {}
	var d: Dictionary = raw
	var money_raw: Variant = d.get("money", -1)
	if not (money_raw is int or money_raw is float) or int(money_raw) != money_raw \
			or int(money_raw) < 0:
		return {}
	var items := {}
	var raw_items: Variant = d.get("items", {})
	if raw_items is Dictionary:
		for k in (raw_items as Dictionary).keys():
			if items.size() >= LEDGER_MAX_ITEMS:
				break
			var c: Variant = (raw_items as Dictionary)[k]
			if (c is int or c is float) and int(c) == c and int(c) >= 0:
				items[String(k)] = int(c)
	var reserved_raw: Variant = d.get("reserved", -1)
	if not (reserved_raw is int or reserved_raw is float) \
			or int(reserved_raw) != reserved_raw or int(reserved_raw) < 0:
		return {}
	return {"money": int(money_raw), "items": items,
		"reserved": int(reserved_raw),
		"owned": _clean_owned_dict(d.get("owned", {}))}


# Loc 1 entry hold tu file (tra {} neu sai — bo entry do):
# stall_id 1..64 ky tu, start_day >= 1, until_day > start_day.
func _clean_hold_entry(raw: Variant) -> Dictionary:
	if not (raw is Dictionary):
		return {}
	var d: Dictionary = raw
	var stall_id := String(d.get("stall_id", "")).strip_edges()
	var start_raw: Variant = d.get("start_day", 0)
	var until_raw: Variant = d.get("until_day", 0)
	if stall_id.is_empty() or stall_id.length() > MAX_STALL_ID_LEN:
		return {}
	if not (start_raw is int or start_raw is float) or int(start_raw) != start_raw \
			or int(start_raw) < 1:
		return {}
	if not (until_raw is int or until_raw is float) or int(until_raw) != until_raw \
			or int(until_raw) <= int(start_raw):
		return {}
	var synced_raw: Variant = d.get("synced_at_ms", 0)
	var synced := 0
	if (synced_raw is int or synced_raw is float) and int(synced_raw) == synced_raw \
			and int(synced_raw) >= 0:
		synced = int(synced_raw)
	return {"stall_id": stall_id, "start_day": int(start_raw),
		"until_day": int(until_raw), "synced_at_ms": synced}


# Loc 1 de nghi trade dang cho tu file (tra {} neu sai — bo de
# nghi do): trade_id khong rong, from/to player_id khong rong
# (<=64 ky tu), ma mon <=64 ky tu, tien int 0..100 ti,
# created_at_ms int >= 0. peer dat ve -1 (so socket cu da het
# han — rebind khi hello lai, xem _rebind_after_hello).
func _clean_trade_entry(raw: Variant) -> Dictionary:
	if not (raw is Dictionary):
		return {}
	var d: Dictionary = raw
	var trade_id := String(d.get("trade_id", "")).strip_edges()
	var from_id := String(d.get("from_player_id", "")).strip_edges()
	var to_id := String(d.get("to_player_id", "")).strip_edges()
	var give_item := String(d.get("give_item_id", "")).strip_edges()
	var want_item := String(d.get("want_item_id", "")).strip_edges()
	if trade_id.is_empty() or from_id.is_empty() or to_id.is_empty():
		return {}
	if from_id.length() > MAX_PLAYER_ID_LEN or to_id.length() > MAX_PLAYER_ID_LEN:
		return {}
	if give_item.length() > MAX_ITEM_ID_LEN or want_item.length() > MAX_ITEM_ID_LEN:
		return {}
	var give_money: Variant = d.get("give_money", -1)
	var want_money: Variant = d.get("want_money", -1)
	if not _is_valid_trade_money(give_money) or not _is_valid_trade_money(want_money):
		return {}
	var give_empty := give_item.is_empty() and int(give_money) == 0
	var want_empty := want_item.is_empty() and int(want_money) == 0
	if give_empty or want_empty:
		return {}
	var created_raw: Variant = d.get("created_at_ms", -1)
	if not (created_raw is int or created_raw is float) \
			or int(created_raw) != created_raw or int(created_raw) < 0:
		return {}
	return {"trade_id": trade_id, "from_peer": -1,
		"from_player_id": from_id, "to_peer": -1,
		"to_player_id": to_id, "give_item_id": give_item,
		"give_money": int(give_money), "want_item_id": want_item,
		"want_money": int(want_money),
		"created_at_ms": int(created_raw)}


# Tien trade hop le: so nguyen 0..100 ti.
func _is_valid_trade_money(raw: Variant) -> bool:
	return (raw is int or raw is float) and int(raw) == raw \
		and int(raw) >= 0 and int(raw) <= MAX_TRADE_MONEY_VND


# Vong 100: loc 1 hang doi thong bao trade chua giao cua 1 nguoi
# choi tu file (tra [] neu sai — bo ca hang doi do): Array cac
# message dict, moi message co "type" thuoc 3 loai
# (trade_completed / trade_declined / trade_cancelled) +
# "trade_id" khong rong. Message trade_completed phai co du
# from/to_player_id de client _clean_trade chap nhan; message
# khong hop le thi bo message do, giu phan dung. Toi da
# TRADE_PENDING_MAX message / nguoi choi.
func _clean_trade_pending(raw: Variant) -> Array:
	if not (raw is Array):
		return []
	var out: Array = []
	for item in raw:
		if out.size() >= TRADE_PENDING_MAX:
			break
		if not (item is Dictionary):
			continue
		var m: Dictionary = item
		var mtype := String(m.get("type", ""))
		if mtype != "trade_completed" and mtype != "trade_declined" \
				and mtype != "trade_cancelled":
			continue
		if String(m.get("trade_id", "")).strip_edges().is_empty():
			continue
		if mtype == "trade_completed":
			if String(m.get("from_player_id", "")).strip_edges().is_empty() \
					or String(m.get("to_player_id", "")).strip_edges().is_empty():
				continue
		out.append(m.duplicate(true))
	return out


# Vong 102: loc 1 danh sach thong bao auction_outbid cho giao
# luc hello sau (tra [] neu sai — bo ca danh sach): moi muc la
# Dictionary type "auction_outbid", auction_id khong rong,
# old_bidder_player_id khong rong, old_bid int >= 0; cap
# OUTBID_PENDING_MAX / nguoi, giu nguyen thu tu (moi nhat o cuoi).
func _clean_outbid_pending(raw: Variant) -> Array:
	if not (raw is Array):
		return []
	var out: Array = []
	for item in raw:
		if out.size() >= OUTBID_PENDING_MAX:
			break
		if not (item is Dictionary):
			continue
		var m: Dictionary = item
		if String(m.get("type", "")) != "auction_outbid":
			continue
		if String(m.get("auction_id", "")).strip_edges().is_empty():
			continue
		if String(m.get("old_bidder_player_id", "")).strip_edges().is_empty():
			continue
		var old_bid: Variant = m.get("old_bid", -1)
		if not (old_bid is int or old_bid is float) or int(old_bid) != old_bid or int(old_bid) < 0:
			continue
		out.append(m.duplicate(true))
	return out


# Vong 101: loc 1 danh sach thong bao auction_closed cho giao
# luc hello sau (tra [] neu sai — bo ca danh sach): moi muc la
# Dictionary type "auction_closed", auction_id khong rong,
# seller_player_id khong rong; cap AUCTION_PENDING_MAX / nguoi,
# giu nguyen thu tu (moi nhat o cuoi).
func _clean_auction_pending(raw: Variant) -> Array:
	if not (raw is Array):
		return []
	var out: Array = []
	for item in raw:
		if out.size() >= AUCTION_PENDING_MAX:
			break
		if not (item is Dictionary):
			continue
		var m: Dictionary = item
		if String(m.get("type", "")) != "auction_closed":
			continue
		if String(m.get("auction_id", "")).strip_edges().is_empty():
			continue
		if String(m.get("seller_player_id", "")).strip_edges().is_empty():
			continue
		out.append(m.duplicate(true))
	return out


# Loc 1 phien dau gia dang mo tu file (tra {} neu sai — bo phien
# do): auction_id khong rong, seller_player_id khong rong
# (<=64 ky tu), item_id khong rong (<=64 ky tu), start_price
# int 1000..100 ti, current_bid int 0..100 ti, current_bidder
# (co the rong = chua ai dau), created_at_ms int >= 0,
# ends_at_ms int > created_at_ms (het han roi van giu — poll
# dau se dong + quyet toan). seller_peer dat ve -1 (rebind
# khi hello lai).
func _clean_auction_entry(raw: Variant) -> Dictionary:
	if not (raw is Dictionary):
		return {}
	var d: Dictionary = raw
	var auction_id := String(d.get("auction_id", "")).strip_edges()
	var seller_id := String(d.get("seller_player_id", "")).strip_edges()
	var item_id := String(d.get("item_id", "")).strip_edges()
	var bidder_id := String(d.get("current_bidder_player_id", "")).strip_edges()
	if auction_id.is_empty() or seller_id.is_empty() or item_id.is_empty():
		return {}
	if seller_id.length() > MAX_PLAYER_ID_LEN \
			or bidder_id.length() > MAX_PLAYER_ID_LEN \
			or item_id.length() > MAX_ITEM_ID_LEN:
		return {}
	var start_raw: Variant = d.get("start_price", 0)
	var bid_raw: Variant = d.get("current_bid", 0)
	if not (start_raw is int or start_raw is float) \
			or int(start_raw) != start_raw \
			or int(start_raw) < MIN_AUCTION_START_PRICE_VND \
			or int(start_raw) > MAX_AUCTION_MONEY_VND:
		return {}
	if not (bid_raw is int or bid_raw is float) \
			or int(bid_raw) != bid_raw \
			or int(bid_raw) < 0 or int(bid_raw) > MAX_AUCTION_MONEY_VND:
		return {}
	var created_raw: Variant = d.get("created_at_ms", -1)
	var ends_raw: Variant = d.get("ends_at_ms", -1)
	if not (created_raw is int or created_raw is float) \
			or int(created_raw) != created_raw or int(created_raw) < 0:
		return {}
	if not (ends_raw is int or ends_raw is float) \
			or int(ends_raw) != ends_raw or int(ends_raw) <= int(created_raw):
		return {}
	return {"auction_id": auction_id, "seller_peer": -1,
		"seller_player_id": seller_id, "item_id": item_id,
		"start_price": int(start_raw), "current_bid": int(bid_raw),
		"current_bidder_player_id": bidder_id,
		"created_at_ms": int(created_raw),
		"ends_at_ms": int(ends_raw)}


# Loc 1 tin chat tu file (tra {} neu sai — bo tin do): ten
# khong rong (<=30 ky tu), text 1..500 ky tu, player_id co the
# rong (tin cu khong ghi), at_ms int >= 0. from_peer dat ve -1
# (so socket cu — hien thi dung player_id/name).
func _clean_chat_entry(raw: Variant) -> Dictionary:
	if not (raw is Dictionary):
		return {}
	var d: Dictionary = raw
	var pname := String(d.get("name", "")).strip_edges()
	var text := String(d.get("text", "")).strip_edges()
	var player_id := String(d.get("player_id", "")).strip_edges()
	if pname.is_empty() or pname.length() > MAX_NAME_LEN:
		return {}
	if text.is_empty() or text.length() > MAX_CHAT_LEN:
		return {}
	if player_id.length() > MAX_PLAYER_ID_LEN:
		return {}
	var at_raw: Variant = d.get("at_ms", -1)
	if not (at_raw is int or at_raw is float) \
			or int(at_raw) != at_raw or int(at_raw) < 0:
		return {}
	return {"type": "chat", "from_peer": -1,
		"player_id": player_id, "name": pname, "text": text,
		"at_ms": int(at_raw)}


# Loc 1 muc trade_log tu file (tra {} neu sai — bo muc do):
# cac truong trade nhu _clean_trade_entry (peer ve -1, so
# socket cu vo nghia sau restart) + completed_at_ms int >= 0
# (bat buoc) + "ledger" neu co phai la Dictionary (quyet toan
# vong 73; sai kieu thi bo khoi ledger, giu muc log).
func _clean_trade_log_entry(raw: Variant) -> Dictionary:
	if not (raw is Dictionary):
		return {}
	var base := _clean_trade_entry(raw)
	if base.is_empty():
		return {}
	var d: Dictionary = raw
	var done_raw: Variant = d.get("completed_at_ms", -1)
	if not (done_raw is int or done_raw is float) \
			or int(done_raw) != done_raw or int(done_raw) < 0:
		return {}
	base["completed_at_ms"] = int(done_raw)
	var ledger_raw: Variant = d.get("ledger", null)
	if ledger_raw != null:
		if not (ledger_raw is Dictionary):
			return {}
		base["ledger"] = (ledger_raw as Dictionary).duplicate(true)
	return base


# Loc 1 muc auction_log tu file (tra {} neu sai — bo muc do):
# cac truong phien nhu _clean_auction_entry (seller_peer ve -1)
# + winner_player_id (co the rong = khong ai dau, <=64 ky tu) +
# hammer_price int 0..100 ti + fee_vnd int >= 0 +
# seller_receives_vnd int >= 0 + closed_at_ms int >= 0 +
# "ledger" neu co phai la Dictionary (quyet toan vong 72; sai
# kieu thi bo khoi ledger, giu muc log).
func _clean_auction_log_entry(raw: Variant) -> Dictionary:
	if not (raw is Dictionary):
		return {}
	var base := _clean_auction_entry(raw)
	if base.is_empty():
		return {}
	var d: Dictionary = raw
	var winner := String(d.get("winner_player_id", "")).strip_edges()
	if winner.length() > MAX_PLAYER_ID_LEN:
		return {}
	var hammer_raw: Variant = d.get("hammer_price", -1)
	if not (hammer_raw is int or hammer_raw is float) \
			or int(hammer_raw) != hammer_raw \
			or int(hammer_raw) < 0 or int(hammer_raw) > MAX_AUCTION_MONEY_VND:
		return {}
	var fee_raw: Variant = d.get("fee_vnd", -1)
	if not (fee_raw is int or fee_raw is float) \
			or int(fee_raw) != fee_raw or int(fee_raw) < 0:
		return {}
	var recv_raw: Variant = d.get("seller_receives_vnd", -1)
	if not (recv_raw is int or recv_raw is float) \
			or int(recv_raw) != recv_raw or int(recv_raw) < 0:
		return {}
	var closed_raw: Variant = d.get("closed_at_ms", -1)
	if not (closed_raw is int or closed_raw is float) \
			or int(closed_raw) != closed_raw or int(closed_raw) < 0:
		return {}
	base["winner_player_id"] = winner
	base["hammer_price"] = int(hammer_raw)
	base["fee_vnd"] = int(fee_raw)
	base["seller_receives_vnd"] = int(recv_raw)
	base["closed_at_ms"] = int(closed_raw)
	var ledger_raw: Variant = d.get("ledger", null)
	if ledger_raw != null:
		if not (ledger_raw is Dictionary):
			return {}
		base["ledger"] = (ledger_raw as Dictionary).duplicate(true)
	return base


# Loc 1 muc shop_log tu file (tra {} neu sai — bo muc do):
# player_id khong rong (<=64 ky tu), item_id khong rong
# (<=64 ky tu), kind "buy"/"sell" (thieu thi "buy" — muc cu
# truoc vong 86 khong ghi kind), price_paid int 0..100 ti
# (muc mua), price_received int 0..100 ti (muc ban — muc mua
# thieu thi 0), fame_gained int >= 0, at_ms int >= 0,
# discount_applied / discount_claimed int 0..50 (thieu thi 0
# — muc cu truoc vong 80 khong ghi 2 truong nay).
func _clean_shop_log_entry(raw: Variant) -> Dictionary:
	if not (raw is Dictionary):
		return {}
	var d: Dictionary = raw
	var player_id := String(d.get("player_id", "")).strip_edges()
	var item_id := String(d.get("item_id", "")).strip_edges()
	if player_id.is_empty() or item_id.is_empty():
		return {}
	if player_id.length() > MAX_PLAYER_ID_LEN \
			or item_id.length() > MAX_ITEM_ID_LEN:
		return {}
	var kind := String(d.get("kind", "buy")).strip_edges()
	if kind != "buy" and kind != "sell":
		return {}
	var price_raw: Variant = d.get("price_paid", -1)
	if not (price_raw is int or price_raw is float) \
			or int(price_raw) != price_raw \
			or int(price_raw) < 0 or int(price_raw) > MAX_TRADE_MONEY_VND:
		return {}
	var received_raw: Variant = d.get("price_received", 0)
	if not (received_raw is int or received_raw is float) \
			or int(received_raw) != received_raw \
			or int(received_raw) < 0 or int(received_raw) > MAX_TRADE_MONEY_VND:
		return {}
	if kind == "sell" and int(received_raw) <= 0:
		return {}
	var fame_raw: Variant = d.get("fame_gained", -1)
	if not (fame_raw is int or fame_raw is float) \
			or int(fame_raw) != fame_raw or int(fame_raw) < 0:
		return {}
	var at_raw: Variant = d.get("at_ms", -1)
	if not (at_raw is int or at_raw is float) \
			or int(at_raw) != at_raw or int(at_raw) < 0:
		return {}
	var disc_raw: Variant = d.get("discount_applied", 0)
	if not (disc_raw is int or disc_raw is float) \
			or int(disc_raw) != disc_raw \
			or int(disc_raw) < 0 or int(disc_raw) > 50:
		return {}
	var claimed_raw: Variant = d.get("discount_claimed", 0)
	if not (claimed_raw is int or claimed_raw is float) \
			or int(claimed_raw) != claimed_raw \
			or int(claimed_raw) < 0 or int(claimed_raw) > 50:
		return {}
	return {"player_id": player_id, "item_id": item_id,
		"kind": kind, "price_paid": int(price_raw),
		"price_received": int(received_raw),
		"fame_gained": int(fame_raw),
		"at_ms": int(at_raw), "discount_applied": int(disc_raw),
		"discount_claimed": int(claimed_raw)}


# Kiem tra ngay game client kem theo (shop_buy / stall_hold_sync):
# khong kem thi dung ngay server (ok); kem so nguyen khac ngay
# server thi tu choi "ngay-server-khong-khop"; kem sai kieu thi bo
# qua nhu khong kem (lenient nhu shop_buy cu — server khong can
# ngay de tinh, chi can biet ngay do co dung ngay hien tai khong).
func _check_client_day(msg: Dictionary) -> Dictionary:
	var raw: Variant = msg.get("game_day", -1)
	if raw is int or raw is float:
		if int(raw) == raw and int(raw) >= 1 and int(raw) != server_day():
			return {"ok": false, "reason": "ngay-server-khong-khop", "server_day": server_day()}
	return {"ok": true, "reason": "", "server_day": server_day()}


# Mở cổng WebSocket và bắt đầu nhận client. Trả {ok:true, port}
# hoặc {ok:false, reason[, error]}. Gọi 2 lần khi đang chạy thì
# trả {ok:false, reason:"server-dang-chay"}.
func start_server(p_port: int = DEFAULT_PORT) -> Dictionary:
	if running:
		return {"ok": false, "reason": "server-dang-chay"}
	if p_port < 1 or p_port > 65535:
		return {"ok": false, "reason": "cong-khong-hop-le"}
	var ws := WebSocketMultiplayerPeer.new()
	var err: Error = ws.create_server(p_port)
	if err != OK:
		return {"ok": false, "reason": "khong-mo-duoc-cong", "error": err}
	peer = ws
	port = p_port
	players = {}
	chat_log = []
	dropped_packets = 0
	trades = {}
	trade_log = []
	_trade_seq = 0
	auctions = {}
	auction_log = []
	_auction_seq = 0
	shop_log = []
	ledger = {}
	holds = {}
	_server_day_base = 1
	_server_day_started_ms = _now_ms()
	_state_dirty = false
	_state_last_save_ms = 0
	# Vong 82: nap trang thai cu (ngay/ledger/holds) CHI KHI
	# persistence bat (state_file_path dat tuong minh — server
	# that / test r82); khong bat thi giu trang thai moi (ngay 1,
	# so trong). File thieu/hong thi load_state bo qua.
	if _persistence_enabled():
		load_state()
	peer.peer_connected.connect(_on_peer_connected)
	peer.peer_disconnected.connect(_on_peer_disconnected)
	running = true
	return {"ok": true, "port": p_port}


# Dừng server: đóng cổng, xóa presence. Client đang nối sẽ thấy
# mất kết nối. Gọi khi chưa chạy cũng an toàn. Vong 82: luu trang
# thai truoc khi xoa CHI KHI persistence bat (restart sau nap lai
# ngay/ledger/holds); khong bat thi khong ghi file nao.
func stop_server() -> void:
	if running and _persistence_enabled():
		save_state()
	if peer != null:
		peer.close()
		peer = null
	players.clear()
	chat_log.clear()
	trades.clear()
	trade_log.clear()
	_trade_seq = 0
	auctions.clear()
	auction_log.clear()
	_auction_seq = 0
	shop_log.clear()
	_server_day_base = 1
	_server_day_started_ms = 0
	_state_dirty = false
	port = 0
	running = false


func _process(_delta: float) -> void:
	if running:
		poll()


# Một nhịp mạng: poll peer + xử lý hết gói đang chờ + đóng các
# phiên đấu giá đã hết giờ. _process gọi sẵn khi node trong cây;
# test headless gọi trực tiếp cũng được (poll 2 lần/frame cũng
# không sao — đóng phiên nào rồi thì không đóng lại).
func poll() -> void:
	if peer == null:
		return
	peer.poll()
	while peer.get_available_packet_count() > 0:
		var from_peer: int = peer.get_packet_peer()
		var raw: PackedByteArray = peer.get_packet()
		_handle_packet(from_peer, raw)
	_close_expired_auctions()
	_maybe_autosave()


# Số người chơi đã đăng ký presence.
func player_count() -> int:
	return players.size()


# Danh sách presence, xếp theo peer_id tăng dần — dạng gửi cho client.
func presence_list() -> Array:
	var ids: Array = players.keys()
	ids.sort()
	var out: Array = []
	for id in ids:
		var info: Dictionary = players[id]
		out.append({
			"peer_id": int(id),
			"player_id": String(info["player_id"]),
			"name": String(info["name"]),
		})
	return out


# Trạng thái quan sát được (log / test): không chứa socket.
func data() -> Dictionary:
	return {
		"port": port,
		"running": running,
		"player_count": players.size(),
		"players": presence_list(),
		"chat_count": chat_log.size(),
		"trade_pending": trades.size(),
		"trade_completed_count": trade_log.size(),
		"trade_undelivered": _trade_pending.size(),
		"auction_undelivered": _auction_pending.size(),
		"outbid_undelivered": _outbid_pending.size(),
		"auction_open": auctions.size(),
		"auction_closed_count": auction_log.size(),
		"shop_buy_count": shop_log.size(),
		"shop_sell_count": _shop_sell_count(),
		"holds_count": holds.size(),
		"server_day": server_day(),
		"state_file": state_file(),
		"state_dirty": _state_dirty,
		"dropped_packets": dropped_packets,
	}


func _send_to(target_peer: int, msg: Dictionary) -> void:
	if peer == null:
		return
	peer.set_target_peer(target_peer)
	peer.put_packet(JSON.stringify(msg).to_utf8_buffer())


# Gửi cho mọi client ĐÃ ĐĂNG KÝ (target 0 = broadcast sẽ gửi cả cho
# socket vừa ngắt — engine báo lỗi ready_state; gửi từng peer đã
# đăng ký thì sạch log và client chưa hello cũng không nhận presence).
func _broadcast(msg: Dictionary) -> void:
	if peer == null:
		return
	var payload := JSON.stringify(msg).to_utf8_buffer()
	for target_peer in players.keys():
		peer.set_target_peer(int(target_peer))
		peer.put_packet(payload)


func _handle_packet(from_peer: int, raw: PackedByteArray) -> void:
	var text := raw.get_string_from_utf8().strip_edges()
	# Chặn rác không phải JSON object trước khi parse — JSON.parse_string
	# in ERROR ra log mỗi lần gặp chuỗi sai (client độc spam sẽ ngập
	# log); object hợp lệ luôn bắt đầu "{" và kết thúc "}".
	if not text.begins_with("{") or not text.ends_with("}"):
		dropped_packets += 1
		return
	var parsed: Variant = JSON.parse_string(text)
	if not (parsed is Dictionary):
		dropped_packets += 1
		return
	var msg: Dictionary = parsed
	match String(msg.get("type", "")):
		"hello":
			_handle_hello(from_peer, msg)
		"chat":
			_handle_chat(from_peer, msg)
		"trade_offer":
			_handle_trade_offer(from_peer, msg)
		"trade_accept":
			_handle_trade_accept(from_peer, msg)
		"trade_decline":
			_handle_trade_decline(from_peer, msg)
		"trade_cancel":
			_handle_trade_cancel(from_peer, msg)
		"auction_create":
			_handle_auction_create(from_peer, msg)
		"auction_bid":
			_handle_auction_bid(from_peer, msg)
		"auction_cancel":
			_handle_auction_cancel(from_peer, msg)
		"auction_list":
			_handle_auction_list(from_peer, msg)
		"ledger_sync":
			_handle_ledger_sync(from_peer, msg)
		"shop_buy":
			_handle_shop_buy(from_peer, msg)
		"shop_sell":
			_handle_shop_sell(from_peer, msg)
		"stall_hold_sync":
			_handle_stall_hold_sync(from_peer, msg)
		"day_sync":
			_handle_day_sync(from_peer, msg)
		"bye":
			_handle_bye(from_peer)
		_:
			dropped_packets += 1


func _handle_hello(from_peer: int, msg: Dictionary) -> void:
	var proto: Variant = msg.get("protocol", PROTOCOL_VERSION)
	if (proto is int or proto is float) and int(proto) != PROTOCOL_VERSION:
		_send_to(from_peer, {"type": "error", "reason": "protocol-khong-ho-tro"})
		dropped_packets += 1
		return
	var player_id := String(msg.get("player_id", "")).strip_edges()
	if player_id.is_empty() or player_id.length() > MAX_PLAYER_ID_LEN:
		_send_to(from_peer, {"type": "error", "reason": "thieu-player-id"})
		dropped_packets += 1
		return
	var pname := String(msg.get("name", "")).strip_edges()
	if pname.is_empty():
		pname = "Người chơi"
	if pname.length() > MAX_NAME_LEN:
		pname = pname.substr(0, MAX_NAME_LEN)
	if players.size() >= MAX_PLAYERS and not players.has(from_peer):
		_send_to(from_peer, {"type": "error", "reason": "server-day"})
		dropped_packets += 1
		return
	players[from_peer] = {
		"peer_id": from_peer,
		"player_id": player_id,
		"name": pname,
		"joined_at_ms": _now_ms(),
	}
	_send_to(from_peer, {"type": "welcome", "peer_id": from_peer,
		"protocol": PROTOCOL_VERSION, "players": presence_list(),
		"server_day": server_day(), "day_length_ms": maxi(day_length_ms, 1)})
	_broadcast({"type": "presence", "players": presence_list()})
	_rebind_after_hello(from_peer, player_id)
	peer_joined.emit(from_peer, player_id)


func _handle_chat(from_peer: int, msg: Dictionary) -> void:
	if not players.has(from_peer):
		dropped_packets += 1
		return
	var text := String(msg.get("text", "")).strip_edges()
	if text.is_empty() or text.length() > MAX_CHAT_LEN:
		dropped_packets += 1
		return
	var info: Dictionary = players[from_peer]
	var chat_msg := {
		"type": "chat",
		"from_peer": from_peer,
		"player_id": String(info["player_id"]),
		"name": String(info["name"]),
		"text": text,
		"at_ms": _now_ms(),
	}
	chat_log.append(chat_msg)
	while chat_log.size() > CHAT_LOG_MAX:
		chat_log.pop_front()
	_mark_state_dirty()
	_broadcast(chat_msg)
	chat_received.emit(chat_msg)


# Xin ngay server hien tai (vong 81 — client hoi de dong bo ngay
# sau khi (re)connect hoac khi can biet con bao lau thi sang ngay).
# Phai hello truoc; chua hello thi bo lang (nhu chat khi chua hello).
func _handle_day_sync(from_peer: int, _msg: Dictionary) -> void:
	if not players.has(from_peer):
		dropped_packets += 1
		return
	var info := server_day_info()
	_send_to(from_peer, {"type": "day_sync_ack",
		"server_day": int(info.get("server_day", 1)),
		"day_length_ms": int(info.get("day_length_ms", DAY_LENGTH_MS)),
		"day_ends_in_ms": int(info.get("day_ends_in_ms", DAY_LENGTH_MS))})


# Gan lai peer_id moi cho trade/auction da nap tu file khi 1
# nguoi choi hello lai sau restart (vong 83): trade/auction
# luu trong file chi giu player_id (peer cu da het han, luc nap
# dat -1). Nguoi vua vao nhan lai: de nghi dang cho minh tra loi
# (trade_offer) / de nghi minh da gui (trade_offered) + lich su
# chat gan day (chat_history, client cu bo qua vi khong biet
# type nay — xem PxbOnline._handle_ws_message). Phien dau gia dang
# mo khong gui lai o day — client tu xin auction_list khi can
# (chi rebind seller_peer). Chi gui cho nguoi vua hello, khong
# broadcast. Vong 100: them gui lai thong bao trade con no
# (_trade_pending, da persist qua restart). Vong 101: them gui lai
# thong bao auction_closed con no (_auction_pending — phien da
# chot luc nguoi ban / nguoi thang offline).
func _rebind_after_hello(peer_id: int, player_id: String) -> void:
	for tid in trades.keys():
		var t: Dictionary = trades[tid]
		var changed := false
		if String(t.get("from_player_id", "")) == player_id \
				and int(t.get("from_peer", -1)) != peer_id:
			t["from_peer"] = peer_id
			changed = true
		if String(t.get("to_player_id", "")) == player_id \
				and int(t.get("to_peer", -1)) != peer_id:
			t["to_peer"] = peer_id
			changed = true
		if not changed:
			continue
		trades[tid] = t
		if String(t.get("to_player_id", "")) == player_id:
			var offer_msg := {"type": "trade_offer"}
			offer_msg.merge(t)
			_send_to(peer_id, offer_msg)
		if String(t.get("from_player_id", "")) == player_id:
			var offered_msg := {"type": "trade_offered"}
			offered_msg.merge(t)
			_send_to(peer_id, offered_msg)
	for aid in auctions.keys():
		var a: Dictionary = auctions[aid]
		if String(a.get("seller_player_id", "")) == player_id \
				and int(a.get("seller_peer", -1)) != peer_id:
			a["seller_peer"] = peer_id
			auctions[aid] = a
	if not chat_log.is_empty():
		_send_to(peer_id, {"type": "chat_history",
			"messages": chat_log.duplicate(true)})
	_flush_trade_pending(peer_id, player_id)
	_flush_auction_pending(peer_id, player_id)
	_flush_outbid_pending(peer_id, player_id)
	# Vong 100: hang doi _trade_pending da persist trong state
	# file nen restart khong mat — chi can flush o day, khong
	# gui lap trade_completed tu trade_log (gui lap co nguy co
	# ap trung khi client da ap roi, vi ws_trades_applied chi
	# giu 50 id gan nhat). Vong 101: hang doi _auction_pending
	# cung vay — khong gui lap auction_closed tu auction_log
	# (ws_auctions_applied cung chi giu 50 id gan nhat). Vong 102:
	# hang doi _outbid_pending cung vay — khong gui lap
	# auction_outbid tu broadcast auction_bid cu (broadcast da qua,
	# nguoi offline khong nhan duoc nua).


# Tìm peer_id đã đăng ký theo player_id; -1 = không có ai đó.
func _find_peer_by_player_id(player_id: String) -> int:
	for pid in players.keys():
		if String((players[pid] as Dictionary).get("player_id", "")) == player_id:
			return int(pid)
	return -1


# Vong 100: gui 1 thong bao trade (completed/declined/cancelled)
# cho 1 nguoi choi — neu dang online thi gui ngay, neu offline
# thi xep vao hang doi _trade_pending de gui lai luc hello sau
# (xem _rebind_after_hello). Khong gui vao peer -1 / peer chua
# dang ky: truoc day _send_to(-1) lam roi goi, ben kia khong bao
# gio nhan duoc trade_completed du giao dich da chot o server.
func _send_trade_notice(player_id: String, peer: int, msg: Dictionary) -> void:
	if peer > 0 and players.has(peer):
		_send_to(peer, msg)
		return
	if player_id.is_empty():
		return
	var queued: Array = _trade_pending.get(player_id, [])
	queued.append(msg.duplicate(true))
	while queued.size() > TRADE_PENDING_MAX:
		queued.pop_front()
	_trade_pending[player_id] = queued
	_mark_state_dirty()


# Vong 100: gui lai cac thong bao trade con no cho nguoi vua
# hello lai (hang doi RAM _trade_pending).
func _flush_trade_pending(peer_id: int, player_id: String) -> void:
	if not _trade_pending.has(player_id):
		return
	var queued: Array = _trade_pending[player_id]
	_trade_pending.erase(player_id)
	for m in queued:
		if m is Dictionary:
			_send_to(peer_id, m)


# Vong 101: gui 1 thong bao auction_closed cho 1 nguoi choi —
# neu dang online thi gui ngay, neu offline thi xep vao hang doi
# _auction_pending de gui lai luc hello sau (xem
# _rebind_after_hello). Khong gui vao peer -1 / peer chua dang ky:
# truoc day broadcast chi toi nguoi online, ben offline khong bao
# gio nhan duoc auction_closed du phien da chot o server.
func _send_auction_closed_notice(player_id: String, peer: int, msg: Dictionary) -> void:
	if peer > 0 and players.has(peer):
		_send_to(peer, msg)
		return
	if player_id.is_empty():
		return
	var queued: Array = _auction_pending.get(player_id, [])
	queued.append(msg.duplicate(true))
	while queued.size() > AUCTION_PENDING_MAX:
		queued.pop_front()
	_auction_pending[player_id] = queued
	_mark_state_dirty()


# Vong 101: gui lai cac thong bao auction_closed con no cho
# nguoi vua hello lai (hang doi RAM _auction_pending).
func _flush_auction_pending(peer_id: int, player_id: String) -> void:
	if not _auction_pending.has(player_id):
		return
	var queued: Array = _auction_pending[player_id]
	_auction_pending.erase(player_id)
	for m in queued:
		if m is Dictionary:
			_send_to(peer_id, m)


# Vong 102: gui 1 thong bao auction_outbid cho nguoi vua bi
# vuot gia — neu dang online thi gui ngay, neu offline thi xep
# vao hang doi _outbid_pending de gui lai luc hello sau (xem
# _rebind_after_hello). Khong gui vao peer -1 / peer chua dang ky:
# truoc day broadcast auction_bid chi toi nguoi online, ben
# offline khong bao gio biet minh da bi vuot gia du tien giu ho
# da duoc giai phong o server.
func _send_outbid_notice(player_id: String, peer: int, msg: Dictionary) -> void:
	if peer > 0 and players.has(peer):
		_send_to(peer, msg)
		return
	if player_id.is_empty():
		return
	var queued: Array = _outbid_pending.get(player_id, [])
	queued.append(msg.duplicate(true))
	while queued.size() > OUTBID_PENDING_MAX:
		queued.pop_front()
	_outbid_pending[player_id] = queued
	_mark_state_dirty()


# Vong 102: gui lai cac thong bao auction_outbid con no cho
# nguoi vua hello lai (hang doi RAM _outbid_pending).
func _flush_outbid_pending(peer_id: int, player_id: String) -> void:
	if not _outbid_pending.has(player_id):
		return
	var queued: Array = _outbid_pending[player_id]
	_outbid_pending.erase(player_id)
	for m in queued:
		if m is Dictionary:
			_send_to(peer_id, m)


# Từ chối 1 lệnh trade: trả trade_error cho người gửi (KHÔNG ngắt
# kết nối — khác gói "error" của hello) + đếm dropped_packets.
func _trade_error(to_peer: int, reason: String) -> void:
	_send_to(to_peer, {"type": "trade_error", "reason": reason})
	dropped_packets += 1


# Tạo 1 đề nghị đổi đồ. Kiểm tra theo thứ tự: người gửi đã hello,
# có người nhận, không đổi với chính mình, mã món ≤64 ký tự, tiền
# 0..100 tỉ (số nguyên), cho + muốn đều không rỗng, người gửi chưa
# có đề nghị đang chờ. Vòng 103: người nhận ĐANG OFFLINE vẫn tạo
# được đề nghị (to_peer = -1) — đề nghị lưu trong trades (đã persist
# trong state file) và _rebind_after_hello gửi lại trade_offer cho
# người nhận lúc họ hello sau (vòng 83 đã gửi lại đề nghị đang mở);
# trước đây từ chối "khong-tim-thay-nguoi-choi" nên đề nghị mất hẳn.
# Đạt thì tạo trade_id "trade-<ms>-<seq>", lưu vào trades, gửi
# trade_offer cho người nhận nếu đang online + trade_offered cho
# người gửi (kèm to_peer để client biết người nhận có online không).
func _handle_trade_offer(from_peer: int, msg: Dictionary) -> void:
	if not players.has(from_peer):
		dropped_packets += 1
		return
	var from_info: Dictionary = players[from_peer]
	var to_player_id := String(msg.get("to_player_id", "")).strip_edges()
	var give_item_id := String(msg.get("give_item_id", "")).strip_edges()
	var want_item_id := String(msg.get("want_item_id", "")).strip_edges()
	var give_money: Variant = msg.get("give_money", 0)
	var want_money: Variant = msg.get("want_money", 0)
	if to_player_id.is_empty():
		_trade_error(from_peer, "thieu-nguoi-nhan")
		return
	if to_player_id == String(from_info["player_id"]):
		_trade_error(from_peer, "khong-doi-voi-chinh-minh")
		return
	if give_item_id.length() > MAX_ITEM_ID_LEN or want_item_id.length() > MAX_ITEM_ID_LEN:
		_trade_error(from_peer, "item-id-qua-dai")
		return
	if not (give_money is int or give_money is float) or int(give_money) != give_money \
			or int(give_money) < 0 or int(give_money) > MAX_TRADE_MONEY_VND:
		_trade_error(from_peer, "tien-trade-khong-hop-le")
		return
	if not (want_money is int or want_money is float) or int(want_money) != want_money \
			or int(want_money) < 0 or int(want_money) > MAX_TRADE_MONEY_VND:
		_trade_error(from_peer, "tien-trade-khong-hop-le")
		return
	var give_empty := give_item_id.is_empty() and int(give_money) == 0
	var want_empty := want_item_id.is_empty() and int(want_money) == 0
	if give_empty or want_empty:
		_trade_error(from_peer, "de-nghi-trong")
		return
	for tid in trades.keys():
		if int((trades[tid] as Dictionary).get("from_peer", -1)) == from_peer:
			_trade_error(from_peer, "da-co-de-nghi-cho")
			return
	var to_peer := _find_peer_by_player_id(to_player_id)
	# Vòng 103: người nhận offline (to_peer -1) vẫn tạo được đề
	# nghị — không từ chối nữa (trước đây "khong-tim-thay-nguoi-choi").
	# Người nhận sẽ nhận trade_offer lúc hello lại (_rebind_after_hello
	# gửi lại đề nghị đang mở); hủy/từ chối sau đó đã có hàng đợi
	# _trade_pending (vòng 100) nên không mất tin.
	# Vòng 73 (sổ cái): người gửi đã đồng bộ ledger thì chỉ cho
	# gửi đề nghị trong khả năng còn lại — tiền cho <= money -
	# reserved (tiền đang giữ hộ đấu giá không dùng được cho
	# trade), món cho phải còn trong ledger. Chưa đồng bộ thì cho
	# qua (hành vi cũ — client kiểm ở lúc gửi, server quyết toán
	# lúc chấp nhận).
	var s_entry: Dictionary = ledger.get(String(from_info["player_id"]), {})
	if not s_entry.is_empty():
		var avail := maxi(int(s_entry.get("money", 0)), 0) - maxi(int(s_entry.get("reserved", 0)), 0)
		if int(give_money) > avail:
			_trade_error(from_peer, "khong-du-tien-cho")
			return
		if not give_item_id.is_empty():
			var s_items: Dictionary = s_entry.get("items", {})
			if int(s_items.get(give_item_id, 0)) < 1:
				_trade_error(from_peer, "khong-du-do-cho")
				return
	_trade_seq += 1
	var trade_id := "trade-%d-%d" % [_now_ms(), _trade_seq]
	var trade := {
		"trade_id": trade_id,
		"from_peer": from_peer,
		"from_player_id": String(from_info["player_id"]),
		"to_peer": to_peer,
		"to_player_id": to_player_id,
		"give_item_id": give_item_id,
		"give_money": int(give_money),
		"want_item_id": want_item_id,
		"want_money": int(want_money),
		"created_at_ms": _now_ms(),
	}
	trades[trade_id] = trade
	_mark_state_dirty()
	var offer_msg := {"type": "trade_offer"}
	offer_msg.merge(trade)
	# Vòng 103: chỉ gửi trade_offer ngay khi người nhận đang online;
	# offline thì đề nghị nằm trong trades, _rebind_after_hello gửi
	# lại lúc họ hello sau. Người gửi luôn nhận trade_offered ngay.
	if to_peer > 0:
		_send_to(to_peer, offer_msg)
	var offered_msg := {"type": "trade_offered"}
	offered_msg.merge(trade)
	_send_to(from_peer, offered_msg)
	trade_offered.emit(trade)


# Chấp nhận 1 đề nghị: chỉ người NHẬN mới được. Chốt thì xóa khỏi
# trades, quyết toán từ sổ cái server (vòng 73 — _settle_trade),
# ghi trade_log, gửi trade_completed cho cả 2 bên (kèm khối
# "ledger" khi đã quyết toán).
func _handle_trade_accept(from_peer: int, msg: Dictionary) -> void:
	if not players.has(from_peer):
		dropped_packets += 1
		return
	var trade_id := String(msg.get("trade_id", "")).strip_edges()
	if not trades.has(trade_id):
		_trade_error(from_peer, "khong-tim-thay-de-nghi")
		return
	var trade: Dictionary = trades[trade_id]
	if int(trade.get("to_peer", -1)) != from_peer:
		_trade_error(from_peer, "khong-phai-nguoi-nhan")
		return
	trades.erase(trade_id)
	_mark_state_dirty()
	var done := trade.duplicate()
	done["completed_at_ms"] = _now_ms()
	var settled := _settle_trade(trade)
	if not settled.is_empty():
		done["ledger"] = settled
	trade_log.append(done)
	while trade_log.size() > TRADE_LOG_MAX:
		trade_log.pop_front()
	var completed_msg := {"type": "trade_completed"}
	completed_msg.merge(done)
	# Vong 100: gui cho ca 2 ben — ben nao dang offline thi xep
	# hang doi gui lai luc hello sau, khong gui vao peer -1.
	_send_trade_notice(String(trade.get("from_player_id", "")),
		int(trade.get("from_peer", -1)), completed_msg)
	_send_trade_notice(String(trade.get("to_player_id", "")),
		int(trade.get("to_peer", -1)), completed_msg)
	trade_completed.emit(done)


# Quyết toán 1 giao dịch đổi đồ từ SỔ CÁI server (vòng 73).
# - Không bên nào từng đồng bộ ledger: trả {} (không khối ledger)
#   → client áp theo thỏa thuận như cũ (v70).
# - Có ít nhất 1 bên đã đồng bộ: kiểm tra bên đã đồng bộ có đủ
#   khả năng cho đi không (tiền cho <= money - reserved, còn món
#   cho trong ledger). Bên chưa đồng bộ thì coi như đủ (hành vi
#   cũ — client tự áp, giống người thắng chưa đồng bộ ở đấu giá).
#   Không đủ → HỦY giao dịch: trả khối {voided:true, reason, ...},
#   KHÔNG chuyển gì trong ledger (cả 2 bên giữ nguyên) — đề nghị
#   vẫn bị xóa + trade_completed vẫn gửi để 2 bên biết đã hủy.
#   Đủ → chuyển tiền + món cả 2 chiều trong ledger, nguyên tử
#   trong 1 lần gọi (không có trạng thái nửa vời: không bên nào
#   nhận đủ trong khi bên kia trả thiếu như khe hở v1).
#   Tiền giữ hộ đấu giá (reserved) KHÔNG tính vào khả năng cho
#   trade — tiền khả dụng = money - reserved.
# Trả dict ledger để gửi kèm trade_completed.
func _settle_trade(trade: Dictionary) -> Dictionary:
	var sender_id := String(trade.get("from_player_id", ""))
	var receiver_id := String(trade.get("to_player_id", ""))
	var give_item := String(trade.get("give_item_id", ""))
	var want_item := String(trade.get("want_item_id", ""))
	var give_money := int(trade.get("give_money", 0))
	var want_money := int(trade.get("want_money", 0))
	var s_entry: Dictionary = ledger.get(sender_id, {})
	var r_entry: Dictionary = ledger.get(receiver_id, {})
	if s_entry.is_empty() and r_entry.is_empty():
		return {}
	var s_short_money := 0
	var r_short_money := 0
	var s_missing_item := false
	var r_missing_item := false
	if not s_entry.is_empty():
		var avail := maxi(int(s_entry.get("money", 0)), 0) - maxi(int(s_entry.get("reserved", 0)), 0)
		if give_money > avail:
			s_short_money = give_money - avail
		if not give_item.is_empty():
			var s_items: Dictionary = s_entry.get("items", {})
			if int(s_items.get(give_item, 0)) < 1:
				s_missing_item = true
	if not r_entry.is_empty():
		var avail_r := maxi(int(r_entry.get("money", 0)), 0) - maxi(int(r_entry.get("reserved", 0)), 0)
		if want_money > avail_r:
			r_short_money = want_money - avail_r
		if not want_item.is_empty():
			var r_items: Dictionary = r_entry.get("items", {})
			if int(r_items.get(want_item, 0)) < 1:
				r_missing_item = true
	var reason := ""
	if s_short_money > 0:
		reason = "thieu-tien-nguoi-gui"
	elif s_missing_item:
		reason = "thieu-do-nguoi-gui"
	elif r_short_money > 0:
		reason = "thieu-tien-nguoi-nhan"
	elif r_missing_item:
		reason = "thieu-do-nguoi-nhan"
	if not reason.is_empty():
		return {
			"voided": true, "reason": reason,
			"sender_paid": 0, "receiver_paid": 0,
			"sender_item_transferred": false,
			"receiver_item_transferred": false,
			"sender_money_short": s_short_money,
			"receiver_money_short": r_short_money,
			"sender_missing_item": s_missing_item,
			"receiver_missing_item": r_missing_item,
		}
	if not s_entry.is_empty():
		s_entry["money"] = maxi(int(s_entry.get("money", 0)), 0) - give_money + want_money
		if not give_item.is_empty():
			var s_items2: Dictionary = s_entry.get("items", {})
			s_items2[give_item] = int(s_items2.get(give_item, 0)) - 1
			s_entry["items"] = s_items2
		if not want_item.is_empty():
			var s_items3: Dictionary = s_entry.get("items", {})
			s_items3[want_item] = int(s_items3.get(want_item, 0)) + 1
			s_entry["items"] = s_items3
		ledger[sender_id] = s_entry
	if not r_entry.is_empty():
		r_entry["money"] = maxi(int(r_entry.get("money", 0)), 0) - want_money + give_money
		if not want_item.is_empty():
			var r_items2: Dictionary = r_entry.get("items", {})
			r_items2[want_item] = int(r_items2.get(want_item, 0)) - 1
			r_entry["items"] = r_items2
		if not give_item.is_empty():
			var r_items3: Dictionary = r_entry.get("items", {})
			r_items3[give_item] = int(r_items3.get(give_item, 0)) + 1
			r_entry["items"] = r_items3
		ledger[receiver_id] = r_entry
	_mark_state_dirty()
	return {
		"voided": false, "reason": "",
		"sender_paid": give_money, "receiver_paid": want_money,
		"sender_item_transferred": not give_item.is_empty(),
		"receiver_item_transferred": not want_item.is_empty(),
		"sender_money_short": 0, "receiver_money_short": 0,
		"sender_missing_item": false, "receiver_missing_item": false,
	}


# Từ chối 1 đề nghị: chỉ người NHẬN mới được. Báo trade_declined
# cho người gửi.
func _handle_trade_decline(from_peer: int, msg: Dictionary) -> void:
	if not players.has(from_peer):
		dropped_packets += 1
		return
	var trade_id := String(msg.get("trade_id", "")).strip_edges()
	if not trades.has(trade_id):
		_trade_error(from_peer, "khong-tim-thay-de-nghi")
		return
	var trade: Dictionary = trades[trade_id]
	if int(trade.get("to_peer", -1)) != from_peer:
		_trade_error(from_peer, "khong-phai-nguoi-nhan")
		return
	trades.erase(trade_id)
	_mark_state_dirty()
	# Vong 100: nguoi gui dang offline thi xep hang doi gui lai
	# luc hello sau thay vi gui vao peer -1.
	_send_trade_notice(String(trade.get("from_player_id", "")),
		int(trade.get("from_peer", -1)), {"type": "trade_declined",
		"trade_id": trade_id, "reason": "nguoi-nhan-tu-choi"})
	trade_declined.emit(trade_id, "nguoi-nhan-tu-choi")


# Hủy 1 đề nghị: chỉ người GỬI mới được. Báo trade_cancelled cho
# người nhận.
func _handle_trade_cancel(from_peer: int, msg: Dictionary) -> void:
	if not players.has(from_peer):
		dropped_packets += 1
		return
	var trade_id := String(msg.get("trade_id", "")).strip_edges()
	if not trades.has(trade_id):
		_trade_error(from_peer, "khong-tim-thay-de-nghi")
		return
	var trade: Dictionary = trades[trade_id]
	if int(trade.get("from_peer", -1)) != from_peer:
		_trade_error(from_peer, "khong-phai-nguoi-gui")
		return
	trades.erase(trade_id)
	_mark_state_dirty()
	# Vong 100: nguoi nhan dang offline thi xep hang doi gui lai
	# luc hello sau thay vi gui vao peer -1.
	_send_trade_notice(String(trade.get("to_player_id", "")),
		int(trade.get("to_peer", -1)), {"type": "trade_cancelled",
		"trade_id": trade_id, "reason": "nguoi-gui-da-huy"})
	trade_cancelled.emit(trade_id, "nguoi-gui-da-huy")


# --- Đấu giá qua WS (G4 bước 12, protocol v1) ---
# Server giữ phiên + validate giá + tự đóng khi hết giờ + tính phí
# sàn 5% (đã chốt). CHƯA trừ/chuyển tiền/đồ thật — client nhận
# auction_closed rồi tự áp (xem PxbOnline.apply_auction_closed);
# trừ tiền/đồ ở server là việc sau (cần sổ cái server giữ).

# Từ chối 1 lệnh đấu giá: trả auction_error cho người gửi (KHÔNG
# ngắt kết nối — giống trade_error) + đếm dropped_packets.
func _auction_error(to_peer: int, reason: String) -> void:
	_send_to(to_peer, {"type": "auction_error", "reason": reason})
	dropped_packets += 1


# Dạng phiên gửi cho client (bỏ seller_peer nội bộ, giữ đủ trường
# để client hiển thị + áp kết quả khi đóng).
static func _auction_public(auction: Dictionary) -> Dictionary:
	return {
		"auction_id": String(auction.get("auction_id", "")),
		"seller_player_id": String(auction.get("seller_player_id", "")),
		"item_id": String(auction.get("item_id", "")),
		"start_price": int(auction.get("start_price", 0)),
		"current_bid": int(auction.get("current_bid", 0)),
		"current_bidder_player_id": String(auction.get("current_bidder_player_id", "")),
		"created_at_ms": int(auction.get("created_at_ms", 0)),
		"ends_at_ms": int(auction.get("ends_at_ms", 0)),
	}


# Làm sạch dict owned client gửi lên (vòng 78): chỉ giữ món có
# trong bảng giá PxbEconomy (tài sản mua ở chợ — nhà/xe/điện
# thoại/quần áo), item_id ≤ 64 ký tự, count int 0..99; món sai
# thì bỏ món đó, giữ phần đúng; tối đa LEDGER_MAX_ITEMS món.
# Trả dict {item_id: count} (rỗng khi đầu vào không phải dict).
func _clean_owned_dict(raw: Variant) -> Dictionary:
	var out := {}
	if not (raw is Dictionary):
		return out
	for k in (raw as Dictionary).keys():
		if out.size() >= LEDGER_MAX_ITEMS:
			break
		var item_id := String(k).strip_edges()
		var count: Variant = (raw as Dictionary)[k]
		if item_id.is_empty() or item_id.length() > MAX_ITEM_ID_LEN:
			continue
		if not (count is int or count is float) or int(count) != count \
				or int(count) < 0 or int(count) > 99:
			continue
		if PxbEconomy.get_item(item_id).is_empty():
			continue
		out[item_id] = int(count)
	return out


# Đồng bộ số dư (ví + túi) của 1 người chơi lên sổ cái server
# (vòng 72, vòng 76 thêm base_money + ack + kẹp). Phải hello
# trước. money phải là số nguyên >= 0 (sai thì bỏ cả gói + đếm
# dropped_packets, không trả ack); items là dict {item_id: count}
# tối đa 512 món, item_id ≤ 64 ký tự, count int >= 0 (món sai
# thì bỏ món đó, giữ phần đúng). base_money (mặc định -1 = chưa
# từng nhận ack): money lúc sync lần trước — nếu player đã có
# entry ledger và base_money >= 0 mà khác money trong ledger thì
# sync STALE (đã có quyết toán chen giữa: client mất kết nối
# đúng lúc chốt phiên rồi sync lại bằng số local cũ) nên KHÔNG
# ghi đè, chỉ trả ack với số server hiện tại. Đồng bộ thay thế
# money/items nhưng GIỮ reserved (tiền đang giữ hộ cho giá cao
# nhất — không cho client tự xóa khoản giữ hộ bằng 1 lần sync)
# và KẸP (vòng 76): money không xuống dưới reserved; mỗi món đã
# hứa bán/cho (phiên đấu giá đang mở của người này / trade đang
# chờ do người này gửi) không xuống dưới số phiên/trade đã hứa
# (cộng dồn nếu nhiều phiên/trade cùng món). Vòng 78: owned
# (dict {item_id: count} tài sản đã mua ở chợ) được HỢP NHẤT
# theo max(server, client) từng món — không thay thế tuyệt đối
# như money/items (client có thể mua local offline trước khi
# sync lần đầu; server cũng không bao giờ quên món nó đã
# validate qua shop_buy) — và trả lại trong ack để client lấy
# làm chuẩn. Sau khi ghi (hoặc khi stale) thì trả gói
# ledger_sync_ack về đúng peer: số server sau khi ghi,
# clamped_money/clamped_items ghi rõ phần đã kẹp, stale = true
# khi sync cũ bị từ chối. Ledger giữ tối đa 256
# người chơi: vượt thì xóa entry của người không còn online
# (tránh client lạ spam player_id làm phình bộ nhớ — xem
# _prune_ledger).
func _handle_ledger_sync(from_peer: int, msg: Dictionary) -> void:
	if not players.has(from_peer):
		dropped_packets += 1
		return
	var player_id := String((players[from_peer] as Dictionary).get("player_id", ""))
	if player_id.is_empty():
		dropped_packets += 1
		return
	# Vong 81: game_day kem theo (neu co) KHONG dung nua — ngay
	# de xet han giu sap la ngay server (xem server_day); dong bo
	# so cai khong phu thuoc ngay client bao.
	var money: Variant = msg.get("money", 0)
	if not (money is int or money is float) or int(money) != money or int(money) < 0:
		dropped_packets += 1
		return
	var raw_items: Variant = msg.get("items", {})
	var items := {}
	if raw_items is Dictionary:
		for k in (raw_items as Dictionary).keys():
			if items.size() >= LEDGER_MAX_ITEMS:
				break
			var item_id := String(k).strip_edges()
			var count: Variant = (raw_items as Dictionary)[k]
			if item_id.is_empty() or item_id.length() > MAX_ITEM_ID_LEN:
				continue
			if not (count is int or count is float) or int(count) != count or int(count) < 0:
				continue
			items[item_id] = int(count)
	var entry: Dictionary = ledger.get(player_id, {})
	# Vong 76: base_money khac ledger hien tai -> sync STALE,
	# khong ghi de, chi tra ack voi so server.
	var base_raw: Variant = msg.get("base_money", -1)
	var base_money := -1
	if (base_raw is int or base_raw is float) and int(base_raw) == base_raw and int(base_raw) >= 0:
		base_money = int(base_raw)
	if not entry.is_empty() and base_money >= 0 \
			and base_money != maxi(int(entry.get("money", 0)), 0):
		_send_to(from_peer, {
			"type": "ledger_sync_ack",
			"money": maxi(int(entry.get("money", 0)), 0),
			"items": (entry.get("items", {}) as Dictionary).duplicate(),
			"reserved": maxi(int(entry.get("reserved", 0)), 0),
			"clamped_money": false, "clamped_items": {},
			"stale": true,
			"owned": (entry.get("owned", {}) as Dictionary).duplicate(),
			"server_day": server_day(),
		})
		return
	# Vong 78: hop nhat owned theo max(server, client) tung mon.
	var owned := _clean_owned_dict(msg.get("owned", {}))
	var server_owned: Dictionary = entry.get("owned", {})
	for oid in server_owned.keys():
		var want := maxi(int(server_owned.get(oid, 0)), int(owned.get(oid, 0)))
		if want > 0:
			owned[oid] = want
	var reserved := 0
	if not entry.is_empty():
		reserved = maxi(int(entry.get("reserved", 0)), 0)
	# Vong 76: kep tien gui len khong xuong duoi reserved.
	var money_i := int(money)
	var clamped_money := false
	if money_i < reserved:
		money_i = reserved
		clamped_money = true
	# Vong 76: kep mon da hua — so toi thieu cho tung mon = so
	# phien mo ban mon do + so trade cho mo cho mon do.
	var min_items := {}
	for a in auctions.values():
		var ad: Dictionary = a
		if String(ad.get("seller_player_id", "")) == player_id:
			var iid := String(ad.get("item_id", ""))
			if not iid.is_empty():
				min_items[iid] = int(min_items.get(iid, 0)) + 1
	for t in trades.values():
		var td: Dictionary = t
		if String(td.get("from_player_id", "")) == player_id:
			var gid := String(td.get("give_item_id", ""))
			if not gid.is_empty():
				min_items[gid] = int(min_items.get(gid, 0)) + 1
	var clamped_items := {}
	for iid in min_items.keys():
		var need := int(min_items[iid])
		if int(items.get(iid, 0)) < need:
			items[iid] = need
			clamped_items[iid] = need
	ledger[player_id] = {"money": money_i, "items": items, "reserved": reserved, "owned": owned}
	_mark_state_dirty()
	if ledger.size() > LEDGER_MAX_PLAYERS:
		_prune_ledger()
	_send_to(from_peer, {
		"type": "ledger_sync_ack", "money": money_i,
		"items": items.duplicate(), "reserved": reserved,
		"clamped_money": clamped_money, "clamped_items": clamped_items,
		"stale": false, "owned": owned.duplicate(),
		"server_day": server_day(),
	})


# --- Giu sap len server (vong 80) ---

# Hold dang con han cua nguoi choi o ngay day ({} neu khong co /
# chua toi ngay bat dau / da het han). Het han thi xoa khoi so de
# khoi phinh (ngay chi tang nen hold het han khong song lai).
func _live_hold_for(player_id: String, day: int) -> Dictionary:
	var h: Variant = holds.get(player_id, {})
	if not (h is Dictionary) or (h as Dictionary).is_empty():
		return {}
	var hd := h as Dictionary
	var start := int(hd.get("start_day", 0))
	var until := int(hd.get("until_day", 0))
	if day >= start and day < until:
		return hd
	if day >= until:
		holds.erase(player_id)
	return {}


# Xoa hold cua nguoi khong con online (chi goi khi so vuot toi da
# — tranh client la spam player_id lam phinh bo nho; cung mau nhu
# _prune_ledger).
func _prune_holds() -> void:
	var online_ids := {}
	for p in players.values():
		online_ids[String((p as Dictionary).get("player_id", ""))] = true
	var doomed: Array = []
	for pid in holds.keys():
		if not online_ids.has(String(pid)):
			doomed.append(pid)
	for pid in doomed:
		holds.erase(pid)
	if not doomed.is_empty():
		_mark_state_dirty()


# Dong bo giu sap len server (vong 80 — client gui sau khi thang
# tran tranh sap, hoac gui lai khi (re)connect). Server validate
# that truoc khi ghi so (khong tin so client khai):
# - phai hello truoc; stall_id khong rong / <= 64 ky tu;
# - start_day >= 1, until_day > start_day, giu toi da 7 ngay
#   (khop PxbMarketBattle.HOLD_DAYS);
# - khong giu tu tuong lai (start_day <= ngay server hien tai);
# - chua het han luc dong bo (until_day > ngay server hien tai);
# - (vong 81) game_day kem theo neu co phai bang ngay server.
# - dang giu sap khac con han thi tu choi (1 nguoi toi da 1 sap —
#   khop luat can_challenge vong 68, ma "dang-giu-sap-khac").
# Dong bo lai dung sap (vd reconnect) thi ghi de, tra ok (luy thua).
# Tra stall_hold_sync_ack ve dung peer: ok=true kem discount 10%
# (gia si ap dung khi mua); ok=false kem reason ("chua-hello" /
# "thieu-sap-id" / "ngay-giu-sap-sai" / "het-han-giu-sap" /
# "dang-giu-sap-khac" / "ngay-server-khong-khop") +
# "holding_stall_id" (sap dang giu neu co) + "server_day" (ngay
# server hien tai — co trong MOI ack cua goi nay).
func _handle_stall_hold_sync(from_peer: int, msg: Dictionary) -> void:
	var req_raw: Variant = msg.get("req_id", 0)
	if not (req_raw is int or req_raw is float) or int(req_raw) != req_raw or int(req_raw) < 1:
		dropped_packets += 1
		return
	var req_id := int(req_raw)
	if not players.has(from_peer):
		_send_to(from_peer, {"type": "stall_hold_sync_ack", "req_id": req_id,
			"ok": false, "stall_id": "", "start_day": 0, "until_day": 0,
			"discount_percent": 0, "holding_stall_id": "", "reason": "chua-hello",
			"server_day": server_day()})
		dropped_packets += 1
		return
	var player_id := String((players[from_peer] as Dictionary).get("player_id", ""))
	if player_id.is_empty():
		_send_to(from_peer, {"type": "stall_hold_sync_ack", "req_id": req_id,
			"ok": false, "stall_id": "", "start_day": 0, "until_day": 0,
			"discount_percent": 0, "holding_stall_id": "", "reason": "chua-hello",
			"server_day": server_day()})
		dropped_packets += 1
		return
	var stall_id := String(msg.get("stall_id", "")).strip_edges()
	if stall_id.is_empty() or stall_id.length() > MAX_STALL_ID_LEN:
		_send_to(from_peer, {"type": "stall_hold_sync_ack", "req_id": req_id,
			"ok": false, "stall_id": "", "start_day": 0, "until_day": 0,
			"discount_percent": 0, "holding_stall_id": "", "reason": "thieu-sap-id",
			"server_day": server_day()})
		dropped_packets += 1
		return
	var start_raw: Variant = msg.get("start_day", 0)
	var until_raw: Variant = msg.get("until_day", 0)
	if not (start_raw is int or start_raw is float) or int(start_raw) != start_raw \
			or not (until_raw is int or until_raw is float) or int(until_raw) != until_raw \
			or int(start_raw) < 1 or int(until_raw) < 1:
		_send_to(from_peer, {"type": "stall_hold_sync_ack", "req_id": req_id,
			"ok": false, "stall_id": stall_id, "start_day": 0, "until_day": 0,
			"discount_percent": 0, "holding_stall_id": "", "reason": "ngay-giu-sap-sai",
			"server_day": server_day()})
		dropped_packets += 1
		return
	# Vong 81: ngay la ngay server lam chu — client kem game_day
	# khac ngay server thi tu choi (khong tin ngay client bao de
	# keo dai hold); khong kem thi dung ngay server.
	var day_check := _check_client_day(msg)
	if not bool(day_check.get("ok", false)):
		_send_to(from_peer, {"type": "stall_hold_sync_ack", "req_id": req_id,
			"ok": false, "stall_id": stall_id, "start_day": 0, "until_day": 0,
			"discount_percent": 0, "holding_stall_id": "", "reason": "ngay-server-khong-khop",
			"server_day": server_day()})
		return
	var start := int(start_raw)
	var until := int(until_raw)
	var day := server_day()
	if until <= start or until - start > HOLD_DAYS_MAX or start > day:
		_send_to(from_peer, {"type": "stall_hold_sync_ack", "req_id": req_id,
			"ok": false, "stall_id": stall_id, "start_day": start, "until_day": until,
			"discount_percent": 0, "holding_stall_id": "", "reason": "ngay-giu-sap-sai",
			"server_day": server_day()})
		return
	if until <= day:
		_send_to(from_peer, {"type": "stall_hold_sync_ack", "req_id": req_id,
			"ok": false, "stall_id": stall_id, "start_day": start, "until_day": until,
			"discount_percent": 0, "holding_stall_id": "", "reason": "het-han-giu-sap",
			"server_day": server_day()})
		return
	var cur := _live_hold_for(player_id, day)
	if not cur.is_empty() and String(cur.get("stall_id", "")) != stall_id:
		_send_to(from_peer, {"type": "stall_hold_sync_ack", "req_id": req_id,
			"ok": false, "stall_id": stall_id, "start_day": start, "until_day": until,
			"discount_percent": 0, "holding_stall_id": String(cur.get("stall_id", "")),
			"reason": "dang-giu-sap-khac", "server_day": server_day()})
		return
	holds[player_id] = {"stall_id": stall_id, "start_day": start,
		"until_day": until, "synced_at_ms": _now_ms()}
	_mark_state_dirty()
	if holds.size() > HOLDS_MAX_PLAYERS:
		_prune_holds()
	_send_to(from_peer, {"type": "stall_hold_sync_ack", "req_id": req_id,
		"ok": true, "stall_id": stall_id, "start_day": start, "until_day": until,
		"discount_percent": WHOLESALE_DISCOUNT_PERCENT, "holding_stall_id": "",
		"reason": "", "server_day": server_day()})


# Mua 1 món ở chợ qua server (vòng 77 — kinh tế
# server-authoritative, đóng khe hở "mua/bán local trong Main chưa
# qua server validate" ở godot-g4.md §98.5 mục 3).
# - Giá lấy từ PxbEconomy.get_item (bảng giá duy nhất — server
#   KHÔNG tin giá client gửi, client cũng không gửi giá); giảm giá
#   theo đúng luật economy.buy (discount 0..50, không áp cho
#   "phong-tro"; xe-dap giá 0 thì mua 0đ vẫn qua server để ghi log).
# - Phải hello trước + đã đồng bộ ledger ít nhất 1 lần (chưa có
#   entry thì server không biết ví có bao nhiêu — trả
#   "chua-dong-bo-so-cai", client sync rồi mua lại); tiền khả dụng
#   = money - reserved (tiền đang giữ hộ đấu giá/trade không được
#   tiêu — cùng luật vòng 76).
# - Thành công: TRỪ TIỀN trong ledger + CỘNG MÓN VÀO owned trong
#   ledger (vòng 78 — server làm chuẩn cho tài sản đã mua, không
#   còn chỉ tin client local) + ghi shop_log + trả ack ok=true
#   (money/reserved là số server sau khi trừ, owned là dict
#   owned đầy đủ sau khi mua); client áp ack.owned làm chuẩn.
#   Thất bại: không trừ gì, ack ok=false + reason (không kèm
#   owned — client giữ owned cũ).
func _handle_shop_buy(from_peer: int, msg: Dictionary) -> void:
	var req_raw: Variant = msg.get("req_id", 0)
	if not (req_raw is int or req_raw is float) or int(req_raw) != req_raw or int(req_raw) < 1:
		dropped_packets += 1
		return
	var req_id := int(req_raw)
	if not players.has(from_peer):
		_send_to(from_peer, {"type": "shop_buy_ack", "req_id": req_id,
			"ok": false, "item_id": "", "price_paid": 0, "fame_gained": 0,
			"money": 0, "reserved": 0, "reason": "chua-hello",
			"server_day": server_day()})
		dropped_packets += 1
		return
	var player_id := String((players[from_peer] as Dictionary).get("player_id", ""))
	if player_id.is_empty():
		_send_to(from_peer, {"type": "shop_buy_ack", "req_id": req_id,
			"ok": false, "item_id": "", "price_paid": 0, "fame_gained": 0,
			"money": 0, "reserved": 0, "reason": "chua-hello",
			"server_day": server_day()})
		dropped_packets += 1
		return
	var item_id := String(msg.get("item_id", "")).strip_edges()
	if item_id.is_empty() or item_id.length() > MAX_ITEM_ID_LEN:
		_send_to(from_peer, {"type": "shop_buy_ack", "req_id": req_id,
			"ok": false, "item_id": "", "price_paid": 0, "fame_gained": 0,
			"money": 0, "reserved": 0, "reason": "thieu-item-id",
			"server_day": server_day()})
		dropped_packets += 1
		return
	var disc_raw: Variant = msg.get("discount_percent", 0)
	if not (disc_raw is int or disc_raw is float) or int(disc_raw) != disc_raw \
			or int(disc_raw) < 0 or int(disc_raw) > 50:
		_send_to(from_peer, {"type": "shop_buy_ack", "req_id": req_id,
			"ok": false, "item_id": item_id, "price_paid": 0, "fame_gained": 0,
			"money": 0, "reserved": 0, "reason": "gia-khong-hop-le",
			"server_day": server_day()})
		dropped_packets += 1
		return
	var disc_claimed := int(disc_raw)
	var it := PxbEconomy.get_item(item_id)
	if it.is_empty():
		_send_to(from_peer, {"type": "shop_buy_ack", "req_id": req_id,
			"ok": false, "item_id": item_id, "price_paid": 0, "fame_gained": 0,
			"money": 0, "reserved": 0, "reason": "khong-co-mon",
			"server_day": server_day()})
		return
	# Vong 81: ngay la ngay server lam chu — client kem game_day
	# khac ngay server thi tu choi, khong tru tien (xem
	# _check_client_day); khong kem thi dung ngay server.
	var day_check := _check_client_day(msg)
	if not bool(day_check.get("ok", false)):
		_send_to(from_peer, {"type": "shop_buy_ack", "req_id": req_id,
			"ok": false, "item_id": item_id, "price_paid": 0, "fame_gained": 0,
			"money": 0, "reserved": 0, "reason": "ngay-server-khong-khop",
			"server_day": server_day()})
		return
	var price := int(it.get("price_vnd", 0))
	# Vong 80: discount KHONG tin so client khai nua — server tinh
	# lai tu so holds: chi 10% khi dang giu sap con han o ngay
	# server hien tai, 0% khi khong giu / het han / phong-tro.
	# Khai 50% ma khong giu sap thi van tra gia day (xem ack
	# discount_applied + discount_claimed de client biet bi sua).
	var day := server_day()
	var disc := 0
	if item_id != "phong-tro" and not _live_hold_for(player_id, day).is_empty():
		disc = WHOLESALE_DISCOUNT_PERCENT
	if disc > 0:
		price = price * (100 - disc) / 100
	var entry: Variant = ledger.get(player_id, {})
	if not (entry is Dictionary) or (entry as Dictionary).is_empty():
		_send_to(from_peer, {"type": "shop_buy_ack", "req_id": req_id,
			"ok": false, "item_id": item_id, "price_paid": 0, "fame_gained": 0,
			"money": 0, "reserved": 0, "reason": "chua-dong-bo-so-cai",
			"server_day": server_day()})
		return
	var entry_d := entry as Dictionary
	var money_i := maxi(int(entry_d.get("money", 0)), 0)
	var reserved := maxi(int(entry_d.get("reserved", 0)), 0)
	if money_i - reserved < price:
		_send_to(from_peer, {"type": "shop_buy_ack", "req_id": req_id,
			"ok": false, "item_id": item_id, "price_paid": 0, "fame_gained": 0,
			"money": money_i, "reserved": reserved, "reason": "khong-du-tien",
			"discount_applied": disc, "discount_claimed": disc_claimed,
			"server_day": server_day()})
		return
	money_i -= price
	var fame_gained := 0
	if String(it.get("kind", "")) == "House" or item_id == "xe-sang":
		fame_gained = PxbBalance.BIG_PURCHASE_FAME_BONUS
	entry_d["money"] = money_i
	# Vong 78: cong mon vao owned trong ledger (server lam chuan
	# cho tai san da mua; owned khong nam trong ledger items vi
	# items la tui do slice PxbInventory, khong dem dau gia/trade
	# duoc — 2 kho rieng trong cung entry).
	var owned_d: Dictionary = entry_d.get("owned", {})
	owned_d[item_id] = int(owned_d.get(item_id, 0)) + 1
	entry_d["owned"] = owned_d
	ledger[player_id] = entry_d
	_mark_state_dirty()
	shop_log.append({"player_id": player_id, "item_id": item_id,
		"price_paid": price, "fame_gained": fame_gained, "at_ms": _now_ms(),
		"discount_applied": disc, "discount_claimed": disc_claimed})
	while shop_log.size() > SHOP_LOG_MAX:
		shop_log.pop_front()
	_send_to(from_peer, {"type": "shop_buy_ack", "req_id": req_id,
		"ok": true, "item_id": item_id, "price_paid": price,
		"fame_gained": fame_gained, "money": money_i,
		"reserved": reserved, "owned": owned_d.duplicate(), "reason": "",
		"discount_applied": disc, "discount_claimed": disc_claimed,
		"server_day": server_day()})


# Bán lại 1 món cho chợ qua server (vòng 86 — đối xứng shop_buy):
# validate req_id / hello / item_id / catalog / ngày server (vòng
# 81) rồi kiểm tra ledger đã đồng bộ + đang sở hữu món (owned >= 1)
# + không phải "phong-tro" (thuê tháng, không bán lại được); TRỪ 1
# MÓN khỏi owned trong ledger + CỘNG tiền bán lại (50% giá catalog,
# PxbEconomy.shop_sellback_price — server tính, không tin số client)
# + ghi shop_log kind "sell" + trả ack kèm owned đầy đủ. Không Danh
# vọng khi bán. Ack lỗi không đổi gì, reason là "chua-hello" /
# "thieu-item-id" / "khong-co-mon" / "khong-ban-duoc" /
# "khong-so-huu" / "chua-dong-bo-so-cai" / "ngay-server-khong-khop".
func _handle_shop_sell(from_peer: int, msg: Dictionary) -> void:
	var req_raw: Variant = msg.get("req_id", 0)
	if not (req_raw is int or req_raw is float) or int(req_raw) != req_raw or int(req_raw) < 1:
		dropped_packets += 1
		return
	var req_id := int(req_raw)
	if not players.has(from_peer):
		_send_to(from_peer, {"type": "shop_sell_ack", "req_id": req_id,
			"ok": false, "item_id": "", "price_received": 0,
			"money": 0, "reserved": 0, "reason": "chua-hello",
			"server_day": server_day()})
		dropped_packets += 1
		return
	var player_id := String((players[from_peer] as Dictionary).get("player_id", ""))
	if player_id.is_empty():
		_send_to(from_peer, {"type": "shop_sell_ack", "req_id": req_id,
			"ok": false, "item_id": "", "price_received": 0,
			"money": 0, "reserved": 0, "reason": "chua-hello",
			"server_day": server_day()})
		dropped_packets += 1
		return
	var item_id := String(msg.get("item_id", "")).strip_edges()
	if item_id.is_empty() or item_id.length() > MAX_ITEM_ID_LEN:
		_send_to(from_peer, {"type": "shop_sell_ack", "req_id": req_id,
			"ok": false, "item_id": "", "price_received": 0,
			"money": 0, "reserved": 0, "reason": "thieu-item-id",
			"server_day": server_day()})
		dropped_packets += 1
		return
	var it := PxbEconomy.get_item(item_id)
	if it.is_empty():
		_send_to(from_peer, {"type": "shop_sell_ack", "req_id": req_id,
			"ok": false, "item_id": item_id, "price_received": 0,
			"money": 0, "reserved": 0, "reason": "khong-co-mon",
			"server_day": server_day()})
		return
	# Vong 81: ngay la ngay server lam chu — client kem game_day
	# khac ngay server thi tu choi, khong cong tien (xem
	# _check_client_day); khong kem thi dung ngay server.
	var day_check := _check_client_day(msg)
	if not bool(day_check.get("ok", false)):
		_send_to(from_peer, {"type": "shop_sell_ack", "req_id": req_id,
			"ok": false, "item_id": item_id, "price_received": 0,
			"money": 0, "reserved": 0, "reason": "ngay-server-khong-khop",
			"server_day": server_day()})
		return
	var entry: Variant = ledger.get(player_id, {})
	if not (entry is Dictionary) or (entry as Dictionary).is_empty():
		_send_to(from_peer, {"type": "shop_sell_ack", "req_id": req_id,
			"ok": false, "item_id": item_id, "price_received": 0,
			"money": 0, "reserved": 0, "reason": "chua-dong-bo-so-cai",
			"server_day": server_day()})
		return
	var entry_d := entry as Dictionary
	var money_i := maxi(int(entry_d.get("money", 0)), 0)
	var reserved := maxi(int(entry_d.get("reserved", 0)), 0)
	if item_id == "phong-tro":
		_send_to(from_peer, {"type": "shop_sell_ack", "req_id": req_id,
			"ok": false, "item_id": item_id, "price_received": 0,
			"money": money_i, "reserved": reserved, "reason": "khong-ban-duoc",
			"server_day": server_day()})
		return
	var owned_d: Dictionary = entry_d.get("owned", {})
	var owned_count := int(owned_d.get(item_id, 0))
	if owned_count < 1:
		_send_to(from_peer, {"type": "shop_sell_ack", "req_id": req_id,
			"ok": false, "item_id": item_id, "price_received": 0,
			"money": money_i, "reserved": reserved, "reason": "khong-so-huu",
			"server_day": server_day()})
		return
	var price_received := PxbEconomy.shop_sellback_price(int(it.get("price_vnd", 0)))
	money_i += price_received
	entry_d["money"] = money_i
	if owned_count <= 1:
		owned_d.erase(item_id)
	else:
		owned_d[item_id] = owned_count - 1
	entry_d["owned"] = owned_d
	ledger[player_id] = entry_d
	_mark_state_dirty()
	shop_log.append({"player_id": player_id, "item_id": item_id,
		"kind": "sell", "price_received": price_received,
		"price_paid": 0, "fame_gained": 0, "at_ms": _now_ms(),
		"discount_applied": 0, "discount_claimed": 0})
	while shop_log.size() > SHOP_LOG_MAX:
		shop_log.pop_front()
	_send_to(from_peer, {"type": "shop_sell_ack", "req_id": req_id,
		"ok": true, "item_id": item_id, "price_received": price_received,
		"money": money_i, "reserved": reserved,
		"owned": owned_d.duplicate(), "reason": "",
		"server_day": server_day()})


# Đếm mục bán lại trong shop_log (vòng 86 — shop_buy_count vẫn
# đếm toàn bộ shop_log như cũ để không đổi nghĩa).
func _shop_sell_count() -> int:
	var n := 0
	for e in shop_log:
		if (e is Dictionary) and String((e as Dictionary).get("kind", "buy")) == "sell":
			n += 1
	return n


# Xóa entry ledger của người không còn online (chỉ gọi khi ledger
# vượt tối đa — tránh spam player_id làm phình bộ nhớ).
func _prune_ledger() -> void:
	var online_ids := {}
	for p in players.values():
		online_ids[String((p as Dictionary).get("player_id", ""))] = true
	var doomed: Array = []
	for pid in ledger.keys():
		if not online_ids.has(String(pid)):
			doomed.append(pid)
	for pid in doomed:
		ledger.erase(pid)
	if not doomed.is_empty():
		_mark_state_dirty()


# Giữ hộ thêm amount tiền cho 1 người chơi (khi đặt giá cao
# nhất). Không làm gì khi chưa có entry ledger (chưa đồng bộ).
func _ledger_reserve(player_id: String, amount: int) -> void:
	if amount <= 0 or player_id.is_empty():
		return
	var entry: Dictionary = ledger.get(player_id, {})
	if entry.is_empty():
		return
	entry["reserved"] = maxi(int(entry.get("reserved", 0)), 0) + amount
	ledger[player_id] = entry
	_mark_state_dirty()


# Giải phóng amount tiền giữ hộ (khi bị đấu giá cao hơn / phiên
# đóng). Không âm. Không làm gì khi chưa có entry ledger.
func _ledger_release(player_id: String, amount: int) -> void:
	if amount <= 0 or player_id.is_empty():
		return
	var entry: Dictionary = ledger.get(player_id, {})
	if entry.is_empty():
		return
	entry["reserved"] = maxi(maxi(int(entry.get("reserved", 0)), 0) - amount, 0)
	ledger[player_id] = entry
	_mark_state_dirty()


# Quyết toán 1 phiên đã đóng từ SỔ CÁI server (vòng 72).
# - Không ai đấu giá: khối ledger toàn 0.
# - Người thắng chưa từng đồng bộ ledger: hành vi cũ (v71) —
#   coi như trả đủ hammer, người bán nhận hammer × 95 / 100,
#   chuyển món được (client tự ghi thiếu nếu thật sự thiếu).
# - Người thắng đã đồng bộ: paid = min(hammer, money trong
#   ledger) — thường = hammer vì tiền đã giữ hộ lúc đặt giá;
#   short_money = hammer - paid. Trừ paid khỏi money người
#   thắng, giải phóng reserved đúng hammer (không âm). Người
#   bán: nếu ledger còn món (items[item] >= 1) thì trừ 1 món,
#   cộng 1 món cho người thắng, nhận paid × 95 / 100 (phí =
#   paid - nhận). Vòng 80: người bán đang giữ sạp còn hạn thì phí
#   chỉ 4%, nhận paid × 96 / 100 (xem fee_percent trong hàm).
# - Nếu người bán KHÔNG còn món trong ledger thì
#   HỦY giao dịch: hoàn paid cho người thắng, winner_paid =
#   seller_received = fee = 0, short_money = 0 (không mất tiền
#   vì thiếu món, không phải vì thiếu tiền), missing_item =
#   true, item_transferred = false. Người bán chưa từng đồng
#   bộ thì coi như còn món (hành vi cũ — client tự áp).
# Trả dict ledger để gửi kèm auction_closed (cả top-level
# fee_vnd / seller_receives_vnd cũng lấy số đã quyết toán).
func _settle_auction(auction: Dictionary, hammer: int, winner: String) -> Dictionary:
	var settled := {
		"winner_paid": 0, "seller_received": 0, "fee_vnd": 0,
		"short_money": 0, "missing_item": false,
		"item_transferred": false,
	}
	if hammer <= 0 or winner.is_empty():
		return settled
	var seller_id := String(auction.get("seller_player_id", ""))
	var item_id := String(auction.get("item_id", ""))
	# Vong 80: nguoi ban dang giu sap con han thi phi san giam 20%
	# (5% -> 4%, nhan 96% — khop PxbMarketBattle.hold_benefits).
	# Vong 81: xet theo ngay server hien tai (server_day).
	var fee_percent := AUCTION_FEE_PERCENT
	if not _live_hold_for(seller_id, server_day()).is_empty():
		fee_percent = AUCTION_FEE_PERCENT * (100 - STALL_TAX_CUT_PERCENT) / 100
	var w_entry: Dictionary = ledger.get(winner, {})
	if w_entry.is_empty():
		var receives := hammer * (100 - fee_percent) / 100
		settled["winner_paid"] = hammer
		settled["seller_received"] = receives
		settled["fee_vnd"] = hammer - receives
		settled["item_transferred"] = true
		return settled
	var w_money := maxi(int(w_entry.get("money", 0)), 0)
	var paid := mini(hammer, w_money)
	var short_money := hammer - paid
	w_entry["money"] = w_money - paid
	w_entry["reserved"] = maxi(maxi(int(w_entry.get("reserved", 0)), 0) - hammer, 0)
	ledger[winner] = w_entry
	var s_entry: Dictionary = ledger.get(seller_id, {})
	var has_item := true
	if not s_entry.is_empty():
		var s_items: Dictionary = s_entry.get("items", {})
		has_item = int(s_items.get(item_id, 0)) >= 1
	if has_item:
		if not s_entry.is_empty():
			var s_items2: Dictionary = s_entry.get("items", {})
			s_items2[item_id] = int(s_items2.get(item_id, 0)) - 1
			s_entry["items"] = s_items2
			s_entry["money"] = maxi(int(s_entry.get("money", 0)), 0) + paid * (100 - fee_percent) / 100
			ledger[seller_id] = s_entry
		var w_items: Dictionary = w_entry.get("items", {})
		w_items[item_id] = int(w_items.get(item_id, 0)) + 1
		w_entry["items"] = w_items
		ledger[winner] = w_entry
		var receives := paid * (100 - fee_percent) / 100
		settled["winner_paid"] = paid
		settled["seller_received"] = receives
		settled["fee_vnd"] = paid - receives
		settled["short_money"] = short_money
		settled["item_transferred"] = true
		_mark_state_dirty()
		return settled
	# Thiếu món ở người bán: hoàn paid, không ai nhận gì.
	w_entry["money"] = int(w_entry.get("money", 0)) + paid
	ledger[winner] = w_entry
	settled["missing_item"] = true
	_mark_state_dirty()
	return settled


# Mở 1 phiên đấu giá. Kiểm tra theo thứ tự: người bán đã hello,
# mã món không rỗng / ≤64 ký tự, giá khởi điểm là số nguyên
# 1.000..100 tỉ, thời gian 30..3600 giây (số nguyên), người bán
# chưa có phiên đang mở. Đạt thì tạo auction_id "auc-<ms>-<seq>",
# lưu vào auctions, broadcast auction_created cho mọi người.
func _handle_auction_create(from_peer: int, msg: Dictionary) -> void:
	if not players.has(from_peer):
		dropped_packets += 1
		return
	var seller_info: Dictionary = players[from_peer]
	var item_id := String(msg.get("item_id", "")).strip_edges()
	var start_price: Variant = msg.get("start_price", 0)
	var duration_s: Variant = msg.get("duration_s", 0)
	if item_id.is_empty():
		_auction_error(from_peer, "thieu-item-id")
		return
	if item_id.length() > MAX_ITEM_ID_LEN:
		_auction_error(from_peer, "item-id-qua-dai")
		return
	if not (start_price is int or start_price is float) \
			or int(start_price) != start_price \
			or int(start_price) < MIN_AUCTION_START_PRICE_VND \
			or int(start_price) > MAX_AUCTION_MONEY_VND:
		_auction_error(from_peer, "gia-khoi-diem-khong-hop-le")
		return
	if not (duration_s is int or duration_s is float) \
			or int(duration_s) != duration_s \
			or int(duration_s) < MIN_AUCTION_DURATION_S \
			or int(duration_s) > MAX_AUCTION_DURATION_S:
		_auction_error(from_peer, "thoi-gian-khong-hop-le")
		return
	for aid in auctions.keys():
		if int((auctions[aid] as Dictionary).get("seller_peer", -1)) == from_peer:
			_auction_error(from_peer, "da-co-dau-gia-mo")
			return
	# Vòng 72 (sổ cái): nếu người bán đã đồng bộ ledger thì chỉ
	# cho mở phiên bán món mình đang có trong ledger. Chưa đồng bộ
	# thì cho qua (hành vi cũ — client cũng chặn ở phía mình).
	var seller_id := String(seller_info["player_id"])
	var s_entry: Dictionary = ledger.get(seller_id, {})
	if not s_entry.is_empty():
		var s_items: Dictionary = s_entry.get("items", {})
		if int(s_items.get(item_id, 0)) < 1:
			_auction_error(from_peer, "khong-du-do-cho")
			return
	_auction_seq += 1
	var now := _now_ms()
	var auction_id := "auc-%d-%d" % [now, _auction_seq]
	var auction := {
		"auction_id": auction_id,
		"seller_peer": from_peer,
		"seller_player_id": String(seller_info["player_id"]),
		"item_id": item_id,
		"start_price": int(start_price),
		"current_bid": 0,
		"current_bidder_player_id": "",
		"created_at_ms": now,
		"ends_at_ms": now + int(duration_s) * 1000,
	}
	auctions[auction_id] = auction
	_mark_state_dirty()
	var created_msg := {"type": "auction_created"}
	created_msg.merge(_auction_public(auction))
	_broadcast(created_msg)
	auction_created.emit(_auction_public(auction))


# Đặt giá. Kiểm tra theo thứ tự: đã hello, phiên tồn tại + đang
# mở, người đấu không phải người bán, giá là số nguyên 1.000..
# 100 tỉ, giá đầu tiên >= giá khởi điểm, các giá sau >= giá hiện
# tại + 1.000đ. Đạt thì cập nhật current_bid / bidder, broadcast
# auction_bid cho mọi người + bao rieng cho nguoi vua bi vuot gia
# (auction_outbid — vong 102, offline thi xep hang doi).
func _handle_auction_bid(from_peer: int, msg: Dictionary) -> void:
	if not players.has(from_peer):
		dropped_packets += 1
		return
	var auction_id := String(msg.get("auction_id", "")).strip_edges()
	if not auctions.has(auction_id):
		_auction_error(from_peer, "khong-tim-thay-dau-gia")
		return
	var auction: Dictionary = auctions[auction_id]
	if int(auction.get("seller_peer", -1)) == from_peer:
		_auction_error(from_peer, "nguoi-ban-khong-duoc-dau-gia")
		return
	var amount: Variant = msg.get("amount", 0)
	if not (amount is int or amount is float) or int(amount) != amount \
			or int(amount) < MIN_AUCTION_START_PRICE_VND \
			or int(amount) > MAX_AUCTION_MONEY_VND:
		_auction_error(from_peer, "gia-dau-khong-hop-le")
		return
	var min_next: int = int(auction.get("start_price", 0))
	if int(auction.get("current_bid", 0)) > 0:
		min_next = int(auction.get("current_bid", 0)) + MIN_BID_INCREMENT_VND
	if int(amount) < min_next:
		_auction_error(from_peer, "gia-dau-thap-hon-gia-hien-tai")
		return
	# Vòng 72 (sổ cái): nếu người đấu đã đồng bộ ledger thì chỉ
	# cho đặt giá trong khả năng còn lại: money - reserved (+ giá
	# cũ của chính mình nếu đang dẫn đầu — tiền giữ hộ đó dùng lại
	# được cho giá mới). Chưa đồng bộ thì cho qua (hành vi cũ —
	# client cũng chặn ở phía mình bằng ví local).
	var bidder_id := String((players[from_peer] as Dictionary).get("player_id", ""))
	var b_entry: Dictionary = ledger.get(bidder_id, {})
	if not b_entry.is_empty():
		var prev_bid := int(auction.get("current_bid", 0))
		var prev_bidder := String(auction.get("current_bidder_player_id", ""))
		var reusable := 0
		if prev_bidder == bidder_id:
			reusable = prev_bid
		var available := maxi(int(b_entry.get("money", 0)), 0) - maxi(int(b_entry.get("reserved", 0)), 0) + reusable
		if int(amount) > available:
			_auction_error(from_peer, "khong-du-tien-cho")
			return
	# Giữ hộ tiền giá mới: giải phóng giá cũ cho người dẫn đầu cũ
	# (khác mình), cộng thêm phần chênh nếu chính mình nâng giá.
	var old_bidder := String(auction.get("current_bidder_player_id", ""))
	var old_bid := int(auction.get("current_bid", 0))
	if not old_bidder.is_empty() and old_bidder != bidder_id:
		_ledger_release(old_bidder, old_bid)
	if not b_entry.is_empty():
		if old_bidder == bidder_id:
			_ledger_reserve(bidder_id, int(amount) - old_bid)
		else:
			_ledger_reserve(bidder_id, int(amount))
	auction["current_bid"] = int(amount)
	auction["current_bidder_player_id"] = String((players[from_peer] as Dictionary).get("player_id", ""))
	auctions[auction_id] = auction
	_mark_state_dirty()
	var bid_msg := {"type": "auction_bid"}
	bid_msg.merge(_auction_public(auction))
	_broadcast(bid_msg)
	# Vong 102: bao cho nguoi vua bi vuot gia — online thi gui
	# ngay, offline thi xep hang doi _outbid_pending (xem
	# _send_outbid_notice). Tu nang gia cua chinh minh thi khong
	# bao (old_bidder == bidder_id).
	if not old_bidder.is_empty() and old_bidder != bidder_id:
		var outbid_msg := {"type": "auction_outbid"}
		outbid_msg.merge(_auction_public(auction))
		outbid_msg["old_bid"] = old_bid
		outbid_msg["old_bidder_player_id"] = old_bidder
		outbid_msg["new_bid"] = int(amount)
		outbid_msg["new_bidder_player_id"] = bidder_id
		_send_outbid_notice(old_bidder, _find_peer_by_player_id(old_bidder), outbid_msg)
	auction_bid_placed.emit(_auction_public(auction))


# Hủy 1 phiên CHƯA có ai đấu giá: chỉ người bán mới được. Có giá
# rồi thì không hủy được (phải chờ hết giờ) — tránh người bán rút
# món sau khi đã có người trả giá. Báo auction_cancelled cho mọi
# người.
func _handle_auction_cancel(from_peer: int, msg: Dictionary) -> void:
	if not players.has(from_peer):
		dropped_packets += 1
		return
	var auction_id := String(msg.get("auction_id", "")).strip_edges()
	if not auctions.has(auction_id):
		_auction_error(from_peer, "khong-tim-thay-dau-gia")
		return
	var auction: Dictionary = auctions[auction_id]
	if int(auction.get("seller_peer", -1)) != from_peer:
		_auction_error(from_peer, "khong-phai-nguoi-ban")
		return
	if int(auction.get("current_bid", 0)) > 0:
		_auction_error(from_peer, "da-co-gia-khong-huy-duoc")
		return
	auctions.erase(auction_id)
	_mark_state_dirty()
	_broadcast({"type": "auction_cancelled",
		"auction_id": auction_id, "reason": "nguoi-ban-da-huy"})
	auction_cancelled.emit(auction_id, "nguoi-ban-da-huy")


# Xin danh sách phiên đang mở: trả auction_list chỉ cho người xin
# (không broadcast), xếp theo ends_at_ms tăng dần (phiên sắp hết
# giờ lên trước).
func _handle_auction_list(from_peer: int, _msg: Dictionary) -> void:
	if not players.has(from_peer):
		dropped_packets += 1
		return
	var open_list: Array = []
	for aid in auctions.keys():
		open_list.append(_auction_public(auctions[aid] as Dictionary))
	open_list.sort_custom(func(a, b) -> bool: return int(a["ends_at_ms"]) < int(b["ends_at_ms"]))
	_send_to(from_peer, {"type": "auction_list", "auctions": open_list})


# Đóng mọi phiên đã hết giờ (gọi cuối mỗi poll): xóa khỏi auctions,
# ghi auction_log, broadcast auction_closed cho mọi người. Có người
# thắng: hammer = current_bid; quyết toán từ sổ cái server
# (_settle_auction, vòng 72) — người bán nhận 95% của số THỰC TRẢ
# (không còn nhận đủ theo hammer khi người thắng trả thiếu), phí =
# thực trả - nhận; thiếu món ở người bán thì hủy giao dịch. Không ai
# đấu giá: winner rỗng, hammer = fee = seller_receives = 0.
func _close_expired_auctions() -> void:
	var now := _now_ms()
	var due: Array = []
	for aid in auctions.keys():
		if int((auctions[aid] as Dictionary).get("ends_at_ms", 0)) <= now:
			due.append(aid)
	due.sort_custom(func(a, b) -> bool: return int((auctions[a] as Dictionary).get("ends_at_ms", 0)) < int((auctions[b] as Dictionary).get("ends_at_ms", 0)))
	for aid in due:
		if not auctions.has(aid):
			continue
		var auction: Dictionary = auctions[aid]
		auctions.erase(aid)
		_mark_state_dirty()
		var hammer := int(auction.get("current_bid", 0))
		var winner := String(auction.get("current_bidder_player_id", ""))
		var settled := _settle_auction(auction, hammer, winner)
		var receives := int(settled.get("seller_received", 0))
		var fee := int(settled.get("fee_vnd", 0))
		var closed := _auction_public(auction)
		closed["winner_player_id"] = winner
		closed["hammer_price"] = hammer
		closed["fee_vnd"] = fee
		closed["seller_receives_vnd"] = receives
		closed["ledger"] = settled
		closed["closed_at_ms"] = now
		auction_log.append(closed)
		while auction_log.size() > AUCTION_LOG_MAX:
			auction_log.pop_front()
		var closed_msg := {"type": "auction_closed"}
		closed_msg.merge(closed)
		_broadcast(closed_msg)
		# Vong 101: broadcast chi toi nguoi dang online — nguoi
		# ban / nguoi thang dang offline thi xep ban sao vao hang
		# doi _auction_pending de gui lai luc hello sau (mau
		# _trade_pending vong 100). Khong gui lap tu auction_log
		# (client ap trung neu da ap — xem _rebind_after_hello).
		var seller_id := String(auction.get("seller_player_id", ""))
		if not seller_id.is_empty() and _find_peer_by_player_id(seller_id) == -1:
			_send_auction_closed_notice(seller_id, -1, closed_msg)
		if not winner.is_empty() and winner != seller_id \
				and _find_peer_by_player_id(winner) == -1:
			_send_auction_closed_notice(winner, -1, closed_msg)
		auction_closed.emit(closed)


# Hủy các phiên đang mở của 1 peer đã rời (bye / mất kết nối) mà
# CHƯA có ai đấu giá — broadcast auction_cancelled cho mọi người.
# Phiên đã có giá thì giữ nguyên tới hết giờ (người thắng vẫn chốt
# được — món/tiền áp ở client khi nhận auction_closed).
func _cancel_auctions_for_peer(peer_id: int, reason: String) -> void:
	var doomed: Array = []
	for aid in auctions.keys():
		var a: Dictionary = auctions[aid]
		if int(a.get("seller_peer", -1)) == peer_id and int(a.get("current_bid", 0)) == 0:
			doomed.append(aid)
	for aid in doomed:
		auctions.erase(aid)
		_mark_state_dirty()
		_broadcast({"type": "auction_cancelled",
			"auction_id": String(aid), "reason": reason})
		auction_cancelled.emit(String(aid), reason)


# Hủy mọi đề nghị đang chờ có 1 bên là peer_id (bye / mất kết nối):
# báo trade_cancelled cho bên còn lại (nếu còn online).
func _cancel_trades_for_peer(peer_id: int, reason: String) -> void:
	var doomed: Array = []
	for tid in trades.keys():
		var t: Dictionary = trades[tid]
		if int(t.get("from_peer", -1)) == peer_id or int(t.get("to_peer", -1)) == peer_id:
			doomed.append(tid)
	for tid in doomed:
		var t: Dictionary = trades[tid]
		trades.erase(tid)
		_mark_state_dirty()
		var other := int(t.get("to_peer", -1)) if int(t.get("from_peer", -1)) == peer_id else int(t.get("from_peer", -1))
		if players.has(other):
			_send_to(other, {"type": "trade_cancelled",
				"trade_id": String(tid), "reason": reason})
		trade_cancelled.emit(String(tid), reason)


func _handle_bye(from_peer: int) -> void:
	if not players.has(from_peer):
		return
	_cancel_trades_for_peer(from_peer, "doi-phuong-mat-ket-noi")
	_cancel_auctions_for_peer(from_peer, "nguoi-ban-mat-ket-noi")
	var player_id := String(players[from_peer]["player_id"])
	players.erase(from_peer)
	_broadcast({"type": "presence", "players": presence_list()})
	peer_left.emit(from_peer, player_id)


# Client mới nối socket: chưa làm gì — chờ nó gửi hello.
func _on_peer_connected(_peer_id: int) -> void:
	pass


# Client mất kết nối: nếu đã đăng ký thì xóa khỏi presence +
# broadcast cho mọi người còn lại + hủy đề nghị trade đang chờ
# có mặt nó (báo cho bên còn lại).
func _on_peer_disconnected(peer_id: int) -> void:
	if not players.has(peer_id):
		return
	_cancel_trades_for_peer(peer_id, "doi-phuong-mat-ket-noi")
	_cancel_auctions_for_peer(peer_id, "nguoi-ban-mat-ket-noi")
	var player_id := String(players[peer_id]["player_id"])
	players.erase(peer_id)
	_broadcast({"type": "presence", "players": presence_list()})
	peer_left.emit(peer_id, player_id)
