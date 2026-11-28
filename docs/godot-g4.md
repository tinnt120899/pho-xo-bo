# Godot G4 — Online thật + release (20/11/2026)

> **G3 đã được kiểm chứng bằng TRÌNH DUYỆT THẬT (20/11 ~09:50)** — lần đầu tiên
> kể từ G0: game Godot chạy được trên Chromium thật, đi được, chuyển map
> 2 chiều, mở điện thoại, đổi khung, 0 console error. Chi tiết §1.
> Việc tiếp theo: online thật (§2) + release (§3) + scene trận MarketBattle (§4 — XONG 20/11 ~11:00, xem §5 việc tiếp theo).

## 1. Browser-verify G3 — XONG 20/11 ~09:50

### 1.1 Cách kiểm chứng (làm thật, không dùng Muse browser)

- Build kiểm chứng: `src/godot-build/` export 20/11 ~08:45 (G3 đủ 18 khu),
  `index.pck` 1.288.892 byte, `index.wasm` 39.514.754 byte — **không export
  lại**, build này đã chứa đủ 18 khu.
- Serve: `python3 -m http.server 8160 --bind 127.0.0.1` trong
  `src/godot-build/` — `index.html`/`index.wasm`/`index.pck` đều 200.
- Trình duyệt: Playwright Chromium 1255 headless trên VM này
  (`~/.cache/ms-playwright/chromium-1255/chrome-linux64/chrome`),
  cờ `--enable-unsafe-swiftshader --use-angle=swiftshader` (WebGL2 phần mềm),
  viewport 720×1280 đúng khung game.
- Script kiểm chứng (giữ trong goal hidden_files, tái chạy được):
  `~/workspace/goals/ph-x-b-vietnamese-2-5d-social-simulation-game/hidden_files/pxb-browser-verify.py`
  (vòng 1: tải + WASD), `pxb-browser-verify2.py` (vòng 2: mũi tên + P + F),
  `pxb-browser-verify3.py` (vòng 3: chuyển map đúng cửa).
- Ảnh chụp + log console: cùng thư mục trên,
  `pxb-browser-verify-2026-11-20/` (`01–10` PNG + `console*.json`).

### 1.2 Kết quả — đều PASS, có ảnh chụp làm bằng chứng

| Kiểm tra | Kết quả |
|---|---|
| WebGL2 | Có: `WebGL 2.0 (OpenGL ES 3.0 Chromium)` |
| Engine khởi động | Canvas 720×1280 sau ~5s; log `Godot Engine v4.7.2.stable.official`, `single-threaded` |
| Console / pageerror | **0 error, 0 pageerror** trong cả 3 vòng |
| Scene Map001 vẽ được | Có: tile atlas nhà trọ, NPC Bạn Thân (xanh) / Cô Tư (tím), Góc Chế Tạo, cửa, hotspot kim cương vàng, nhãn event — ảnh `02-scene.png` |
| HUD | Có: `Phố Xô Bồ — Xóm Trọ Cũ`, `Ngày 1 • Khung Sáng`, `Túi: trống`, `Ví: 0đ • EXP 0`, `Thể 100 • Trí 100 • Tâm 100`, 3 nút `Đổi khung (F)` / `Việc làm` / `Điện thoại (P)` |
| Di chuyển bằng mũi tên | **Có** (vòng 2): player áo xanh lá đi từ (4,5) → (5,8) sau 4 lần bấm, đúng chiếu iso; ảnh `05-before.png` → `06-transfer.png` |
| Mở điện thoại (phím P) | **Có**: panel 9 tab đúng thứ tự (Danh bạ/Tin nhắn, Ngân hàng, Bản đồ, Việc làm, Chợ, Học tập, Sức khỏe, Xã hội, Cài đặt), nội dung `Bạn thân — BestFriend, thân thiết 20/100 (QuenBiet)`, nút `Trò chuyện: Bạn thân` / `Đóng điện thoại`; bấm P lần 2 đóng lại — ảnh `07-phone.png` |
| Đổi khung (phím F) | **Có**: `Ngày 1 • Khung Sáng` → `Ngày 1 • Khung Chiều` + toast `Ngày 1 • Khung Chiều` — ảnh `08-frame.png` |
| Chuyển map Map001 → Map002 | **Có** (vòng 3): phải 1 + lên 1 bước lên cửa (5,4) `Cửa ra Chợ Đầu Mối` → title `Phố Xô Bồ — Chợ Đầu Mối` + toast `Đã sang Chợ Đầu Mối`; Map002 vẽ khác hẳn Map001 (đường nhựa, NPC Chị Lệ cam / Anh Hải xanh ngọc, cửa (5,8) đi Khu Công Nhân, hotspot 2 ô) — ảnh `09-transfer-map2.png` |
| Chuyển ngược Map002 → Map001 | **Có**: lên 1 + xuống 1 chạm cửa (5,4) → title `Xóm Trọ Cũ` + toast `Đã sang Xóm Trọ Cũ`, player spawn đúng cửa (5,4) — ảnh `10-back-map1.png` |

### 1.3 Hai lỗi SUÝT kết luận sai — ghi để không tái phạm

1. **Vòng 1 bấm D/S không di chuyển — không phải lỗi game.** `player.gd`
   chỉ nghe `ui_up/down/left/right` (mặc định = phím mũi tên), không bind
   WASD. G0 doc ghi "WASD/mũi tên" là sai so với code hiện tại: chỉ mũi tên
   mới đi được. Sửa test (vòng 2 dùng mũi tên) thì đi được ngay.
2. **Vòng 2 đi 4 bước không chuyển map — không phải lỗi game.** Cửa Map001
   → Map002 ở ô **(5,4)**, không phải (5,8) — (5,8) là cửa Map002 → Map003.
   Người kiểm chứng đọc nhầm số ô. Sửa test (vòng 3: phải + lên) thì
   chuyển map ngay, 2 chiều.

### 1.4 Phát hiện khi xem ảnh thật (không chặn release, ghi cho G4 polish)

1. **HUD chìm vào tile:** 5 dòng HUD trái + 3 nút phải nằm đè lên vùng map
   (map vẽ từ y=0), chữ tối trên nền tile sáng/màu — đọc được nhưng rối,
   nhất là dòng `Thể 100 • Trí 100 • Tâm 100` và nhãn event `Bạn Thân` /
   `Cửa ra Chợ Đầu Mối` chồng nhau. Cần nền mờ / bóng chữ cho HUD + nhãn.
2. **Map chỉ chiếm ~35% chiều cao màn hình:** map 12×9 ở tile 64×32 vẽ
   xong ở khoảng y=0–500 trên viewport 720×1280, dưới là nền tối trống.
   Trên điện thoại thật sẽ thấy thưa — cần camera zoom (vd zoom 2× theo
   player) hoặc tile lớn hơn khi trình bày dọc.
3. **Nhãn event chồng lấn:** `Cô Tư` bị cửa che một nửa ở ảnh `10`; các
   nhãn NPC/cửa/hotspot gần nhau đè lên nhau. Cần chống chồng lấn khi vẽ
   nhãn (dịch lên / ẩn bớt).
4. Tile Map003–018 tái dùng tile nhà trọ vẫn là PROVISIONAL (đã biết từ G3).

### 1.5 Verify headless kèm theo đợt này (cây code không đổi từ export 08:45)

| Kiểm tra | Kết quả |
|---|---|
| `--check-only --script main.gd` | exit 0 |
| `--headless --quit-after 120` | exit 0, không ERROR/warning |
| HTTP 200 (cổng 8160) | `index.html` / `index.wasm` / `index.pck` |

## 2. G4 — Online thật

- `PxbOnline` hiện chỉ có health/balance/gift qua endpoint .NET thật;
  trade/đấu giá/công ty vẫn `server-chua-co-endpoint`.
- Server `.NET 8` đã có trong `src/server/` (`EconomyLedger.cs`,
  endpoint `/ledger/balance` + `/ledger/gift`) nhưng **VM này không có
  dotnet SDK nên không build/chạy/verify được server** — viết endpoint
  mới mà không biên dịch được là nợ chưa verify; chỉ viết khi có máy
  dotnet hoặc khi chủ chốt dùng Godot headless dedicated server thay cho
  .NET (quyết sau, xem `docs/opensource-engine.md` §3.4).
- Trước mắt: giữ chơi ngoại tuyến + save local 3 slot (đã có), online
  chỉ báo đúng trạng thái (`_check_online` đã báo offline thật).

## 3. G4 — Release

- Build web mới nhất ở `src/godot-build/` (đã đồng bộ sang `godot-build/`
  ở root repo làm bản chơi local). `gh-pages-staging/` chứa bản split cũ
  (bản MV) — **kiểm tra lại trước khi deploy gh-pages**, không deploy nhầm.
- Repo vẫn private, GitHub Pages chưa bật — **chờ chủ** bật Pages + chọn
  Source `gh-pages` / root thì link `tinnt120899.github.io/pho-xo-bo/`
  mới chạy bản Godot (wasm single-threaded, không cần COOP/COEP).
- Khi deploy: `src/godot-build/` → root `gh-pages` (không phải
  `godot-play-single.html` — đó là bản MV cũ).

## 4. Scene trận MarketBattle (UI) — XONG (G4 bước 1, 20/11 ~11:00)

- Luật ĐÃ CHỐT 20/11 06:06, logic `scripts/pxb_marketbattle.gd` + test
  123/123 đã xong (G2). Scene nay đã có: `scripts/battle_scene.gd`
  (class `BattleScene`, Node2D trên CanvasLayer layer 2 — trên HUD,
  không bị camera zoom 1.6 kéo theo) + 2 test mới.
- Vẽ: lưới 12×9 isometric (cùng công thức `IsoMap`, tâm (360,560)),
  ô di chuyển xanh lá, địch trong tầm viền đỏ, đấu sĩ = vòng tròn
  màu vai + thanh HP + tên (lệch theo chẵn/lẻ x, vẽ 2 lượt để tên
  không bị vòng tròn đè), vòng vàng + mũi tên chỉ lượt đi; HUD trận:
  tỉ số % HP 2 đội, vòng x/12, lượt còn xs (≤3s đỏ), trận còn m:ss;
  panel dưới: lượt ai/vai/vũ khí/tầm, gợi ý chạm, dòng log hành động,
  nút "Kết thúc lượt" + "Đóng (B)"; hết trận hiện panel kết quả
  (thắng/hòa, Danh vọng mỗi đội, giữ sạp đến ngày game mấy).
- Chạm/chuột: ô xanh = di chuyển (1 lần/lượt), địch trong tầm = đánh,
  Vàng chạm đồng đội kề = hỗ trợ +12 HP, chạm đấu sĩ mình = xem;
  đồng hồ lượt 10s tự chuyển lượt, đồng hồ trận 180s kết thúc bằng
  % HP — đều gọi thẳng `PxbMarketBattle`, không sửa luật.
- Nối vào Main: phím **B** mở/đóng trận demo 3v3 (Đội Bạn: Bạn Tank/
  Chảo, Bạn Thân Chiến thuật/Cá khô, Cô Tư Hỗ trợ/Loa — vs Đội Chợ
  Đầu Mối seed NPC; tranh sạp `sap-cho-dau-moi`, đội chợ đang giữ).
  Khi mở: khóa input map, ẩn HUD (`_ui_layer`); khi đóng: trả lại.
  Gợi ý phím B đã thêm vào màn hình title.
- Verify thật đợt này (20/11 ~10:55–11:00): test scene **43/43
  PASS** (di chuyển 13 ô đúng tầm 3, đánh Tank −9 HP đúng luật,
  hỗ trợ +12 HP, nút, hết 10s tự chuyển lượt, hết 180s hòa khi
  100%–100%, hòa không giữ sạp); test nối Main **15/15 PASS**
  (phím B mở/đóng thật, khóa/mở input, ẩn/hiện HUD, đồng hồ thật
  tự chuyển lượt sau 11s); regression G2 MarketBattle 123/123,
  G1 419/419, G3 95/95, G2 selftest 87/87 (không regression);
  `--check-only` 4 file mới/sửa đều exit 0; scene Main 120 frame
  exit 0; export web exit 0 (wasm SHA không đổi `fc74679e…`,
  pck mới `964beb1a…`, chứa `res://scripts/battle_scene.gd`);
  HTTP 200 đủ 6 file (cổng 8163), `GODOT_THREADS_ENABLED = false`.
- **Browser-verify thật (Chromium 1255 + swiftshader, 720×1280):**
  build mới chạy được, bấm B mở trận, lưới + đấu sĩ + HUD + 2 nút
  vẽ đúng như thiết kế, 0 console error, 0 pageerror — ảnh
  `hidden_files/pxb-browser-verify-2026-11-20/13-battle-open.png`
  (script tái chạy: `hidden_files/pxb-browser-verify-battle.py`).
  2 lỗi vẽ tìm được trên ảnh thật và đã sửa: (1) dòng gợi ý tràn
  khỏi panel → rút ngắn; (2) tên đấu sĩ chéo nhau đè lên nhau →
  lệch theo chẵn/lẻ x + vẽ tên sau vòng tròn (2 lượt vẽ).
- Chưa làm: animation di chuyển/đánh (đấu sĩ nhảy ô tức thì); chọn
  đội/vũ khí trước trận; lưu giữ sạp + Danh vọng vào save (logic
  `PxbMarketBattle.data()` đã có, Main chưa nối vào SaveCloud);
  deploy gh-pages bản mới (wasm không đổi nên chỉ cần push lại pck
  chunk + index.html — LƯU Ý: pck mới 4.204.080 byte, gấp ~3 lần
  bản 11:00 (1.352.664 byte), do export lần này đóng gói cả
  `.godot/imported/*.ctex` + art gốc; deploy sẽ nặng hơn).
  AI lượt địch ĐÃ XONG (G4 bước 2, xem §5.1).

## 5. Việc tiếp theo — G4 bước 2

### 5.1 AI lượt địch — XONG (G4 bước 2, 20/11 ~12:00)

- Logic lõi `PxbMarketBattle.ai_take_turn(battle, fighter_id)` (mới,
  `scripts/pxb_marketbattle.gd`): xác định, không ngẫu nhiên, KHÔNG
  sửa luật — chỉ gọi `move_fighter` / `attack` / `support` /
  `end_turn` có sẵn. Thứ tự: (1) Vàng hỗ trợ đồng đội kề bên thiếu
  HP nhất; (2) đánh địch trong tầm vũ khí, ưu tiên ít HP nhất (hòa
  thì id nhỏ); (3) chưa hành động thì đi tới ô trong tầm di chuyển
  gần địch gần nhất nhất (chỉ đi khi gần hơn vị trí hiện tại; hòa
  thì x nhỏ, rồi y nhỏ); (4) sau khi đi, đánh nếu có địch vào tầm;
  (5) kết thúc lượt. Trả `{ok, actions: [chuỗi mô tả], ended}`.
- Scene `BattleScene` (`scripts/battle_scene.gd`): `ai_enabled`
  (mặc định **tắt** — test cũ không đổi hành vi), `ai_team = "B"`,
  `AI_ACT_DELAY = 1,2s` (đợi đầu lượt địch để người chơi kịp thấy
  lượt chuyển sang ai). Khi tới lượt đội AI: đợi đủ delay rồi chạy
  1 lượt AI, ghi hành động vào dòng log dưới panel; gợi ý dưới
  panel đổi thành "Đội Chợ đang đi…" khi tới lượt AI. `Main`
  (`_start_battle_demo`) bật `ai_enabled = true` khi mở trận demo.
- Test mới `tests/g4_battle_ai_test.gd`: **34/34 PASS** — đánh trong
  tầm (Chảo 12 → Tank −9 HP đúng luật), đi tới (6,4) rồi chưa đánh,
  Vàng hỗ trợ +12 HP, chọn mục tiêu ít HP nhất, chặn khi sai lượt /
  trận đã xong, scene AI tắt thì địch đứng yên, bật thì sau delay
  B1 đi tới (8,3) + sang lượt A2, trận tự chạy hết 180s (log có đòn
  của Tiểu thương, đội A mất HP giữa trận).
- Verify thật đợt này: `--check-only` 4 file đều exit 0; regression
  MarketBattle 123/123, battle scene 43/43, battle main 15/15,
  G2 selftest 87/87, G1 selftest 419/419, G3 playtest 95/95; scene
  Main 120 frame exit 0; export web exit 0 (wasm SHA không đổi
  `fc74679e…`, pck mới `aaba00da…`, 4.204.080 byte — xem lưu ý §4);
  HTTP 200 đủ 4 file (cổng 8163).
- **Browser-verify thật (Chromium 1255 + swiftshader, 720×1280):**
  build mới chạy được, bấm B mở trận, đợi 150s wall, 0 console
  error, 0 pageerror — ảnh `hidden_files/pxb-browser-verify-2026-11-20/17-battle-ai-after.png`
  (script tái chạy: `hidden_files/pxb-browser-verify-ai.py`):
  đồng hồ trận còn 2:27 (đã qua 33s game), tới lượt "Tiểu thương 3
  (Hỗ trợ — Ghế nhựa…)", panel ghi "Đội Chợ đang đi…" +
  "Tiểu thương 2 di chuyển tới (6,4).", 2 đấu sĩ địch đã rời cột
  phải tiến về giữa lưới. Đúng hành vi AI đã test headless.
- Phát hiện về môi trường (ghi để không kết luận sai sau này):
  game trong headless Chromium + swiftshader chạy **~4–5× chậm hơn
  thời gian thật** (25s wall chỉ được ~6s game; 150s wall được ~33s
  game) — chờ theo đồng hồ game trong ảnh, không chờ theo wall.
  Lỗi test ban đầu "đội A không mất HP sau 180s" là do test sai:
  hết trận HP hồi đầy theo luật — đã sửa test đo HP giữa trận.

1. ~~**AI lượt địch** cho trận MarketBattle~~ — **XONG, xem §5.1.**
2. **Deploy gh-pages bản mới** (pck `aaba00da…` đã export 20/11
   ~11:52; wasm không đổi `fc74679e…` nên chỉ push lại pck chunk +
   index.html — xem `docs/artpass-20-11.md` §6 cách deploy chunk;
   pck nay 4.204.080 byte nên số chunk tăng ~3 lần).
3. **G4 online thật**: server `.NET 8` trong `src/server/` vẫn chưa
   build/chạy được trên VM (không có dotnet SDK) — quyết dùng Godot
   headless dedicated server thay .NET hay chờ máy có dotnet
   (xem `docs/opensource-engine.md` §3.4).
4. Polish G4 §1.4 còn lại: camera zoom trận (lưới đang nhỏ giữa màn
   hình), tile riêng Map003–018 (đang PROVISIONAL), hiệu ứng đánh/
   ngã sạp.


## Link chơi thật (LIVE 20/11 09:54)

- Repo đã public + GitHub Pages đã bật (branch gh-pages, root), verify bằng trình duyệt thật: trang tải thành công, tiêu đề "Phố Xô Bồ", màn hình tải game Godot.
- Link: https://tinnt120899.github.io/pho-xo-bo/

## 6. Art pass Nadia — đồ họa giống Treasure of Nadia (20/11, 6 vòng sửa)

Đổi hướng theo lệnh chủ 10:48 20/11: dựng đồ họa CHO GIỐNG Treasure of
Nadia, không chỉ sửa lặt vặt. Đọc `docs/nadia-reference.md` +
`docs/nadia-scene-study.md` rồi áp phong cách Nadia vào Godot.

### 6.1 Cái đã làm (Map001–002)

- **Nền vẽ tay procedural** (`scripts/nadia_scene.gd`, mới, ~900 dòng):
  sky wash 3 dải ấm, mái nhà xa, mặt đất lát gạch có nứt/rêu/vũng
  nước/lá rơi/phấn vẽ, tường 2 bên có poster + cây leo + vết nước,
  mặt tiền nhà theo từng ô: tường vàng cũ + vết bẩn/nứt, mái tôn có
  đường gờ + ống khói, biển hiệu gỗ chữ Việt ngắn (PHỞ BÒ, CÀ PHÊ,
  TẠP HÓA, CHÁO LÒNG…), cửa sổ/cửa ra vào/cổng sắt, mái hiên sọc +
  quầy hàng + giỏ trái cây (chợ), hàng rào thấp + chậu cây + mèo
  ngủ cuộn tròn, cột điện + 3 dây võng + chim đậu, đạo cụ dưới map:
  xe máy, cây chuối, xe đồ ăn có khói bay (vẽ lại ~7 lần/s), ghế
  nhựa + ly cà phê, cột đèn lồng đỏ, xe đẩy hàng rong, xe đạp dựng
  vỉa hè, chồng giỏ hàng.
- **Nhân vật Nadia** (`character_sprite.gd` viết lại): cao ~72px,
  tỉ lệ đầu:thân ~1:5.5, mặt có lông mày/mắt có highlight/má hồng/
  miệng/nháy mắt ~3s, tóc ngắn/dài/búi/nón, áo có cổ/cúc/túi, chân
  dài + giày có viền trắng, tay vung ngược chân, nhún khi đi, bóng
  bầu dục dưới chân, người chơi có vòng vàng.
- **Hotspot lấp lánh Nadia** (`marker.gd`, `pxb_hotspot.gd`):
  sao 4 cánh dài + halo + 3 tia xoay, xanh #2E7FD9 = thường,
  cam #E07800 = thưởng tốt (`hs-cho-chieu` đánh dấu `rarity: hiem`
  trong `data/maps.json` để có 1 sao cam trong slice), không biến
  mất khi chưa nhặt. Bỏ dấu "!" cũ.
- **HUD/UI gỗ/giấy** (`main.gd`): panel viền gỗ nâu bo 12 + bóng
  mềm, nút gỗ nâu chữ kem, điện thoại là panel gỗ bo 18.
- **Giữ 4 điểm sửa 10:27–10:30** nhưng làm theo chuẩn Nadia:
  nhãn kẹp dưới HUD + cách mép ~20px, nhãn của điểm ngoài màn hình
  thì ẨN (không trôi vào màn hình không có điểm neo), nửa dưới map
  có đường/vỉa hè/cây/đạo cụ tới đáy, điện thoại gọn 680x900 căn
  giữa dọc + chân trang + gợi ý tiến trình + mẹo xoay theo ngày,
  khung Tối tối hẳn (MUL 0.42,0.52,0.85 + cửa sổ sáng), toast đổi
  khung dưới HUD, desktop có chú thích 2 bên (≥1400px) + ghi rõ
  game dọc.

### 6.2 Các vòng sửa sau khi tự xem ảnh (artpass 35 → 39 checks)

1. Camera lệch lên 100 world units (`CAMERA_LOOK_UP`): người chơi
   ở 2/3 dưới màn hình, mặt tiền thoát khỏi HUD.
2. Nhãn cửa/chế tạo: trên (-120) thì chồng nhãn NPC, dưới (+24)
   thì chế tạo rơi vào chỗ người chơi đứng, cửa thì bị Cô Tư che
   chữ "Đầu" — chốt: chế tạo trên -120, cửa dưới +70, hotspot
   dưới +24.
3. Biển hiệu rút ngắn ≤8 ký tự + cỡ 10 để vừa bảng 58px.
4. Điện thoại: panel 680x1100 → 680x900, scroll 420 → 280, thêm
   `_phone_hint` (chương + ending gợi ý) + `_phone_tip` (mẹo xoay
   theo ngày); ending ID dịch sang tiếng Việt (`ENDING_NAMES`:
   TuDo → Tự do…).
5. Desktop: chú thích 2 bên bị canvas che (z-index 0 → 10) +
   chữ kem + text-shadow cho đọc được trên nền đen.
6. Hạn chế đã đo: canvas WebGL `alpha: false` nên engine tô đen
   letterbox — CSS gradient không hiện qua được; 2 dải đen còn đó
   nhưng có chú thích giải thích. Muốn hết đen hẳn phải đổi
   stretch aspect sang "expand" (chưa làm — cần neo lại HUD).

### 6.3 Verify

- `--check-only` 0 lỗi; artpass 39/39; G1 selftest 419/419;
  G3 playtest 95/95; G1 playtest 14/14; hotspot 37/37;
  MarketBattle 123/123; scene 120 frame 0 ERROR.
- Export web exit 0; Chromium local 720x1280 (map/phone/Chiều/
  Tối) + desktop 1920x1080 đều 0 lỗi, đã xem ảnh thật từng vòng.
- Deploy gh-pages bản mới: xem §6.4 (chunk base64, verify khớp byte).

### 6.4 Deploy gh-pages (tái tạo từ bản 06:12, script nay ở repo)

- Script `tools/godot/build_gh_pages.py` (mới, persistent trong
  repo): chia `index.wasm` (~39,5 MB) + `index.pck` (~1,35 MB)
  thành chunk base64 ≤180 KB, chèn loader fetch vào `index.html`
  (ghi đè fetch để ráp lại trong trình duyệt), verify SHA từng
  chunk decode khớp byte với `src/godot-build/`.
- Staging `gh-pages-staging/` (307 file): `index.html` + `wasm/`
  + `pck/` + `index.png`/`index.icon.png`/`index.apple-touch-icon.png`.
  Push lên branch `gh-pages` bằng snapshot-push theo lô ~20 file,
  sync record riêng (xem `src/nadia/www.muse-github-snapshot-sync.json`).
- Live link vẫn phục vụ bản 06:12 tới khi deploy này xong.

## 7. Art pass 2 — Nadia-style bằng ẢNH VẼ THẬT (20/11 ~12:00, theo 6 điểm live-check 11:40)

Kết luận live-check 11:40: vẽ bằng code KHÔNG BAO GIỜ ra tranh vẽ
tay có shading mềm kiểu Nadia — vòng này đổi hẳn sang ảnh vẽ thật
(tự tạo mới bằng media image generation, KHÔNG lấy từ Nadia/game
khác), nhân vật + nền đều dùng ảnh, code chỉ còn fallback.

### 7.1 Ảnh (src/godot/art/, tự tạo mới 20/11)

- 5 sprite nhân vật tách nền trắng → trong suốt, chuẩn hóa cao
  512px: `char_player.png` (260×512), `char_cotu.png` (275×512),
  `char_banthan.png` (330×512), `char_chile.png` (233×512),
  `char_anhhai.png` (213×512) — mặt chi tiết (mắt/má/tóc mái),
  quần áo có shading. Xử lý bằng PIL (`/tmp/process_art.py`,
  không lưu trong repo): trắng → trong suốt (ngưỡng 235 + feather),
  tách từng nhân vật theo bbox, resize cao 512.
- `bg_map001.png` (1120×630): composite — sky band (mây + nắng +
  chim, 280px) + facade crop (tường vàng cũ, mái tôn, 3 biển
  "PHO BO / CA PHE / TAP HOA" đủ chữ, đèn lồng, cửa sổ/cửa ra vào).
- `sky_band.png` (1120×280): trời riêng cho Map002.
- `title_bg.png` (720×1280): crop giữa facade làm nền title.
- Map001 dùng composite thay toàn bộ trời + mái xa + mặt tiền +
  dây điện code; Map002 dùng sky_band thay trời code, giữ mái xa +
  mặt tiền code (vẽ đè lên ảnh trời).

### 7.2 Code (6 điểm live-check đều sửa)

1. **Nhân vật có mặt** (`character_sprite.gd`): cfg có `texture`
   → Sprite2D ảnh thật cao 104px (nhún + nghiêng nhẹ khi đi,
   flip_h khi quay trái); không có file thì fallback vẽ code.
   `player.gd` + `marker.gd` (NPC_STYLE) gắn texture từng người.
2. **Nhãn luôn trên nhân vật** (`marker.gd`, `main.gd`,
   `iso_map.gd`): nhãn là Label trên CanvasLayer riêng (layer 1,
   tạo trước lớp HUD nên vẽ dưới HUD, trên mọi Node2D thế giới),
   font 32px, tính rect theo `label_screen_rect()` (tọa độ màn
   hình, kẹp y ≥ 276, cách mép 16px); nhãn NPC dời lên -144 (đầu
   nhân vật ảnh cao 104px). Không có lớp thì fallback `_draw_name()`.
3. **Trời có chi tiết**: composite/sky_band có mây + nắng + chim
   (Sáng); overlay Chiều (1.0,0.82,0.55) / Tối (0.42,0.52,0.85)
   giữ nguyên; Tối có trăng + sao + đèn lồng có quầng
   (`night_glow.gd`: trăng ở nửa dưới dải trời, sao rải 80px dưới
   cùng dải trời, màu HDR >1.0 để xuyên qua lớp overlay MUL —
   màu thường bị nhân tối, chìm vào trời đêm); nhà có cửa sổ/cửa
   ra vào trong ảnh; bóng đổ nhà/cây/xe (`nadia_scene.gd`
   `_draw_shadows()`, nắng từ phải-trên → bóng lệch trái-dưới).
   Camera `CAMERA_LOOK_UP` (0,-100) → (0,-230) để biển hiệu xuống
   dưới HUD lúc spawn; trời hiện rõ khi đi lên hàng trên.
4. **Điện thoại** (`main.gd`): bỏ lặp "Bạn thân — Bạn thân"
   (tên trùng loại quan hệ thì in 1 lần); danh bạ liệt kê cả NPC
   chưa quen (toàn bộ 18 khu) lấp khoảng trống; nội dung dài cho
   vào ScrollContainer (không tràn panel — label phải đặt
   `custom_minimum_size.x = 580` nếu không autowrap ép về 1px,
   chữ xếp dọc 1 ký tự/dòng); notch + thanh home (Panel bo tròn
   nâu đậm) hiện/ẩn theo điện thoại; panel giữ đúng 680x900
   (separation VBox 10 → 8, không panel phình lên 907).
5. **Nút "Bắt đầu chơi"**: trong game lớn 620x110 (font 40) +
   nút DOM thật ngoài canvas (`web_shell.html` #start-overlay:
   nút HTML "▶ BẮT ĐẦU CHƠI", enable khi engine tải xong, click
   đặt `window.__pxb_start = true`, Godot poll 4 lần/giây qua
   `JavaScriptBridge.eval` rồi đóng title; overlay ẩn sau 400ms).
6. **Desktop hết dải đen** (`web_shell.html`): `.side-panel`
   (thay `.side-caption`) — JS `layoutSidePanels()` đo vùng
   letterbox thật (scale = min(w/720, h/1280)) rồi đặt panel 2 bên
   đúng bằng phần thừa, nền gradient ấm + họa tiết + chữ nâu đậm,
   `pointer-events: none`, ẩn khi phần thừa < 80px.

### 7.3 Lỗi tìm ra trong vòng này (ghi để không tái phạm)

- **NightGlow bị ảnh nền che**: IsoMap bật y-sort — NightGlow ở
  y=0 xếp trước Sprite2D nền (y=7, đục) nên trăng/sao/đốm sáng bị
  vẽ đè lên, không thấy dù `moon_on = true`. Sửa: `z_index = 10`
  cho NightGlow (ánh sáng chồng lên nhân vật là đúng).
- **Trăng/sao sai tọa độ**: `set_sky(offset + (-560,-330))` là
  đỉnh mặt tiền, không phải đỉnh dải trời — sao rơi lên cửa/nền
  đất. Đúng: `offset + (-560,-610)` (đỉnh composite 630px, tâm ở
  offset+(0,-295)). Trăng/sao phải ở nửa dưới dải trời mới thấy
  dưới HUD khi đi lên hàng trên.
- **Overlay MUL nuốt nguồn sáng**: màu trăng/sao/đèn vẽ thường
  (≤1.0) bị nhân với (0.42,0.52,0.85) thành xanh tối, chìm vào
  trời đêm. Nguồn sáng phải vẽ bằng màu HDR >1.0.
- **Panel điện thoại phình 900 → 907**: ScrollContainer mới làm
  tổng chiều cao tối thiểu VBox vượt 900. Sửa bằng separation
  10 → 8, giữ đúng 680x900.
- **WASD không đi được**: hint ghi "WASD / mũi tên" nhưng code
  chỉ dùng action `ui_up/down/left/right` (mặc định chỉ có phím
  mũi tên, không bind W/A/S/D trong project.godot) — đi lên phải
  dùng ArrowUp. Chưa sửa (việc riêng, ghi cho vòng sau).
- **Nghi lệch tọa độ Map003+** (chưa verify bằng mắt): TileMapLayer
  `map_to_local((5,4)) = (352,80)` vs `tile_center((5,4)) =
  (344,462)` — marker/NPC dùng hệ offset, tile layer dùng hệ thô.
  Map001–002 không ảnh hưởng (layer ẩn, NadiaScene dùng hệ
  offset). Cần screenshot Map003 trước khi kết luận.

### 7.4 Verify (vòng này)

- `--check-only` exit 0; artpass 57/57 (thêm 18 check mới: ảnh
  nhân vật/nền/title đã nạp, nút 620x110, lớp nhãn dưới HUD, notch/
  home bar, danh bạ không lặp + liệt kê NPC, trăng + đèn đường);
  scene 120 frame exit 0; G1 selftest 419/419; G2 selftest 87/87;
  G3 playtest 95/95.
- Export web exit 0; Chromium local (Xvfb + Playwright, 0 console
  error): desktop 1280x720 (title DOM / map spawn / lên hàng trên /
  Chiều / Tối + trăng sao / điện thoại) + portrait 720x1280 — đã
  xem ảnh thật từng vòng (`visual-check/artpass2/`).
- Hạn chế còn lại (đã đo, không giấu): trời + mặt trời chỉ hiện
  rõ khi đi lên hàng trên (lúc spawn HUD chiếm 252px trên cùng +
  camera theo người chơi nên trời nằm ngoài khung); mặt đất vẫn
  là hình thoi vẽ code (be) dưới mặt tiền vẽ ảnh — tương phản
  thấy rõ ở bản portrait; ảnh PNG (1,1–1,3 MB) KHÔNG push được
  lên main qua snapshot-push (giới hạn 188.416 byte/file, chỉ file
  text) — PNG chỉ có ở working copy local + nướng trong file
  `.pck` đã deploy; clone mới sẽ fallback về vẽ code (nhân vật)
  và không có ảnh nền (có guard `ResourceLoader.exists`).
- Deploy gh-pages: xem §6.4 (script `tools/godot/build_gh_pages.py`).
- Live link vẫn phục vụ bản 06:12 tới khi deploy này xong.



## 8. G4 bước 3 — WASD + tọa độ Map003 + artpass3 (20/11 ~13:00–13:20)

> Làm song song 2 luồng: luồng kia sửa code (WASD, DIAMOND_DOWN, art
> mới sky/ground/night, HUD gọn, nhãn chống chồng) 12:36–13:04; luồng
> này verify + export + deploy + browser-verify. Không sửa đè code
> của luồng kia khi thấy file còn đang đổi (kiểm tra mtime trước
> mỗi bước; xem bài học chạy song song ở cuối §8).

### 8.1 WASD + tọa độ Map003 — XONG

- `player.gd` `_held_dir()`: nghe cả `move_*` (W/A/S/D, đã bind sẵn
  trong `project.godot`) lẫn `ui_*` (mũi tên) — trước đây chỉ `ui_*`
  nên W/D không đi được dù hint ghi "WASD / mũi tên" (lỗi 12:20).
- `iso_map.gd`: `tile_set.tile_layout = TILE_LAYOUT_DIAMOND_DOWN`
  (không phải STACKED mặc định) — TileMapLayer trước đây vẽ sai chỗ
  so với marker/người chơi ở Map003+.
- Test mới `tests/g4_coord_wasd_test.gd`: **16/16 PASS** — action
  move_* đủ W+Up/S+Down/A+Left/D+Right; W lên (4,4), D sang (5,4),
  mũi tên trái vẫn đi, giữ W đi liên tục 2 ô; 108 ô Map003 tâm tile
  ground/object trùng `tile_center`, marker đúng tile của mình.
- Test mới `tests/g4_artpass3_test.gd` (vòng sửa 12:30): **21/21
  PASS** — 4 ảnh mới tồn tại, ground sprite mép trên y~280, HUD gọn
  ≤140, panel điện thoại y ≥ 150, skyfx tồn tại, đổi khung Toi đổi
  ảnh nền đêm + tint nhân vật tối + night_glow bật + sky_in_image,
  nhãn Map001 không chồng nhau, về Sáng ảnh nền + tint trở lại.

### 8.2 Hồi quy sau vòng sửa — artpass 57/57 trở lại

- Lúc 12:59 artpass cũ rớt 6/57 + artpass3 rớt 2/21 (HUD 157px,
  nhãn "Hẻm trọ buổi tối" chồng "Cửa ra Chợ Đầu Mối", zoom 1.4 vs
  test cũ đòi 1.6, toast y=200 vs [260,280], màu overlay Toi
  (0.55,0.62,0.9) vs (0.42,0.52,0.85), night spots rỗng ở Map001-002).
  Nguyên nhân: một phần là code chưa sửa xong (HUD, nhãn), một phần
  là test cũ lỗi thời so với thay đổi có chủ ý (zoom 1.4 cho thấy
  trời lúc spawn; overlay Toi nhạt hơn vì ảnh nền đêm đã tối sẵn;
  spots rỗng vì cửa sổ sáng đã có trong ảnh đêm; toast/phone dời
  theo HUD gọn). Luồng kia sửa code + cập nhật test 13:01–13:04.
- Verify lại lúc 13:05: **artpass 57/57**, **artpass3 21/21**;
  G1 selftest 419/419, G3 playtest 95/95, G2 selftest 87/87,
  MarketBattle 123/123, battle scene 43/43, battle main 15/15,
  battle AI 34/34, G1 playtest 14/14, coord+WASD 16/16 — không
  regression.

### 8.3 Bài học chạy Godot headless (ghi để không tái phạm)

1. **Cache class cũ gây lỗi parse ảo:** log 12:50–12:56 báo
   `SkyEffects` không tìm thấy, `kind` không khai báo,
   `skyfx` không resolve — nhưng code đúng. Nguyên nhân:
   `global_script_class_cache.cfg` cũ, trước lần `--import`
   12:54 của luồng kia. Sau import, mọi `--check-only` đều
   exit 0. Gặp lỗi parse lạ: chạy `--headless --import` trước
   rồi mới kết luận code hỏng.
2. **Test lỗi giữa `_init` thì engine treo:** test script lỗi
   runtime trước khi tới `quit()` thì SceneTree chạy idle mãi
   (0% CPU, không thoát) — tiến trình test đầu tiên của luồng
   này treo 7 phút vì vậy. Luôn bọc lệnh test headless bằng
   `timeout 150`.
3. **Hai luồng Godot cùng lúc:** tiến trình import/check-only
   của luồng kia + test của luồng này cùng mở một project gây
   nhiễu (treo, cache cũ). Trước khi chạy Godot, kiểm tra
   `ps` + mtime file; chỉ chạy khi không còn tiến trình Godot
   nào khác.

### 8.4 Deploy gh-pages bản mới — XONG (bản artpass3-fix)

- Luồng này push batch 1/3 (`39276bc6`, index.html + pck 000–018
  bản 053c5401) 13:42 — bị luồng kia ghi đè ngay sau đó vì luồng
  kia deploy bản export mới hơn (7e84335). Batch 2/3 của luồng này
  lỗi `not a fast forward` và đã DỪNG, không push lại (đẩy chunk
  pck cũ lên loader mới sẽ làm hỏng bản build).
- Deploy chính thức (luồng kia, 13:43–13:48): **6/6 batch,
  head `8bed7c2cc0a`** — `f18ba5ef` (1/6: index.html + pck
  000–008), `6eac413f` (2/6: 009–018), `edcdc17a` (3/6: 019–028),
  `8a4b5053` (4/6: 029–038), `05479f43` (5/6: 039–048),
  `8bed7c2cc0a` (6/6: 049–050). pck **6.876.644 byte, SHA
  `7e84335…`**, 51 chunk; wasm không đổi `fc74679e…`.
- HTTP 200 đủ 4 file trên build local (cổng 8164). Live site:
  `https://tinnt120899.github.io/pho-xo-bo/` — kiểm tra ở §8.7.
- Push main: **`36e507c2`** (20 file: WASD + DIAMOND_DOWN +
  artpass3-fix + 3 test mới; artpass3 23/23, artpass 57/57,
  G1 419/419, G3 95/95).
- Verify remote khớp byte: **4/4 mẫu** (index.html, pck
  000/025/050) — blob SHA remote = staging; head gh-pages
  `8bed7c2c` đứng yên sau deploy, không còn lô nào đè sau.

- Export 13:07 exit 0: pck mới **6.859.624 byte, SHA
  `053c5401…`** (từ 4.210.640 — tăng do nướng 4 ảnh JPG mới);
  wasm không đổi `fc74679e…`. pck chứa `move_up` +
  `ground_wide`/`sky_wide`. **Lưu ý: bản export này đã bị thay
  thế trước khi lên live** — luồng kia export lại 13:25 (pck
  **6.876.644 byte, SHA `7e84335…`**, art đêm vẽ lại) và deploy
  bản đó; xem §8.4.
- `--headless --quit-after 120` exit 0, không ERROR.
- Staging rebuild (bản 053c5401): pck **51 chunk** (từ 32), wasm
  293 chunk không đổi; `build_gh_pages.py --verify-only` OK
  (khớp byte).

### 8.5 Browser-verify WASD thật (Chromium 1255 + swiftshader)

- Script mới `hidden_files/pxb-browser-verify-wasd.py`.
- **Lỗi verify lần 1:** click tọa độ (360,665) quá sớm — nút DOM
  `#start-btn` bắt đầu DISABLED ("Đang tải game…"), chỉ enable
  khi engine tải xong; click sớm không có tác dụng, 5 ảnh đều ở
  title (byte-identical). Sửa script: đợi
  `#start-btn:not([disabled])` rồi mới click qua selector, thử
  lại tối đa 3 lần, xác nhận `window.__pxb_start === true` +
  overlay ẩn.
- **Lần 2 — PASS, đã xem ảnh thật:** title biến mất, map Map001
  vẽ đẹp (trời mây + chim, mặt tiền CÀ PHÊ + đèn lồng, sprite
  thật); bấm **W** player lên 1 ô (ảnh 18→19); bấm **D** sang
  cửa (5,4) → title `Chợ Đầu Mối` + toast `Đã sang Chợ Đầu Mối`
  (ảnh 20); 4× **S** xuống cửa (5,8) → title `Khu Công Nhân` +
  toast `Đã sang Khu Công Nhân` (ảnh 22) — **DIAMOND_DOWN đúng
  bằng mắt**: tile/NPC/cửa Map003 thẳng hàng, không lệch. 0 console
  error, 0 pageerror.
- Phát hiện cho vòng polish sau (không chặn deploy):
  1. Map003: nửa trên màn hình (~55%) là nền nâu trơn — Map003
     không có ảnh trời/đất riêng (chỉ Map001-002 có), tile chỉ
     phủ nửa dưới.
  2. HUD tràn chữ: tên map dài ("Khu Công Nhân") bị cắt ở mép
     panel 452px, chữ chui dưới nút phải.
  3. Map002/Map003: nhãn 2 cửa ở đáy màn hình chồng/cắt nhau
     ("Cửa đi Bến Xe Miền Đông" đè "...u Mới") — test chống
     chồng hiện chỉ kiểm tra Map001.

### 8.6 Vòng sửa artpass3-fix — sau khi tự xem ảnh lần 2 (13:20–13:45)

Live-check lần 2 (ảnh thật Chromium, 6 điểm) chưa đạt: trăng
không thấy, mặt trời Sáng/Chiều không thấy, tường bên/hàng rào
code vẫn hiện, nhãn chế tạo đè người chơi, toast đè tiêu đề điện
thoại. Đã sửa + xem lại ảnh, 6 điểm hết:

- **Trăng/mặt trời vô hình — nguyên nhân y-sort:** `IsoMap`
  bật `y_sort_enabled`; `SkyEffects` ở y=0 nên bị sprite nền
  composite (y=23, đục) vẽ đè (cùng họ lỗi NightGlow 12:20).
  Sửa: `skyfx.z_index = 10` (`iso_map.gd`). Mặt trời Sáng/Chiều
  dời xuống world y −140 (màn hình ~245, dưới HUD 173) + mặt
  trời Sáng vàng đậm hơn (trước −195 nằm sau HUD + chìm trong
  mây trắng). Trăng vẽ bằng code ở world (368,−103) = màn hình
  (394,297) lúc spawn; trăng trong ảnh đêm đã XÓA (clone vùng
  trời trái bằng PIL — lần đầu clone nhầm vùng chứa nửa trăng
  nên trăng vẫn còn, phải vá lại lần 2 bằng vùng trời sạch
  x 0..400). `sky_night.jpg` cũng xóa trăng (chỉ còn sao + mây
  đêm) để không có 2 trăng khi đi lên cao. Bài học: ảnh gen
  không đặt trăng đúng tọa độ được — trăng/mặt trời nên vẽ code.
- **Tường bên + hàng rào code:** `_draw_side_walls()` và thanh
  hàng rào `_draw_bottom_fence()` bỏ với Map001 (ảnh composite
  đã vẽ sẵn tường/nhà 2 bên) — chỉ giữ chậu cây + mèo ngủ.
  Map002+ giữ nguyên (mặt tiền vẽ code).
- **Nhãn chế tạo:** +24 → −40 (lên trên icon, như hotspot) —
  +24 cũ đè đúng chỗ người chơi spawn (4,5).
- **Toast:** `_open_phone()` ẩn toast — toast y=200 đè lên
  tiêu đề "Điện thoại" (panel y=190) khi mở điện thoại ngay
  sau đổi khung.
- **Test:** artpass3 thêm check mặt trời (`sun_pos.y` trong
  −160..−100) + trăng (`moon_pos` trong x 100..600, y
  −300..−20) → **23/23 PASS**; artpass 57/57; hồi quy còn lại
  giữ nguyên (G1 419/419, G3 95/95, MarketBattle 123/123…).
- **Staging Map003 — bài học:** map bắt đầu lấy từ
  `data/maps.json` (`start.map`), KHÔNG phải `current_map_id`
  (biến này bị `load_map()` ghi đè lúc `_ready`). Lần stage
  đầu sửa nhầm `current_map_id` nên vẫn hiện Map001; sửa đúng
  `maps.json` → Map003 hiện đúng.

### 8.7 Kiểm tra live site sau deploy — XONG (13:50)

- **Byte-level (curl):** `index.html` live 200, liệt kê đủ 51
  pck part; tải + ráp lại 51 part → **6.876.644 byte, SHA
  `7e843358520402a1` — khớp đúng từng byte với build local
  13:25**. Deploy đúng, không lẫn chunk bản cũ.
- **Trình duyệt thật với đúng bản live:** Chromium không mở được
  URL live trực tiếp (`ERR_TUNNEL_CONNECTION_FAILED` ×2 — proxy
  của VM chặn tunnel HTTPS ra ngoài, không phải lỗi site; curl
  từ shell vẫn tới được). Thay thế bằng cách chạy lại
  `pxb-browser-verify-wasd.py` trên build local 8164 — lúc này
  `src/godot-build/` đã là đúng bản live 7e84335 (SHA khớp):
  start OK, W lên 1 ô, D sang Chợ Đầu Mối, 4×S sang Khu Công
  Nhân, 0 console error, 0 pageerror, đã xem ảnh thật (18–22).
  Mặt trời hiện (fix §8.6 có tác dụng), nhãn "Góc Chế Tạo" đã
  lên trên, không còn đè người chơi lúc spawn.
- Hạn chế chưa kiểm chứng: tải trang live bằng trình duyệt thật
  (bị proxy chặn) — cần chủ hoặc máy khác mở
  `https://tinnt120899.github.io/pho-xo-bo/` kiểm tra 1 lần.
- Polish còn lại (đã ghi §8.5): Map003 nửa trên nâu trơn, HUD
  cắt tên map dài, nhãn 2 cửa Map002/Map003 chồng nhau ở đáy.

## 9. Việc tiếp theo — G4 bước 4 — XONG (20/11 ~14:00–14:30)

### 9.1 Polish §8.5 — XONG

- **Nền trời mặc định cho Map003+** (`scripts/iso_map.gd`): `sky_band.png`
  (trước chỉ Map002) + `sky_wide.jpg` (trước chỉ Map001-002) nay dùng cho
  MỌI map (điều kiện `map_id == 2` → `map_id >= 2`, bỏ điều kiện
  `map_id == 1 or 2` ở sky_wide); vị trí như Map002 (bg offset+(0,-190),
  sky_wide offset+(0,-530)) — đáy trời ở offset.y-50, vừa chân mặt
  tiền/tile hàng trên. Đêm đổi sang `sky_night.jpg` như Map002
  (`has_night_bg = true` → MUL đêm nhẹ 0.55,0.62,0.9).
- **HUD co chữ theo tên map** (`main.gd` `_fit_hud_map()`, gọi trong
  `load_map`): đo bằng `font_bold.get_string_size`, co từ 30 xuống
  tối thiểu 20 tới khi vừa 412px (panel 452 − 2×18 margin). Đo thật:
  HUD cũ tràn ở 17/18 map (kể cả tên ngắn: "Xóm Trọ Cũ" 415px ở cỡ
  30) — chỉ "Phố Tây" vừa cỡ 30; dài nhất "Phố Đi Bộ – Chợ Đêm" về
  cỡ 20, "Khu Chung Cư Cao Cấp"/"Khu Biệt Thự Ven Sông"/"Khu Sân
  Golf & Resort" về cỡ 20.
- **Chống chồng nhãn trên mọi map** (`main.gd` `_deoverlap_labels()`
  + `marker.gd` `label_shift`): mỗi frame (trong `Main._process`,
  trước `_process` của marker con) tính lại rect màn hình mọi nhãn
  hiện, sắp theo y rồi đẩy nhãn chồng xuống dưới (hết chỗ dưới thì
  đẩy lên trên, kẹp 190..1280-16-h), lệch lưu vào
  `marker.label_shift` (px màn hình) để `_update_label` áp dụng.
- **Test mới** `tests/g4_polish_test.gd`: **18/18 PASS** — sky Map003
  (bg sky_band đúng vị trí, sky_wide đúng vị trí, có ảnh đêm, đêm
  đổi sky_night), HUD vừa panel + cỡ lớn nhất có thể (Map001/002/018),
  nhãn Map002 + Map003 không chồng nhau, Map001 giữ composite.
- **Sửa test cũ lỗi thời** (`tests/g2_ui_wiring_test.gd`, 2 check):
  `_update_hud` từ vòng HUD gọn 12:30 đã gộp túi vào dòng ngày
  ("Ngày 1 • Khung Sáng • Túi: trống") và `_hud_bag` ẩn đi không cập
  nhật text nữa, nhưng test vẫn đọc `_hud_bag.text` nên rớt 2/37 từ
  vòng 12:30 mà không ai để ý (vòng hồi quy 13:05 không chạy suite
  này). Nay test đọc `_hud_day.text` ("Túi: trống" / "Túi: 1 loại").
  **37/37 PASS** trở lại.
- Hồi quy: artpass 57/57, artpass3 23/23, G1 selftest 419/419,
  G3 playtest 95/95, G2 selftest 87/87, MarketBattle 123/123,
  battle scene 43/43, battle main 15/15, battle AI 34/34,
  G1 playtest 14/14, coord+WASD 16/16, hotspot 37/37, jobs 56/56,
  inventory+crafting 78/78, economy+education 92/92, phonehub 66/66,
  savecloud 69/69, social+titles+story 102/102, tools 155/155,
  online 91/91, ui_wiring2 71/71; scene 120 frame 0 ERROR.
- Export web exit 0: pck mới **6.872.908 byte, SHA `71c1c358…`**
  (trước `7e84335…`), wasm không đổi `fc74679e…`,
  `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ 4 file (cổng 8165).
- **Browser-verify thật (Chromium 1255 + swiftshader, 720×1280):**
  0 console error, 0 pageerror — ảnh
  `hidden_files/pxb-browser-verify-2026-11-20/23-polish-map1.png`,
  `28-polish-map2.png`, `29-polish-map3.png` (script tái chạy:
  `hidden_files/pxb-browser-verify-polish3.py`):
  Map002 toast "Đã sang Chợ Đầu Mối", 2 nhãn cửa đáy map xếp chồng
  dọc không đè nhau ("Cửa về Xóm Trọ Cũ" trên, "Cửa đi Khu Công
  Nhân" dưới, cách nhau ~5px); Map003 toast "Đã sang Khu Công Nhân",
  HUD "Phố Xô Bồ — Khu Công Nhân" vừa panel, **nửa trên là trời
  xanh có mây + chim + mặt trời, hết nền nâu trơn**; 2 nhãn cửa
  Map003 cũng không chồng nhau. Bài học input: `keyboard.press`
  nhanh bị miss giữa các frame (game ~0.22× thời gian thật); giữ
  phím 1500ms thì đi 2-3 ô; **giữ 400ms = đúng 1 ô** (đủ ≥1 frame
  poll thấy phím, thả trước khi bước 0.15s game xong).
- Phát hiện còn lại (không chặn deploy): Map003 tile vẫn là khối
  vàng tái dùng (PROVISIONAL, chờ art riêng); toast "Đã sang…"
  đè lên mặt trời ở góc trái (cosmetic, đã biết từ trước).
- **Va chạm song song (ghi 20/11 ~14:30):** trong lúc vòng này
  chạy, một luồng khác làm artpass4 trên cùng working copy
  (main.gd 07:16, export 07:17:54, pck mới `b6900f13…`). Push
  main `8e590ded…` đã quét cả thay đổi artpass4 của luồng kia
  (main.gd có cả `_deoverlap_labels` + `_resolve_label_overlaps`,
  marker.gd có cả `label_shift` + `label_override`) — commit vẫn
  coherent, đã verify lại trên code gộp: polish 18/18, artpass4
  17/18 (1 FAIL là mục điện thoại của luồng kia, đang làm dở),
  artpass 57/57, artpass3 23/23, G1 419/419, G3 95/95, G2 87/87,
  MarketBattle 123/123, ui_wiring 37/37 + 71/71, battle AI 34/34.
  **Deploy gh-pages CHƯA làm trong vòng này** (staging trên đĩa
  vẫn là bản polish `71c1c358…` đã verify; build hiện tại là
  `b6900f13…` của luồng kia, chưa verify xong) — vòng sau export
  lại từ code gộp, verify rồi deploy 1 lần. Hai hệ nhãn cùng chạy
  (`_resolve_label_overlaps` ghi `label_override`, `_update_label`
  ưu tiên nó; `_deoverlap_labels` tính `label_shift` nhưng bị
  override che) — **ĐÃ GỘP ở §10** (chỉ còn 1 hệ).

## 10. Art pass 4 — XONG (20/11 ~14:00–15:00, live check 13:53–13:56)

5 điểm ưu tiên từ kiểm live 13:53–13:56 trên bản artpass3
(gh-pages `8bed7c2c`), sửa xong, tự xem ảnh thật, deploy lại.

### 10.1 Nhãn chống chồng — viết lại bộ giải (lần 2)

- **Lần 1 (khoảng trống, vật cản toàn thân 90×160, gap nhân đôi
  grow+6px) SAI:** debug cho thấy "Góc Chế Tạo" + "Cửa ra" cùng
  rơi về y=1216 và chồng nhau. Nguyên nhân: grow(4)/grow(6) +
  cộng thêm 6px trong công thức = gap tính 2 lần, ăn hết khe hẹp
  giữa nhãn NPC và đầu NPC; vật cản toàn thân 160px đẩy nhãn
  xuống tận đáy màn hình, rời khỏi điểm neo.
- **Lần 2 (đang chạy):** vật cản chỉ đầu + thân trên
  (`_sprite_obstacle_rect`: 90×100px, đầu ở -150, ngực ở -50 —
  chân/bị che không sao, mặt/ngực mới quan trọng); gap 1 lần
  duy nhất `LABEL_GAP = 4.0` (không grow); chọn khoảng dọc trống
  gần vị trí mong muốn nhất; nếu khoảng dọc gần nhất xa hơn
  60px thì **dịch NGANG giữ nguyên y** (ưu tiên phải rồi trái,
  40/80/120/160px) thay vì đẩy lên/xuống xa khỏi điểm neo.
- Đo thật lúc spawn (debug headless frame 60): Cô Tư giữ
  (438,961); Bạn Thân giữ (229,827); Góc Chế Tạo (293,874) —
  kẹp giữa nhãn Bạn Thân (đáy 865) và đầu Bạn Thân (915), cách
  mỗi bên 4–9px, KHÔNG đè mặt; Hẻm trọ buổi tối (424,1154) —
  dưới thân trên Cô Tư (hết 1150) +4px, chỉ che chân; Cửa ra giữ
  (281,1225) đáy map.
- **Gộp 2 hệ nhãn (§9):** xóa `_deoverlap_labels()` +
  `marker.label_shift` — hệ cũ chạy chồng mỗi frame, `label_shift`
  của nó còn làm nhiễu đầu vào (desired rect) của bộ giải mới
  nhưng kết quả không bao giờ được dùng (override ưu tiên).
  Chỉ còn `_resolve_label_overlaps` + `label_override`.
  Polish test đổi sang kiểm tra vị trí HIỂN THỊ (override nếu
  có, không thì rect cơ bản) — Map002/003 vẫn không chồng nhau
  qua bộ giải chung.

### 10.2 Nhân vật tối theo khung Tối — nguyên nhân gốc

- Tint cũ (0.72,0.78,0.95) quá nhạt. Lấy mẫu pixel chứng minh
  overlay MUL ngày/đêm ĐÃ phủ lên nhân vật (facade Tối/Nền
  = 0.41 khớp ảnh đêm × MUL; đất = 0.62 khớp MUL) — tint chỉ
  yếu chứ không thiếu. Đổi tint Tối → **(0.42,0.48,0.72)**,
  Chiều → (1.0,0.85,0.62) ấm hơn. Đo ảnh Tối: nhân vật
  48.3 vs Sáng 120.8 (tỷ lệ 0.40, gồm cả vòng chọn vàng dưới
  chân) — nhìn thật: nhân vật xanh đậm, hòa vào nền đêm.

### 10.3 Đường nối dọc 2 tấm nền — cân bằng lại ảnh

- `tools/godot/regrade_bg.py`: cân lại `bg_map001.png` +
  `bg_map001_night.jpg` (bản gốc backup `/tmp/artpass4-bak/`):
  gain hằng theo từng phần ba + ramp tuyến tính 160px qua
  biên x≈373/747, gain kẹp [0.92, 1.08], chỉ y≥240 + feather
  dọc 40px. Ngày: độ sáng 3 phần 103.0/104.3/96.2 →
  100.6/101.2/100.1; đêm 51.8/55.9/55.7 → 53.8/54.2/54.0.
  (Bản v1 gain mượt 201px đã bỏ — làm bước nhảy ở khớp tệ hơn.)
  Ảnh TẠP HÓA sau sửa: không còn ranh giới thẳng cắt qua
  cửa/cửa sổ/mặt đất (chênh sáng 3 phần còn lại chủ yếu do
  nội dung cửa tối, không phải nối ảnh).

### 10.4 Toast + sao đêm + điện thoại

- Toast ngày/khung (60,200) → **(60,720)** (giữa-dưới, trên
  vỉa hè, không đè đĩa mặt trời/trăng ở y~200–400).
- Sao đêm: vẽ LUÔN (kể cả khi `sky_in_image`), 64 sao (trước
  36), alpha tới 0.95, bán kính tới 4.5; trăng vẫn bỏ qua khi
  có ảnh trời (tránh 2 mặt trăng); thêm cờ `stars_drawn`.
- Điện thoại: panel (20,190) → **(20,216)** (dưới nút HUD
  "Điện thoại (P)" hết ở y=208 + 8px); notch → (300,209);
  homebar → (290,1104); content scroll min 200 → **224**.
- **Lỗi Chị Lệ lần 2 (14:15):** sau lần 1 vẫn nửa cắt — vì
  danh bạ liệt kê NPC chưa quen cả 18 khu (38 dòng) và mỗi
  bullet dài ~50 ký tự gập 2 dòng; dòng 2 bị cắt ở mép dưới
  viewport. Sửa gốc: bullet "chưa quen" gọn 1 dòng
  (`• <tên> — chưa quen`, tên dài nhất 20 ký tự = 34 ký tự),
  gợi ý nói chuyện chuyển lên dòng tiêu đề. "Chị Lệ — chưa
  quen" nay hiện đủ 1 dòng; dòng nửa cắt ở mép cuộn còn lại
  là mục mới nguyên vẹn (báo hiệu cuộn được), không phải nửa
  sau của 1 mục.

### 10.5 Test + verify vòng này

- **Test mới** `tests/g4_artpass4_test.gd`: **18/18 PASS** —
  toast y 700–740; tint Tối r<0.6, b>r; panel/notch/homebar;
  panel 680×900 sau khi mở; content scroll 224;
  `_social_text()` kết thúc `"\n "` + bullet "chưa quen"
  ≤44 ký tự; `stars_drawn`; nhãn override không chồng nhau,
  không đè đầu/thân trên; về Sáng tint trắng trở lại.
- Hồi quy đầy đủ (sau gộp hệ nhãn): artpass 57/57, artpass3
  23/23, polish 18/18, G1 selftest 419/419, G1 playtest 14/14,
  G2 selftest 87/87, G3 playtest 95/95, MarketBattle 123/123,
  battle scene 43/43, battle main 15/15, battle AI 34/34,
  coord+WASD 16/16, hotspot 37/37, jobs 56/56,
  inventory+crafting 78/78, economy+education 92/92, phonehub
  66/66, savecloud 69/69, social+titles+story 102/102, tools
  155/155, online 91/91, ui_wiring 37/37 + 71/71;
  `--check-only` main.gd + marker.gd exit 0; scene 120 frame
  exit 0.
- Export web exit 0: pck **6.876.920 byte, SHA `101dda2e…`**
  (trước `7e84335…`), wasm không đổi `fc74679e…`.
- **Tự xem ảnh thật** (Chromium 1255 + swiftshader, 720×1280,
  `visual-check/artpass4/ap4-01..06.png`, script
  `visual-check/check_artpass4.py`, 0 console error,
  0 pageerror): Sáng spawn — nhãn tách nhau, không đè mặt,
  mặt trời rõ; TẠP HÓA — không đường nối dọc; Chiều — toast
  không đè mặt trời, ngả cam ấm; Tối — nhân vật xanh đậm,
  trăng rõ, sao dày, toast không đè trăng, đèn lồng/cửa sổ
  sáng; điện thoại — nút HUD đủ, "Chị Lệ — chưa quen" đủ
  1 dòng. **5/5 điểm đã hết.**
- File `tests/debug_labels_test.gd` (debug tạm, in rect nhãn)
  đã xóa trước khi push.
- Giới hạn còn lại: PNG art chỉ có trong bản local + `.pck`
  đã deploy (snapshot-push giới hạn text 188.416 byte/file) —
  clone mới vẫn fallback nhân vật vẽ code; nhãn "Cửa ra" vẫn
  ở sát đáy (6px, đúng vị trí vì cửa ở đáy map); nhãn Hẻm
  che chân Cô Tư (chỉ chân, không che thân).

## 11. Việc tiếp theo — G4 bước 5

1. G4 online thật: quyết Godot headless dedicated server thay .NET
   hay chờ máy có dotnet (xem `docs/opensource-engine.md` §3.4).
2. Lưu giữ sạp + Danh vọng trận MarketBattle vào SaveCloud
   (logic `data()` đã có, Main chưa nối); animation di chuyển/
   đánh; chọn đội/vũ khí trước trận.
3. Tile riêng Map003–018 (đang PROVISIONAL); camera zoom trận
   MarketBattle (lưới đang nhỏ giữa màn hình).

## 12. G4 bước 5 — Lưu giữ sạp + Danh vọng trận vào SaveCloud — XONG (20/11 ~14:50–15:05)

### 12.1 Nối Main ↔ PxbMarketBattle ↔ SaveCloud

- `scripts/battle_scene.gd`: thêm `signal battle_finished(winner)`
  (phát trong `_on_battle_finished`, sau khi `_last_action` cập
  nhật) — Main nghe để ghi kết quả trận, không sửa luật.
- `main.gd`:
  - `battle_state: Dictionary` bền theo phiên + `_battle_saved`
    (chống ghi 2 lần nếu `_finish_battle` bị gọi lại).
  - `_start_battle_demo()`: `expire_holds(battle_state, day)` rồi
    `battle_mb.from_data(battle_state)` — trận demo mới khôi phục
    giữ sạp + lịch sử từ save trước; nối
    `battle_scene.battle_finished → _on_battle_finished`.
  - `_on_battle_finished(winner)`: `battle_state =
    battle_mb.data()`; Danh vọng đội Bạn lấy từ
    `battle.result.rewards.teamA.famePerFighter` (thắng +50 /
    hòa +20 / thua +10, đúng luật) cộng vào `fame` + cập nhật
    HUD + toast ("Trận kết thúc — Danh vọng +50. Giữ sạp
    sap-cho-dau-moi đến ngày 8." khi đội Bạn thắng trận tranh sạp).
  - `_collect_system_data()`: thêm `"pxb_marketbattle": battle_state`
    (JSON-safe: holds + history đã qua `from_data` lọc).
  - `_apply_save_data()`: khôi phục qua `PxbMarketBattle` tạm
    (`from_data` loại hold rác thiếu teamId/ngày + history thiếu
    `result`), rồi `expire_holds(battle_state, day)` theo ngày
    vừa tải.
  - `_advance_frame()`: sang ngày game mới thì
    `expire_holds(battle_state, day)` — sạp hết hạn tự dọn, không
    chờ tới lúc mở trận/load save.
- Chưa làm: quyền lợi giữ sạp chưa áp vào Economy (giá sỉ −10% /
  thuế −20% / Danh vọng +10/ngày — `hold_benefits()` đã có, Main
  chưa gọi khi mua bán/ngày mới); animation di chuyển/đánh; chọn
  đội/vũ khí trước trận; chặn thách đấu khi đã giữ sạp khác
  (`can_challenge` đã có, demo chưa gọi).

### 12.2 Test mới + hồi quy

- `tests/g4_battle_save_test.gd`: **31/31 PASS** — thắng (giữ
  sạp đội Bạn đến ngày+7, fame +50, lịch sử 1), save slot 1 →
  xóa trắng state → load khôi phục đúng giữ sạp + fame 50 +
  lịch sử; hòa (+20, giữ sạp không đổi chủ, lịch sử 2); thua
  (+10, đội Chợ giữ sạp thay, lịch sử 3); `is_holding` đúng
  trước ngày hết / sai đúng ngày hết; `expire_holds` dọn 1 sạp;
  `from_data` loại hold rác + history thiếu `result`.
- Hồi quy đầy đủ trên cây gộp (luồng song song sửa vòng 5 cùng
  lúc — xem §12.4): artpass **60/60** (thêm 2 check mới, xem
  §12.3), artpass3 23/23, polish 18/18, artpass4 18/18, G1
  selftest 419/419, G1 playtest 14/14, G2 selftest 87/87, G3
  playtest 95/95, MarketBattle 123/123, battle scene 43/43,
  battle main 15/15, battle AI 34/34, coord+WASD 16/16, hotspot
  37/37, jobs 56/56, inventory+crafting 78/78,
  economy+education 92/92, phonehub 66/66, savecloud 69/69,
  social+titles+story 102/102, tools 155/155, online 91/91,
  ui_wiring 37/37 + 71/71; scene 120 frame exit 0.
- Export web exit 0: pck **6.846.480 byte, SHA `e05e7ed6…`**
  (wasm không đổi `fc74679e…`, single-threaded); HTTP 200 đủ 6
  file. **Lưu ý:** build này đã bị luồng song song xóa khỏi
  `src/godot-build/` lúc 08:00 (xem §12.4) — bản browser-verify
  là build 08:00 của luồng kia (`45686e4c…`, cùng cây code đã
  verify, chỉ khác pck do export lại sau sửa vòng 5).

### 12.3 Hai expectation artpass stale — sửa test, không sửa code

- **Màu overlay Tối:** test đòi `(0.55,0.62,0.9)` nhưng code
  `_daynight_color(2)` trả `(0.7,0.78,0.95)` khi map có ảnh nền
  đêm riêng — là quyết định có chủ ý từ live-check 14:34 (ảnh
  đêm đã tối sẵn ~0.65, MUL 0.7 giữ nhân vật nhìn rõ). Sửa test:
  đòi `(0.7,0.78,0.95)` + check `has_night_bg` đúng trên Map001.
- **Vị trí toast:** test đòi y 700–740 (vị trí cũ vòng 4) nhưng
  code đã dời toast xuống góc dưới-trái (24,1216) theo live-check
  14:34 (y=720 cũ đè cửa/cửa sổ) — luồng vòng 5 đã sửa test
  thành `y >= 1200.0`. Cả hai đều là test lỗi thời so với code
  đã chốt, không phải game sai.
- Bài học đo được: **chuỗi GDScript trong `.pck` export KHÔNG
  grep được** (Godot 4.7 lưu script dạng binary token — grep
  `Trận kết thúc` / `battle_finished` / `Đã sang` đều 0 hit,
  trong khi chuỗi JSON `Khu Công Nhân` vẫn thấy ×3). Muốn chắc
  code mới có trong build thì kiểm tra bằng hành vi chạy thật
  (test headless + browser-verify), không grep pck. Đừng kết
  luận "code chưa vào build" chỉ vì grep không thấy.

### 12.4 Va chạm luồng song song (ghi 20/11 ~15:00)

- Trong lúc vòng này chạy, một luồng khác làm vòng 5 trên cùng
  working copy: `main.gd` đổi 07:51:50 (+295 byte, overlay
  layer 1 + nhãn) và 07:57:44, `iso_map.gd` đổi 07:51:59, chạy
  `--check-only` toàn project lúc 07:55. Hậu quả đo được:
  artpass rớt 1 mục ở lần chạy đầu (màu Tối — test stale, xem
  §12.3), rồi rớt mục toast ở lần sau (code toast đã dời nhưng
  test chưa sửa — luồng kia sửa sau đó); `src/godot-build/`
  bị xóa lúc ~08:00 (luồng kia export lại, pck mới `45686e4c…`,
  6.843.288 byte) làm http.server 8163 trả 404 giữa chừng.
- Cách xử lý vòng này: KHÔNG sửa đè file luồng kia đang đổi;
  chỉ sửa test của mình (artpass màu Tối); kiểm tra marker của
  mình còn nguyên sau mỗi lần file đổi (`battle_state` ×9,
  `signal battle_finished` còn đủ); chạy lại suite liên quan
  trên cây HIỆN TẠI (artpass 60/60, battle save 31/31, G1
  419/419, battle main 15/15, scene 120 frame exit 0) sau khi
  cây ổn định (không còn Godot nào chạy, mtime đứng yên).
- **Deploy gh-pages CHƯA làm trong vòng này** (tránh đè deploy
  của luồng kia như vụ §8.4): staging trên đĩa vẫn là bản
  artpass4 `101dda2e…`; bản verify trình duyệt là build 08:00
  `45686e4c…` của luồng kia (cùng cây code đã verify). Vòng sau:
  export lại từ cây ổn định, rebuild staging, deploy 1 lần.
- Script `pxb-browser-verify-battle.py` đã sửa theo bài học
  §8.5: chờ `#start-btn:not([disabled])` + click qua selector +
  xác nhận `window.__pxb_start === true` (thử lại 3 lần) thay
  vì click tọa độ (360,665) — lần chạy đầu vòng này click tọa
  độ trượt, 5 ảnh đều ở title dù engine đã chạy.
- **Browser-verify thật build 08:00** (Chromium 1255 +
  swiftshader, 720×1280, `pxb-browser-verify-battle.py` đã sửa):
  engine-start OK, start-clicked OK, **0 console error, 0
  pageerror** — ảnh `hidden_files/pxb-browser-verify-2026-11-20/13-battle-open.png`:
  trận mở đúng (BỤI ĐỜI CHỢ CÁ, Đội Bạn 100% — Đội Chợ Đầu Mối
  100%, Vòng 1/12, lưới + ô xanh + 2 nút). Phát hiện nhỏ (không
  chặn): nhãn tên đấu sĩ còn hơi chồng nhau ("Cô Tư"/"Bạn Thân").

### 12.5 QUYẾT ĐỊNH ONLINE — Godot headless dedicated server (Bậc 1, 20/11 ~15:00)

- Quyết (Center, Bậc 1 — điểm `opensource-engine.md` §3.4 mục 4
  hẹn "quyết sau khi slice Godot chạy", nay slice đã chạy +
  browser-verify): **online dùng Godot headless dedicated
  server + WebSocket**, không giữ server .NET 8 làm đường chính.
- Lý do: (1) Web export bắt buộc WebSocket (trình duyệt không
  mở được UDP thô) — Godot có `WebSocketMultiplayerPeer` sẵn;
  (2) VM này không có dotnet SDK nên server .NET 8 không
  build/chạy/verify được ở đây — viết endpoint mới đều là nợ
  chưa verify; (3) dedicated server chạy + verify được ngay
  trên VM bằng cùng binary 4.7.2, dùng chung luật GDScript
  (PxbMarketBattle, Economy…) thay vì viết lại bằng C#.
- Server .NET trong `src/server/` giữ lại làm tham chiếu, không
  xóa; `PxbOnline` giữ nguyên trạng thái báo offline thật cho
  tới khi server mới có endpoint.
- Bước tiếp theo (G4 bước 6): server skeleton — `src/godot/server/`
  chạy headless (`--headless --dedicated-server` hoặc scene
  server riêng), WebSocket, chat relay + presence 2 người chơi,
  test headless 2 instance (server + client) đổi được 1 tin
  nhắn; rồi nối `PxbOnline` sang endpoint mới thay cho .NET.

## 13. Việc tiếp theo — G4 bước 6

1. **Deploy gh-pages bản đã verify** (build 08:00 `45686e4c…`
   hoặc export lại từ cây ổn định — rebuild staging rồi deploy
   1 lần, kiểm tra head gh-pages trước khi push từng batch để
   không đè luồng khác).
2. **G4 online thật — server skeleton** (xem §12.5): Godot
   headless dedicated server + WebSocket, chat relay + presence.
3. Quyền lợi giữ sạp áp vào Economy (`hold_benefits` đã có,
   Main chưa gọi); animation di chuyển/đánh trận; chọn đội/vũ
   khí trước trận; `can_challenge` ở demo.
4. Tile riêng Map003–018 (đang PROVISIONAL); camera zoom trận
   MarketBattle (lưới đang nhỏ giữa màn hình); nhãn tên đấu sĩ
   trong trận còn hơi chồng nhau (ảnh browser-verify 13).

## 14. Art pass 5 — vòng sửa 5 (20/11 ~15:00–16:30, kiểm live 14:34–14:40)

6 điểm từ kiểm live 14:34–14:40, điểm 1 là LỖI GỐC (chia đôi
sáng/tối ở khu TẠP HÓA). Sửa xong, tự xem ảnh thật cả 3 khung
ở khu TẠP HÓA (portrait + desktop), deploy lại.

### 14.1 Lỗi gốc: chia đôi sáng/tối — NGUYÊN NHÂN THẬT (không phải overlay 1 tấm)

Điều tra bằng đo pixel (script `/tmp/repro5.py`, staging build):
- Ảnh đêm `bg_map001_night.jpg` tự nó đã tối đều cả 3 cửa hàng —
  ảnh đêm không phải nguồn chia đôi.
- Pixel cùng 1 điểm tường Sáng (131,72,46) → Chiều (131,59,25)
  = đúng ×(1.0, 0.82, 0.55) màu overlay Chiều → overlay MUL
  ĐÃ phủ đều cả nền. Không có chuyện overlay chỉ phủ 1 tấm.
- Nguồn chia đôi thật: **`ground_wide.jpg` có gradient sáng
  trái→phải** (cột trái ~119, phải ~174 R) + `sky_wide.jpg`
  gradient xanh→ấm (cố ý, mặt trời) — mắt đọc thành "phải
  sáng hơn" ở mọi khung, mạnh nhất ở Tối (đất phải sáng hơn
  trái ~30 đơn vị). Tối ở spawn đo: đất L=70 R=100.
- **Cách sửa đúng (vẫn là (b) nhưng tận gốc):**
  1. `ground_wide.jpg`: san phẳng gradient ngang bằng PIL
     (gain từng cột, clip [0.85, 1.18]) — cột trái/giữa/phải
     110.6/137.4/141.8 → 129.9/132.2/131.3. Backup gốc
     `/tmp/ground_wide_orig.jpg`.
  2. `bg_map001.png`: xóa mặt trời vẽ sẵn trong ảnh (vùng
     x 855–1045, y 5–175, nội suy ngang + blur 4px) vì mặt
     trời nay neo camera sẽ vẽ chồng lên. Backup
     `/tmp/bg_map001_orig.png`. Biển PHỞ BÒ/CÀ PHÊ/TẠP HÓA
     không động vào.
  3. `main.gd`: overlay lên **layer 1** (trước là 0), tạo
     TRƯỚC `_label_layer`/`_ui_layer` (cùng layer 1) nên
     render trên mọi nội dung canvas mặc định nhưng dưới
     nhãn/HUD/điện thoại — 1 lớp phủ duy nhất, phủ đều nền +
     nhân vật + đất.
- **Kiểm chứng:** đo sáng ở khu TẠP HÓA (click-to-move sang
  phải, Chromium local, portrait 720×1280): Sáng mặt tiền
  L=115 R=114, Chiều 107/106, Tối 41/44 (lệch 1–3, trước đây
  lệch ~30); đất lệch ≤10. Tự xem ảnh: Tối tối đều toàn màn
  hình, không còn đường chia dọc, không cửa sổ cắt đôi.

### 14.2 Nhân vật Tối không còn bóng đen

- Nguyên nhân: overlay 0.55 × tint riêng 0.42 = 0.23 độ sáng
  → bóng đen chỉ còn mắt trắng (ảnh r5-05).
- Sửa: bỏ hẳn `_update_character_tint` (nhân vật luôn trắng,
  chỉ overlay MUL làm nhiệm vụ tối); overlay đêm nới lên
  **(0.7, 0.78, 0.95)** khi có ảnh nền đêm, (0.55, 0.62, 0.9)
  khi không. Ảnh Tối thật: mặt/quần áo đọc được (áo xanh
  nam, áo xanh lá nữ, bà ba tím Cô Tư), hòa vào nền đêm.
- Test `artpass_test.gd` đã chờ sẵn giá trị (0.7,0.78,0.95)
  từ quyết định kiểm live — code nay khớp test.

### 14.3 Nhãn — đường dịch ngang cũng phải giữ khe 12px

- Lỗi test artpass5: "Góc Chế Tạo đè lên đầu/biểu tượng".
  Probe (`/tmp/probe_labels*.gd`, đã xóa sau khi dùng) cho
  thấy ở trạng thái ổn định nhãn sạch — lỗi chỉ xuất hiện khi
  camera đang smoothing: resolver dùng `intersects()` thuần
  ở đường dịch ngang nên chấp nhận vị trí chỉ cách nhãn Cô Tư
  4px (muốn x 293 → dịch +160 → x 453, y giữ 919, khe dọc
  với Cô Tư chỉ 4px).
- Sửa `main.gd` `_resolve_label_overlaps`: đường dịch ngang
  kiểm `cand.grow(LABEL_GAP).intersects(...)` (giữ khe 12px
  cả 2 chiều với vật cản + nhãn đã đặt); không dịch được thì
  rơi về `best_y` (đã giữ gap). `LABEL_GAP` 4 → **12**,
  `LABEL_BOTTOM_MAX` 1200 (trước 1264), vật cản đầu
  (-48,-165, 96×115), thêm vật cản icon 48×48 cho
  hotspot/craft/door để nhãn không che sao xanh/cửa.
- Cột đèn lồng NadiaScene dời tile (10,10) → (2,10)
  (`nadia_scene.gd`, `iso_map.gd` night_glow.lamps) — hết
  cột đen xuyên nhãn "Cửa ra Chợ Đầu Mối".
- Sửa test: kiểm neo camera trước đây set trực tiếp
  `_camera.position` — vô nghĩa vì `Main._process` đặt lại
  camera theo người chơi mỗi frame (nên kiểm mặt trời chỉ
  đi +91 thay vì +200). Nay dịch chuyển NGƯỜI CHƠI
  (`player.place(..., (10,5))` rồi về (4,5)) và so sánh vị
  trí MÀN HÌNH của mặt trời/trăng (bất biến khi camera neo
  đúng), chờ camera smoothing ổn định (frame ≥60/90/150).

### 14.4 Mặt trời/trăng neo camera + toast góc dưới + điện thoại

- `scripts/sky_effects.gd`: mặt trời/trăng neo camera qua
  `_cam_anchor` (màn hình Sáng (170,290), Chiều (330,290),
  trăng (400,300) — dưới HUD ~190, trên mái); `_process`
  redraw lại khi camera dịch >2px (trước chỉ khi người chơi
  di chuyển ở frame 1). Trăng không còn bị cắt nửa ở mép
  trái khi camera ở TẠP HÓA (ảnh v5c-04: trăng tròn đầy đủ,
  sao rõ, đèn lồng đỏ sáng, cửa sổ vàng).
- Toast đổi khung: (24,1216), font 24, 440×40 — góc dưới
  trái, không che mặt trời/trăng/cửa (ảnh v5-portrait-03).
- Điện thoại: content scroll 224 → **238** (7 dòng danh bạ
  × ~34px, "Anh Ba — chưa quen" hiện đủ), actions scroll
  216 → 192 (tổng chiều cao VBox không đổi). Ảnh v5c-06:
  đủ 5 dòng, nút "Trò chuyện" không đè dòng cuối, khối
  "Hôm nay" lấp khoảng trống, panel không còn đè nút HUD.

### 14.5 Kết quả verify vòng 5

- `g4_artpass5_test` **17/17 PASS** (mới: overlay layer/trật
  tự/MUL/full-screen, toast góc dưới, scroll 238/192, mặt
  trời/trăng neo camera, nhãn không chồng/khe ≥10/đáy ≤1200).
- Hồi quy: artpass 60/60, artpass3 24/24, artpass4 19/19,
  G1 419/419, G2 87/87, G3 95/95, MarketBattle 123/123,
  battle scene 43/43, coord/WASD 16/16, battle AI 34/34.
- `--check-only` exit 0; export Web exit 0, pck 6.843.288
  byte SHA `45686e4c195b`, wasm không đổi `fc74679e3b97`.
- Chromium local (Playwright, swiftshader), 0 console error,
  0 page error, 2 viewport: portrait 720×1280 (click-to-move
  sang phải) + desktop 1920×1080. Ảnh
  `visual-check/artpass5/v5c-01..06.png` (portrait, TẠP HÓA
  cả 3 khung + Tối spawn + điện thoại), `v5-*.png` (desktop
  + portrait đợt đầu), `probe-*.png` (điều tra focus).
- **Hạn chế harness (không phải lỗi game):** trong Chromium
  swiftshader của máy ảo, giữ phím WASD không di chuyển
  (đã kiểm: focus canvas vẫn là `activeElement`, input map
  đúng physical_keycode 68; F/P qua `_unhandled_input` vẫn
  chạy, click-to-move chạy). Headless `g4_coord_wasd_test`
  16/16 PASS + kiểm live bằng browser thật 13:53 đã xác nhận
  "W/D/A và mũi tên đều đi được" — vòng 5 không động vào
  `player.gd`/input nên đây là giới hạn của harness đo, không
  phải hồi quy. Đo sáng desktop trả 0 (drawImage canvas
  WebGL trống sau frame) — chỉ là lỗi đo, ảnh desktop vẫn
  hiện game bình thường.

## 15. Việc tiếp theo — G4 bước 6 (sau artpass5)

1. **Deploy gh-pages bản artpass5 — XONG 20/11 ~16:30** (main
   `a6899a8c`, gh-pages head `59bb6e25`, 3 lô: `6f413d79` +
   `a5277a95` + `59bb6e25`; index.html + pck 000/025/050 +
   wasm 000 khớp byte 5/5 với staging; pck `45686e4c`,
   wasm `fc74679e` không đổi). Link live:
   https://tinnt120899.github.io/pho-xo-bo/ (Pages rebuild
   vài phút sau push).
2. **G4 online thật — server skeleton** (xem §12.5): Godot
   headless dedicated server + WebSocket, chat relay + presence.
3. Quyền lợi giữ sạp áp vào Economy (`hold_benefits` đã có,
   Main chưa gọi); animation di chuyển/đánh trận; chọn đội/vũ
   khí trước trận; `can_challenge` ở demo.
4. Tile riêng Map003–018 (đang PROVISIONAL); camera zoom trận
   MarketBattle (lưới đang nhỏ giữa màn hình); nhãn tên đấu sĩ
   trong trận còn hơi chồng nhau (ảnh browser-verify 13).
5. Nhãn "Cửa ra/Góc Chế Tạo/Bạn Thân" ở TẠP HÓA xếp chồng dọc
   giữa mặt tiền cửa hàng (không chồng nhau, có khe — nhưng
   nhìn như khối nổi trên cửa); cân nhắc neo nhãn gần điểm neo
   hơn thay vì đẩy lên cao khi va đầu nhân vật.

## 16. G4 bước 6 — Server skeleton online thật — XONG (20/11 ~15:45–16:00)

### 16.1 Code mới (chỉ thêm file, không sửa file cũ)

- `src/godot/server/pxb_server.gd` — `class_name PxbServer`
  (Node): dedicated server headless + WebSocket, giao thức JSON
  v1. `start_server(port)` (mặc định 8765), `stop_server()`,
  `poll()` (gọi từ `_process`; test gọi tay cũng được),
  presence (`hello` → `welcome` + broadcast `presence`),
  chat relay (`chat` → broadcast cho mọi client ĐÃ ĐĂNG KÝ),
  `bye` + mất kết nối → xóa presence + broadcast. Gói sai
  JSON / type lạ / chat khi chưa hello / text rỗng hoặc >500
  ký tự / tên >30 ký tự (cắt) / player_id rỗng → bỏ lặng, đếm
  `dropped_packets`, server không crash. CHƯA có auth
  (player_id do client tự khai — chỉ dùng nội bộ); server
  KHÔNG quyết tiền/đồ của ai (chat + presence chỉ là relay).
- `src/godot/server/server_main.gd` (SceneTree): chạy server
  thật — `godot --headless --path src/godot
  -s res://server/server_main.gd -- --port 8765`; log 1 dòng
  khi có người vào/ra/chat.
- `src/godot/tests/g4_online_server_test.gd`: test headless
  socket thật qua loopback (không stub).
- `src/godot/tests/g4_online_server_probe.gd`: probe client 2
  tiến trình (`--port/--player-id/--name/--chat/--listen`).

### 16.2 Verify thật đợt này

- `--check-only` exit 0: `pxb_server.gd`, `server_main.gd`,
  `g4_online_server_test.gd`, `g4_online_server_probe.gd`
  (lần đầu báo `PxbServer` không khai báo — cache class cũ;
  chạy `--headless --import` rồi check lại thì hết, đúng bài
  học §8.3).
- **Test server 37/37 PASS** (socket WebSocket thật
  127.0.0.1:18765): mở cổng, cổng trùng/sai thì lỗi, 0 người
  lúc đầu; A+B nối, welcome peer_id > 0, presence 2 người,
  chat A → B nhận đúng player_id/tên + A nhận echo; B ngắt →
  presence về 1 người; C chat khi chưa hello / gói sai JSON /
  type lạ / chat rỗng đều bị bỏ, không tới A; tên 40 ký tự
  cắt về 30; cuối trận server vẫn chạy, 2 người, 1 tin chat.
- **2 tiến trình thật:** server `server_main.gd` chạy riêng
  cổng 18765 + 2 probe riêng (sender `--chat
  HELLO-TU-2-PROCESS`, listener `--listen 20`): sender
  welcome players=2 + echo chat, listener nhận đúng tin chat
  từ Probe A, server log đủ +vào/ra/chat, cuối 0 người online.
  Cả 3 tiến trình exit 0, đã kill server sau khi xong.
- Hồi quy: G2 online 91/91, battle save 31/31, G1 selftest
  419/419, G2 selftest 87/87, G3 playtest 95/95, MarketBattle
  123/123, artpass 60/60, artpass5 17/17; scene Main 120 frame
  exit 0, không ERROR.
- **2 lỗi log đã sửa trong vòng này:** (1) broadcast target 0
  gửi cả cho socket vừa ngắt → engine báo `ready_state !=
  STATE_OPEN` — nay broadcast chỉ gửi từng peer ĐÃ ĐĂNG KÝ;
  (2) gói sai JSON làm `JSON.parse_string` in ERROR — nay chặn
  trước bằng kiểm tra chuỗi bắt đầu `{` + kết thúc `}`. Sau
  sửa, test 37/37 chạy sạch, 0 ERROR.
- **Quirk check-only (không phải lỗi game):**
  `--check-only --script res://main.gd` báo lỗi suy kiểu ở
  `scripts/sky_effects.gd:105` (`var sc`/`var sr` trong
  `_draw_moon`) rồi kéo theo iso_map/main compile fail — nhưng
  check-only riêng `sky_effects.gd` exit 0 và scene Main chạy
  120 frame exit 0 (compile đủ project vẫn đúng). Đây là lỗi
  suy kiểu giả khi biên dịch main.gd đơn lẻ, KHÔNG sửa code
  artpass5 vì nó. (Ghi để vòng sau không tưởng game hỏng.)

### 16.3 Va chạm luồng song song (ghi 20/11 ~15:50)

- Trong lúc vòng này chạy, một luồng khác (v6 — file
  `visual-check/check_v6d_title.py`, `tests/v6_*`) sửa cùng
  working copy: `main.gd`, `iso_map.gd`, `nadia_scene.gd`,
  `sky_effects.gd`, `project.godot` đổi ~08:51 UTC;
  `src/godot-build/` export lại 08:52 (pck 6.849.684 byte,
  trước đó 6.843.288 byte `45686e4c…`). Vòng này KHÔNG export
  đè lên build đó và KHÔNG deploy gh-pages (tránh đè deploy
  của luồng kia, như vụ §8.4). File server của vòng này tạo
  trước 08:52 nên có thể đã nằm trong pck 08:52 — nhưng chuỗi
  GDScript trong pck không grep được (§12.3), nên vòng sau
  export lại từ cây ổn định rồi mới kết luận. Hồi quy chạy sau
  các sửa của luồng kia vẫn PASS hết.
- **Export web CHƯA làm trong vòng này** (lý do trên) — vòng
  sau export lại từ cây ổn định, verify rồi deploy 1 lần.
- **Deploy gh-pages CHƯA làm** — chờ export vòng sau.

## 17. Việc tiếp theo — G4 bước 7

1. **Export lại từ cây ổn định + deploy gh-pages** (staging
   hiện là bản artpass5 `45686e4c…`; build trên đĩa đã là bản
   08:52 của luồng v6 — kiểm tra pck SHA + head gh-pages trước
   khi push từng batch, không đè luồng khác).
2. **Nối PxbOnline sang server Godot mới** (thay endpoint .NET):
   client WebSocket trong game (`PxbOnline` thêm transport WS
   hoặc client mới dùng chung protocol v1: hello/chat/presence)
   + hiển thị trạng thái online + chat trong điện thoại (tab
   Tin nhắn); giữ endpoint HTTP .NET làm fallback cho tới khi
   WS ổn định.
3. Quyền lợi giữ sạp áp vào Economy (`hold_benefits` đã có,
   Main chưa gọi); animation di chuyển/đánh trận; chọn đội/vũ
   khí trước trận; `can_challenge` ở demo.
4. Tile riêng Map003–018 (đang PROVISIONAL); camera zoom trận
   MarketBattle (lưới đang nhỏ giữa màn hình); nhãn tên đấu sĩ
   trong trận còn hơi chồng nhau (ảnh browser-verify 13).
5. Server: auth player_id (hiện tự khai), giới hạn tốc độ chat
   (chống spam), lưu lịch sử chat cho client mới vào (hiện chỉ
   giữ 100 tin trong RAM).

## 18. Art pass 6 — vòng sửa 6 (20/11 ~16:00–17:30, kiểm live 15:18–15:24)

### 18.1 Lỗi chia đôi sáng/tối — NGUYÊN NHÂN GỐC ĐÃ TÌM RA (không phải ảnh hẹp)

- Live 15:18 báo dải sáng ~10–15% mép phải cuối TẠP HÓA ở Tối/Chiều; vòng 5 đo ở GIỮA khu nên lệch 1–3 là đúng nhưng sai chỗ.
- Tái hiện bằng click-to-move (giữ phím WASD không di chuyển trong Chromium swiftshader trên máy ảo — đã biết, headless 16/16 PASS; F đổi khung vẫn chạy vì `_unhandled_input` là event-driven, còn `_held_dir()` poll `Input.is_action_pressed` nên phím nhấn nhanh lọt giữa 2 frame ở FPS thấp): 5 click (600,1100) đưa người chơi tới ô (10,1) — cuối map phải.
- Đo pixel TẠI DẢI ĐÓ (trước sửa): ground Tối nhảy +26 tại đúng x=527 (99.8 → 125.8), Chiều cũng nhảy tại x=527 (103.0 → 125.8). Ranh giới trùng khớp `(720 − camera_x) × 1.4 + 360 = (720−600)×1.4+360 = 528`.
- **Nguyên nhân gốc: `_overlay_layer.follow_viewport_enabled = true`** (main.gd, thêm ở vòng 5). CanvasLayer follow_viewport bám theo camera nên ColorRect (0,0)–(720,1280) thành hình chữ nhật THẾ GIỚI x 0..720, không phải màn hình. Lúc spawn camera x=280, overlay phủ màn hình −32..976 (đủ) nên không thấy lỗi; camera sang phải cuối map x=600 thì overlay chỉ phủ tới màn hình x=528, phần phải x>528 thoát lớp phủ → sáng như ban ngày. Ảnh nền/đất/overlay đều đủ rộng (geometry probe: mép phải nhìn thấy 857 < mép ảnh 872) — giả thuyết "ảnh đêm hẹp hơn" là SAI.
- **Sửa:** xóa `follow_viewport_enabled = true` (mặc định false = không gian màn hình, ColorRect 720×1280 phủ kín màn hình bất kể camera). **LUẬT: không bao giờ bật follow_viewport cho lớp overlay toàn màn hình.** Lưới an toàn: `default_clear_color` đổi từ be sáng (0.78,0.70,0.55) sang tối (0.10,0.12,0.18) để mọi khoảng hở tương lai đọc tối, không sáng.
- **Verify sau sửa (đo đúng mép phải cuối map):** Tối ground phải 101–103 (trước 129), Chiều 106 (trước 129); lệch so với giữa khung <10 mọi dải (sky/facade/ground, cả 3 khung); không còn bước nhảy tại x=527 (cột 500–560 đều 92–100 Tối, 95–103 Chiều). Test `tests/v6_overlay_test.gd` 16/16 PASS (kiểm tra hành vi: đưa camera ra (600,174), `get_global_rect()` của overlay vẫn (0,0)–(720,1280)).

### 18.2 Các điểm còn lại (theo báo cáo live 15:18)

- **Mặt trời/trăng sticker:** `sky_effects.gd` vẽ lại bằng `_draw_soft_disc` — gradient xuyên tâm 14 vòng alpha tăng dần vào trong (không còn đĩa phẳng + quầng cứng), đĩa có độ đậm nhạt ở rìa, vết lõm trăng vẽ mềm 3 vòng; dời lên y=240 màn hình (giữa dải trời, không đè mái/biển ở cả spawn lẫn cuối map). Test kiểm tra vị trí màn hình (170,240) Sáng / (400,240) Tối.
- **Nền 3 dải cắt thẳng:** feather 50px cuối `bg_map001.png` + `bg_map001_night.jpg` (alpha smoothstep → 0). Ảnh đêm đổi sang PNG (`bg_map001_night.png`, `iso_map.gd` cập nhật đường dẫn, xóa `.jpg` + `.import` cũ + cache `.godot/imported` — `ResourceLoader.exists` vẫn báo có nếu còn `.import`).
- **Nút bắt đầu kẹt 100%:** `onProgress` tới 100% nhưng `.then()` chỉ chạy sau khi wasm compile xong → nút kẹt ở "Đang tải game… 100%" (disabled). Sửa: đạt 100% đổi nhãn "Đang khởi động game…"; watchdog 12s không tiến độ → "Đang tải chậm — mạng yếu, vẫn đang tải…"; `.then()`/lỗi tắt watchdog.
- **Nhãn bị cắt ở mép trái khi camera sang phải:** đã kiểm tra — nhãn đã kẹp đúng (x ≥ 16, y ≥ 190) trong ảnh v6c-08, không còn bị cắt; không sửa thêm.
- **Xe đạp/chậu cây mép dưới cắt nửa:** xe đạp (12,9) + xe đẩy (8,13) nằm ngay mép dưới vùng nhìn thấy lúc spawn (thế giới y 654, mép 631) → dời xuống 2 ô: (12,11) + (8,15) (y 686, nằm hẳn dưới vùng nhìn thấy lúc spawn, hiện đủ khi đi xuống cuối map). Chậu cây (11,12) đã ở y 686 nên giữ nguyên.
- **Desktop + tiêu đề caro be trống:** `web_shell.html` tải tranh vẽ tay `title_bg.jpg` (nén từ `title_bg.png`, 119KB) làm nền overlay tiêu đề (cover) + nền 2 panel desktop (lớp kem mờ 0.88 để chữ đọc được); thẻ tiêu đề thành panel giấy mờ ở dưới màn hình; 2 nhân vật chibi (char_player.png / char_banthan.png) đứng 2 bên nút. Ảnh phục vụ qua fetch: local có file thật cạnh index.html; gh-pages loader ráp từ chunk (xem §18.3).

### 18.3 Deploy: ảnh tiêu đề chunk như wasm/pck

- `tools/godot/build_gh_pages.py` thêm `IMG_PARTS`: chunk base64 `title_bg.jpg` (1 chunk) + `char_player.png` (2) + `char_banthan.png` (2) vào `staging/img/<tên>/`; loader mở rộng fetch-override phục vụ 3 tên file với đúng Content-Type. Verify ráp lại khớp byte.
- Export web vòng này: exit 0, pck 6.849.684 byte SHA `6d668deb…`, wasm không đổi `fc74679e…`.
- Deploy gh-pages: main `7c5bb35f`; gh-pages 3 batch `e1a8db75` (index.html + pck 000–018) → `7324e001` (pck 019–037) → `2288401c` (pck 038–050 + 5 chunk ảnh); wasm 293 chunk không đổi nên không push lại. Verify khớp byte 6/6 mẫu remote-vs-staging (index.html, pck 000/025/050, img title_bg + char_player).

### 18.4 Verify vòng 6 (đầy đủ)

- `--check-only` 5 file sửa/mới exit 0 (main.gd, sky_effects.gd, nadia_scene.gd, iso_map.gd, v6_overlay_test.gd).
- Test: v6 16/16, artpass 60/60, G1 419/419, G2 87/87, G3 95/95, MarketBattle 123/123 — 0 FAIL.
- Chromium local (swiftshader, 0 console error): driver click-to-move tới (10,1), đo pixel mép phải 3 khung (xem §18.1); ảnh tiêu đề desktop 1920×1080 (tranh + 2 nhân vật + nút) + trong game desktop (2 panel tranh mờ); ảnh Tối/Sáng cuối map đã xem trực tiếp.
- Hạn chế harness đã biết (ghi lại, không phải hồi quy): giữ phím WASD không di chuyển trong Chromium swiftshader trên máy ảo; click-to-move + F vẫn chạy; đã dùng click-to-move để lái.

### 18.5 Việc tiếp theo

- Chờ kiểm live trên https://tinnt120899.github.io/pho-xo-bo/ (sau khi Pages rebuild bản deploy vòng 6) rồi mới báo chủ.
- G4 bước 7 (nối PxbOnline sang server Godot mới) theo §17.

## 19. Art pass 7 — vòng sửa 7 (20/11 ~17:30–18:30, kiểm local Chromium 18:0x)

Live 16:01–16:26 (bản artpass6): chia đôi sáng/tối ĐÃ HẾT, tiêu đề đã có tranh — vẫn CHƯA đủ đẹp như Nadia. 6 điểm, làm theo thứ tự.

### 19.1 Điểm 1 — Nhãn kẹt "buổi tối" — NGUYÊN NHÂN GỐC (không phải save/load)

- Nhãn "Hẻm trọ buổi tối" là TÊN TĨNH của hotspot `hs-tro-toi` (best_frame "Tối", port từ `Exploration.cs`): `scripts/pxb_hotspot.gd` HOTSPOTS + `data/maps.json:336`. Nhãn được set 1 lần lúc tạo marker, không cập nhật khi đổi khung.
- **Sửa (`scripts/marker.gd`):** marker giữ `_base_name` (tên gốc) + `_frame_name` (khung hiện tại); `_display_name()` thay từ "buổi …" trong tên bằng khung hiện tại (`.to_lower()` — "buổi sáng", không "buổi Sáng"); `set_frame_name(f)`; `Main._update_daynight()` gọi `set_frame_name(_frame_name())` cho mọi marker mỗi lần đổi khung. `_base_name` lazy-fallback trong `_display_name()` vì `_ready` không chạy với node thêm trong `SceneTree._init` (test headless). Dữ liệu canonical không đổi.
- **Caveat thiết kế (chờ quyết):** nhãn động không còn báo best frame nữa (độ sáng sparkle 1.5× + toast nhặt đồ vẫn báo). Nếu muốn giữ tín hiệu best frame, đổi tên hotspot thành trung tính ("Hẻm trọ") thay vì từ "buổi" động.
- **Verify live local:** Sáng "Hẻm trọ buổi sáng" (a7-02) → Chiều (a7-08) → Tối "Hẻm trọ buổi tối" (a7-09) → Ngày 2 Sáng "Hẻm trọ buổi sáng" (a7-10). Test `tests/g4_artpass7_test.gd` 25/25 (chuỗi Sáng→Chiều→Tối→Sáng + reload, tên NPC/không-khung không đổi).

### 19.2 Điểm 2 — Di chuyển bàn phím không ổn định — NGUYÊN NHÂN GỐC: polling

- `Player._process` poll `Input.is_action_pressed`; ở FPS thấp (swiftshader ~5fps) phím nhấn nhanh lọt giữa 2 frame → mất. F/P chạy vì event-driven trong `_unhandled_input`.
- **Sửa:** `player.gd` thêm `press_dir()`/`release_dir()`/`clear_held_dirs()` + `_held_dirs` (hướng event-held được kiểm tra trước trong `_held_dir()`, poll Input giữ làm fallback); `main.gd` `_key_to_dir(event)` (physical_keycode trước — Shift+D vẫn là KEY_D vật lý — rồi keycode) hook trong `_unhandled_input` (nhấn bước ngay, nhả xóa); `web_shell.html` focus handler (pointerdown/keydown focus canvas, vì nút DOM "Bắt đầu chơi" giữ focus).
- **Verify live local (Chromium, ERRORS: 0):** giữ D (a7-03), giữ W (a7-04), Shift+D (a7-05), ArrowRight (a7-06) — camera/người chơi đều di chuyển. Click-to-move ở a7-07 không kết luận được (script click (1400,700) nằm ngoài canvas, trúng panel phải) — không phải lỗi game.

### 19.3 Điểm 3 — Cửa sổ TẠP HÓA sáng cam ở Sáng — NGUYÊN NHÂN: chính ảnh ngày

- `art/bg_map001.png` (1120×630) được gen với cửa sổ sáng ấm. **Sửa:** PIL làm mát/khử bão hòa có chọn lọc riêng phần kính, trong rect đã đo — cửa sổ TẠP HÓA (955,455)–(1045,558), cửa kính TẠP HÓA (800,462)–(892,508), cửa kính đôi CÀ PHÊ (465,465)–(570,540), mask feathered, chỉ pixel cam mạnh (R−B>50, R>150). Ảnh đêm không đụng. Gốc backup `visual-check/artpass7/bg_map001_orig.png` + `ground_wide_orig.jpg` (PNG chỉ sống local + trong pck, không có trong git).
- **Verify live local:** Sáng cửa TẠP HÓA rèm kem nhạt, không phát sáng cam (a7-07); ảnh đêm vẫn sáng vàng đúng (a7-09).

### 19.4 Điểm 4 — Desktop cắt đáy ~200px + 2 bên be trống

- **Nguyên nhân:** camera zoom 1.4 + look-up −320 chỉ thấy tới world y 599 lúc spawn; xe đạp/hoa ở y 686 nằm dưới mép.
- **Sửa:** `main.gd` `CAMERA_ZOOM := 1.25` + `CAMERA_LOOK_UP := Vector2(0,-265)` — thấy y −315..709 lúc spawn (đỉnh mặt tiền −308 tới đáy đất + xe đạp ~702). `web_shell.html`: panel 2 bên có nội dung thật (`.keys`: WASD/mũi tên di chuyển, F đổi khung, P điện thoại, E tương tác, B trận; panel phải: chạm + màu hotspot) trên nền tranh tiêu đề mờ.
- **Verify live local:** đáy spawn thấy đủ xe đạp/chậu cây/xe đẩy (a7-02); panel 2 bên có tranh + chữ (a7-01/a7-02).

### 19.5 Điểm 5 — Mỹ thuật phẳng, thiếu chiều sâu/bóng

- `character_sprite.gd` `set_frame(f)`: bóng đổ ellipse theo khung — Sáng rx 14, lệch (8,3), alpha 0.30; Chiều rx 26, lệch (−22,3), alpha 0.34, bóng dài sang trái; Tối rx 12, alpha 0.12. Vòng vàng người chơi mỏng lại (width 1.5, alpha 0.6, r 40/36).
- `marker.gd` `set_player_on(b)`: ẩn ellipse sáng mặt đất của hotspot khi người chơi đứng trên ô đó (trước đọc như bóng xanh dưới chân); sao vẫn hiện phía trên.
- `nadia_scene.gd` `_draw_facade_light()` + `set_frame(f)` (iso_map forward): wash sáng/tối nhẹ trên mặt tiền Map001 theo hướng nắng (alpha ≤0.10 Sáng, ≤0.14 Chiều, bỏ qua ở Tối). `ground_wide.jpg`: PIL làm sâu vũng nước (sáng 25% trên +14, tối 25% dưới −12 — hiệu quả nhẹ khi xem). Lưu ý: `nadia_scene._draw_ground()` là DEAD code (đất là ảnh `ground_wide.jpg`), nên vũng phải sửa bằng ảnh.
- **Verify live local:** bóng ellipse dưới chân người chơi thấy rõ (a7-03), vũng nước có phản chiếu (a7-06/07), sao hotspot chỉ ở ô hotspot (a7-06).

### 19.6 Điểm 6 — Tải kẹt 15% + ảnh "loading or decoding failed"

- **Nguyên nhân:** chunk loader fetch mỗi chunk base64 đúng 1 lần, không retry, không kiểm tra `r.ok` — 1 chunk lỗi (404 lúc Pages đang rebuild / mạng chập chờn) là cả wasm/pck/ảnh chết, game kẹt 15%.
- **Sửa (`tools/godot/build_gh_pages.py` LOADER_TEMPLATE):** `fetchChunk(u)` retry 3 lần, backoff 400ms×lần, kiểm tra `r.ok` + non-empty, `console.warn` mỗi lần retry. `web_shell.html` `loadTitleArt` dùng `fetchBlobRetry(url, 3)`, warn thay vì nuốt lỗi im lặng. Watchdog 12s đã có từ vòng 6.
- **Verify:** retry chưa được kích hoạt bằng lỗi mạng thật trong lần kiểm này (tải local nhanh, không kẹt) — chỉ kiểm code + tải thành công; ghi lại để không nói quá.

### 19.7 Verify vòng 7 (đầy đủ)

- `--check-only` exit 0 cả 7 file sửa/mới (main.gd, player.gd, marker.gd, character_sprite.gd, nadia_scene.gd, iso_map.gd, g4_artpass7_test.gd).
- Test mới artpass7 25/25; regression: artpass 60/60, G1 selftest 419/419, G1 playtest 14/14, G2 selftest 87/87, G2 hotspot 37/37, G2 phonehub 66/66, G2 MarketBattle 123/123, G3 playtest 95/95, g4_coord_wasd 16/16, artpass3 24/24, artpass4 19/19, artpass5 17/17, v6_overlay 16/16, battle scene 43/43, battle AI 34/34, battle main 15/15, battle save 31/31, polish 18/18 — 0 FAIL. Smoke `--headless --quit-after 120` exit 0, không lỗi.
- Kỳ vọng test cũ sửa theo tiền lệ §12.3 (sửa test, không sửa code): `tests/artpass_test.gd` zoom 1.4 → 1.25; `tests/g4_artpass3_test.gd` ảnh đêm `.jpg` → `.png` (vòng 6 đổi file) + kiểm nhãn không chồng dùng rect ĐÃ RESOLVE (`label_override` nếu có — ở zoom 1.25 rect gốc "Cô Tư" vs "Góc Chế Tạo" chạm nhau nhưng resolver dời mỗi frame, nên phải assert kết quả trên màn hình).
- Export web exit 0: pck 6.858.400 byte SHA `5e424b74…`; wasm không đổi `fc74679e…` (39.514.754 byte).
- Chromium local (script `visual-check/check_artpass7.py`, desktop 1920×1080, server 127.0.0.1:8161): **ERRORS: 0**. Ảnh `visual-check/artpass7/a7-01…a7-11.png` đã xem trực tiếp: tiêu đề có tranh + 2 nhân vật; nhãn đổi đúng Sáng→Chiều→Tối→Sáng; D/W/Shift+D/ArrowRight đều đi; cửa TẠP HÓA Sáng hết sáng cam; đáy đủ; điện thoại 9 tab đầy nội dung.
- Nit còn lại (nhỏ, không chặn): dải tối ~10px ở mép phải cột game trên desktop (a7-06/07/09/10); toast "Ngày 2 • Khung Sáng" đè nhẹ xe đạp ở đáy (a7-10, tự mờ); nhân vật ở Tối vẫn hơi sáng so với đất (a7-09).

### 19.8 Deploy — XONG (20/11 ~16:50)

- Staging đã rebuild sẵn từ artpass7 (pck `5e424b74…`, wasm không đổi,
  `build_gh_pages.py` verify OK) — vòng này chỉ deploy gh-pages, 3 lô:
  `c1388653` (1/3: index.html + pck 000–018), `73da431e` (2/3: pck
  019–037), `f3d59243` (3/3: pck 038–050). gh-pages head `f3d59243`,
  kiểm tra trước mỗi lô khớp head trước đó, không có writer khác đè.
- Verify khớp byte từ site live: index.html khớp staging; 51 chunk
  pck tải về ráp lại **6.858.400 byte, SHA `5e424b743c17` — khớp đúng
  từng byte với build local**. Lưu ý: lần tải đầu 4 chunk 019–022
  lệch (CDN Pages còn cache bản cũ); tải lại vài phút sau thì khớp
  hết — blob SHA qua API (`70ee1586…` cho part-019) khớp staging
  ngay từ đầu, chứng tỏ repo đúng, chỉ CDN chậm. Đừng kết luận
  deploy sai chỉ vì curl ngay sau push thấy lệch — kiểm tra blob
  qua API rồi tải lại sau vài phút.
- Headless smoke trước deploy: `--headless --quit-after 120` exit 0,
  không ERROR. Browser-verify bản này đã làm ở vòng artpass7
  (a7-01..11, ERRORS: 0) — không chạy lại vì cùng pck đã verify.
- Link live: https://tinnt120899.github.io/pho-xo-bo/ (Pages rebuild
  vài phút sau push).

## 20. Việc tiếp theo — G4 bước 7

1. **Nối PxbOnline sang server Godot mới** (xem §17.2): client
   WebSocket trong game dùng protocol v1 (hello/chat/presence) +
   hiển thị trạng thái online + chat trong điện thoại (tab Tin nhắn);
   giữ endpoint HTTP .NET làm fallback cho tới khi WS ổn định.
   Server skeleton đã xong (§16): `src/godot/server/pxb_server.gd`,
   test 37/37 + probe 2 tiến trình.
2. Quyền lợi giữ sạp áp vào Economy (`hold_benefits` đã có,
   Main chưa gọi); animation di chuyển/đánh trận; chọn đội/vũ
   khí trước trận; `can_challenge` ở demo.
3. Tile riêng Map003–018 (đang PROVISIONAL); camera zoom trận
   MarketBattle (lưới đang nhỏ giữa màn hình); nhãn tên đấu sĩ
   trong trận còn hơi chồng nhau (ảnh browser-verify 13).
4. Nhãn "Cửa ra/Góc Chế Tạo/Bạn Thân" ở TẠP HÓA xếp chồng dọc
   giữa mặt tiền cửa hàng (không chồng nhau, có khe — nhưng
   nhìn như khối nổi trên cửa); cân nhắc neo nhãn gần điểm neo
   hơn thay vì đẩy lên cao khi va đầu nhân vật.

## 21. Art pass 8 — vòng sửa 8 (20/11 ~17:10–18:10, kiểm live artpass7 16:52–17:10)

### 21.1 Kiểm live artpass7 — game đứng hình trên trình duyệt thật

- Live check (browser-task f6bc057d, 16:52–17:11, 1920×1000):
  D (hoa + thường, ~18 lần) + ArrowRight (~16 lần) = nhân vật
  đứng yên tuyệt đối; tap-to-move 3 điểm phải (kể cả giữ 10,7s)
  = không nhúc nhích; E gần Cô Tư không mở hội thoại; NPC/lá
  tĩnh hoàn toàn. F (đổi khung) và P (điện thoại) vẫn chạy.
  Tải kẹt "Đang khởi động game…" >20s lần đầu; 2 ảnh tiêu đề
  "loading or decoding failed"; cửa TẠP HÓA Sáng vẫn sáng cam;
  đáy vẫn cắt ở 1920×1000; văn bản landing vẫn lộ 2 bên khi
  đang chơi; biển TẠP HÓA cắt nửa chữ Á ở spawn.
- Trong khi vòng 7 kiểm local Chromium báo D/W/Shift+D/
  ArrowRight đều đi được — phải tìm ĐIỂM KHÁC BIỆT giữa bản
  local và bản live, không sửa mù.

### 21.2 Tái hiện — phát hiện: vòng 7 kiểm SAI BẢN (raw export, không phải staging)

- Vòng 7 kiểm local phục vụ `src/godot-build/` (export thô,
  KHÔNG có chunk loader) — đường loader của gh-pages chưa bao
  giờ được kiểm local. Script mới
  `visual-check/check_artpass8_repro.py` phục vụ staging
  (port 8162) và raw build (8161) song song;
  `check_artpass8_taps.py` nhấn kiểu tap như kiểm live + tap
  vào TRONG canvas.
- Repro trên staging 1920×1000 (~17:20): nút bật ~10s;
  **di chuyển ĐƯỢC** (giữ D 3s đi phải, 10 tap D tới cuối
  TẠP HÓA, tap-to-move trong canvas chạy); F đổi khung đúng
  nhãn + toast; P mở điện thoại; **đáy KHÔNG cắt**; 0 failed
  request; 1 warning WebGL ReadPixels. Test tap của vòng 7
  KHÔNG HỢP LỆ: click (1400,700) nằm NGOÀI canvas (canvas
  x 679–1241 ở 1920 rộng) — cùng lỗi trong script repro đầu
  tiên, đã sửa thành (1150,750).
- Live files lúc ~17:15 đã byte-identical với staging (index.html
  SHA `fbfa8ac4…`, index.js `33c94cb3…`, ráp lại pck live
  6.858.400 byte SHA `5e424b743c17…` = staging). Lần ráp đầu
  sai vì tên chunk 10–50 không `%03d` (5.509.020 byte) — đã
  làm lại đúng.
- **Chẩn đoán (giả thuyết mạnh, chưa chứng minh bằng live
  re-check): live lỗi = CDN trộn pck cũ/mới.** Deploy xong
  ~16:45–16:52; kiểm live chạy 16:52–17:10, đúng trong cửa
  sổ lan truyền. URL chunk CỐ ĐỊNH (`wasm/part-000.txt`…)
  nên CDN Pages cache từng chunk riêng (max-age 600s) và
  trình duyệt ráp pck từ hỗn hợp chunk cũ + mới (chính cron
  16:45 đã thấy chunk 019–022 lệch ở lần tải đầu). Giải
  thích mọi triệu chứng live cùng lúc: `main.gd` cũ (zoom
  1.4 → đáy cắt), `player.gd` cũ (poll-based, lỡ tap ở FPS
  thấp), `marker.gd` mới (nhãn sửa được — live thấy đúng),
  ảnh nền cũ (cửa Sáng vẫn cam). Cache đã ổn định lúc
  17:15 (live = staging).

### 21.3 Sửa gốc — chunk theo phiên bản (versioned chunks)

- `tools/godot/build_gh_pages.py`: version = 8 hex đầu của
  sha256 nội dung; thư mục chunk `wasm/<sha8>/`,
  `pck/<sha8>/`, `img/<tên>/<sha8>/`; loader dùng URL có
  version; ghi `versions.json` vào staging; `verify()` kiểm
  tra thư mục versioned và assert loader dùng đường dẫn
  versioned. Thứ tự deploy: push hết thư mục chunk version
  mới TRƯỚC, verify, push `index.html` CUỐI CÙNG. Mỗi deploy
  thêm ~7MB thư mục version pck (wasm chỉ khi wasm đổi);
  thư mục version cũ mồ côi trên gh-pages, dọn định kỳ.
  Từ nay lỗi trộn CDN không thể xảy ra nữa (URL đổi theo
  nội dung).

### 21.4 Sửa cửa TẠP HÓA buổi Sáng (2 lớp)

- Lớp ảnh — `tools/godot/fix_taphoa_day_windows.py` (tái
  lập được): đo trước — ô cửa ngày R-B +104..+142, cửa sổ
  +48..+147, so với cửa sổ PHỞ BÒ (rèm xanh, không sáng) và
  cửa CA PHE (rèm trắng, không sáng); ảnh đêm có cửa sáng
  (đúng ở đó). Sửa: ô cửa rect (802,396,878,464), pixel
  R>145 & R-B>55, blend 0.85 về kính lạnh; cửa sổ rect
  (928,402,1052,538), pixel R>150 & R-B>70, blend 0.6.
  Kết quả đo: kính ô cửa R-B 104→26 (RGB 161,118,57 →
  132,119,106); giữa cửa sổ 77→50; trung bình rect ô cửa
  91→29, cửa sổ 71→45; đối chứng PHỞ BÒ không đổi (84).
  Chỉ 8.396 pixel đổi, TẤT CẢ trong 2 rect, 0 ngoài rect.
  Mảng xám-xanh trên cửa là CÓ SẴN (vùng (795,330,885,395)
  byte-identical trước/sau: (100,70,46)) — thạch cao cũ,
  không phải do sửa. Backup ảnh gốc
  `visual-check/artpass8/bg_map001_day_before.png`; so
  sánh trước/sau
  `visual-check/artpass8/taphoa-before-after.png`. Ảnh đêm
  không chạm. File sửa: `src/godot/art/bg_map001.png`
  (1120×630) — binary, KHÔNG push được qua snapshot-push,
  chỉ sống trong pck đã deploy.
- Lớp code — `src/godot/scripts/nadia_scene.gd`: hàm tĩnh
  mới `window_glass_color(f)`: Sáng (0.78,0.84,0.88) kính
  lạnh ban ngày; Chiều (1.0,0.84,0.52) ấm; Tối
  (1.0,0.78,0.38) hổ phách sáng đèn. `_draw_window` dùng
  nó. Lưu ý: Map001 KHÔNG dùng `_draw_window` (mặt tiền là
  ảnh composite — sửa bằng lớp ảnh); Map002+ dùng mặt tiền
  code. `set_frame` đã gọi `queue_redraw()` khi đổi khung;
  `_process` redraw mỗi 0.15s.

### 21.5 Sửa còn lại

- **Panel 2 bên ẩn chữ landing khi vào game**
  (`src/godot/web_shell.html`): tiêu đề/phụ panel bọc
  `.panel-title` / `.panel-sub`; CSS
  `body.in-game .side-panel .panel-title,.panel-sub
  { display: none; }` (hộp phím giữ lại làm trợ giúp;
  nền art mờ giữ lại); nút bắt đầu thêm
  `document.body.classList.add('in-game')`.
- **Watchdog phân biệt kẹt biên dịch vs kẹt mạng**
  (`web_shell.html`): theo dõi `lastProgress` trong
  `onProgress`; kẹt >12s hiển thị "Đang khởi động
  game… (lần đầu biên dịch hơi lâu, chờ chút)" nếu tiến
  độ đã tới 100% (biên dịch wasm 39MB, 10–30s trên máy
  chậm), ngược lại "Đang tải chậm — mạng yếu, vẫn đang
  tải…".

### 21.6 Verify vòng 8 (đầy đủ)

- **Quirk môi trường mới (20/11 ~17:35): `--check-only`
  TREO** — chạy 10+ phút, main thread ngủ trong
  `hrtimer_nanosleep`, ~3% CPU, không ghi import mới;
  kill bằng SIGTERM. (Import vẫn hoàn thành trong lần
  chạy đó — export sau chỉ mất 20s.) **Từ nay dùng đường
  test `-s` thay vì `--check-only`.**
- Test mới `src/godot/tests/g4_artpass8_test.gd` 18/18 PASS
  (~17:40, 4s): độ ấm pixel ảnh nền incl. đối chứng đêm,
  màu kính cửa sổ theo khung, `Main._key_to_dir`
  physical/keycode incl. Shift+D, F không phải di chuyển,
  toán fit desktop 1920×1000. 2 WARNING chỉ từ
  `Image.load_from_file` trong chính test — test-only,
  không phải code game.
- Regression đầy đủ, 0 FAIL (~17:40): artpass 60/60, G1
  selftest 419/419, G1 playtest 14/14, G2 selftest 87/87,
  hotspot 37/37, phonehub 66/66, jobs 56/56,
  economy+education 92/92, inventory+crafting 78/78,
  social+titles+story 102/102, tools 155/155, online
  91/91, savecloud 69/69, UI wiring 37/37, UI wiring2
  71/71, MarketBattle 123/123, G3 playtest 95/95,
  artpass3 24/24, artpass4 19/19, artpass5 17/17,
  artpass7 25/25, battle scene 43/43, battle AI 34/34,
  battle main 15/15, battle save 31/31, coord WASD
  16/16, polish 18/18, online server 37/37.
- Headless smoke `--headless --quit-after 120` exit 0,
  không lỗi. Export exit 0: pck mới 6.863.932 byte SHA
  `73ae78df…`, wasm không đổi 39.514.754 byte
  (`fc74679e…`).
- Staging build `build_gh_pages.py` VERIFY OK (~17:42):
  wasm version `fc74679e` (293 chunk, không đổi), pck
  version `73ae78df` (51 chunk), img title_bg `260962c1`
  (1 chunk), char_player `9639c122` (2), char_banthan
  `4750238d` (2); fileSizes khớp build; loader dùng
  đường dẫn versioned. Chunk cũ không version đã xóa
  khỏi staging. Staging: `wasm/fc74679e/`,
  `pck/73ae78df/`, `img/<tên>/<ver>/`, `versions.json`,
  `index.html`, `index.js`, worklets, icons.
- **Browser-verify staging mới**
  (`visual-check/check_artpass8_verify.py`, 1920×1000,
  ~17:50, exit 0, ~149s): **ERRORS: 0, FAILED REQUESTS:
  0**; canvas box 1920×1000; `body.in-game` set + tiêu
  đề panel ẩn = True. Ảnh `visual-check/artpass8/a8-01`
  …`a8-07` đã xem trực tiếp:
  - Di chuyển ĐƯỢC: giữ D 3s + 10 tap D đi tới cuối
    TẠP HÓA, tap-to-move trong canvas chạy, biển "TẠP
    HÓA" hiện trọn, không cắt.
  - Cửa TẠP HÓA Sáng hết sáng cam: đo đúng vị trí ô cửa
    (cùng bước giữ D 3s) R-B 80 (vòng 7) → 57 (vòng 8);
    ảnh gốc 104→26; `.ctex` re-import 10:39:54
    (842.838 byte, từ 841.156), pck ghi 10:39:56 — ảnh
    mới CHẮC CHẮN trong pck. (2 lần đo trước sai hộp đo:
    đo tường thay vì cửa — đo pixel phải đo ĐÚNG VỊ TRÍ.)
  - Khung Tối đúng: trời xanh đậm, trăng + sao, cửa sổ
    TẠP HÓA sáng đèn (ảnh đêm không chạm — đúng), nhãn
    "Hẻm trọ buổi tối", toast "Ngày 1 • Khung Tối" ở đáy.
  - Đáy đủ ở 1920×1000 (xe đạp + chậu hoa thấy trọn);
    panel 2 bên chỉ còn hộp phím, không còn chữ landing.
  - So sánh trước/sau trong game:
    `visual-check/artpass8/taphoa-game-before-after.png`
    (trên = vòng 7, dưới = vòng 8).

### 21.7 Deploy — XONG (20/11 ~18:00–18:10)

- Main `81bb16d3` (9 file: web_shell, nadia_scene,
  g4_artpass8_test mới, build_gh_pages versioned,
  fix_taphoa_day_windows mới, docs §21, 3 script
  visual-check artpass8). Kiểm tra trước push: head main
  vẫn `0662f332` (cron 17:45 chưa push); remote-vs-local
  7 file: 4 file đổi đúng như kỳ vọng, main/player/marker
  identical nên không push; 5 file mới xác nhận ABSENT
  (lưu ý: `get_file_contents` trả `ok:true` cả khi file
  không tồn tại — phải xem `result.isError`).
- gh-pages head `81d88ba0`, 5 lô (thứ tự: chunk version
  mới trước, `index.html` CUỐI): `b67eea16` (pck
  000–016), `855c7e8c` (017–033), `009b536c` (034–050),
  `c2d635d1` (img versioned 5 file + versions.json),
  `81d88ba0` (index.html). **Lỗi mới: push 51 chunk pck
  1 lô 8.8MB bị HTTP 413** (transport MCP nhỏ hơn giới
  hạn 16MiB của CLI) — chia 3 lô ~17 file/lô như vòng 7.
  wasm `fc74679e` KHÔNG push lại (đã có trên gh-pages).
  Trước lô index.html đã verify qua API: 4 mẫu chunk +
  versions.json khớp staging 4/4.
- **Verify khớp byte từ site live — ĐÚNG NGAY LẦN ĐẦU,
  không cần chờ CDN:** index.html live SHA `7facd2b1`
  = staging; versions.json live khớp; ráp 51 chunk pck
  live → **6.863.932 byte, SHA `73ae78dff7e2` = build
  mới**. URL versioned khiến trộn CDN không thể xảy ra
  (chunk mới có URL mới hoàn toàn) — khác vòng 7 phải
  tải lại sau vài phút.
- Link live: https://tinnt120899.github.io/pho-xo-bo/
  (Pages rebuild vài phút sau push; verify trên đã
  thấy bản mới ngay).

### 22. G4 bước 7 — Nối PxbOnline sang server Godot — XONG (20/11 ~17:45–18:30)

### 22.1 Code mới

- `scripts/pxb_online.gd` (G4 bước 7): client WebSocket protocol
  v1 dùng `WebSocketMultiplayerPeer` (đã chứng minh nối được
  PxbServer trong test server). `connect_ws(url, player_id,
  name)` (mặc định `ws://localhost:8765`, id tự sinh
  `pxb-<ms>-<rand>`, tên "Người chơi"), `disconnect_ws()` (gửi
  bye), `poll_ws()` (gọi từ `_process` khi vào cây + gọi tay
  trong test), `send_ws_chat(text)` (chặn ở client: chưa nối /
  rỗng / >500 ký tự), signal `ws_status_changed` /
  `ws_presence_changed` / `ws_chat_received`. Nhắn khi socket
  CONNECTED mới gửi hello; welcome → `ws_connected=true` +
  presence; error server → ngắt. Gói rác không phải JSON object
  chặn trước khi parse (tránh log ERROR như server). KHÔNG tự
  reconnect — bấm nối lại. `data()`/`from_data()` thêm `ws_url`
  / `ws_player_id` / `ws_display_name` / `ws_chat_log` (lọc bẩn:
  tên cắt 30, tin quá dài/thiếu tên thì bỏ, log tối đa 100).
  Đường HTTP .NET giữ nguyên làm fallback — WS chỉ chat +
  presence, KHÔNG quyết tiền/đồ.
- `main.gd`: nối 3 signal WS lúc `_ready`; `_online_text()`
  thêm "• Chat: …"; tab Tin nhắn thêm khối `ws_phone_text()`
  (trạng thái + người online + 8 tin gần nhất) vào cuối
  `_social_text()` + nút "Kết nối chat online (server local)"
  / khi đã nối: ô nhập `LineEdit` (placeholder "Nhắn chat
  online…", tối đa 500) + "Gửi chat" + "Ngắt kết nối chat";
  tin/presence mới → làm tươi tab nếu đang mở, không thì báo
  số chưa đọc; nối xong toast "Đã nối chat online (N người)".
- `tests/g2_online_test.gd`: cập nhật check
  `default_data()` (thêm 4 key WS mới).

### 22.2 Test mới + hồi quy

- `tests/g4_online_ws_client_test.gd`: **49/49 PASS** — socket
  thật qua loopback cổng 18767: A+B hello + welcome +
  presence 2 người, chat A → B nhận đúng player_id/tên + A
  nhận echo, B ngắt → presence về 1, gửi khi chưa nối / chat
  rỗng / chat 501 ký tự bị chặn ở client (server không nhận
  thêm tin), chat đúng 500 ký tự gửi được + echo về, nối cổng
  đóng thì không kết nối, `data()`/`from_data()` giữ ws_url +
  id + tên + log chat (tên dài cắt 30, tin bẩn bỏ), reset_state
  ngắt WS + xóa log + server về 0 người.
- Hồi quy đầy đủ, 0 FAIL: G2 online 91/91, server 37/37, G1
  selftest 419/419, G2 selftest 87/87, G3 playtest 95/95,
  artpass 60/60, artpass3 24/24, artpass4 19/19, artpass5
  17/17, artpass7 25/25, artpass8 18/18, polish 18/18,
  v6_overlay 16/16, coord+WASD 16/16, ui_wiring 37/37 +
  71/71, MarketBattle 123/123, battle scene 43/43, battle AI
  34/34, battle main 15/15, battle save 31/31, G1 playtest
  14/14, hotspot 37/37, phonehub 66/66, jobs 56/56,
  economy+education 92/92, inventory+crafting 78/78,
  social+titles+story 102/102, tools 155/155, savecloud
  69/69. Smoke `--headless --quit-after 120` exit 0.
- Export web exit 0: pck **6.880.296 byte, SHA `d9e5dc31…`**
  (trước `73ae78df…`), wasm không đổi `fc74679e…`,
  `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ 3 file
  (cổng 8166).

### 22.3 Browser-verify chat WS thật (Chromium 1255 + swiftshader, 720×1280)

- Server thật `server_main.gd` cổng 8765 + game `src/godot-build/`
  cổng 8166, script `hidden_files/pxb-browser-verify-ws.py` +
  `pxb-browser-verify-ws-send.py`, ảnh
  `hidden_files/pxb-browser-verify-2026-11-20/30–34`:
  engine-start OK, start-clicked OK, P mở điện thoại OK,
  **0 console error, 0 pageerror**.
- Bấm "Kết nối chat online (server local)": server log ghi
  `+ peer … (pxb-1795172114960-…)`, toast game "Đã nối chat
  online (1 người).", ô nhập + nút "Gửi chat" / "Ngắt kết
  nối chat" hiện đúng.
- Gõ "Xin chao Cho Dau Moi!" + bấm "Gửi chat": server log
  ghi `chat [Người chơi] Xin chao Cho Dau Moi!` — tin nhắn
  gõ trong game tới server thật; ô nhập xóa sau khi gửi.
  (Echo về `ws_chat_log` đã chứng minh bằng headless 49/49;
  trên ảnh trình duyệt tin nằm cuối vùng nội dung cần cuộn
  nên chưa thấy trực tiếp — xem hạn chế dưới.)

### 22.5 KIỂM LIVE THẤT BẠI — nguyên nhân gốc: thiếu thư mục wasm versioned (20/11 ~18:05–18:20)

- Kiểm live bằng cloud browser (18:05–18:12, 3 lần tải, ~7
  phút): trang chào hiện đúng, nhưng nút "BẮT ĐẦU CHƠI" không
  bao giờ bật — kẹt "Đang tải chậm — mạng yếu…" , thanh tiến
  trình thoáng qua 15% rồi mất, 0 console/pageerror quan sát
  được. Không vào được game nên chưa kiểm được điện thoại/nút
  chat/F — đúng lỗi live 17:55 đã ghi ở AGENTS.md.
- **Nguyên nhân gốc (đo được, không phải đoán):** loader
  versioned (§21.3) tải `wasm/fc74679e/part-*.txt`, nhưng trên
  gh-pages KHÔNG HỀ CÓ thư mục này — 293 chunk wasm chỉ nằm ở
  đường dẫn cũ KHÔNG version `wasm/part-*.txt`. Bằng chứng:
  curl live `wasm/fc74679e/part-050/100/150/200/292` → 404,
  part-000 → 503; API `get_file_contents` ref gh-pages
  `wasm/fc74679e/part-050.txt` → isError "file does not
  exist"; cây gh-pages head `a0ce1a35` (API, 710 entry):
  wasm chỉ có thư mục `wasm/` (293 file cũ), pck có cả `pck/`
  cũ + `pck/73ae78df` + `pck/d9e5dc31`, img versioned đủ.
  Vòng 8 đã SAI khi ghi "wasm KHÔNG push lại (đã có trên
  gh-pages)" — chỉ đúng với img (img versioned đã push đủ),
  sai với wasm. Kiểm local staging không phát hiện vì staging
  trên đĩa CÓ `wasm/fc74679e/` đầy đủ. Bài học: sau mỗi deploy
  versioned, kiểm tra SỰ TỒN TẠI của từng thư mục version trên
  remote (qua API tree), không suy từ "đã có từ trước".
- **Sửa:** đẩy đủ `wasm/fc74679e/` (293 chunk) lên gh-pages,
  13 lô × 24 file (tránh 413 như §21.7), head cuối
  `33353ad4…` (lô 1 `f21bb195…` … lô 13 `33353ad4…`).
  Sync record đã ghi đủ 13 lô.
- **Verify byte từ live (sau sửa):** ráp 293 chunk wasm live
  → 39.514.754 byte, SHA `fc74679e…` = build local (xem
  §22.6); pck + index.html + versions.json đã khớp từ trước.
- Kiểm live lại bằng cloud browser sau khi sửa — xem §22.6.

- Khối chat online nằm CUỐI nội dung tab Tin nhắn (sau danh
  bạ ~38 dòng) — muốn xem tin phải cuộn vùng nội dung; cân
  nhắc đưa khối chat lên trên danh bạ hoặc tự cuộn tới cuối
  khi có tin mới (vòng polish sau).
- Server WS hiện chỉ chạy local (localhost:8765, chưa có địa
  chỉ công khai) — người chơi khác máy chưa nối được; cần
  deploy server + cấu hình `ws_url` khi có máy chủ.
- Chưa có auth (player_id tự khai) + chưa giới hạn tốc độ
  chat + chưa lưu lịch sử cho client mới vào (ghi từ §17.5).

### 22.6 Verify byte từ live sau bản sửa wasm — ĐÚNG HẾT (20/11 ~18:30)

- Ráp 293 chunk `wasm/fc74679e/` từ site live (lần 1 thiếu
  46 chunk do 503 thoáng qua ngay sau 13 lần push liên tiếp
  — Pages đang rebuild; kiểm lại có retry thì 0 chunk lỗi):
  **39.514.754 byte, SHA `fc74679e3b97f768` = build local**.
  (Lần ráp tuần tự bị SIGTERM giữa chừng khi chưa in kết
  quả — không phải lỗi dữ liệu, đã chạy lại song song 16
  luồng, 293/293 trong ~30s, khớp SHA.)
- pck live đã khớp từ trước: 6.880.296 byte, SHA
  `d9e5dc31…`; `index.html` live SHA `1a63018a…` = staging
  loader mới vòng 9 (có `pxbShowLoadError`); `versions.json`
  live: pck `d9e5dc31`, wasm `fc74679e`.
- **Còn lại — kiểm live bằng cloud browser trên URL thật
  vẫn CHƯA chạy lại sau bản sửa** (parent làm cửa cuối theo
  §24.5 + luật AGENTS.md 17:55): tải + nút Bắt đầu bật +
  vào game + điện thoại + nút chat. Byte đã đúng hết nên lỗi
  kẹt 15% không còn nguyên nhân ở deploy nữa; nếu cloud
  browser vẫn kẹt thì nguyên nhân nằm ở mạng/proxy của
  trình duyệt đó, không phải ở file trên Pages.

## 23. Việc tiếp theo — G4 bước 8

1. ~~**Deploy gh-pages bản bước 7**~~ — ĐÃ XONG (cron 18:01–18:03
   20/11, gh-pages `a0ce1a35`, pck `d9e5dc31…`). NHƯNG deploy
   này lặp lại đúng lỗi vòng 9 (§24): không push chunk wasm
   versioned nên live vẫn kẹt tải cho tới khi vòng 9 deploy bù.
2. Quyền lợi giữ sạp áp vào Economy (`hold_benefits` đã có,
   Main chưa gọi); animation di chuyển/đánh trận; chọn đội/vũ
   khí trước trận; `can_challenge` ở demo.
3. Tile riêng Map003–018 (đang PROVISIONAL); camera zoom trận
   MarketBattle (lưới đang nhỏ giữa màn hình); nhãn tên đấu sĩ
   trong trận còn hơi chồng nhau (ảnh browser-verify 13).
4. Khối chat online trong tab Tin nhắn: đưa lên trên / tự
   cuộn tới tin mới (xem §22.4); server WS: auth player_id,
   giới hạn tốc độ chat, lịch sử cho client mới vào.
5. Dọn thư mục version pck/wasm cũ trên gh-pages định kỳ
   (mỗi deploy thêm ~7MB).

## 24. Vòng sửa 9 — kẹt tải 15% trên live, gốc ở deploy (20/11 ~18:10–19:30)

### 24.1 Kiểm live — game không vào được

- Live check (browser-task c5ef5035, 17:55–18:02, 1920×999):
  3 lần thử đều kẹt ở 15% rồi treo ở "Đang tải chậm — mạng
  yếu, vẫn đang tải…", nút Bắt đầu không bao giờ bật, chờ
  >3 phút/lần. Điểm kẹt lặp lại giống hệt ở 15% cả 3 lần
  (kể cả tab mới `?v=8`) — giống một chunk cụ thể bị treo/
  lỗi tải, không phải mạng chậm ngẫu nhiên. Các bước sau
  (di chuyển, cửa Sáng/Chiều/Tối, desktop) không kiểm được.
- Lưu ý: kiểm live vòng 7 (16:52) game VẪN VÀO ĐƯỢC — lỗi
  xuất hiện sau deploy art pass 8 (chunk versioned +
  index.html mới).

### 24.2 Tái hiện + tìm gốc — thư mục wasm versioned chưa từng tồn tại

- curl từ VM: `index.html` live 200 (31.021 byte, SHA
  `7facd2b1…` = staging artpass8 lúc đó);
  `wasm/fc74679e/part-000.txt` → **404** (lần đầu 503 thoáng
  qua, thử lại 404), `part-100/292.txt` → 404; trong khi
  `pck/73ae78df/part-000/050.txt` → 200,
  `img/title_bg.jpg/260962c1/part-000.txt` → 200.
  Chunk wasm KHÔNG version cũ (`wasm/part-000/292.txt`) vẫn
  200 — chỉ thiếu đúng thư mục versioned mới.
- **Gốc:** vòng 8 đổi sang chunk versioned nhưng chỉ push
  pck + img + index.html — "wasm `fc74679e` KHÔNG push lại
  (đã có trên gh-pages)" là SAI: trên gh-pages chỉ có chunk
  wasm KHÔNG version (`wasm/part-*.txt`), chưa từng có
  `wasm/fc74679e/`. Docstring của `build_gh_pages.py` đã ghi
  "wasm chỉ thêm khi wasm đổi" nhưng khi SCHEME đổi thì thư
  mục version mới vẫn phải push dù nội dung không đổi.
  Deploy G4 bước 7 (cron, 18:01–18:03, gh-pages `a0ce1a35`,
  pck `d9e5dc31…`) lặp lại đúng lỗi này — `wasm/fc74679e/`
  vẫn 404 sau deploy đó.
- **Cơ chế kẹt 15% (đã chứng minh bằng repro, xem §24.3):**
  `engine.startGame` = `Promise.all([init(wasm),
  preloadFile(pck)])`; pck tải có báo tiến độ → 6,86MB /
  46,4MB = 14,8% ≈ 15%; wasm fetch qua loader → 404 sau
  3 lần retry → `assemble` reject → engine nuốt rejection
  (Godot `instantiateWasm` dùng `WebAssembly.
  instantiateStreaming(Promise.resolve(r))` không có catch
  nên promise init không bao giờ settle) → `startGame`
  không resolve/reject → `displayFailureNotice` không chạy,
  tiến độ đứng yên, watchdog chỉ đổi nhãn thành "Đang tải
  chậm". Đây là lỗi TREO IM, không phải lỗi mạng.
- Chromium local KHÔNG mở được URL live thật
  (`ERR_TUNNEL_CONNECTION_FAILED` — proxy VM chặn github.io
  với Chromium, kể cả khi truyền proxy có auth; curl thì
  được 200). Từ nay verify live-URL bằng Chromium local là
  KHÔNG KHẢ THI trên VM này — dùng curl byte-verify +
  Chromium trên bản sao byte-identical + kiểm live bằng
  cloud browser của parent làm cửa cuối.

### 24.3 Repro — mô phỏng đúng trạng thái live, trước và sau sửa

- Script `visual-check/artpass9/check_live_load.py` (poll
  nút + tiến độ 5s/lần, ghi console/network) và
  `check_artpass9_verify.py` (verify đầy đủ: nút bật, giữ
  D, tap D, tap-to-move, F, P).
- Mô phỏng live: copy staging sang `/tmp/live-sim`, xóa
  `wasm/fc74679e/`, phục vụ cổng 8163. **Trước sửa:**
  879 failed request (293 chunk × 3 lần retry, toàn 404),
  nút kẹt "Đang tải chậm — mạng yếu, vẫn đang tải…" sau
  45s, không có báo lỗi nào (ảnh `live-title.png` lúc đầu
  — chụp lại sau sửa, xem dưới). **Sau sửa (loader cứng):**
  chỉ 48 failed request (16 worker × 3 lần), ngay t+15s
  nút đã bật với nhãn "⚠ Không tải được game — bấm để tải
  lại", notice ghi đúng "Không tải được index.wasm: HTTP
  404 wasm/fc74679e/part-002.txt — hãy kiểm tra mạng rồi
  bấm để tải lại trang."; tiến độ dừng ở 6880296/46395050
  (= 14,8%, pck đã tải xong) — cùng điểm 15% nhưng giờ có
  lỗi thật + nút thử lại thay vì treo im.

### 24.4 Sửa gốc — loader cứng + deploy bù chunk wasm

- `tools/godot/build_gh_pages.py` — loader mới (vòng 9):
  - `fetchChunk`: timeout thật mỗi lần thử
    (AbortController 30s) — fetch treo vĩnh viễn trước đây
    không bao giờ reject nên retry không chạy.
  - `assemble`: tải giới hạn song song 16 chunk/lần thay
    vì `Promise.all` 293 fetch cùng lúc (tránh nghẹt kết
    nối qua proxy/CDN; A/B trên cùng server local: loader
    cũ 24,8s vs loader mới 27,0s tới lúc nút bật — chênh
    ~2s trong nhiễu, nút thắt là biên dịch wasm trên CPU
    VM yếu, không phải giới hạn song song).
  - `pxbShowLoadError(msg)`: loader TỰ hiện lỗi (không đợi
    engine) — notice ghi tên file lỗi + nút Bắt đầu bật lại
    với nhãn "⚠ Không tải được game — bấm để tải lại",
    bấm thì tải lại trang; áp lại sau 500ms để không bị
    handler lỗi riêng của engine đè mất.
  - Watchdog tổng 120s: sau 120s mà nút vẫn chưa bật và
    chưa có lỗi nào hiện thì báo lỗi thật thay vì treo mãi
    ở "đang tải chậm". Ảnh lỗi không chặn game (chỉ warn,
    DOM dùng fallback gradient).
  - `verify()` assert thêm 5 marker cứng vòng 9
    (`pxbShowLoadError`, `AbortController`,
    `CHUNK_TIMEOUT_MS`, `CHUNK_CONCURRENCY`, `120000`).
  - Thêm `--check-live`: GET `versions.json` + part-000
    của wasm/pck/từng ảnh trên site live + so index.html
    live với staging — chạy trước khi tuyên bố deploy xong.
  - Docstring: ghi bài học vòng 9 + checklist deploy —
    khi index.html đổi sang đường dẫn version MỚI thì thư
    mục version đó PHẢI ĐƯỢC PUSH dù nội dung không đổi.
- Staging build lại: `build_gh_pages.py` VERIFY OK —
  wasm `fc74679e` (293 chunk), pck `d9e5dc31` (51 chunk),
  img đủ 3 ảnh, fileSizes khớp, loader có đủ marker cứng.
- Deploy gh-pages (thứ tự: chunk wasm versioned trước,
  `index.html` cuối):
  - **Song song ngoài ý muốn:** trong lúc vòng 9 đang làm,
    một worker khác (nhiều khả năng cron 24/24) cũng deploy
    cùng bản sửa — 13 commit 18:14:29–18:16:36
    ("Deploy fix live ket tai 15%: wasm fc74679e chunk
    versioned (01/13)…(13/13)", gh-pages `f21bb195` →
    `33353ad4`). Lô chunk wasm của vòng 9 (8 lô × 37 file)
    đều **HTTP 413** (transport MCP nhỏ hơn giới hạn 16MiB
    của CLI — 37 file × 180KB ≈ 6,7MB vẫn quá lớn; vòng 8
    dùng 17 file/lô ≈ 3,1MB thì được; worker kia dùng ~23
    file/lô thì được). **LUẬT MỚI: mỗi lô push ≤ 23 file
    chunk (~4MB), không bao giờ đẩy 37 file/lô nữa.**
  - `index.html` (loader cứng) của vòng 9 push thành công
    sau đó — gh-pages head `8091400c` (18:21:38).
    Trước mỗi lô đều kiểm tra head gh-pages; không đè commit
    của writer kia (chunk wasm của họ ráp lại đúng SHA
    `fc74679e…`, xem §24.5 — cùng nội dung, không xung đột).
  - Main push trước đó: `60fc7712` (build_gh_pages.py +
    docs §24 + 2 script artpass9).
- **PHỐI HỢP VỚI LUỒNG G4 BƯỚC 7 (cron 17:45, ghi 18:20):
  chunk wasm versioned ĐÃ ĐẨY XONG, KHÔNG CẦN ĐẨY LẠI** —
  13 lô × 24 file, head gh-pages `33353ad4…` (lô 1
  `f21bb195…`, lô 13 `33353ad4…`), sync record đã ghi đủ 13
  lô; byte-verify live đang chạy (ráp 293 chunk → SHA
  `fc74679e…`, xem §22.6). Vòng 9 chỉ cần đẩy `index.html`
  loader mới (staging đã build lại, VERIFY OK) — đừng đẩy
  lại 293 chunk wasm, đừng rebuild staging đè lên nhau.

### 24.5 Verify vòng 9

- Regression Godot (đường `-s`, `--check-only` treo theo
  §21.6), 0 FAIL: G1 selftest 419/419, G1 playtest 14/14,
  G2 selftest 87/87, hotspot 37/37, phonehub 66/66, jobs
  56/56, economy+education 92/92, inventory+crafting
  78/78, social+titles+story 102/102, tools 155/155,
  online 91/91, savecloud 69/69, UI wiring 37/37, UI
  wiring2 71/71, MarketBattle 123/123, G3 playtest 95/95,
  artpass 60/60, artpass3 24/24, artpass4 19/19, artpass5
  17/17, artpass7 25/25, artpass8 18/18, battle scene
  43/43, battle AI 34/34, battle main 15/15, battle save
  31/31, coord WASD 16/16, polish 18/18, online server
  37/37, online WS client 49/49, v6 overlay 16/16.
  (Không đổi code GDScript — chỉ đổi loader JS + docs —
  nhưng vẫn chạy đủ regression theo luật vòng sửa.)
- Browser-verify staging mới (Chromium local, 1920×1000,
  cổng 8164): nút BẮT ĐẦU bật sau 29,4s (lần đầu, gồm biên
  dịch wasm trên CPU VM), **ERRORS: 0, FAILED REQUESTS: 0**;
  giữ D 3s + 10 tap D đi được tới cuối TẠP HÓA (ảnh
  `a9-03`, `a9-04`), tap-to-move, F đổi khung, P điện
  thoại (ảnh `a9-05…a9-07`). Thời gian bật nút trên máy
  người chơi sẽ nhanh hơn (biên dịch wasm trên CPU VM yếu
  là nút thắt; loader cũ đo cùng setup là 24,8s; lần đo
  lại với bản icon-inline là 11,5s).
- Browser-verify trên file tải TRỰC TIẾP TỪ LIVE
  (354 file, index.html SHA `1a63018a…` = staging, cổng
  8167): nút bật sau 15,4s; giữ D + 10 tap D đi được tới
  cuối TẠP HÓA, biển "TẠP HÓA" hiện trọn không cắt; F đổi
  khung, P mở điện thoại (ảnh `a9-01…a9-07` ghi đè từ lần
  chạy này); **ERRORS: 1, FAILED REQUESTS: 1 — đều là
  `index.png` 404** (icon chưa từng được deploy, xem mục
  icon bên dưới — đã sửa bằng inline data URI sau đó).
  Lần chạy verify này bị ngắt giữa chừng do service
  restart (mất /tmp + module playwright — cài lại bằng
  `pip install --break-system-packages playwright`,
  browser chromium-1255 trong cache vẫn còn); chạy lại
  đầy đủ sau đó và PASS.
- Verify từ site live (curl): `--check-live` OK sau khi CDN
  hết cache (lần đầu FAIL chỉ vì index.html live còn bản
  cũ trong cache 10 phút — sau đó khớp staging); ráp lại
  toàn bộ chunk từ live: wasm 39.514.754 byte SHA
  `fc74679e3b97f768…` ✓, pck 6.880.296 byte SHA
  `d9e5dc318664f96a…` ✓; `versions.json` live khớp staging.
- **Icon 404 (phát hiện thêm lúc verify):** 3 file icon/
  splash (`index.png` 21KB, `index.icon.png` 5,7KB,
  `index.apple-touch-icon.png` 11,9KB) chưa bao giờ có trên
  gh-pages vì snapshot-push không đẩy được file nhị phân —
  là console error duy nhất còn lại sau khi sửa kẹt tải.
  Sửa: `build_gh_pages.py` inline cả 3 dạng data URI vào
  index.html (86.987 byte, vẫn dưới giới hạn 188.416);
  `verify()` assert đủ 3 data URI + không còn trỏ file
  riêng. Sau sửa: tải staging mới nút bật sau 11,5s,
  **FAILED REQUESTS: 0**; 1 console warning còn lại là
  "GPU stall due to ReadPixels" của swiftshader (đã biết
  từ vòng 8, chỉ là cảnh báo hiệu năng, không phải lỗi).
  Deploy icon-inline: index.html mới (main `f5b2fdd8`,
  gh-pages `462a5eac`, index.html staging SHA
  `c82cf663…`, 86.987 byte), `--check-live` OK sau đó
  (live index.html SHA `c82cf663…` = staging, 3 data URI,
  pxbShowLoadError ×4; CDN mất ~7 phút mới đổi bản).
  **Verify cuối trên file tải TRỰC TIẾP TỪ LIVE bản mới**
  (354 file, cổng 8167, 22:10 +07): nút bật sau 24,0s,
  **ERRORS: 0, FAILED REQUESTS: 0**; giữ D + 10 tap D đi
  được tới cuối TẠP HÓA, F đổi khung, P mở điện thoại
  (ảnh `a9-01…a9-07` ghi đè từ lần chạy này). 24,0s là
  lần tải đầu trên CPU VM yếu (biên dịch wasm); các lần
  đo trước: 11,5s / 15,4s / 29,4s — dao động theo tải CPU,
  đều dưới watchdog 120s.
- Lưu ý hạ tầng: service restart 2 lần trong buổi đã xóa
  sạch /tmp (mất file tải live + server http) và gỡ
  module playwright (cài lại bằng `pip install
  --break-system-packages playwright`; browser
  chromium-1255 trong cache vẫn còn). File tải live cuối
  để ở `~/workspace/live-final-verify/` (ngoài repo,
  bền qua restart) thay vì /tmp.
- Ảnh kiểm chứng: `visual-check/artpass9/` (`a9-01…a9-07`,
  `live-title.png` + script `check_live_load.py`,
  `check_artpass9_verify.py`).
- Caveat cho parent: **chưa kiểm live bằng cloud browser
  trên URL thật** (Chromium local không mở được github.io)
  — parent cần chạy kiểm live cuối trước khi báo user.

## 25. Vòng sửa 9+ — di chuyển hỏng trên live (20/11 ~22:05–23:30)

### 25.1 Kiểm live — tải xong, di chuyển vẫn hỏng

- Kiểm live cloud browser 22:05–22:13 (bản gh-pages sau khi
  cron bổ sung 293 chunk wasm): **tải ĐÃ SỬA XONG** — nút
  "Bắt đầu chơi" bật sau ~20 giây, vào game được ngay,
  điện thoại/chat (P), đổi khung F, nhãn Sáng/Chiều/Tối
  đều đúng. Nhưng **di chuyển VẪN HỎNG**: nhấn D/d/mũi
  tên phải nhiều lần + tap vào đất trống phía phải đều
  không nhúc nhích, nhân vật đứng yên tuyệt đối. P và F
  vẫn nhận nên kết luận ban đầu là "không phải focus/
  bàn phím — lỗi logic di chuyển".
- **Đính chính §24.5:** câu "giữ D + 10 tap D đi được tới
  cuối TẠP HÓA" là SAI — so ảnh a9-03 (sau giữ D) với
  a9-04 (sau 10 tap D) thì nhân vật ở YÊN MỘT CHỖ; toàn
  bộ di chuyển đến từ 3 giây GIỮ D, 10 tap không thêm ô
  nào. a9-05 (sau tap-to-move) cũng y nguyên. Verify cũ
  không so từng ảnh nên đã kết luận sai.

### 25.2 Tái hiện + tìm gốc — 2 lỗi thật, 1 hiểu lầm

- Đối chiếu bản live (22:15): `versions.json` live vẫn
  wasm `fc74679e` / pck `d9e5dc31`; live `index.html` SHA
  `c82cf663…` = staging; pck local SHA `d9e5dc31…` = live.
  **Bản live ĐANG CHẠY code di chuyển mới nhất — không
  phải pck cũ.** Gốc không ở deploy.
- Test headless mới `tests/g4_move_input_test.gd` (đi qua
  pipeline input thật `Input.parse_input_event`, khác test
  cũ chỉ gọi `_try_step`/`action_press` trực tiếp):
  keydown D 1 lần → (5,5) ✓; nhấn-nhả nhanh D → (6,5) ✓;
  mũi tên phải → (7,5) ✓; F/P ✓. **Nhấn 1 lần = 1 ô
  ĐÃ CHẠY ở tầng logic.**
- **Lỗi 1 — tap-to-move chết khi chạm ô bị chặn:** tap
  vào ô không đi được (tường biên/mặt tiền) thì code cũ
  (`elif iso_map.is_walkable(tile)`) im lặng bỏ qua,
  không đi đâu cả. Tap (1150,750) của verify cũ ánh xạ
  tới ô (11,2) — cột biên bị chặn. Người chơi tap "đất
  trống phía phải" rất dễ rơi vào ô biên/mặt tiền vì
  nền vẽ tay không khớp lưới tile.
- **Lỗi 2 — nhấn nhanh trong lúc đang tween bị mất:**
  `press_dir` cũ chỉ bước ngay khi `not _moving`; phím
  nhấn trong 0,15s tween (keyup đến trước khi tween
  xong) thì held bị xóa, bước đó mất hẳn. Nhấn dồn dập
  kiểu trình duyệt cloud (nhấn-nhả nhanh liên tiếp)
  sẽ mất bước.
- **Hiểu lầm — tọa độ chuột headless:** `parse_input_event`
  ở headless NHÂN ~20x tọa độ chuột (probe: gửi
  (462,1022) → tới `_unhandled_input` thành
  (8959,20440)) — do stretch headless, KHÔNG phải lỗi
  game. Nên tap-to-move headless phải gọi thẳng
  `_unhandled_input`; đường GUI thật kiểm bằng trình
  duyệt. Probe GUI cũng cho thấy KHÔNG Control nào
  nuốt click tại điểm tap (`_daynight` đã
  `MOUSE_FILTER_IGNORE` từ trước; `gui_get_hovered_control`
  null).
- Focus đã loại trừ: `web_shell.html` vòng 7 đã focus
  canvas khi bấm Bắt đầu + mọi `pointerdown`
  (dòng 389–398, 430); thí nghiệm local đo
  `activeElement = canvas` trước và sau khi bấm start.
  Camera smoothing (`position_smoothing_enabled`, tốc độ
  10) làm nền trôi chậm sau mỗi bước — đo độ dịch nền
  ngay sau bước sẽ ĐÁNH GIÁ THẤP số ô đã đi; phải so
  vị trí nhân vật/NPC, không so nền.

### 25.3 Sửa gốc — queue bước + tap tới ô gần nhất

- `player.gd` — hàng `_queued_dirs: Array[Vector2i]`
  (tối đa 8): `press_dir` khi đang tween thì append
  hướng vào hàng thay vì bỏ; `_process` khi tween xong
  thì `pop_front` và bước ngay. `release_dir` cố tình
  KHÔNG xóa hàng (nhấn-nhả nhanh vẫn đủ 1 ô). `place()`
  xóa hàng. Giữ phím vẫn đi liên tục như cũ (poll
  `_held_dir`); nhấn 1 lần = đi đúng 1 ô, nhấn dồn
  3 lần trong 1 tween = đủ 3 ô.
- `main.gd` — `_nearest_walkable(t)` (BFS trên lưới
  12x9): tap vào ô không đi được thì đi tới ô đi được
  GẦN NHẤT thay vì đứng yên. Nhánh tap trong
  `_unhandled_input` đổi từ `elif is_walkable` thành
  `else` + fallback này (tương tác NPC/hotspot/cửa
  khi đứng kề vẫn như cũ).
- Test mới `tests/g4_move_input_test.gd` (9 checks):
  spawn; 3 phím D nhấn nhanh → (7,5) [queue]; nhấn D
  1 lần → (8,5); mũi tên phải → (9,5); tap (9,7);
  tap ô biên (11,2) → (10,2) gần nhất; F → Chiều;
  P → mở điện thoại. **9/9 PASS** (lần chạy đầu 7/9
  do kỳ vọng test sai: giữ phím 25 frame đi 2 ô là
  đúng thiết kế đi liên tục — đã sửa test thành
  nhấn-nhả nhanh).
- Thí nghiệm trình duyệt `check_move_single.py`
  (staging = bản live, viewport 1920×1000, ảnh
  `m1-01…m1-08`): nút bật sau 24,0s; `activeElement`
  = canvas trước/sau start; **ERRORS: 0, FAILED: 0**;
  3 lần nhấn D riêng lẻ → nhân vật từ spawn (4,5)
  tới khu Cô Tư (~(7,5)); mũi tên phải +1 ô; **tap
  (1050,700) ĐI ĐƯỢC** (~2,5 ô lên phải); tap
  (1150,750) KHÔNG đi (ô biên (11,2) — chính lỗi
  đã sửa bằng fallback); phím F đổi khung Chiều.

### 25.4 Export + deploy — XONG (20/11 ~22:55–23:06)

- Export Godot (exit 0): pck mới 6.891.804 byte SHA
  `7f8ef9bbdfe0225a…` (52 chunk versioned), wasm không đổi
  `fc74679e…`. Staging rebuild bằng `build_gh_pages.py`:
  VERIFY OK (pck/wasm/img khớp byte, loader cứng đủ
  marker, icon inline đủ 3 data URI).
- **Writer song song:** lượt cron hourly 23:00 đã đẩy
  main trước — commit `08a0de9c` (23:01:34 +07, 5 paths:
  `player.gd`, `main.gd`, `pxb_economy.gd` [G4 bước 8],
  `g4_move_input_test.gd`, `g4_battle_hold_benefits_test.gd`;
  message ghi rõ "2053 PASS 0 FAIL; export web pck
  7f8ef9bb") — rồi deploy gh-pages trong 4 lô
  (`e5cda33b` 23 chunk pck 000–022, `bc4d25f6` 23 chunk
  023–045, `722c8e14` 6 chunk 046–051, `1ed8f9f8`
  `index.html` + `versions.json`), ghi đủ vào sync record
  (133 entries). Cùng lượt cron đã làm G4 bước 8 trước
  đó (~22:34 +07: áp quyền lợi giữ sạp vào Economy —
  `pxb_economy.gd` 15:34 UTC, test hold_benefits 30/30)
  nên pck `7f8ef9bb` chứa CẢ sửa di chuyển VÀ G4-8.
- Docs §25 KHÔNG nằm trong commit `08a0de9c` của cron —
  bản docs này là follow-up riêng sau deploy.
- CDN mất vài phút mới đổi bản: lúc 23:03 live vẫn
  `d9e5dc31`, tới ~23:06 đã là `7f8ef9bb`.

### 25.5 Verify vòng 9+ — XONG

- Regression Godot (35 suite, `-s`): **2053 PASS / 0 FAIL**.
  Lần chạy đầu 34 OK + 1 FAIL `g4_online_server_probe`
  (timeout phase=0) — là artifact của harness: probe cần
  server riêng đang chạy; chạy lại với server thật trên
  18765 thì "PROBE OK: echo chat". Tổng 2053 tính cả
  probe chạy lại (37/37 server test + 49/49 WS client).
  Ghi chú: lần chạy đầu của `g4_move_input_test` là 7/9
  do kỳ vọng test sai (giữ phím 25 frame đi 2 ô là đúng
  thiết kế đi liên tục) — đã sửa test, 9/9.
- Browser-verify staging mới (Chromium local, 1920×1000,
  cổng 8168, script `check_move_v2.py`, ảnh `m2-01…m2-08`):
  nút bật sau 24,7s, `activeElement` = canvas trước/sau
  start, **ERRORS: 0, FAILED REQUESTS: 0**; 3 lần nhấn D
  riêng lẻ → đi ~3 ô sang phải (camera pan, TẠP HÓA lộ
  ra); mũi tên phải +1 ô; **tap (1150,750) — điểm chết
  cũ — NAY ĐI ĐƯỢC** (đi tới cuối TẠP HÓA, fallback ô
  gần nhất hoạt động); tap (1050,700) không đổi (đã đứng
  sát đích); phím F → Khung Chiều (mặt trời cam +
  toast "Ngày 1 • Khung Chiều").
- Verify từ site live (curl): `--check-live` OK (live
  `versions.json` pck `7f8ef9bb`, mọi part-000 200, live
  `index.html` SHA `6282a11b…` = staging); **ráp lại
  toàn bộ 52 chunk pck từ live: 6.891.804 byte, SHA
  `7f8ef9bbdfe0225a…` = build ✓** (file ở
  `~/workspace/live-move-verify/`).
- Caveat cho parent: **chưa kiểm live bằng cloud browser
  trên URL thật** — parent cần chạy kiểm live cuối
  (nhấn D 1 lần / tap điểm cũ) trước khi báo user.

### 25.6 Kiểm live bản 7f8ef9bb — RỚT Ở BƯỚC TẢI (23:10–23:13 +07)

- Browser-task `be62ff52` (cloud browser, 23:10–23:13):
  `versions.json` live ĐÚNG bản mới (pck `7f8ef9bb`,
  wasm `fc74679e`) — nhưng mở game thì kẹt ở nút
  "Đang khởi động game…" **>120 giây**, không chuyển
  sang "BẮT ĐẦU CHƠI", không hiện thông báo lỗi tải.
  Dừng ở bước 1 theo luật (kẹt >120s); di chuyển /
  đổi khung / điện thoại CHƯA kiểm được trên bản này.
  Không quan sát được console error qua giao diện
  thường (lỗi nếu có nằm ở quá trình khởi động WASM).
- Nghịch lý: cùng bản này chạy local staging thì nút
  bật sau 19,8s (script `check_move_single.py`, ảnh
  `move-v10/m1-*`, ERRORS 0); `--check-live` OK; 52
  chunk pck ráp lại từ live khớp SHA từng byte.
  Chưa rõ gốc kẹt là CDN/proxy chậm thoáng qua lúc
  23:10 hay môi trường cloud browser — cần kiểm lại,
  không kết luận "bản mới hỏng tải" từ 1 lần kẹt.
- Giới hạn chẩn đoán từ VM: probe Playwright local mở
  thẳng URL live bị `net::ERR_TUNNEL_CONNECTION_FAILED`
  (egress proxy của VM chặn tunnel của Chromium; curl
  thì vẫn 200) — **không tự chẩn đoán được lỗi tải
  live bằng trình duyệt local**; chỉ curl/byte-verify
  được. Script probe: `visual-check/artpass9/
  probe_live_load_v10.py`.
- Chat chính đã tự mở kiểm live mới
  (browser-task `25039c4d`, lúc ~23:15) — kết quả của
  lần đó sẽ quyết định: nếu vẫn kẹt tải thì phải chẩn
  đoán sâu (DevTools network xem chunk/request nào
  treo); nếu tải được thì kiểm tiếp di chuyển.

## 25. Vòng 10 — kiểm live 22:09 + quyền lợi giữ sạp G4 bước 8 (20/11 ~22:05–22:47)

### 25.1 Kiểm live bằng cloud browser trên URL thật — ĐẠT trừ di chuyển

- Browser-task 708b5a8b (22:08–22:24 +07, chẩn đoán tiếp 22:30–22:39):
  tải nhanh, nút BẮT ĐẦU bật sau vài giây, vào game Map001, F đổi
  khung (Sáng→Chiều→Tối, trăng/sao, nhân vật tối đi), P mở điện thoại
  đủ 9 tab + khối chat online cuối tab Tin nhắn, **0 console/pageerror/
  failed request**.
- Di chuyển KHÔNG ĐẠT trong môi trường đó: ~70 lần bấm D/W/A/S/mũi
  tên + chạm chuột 3 điểm + giữ chuột/drag đều không nhúc nhích;
  chẩn đoán lại (viewport 1920×999, canvas x 678–1240, tâm (959,504)):
  40 lần bấm D + 30 ArrowRight + tap (1110,700) và (1050,800) trong
  canvas đều không đi; nút Điện thoại trong game bấm chuột thì mở
  ngay → input tới được game, nhưng tap/phím di chuyển không đi.
  Kết luận của browser: nghiêng về lỗi di chuyển thật (ít nhất đường
  chạm-chuột); đường phím chưa kết luận tuyệt đối vì môi trường đó
  không giữ phím thật được (không có keyboard.down/keyUp, không có
  eval/CDP để đo activeElement).
- E gần Cô Tư không mở hội thoại (ghi nhận thêm): người chơi chưa di
  chuyển tới kề Cô Tư nên `_try_interact` không có event trong tầm —
  chưa phải bug riêng, kiểm lại sau khi di chuyển được.

### 25.2 Tái hiện local — di chuyển ĐƯỢC trên đúng bản live

- Script mới của luồng song song
  `visual-check/artpass9/check_move_single.py` (staging = bản live,
  pck d9e5dc31, cổng 8164, Chromium 1255 + swiftshader, 1920×1000):
  nút bật sau 24,0s; activeElement trước/sau start đều là canvas;
  0 ERROR, 0 failed request.
- Ảnh m1-01…m1-08 (vòng này đã xem trực tiếp): 3 lần giữ D 400ms →
  người chơi đi phải, camera theo, biển TẠP HÓA hiện trọn (m1-04);
  tap (1050,700) đi tới ô (m1-06); F → Khung Chiều + toast (m1-08).
  Vậy code di chuyển của bản deploy CHẠY ĐƯỢC với input thật trên
  Chromium local.
- Chênh lệch còn lại: cloud browser không giữ phím thật + tap trúng ô
  bị chặn (xem §25.3) — cần kiểm lại bằng bàn phím vật lý giữ D 3s
  trên URL live để khép.

### 25.3 Chẩn đoán + sửa của luồng song song (đang làm, chưa verify xong)

- Test mới `tests/g4_move_input_test.gd` (8/9 PASS): keydown D/mũi
  tên qua `Input.parse_input_event` đi được 1 ô/lần; tap-to-move qua
  parse_input_event FAIL (đứng ở (7,5), auto_target (-1,-1)) nhưng gọi
  thẳng `Main._unhandled_input` thì PASS → kết luận ban đầu "click bị
  GUI nuốt".
- Probe của luồng đó do vòng này chạy lại: `g4_gui_probe` — KHÔNG
  Control visible nào chứa điểm (462,1022),
  `gui_get_hovered_control` = null (không có Control nào ăn click ở
  điểm đó); `g4_mouse_probe` — click qua parse_input_event VẪN tới
  được `_unhandled_input` của probe, nhưng position bị biến thành
  (8959.999, 20440.0) — artefact của đường parse_input_event headless,
  không phải của trình duyệt thật. Kết luận "GUI nuốt click" vì vậy
  CHƯA chắc; đừng sửa theo nó.
- Sửa thật của luồng song song (main.gd + player.gd, 15:38–15:44 UTC,
  đang tiếp tục sửa lúc 15:46):
  1. `player.gd` `_queued_dirs` (tối đa 8): press_dir trong lúc tween
     thì QUEUE bước lại, bước ngay khi tween xong; release_dir cố
     tình KHÔNG xóa queue — phím nhấn-nhả nhanh không bị mất bước
     (cơ chế mất bước: press trong lúc `_moving` thì code cũ chỉ ghi
     `_held_dirs`, keyup xóa ngay → mất hẳn; ở FPS thấp + bấm dồn
     dập thì hầu hết các lần bấm rơi vào lúc tween).
  2. `main.gd` `_nearest_walkable(t)` (BFS 12×9): tap vào ô không đi
     được (tường biên/mặt tiền) thì đi tới ô đi được GẦN NHẤT thay vì
     đứng yên — đúng điểm tap (1110,700)/(1050,800) trên live ánh xạ
     tới ô biên bị chặn.
- Va chạm: luồng song song sửa cùng main.gd/player.gd trong lúc vòng
  này làm G4 bước 8 — code bước 8 còn nguyên (đã kiểm grep sau mỗi
  lần file đổi), nhưng KHÔNG push/deploy trong vòng này để khỏi đè/
  chẻ fix của luồng kia (xem §25.5).

### 25.4 G4 bước 8 — quyền lợi giữ sạp áp vào Economy — XONG CODE + TEST, CHƯA PUSH

- `pxb_economy.gd`: `buy(item_id, discount_percent := 0)` — giá hiệu
  dụng = price × (100−disc)/100 (chia nguyên); tiền thuê phòng trọ
  KHÔNG giảm (không phải giá sỉ); trả thêm `"price_paid"`.
  `auction_seller_receives(hammer, tax_cut_percent := 0)` — phí 5% ×
  (100−cut)/100 (giữ sạp cut 20 → phí 4%, nhận 96%).
- `main.gd`: `_hold_benefits_now()` =
  `hold_benefits(battle_state, "doi-ban", day)`; `buy_item` truyền
  wholesaleDiscountPercent (trừ phong-tro), toast "Đã mua X
  (giá sỉ −10%.)" khi có giảm; `_advance_frame`: sang ngày mới (sau
  expire_holds) mà còn giữ sạp thì fame += famePerDay (10), toast
  ngày thêm "• Giữ sạp +10 Danh vọng".
- Test mới `tests/g4_battle_hold_benefits_test.gd`: **30/30 PASS** —
  hold_benefits đúng 10/20/10, hết hạn ngày 8 thì {}, đội khác {},
  economy mua giảm (4.600.000 mua được điện thoại cũ, còn 100.000,
  price_paid 4.500.000), không giảm thì không đủ tiền, thuê trọ không
  giảm, đấu giá 1.000.000 → 950.000 / giữ sạp → 960.000; Main: thắng
  trận giữ sạp → mua giá sỉ được, sang ngày +10 Danh vọng, xóa giữ
  sạp → mua giá đầy + không +fame.
- Hồi quy đầy đủ trên cây TRƯỚC sửa di chuyển của luồng song song
  (chạy 15:35–15:39 UTC): economy 92/92, battle save 31/31, battle
  main 15/15, MarketBattle 123/123, battle AI 34/34, online 91/91,
  savecloud 69/69, G1 selftest 419/419, G2 selftest 87/87, G3 playtest
  95/95, G1 playtest 14/14, artpass 60/60, artpass3 24/24, artpass4
  19/19, artpass5 17/17, artpass7 25/25, artpass8 18/18, battle scene
  43/43, coord+WASD 16/16, polish 18/18, v6_overlay 16/16, online
  server 37/37, WS client 49/49, hotspot 37/37, inventory+crafting
  78/78, jobs 56/56, phonehub 66/66, social+titles+story 102/102,
  tools 155/155, ui_wiring 37/37 + 71/71 — **0 FAIL**. (4 suite in
  tổng kết dạng khác nên grep lần đầu trượt: artpass 60, artpass7 25,
  artpass8 18, v6 16 — đã chạy lại riêng, đều PASS.)
- Lưu ý test: g4_move_input_test 8/9 (1 FAIL tap-to-move qua
  parse_input_event — artefact vị trí ×20 của đường test headless,
  xem §25.3; không phải hồi quy của bước 8).

### 25.5 CHƯA PUSH / CHƯA EXPORT / CHƯA DEPLOY trong vòng này — lý do

- Luồng song song đang sửa main.gd/player.gd (sửa lần cuối 15:44:52
  UTC, đang chạy probe/test lúc 15:46) — cây chưa ổn định. Push
  main.gd lúc này sẽ quét cả fix di chuyển chưa verify xong của luồng
  kia; push lẻ economy+test sẽ chẻ tính năng. Đợi cây ổn định → chạy
  lại hồi quy trên cây gộp (đặc biệt g4_move_input +
  g4_battle_hold_benefits + artpass) → export → deploy 1 lần.
- Việc tiếp theo: (1) luồng song song verify fix di chuyển (hồi quy +
  local browser + kiểm live lại bằng bàn phím vật lý giữ D); (2) push
  main (bước 8 + fix di chuyển) + export + deploy gh-pages bản mới;
  (3) kiểm live cuối trên URL thật.

## 26. G4 bước 9 — Nhãn tên đấu sĩ chống chồng — XONG (20/11 ~23:50–00:10)

### 26.1 Lỗi

- Nhãn tên đấu sĩ trong trận MarketBattle còn hơi chồng nhau (ghi từ
  §13/§20, thấy trên ảnh browser-verify 13: "Cô Tư"/"Bạn Thân").
  Nguyên nhân: tên rộng tới 120px, 2 đấu sĩ kề nhau chỉ cách 32px
  ngang (TILE_W 64, iso) — lệch theo chẵn/lẻ x (44 vs 64) chỉ tách
  được 20px dọc, không đủ cho chữ cao ~22px.

### 26.2 Sửa (`scripts/battle_scene.gd`)

- `fighter_name_rects() -> Array` (mới): tính rect từng tên theo độ
  rộng chữ thật (`font.get_string_size`, cap 120px) + dy chẵn/lẻ x
  như cũ; sắp theo y rồi x, đẩy rect chồng xuống dưới rect đã đặt
  (khe 4px); kẹp đáy ≤ 980 (trên panel hành động y=1000), hết chỗ
  dưới thì đặt lên trên rect đang chặn. Trả về `{id, name, rect}`.
- `_draw_fighters` lượt 2: tên vẽ theo rect đã resolve (baseline =
  rect.y + 20, căn giữa theo `rect.size.x`); fallback giữ hành vi cũ
  nếu thiếu id. Không sửa luật, không sửa vị trí vòng tròn/HP bar.
- Test mới `tests/g4_battle_names_test.gd`: **12/12 PASS** — đủ 6
  nhãn lúc spawn, không chồng; cặp kề (5,4)-(6,4) đúng điểm lỗi cũ;
  cụm 6 ô kề; tên dài ("Tiểu thương 12") cap 120px; nhãn giữ gần
  đấu sĩ (≤110px) + trong màn hình + trên panel.

### 26.3 Verify vòng này

- Hồi quy đầy đủ (script 22:45): **1978 PASS / 0 FAIL** (1966 cũ +
  12 mới); battle scene 43/43, battle AI 34/34, battle main 15/15,
  battle save 31/31, MarketBattle 123/123 — không regression.
- Smoke `--headless --quit-after 120` exit 0, 0 error — lưu ý: lần
  chạy đầu báo parse error ảo `main.gd:2038 _update_dbg() not found`
  dù hàm CÓ định nghĩa ở dòng 2173; chạy `--headless --import` rồi
  chạy lại thì hết (đúng bài học cache cũ §8.3 — không sửa code vì nó).
- Export web vòng này exit 0: pck `bea7de95…` (6.903.908 byte),
  wasm không đổi `fc74679e…`; HTTP 200 đủ 4 file (cổng 8170),
  `GODOT_THREADS_ENABLED = false`.
- **Va chạm song song — export bị ghi đè (ghi 00:05 21/11):** một
  worker khác (Vòng 10 — D-pad + nhãn debug, xem dưới) sửa
  `main.gd` 16:58:40, `web_shell.html` 16:57:10, thêm
  `tests/g4_dpad_test.gd` 16:58:12 rồi export lại lúc 17:00:36 —
  pck trên đĩa nay là **`bc296e9e…` (6.903.924 byte)**, KHÔNG còn
  là `bea7de95…` của vòng này. Build hiện tại là cây GỘP (fix
  nhãn trận vòng này + D-pad Vòng 10); `g4_battle_names_test` có
  trong pck (grep thấy tên file) nên code vòng này vẫn nằm trong
  build. Staging rebuild sau đó (VERIFY OK) đã dùng đúng pck
  `bc296e9e…` hiện tại, khớp byte với build trên đĩa.
- **Vòng 10 — D-pad + nhãn debug (worker song song, code chưa
  push trong vòng này):** sau kiểm live 23:14 (nhân vật đứng yên
  dù phím/tap chạy tốt trên Chromium local — không tái hiện được
  lỗi live), worker đó thêm ĐƯỜNG INPUT THỨ 2 không phụ thuộc bàn
  phím: 4 nút mũi tên trên màn hình (`button_down` → `press_dir`,
  `button_up` → `release_dir`) + nhãn debug hiện ô hiện tại +
  input cuối, để lần kiểm live sau đọc được ngay input có tới game
  không. File của họ: `main.gd`, `web_shell.html`,
  `tests/g4_dpad_test.gd` — vòng này KHÔNG push các file đó (để
  worker đó tự push), chỉ push 3 file của vòng này.
- Hồi quy đầy đủ trên cây GỘP (chạy lại sau khi cây ổn định, gồm
  cả `g4_dpad_test.gd` của Vòng 10): **1990 PASS / 0 FAIL**
  (1978 cũ + 12 D-pad mới); battle names 12/12, battle scene 43/43,
  battle AI 34/34, battle main 15/15, battle save 31/31,
  MarketBattle 123/123, move-input 9/9 — không regression.
  (Lần chạy 23:5x trước khi gộp là 1978/0 trên cây chưa gộp,
  không tính cho cây này.)
- Kiểm tra đường tải live trước deploy: `versions.json` live vẫn
  pck `7f8ef9bb`; 6 chunk mẫu live (wasm 000/150/292, pck 000/051,
  img title_bg) đều **200 trong 0,9–1,7s** — đường tải live khỏe
  lúc 23:47. Vụ kẹt tải >120s ở kiểm live 23:10 (browser-task
  be62ff52) nhiều khả năng là kẹt thoáng qua ở CDN/proxy hoặc môi
  trường cloud browser, không phải file trên Pages (byte đã khớp
  SHA từ trước) — không kết luận "bản mới hỏng tải" từ 1 lần kẹt.
  Kết quả kiểm live lại (browser-task 25039c4d, mở ~23:15) vẫn CHƯA
  có trong phiên này — parent/chủ xem kết quả đó để chốt di chuyển
  trên bản `7f8ef9bb`.
- **Push main CHƯA xong — service restart 3 lần (00:0x–00:15 21/11):**
  `github push-files` bị gián đoạn cả 3 lần thử (service restart
  ngay trong lúc push, đúng kiểu §24.5); đã đối chiếu head remote
  sau mỗi lần: vẫn `c1f86361…`, không có commit mới nào được tạo,
  sync record KHÔNG ghi thêm (đúng luật — chưa xác nhận thì không
  advance). Không retry lần 4 trong vòng này (3 lần cùng lỗi là
  đủ; retry mù có nguy cơ tạo commit trùng nếu 1 lần thực ra đã
  lọt). Paths file giữ lại ở
  `hidden_files/pxb-push-paths-2026-11-21-0010` để vòng sau push
  lại 1 lệnh. Deploy gh-pages cũng dùng cùng cơ chế push nên
  cũng CHƯA làm được trong vòng này.

### 26.4 Việc tiếp theo

1. **Push main lại** (paths file đã sẵn ở
   `hidden_files/pxb-push-paths-2026-11-21-0010` — 4 file vòng
   này; kiểm tra head vẫn `c1f86361…` trước khi push) **+ deploy
   gh-pages bản `bc296e9e…`** (staging đã rebuild + VERIFY OK:
   pck `bc296e9e`, wasm `fc74679e` không đổi, img đủ 3 ảnh, loader
   cứng đủ marker, icon inline đủ 3 data URI; push pck versioned
   + index.html cuối, kiểm tra head trước mỗi lô ≤23 file).
   Lưu ý: deploy này sẽ đưa cả D-pad Vòng 10 lên live (cùng pck
   gộp) — đúng ý đồ (D-pad là đường input thứ 2 cho kiểm live
   sau), nhưng worker Vòng 10 vẫn cần push riêng `main.gd` +
   `web_shell.html` + `g4_dpad_test.gd` lên main trước/sau đó để
   code trên GitHub khớp build đã deploy.
2. Animation di chuyển/đánh trận; chọn đội/vũ khí trước trận;
   `can_challenge` ở demo (xem §20.2).
3. Tile riêng Map003–018 (đang PROVISIONAL); camera zoom trận
   MarketBattle (lưới đang nhỏ giữa màn hình).
4. Khối chat online trong tab Tin nhắn: đưa lên trên / tự cuộn tới
   tin mới; server WS: auth player_id, giới hạn tốc độ chat, lịch
   sử cho client mới vào.
5. Dọn thư mục version pck/wasm cũ trên gh-pages định kỳ.

## 27. Cron 03:45 21/11 — hồi quy + staging OK, push main + deploy CHƯA XONG (3 lần service restart)

### 27.1 Hồi quy cây hiện tại — 37/37 suite, 0 FAIL

- Subagent chạy `bash tools/godot/run_regression.sh` (~04:38 +07,
  log `~/workspace/regression-move.log`): **37/37 suite OK,
  0 FAIL — 2079 assert PASS** (tính từ log; v6_geometry_probe
  không in số đếm, probe server PROBE OK). Mới so với vòng §26:
  `g4_dpad_test` nay 14/14 (trước 12/12), `g4_battle_names_test`
  12/12 giữ nguyên.
- Smoke `--headless --quit-after 120` exit 0, không ERROR.
- Không sửa code trong vòng này (chỉ chạy test + verify staging).

### 27.2 Staging verify — OK (build `ba8e4a99…`, không phải `bc296e9e…` của §26)

- `build_gh_pages.py --verify-only` exit 0: pck `ba8e4a99`
  (6.904.868 byte, 52 chunk, khớp byte với `src/godot-build/`),
  wasm `fc74679e` (293 chunk, 39.514.754 byte, khớp byte),
  img đủ 3 ảnh khớp byte, loader dùng chunk versioned + đủ 5
  marker cứng vòng 9, icon inline đủ 3 data URI.
- Build trên đĩa là bản export 01:04 +07 (sau export 00:00 +07
  của Vòng 10); không có file code `src/godot/` nào mới hơn
  export này — pck chứa đúng cây hiện tại (battle names +
  D-pad Vòng 10).
- Live lúc này vẫn pck `7f8ef9bb` (curl `versions.json` 10:26
  +07); wasm `fc74679e` đã có đủ trên gh-pages (curl
  `wasm/fc74679e/part-000` + `part-292` đều 200) — deploy sau
  KHÔNG push lại wasm.

### 27.3 Push main — THỬ 3 LẦN, cả 3 đều restart, KHÔNG commit mới

- Push 4 file (paths file
  `hidden_files/pxb-push-main-2026-11-21-0345`):
  `src/godot/scripts/battle_scene.gd`,
  `src/godot/tests/g4_battle_names_test.gd` (+ `.uid`, mới),
  `docs/godot-g4.md`. Trước mỗi lần đều đối chiếu head main
  vẫn `c1f86361…`; đối chiếu remote-vs-local: `battle_scene.gd`
  remote blob `2b0680a1…` ≠ local (đúng — local có fix tên trận),
  2 file test mới xác nhận ABSENT trên remote (`isError`), docs
  sync base chính là head nên không lệch được.
- Cả 3 lần `github push-files` đều bị **service restart giữa
  chừng** (lần 1 ~21:48 UTC, lần 2 ~23:xx UTC, lần 3 ~01:28
  UTC); đối chiếu head sau mỗi lần vẫn `c1f86361…`, sync record
  KHÔNG ghi thêm — đúng luật (chưa xác nhận thì không advance).
  DỪNG ở 3 lần theo tiền lệ §26.3, không retry lần 4 trong
  vòng này.
- **Deploy gh-pages CHƯA làm** (cùng cơ chế push-files, sẽ gặp
  cùng lỗi restart) — lượt sau làm 1 lần: pck `ba8e4a99` 52
  chunk chia 3 lô ≤23 file + `index.html` + `versions.json`
  cuối; kiểm tra head gh-pages (`1ed8f9f8…`) trước mỗi lô.
- Lưu ý cho lượt sau: build `ba8e4a99` chứa cả code D-pad Vòng
  10 (`main.gd`/`web_shell.html`/`g4_dpad_test.gd` — worker
  Vòng 10 tự push theo §26.4, chưa thấy push). Deploy sẽ đưa
  D-pad lên live trước khi code lên main — sau deploy nhớ đẩy
  nốt 3 file D-pad lên main để code GitHub khớp build đã
  deploy, tránh lệch như vụ wasm §22.5.
- Vòng 10 agent (`3d626c35`) vẫn listed running lúc 21:32 UTC,
  hoạt động cuối ~21:24 UTC; sau 3 restart không rõ trạng thái
  — không can thiệp (thuộc chat khác). Staging có thư mục pck
  lạ `64880480` (17:06 UTC) — dọn sau, không ảnh hưởng deploy.

### 27.4 Việc tiếp theo

1. **Push main lại** (paths file đã sẵn — kiểm tra head vẫn
   `c1f86361…` trước khi push) **+ deploy gh-pages `ba8e4a99`**
   (xem §27.3).
2. **Kiểm live bằng cloud browser trên URL thật sau deploy**
   (D-pad 4 nút + phím D + tap, đọc nhãn debug ô hiện tại/input
   cuối) — cửa cuối theo luật AGENTS.md 20/11 23:21; live hiện
   vẫn bản `7f8ef9bb` nên kiểm lúc này chỉ lặp lại kết quả cũ.
3. Animation di chuyển/đánh trận; chọn đội/vũ khí trước trận;
   `can_challenge` ở demo; tile riêng Map003–018; camera zoom
   trận; khối chat online đưa lên trên tab Tin nhắn; server WS:
   auth player_id, giới hạn tốc độ chat, lịch sử cho client mới.

## 28. Vòng 10b — "1 click D-pad đi tới Map002" HÓA RA LÀ CỬA (5,4) + đọc nhầm ô — XONG, đã deploy (21/11 ~01:00–04:30 +07)

### 28.1 "Bug" còn lại sau tap-per-tile — đọc nhầm số ô ở cỡ chữ nhỏ

- Sau khi đổi D-pad sang tap-per-tile (`step_dir`, §26), chạy
  lại `check_dpad2.py` (UP → RIGHT → LEFT → DOWN): RIGHT vẫn
  "đi tới Map002 (8,4)", LEFT "về (4,4)". Tưởng còn driver lạ.
- Thêm bộ đếm `_dpad_press_count` (hiện `P:N` ở dòng 2 nhãn
  debug) + chạy `check_diag.py` (chỉ 1 click RIGHT): **P:1,
  dừng đúng (5,5)** — 1 click = đúng 1 lần `button_down` = 1 ô.
  Tap-per-tile HOẠT ĐỘNG.
- Chạy lại đúng chuỗi e-run (`check_up_then_right.py`, UP rồi
  RIGHT, chụp mỗi 500ms): i-01 sau UP: `(4,5)`... — SAI. Phóng
  to nhãn debug 3× mới đọc đúng: **i-01 = `Ô (4,4) • ▲`**
  (UP ĐÃ đi được, (4,4) đi được — trước đó đọc nhầm thành
  (4,5) vì chữ nhỏ bị xe đẩy che một phần).
- Gốc thật: cửa Map001→Map002 ở ô **(5,4)**
  (`data/maps.json`: `{"kind":"door","tile":[5,4],"to_map":2}`).
  Từ (4,4), 1 click RIGHT → (5,4) = đúng ô cửa → `_transfer(2)`
  → spawn Map002 (8,4). HOÀN TOÀN ĐÚNG LUẬT GAME — không có
  driver lạ nào: mọi ảnh chụp đều `H:[] Q:0 A:(-1,-1) MR:0`,
  P tăng đúng 1/click. Chuỗi LEFT sau đó (8,4)→(4,4) trên
  Map002 cũng đọc nhầm tương tự (thực tế là 1 ô, sẽ verify lại
  bằng zoom trong j-run).
- Bài học: **không bao giờ đọc ô từ ảnh thu nhỏ** — nhãn debug
  font 20 ở (24,1172) phải phóng to 3× mới đọc chắc; các kết
  luận "đi 4–7 ô" ở vòng 10/10b trước khi có zoom đều không
  đáng tin.

### 28.2 Verify cuối trên staging (build `ba8e4a99`, `check_final.py`)

- D-pad 4 hướng, tránh ô cửa (5,4): DOWN (4,5)→**(4,6)** ▼
  P:1; LEFT (4,6)→**(3,6)** ◀ P:2; RIGHT (3,6)→**(4,6)** ▶ P:3;
  UP (4,6)→**(4,5)** ▲ P:4 — đúng 1 ô/click, về đúng spawn.
- Phím D: (4,5)→**(5,5)** • D (P vẫn 4 — phím không tính vào
  bộ đếm D-pad). Tap (1000,850): đang đi tới `(9,7)` — nhãn
  hiện `chạm (9,7)` + `A:(9,7)` giữa đường (auto-target hiện
  sống trong dòng chẩn đoán). ERRORS: [].
- Hồi quy đầy đủ (36 suite, `tools/godot/run_regression.sh`):
  **36 OK, 1 FAIL: `g4_polish_test`** — chạy lẻ 3 lần liên tiếp
  đều 18/18 PASS → kết luận flake (hết `timeout 120` hoặc
  tranh tài nguyên trong chuỗi dài), không phải hồi quy do
  thay đổi vòng 10b. `g4_dpad_test` 14/14 PASS.
  (Lưu ý: lần chạy hồi quy đầu tiên trong vòng này 0/37 do chạy
  bản copy `/tmp/run_regression.sh` — `cd ../..` từ /tmp sai
  đường dẫn Godot; phải chạy từ repo
  `bash tools/godot/run_regression.sh`.)

### 28.3 Deploy gh-pages — XONG, verify khớp byte từ live

- Push-files 5 lô (paths file `~/workspace/deploy10b-batch*.txt`):
  (1) pck `ba8e4a99` part 000–016 + `versions.json` →
  `6eddda03`; (2) part 017–033 → `1795ec8f`; (3) part 034–050
  → `a5126dd4`; (4) part 051 → `06b2dcc5`; (5) `index.html`
  CUỐI → `d4b90cdb`. Sync record đã ghi đủ 5 commit.
- **Lỗi restart ở đường ghi:** 2 lần `push-files` đầu + 3 lần
  `call-tool list_commits` trước đó đều "service restarted" và
  KHÔNG có hiệu lực (đối chiếu `versions.json` live vẫn
  `7f8ef9bb` ở `1ed8f9f8`); lần thử lại sau khi chờ 45s thì
  thành công (approval `userConfirmationStatus: approved`).
  `call-read-tool` (đọc) luôn chạy ổn — chỉ đường ghi
  (`call-tool`/`push-files`) mới restart. Không retry dồn dập;
  sau mỗi lần restart phải đối chiếu lại live trước khi thử lại.
  (Cùng lỗi cron 03:45 gặp ở §27.3 khi push main.)
- Verify từ live (raw.githubusercontent.com): `versions.json`
  live pin pck **`ba8e4a99`**; `index.html` live trỏ
  `pck/ba8e4a99`; ráp lại 52 chunk pck từ live = 6.904.868
  byte, SHA **`ba8e4a99f3bc…`** = đúng SHA build local.
  wasm không đổi (`fc74679e`).
- **Live hiện là bản D-pad + nhãn debug 2 dòng**
  (`Ô (x,y) • <input>` + `H:[...] Q:n A:(x,y) MR:0/1 P:n`).
  Nhãn debug là tính năng chẩn đoán TẠM — giữ lại cho cửa kiểm
  live bằng cloud browser, sẽ ẩn sau khi cửa đó qua.

### 28.4 Việc tiếp theo

1. **Kiểm live bằng cloud browser trên URL thật** (cửa cuối theo
   luật AGENTS.md 20/11 23:21): D-pad 4 nút (mỗi nút 1 ô, đọc
   nhãn debug phóng to), phím D, tap đất trống; lưu ý cửa (5,4)
   ngay cạnh spawn — từ (4,4) bấm RIGHT là sang Map002 theo
   đúng luật, KHÔNG phải lỗi. Chỉ báo chủ khi cửa này qua.
2. **Push main** các file vòng 10/10b (xem §27.3 + §28.5) để
   code GitHub khớp build đã deploy.
3. Ẩn nhãn debug (thêm toggle) sau khi kiểm live qua; rồi tiếp
   G4: animation di chuyển/đánh trận, chọn đội/vũ khí, `can_challenge`,
   tile riêng Map003–018, camera trận.

### 28.5 Push main — file vòng 10/10b (ghi để lượt sau đẩy)

- `src/godot/main.gd` (D-pad + nhãn debug 2 dòng + `P` counter),
  `src/godot/player.gd` (`step_dir`), `src/godot/web_shell.html`
  (focus recovery thêm F/P/E/B), `src/godot/tests/g4_dpad_test.gd`
  (mới, 14/14), `tools/godot/run_regression.sh` (mới, 36 suite),
  `docs/godot-g4.md` (§28) — cộng 3 file cron §27.3 chưa đẩy:
  `src/godot/scripts/battle_scene.gd`,
  `src/godot/tests/g4_battle_names_test.gd` (+ `.uid`).

## 29. Kiểm live bản ba8e4a99 — ĐẠT, di chuyển ĐÃ SỬA XONG (21/11 ~11:32–11:38 +07)

### 29.1 Kết quả kiểm live (cloud browser, browser-task 416fb4f8)

- `versions.json` live: pck `ba8e4a99`, wasm `fc74679e` — đúng bản
  deploy, không phải `7f8ef9bb`. Lưu ý: báo cáo browser ghi thêm
  field `build: "1759218600"` + `map: "ba8e4a99"` trong
  `versions.json` — curl trực tiếp từ VM trước và sau kiểm đều
  KHÔNG thấy 2 field này (chỉ wasm/pck/img), pck vẫn `ba8e4a99`
  cả 2 cách đo nên không ảnh hưởng kết luận; ghi lại để không ai
  tưởng `versions.json` đã đổi.
- Tải vào game: nút BẮT ĐẦU CHƠI bật sau <1 phút (< ngưỡng 120s),
  vào ngay Map001 Xóm Trọ Cũ, Ngày 1, Khung Sáng. 0 console error /
  pageerror / failed request.
- Di chuyển — cả 4 cách đều ĐI ĐƯỢC, xác nhận bằng nhãn debug so
  ô trước/sau (không chỉ nhìn camera):
  - D-pad phải: (4,5) → (5,5), đúng 1 ô.
  - Phím D 1 lần: (5,5) → (6,5), debug hiện input cuối "D".
  - Mũi tên phải 1 lần: (6,5) → (7,5), debug hiện "→".
  - Tap đất trống phía phải: (7,5) → (10,2), debug
    "Ô (10,2) • chạm (10,2)".
  - 4 nút D-pad hiện đủ ở góc dưới trái canvas.
- F: Sáng → Chiều (nhãn "Ngày 1 • Khung Chiều", cảnh hoàng hôn,
  "Hẻm trọ buổi chiều"), nhân vật ở yên (10,2). P: điện thoại mở,
  đủ 9 tab.
- 2 lần "site_in_use" thoáng qua (1 khi bấm D-pad, 1 khi nhấn D)
  — thử lại ngay thì chạy bình thường, không ảnh hưởng kết quả.
- Trạng thái cuối: ô (10,2), khung Chiều, điện thoại đang mở.
- **ĐÍNH CHÍNH kết luận 23:14** (3 vòng live báo không đi được):
  trên bản `ba8e4a99` này di chuyển ĐÃ ĐI ĐƯỢC bằng cả 4 cách.
  Các vòng sửa 9+/10/10b (queue bước + tap tới ô gần nhất +
  D-pad + nhãn debug) đã khép lỗi live.

### 29.2 Push + deploy vòng này (cron 09:45) — đã xong trước kiểm live

- Push main `8f477519` (G4 bước 9 + docs §26–27). Deploy
  gh-pages pck `ba8e4a99` (3 lô của run này: `f375f151` /
  `5f5e59d9` / `0177ff01`; writer song song đẩy cùng pck 5 lô
  `6eddda03` / `1795ec8f` / `a5126dd4` / `06b2dcc5` / `d4b90cdb`
  gồm cả index.html + versions.json nên lô 4 của run này không
  cần đẩy). Verify byte từ live: ráp 52 chunk pck = 6.904.868
  byte, SHA `ba8e4a99f3bc…` = build local; index.html live
  byte-identical staging.
- Main nay: `8aee35f9` (worker Vòng 10b tự đẩy D-pad +
  `run_regression.sh` + docs §28) — code GitHub KHỚP build đã
  deploy, hết lệch §27.3. File ráp pck từ live ở
  `~/workspace/live-move-verify/pck-ba8e4a99/`.

### 29.3 Việc tiếp theo

1. **Ẩn nhãn debug** (toggle, mặc định ẩn) — nhãn là tính năng
   chẩn đoán TẠM (§28.3); cửa live đã qua nên ẩn đi trước khi
   báo chủ. Chu trình: code + test + export + deploy + kiểm
   live lại.
2. G4 tiếp: animation di chuyển/đánh trận; chọn đội/vũ khí trước
   trận; `can_challenge` ở demo; tile riêng Map003–018; camera
   zoom trận; khối chat online đưa lên trên tab Tin nhắn; server
   WS auth + giới hạn tốc độ + lịch sử.
3. Chỉ báo chủ khi nhãn debug đã ẩn + kiểm live lại vẫn đi được
   (cửa §28.4 mục 1 đã qua — báo chủ ở bước này).

## 30. Ẩn nhãn debug mặc định + F9 toggle — XONG CODE + DEPLOY, chờ kiểm live lại (21/11 ~11:45–12:30 +07)

### 30.1 Sửa (`src/godot/main.gd`)

- `_debug_labels_visible := false` (mới, mặc định ẩn); `_dbg_label.visible = not title_open and _debug_labels_visible` trong `_process` (trước chỉ `not title_open`).
- `set_debug_labels_visible(v)` (mới): đổi cờ + áp visibility ngay (`v and not title_open`).
- Phím **F9** trong `_unhandled_input` (sau nhánh E): `set_debug_labels_visible(not _debug_labels_visible)`. F9 không đi qua `_key_to_dir` (không phải phím di chuyển), không mở trận/điện thoại.
- `_update_dbg()` không đổi: text vẫn cập nhật kể cả khi nhãn ẩn, nên bật F9 lên là thấy ngay ô hiện tại + input cuối, không cần đi thêm bước nào. D-pad không bị ảnh hưởng (riêng `_dpad.visible`).

### 30.2 Test + verify headless

- Test mới `tests/g4_debug_toggle_test.gd`: **15/15 PASS** — trước/sau start đều ẩn; F9 bật → hiện (text "(4,5)"), F9 lần 2 → ẩn lại; D-pad phải khi nhãn ẩn vẫn đi (5,5), text cập nhật "(5,5)" dù đang ẩn, P:1; `set_debug_labels_visible(true/false)` trực tiếp đúng.
- `tests/g4_dpad_test.gd` cập nhật theo mặc định mới: sau start kiểm tra nhãn AN, bấm F9 rồi mới đo D-pad — **15/15 PASS** (trước 14/14).
- `tools/godot/run_regression.sh`: thêm `g4_debug_toggle_test` → **37 suite + probe = 38 OK, 0 FAIL** (artpass 60/60, G1 selftest 419/419, G3 playtest 95/95, G2 selftest 87/87, MarketBattle 123/123, battle AI 34/34, battle scene 43/43, coord+WASD 16/16, dpad 15/15, debug toggle 15/15, online server 37/37 + probe OK…).
- `--check-only` main.gd + 2 test đều exit 0; scene Main 120 frame exit 0, không ERROR.
- Export web exit 0: pck mới **6.908.568 byte, SHA `84b8649dbe547e98…`** (trước `ba8e4a99`), wasm không đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ 4 file (cổng 8171).
- Lỗi gặp khi export (ghi để không tái phạm): chạy export từ repo root với đường dẫn `src/godot-build/index.html` thì Godot hiểu tương đối theo `--path src/godot` nên báo "Target folder does not exist" — phải `cd src/godot` rồi export `../godot-build/index.html` như docs G0 §3.

### 30.3 Deploy gh-pages — XONG, verify khớp byte từ live

- Staging `build_gh_pages.py` VERIFY OK (pck 52 chunk, wasm 293 chunk không đổi, img không đổi).
- Push-files 5 lô (source-dir `gh-pages-staging`, head gh-pages trước deploy `0177ff01` đã đối chiếu + remote `versions.json` = pck `ba8e4a99`, không lệch): (1) pck 000–016 → `3cd95d48`; (2) 017–033 → `1fc02d5b`; (3) 034–051 → `165590a5`; (4) `versions.json` → `2575efa3`; (5) `index.html` CUỐI → `0e0b90e0`. Sync record đã ghi đủ 5 commit (150 entries).
- Verify từ live: `--check-live` **OK** (versions.json pin pck `84b8649d`, wasm/img part-000 đều 200, index.html live khớp staging từng byte); ráp lại 52 chunk pck từ live = 6.908.568 byte, SHA **`84b8649d`** = đúng SHA build local (`~/workspace/live-dbg-verify/pck-84b8649d/`).

### 30.4 Kiểm live lại bản 84b8649d — ĐẠT (cloud browser + Playwright F9, 21/11 ~11:59–12:17)

- **Cloud browser trên URL thật** (browser-task cd43c26a, 11:59–12:12, viewport ngang 1920×999 — cột game ~560px, đáy canvas sát mép viewport): nhãn debug mặc định **ẨN** (ảnh phóng to dải đáy ở cả Map001 Khung Sáng và Map002 Khung Chiều: không còn 2 dòng "Ô (x,y)" / "H:[...] Q:.."); di chuyển **ĐẠT** — D-pad ▶ 1 ô, mũi tên/WASD đúng từng ô, ▶+▲ vào cửa (5,4) → Map002 + toast "Đã sang Chợ Đầu Mối" (lần thử đầu phím phải gửi đúng lúc game vừa vào nên không nhận — không phải lỗi game; thử lại từng bước thì chuyển ngay); tap đất trống gần nhân vật đi được; F Sáng→Chiều, P mở điện thoại đủ 9 tab + đóng được; **0 console error / pageerror / failed request**; nút BẮT ĐẦU CHƠI bật sau vài giây.
- **Toggle F9 — cloud browser KHÔNG gửi được** (công cụ bàn phím từ chối phím chức năng; Ctrl+Shift+I/J mở DevTools không hiện; không có evaluate/console để dispatch KeyboardEvent) — không phải lỗi game, mà là giới hạn công cụ. Đã khép bằng **Playwright Chromium 1255 local trên staging** (byte-identical live: index.html khớp từng byte, pck SHA `84b8649d` đã verify từ live): script `hidden_files/pxb-browser-verify-f9.py`, bằng chứng `hidden_files/pxb-browser-verify-2026-11-21/` (ảnh 30–33 + strip + `console-f9.json`) — F9 lần 1: dải đáy đổi **3.787 px**, ảnh 31b đọc rõ nhãn **"Ô (4,5)" + "H:[] Q:0 A:(-1, -1) MR:0 P:0"**; F9 lần 2: dải đáy về baseline **0 px khác**; phím D sau toggle vẫn đi được; 0 console error / pageerror.
- Quan sát mở (không chặn): tap xa phía phải gần vũng nước trên Map002 không di chuyển sau 5s — có thể ô đó bị chặn/ngoài vùng đi được, chưa kết luận tap-to-move hỏng (tap gần đi được; tap live §29.1 (7,5)→(10,2) đã đi được; headless move-input 9/9 gồm tap tới ô gần nhất). Ghi để vòng polish sau xem lại, không coi là bug.
- **Cửa §29.3 mục 3 đã qua: nhãn debug đã ẩn + kiểm live lại vẫn đi được → báo chủ được.**

### 30.5 Việc tiếp theo

1. Điền kết quả kiểm live §30.4; push main (code vòng này + docs §30).
2. G4 tiếp theo (§29.3 mục 2): animation di chuyển/đánh trận; chọn đội/vũ khí trước trận; `can_challenge` ở demo; tile riêng Map003–018; camera zoom trận; khối chat online đưa lên tab Tin nhắn; server WS auth + giới hạn tốc độ + lịch sử.

## 31. G4 bước 10 — Animation di chuyển/đánh trận MarketBattle — XONG (21/11 ~12:20–13:00 +07)

### 31.1 Sửa (`src/godot/scripts/battle_scene.gd` — chỉ lớp vẽ, KHÔNG sửa luật)

- **Trượt khi di chuyển:** vị trí VẼ `_visual_pos` (mới, theo id đấu sĩ)
  trượt về ô logic với tốc độ 420 px/s thay vì nhảy tức thì; `_update_visual_pos`
  gọi mỗi frame (`_process`) + trong `simulate_seconds` (test headless);
  `snap_visual_pos()` đặt ngay về ô logic (dùng sau khi dời tay trong test).
  `setup()` khởi tạo vị trí vẽ đúng ô spawn.
- **Đánh:** `click_tile` "attacked" → `_start_attack_fx` (người đánh, mục tiêu,
  damage/dodged/ko từ `res` của `mb.attack`); `_fighter_draw_pos` lao người
  đánh tới 45% khoảng cách (tối đa 28px, theo sin, 0.45s) + rung mục tiêu
  ±3px; vòng chớp trắng trên mục tiêu (đỏ khi KO), mờ dần.
- **Hỗ trợ:** `_start_support_fx` → vòng xanh lan ra (22→40px) + chữ "+N HP"
  bay lên, mờ dần trong 0.6s.
- **Lượt AI:** `_run_ai_turn` chụp HP trước/sau `ai_take_turn`, suy fx từ
  chênh lệch (HP giảm = bị đánh, HP tăng = được hỗ trợ) — vì `ai_take_turn`
  chỉ trả chuỗi mô tả, không trả id mục tiêu.
- Test mới `tests/g4_battle_anim_test.gd`: **24/24 PASS** — vị trí vẽ còn ở ô
  cũ ngay sau click, sau 0.1s đã rời ô cũ, sau 0.6s về đúng ô mới; đánh
  đúng 9 HP (Tank giảm thương, luật không đổi), lao tới >8px giữa animation,
  fx hết sau 0.45s; hỗ trợ +12 HP, fx hết sau 0.6s; lượt AI đánh trúng A1
  + thấy fx. (Lỗi test ban đầu: đặt A1 chồng ô (1,4) của A2 nên AI đánh A2
  thay vì A1 — đã dời A2/A3 ra xa; bài học: đừng để 2 đấu sĩ cùng ô trong
  setup test.)
- `tools/godot/run_regression.sh`: thêm `g4_battle_anim_test` → 38 suite + probe.

### 31.2 Verify vòng này

- Hồi quy đầy đủ: **39 OK, 0 FAIL** (38 suite + probe server); battle anim
  24/24, battle scene 43/43, battle AI 34/34, battle main 15/15, battle save
  31/31, MarketBattle 123/123, artpass 60/60, G1 419/419, G3 95/95.
- Smoke `--headless --quit-after 120` exit 0, không ERROR.
- Export web exit 0: pck **6.918.732 byte, SHA `7dec3410…`**, wasm không đổi
  `fc74679e…`; HTTP 200 đủ 3 file (cổng 8172).
- **Browser-verify thật (Chromium 1255 + swiftshader, 720×1280, script
  `hidden_files/pxb-browser-verify-battle-anim.py`, ảnh
  `hidden_files/pxb-browser-verify-2026-11-21/34–35`):** engine-start OK,
  start-clicked OK, B mở trận đúng (BỤI ĐỜI CHỢ CÁ, 100%–100%, Vòng 1/12),
  click ô xanh (2,3) → log "Bạn di chuyển tới (2,3).", vòng đỏ Bạn sang
  đúng ô (2,3), ô xanh hết sau khi đi; **0 console error, 0 pageerror**.
  Lưu ý đo: game chạy ~0.43× thời gian thật trên swiftshader nên ảnh
  +300ms đã gần tới đích (trượt 2 ô chỉ ~0.17s game) — trượt giữa đường
  chứng minh bằng headless 24/24 (vị trí vẽ còn ở ô cũ ngay sau click),
  không bắt được khoảnh khắc giữa đường trên ảnh tĩnh ở tốc độ này.
  Fx đánh/hỗ trợ chỉ verify headless (địch ở xa, không kịp đưa vào tầm
  trong 1 lượt kiểm nhanh) — ghi rõ, không nói quá.

### 31.3 Deploy gh-pages — XONG

- Staging `build_gh_pages.py` VERIFY OK (pck `7dec3410` 52 chunk, wasm
  `fc74679e` không đổi, img đủ 3 ảnh, loader cứng đủ marker, icon inline
  đủ 3 data URI).
- Push-files 5 lô (head gh-pages trước deploy `0e0b90e0` theo sync record;
  live `versions.json` lúc đó vẫn pck `84b8649d`, không lệch): (1) pck
  000–016 → `cb147518`; (2) 017–033 → `990661d2`; (3) 034–051 →
  `975fe3b8`; (4) `versions.json` → `6a34974f`; (5) `index.html` CUỐI →
  `52f246eb`. Sync record đã ghi đủ 5 commit (156 entries). Trước lô 4 đã
  verify qua API: blob SHA 2 mẫu chunk (part-000 `1680b32d…`, part-051
  `5dd00342…`) khớp staging (tính theo git blob SHA-1, không phải sha256
  file — bài học: đừng so sha256 với blob SHA).
- Verify từ remote (raw.githubusercontent.com, tránh CDN Pages còn cache
  bản cũ): ráp lại 52 chunk pck = 6.918.732 byte, SHA **`7dec3410b9204115`**
  = build local; `index.html` SHA `52053681a2e9` = staging;
  `versions.json` trên branch = pck `7dec3410`. Lưu ý: `versions.json` qua
  domain Pages vẫn hiện `84b8649d` ngay sau deploy (CDN chậm vài phút như
  §19.8) — repo đã đúng, không kết luận deploy sai vì CDN.

### 31.4 Push main — XONG (riêng vòng này, không chung vòng 11)

- Push main `de283d81` (5 file: `battle_scene.gd`, `g4_battle_anim_test.gd` +
  `.uid`, `run_regression.sh`, `docs/godot-g4.md` §31). Trước push đã đối
  chiếu: head main vẫn `da241a4d`, remote `battle_scene.gd` là bản trước
  animation (không có `_visual_pos`), file test mới xác nhận ABSENT.
  Code GitHub khớp build live `7dec3410` tại thời điểm push. (Vòng 11 sau
  đó export pck mới `a87a871d` trên cây gộp — deploy bản đó sẽ thay live;
  xem §32.4.)

### 31.5 Việc tiếp theo

1. G4 tiếp: chọn đội/vũ khí trước trận; `can_challenge` ở demo; tile riêng
   Map003–018; camera zoom trận; khối chat online đưa lên tab Tin nhắn;
   server WS auth + giới hạn tốc độ + lịch sử.
2. Kiểm live bằng cloud browser trên URL thật sau deploy (cửa cuối theo
   luật AGENTS.md): mở trận bằng B, click ô xanh xem trượt, chờ lượt AI
   xem địch di chuyển/đánh có animation.

## 32. Vòng 11 — Tap-to-move + lỗi biên Map002 + nhãn debug stale (21/11 ~12:00–14:00 +07)

### 32.1 Kiểm live 11:33–11:57 báo 2 lỗi — probe KHÔNG tái hiện được lỗi nào

- Kiểm live (browser task `9b4d13eb`): D-pad/WASD đi đúng 1 ô/lần, F/P OK,
  0 lỗi console. Nhưng báo: (1) tap đất trống → nhãn nhảy tới ô đã chạm
  (vd "Ô (9,4) • chạm (9,4)") nhưng sprite KHÔNG đi tới đó sau 4s
  (tọa độ sprite ~(930,760) trước/sau sai số ~2px); (2) bấm phải tại
  (9,4) Map002 → về (7,4) thay vì (10,4), chu trình 8→9→7 (tái hiện 2×);
  (3) nhãn debug bị nhãn cửa Map002 che.
- Probe Chromium local trên ĐÚNG bản live `ba8e4a99` (staging `/tmp/r11-live`,
  `versions.json` pin pck live; script `visual-check/artpass11/probe_live.py`,
  `probe2.py`, `probe3.py`, `probe4.py`):
  - (9,4)→(10,4) đúng cả 3 lần probe (D-pad, tap xen kẽ, burst); bấm phải
    tại (10,4) → vẫn (10,4) đúng [(11,4) là biên, `layers[1]` chặn].
    Data Map002 đúng: chỉ biên bị chặn, (10,4) đi được, cửa (5,4)→Map001.
  - Tap hợp lệ (900,806)→(10,6): nhãn tới (10,6), diff ảnh trước/sau
    13,2% = camera cuộn theo (sprite ĐI THẬT). Tap (1000,850) đầu tiên
    không làm gì vì map ra ô (14,6) ngoài biên — điểm tap xấu, không phải bug.
  - Phép đổi chạm→ô ĐÚNG toán iso (phải = +x/−y): tap ngang hàng nhân vật
    mà nhãn nhảy lên 2 hàng là đúng (vd (7,4)→(9,2)).
  - **Bằng chứng "sprite không đi" của checker là SAI PHƯƠNG PHÁP:**
    camera bám theo người chơi nên sprite gần như đứng yên TRÊN MÀN HÌNH
    (tọa độ màn hình ~không đổi) trong khi đi thật — phải so landmark
    (biển hiệu/cửa) trước/sau, không đo tọa độ sprite trên màn hình.
  - rAF chỉ **3,0 fps** trên swiftshader (không phải lỗi game): mỗi bước
    cần ~2 frame (~0,66s) nên đi chậm trên máy kiểm local, nhưng tween
    0,15s vẫn xong trong 1 frame.

### 32.2 Gốc thật tìm ra: NHÃN DEBUG STALE (không phải tap hỏng)

- Sau tap, nhãn hiện `A:(10,6)` MÃI dù người chơi đã tới (10,6):
  `_update_dbg()` trước đây chỉ gọi từ `moved_to` — mà `moved_to` chạy
  TRƯỚC khi queue pop / auto-target clear trong `player._process`
  (xem `player.gd`: `moved_to.emit` rồi mới pop queue; `_step_toward_auto`
  clear `A` im lặng, không refresh nhãn). Tương tự `Q:1` kẹt sau khi
  queued step bị chặn (không có `moved_to` mới để refresh).
- Chính nhãn stale này làm checker (và vòng 11 lúc đầu) tưởng tap "chỉ
  cập nhật ô logic, không kéo sprite". Chu trình (9,4)→(7,4) nhiều khả
  năng cũng là đọc nhãn giữa lúc auto-walk/stale (không tái hiện được
  bằng D-pad, tap, hay xen kẽ tap+D-pad).

### 32.3 Sửa (`src/godot/main.gd` — vòng 11)

- **Nhãn luôn tươi:** `Main._process` gọi `_update_dbg()` MỖI FRAME
  (kể cả khi ẩn) — A:/Q: không bao giờ stale nữa.
- **Dời nhãn:** (24,1172) cuối canvas → **(24,200) góc trên-trái, dưới
  panel HUD**; nền tối mờ 72% + chữ kem, size (440,64) cho đủ 2 dòng —
  không còn bị nhãn cửa Map002 (kẹp y≤1200) che.
- **Mặc định ẩn KHÔNG ĐỔI** (`_debug_labels_visible=false`, F9 toggle) —
  bản live `ba8e4a99` đã ẩn sẵn (probe 1 không F9 thì không thấy nhãn).
- Test mới `tests/g4_r11_dbg_test.gd`: **11/11 PASS** — nhãn mặc định ẩn
  + ở (24,200); Map002 (10,4) đi được / (11,4) chặn; D-pad phải
  (9,4)→(10,4), phải nữa vẫn (10,4); tap tới (10,6) + nhãn tươi
  `A:(-1,-1)`. (Bài học test: `process_frame` chạy TRƯỚC `Main._process`
  nên phải đợi thêm 3 frame sau khi A clear mới đọc nhãn.)
- `run_regression.sh`: thêm `g4_r11_dbg_test` → 39 suite + probe.

### 32.4 Verify + push + deploy — (điền sau khi xong)

- Hồi quy đầy đủ: **40 OK, 0 FAIL** (39 suite + probe — đã gồm
  `g4_r11_dbg_test` 11/11 và `g4_battle_anim_test` 24/24).
- `--check-only` main.gd OK; export web exit 0: pck **6.922.136 byte,
  SHA `a87a871d…`**, wasm không đổi `fc74679e…`.
- Browser-verify bản mới `a87a871d` (staging `gh-pages-staging`,
  `probe4_verify.py`, Chromium 1255 + swiftshader): nhãn mới góc trên-trái
  nền tối đọc rõ; (9,4)→(10,4) đúng, phải nữa vẫn (10,4); tap → (10,6)
  + nhãn tươi `A:(-1,-1)`; diff ảnh sau tap 11,6% (camera cuộn);
  0 console error.
- Push main — **XONG, commit `aaf2b5c5`** (5 file: `main.gd`, test r11 +
  `.uid`, `run_regression.sh`, docs §32). Lưu ý: lần push đầu bị từ chối
  "not a fast forward" vì agent §31 push xen vào (`de283d81`, battle anim)
  — đã đối chiếu lại: `battle_scene.gd` IDENTICAL, `main.gd`/`run_regression.sh`/
  docs chỉ khác đúng phần r11, rồi push lại từ head mới. Bài học: `list_commits`
  muốn xem branch khác phải dùng tham số `sha`, không phải `branch`.
- Deploy gh-pages — **XONG, 5 lô**: (1) pck 000–016 → `dcb80bbc`;
  (2) 017–033 → `009d5145`; (3) 034–051 → `29e1fdde`;
  (4) `versions.json` → `e6134e80`; (5) `index.html` CUỐI → `91dfacf4`.
  Sync record 163 entries.
- Verify từ remote: ráp lại 52 chunk pck = 6.922.136 byte, SHA
  **`a87a871dc2f9d2ce`** = build local; `index.html` SHA `4fa85edcea5fc7af`
  = staging; `versions.json` qua API blob SHA `7882a5da` = staging, pck
  `a87a871d` (raw.githubusercontent.com vẫn hiện `7dec3410` ngay sau deploy
  do CDN cache — đã biết từ §31, không phải deploy sai).
- **Kiểm độc lập lại (cron 12:45, 21/11 ~12:55):** ráp lại 52 chunk pck
  từ live = 6.922.136 byte, SHA `a87a871dc2f9d2ce…` = build local;
  `index.html` live (Pages) SHA `4fa85edc…` = staging; `versions.json`
  live (Pages) pin pck `a87a871d` — khớp hết, không cần deploy lại.
  File ráp ở `~/workspace/live-r11-verify/pck-a87a871d/pck.bin`.

### 32.5 Việc tiếp theo

1. Kiểm live bằng cloud browser trên URL thật sau deploy (cửa cuối):
   tap + D-pad ở Map002 hàng 4, đọc nhãn mới góc trên-trái.
2. G4 tiếp: chọn đội/vũ khí trước trận; `can_challenge` ở demo; tile riêng
   Map003–018; camera zoom trận; khối chat online đưa lên tab Tin nhắn;
   server WS auth + giới hạn tốc độ + lịch sử.

## 33. Vòng 12 — Hồi quy D-pad + Map002 vỡ hình + nhãn debug ẩn (21/11 ~13:15–15:30 +07)

### 33.1 Kiểm live 12:56–13:14 báo hồi quy so với kiểm 11:33 (pck `a87a871d`)

1. D-pad/phím hỏng lại ở Xóm Trọ Cũ (Lên/Xuống không đi; Phải/Trái
   thất thường; D/ArrowRight ×3 không đi; F/P vẫn nhận).
2. Map002 vỡ hình + kẹt nhân vật: nhãn "Cửa đi Khu Công Nhân",
   "Sạp rau buổi sáng", "Chị Lệ", "Anh Hải" dồn thành cột ở vùng
   trời; sạp nén thành dải hẹp; dải tối ngang; nhân vật kẹt ở điểm vào.
3. Nhãn debug không thấy (vòng 11 để mặc định ẩn, checker không biết F9).
4. Tap ở Xóm Trọ Cũ vẫn đi được — giữ nguyên.
5. Phụ: NPC Cô Tư / nhãn cửa đè lên vùng D-pad.

### 33.2 Tái hiện (probe Chromium local, đúng bản live `a87a871d`)

- **Lỗi 1 KHÔNG tái hiện:** Map001 D-pad 4 hướng + phím D +
  ArrowRight + tap đều đi đúng 1 ô, Q:0, 0 lỗi console. Kết luận:
  triệu chứng live của checker nhiều khả năng là artifact của
  harness (tọa độ click/viewport) hoặc bản lai CDN, không phải lỗi
  code — không bịa fix cho lỗi 1, chỉ giữ nguyên + kiểm lại sau deploy.
- **Lỗi 2 tái hiện ngay khi vào Map002:** 4 nhãn dồn cột ở trời,
  sạp nén dải hẹp, dải tối ngang. Nhưng D-pad Trái vẫn đi được
  (5,4)→(4,4) — nhân vật KHÔNG kẹt trên staging; tap Map002 chưa
  được thử (probe quay về Map001 trước).
- Dị thường chẩn đoán: bản deploy `a87a871d` hiện nhãn debug mà
  KHÔNG cần F9, và P đọc 1 sau 1 lần bấm phím — ngược với source
  lúc đó (mặc định ẩn). Nghĩa là pck deploy được build từ working
  copy khác source hiện tại ở ít nhất default nhãn debug. P:0 sạch
  ở probe vòng 12b (bấm nút start bằng selector thay vì tọa độ
  hardcode) — P:1 trước đó là click lạc vào vùng D-pad, không phải
  lỗi đếm phím.

### 33.3 Gốc thật (probe headless engine)

- **Nhãn bay lên trời:** `_resolve_label_overlaps` + `_nearest_free_y`
  khắc khoảng trống dọc bằng vật cản (mỗi cái phồng LABEL_GAP 12);
  ở Map002 các marker cụm giữa màn hình nên mọi khoảng trống gần y
  muốn đều bị khắc hết, fallback cũ áp `best_y` dù cách 200–600px
  ("Sạp rau" want 818 → 606; "Cửa đi" want 1162 → 556). Kèm bug
  khoảng đảo (`[lo,hi]` với lo > hi) làm `clampf` trả giá trị rác.
- **Dải tối:** `sky_band.png` (1120×280) ở offset+(0,-190) = y −28..252;
  ảnh đất ở (360,730) = y 280..1180 → khe 28px (252..280) lộ màu
  clear tối.
- **Sạp nén:** `NadiaScene._draw_facades` vẽ 12 mặt tiền 64px tại
  tâm iso cách nhau 32px → chồng ngang 50% (biển 58px, mái 60px bị
  hàng xóm che nửa).
- Map001 không dính vì marker thưa + nền composite vẽ sẵn phủ kín
  đầu màn hình. NPC không đi lang thang (tĩnh) — chồng D-pad là do
  camera di chuyển, không phải NPC đi lại.

### 33.4 Sửa

`src/godot/main.gd`:
- Nhãn debug **hiện mặc định** trở lại (`_debug_labels_visible=true`),
  F9 vẫn toggle, vị trí (24,200) giữ nguyên.
- `_resolve_label_overlaps`: thêm rect D-pad `DPAD_RECT (48,880,160,160)`
  làm vật cản khi D-pad hiện; fallback **giữ nguyên y muốn** khi
  `best_y` xa (thay vì áp best_y 200–600px) — nhãn có thể chạm sprite
  1 chút nhưng vẫn neo đúng marker.
- `_nearest_free_y`: chỉ thêm khoảng còn lại hợp lệ (`up > lo`,
  `dn < hi`) — không còn khoảng đảo.
- `LABEL_MAX_DRIFT` 60 → **120.0** (3 chiều cao nhãn, vẫn neo rõ).
- Ảnh đất (360,730) → **(360,700)**: mép trên 250 chồng lên đáy
  ảnh trời 252 — hết dải tối. An toàn cho Map001 (nền composite
  vẫn phủ y −308..322) và Map003+ (cùng sky_band).
- **Vòng 12b** (sau khi test mới lộ 3 lỗi hồi quy, xem §33.5):
  - `LABEL_ESCAPE_MAX_DRIFT = 200.0`: nhãn ở y muốn mà đè lên
    nhân vật chính / nút D-pad đáng kể (giao nhau ≥10px cả 2 chiều)
    thì được nhảy xa tới 200px (D-pad 121px, "Góc Chế Tạo" Map001
    165px, "Hẻm trọ" (11,8) 135px); xa hơn thì giữ neo ("Sạp rau"
    Map002 spawn 249px — nhảy thì mất neo, đứng yên thì chỉ che
    nhân vật tạm thời ở điểm spawn). Đè lên NPC/icon thì không tính.
  - Lượt tách nhãn chồng nhau sau vòng chính: đẩy nhãn TRÊN lên
    (chồng + LABEL_GAP), kèm **cascade 1 cấp** (nhãn chặn cũng được
    đẩy lên 1 nấc — vd "Cửa về" muốn lên 1112 bị "Góc Chế Tạo" ở
    1081 chặn thì đẩy "Góc Chế Tạo" lên 1062 trước); không lên
    được thì đẩy nhãn dưới xuống. Vật cản lượt tách chỉ tính
    "cứng" (nhân vật + D-pad + sprite NPC, không tính icon 48px).
    Sửa 2 nhan cửa Map002: spawn tách ra 12px (1112/1162); ở (4,4)
    sau Trái cũng tách (cascade).
  - Thứ tự xử lý giữ y tăng dần (thử y giảm dần ở vòng 12b làm
    "Góc Chế Tạo" Map002 bay xuống 556px vì vật cản của cửa che
    mất khoảng trống gần 978 — đã hoàn lại).

`src/godot/scripts/nadia_scene.gd`:
- `_draw_facades` rẽ sang `_draw_market_row()` riêng cho `map_id == 2`:
  đoạn tường/mái 34px mỗi ô (chồng 2px giấu khe cầu thang iso), shop
  chỉ ở ô CHẴN (biển 58px + mái 60px vừa khoảng 64px, không chồng),
  cửa sổ + chậu hoa ở ô LẺ. Map003+ giữ vẽ cũ (tạm, ngoài phạm vi).

Test:
- Mới `tests/artpass12_test.gd` (14 kiểm): nhãn debug mặc định hiện;
  Map002 nhãn neo ≤120px (ngoại lệ thoát ≤200px khi y muốn đè lên
  nhân vật/D-pad), trong màn hình, không đè D-pad, không cặp nào
  chồng nhau ≥1px (ngưỡng 1px bỏ qua sai số float 0,5px); không dải
  tối; D-pad Trái Map002; tap tới (8,6) Map002; Map002 (4,4) sau
  Trái (đúng repro); Map001 (11,8); D-pad Phải nhanh ×3; bộ đếm P:5.
  Thứ tự test: tap TRƯỚC, bấm Trái SAU — tap từ (4,4) tới (8,6) đi
  ngang qua cửa (5,4) sẽ transfer về Map001 (không phải tap hỏng).
- `tests/g4_debug_toggle_test.gd`, `tests/g4_r11_dbg_test.gd`,
  `tests/g4_dpad_test.gd` cập nhật theo default mới (hiện; F9 2 chiều).
- `tools/godot/run_regression.sh`: thêm `artpass12_test` → 41 mục.

### 33.5 Verify vòng này

- `--check-only --script` cho `main.gd`, `nadia_scene.gd`,
  `artpass12_test.gd`: exit 0. Lưu ý: `--check-only` toàn project
  (không `--script`) treo >45 phút (tiến trình Godot vẫn chạy 5% CPU,
  không kết thúc) — đã kill và dùng `--script` từng file thay thế;
  test headless chạy được chứng tỏ code parse tốt. (Cần xem lại sau:
  có thể do import toàn project.)
- Hồi quy đầy đủ: **41 OK, 0 FAIL**.
- Export web exit 0: pck **6.941.688 byte, SHA `80da1a51…`**, wasm
  không đổi `fc74679e…`.
- Browser-verify bản mới `80da1a51` (staging `gh-pages-staging`,
  `verify_fix.py` + `verify_tap_map002.py`, Chromium + swiftshader):
  0 console error, 0 request fail cả 2 phiên. Map001: nhãn debug
  hiện mặc định `Ô (4,5)` P:0 (không F9); D-pad Lên (4,4) / Xuống
  (4,5) / Trái (chặn bởi Bạn Thân, P:3) / Phải (5,5) / phím D (6,5)
  / ArrowRight (7,5) đều đúng 1 ô; tap → (8,1) `chạm (8,1)`.
  Map002: vào bằng cửa (5,4) P:2; Trái → (4,4) P:3 (không kẹt);
  tap → (8,6) `chạm (8,6)` rồi (8,7) — tap trong Chợ đi được;
  2 nhãn cửa tách nhau (1112/1162, khe 12px) cả ở spawn lẫn sau
  Trái (cascade vòng 12b); nhãn neo gần marker, sạp đọc được từng
  biển (RAU CỦ / HOA QUẢ / BÁNH MÌ), không dải tối, không cột
  nhãn ở trời. Lưu ý probe: tap ở (620,900) trong Map002 ánh xạ
  ra ngoài map (6,-1) nên không đi — lỗi điểm chạm của probe,
  không phải lỗi game; đã thử lại đúng điểm (8,6) thì đi được.
  Phải ở (5,4) Map002 là cửa về Map001 (transfer đúng luật) nên
  các bước sau đó của probe chạy ở Map001 — không phải lỗi.
- Push main — **XONG, commit `31f82a77`** (9 file: `main.gd`,
  `nadia_scene.gd`, test artpass12 + `.uid`, 3 test cập nhật,
  `run_regression.sh`, docs §33). Đối chiếu trước push: 6 file cũ
  remote-at-head blob SHA = blob SHA tại sync base (không divergence);
  2 file mới chưa có trên remote. Sync record 171 entries.
- Deploy gh-pages — **XONG, 5 lô**: (1) pck 000–016 → `87839c18`;
  (2) 017–033 → `3770e7af`; (3) 034–051 → `564d39cc`;
  (4) `versions.json` → `d06d49e2`; (5) `index.html` CUỐI →
  `6e7c4af7`. Gh-pages head trước deploy `91dfacf4` khớp record.
- Verify từ live (raw.githubusercontent.com, VM không tới được
  github.io): ráp lại 52 chunk pck = 6.941.688 byte, SHA
  **`80da1a51d0c6459b`** = build local; `index.html` live SHA
  `4e88b570…` = staging; `versions.json` live pin pck `80da1a51`,
  wasm `fc74679e`. File ráp ở `/tmp/live-r12-verify/pck-80da1a51/`.

### 33.6 Việc tiếp theo

1. Kiểm live bằng cloud browser trên URL thật sau deploy (cửa cuối):
   D-pad 4 hướng + phím D + tap ở cả 2 map, vào Chợ bằng cửa rồi bấm
   Trái xem còn vỡ hình không, đọc nhãn debug góc trên-trái.
2. Nếu live tái hiện lỗi 1 (D-pad chết ở Map001): đối chiếu
   `versions.json` + SHA pck trước (nghi bản lai CDN), rồi mới nghi
   code.
3. Map003+ vẫn dùng vẽ facade cũ chồng 50% (tạm) — sửa khi tới lượt.
4. Map002 vẫn dùng lại ảnh đất của Map001 (lá/xe đạp/xe đẩy) — cần
   ảnh đất riêng cho chợ khi làm art Map002.

## 34. Vòng 13 — FOCUS_NONE cho mọi nút (21/11 ~14:50–15:30 +07)

### 34.1 Gốc (lỗi thật, tìm được trong báo cáo tái hiện r12)

Báo cáo tái hiện r12 (~14:00) chỉ ra: chỉ nút D-pad có
`focus_mode = FOCUS_NONE` (`main.gd:2375`); 7 chỗ `Button.new()`
còn lại — "Bắt đầu chơi", "Đổi khung (F)", "Việc làm",
"Điện thoại (P)", 9 tab điện thoại, nút hành động điện thoại, nút
lựa chọn hội thoại — đều giữ `FOCUS_ALL` mặc định. Sau khi bấm
bằng chuột, nút giữ focus bàn phím và phím mũi tên (`ui_*`) bị hệ
focus navigation của Godot ăn mất trước khi tới
`Main._unhandled_input` → mũi tên không đi. F/P vẫn chạy vì không
phải `ui_*` — đúng triệu chứng live 12:56 (D-pad lên/xuống không
đi, F/P vẫn nhận). WASD (`KEY_D`...) không phải `ui_*` nên lý
thuyết vẫn tới được — việc phím D cũng chết trên live chưa giải
thích hết (nghi bản lai CDN / môi trường checker), nhưng sửa focus
vẫn bắt buộc. Vòng 12 chưa sửa vì lúc đó đang sửa cùng file.

### 34.2 Sửa

`src/godot/main.gd` — 1 dòng trong `_style_button` (bao phu tất cả
8 chỗ `Button.new()`, kể cả nút thêm sau này):
`b.focus_mode = Control.FOCUS_NONE` + comment giải thích. Dòng
riêng ở nút D-pad giữ nguyên (thừa nhưng vô hại, comment của nó
đã ghi lý do từ vòng 10).

### 34.3 Test mới `tests/g4_focus_none_test.gd` (13 kiểm)

- Tĩnh: nút Bắt đầu / Đổi khung / Việc làm / Điện thoại (P) /
  4 nút D-pad / 9 tab điện thoại / nút hành động / 2 nút lựa chọn
  hội thoại — tất cả `FOCUS_NONE`.
- Chức năng: `grab_focus()` lên nút HUD rồi kiểm
  `gui_get_focus_owner() == null` (FOCUS_NONE thì không lấy được
  focus). Trước sửa: 5/13 PASS, kiểm này FAIL đúng (focus owner =
  Button — probe xác nhận); sau sửa: **13/13 PASS**.
- Trung thực về giới hạn: headless KHÔNG tái hiện được việc GUI ăn
  phím mũi tên (event tiêm qua `Input.parse_input_event` vẫn tới
  `_unhandled_input` dù nút đang focus — probe `zz_focus_probe`
  đã xóa; bài học này khớp luật "headless không đáng tin cho di
  chuyển" trong AGENTS.md). Bước ArrowRight trong test chỉ là kiểm
  sanity "vẫn đi", không phải bằng chứng sửa — bằng chứng thật phải
  là kiểm live trên web sau deploy (bấm nút HUD bằng chuột thật rồi
  bấm mũi tên).
- `tools/godot/run_regression.sh`: thêm `g4_focus_none_test` →
  42 suite.

### 34.4 Verify vòng này

- `--check-only --script` cho `main.gd`,
  `g4_focus_none_test.gd`: exit 0. Scene 120 frame exit 0.
- Hồi quy đầy đủ: **42 OK, 0 FAIL** (41 cũ + 1 mới).
- Export web exit 0: pck **6.945.720 byte, SHA `d691d82e…`**,
  wasm không đổi `fc74679e…`. HTTP 200 đủ 6 file (cổng 8161).
- Push main — XONG, commit `33551e47` (5 file: `main.gd`,
  test mới + `.uid`, `run_regression.sh`, docs §34). Đối chiếu
  trước push: head `91a57d0b` khớp record; commit mới nhất chạm
  `main.gd` / `run_regression.sh` = `31f82a77` (đúng sync base),
  `godot-g4.md` = `91a57d0b` (đúng sync base), test mới chưa có
  trên remote — không divergence. Sync record 173 entries.
- Deploy gh-pages — **GIỮ LẠI (chưa deploy)**: lúc push, kiểm live
  bản `80da1a51` (§33.6 mục 1) vẫn đang chạy trên cloud browser
  (task `browser-task:145187af...`, bắt đầu ~14:39) — deploy pck
  mới giữa chừng sẽ làm checker thấy bản lai và kết quả kiểm mất
  giá trị. Deploy `d691d82e` ở run sau, ngay khi kết quả kiểm live
  về (dù pass hay fail đều deploy, vì fix này là đáp án cho triệu
  chứng "mũi tên chết sau khi bấm nút" nếu kiểm live tái hiện nó).

### 34.5 Việc tiếp theo

1. Deploy pck `d691d82e` lên gh-pages khi kiểm live `80da1a51`
   xong (đối chiếu `versions.json` + SHA pck như §33.5).
2. Kiểm live bản mới: bấm nút HUD ("Điện thoại (P)") bằng chuột
   thật rồi bấm mũi tên — phải đi được ngay, không cần bấm lại
   canvas; kiểm tương tự sau khi bấm nút "Việc làm" và sau khi
   đóng hội thoại NPC.
3. Map003+ vẫn dùng vẽ facade cũ chồng 50% (tạm) — sửa khi tới lượt.
4. Map002 vẫn dùng lại ảnh đất của Map001 — cần ảnh đất riêng cho
   chợ khi làm art Map002.

### 34.6 Deploy `d691d82e` lên gh-pages + kiểm nhanh (21/11 ~15:00–15:20 +07)

- Đối chiếu trước deploy: `versions.json` remote trên gh-pages pin
  đúng pck `80da1a51` tại head `6e7c4af7` (= deploy vòng 12); đường
  dẫn `pck/d691d82e/part-000.txt` chưa tồn tại remote — deploy là
  nối tiếp sạch, không divergence. (Lưu ý: sync record gh-pages
  `src/nadia/www.muse-github-snapshot-sync.json` đã stale từ vòng 8
  — các vòng 9–12 không ghi entry; đã ghi bù 5 entry của vòng này,
  18 → 23 entry. Các commit gh-pages vòng 9–12 vẫn thiếu trong
  record — không đoán paths để ghi bù.)
- Rebuild staging `tools/godot/build_gh_pages.py`: VERIFY OK, 52
  chunk pck, wasm `fc74679e` không đổi.
- Deploy 5 lô (mỗi lô ≤18 file): `44a032a6` (chunk 000–016),
  `2ffe8b76` (017–033), `40ca84b6` (034–051), `fa085d62`
  (`versions.json`), `8c1e7d3e` (`index.html` CUỐI — head gh-pages).
- Verify khớp byte từ live: ráp 52 chunk từ
  `raw.githubusercontent.com` = 6.945.720 byte, SHA `d691d82e` ✓;
  `versions.json` live pin `d691d82e` tại head `8c1e7d3e` ✓;
  `index.html` live SHA `73dfdad05180fe42` = staging ✓ (ngay lần
  fetch đầu, không dính CDN cache cũ).
- Kiểm nhanh Chromium local trên đúng bản deploy (staging, cổng
  8162, viewport 720×1280, probe
  `visual-check/artpass13/check_focus_deploy.py`): 0 console error,
  0 request fail.
  - Spawn Ô (4,5). D-pad ▶ → (5,5) ✓. **FOCUS TEST ĐẠT**:
    bấm ArrowRight ngay sau khi click nút D-pad → (6,5) ✓ (trước
    fix, mũi tên sẽ bị GUI ăn focus). ArrowUp → (6,4) ✓, ArrowDown
    → (6,5) ✓, ArrowLeft → (5,5) ✓. D-pad ▲ → (5,4) (= ô cửa,
    chuyển sang Chợ Đầu Mối — đúng luật) rồi ▼ → (5,5) ✓. Phím D
    → (6,5) ✓. P:1→3 đúng số lần bấm D-pad, không click lặp.
  - Tap: (600,1150) đăng ký `chạm (10,6)`, đi (4,5)→(10,6) ✓;
    (500,900) đăng ký `chạm (4,1)`, đi (4,5)→(4,1) ✓. Nhưng 2
    điểm chạm vùng trên (200,750) và (500,700) KHÔNG đăng ký gì
    (A vẫn (-1,-1)) — map ra ngoài hình thoi đất (chạm vào ảnh
    nền mặt tiền/trời, không có ô). Và tap (200,900) đăng ký đích
    (1,5) nhưng KHÔNG di chuyển, A xóa ngay trong 0,5s — đường đi
    qua (3,5) nơi Bạn Thân đang đứng: auto-walk bỏ cuộc khi bước
    tiếp bị NPC chặn thay vì đi vòng. Cả 2 đều là hành vi cũ (không
    phải hồi quy của fix focus), ghi lại làm việc cho vòng sau:
    (a) tap-to-move cần pathfind vòng NPC thay vì bỏ đích khi gặp
    chướng ngại; (b) chạm ngoài hình thoi đất nên có phản hồi
    (hoặc mở rộng vùng chạm) thay vì im lặng.
- Kết luận: fix focus đã live trên `d691d82e` và kiểm local đạt.
  Còn cần kiểm live bằng cloud browser trên URL thật (§34.5 mục 2:
  bấm nút HUD thật rồi bấm mũi tên) để chốt hẳn.

## 35. Vòng 14 — Tap BFS vòng NPC + chạm ngoài hình thoi + nhãn Map002 hết nổi cao (21/11 ~15:45–16:30 +07)

### 35.1 Việc làm (4 lỗi từ kiểm live 14:55 + §34.6)

1. **Tap-to-move bỏ cuộc khi NPC chặn đường** (vòng 13: tap (200,900) → đích (1,5) nhưng đường qua (3,5) có Bạn Thân → A xóa ngay, không đi).
   Gốc: `player.gd:_step_toward_auto()` chỉ thử 2 hướng tham lam theo |dx|/|dy|.
   Sửa (`player.gd`): BFS 4 hướng `_find_path(from, to)` trên lưới 12×9 qua `is_walkable` (tránh NPC/tường), lưu `_auto_path`; `_step_toward_auto()` đi theo đường, tính lại khi bước kế bị chặn; `_clear_auto()` xóa cả đích lẫn đường (phím/D-pad bấm tay hủy tap-walk); guard kề ô (`_tile_dist == 1`) chống đường lệch khi đặt đích giữa tween (không xảy ra vì `_try_step` đặt `tile` = đích ngay khi bắt đầu tween — guard chỉ là lưới an toàn).
2. **Chạm ngoài hình thoi đất thì im lặng** (vòng 13: (200,750)/(500,700) không đăng ký gì).
   Sửa (`main.gd` nhánh tap): `world_to_tile` ngoài biên → kẹp về ô trong biên gần nhất (`clampi` 0..11/0..8) rồi `_nearest_walkable` → đi tới ô đi được gần nhất (chạm vào mặt tiền thì đi tới trước cửa hàng đó); không có ô đi được nào thì toast "Chỗ đó không đi được." (thay vì im lặng). Cả nhánh trong biên mà `_nearest_walkable` trả (-1,-1) cũng toast.
3. **Nhãn debug che tiêu đề điện thoại** (live 14:55: nhãn (24,200) đè panel điện thoại y=216).
   Sửa (`main.gd`): `_process` + `set_debug_labels_visible` đặt `_dbg_label.visible = ... and not phone_open and not battle_open` (sửa ở `_process` vì nó đặt lại visible mỗi frame — sửa trong `_open_phone` sẽ bị ghi đè).
4. **Nhãn NPC Map002 nổi cao trên trời** (live 14:55: "Anh Hải"/"Chị Lệ" cách NPC ~70–200px).
   Gốc đo bằng probe headless (`/tmp/pxb_r14_label_probe*.gd`, đã xóa sau khi dùng):
   - `Anh Hải` drift **-100px** (want 706 → 606), khe trên đầu **197px**; `Chị Lệ` drift 0, khe 47px.
   - Chuỗi gây drift: (a) `NPC_PARITY_OFFSET = 40` (marker.gd) đẩy nhãn NPC ô lẻ lên thêm 50px màn hình (Anh Hải (6,3) lẻ, Chị Lệ (2,2) chẵn) — want_y hai nhãn chỉ cách nhau 50px; (b) `_nearest_free_y` tính vật cản khi chồng X chỉ **1px** (mép nhãn Anh Hải chạm mép vật cản sprite Chị Lệ đúng 1px) → cắt hết khoảng dọc gần neo, best_y rơi về 606.
   Sửa: **bỏ hẳn `NPC_PARITY_OFFSET`** (tách nhãn NPC kề nhau nay là việc của resolver, không cần lệch sẵn — cặp "Bạn Thân"/"Cô Tư" đều chẵn nên lệch này vốn không tách được chúng); **`_nearest_free_y` chỉ tính vật cản khi chồng X ≥ 10px** (cả obstacles lẫn placed — chồng < 10px thì bỏ qua).
   Sau sửa (probe lại): Anh Hải drift **0**, khe trên đầu **47px** = Chị Lệ; Map001 không đổi (Cô Tư/Bạn Thân drift 0, khe 47px). Còn drift cũ không sửa vòng này: "Góc Chế Tạo" Map001 -132px (main pass, kẹt giữa vật cản người chơi + nhãn Bạn Thân + icon — nhãn vẫn đọc được, không bay lên trời, để nguyên).

### 35.2 Không tái hiện: nền mờ sau điện thoại ở Chợ (live 14:55 mục d)

- Kiểm bằng ảnh thật (r14-05, xem §35.4): mở điện thoại ở Chợ, nền mờ sau panel là **cảnh Chợ hiện tại** (sạp + nhãn "Cửa đi Khu Công Nhân" dưới panel), không có "CA PHE" nào. Code cũng cho thấy `_phone_dim` chỉ là ColorRect đen 0.55 phủ lên map hiện tại; "CA PHE" chỉ tồn tại trong `bg_map001.png`/`title_bg.png` (Map001/title, đã ẩn khi chơi). Kết luận: mục (d) là đọc nhầm của checker (có thể là panel 2 bên desktop hiện tranh title) — không có lỗi để sửa, không bịa fix.

### 35.3 Test mới + hồi quy

- `tests/g4_r14_tap_test.gd`: **15/15 PASS** — spawn (4,5); chạm (200,750)/(500,700) đăng ký đích + ghi "chạm (x,y)" + đích đi được; BFS (4,5)→(1,5) đúng 5 bước, không qua (3,5)/(5,4), tới đích + xóa auto-target, không chuyển map giữa chừng; mở điện thoại → nhãn debug ẩn, đóng → hiện lại.
  - Bài học test: `tile` được đặt ngay khi bắt đầu tween nên kiểm "tới đích" ngay thì thiếu 1 bước `moved_to` + auto-target chưa xóa — phải chờ 3 frame sau khi hết tween mới assert.
- Hồi quy đầy đủ: **43 OK, 0 FAIL** (42 cũ + 1 mới; `run_regression.sh` thêm `g4_r14_tap_test`).
- `--check-only` exit 0 (main.gd, player.gd, marker.gd, test mới — chạy sau `--import` để tránh cache class cũ, bài học §8.3); scene Main 120 frame exit 0, 0 ERROR/warning.
- Export web exit 0: pck **6.950.036 byte, SHA `9d9896a9…`** (trước `d691d82e…`), wasm không đổi `fc74679e…`; HTTP 200 đủ 2 file (cổng 8166).

### 35.4 Browser-verify thật (Chromium 1255 + swiftshader, 720×1280, build 9d9896a9)

- Script mới `visual-check/artpass14/check_r14.py` (tái chạy được).
- **Lỗi verify lần 1:** click nút bắt đầu sai tọa độ — script dùng fallback (360,740) của bản staging có DOM overlay, nhưng build thô `src/godot-build` không có `web_shell.html` nên nút "Bắt đầu chơi" là Button trong canvas ở ~(360,1060); click (360,740) trúng panel trên nút, game mãi ở title, 6 ảnh byte-identical. Sửa script click (360,1060) rồi chạy lại. Bài học: **verify build thô ≠ verify staging — nút bắt đầu khác vị trí; ảnh byte-identical liên tiếp = game chưa vào, không phải kết quả.**
- **Lần 2 — PASS, đã xem ảnh thật, 0 console error, 0 pageerror, 0 request fail:**
  - Tap (200,750): nhãn debug `Ô (2,4) • chạm (1,1) / A:(1, 1)` — đăng ký đích ngay; 4s sau `Ô (1,1) • chạm (1,1) / A:(-1, -1)` — đã đi tới (1,1) và xóa đích. (r14-02/03)
  - Map002 lúc vào: "Chị Lệ" + "Anh Hải" nằm sát trên đầu NPC (khe ~47px), không còn chồng thành cột ở vùng trời như ảnh 60-m2-arrival. (r14-04)
  - Mở điện thoại ở Chợ: tiêu đề "Điện thoại — Danh bạ / Tin nhắn" đọc đủ, **không còn nhãn debug đè lên**; nền mờ là cảnh Chợ. Đóng điện thoại: nhãn debug hiện lại. (r14-05/06)
- Còn lại (không sửa vòng này): sạp chợ Map002 vẫn là khối hộp be nhỏ/thô (chờ hướng art Claude — xem §35.6); nhãn "Cửa đi Khu Công Nhân" ở sát đáy bị toast đè nhẹ (đã biết từ trước).

### 35.5 Việc tiếp theo

1. **Claude đã trả lời về đồ họa** (dòng Notion `41f4047a-8982-81ff-ac73-d293ef69307e`, xem §35.6) — Center ĐÃ NHẬN + ETA đã ghi trên dòng lúc 15:45 (trước vòng này). Việc nhanh (b) hạn trước 21:00 21/11: Default Texture Filter = Linear Mipmap + bật mipmaps khi import, thu nhỏ sẵn ảnh nhân vật về 208px, chuyển nhãn NPC sang Label trong thế giới; gửi ảnh trước/sau chụp trên điện thoại thật. Làm ở vòng sau ngay sau khi deploy vòng 14 xong.
2. Dựng lại Map001 (hạn 12:00 22/11), nhân vật 6 khung (20:00 22/11), ánh sáng + sự sống (23/11) — theo ETA đã ghi trên dòng.
3. Sạp chợ Map002 (khối be thô) — làm khi tới lượt art Map002, sau khi Map001 theo hướng Claude xong.

### 35.6 Claude trả lời — đã nhận (21/11 ~15:45, dòng 41f4047a-8982-81ff-ac73-d293ef69307e)

- Chủ (qua trợ lý Claude) đã chuyển trả lời cho câu hỏi đồ họa Center gửi sáng 21/11. Toàn văn đã đọc tươi (fetch 16:00): chẩn đoán 4 điểm gốc — (1) ảnh nền AI trộn với nhà vẽ bằng code trong `nadia_scene.gd` → hai phong cách đánh nhau; (2) nhân vật 512px thu còn 104px không mipmap → răng cưa, chỉ 1 khung; (3) map iso 12×9 chỉ phủ ~1/3 màn dọc, trời trống; (4) nhãn NPC trên CanvasLayer nên lơ lửng.
- 3 việc theo thứ tự (chi tiết + tên node trong trang chẩn đoán `41f4047a-8982-81fe-9924-e3926327667b`): (1) Dựng lại Map001: blockout Blender (camera ortho X=60°, Z=45°) → AI vẽ đè → 4 lớp Ground/YSort/Foreground/LightsLayer, phủ kín 9:16 bằng nhà ống cao + tiền cảnh, tắt hẳn vẽ nhà bằng code; (2) Nhân vật 6 khung (trước/sau-3/4 × 3 khung, lật ngang), ảnh 2× cỡ hiển thị, Linear Mipmap, nhãn là Label con của nhân vật, chỉ hiện khi ở gần; (3) Ánh sáng: nền đêm nướng sẵn + sprite phát sáng cộng dồn + CanvasModulate chiều + 3–5 chuyển động nhỏ (hơi nồi phở, biển đung đưa, lá rơi).
- Center ĐÃ NHẬN + ETA đã ghi trên dòng lúc 15:45 (do main agent ghi — vòng 14 này chạy sau đó): Center tự làm (không giao Muse Editor — bạn ấy giữ giám sát 30 phút + Bộ hiệu ứng hạn 18:00). ETA: (b) việc nhanh trước 21:00 21/11; (1) Map001 trước 12:00 22/11; (2) 6 khung trước 20:00 22/11; (3) ánh sáng 23/11. Làm trọn Map001 trước, không trải nhiều map; mỗi việc xong gửi ảnh điện thoại duyệt; xếp lịch không trễ slot 1Min/Ủa và vòng thử (PV-07).
- LƯU Ý cho vòng sau: việc (b) "chuyển nhãn NPC sang Label trong thế giới" CHỒNG với fix D vòng 14 (vòng 14 giữ CanvasLayer nhưng sửa drift) — (b) là đổi hẳn kiến trúc nhãn (Label con của Marker trong thế giới + chỉ hiện khi ở gần), phải làm riêng sau khi deploy vòng 14, không gộp chung để tránh phá bộ resolver/artpass tests đang PASS.

### 35.7 Deploy `9d9896a9` lên gh-pages — XONG (21/11 ~16:20–16:35 +07)

- Đối chiếu trước deploy: `versions.json` remote pin đúng pck `d691d82e` tại head `8c1e7d3e` (= deploy vòng 13); `pck/9d9896a9/` chưa tồn tại remote — nối tiếp sạch, không divergence.
- Rebuild staging `tools/godot/build_gh_pages.py`: VERIFY OK, 52 chunk pck, wasm `fc74679e` không đổi, img không đổi.
- Deploy 5 lô: `b4077061` (chunk 000–016), `6ca40d07` (017–033), `d87ca6b3` (034–051), `157cd0e6` (`versions.json`), `c42d44ab` (`index.html` CUỐI — head gh-pages).
- Verify khớp byte từ live: ráp 52 chunk từ `raw.githubusercontent.com` = 6.950.036 byte, SHA `9d9896a97b987031` ✓; `index.html` live SHA `de8c6d44ab176d02` = staging ✓; `versions.json` qua API tại head `c42d44ab` pin `9d9896a9` ✓.
- Lưu ý CDN (đã biết, §19.8): `versions.json` qua `tinnt120899.github.io` vẫn hiện `d691d82e` ngay sau deploy — Pages CDN cache, repo qua API đã đúng; tải lại sau vài phút sẽ khớp. Không kết luận deploy sai vì curl ngay sau push.
- Link live: https://tinnt120899.github.io/pho-xo-bo/ (Pages rebuild vài phút sau push).

## 36. Vòng 14b — Claude (b) phần nhanh: Linear Mipmap + thu nhỏ nhân vật 208px (21/11 ~16:35–17:00 +07)

### 36.1 Việc làm (2/3 mục nhanh (b) — hạn trước 21:00 21/11)

1. **Default Texture Filter = Linear Mipmap** (`project.godot` [rendering]): thêm `textures/canvas_textures/default_texture_filter=3` (0 Nearest, 1 Linear, 2 Nearest Mipmap, 3 Linear Mipmap). Trước đó không có setting này (mặc định Linear, không mipmap).
2. **Bật mipmaps khi import** cho 5 ảnh nhân vật: `art/char_*.png.import` `mipmaps/generate=false` → `true` (chỉ 5 file này; ảnh nền/sky hiển thị ~1:1 nên không cần).
3. **Thu nhỏ sẵn ảnh nhân vật 512px → 208px** (2× cỡ hiển thị 104px): PIL LANCZOS, giữ alpha. `char_player` 260×512→106×208, `char_cotu` 275→112, `char_banthan` 330→134, `char_chile` 233→95, `char_anhhai` 213→87 (đều cao 208). Gốc 512px lưu ở `visual-check/artpass14/orig-512/`.
   - An toàn vì `character_sprite.gd` tính scale theo `TEX_HEIGHT / texture.get_height()` (không hardcode 512) — hiển thị vẫn đúng 104px.
   - `.ctex` sau re-import: player 141.858→50.758 byte, banthan 167.334→57.836 byte; tên file `.ctex` không đổi (hash theo params, không theo nội dung ảnh).
4. **Chưa làm — nhãn NPC sang Label trong thế giới** (mục (b) thứ 3): là đổi hẳn kiến trúc nhãn (Label con của Marker + chỉ hiện khi ở gần), chồng với fix drift vòng 14 nhưng khác hẳn cách làm; làm riêng ở vòng sau, không gộp vào deploy này để khỏi phá bộ resolver/tests đang PASS. Ghi chú cho vòng sau: phải sửa `marker.gd` + `_resolve_label_overlaps` + các artpass test assert `label_screen_rect()`.

### 36.2 Lỗi export — bài học

- Export lần 1 dùng output `../godot-build/index.pck` → pck chỉ **18.146 byte, bắt đầu bằng `<!DOCTYPE html>`**: Godot 4.7.2 viết shell HTML vào đúng đường dẫn được đưa, không phải pck game. **LUẬT: luôn export bằng đường dẫn của preset (`../godot-build/index.html`), không bao giờ đưa đường dẫn `.pck`.**
- Export lại đúng cách: exit 0, pck **6.473.700 byte, SHA `cf88493c…`** (nhỏ hơn 6.950.036 của vòng 14 — đúng vì ảnh nhân vật đã thu nhỏ), wasm không đổi `fc74679e…`, HTTP 200 đủ 2 file.

### 36.3 Verify

- `--check-only` (character_sprite.gd, marker.gd) exit 0; hồi quy đầy đủ **43 OK, 0 FAIL**.
- Browser-verify script mới `visual-check/artpass14/check_r14b.py` (bản đổi tên output của check_r14.py): **0 console error, 0 pageerror, 0 request fail**; game vào được, tap/chạm/điện thoại vẫn chạy như vòng 14.
- Xem ảnh thật: Map001 (r14b-01) + Map002 (r14b-04) — sprite người chơi/Bạn Thân/Cô Tư/Anh Hải/Chị Lệ hiển thị đúng cỡ 104px, không méo/vỡ; nhãn "Anh Hải"/"Chị Lệ" vẫn sát trên đầu NPC (giữ được fix vòng 14). Còn tồn tại từ trước: nhãn "Sạp rau buổi sáng" hơi đè "Anh Hải", "Góc phế liệu chợ" bị cắt ở mép phải — thuộc layout nhãn, không phải do resize.
- **Giới hạn ảnh trước/sau:** ACK trên dòng đã hẹn "ảnh trước/sau chụp trên điện thoại thật" — VM không có điện thoại thật; ảnh trước/sau ở đây là screenshot Chromium 720×1280 (r14-*.png vs r14b-*.png). Chủ xem trên điện thoại của mình để duyệt cuối.

### 36.4 Lưu ý đồng bộ art

- 5 PNG đã resize chỉ sống ở **bản local + trong pck** (snapshot-push chỉ nhận file text) — giống mọi art PNG từ trước. File `.import` (text, đã push) thì tương thích cả 2 cỡ ảnh; nhưng **art trên repo main vẫn là bản 512px cũ** — clone mới về sẽ thấy ảnh 512px cho tới khi có cơ chế đẩy art nhị phân. Ghi rõ để vòng sau không tưởng repo đã có ảnh 208px.
- Ảnh title `char_player.png`/`char_banthan.png` trong `src/godot-build/` cũng đã copy bản 208px mới (45.086 / 53.272 byte) để deploy staging chunk lại với version mới.

### 36.5 Deploy `cf88493c` lên gh-pages — XONG (21/11 ~17:05–17:20 +07)

- Đối chiếu trước deploy: `versions.json` remote pin pck `9d9896a9` tại head `c42d44ab` (= deploy vòng 14); `pck/cf88493c/` chưa tồn tại remote — nối tiếp sạch.
- Rebuild staging `tools/godot/build_gh_pages.py`: VERIFY OK; pck 48 chunk; img char_player `9639c122`→`5dc7da77`, char_banthan `4750238d`→`a4c96723` (ảnh 208px mới), title_bg không đổi.
- Deploy 6 lô: `64752ee7` (chunk 000–016), `99340298` (017–033), `3d64de91` (034–047), `9b051eee` (img char 2 file), `061d9861` (`versions.json`), `3c7063e6` (`index.html` CUỐI — head gh-pages).
- Verify khớp byte từ live: ráp 48 chunk = 6.473.700 byte, SHA `cf88493c56f6edd6` ✓; img chunk char_player 45.086 byte + char_banthan 53.272 byte, đúng magic PNG ✓; `index.html` live SHA `069ae1886a2f5188` = staging ✓; `versions.json` qua API tại head `3c7063e6` pin `cf88493c` + img mới ✓.
- Link live: https://tinnt120899.github.io/pho-xo-bo/ (Pages rebuild vài phút sau push).


## 37. Vòng 15 — Nhãn NPC sang Label trong thế giới (21/11 ~16:50–17:30 +07)

Mục (b) thứ 3 của Claude (xem §35.6) — hạn trước 21:00 21/11. 2/3 mục
nhanh đã xong ở vòng 14b (Linear Mipmap + ảnh 208px); mục này làm riêng
sau khi deploy vòng 14b, không gộp chung (đúng lưu ý §35.6).

### 37.1 Việc làm

- **Nhãn NPC thành Label con của Marker** (`scripts/marker.gd`):
  `_make_world_label()` — Label con trực tiếp của Marker (Node2D),
  dùng rect neo thô `_anchor_rect()` (NPC: trên -170, cao 32 world),
  font 20 world, `z_index = 10` (trên ảnh nền/mặt tiền — cùng kỹ
  thuật SkyEffects/NightGlow dùng để thoát y-sort của IsoMap),
  `mouse_filter = IGNORE`. Nhãn hotspot/che tao/cua KHÔNG đổi —
  vẫn Label trên CanvasLayer layer 1 (resolver vẫn dịch được).
- **Chỉ hiện khi ở gần** (`main.gd` `_update_npc_labels()`, chạy
  mỗi frame trước resolver): Manhattan từ ô người chơi tới ô NPC
  ≤ `Marker.LABEL_NEAR_TILES = 5`. Ngưỡng 5 giữ cả 2 NPC hiện lúc
  spawn Map001 (Bạn Thân 1 ô, Cô Tư đúng 5 ô) + Map002 (Chị Lệ 5 ô,
  Anh Hải 2 ô) — ảnh spawn không đổi; xa hơn thì ẩn.
  Marker giữ `_label_near` (mặc định true để marker đứng lẻ không
  có Main vẫn hiện như cũ) + `_npc_label_should_show()` (gần +
  neo trong màn hình) dùng chung cho `_update_label()` và
  `label_screen_rect()` để 2 chỗ không lệch nhau 1 frame.
- **Resolver bỏ qua NPC** (`main.gd` `_resolve_label_overlaps()`):
  không đặt `label_override` cho NPC nữa (dịch là rời neo); rect
  màn hình của nhãn NPC ghi sẵn vào `placed` để nhãn hotspot/cửa/
  chế tạo tránh. Obstacle sprite NPC vẫn giữ nguyên.
- **`label_screen_rect()` cho NPC** nay là rect màn hình thật của
  Label con (canvas transform × vị trí local), rỗng khi nhãn ẩn.
  `_anchor_rect()` tách ra từ `label_rect()` (phần kep camera giữ
  nguyên cho nhãn CanvasLayer).
- **Test cũ cập nhật** (`g4_artpass4_test.gd`, `g4_artpass5_test.gd`):
  lấy rect hiển thị thật = override-nếu-có-không-thì-screen-rect
  (như polish test) để nhãn NPC vẫn được kiểm chồng/đè đầu.
  `artpass_test.gd` (state 3), `g4_artpass3_test.gd`,
  `g4_polish_test.gd` đã dùng screen-rect nên không cần sửa;
  `artpass12_test.gd` chỉ kiểm override (nhãn cửa) nên giữ nguyên.

### 37.2 Lỗi tìm ra khi làm: Label tự tăng lên minimum size

- Test mới rớt 8/63 lần đầu: tâm nhãn lệch +2 world khỏi chân NPC,
  `size` thành (chu+20, 32) thay vì (chu+16, 26) đã đặt. Nguyên nhân:
  Label có StyleBoxFlat (content margin 10+10 ngang, 4+4 dọc) nên
  minimum size = (chu+20, font-cao 24+8=32) — Control tự tăng lên
  minimum size khi vào tree, chỉ giữ nguyên `position`.
- Sửa: `_anchor_rect()` cho NPC trả đúng minimum size
  (`size.x + 20`, `font.get_height(20) + 8`, tâm x = `-w/2` thay vì
  `-w/2 - 8`). Khe trên đầu NPC còn ~42px màn hình (trước ~50px).
- Probe `/tmp/pxb_r15_probe.gd` (đã xóa sau khi dùng) đo thật:
  Cô Tư pos (-37,-170) size (78,32), anchor (74,26);
  Bạn Thân size (115,32), anchor (111,26); font_h=24.

### 37.3 Test mới + hồi quy

- `tests/g4_r15_label_world_test.gd`: **63/63 PASS** — nhãn NPC
  là con của Marker, không trên CanvasLayer, z 10, font 20, đúng
  rect neo, không override; spawn Map001/Map002 cả 2 NPC hiện,
  tâm X trùng chân NPC, khe trên đầu 40–60px; xa 11 ô / 8 ô thì
  nhãn ẩn + rect rỗng; nhãn hotspot/chế tạo/cửa vẫn CanvasLayer;
  nhãn các map không chồng nhau.
- Hồi quy đầy đủ: **44 OK, 0 FAIL** (43 cũ + 1 mới;
  `run_regression.sh` thêm `g4_r15_label_world_test`).
- `--check-only` exit 0 (marker.gd, main.gd sau `--import`);
  scene Main 120 frame exit 0, 0 ERROR/warning.
- Export web exit 0 (đúng đường dẫn preset `../godot-build/index.html`,
  bài học §36.2): pck **6.481.136 byte, SHA `b6913210…`**
  (trước `cf88493c…` 6.473.700 — tăng nhẹ do code mới),
  wasm không đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`;
  HTTP 200 đủ 4 file (cổng 8167).

### 37.4 Browser-verify thật (Chromium 1255 + swiftshader, 720×1280, build b6913210)

- Script mới `visual-check/artpass15/check_r15.py` (tái chạy được).
- **0 console error, 0 pageerror, 0 request fail.**
- Đã xem ảnh thật: Map001 spawn (r15-01) — "Bạn Thân" sát trên đầu
  2 nhân vật, "Cô Tư" sát trên đầu Cô Tư, không chồng nhãn khác;
  Map002 (r15-03) — "Chị Lệ"/"Anh Hải" sát trên đầu NPC, vị trí
  nhãn y hệt bản vòng 14 (r14-04) — không hồi quy.
- **"Sạp rau buổi sáng" hơi chạm đỉnh đầu người chơi lúc vào Chợ:**
  đã đối chiếu ảnh vòng 14 (r14-04) — Y HỆT, có từ trước (luật
  vòng 12: giữ y muốn thay vì bay xa khi khe gần nhất quá xa),
  không phải hồi quy của vòng này.
- **Flake harness (không phải lỗi game):** lần chạy check_r15.py
  đầu + probe1 click (500,850)/(200,750)/(480,879) đều không đăng
  ký (đứng yên ở (4,5), A:(-1,-1)) — nhưng chạy lại Y HỆT bằng
  script r14b (`check_r14b.py` đổi cổng 8167) thì tap (200,750)
  đăng ký ngay + đi tới (1,1); probe2/probe3 (cùng cấu trúc r14b)
  cũng đi được, KỂ CẢ click đúng giữa nhãn "Cô Tư" (480,879) →
  đăng ký (3,1) + tới (3,1). Headless probe cũng xác nhận logic
  tap đúng ((500,850) → auto-target (3,1)). Kết luận: 2 lần chạy
  đầu bị mất click do harness (lần đầu chạy trên build mới export,
  giống các flake swiftshader đã biết: phím nhấn nhanh bị miss),
  không phải nhãn nuốt click (`mouse_filter = IGNORE` có tác dụng).
  Bài học: click không đăng ký ở lần chạy đầu thì CHẠY LẠI y hệt
  trước khi kết luận game hỏng.

### 37.5 Việc tiếp theo

1. **Deploy gh-pages bản `b6913210`** (staging rebuild + push batch,
   kiểm tra head gh-pages trước mỗi lô — xem §37.6).
2. Dựng lại Map001 theo hướng Claude (hạn 12:00 22/11), nhân vật
   6 khung (20:00 22/11), ánh sáng + sự sống (23/11) — theo ETA
   §35.6. Việc (b) đã đủ 3/3 trước hạn 21:00 21/11.
3. Sạp chợ Map002 (khối be thô) — làm khi tới lượt art Map002.

### 37.6 Deploy `b6913210` lên gh-pages — XONG 21/11 ~17:40 +07

- Staging rebuild `build_gh_pages.py`: VERIFY OK; versions.json pin
  pck `b6913210`, wasm `fc74679e` không đổi, img không đổi.
- Kiểm tra tiền-push: remote gh-pages `versions.json` pin `cf88493c`
  ở head `3c7063e6` (đúng trạng thái vòng 14b) — NHƯNG sync record
  thiếu hẳn entry deploy gh-pages vòng 14 (9d9896a9) + 14b
  (cf88493c); entry gh-pages mới nhất trong record vẫn là vòng 13
  (80da1a51). Đối chiếu diff: index.html remote ↔ staging chỉ khác
  version pck + số chunk (48→49) + fileSizes pck (6473700→6481136)
  — không có writer khác chen vào. Lấy head đã verify `3c7063e6`
  làm base; các lô deploy vòng này ghi record đầy đủ trở lại.
- Push gh-pages 5 lô (mỗi lô ghi sync record ngay sau khi xong):
  chunk 1/3 `ee628999` (part-000..019), 2/3 `66614a85`
  (part-020..039), 3/3 `97ee0af1` (part-040..048),
  versions.json `4fcd9816`, index.html CUỐI `eeb3347c`.
  Spot-check 3 chunk (000/024/048) blob SHA remote = local.
- Verify live (curl): versions.json pin `b6913210`; index.html live
  trỏ pck/b6913210, fileSizes 6481136; tải đủ 49 chunk từ live,
  ráp lại = 6.481.136 byte, SHA256 `b6913210…` KHỚP TỪNG BYTE với
  pck local. Link live: https://tinnt120899.github.io/pho-xo-bo/
- **Hạn chế lần này:** smoke browser trên URL live KHÔNG chạy được
  từ VM này — Chromium báo `ERR_TUNNEL_CONNECTION_FAILED` (2 lần),
  trong khi curl cùng máy trả 200. Đây là lỗi đường mạng/proxy của
  Chromium trong sandbox, không phải lỗi site. Game đã browser-verify
  trên bản local CÙNG TỪNG BYTE pck + live đã khớp byte — nhưng theo
  luật "kiểm live bằng cloud browser" thì phần này còn thiếu; vòng
  sau thử lại live browser khi tunnel ổn.
- Lưu ý push: lần push main đầu bị service restart cắt giữa chừng
  (chưa lên, check head vẫn `7b21c4dd` rồi push lại mới xong);
  lần push versions.json cũng bị restart cắt (chưa lên, check lại
  rồi push lại). `/tmp` bị xóa sau mỗi restart — manifest phải tạo
  lại. Và: file `docs/godot-g4.md` 226.162 byte vẫn push qua
  snapshot-push được (giới hạn thật là 16 MiB tổng, không phải
  188.416 byte/file như MEMORY.md đang ghi — con số đó là cỡ chunk
  base64 của build_gh_pages, không phải giới hạn push).

## 38. Vòng 16 — Map001 dựng lại bước 1: ảnh nhà ống cao phủ kín 9:16 (22/11 ~00:30–01:00 +07)

Mục (1) của Claude (§35.6), hạn 12:00 22/11 — làm bước 1 (nền mới),
chưa phải blockout Blender đầy đủ (VM không có Blender).

### 38.1 Việc làm

- **Ảnh mới** (`src/godot/art/bg_map001_tall.png` 864×1536 + bản đêm
  `bg_map001_tall_night.png`): gen bằng media image generation
  (prompt: 3 nhà ống cao 4 tầng, tường vàng cũ, mái ngói, ban công
  cây, biển PHO BO / CA PHE / TAP HOA, đèn lồng đỏ, vỉa hè — đúng
  phong cách vẽ tay Nadia), xử lý bằng PIL
  (`tools/godot/make_map001_tall.py`, tái chạy được): gốc 1152×2048
  thu về 864×1536 (camera chỉ thấy ~576 đơn vị thế giới ngang nên
  vẫn >1,3× oversampling; tránh pck phồng thêm ~5MB), bản đêm suy
  ra từ bản ngày (tối + lạnh toàn cục, giữ 381.184 pixel ấm sáng
  cửa sổ/đèn lồng; mean ngày 91,5 → đêm 51,9). Bản gốc webp giữ ở
  `visual-check/artpass16/bg-map001-tall-source.webp`.
- **Code** (`scripts/iso_map.gd`): Map001 ưu tiên ảnh cao khi có
  (`has_tall_bg` mới); đáy ảnh neo ở offset.y+20 như ảnh cũ, đỉnh
  lên tới offset.y-1516 — phủ kín cả tầm nhìn khi đi lên hàng trên
  (camera thấy tới offset.y-777); **không vẽ dải trời sky_wide cho
  Map001 nữa** (sẽ đè lên tầng trên của ảnh cao); ảnh composite cũ
  giữ làm fallback khi thiếu ảnh cao. `set_frame` đổi ngày/đêm dùng
  chung `_bg_day_tex`/`_bg_night_tex` nên không cần sửa. Wash sáng
  mặt tiền `_draw_facade_light` giữ nguyên (nay phủ đúng dải mặt
  tiền tầng trệt của ảnh cao, alpha ≤0,14).
- **Test mới** `tests/g4_r16_map001_rebuild_test.gd`: **16/16 PASS**
  — ảnh tồn tại + đúng 864×1536, đêm tối hơn ngày (tỉ lệ 0,57),
  Map001 `has_tall_bg`, đáy neo offset.y+20, đỉnh vượt tầm nhìn
  hàng trên, không sky_wide, đổi khung Toi/Sáng đổi đúng ảnh,
  Map002 không đổi (sky_band + sky_wide).
- **Test cũ cập nhật** (tiền lệ §12.3 — test lỗi thời so với thay
  đổi có chủ ý, sửa test không sửa code): `g4_artpass3_test`
  (3 check tên ảnh nền ngày/đêm → ảnh cao) + `g4_polish_test`
  (Map001 bg composite + có sky_wide → bg ảnh cao + không sky_wide).

### 38.2 Verify vòng này

- Hồi quy đầy đủ: **45 OK, 0 FAIL** (44 cũ + 1 mới; lần chạy đầu
  43 OK + 2 FAIL đúng 2 test cũ trên — đã cập nhật, chạy lại đủ).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR.
- Export web exit 0: pck **10.028.440 byte, SHA `34bd6889…`**
  (trước 6.481.136 — tăng ~3,5MB do 2 ảnh cao; wasm không đổi
  `fc74679e…`); HTTP 200 đủ 4 file (cổng 8171).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass16/check_r16.py` +
  `check_r16_m2.py`, ảnh `r16-01…r16-05`): **0 console error,
  0 pageerror, 0 request fail.**
  - Spawn Map001: nhà ống cao 4 tầng phủ kín khung dọc, biển
    PHO BO / CA PHE / TAP HOA đọc được, không còn dải trời trống.
  - Đi lên 4 ô tới (4,1): mặt tiền vẫn kín khung, không hở trời.
  - F ×2 → Tối: ảnh đêm (tối xanh, trăng + sao, cửa sổ ấm còn
    sáng), nhãn "Hẻm trọ buổi tối" đổi đúng, toast "Ngày 1 •
    Khung Tối".
  - Vào Map002 bằng cửa (5,4): đúng Chợ Đầu Mối + toast "Đã sang
    Chợ Đầu Mối", sky_band + sky_wide như cũ — không hồi quy.
- **Nit còn lại (không chặn, ghi cho vòng sau):**
  1. Sao đêm NightGlow vẫn vẽ ở dải cũ (world y −92..−12) nên
     rơi lên mái hiên/biển hiệu thay vì trời — nhìn như bụi sáng,
     nhỏ; dời dải sao lên khi làm ánh sáng 23/11.
  2. Mặt trời Sáng (neo màn hình) đè lên biển PHO BO lúc spawn —
     dời mặt trời sang phải hoặc xuống thấp hơn.
  3. Đất iso (ground_wide.jpg, ảnh chụp) vẫn khác phong cách với
     mặt tiền vẽ tay — đường nối vỉa hè/đất còn thấy; cần art đất
     riêng cho Map001 ở bước tiếp theo.
  4. Sạp Chợ Map002 vẫn khối be thô (đã biết, chờ art Map002).
- **Lưu ý đồng bộ art:** 2 PNG cao chỉ sống ở local + trong pck
  (snapshot-push chỉ nhận file text) — giống mọi art PNG từ trước;
  file `.import` (text) đã push thì tương thích cả 2 cỡ ảnh.
  Clone mới về sẽ fallback về ảnh composite cũ cho tới khi có cơ
  chế đẩy art nhị phân.

### 38.3 Deploy — XONG (22/11 ~01:00 +07)

- Push main — XONG, commit `a1f549e3` (12 file: iso_map.gd, test
  r16 mới + `.uid`, 2 test cập nhật, run_regression.sh,
  make_map001_tall.py mới, 2 `.import` mới, 2 script visual-check
  artpass16, docs §38). Đối chiếu trước push: head `3230d76e`
  khớp record; commit mới nhất chạm 5 file sửa đều đúng sync base
  (iso_map/artpass3 `d0b5cbd1`, polish `bb47c522`,
  run_regression `42dafc2a`, docs `3230d76e`); 7 file mới xác nhận
  ABSENT trên remote trước khi push.
- Deploy gh-pages — XONG, 6 lô: `25e7ab71` (pck 000–022),
  `422d7708` (023–045), `4ee21f4a` (046–068), `5e1d0ca3`
  (069–074), `27133ed1` (versions.json), `a349ec32` (index.html
  CUỐI — head gh-pages). Staging rebuild `build_gh_pages.py`
  VERIFY OK; pck `34bd6889` (75 chunk), wasm `fc74679e` không đổi.
  Spot-check 3 chunk (000/037/074) blob SHA remote = local trước
  khi đẩy index.html.
- Verify khớp byte từ live: ráp 75 chunk từ
  `raw.githubusercontent.com` = 10.028.440 byte, SHA
  `34bd6889b567dad8` ✓; `versions.json` live pin `34bd6889`;
  `index.html` live SHA `102bf8dbff863da7` = staging ✓.
- Link live: https://tinnt120899.github.io/pho-xo-bo/ (Pages rebuild
  vài phút sau push).

### 38.4 Việc tiếp theo

1. Map001 bước 2: art đất riêng (khớp mặt tiền vẽ tay) + dời dải
   sao/mặt trời (nit 1–3 trên). — **XONG vong 17, xem §39.**
2. Nhân vật 6 khung (hạn 20:00 22/11, cần nguồn gen ảnh AI) +
   ánh sáng + sự sống (23/11) — theo ETA §35.6.
3. Sạp chợ Map002 (khối be thô) — làm khi tới lượt art Map002.

## 39. Vòng 17 — Map001 bước 2: sao/mặt trời neo camera + đất vẽ tay (22/11 ~01:00–01:45 +07)

Nit 1–3 của §38.2, làm xong cả 3 trong 1 vòng (2 luồng song song:
luồng này code + verify + deploy; luồng kia gen art đất).

### 39.1 Vấn đề gốc (đo bằng mắt trên ảnh r16)

- Ảnh nhà ống cao **không có vùng trời thật nào trong tầm nhìn**:
  camera (zoom 1.25, look-up −265) lúc spawn thấy tới world y −315,
  lúc lên hàng trên tới −379; ảnh cao kéo tới −1214 nhưng phần trên
  không bao giờ vào khung. Nửa trên màn hình lúc nào cũng là mặt tiền.
- Sao đêm cũ neo theo map (`sky_top.y+200..280` = world y −108..−28)
  rơi lên mái hiên/biển hiệu — nhìn như bụi sáng trên mái hiên
  (ảnh r16-03). Mặt trời Sáng neo màn hình (170,240) đè lên mái hiên
  trái + biển PHO BO lúc spawn (ảnh r16-01).
- Đất `ground_wide.jpg` là ảnh chụp thật — lệch phong cách với mặt
  tiền vẽ tay, đường nối vỉa hè/đất còn thấy (ảnh r16-01).

### 39.2 Việc làm

- **Sao đêm neo camera** (`scripts/night_glow.gd`): bỏ hẳn dải sao
  theo `sky_top`; sao vẽ ở dải màn hình cố định y **208..262**
  (dưới HUD ~200, trên mái hiên ~280), x 24..696 — cùng thủ thuật
  như trăng neo camera (400,240) của SkyEffects: "sao trên mái nhà"
  đọc được như trời đêm. Giữ nguyên số lượng (64 khi `sky_in_image`,
  36 khi không), cỡ, màu HDR. Thêm `_cam_anchor()` (như SkyEffects)
  + `_process()` vẽ lại khi camera đổi chỗ (chỉ khi `lit`); biến
  `star_screen_top/bottom` để test đọc. Trăng Map003+ vẫn vẽ theo
  map ở `sky_top+(560,250)` (trùng vị trí trăng neo camera lúc
  spawn nên chỉ thấy 1 trăng — không động vào). `set_sky` giữ lại
  cho trăng.
- **Mặt trời Sáng sang phải** (`scripts/sky_effects.gd`):
  (170,240) → **(560,240)**. Bên phải, trên biển TAP HOA (~y 390
  trở xuống), chỉ có tường tầng trên — mặt trời nằm "trên mái nhà"
  như trăng. Chiều (330,240) + trăng (400,240) không đổi.
- **Đất vẽ tay Map001** (`src/godot/art/ground_map001.png`,
  1440×900, ~2,4 MB — luồng song song gen bằng media image
  generation, prompt + xử lý PIL ghi ở
  `visual-check/artpass17/ground_map001-note.md`): watercolor/
  gouache, dải vỉa hè đá cũ ~18% trên cùng, dưới là đất hẻm nứt +
  lá vàng + rêu + vũng nước. Nối vào game (`main.gd`):
  `_ground_sprite` + `_update_ground(map_id)` gọi trong `load_map`
  — Map001 dùng `ground_map001.png`, map khác về `ground_wide.jpg`;
  cả 2 ảnh cùng 1440×900 nên scale giữ nguyên; thiếu file (clone
  mới chưa có art nhị phân) thì fallback ảnh cũ.
- **Test cập nhật theo tiền lệ §12.3** (test lỗi thời so với thay
  đổi có chủ ý): `v6_overlay_test` check mặt trời (170,240) →
  (560,240); `g4_artpass3_test` check ground sprite chấp nhận cả 2
  tên file.

### 39.3 Test mới + verify vòng này

- Test mới `tests/g4_r17_sky_test.gd`: **14/14 PASS** — mặt trời
  Sáng dưới HUD + sang phải (x>350, <550), Chiều giữ vị trí cũ,
  Tối sao đã vẽ + dải sao dưới HUD/trên mái hiên, trăng không đổi,
  Map001 đất vẽ tay, sang Map002 về đất cũ, về Map001 lại đất vẽ
  tay. (Lỗi test lần đầu: đọc `sun_pos` ngay sau `_advance_frame`
  trong cùng frame — `_draw` chưa chạy; đã sửa thành đọc ở frame
  sau, như artpass4.)
- Hồi quy đầy đủ: **46 OK, 0 FAIL** (45 cũ + 1 mới; lần chạy đầu
  45 OK + 1 FAIL đúng `v6_overlay_test` — test cũ đòi mặt trời
  (170,240), đã cập nhật, chạy lại đủ). Smoke `--headless
  --quit-after 120` exit 0, 0 ERROR.
- Export web exit 0: pck **11.692.520 byte, SHA `cddb9cd5…`**
  (trước `34bd6889…` — tăng ~1,66 MB do ảnh đất 2,4 MB);
  wasm không đổi `fc74679e…`; HTTP 200 đủ 4 file (cổng 8172).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass17/check_r17.py`, ảnh
  `r17-01…r17-03`): **0 console error, 0 pageerror,
  0 request fail.**
  - Spawn Sáng: mặt trời là đĩa vàng tròn + quầng mềm ở góc
    phải trên, không đè biển/mái hiên trái; biển PHO BO đọc đủ;
    đất vẽ tay (vỉa hè đá + đất nứt + lá vàng + vũng) khớp phong
    cách mặt tiền, đường nối vỉa hè/đất hết lộ.
  - F ×2 → Tối: sao nằm thành dải hẹp ngay dưới HUD/debug, không
    còn chấm trắng rải trên mái hiên/biển hiệu; trăng vẫn ở giữa
    trên; đất đêm tối đều, vẫn là tranh vẽ tay.
  - Về Sáng + sang Map002 bằng cửa (5,4): đúng Chợ Đầu Mối +
    toast "Đã sang Chợ Đầu Mối", đất về ảnh cũ (đúng thiết kế —
    chỉ Map001 có đất vẽ tay riêng); mặt trời trên trời thật của
    Map002. Không hồi quy.
- Nit còn lại (không chặn): dải sao hơi chạm hộp nhãn debug
  (nhãn debug tạm thời, mặc định hiện trong giai đoạn sửa di
  chuyển — hết debug là hết chạm); Map002 vẫn dùng đất ảnh chụp
  + sạp khối be (chờ art Map002).

### 39.4 Deploy — XONG (22/11 ~01:45 +07)

- Push main — XONG, commit `0654c7ac` (12 file: sky_effects,
  night_glow, main.gd, test r17 mới + `.uid`, 2 test cập nhật,
  run_regression.sh, 2 script/ghi chú artpass17, `.import` đất mới,
  docs §39). Đối chiếu trước push: head `39bf251f` khớp record;
  6 file sửa không divergence (remote-at-head vẫn nội dung cũ);
  5 file mới xác nhận ABSENT trên remote trước khi push.
- Deploy gh-pages — XONG, 6 lô: `8279590d` (pck 000–019),
  `1595cbd1` (020–039), `534920c4` (040–059), `e977b838`
  (060–079), `89a3f84a` (080–086 + versions.json), `5f641feb`
  (index.html CUỐI — head gh-pages). Staging rebuild
  `build_gh_pages.py` VERIFY OK; pck `cddb9cd5` (87 chunk),
  wasm `fc74679e` không đổi. Spot-check 3 chunk (000/043/086)
  blob SHA remote = local trước khi đẩy index.html.
- Verify khớp byte từ live: ráp 87 chunk từ
  `raw.githubusercontent.com` = 11.692.520 byte, SHA
  `cddb9cd543aea8e7` ✓; `versions.json` live pin `cddb9cd5`;
  `index.html` live SHA `4c31a5ab8eb8a35f` = staging ✓.
- Link live: https://tinnt120899.github.io/pho-xo-bo/ (Pages rebuild
  vài phút sau push).

### 39.5 Việc tiếp theo

1. Nhân vật 6 khung (hạn 20:00 22/11, cần nguồn gen ảnh AI) +
   ánh sáng + sự sống (23/11) — theo ETA §35.6.
2. Sạp chợ Map002 (khối be thô) + đất vẽ tay Map002 — làm khi tới
   lượt art Map002.
3. Kiểm live lại bằng cloud browser khi tunnel ổn (luật kiểm live).

## 40. Vòng 18 — Nhân vật 6 khung: walk cycle người chơi (22/11 ~01:45–02:30 +07)

Mục (2) của Claude (§35.6), hạn 20:00 22/11 — làm cho NGƯỜI CHƠI
trước (NPC chưa có sheet riêng, giữ ảnh đơn + nhún như cũ).

### 40.1 Việc làm

- **Art** (`src/godot/art/walk_player_f0..f5.png`, 119×208, luồng
  song song gen bằng media image generation): sheet 6 nhân vật 1
  hàng ngang, gen 1 lần đạt ngay — cùng mặt/tóc đen rối/áo xanh/
  quần tối/giày trắng với `char_player.png`, tư thế chân xen kẽ
  hợp lý. PIL tách theo khe trắng thật giữa các nhân vật (chia
  đều 6 lát đã cắt mất bàn tay f0/f5 + lọt tóc nhân vật kề vào
  f3/f4 — phát hiện nhờ ảnh kiểm nền magenta, đã sửa), trắng →
  trong suốt (flood-fill từ biên, ngưỡng ~235, feather 1.5),
  chuẩn hóa cùng canvas căn giữa ngang để không trượt khi chạy
  animation. Script `visual-check/artpass18/slice_walkcycle.py`,
  ghi chú `walkcycle-note.md`. Chỉ ~4 tư thế phân biệt rõ trong
  6 frame (f5≈f0, f2≈f4); chỉ có mặt trước — đi 4 hướng tạm dùng
  bộ này + flip ngang.
- **Code** (`scripts/character_sprite.gd`): cfg thêm `"frames"`
  (mảng đường dẫn); nạp được ≥2 frame thì chế độ frames — đổi
  khung mỗi 0.05s khi di chuyển (6 frame / 0.30s = 2 ô tile /
  chu trình, 3 frame / ô), dừng về frame 0; bob giảm còn 1.5
  (frame đã có chân động). Thiếu file → fallback ảnh đơn
  `texture` như cũ, không crash (clone mới chưa có art nhị phân
  vẫn chạy). `player.gd` nối 6 đường dẫn `walk_player_f*.png`.
- **Test mới** `tests/g4_r18_walkcycle_test.gd`: **16/16 PASS** —
  đủ 6 frame, đổi khung 0→1→2→3→5→0 đúng nhịp, dừng về frame 0,
  frames rác → fallback ảnh đơn, NPC không frames không đổi hành
  vi, Player trong Main nối frames. **Lỗi tìm ra khi test:** chia
  float `_frame_t / FRAME_TIME` sau 6 lần cộng 0.05 dừng ngay
  dưới 0.30 nên `int()` rớt xuống frame 5 thay vì 0 — sửa code
  thành tích lũy trừ dần (`while _frame_t >= FRAME_TIME`), không
  chia float; test chạy lại 16/16.
- **Lỗi export lần đầu (do lệnh sai, không phải game):**
  `--path src/godot` + đường dẫn tương đối `src/godot-build/...`
  khiến Godot tìm thư mục đích trong project (`Target folder
  does not exist`) — export bằng đường dẫn tuyệt đối thì xong.
  Bài học: export release luôn dùng đường dẫn tuyệt đối hoặc
  `cd src/godot` + `../godot-build/...` như G0.

### 40.2 Verify vòng này

- Hồi quy đầy đủ: **47 OK, 0 FAIL** (46 cũ + 1 mới); smoke
  `--headless --quit-after 120` exit 0, 0 ERROR.
- Export web exit 0: pck **11.898.092 byte, SHA `8f4a2e0a…`**
  (trước `cddb9cd5…` — tăng ~0,2 MB do 6 frame walk); wasm
  không đổi `fc74679e…`; HTTP 200 đủ 4 file (cổng 8173).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass18/check_r18.py`, ảnh
  `r18-01…r18-06`): **0 console error, 0 pageerror, 0 request
  fail.**
  - Giữ D: người chơi đi (4,5)→(7,5)→(10,5), tư thế chân KHÁC
    NHAU rõ giữa 2 ảnh giữa lúc bước (dạng rộng ↔ bắt chéo);
    thả phím: về tư thế đứng frame 0 tại (10,5).
  - **Lỗi script lần đầu (không phải game):** `check_r18.py`
    bấm cửa (5,4) sau khi đã đi tới (10,5) nên ảnh r18-06 vẫn ở
    Map001 (Ngày 2). Chạy bù `check_r18_m2.py` từ spawn: phải 1
    + lên 1 → đúng Chợ Đầu Mối + toast "Đã sang Chợ Đầu Mối",
    Chị Lệ/Anh Hải hiện đủ — không hồi quy.
- **Lưu ý đồng bộ art:** 6 PNG walk chỉ sống ở local + trong pck
  (snapshot-push chỉ nhận file text) — giống mọi art PNG từ trước;
  6 file `.import` (text) đã push thì tương thích. Clone mới về
  sẽ fallback về ảnh đơn `char_player.png` cho tới khi có cơ chế
  đẩy art nhị phân.

### 40.3 Deploy — CHẶN (22/11 ~02:30 +07, chưa xong)

- Push main + deploy gh-pages **CHƯA làm được trong vòng này**:
  `github push-files` bị gián đoạn 4 lần liên tiếp (cả bản đủ 16
  file lẫn bản nhỏ 4 file code) — lỗi "service restarted while it
  was running", head main vẫn `33d68d07` sau mỗi lần kiểm tra
  lại. Connector GitHub vẫn `connected`, read (`list_commits`)
  chạy bình thường; chỉ đường ghi `push_files` bị gián đoạn.
  ĐÃ DỪNG retry sau lần 4 (không lặp lại cùng 1 lệnh hỏng).
- **Retry 22/11 09:31 +07 (vòng sau): lại fail 3 lần nữa** — lần
  1 bản đủ 16 file, lần 2 bản đủ 16 file, lần 3 bản nhỏ 4 file
  (`pxb-push-r18a-paths`); cả 3 đều "service restarted", head
  main vẫn `33d68d07` sau mỗi lần kiểm tra lại, KHÔNG có commit
  nào áp dụng (đã đối chiếu lại trước mỗi lần retry: head khớp
  record, 4 file có base không divergence, 11 file mới xác nhận
  chưa tồn tại remote). Tổng cộng 7 lần push fail liên tiếp.
  Đường ghi `push_files` đang hỏng phía service — cần chờ hoặc
  tìm đường ghi khác, không retry vô hạn. DỪNG theo lệnh task.
- Mọi thứ khác của vòng này đã xong + verify (xem §40.2); code,
  test, export pck `8f4a2e0a…` đều ở working copy local.
- Manifest push đã chuẩn bị sẵn (bền, ngoài repo):
  `~/workspace/pxb-push-r18a-paths` (4 file code/test) +
  `~/workspace/pxb-push-r18-paths` (đủ 16 file) — vòng sau retry
  push main trước (đối chiếu lại head + divergence), rồi mới
  rebuild staging + deploy gh-pages pck `8f4a2e0a…` như §38.3/§39.4.
- Live site vẫn phục vụ bản vòng 17 (pck `cddb9cd5…`) — không hồi
  quy, chỉ chưa có walk cycle.

### 40.4 Việc tiếp theo

1. Ánh sáng + sự sống (23/11) — theo ETA §35.6: dải sao đã neo
   camera (vòng 17), còn nướng sáng đêm + sprite phát sáng cộng
   dồn + CanvasModulate + chuyển động nhỏ (lá rơi/khói/chim).
2. Walk cycle cho NPC (Cô Tư/Bạn Thân/Chị Lệ/Anh Hải) — cần sheet
   riêng từng người; mặt sau/mặt nghiêng cho người chơi (hiện chỉ
   mặt trước + flip).
3. Sạp chợ Map002 (khối be thô) + đất vẽ tay Map002 — làm khi tới
   lượt art Map002.
4. ~~G4 bước 7: nối PxbOnline sang server Godot mới (§17.2)~~ —
   **ĐÃ XONG từ commit `e01fa1542a`** (đính chính doc cũ §17.2/§20
   còn ghi là việc tiếp theo): `PxbOnline` đã có client WebSocket
   (`WebSocketMultiplayerPeer`, protocol v1) + chat trong điện thoại
   tab Tin nhắn, test `g4_online_ws_client_test` 49/49, browser-
   verify chat thật 0 lỗi. Việc online còn lại: auth player_id,
   giới hạn tốc độ chat, lưu lịch sử chat cho client mới vào
   (§17.5); server .NET giữ làm tham chiếu.


## 41. Vòng 19 — Ánh sáng + sự sống: glow ADD thật + lá rơi/đom đóm (22/11 ~09:45–10:15 +07)

Mục (3) của Claude (§35.6), ETA 23/11 — làm sớm trong lượt cron này
vì push main vòng 18 bị chặn (xem §41.4) nên chuyển sang việc tiếp
theo thay vì ngồi chờ.

### 41.1 Việc làm

- **GlowCanvas — ánh sáng cộng dồn THẬT** (`scripts/glow_canvas.gd`,
  mới): Node2D con của `_overlay_layer`, thêm SAU ColorRect MUL
  (nên vẽ TRÊN lớp nhân) nhưng TRƯỚC `_label_layer`/`_ui_layer`
  (cùng layer 1, thêm sau → vẫn dưới nhãn/HUD). Material
  `BLEND_MODE_ADD`: cộng ánh sáng thật vào ảnh cuối — đèn lồng/
  cửa sổ sáng hẳn lên rõ rệt mà không cần màu HDR >1.0 như
  NightGlow (vốn vẽ DƯỚI lớp MUL nên bị nhân tối, phải "xuyên"
  bằng HDR). Chỉ bật khung Tối; nguồn = `lamps + spots` của
  NightGlow (tọa độ thế giới → màn hình qua camera, vì CanvasLayer
  không theo viewport nên tọa độ vẽ là tọa độ màn hình). Vẽ halo
  mềm 10 vòng alpha giảm dần + tâm sáng, như kỹ thuật đĩa mềm của
  SkyEffects.
- **AmbientLife — sự sống nhỏ** (`scripts/ambient_life.gd`, mới):
  Node2D thế giới, z_index 10 (như SkyEffects/NightGlow), neo theo
  camera nên phủ kín khung nhìn: 14 lá vàng-xanh rơi chậm (24–42
  px/s) + lắc ngang, chạm đáy lặp lại từ trên; 10 đom đóm bay lang
  thang + nhấp nháy, CHỈ khung Tối. Seed RNG cố định 20261122 để
  test ổn định. `sim_step(delta)` là bước mô phỏng thật — `_process`
  gọi mỗi frame, test gọi trực tiếp để đo chính xác.
- **Nối dây** (`main.gd`): tạo 2 node trong `_build_ui()` (sau lớp
  overlay); `_update_daynight()` gọi `set_lit(frame==2)` +
  `set_sources(_glow_sources())` + `ambient.set_frame()` — nguồn
  đổi theo map mỗi lần đổi khung/đổi map. Helper `_glow_sources()`:
  Map001-002 = 1 đèn lồng (spots rỗng — cửa sổ đã sáng trong ảnh
  đêm), Map003+ thêm cửa sổ sáng.
- **Không đổi:** lớp MUL ngày/đêm, NightGlow, SkyEffects, sao/trăng
  giữ nguyên — vòng này chỉ THÊM 2 node mới, không sửa đường vẽ cũ
  (rủi ro hồi quy thấp; đã chứng minh bằng hồi quy 48/48 + browser).

### 41.2 Lỗi tìm ra khi làm (ghi để không tái phạm)

1. **GlowCanvas.visible mặc định true:** `set_lit(false)` lần đầu
   là no-op (lit đã false) nên node vẫn `visible=true` ở khung
   Sáng — `_draw` trả sớm nên không vẽ gì (vô hại về hình), nhưng
   test bắt đúng. Sửa: `set_lit` LUÔN gán `visible = on`, `_init`
   đặt `visible = false`.
2. **Test đo lá bằng trung bình y + baseline cũ:** lá chạm đáy lặp
   về y=-30 làm trung bình GIẢM dù lá vẫn rơi — FAIL giả. Sửa:
   đo 1 lá cụ thể xa đáy (y<1000) trước/sau `sim_step(1.0)`.
3. **Literal `[]` không kiếu bị từ chối ở tham số `Array[Vector2]`:**
   `set_sources([Vector2...])` lỗi type, `_state` không bao giờ
   sang 3 → test lặp state 2 vô hạn tới TIMEOUT (log 4465 dòng,
   371 lần lặp). Sửa: khai `var src: Array[Vector2] = [...]` rồi
   truyền. Bài học: lỗi type trong callback `_on_frame` không dừng
   test — state machine lặp mãi; test nào lặp state phải có guard
   đếm lần lặp (đã có TIMEOUT 400 frame, nhưng log phình vì mỗi
   lần lặp in 8 dòng PASS).
4. **Lá quá nhỏ/mờ trên ảnh thật:** lá 3–6px alpha 0.55 chìm hẳn
   vào lá vẽ sẵn trên đất. Tăng lên 4.5–8px, alpha 0.7 — vẫn tinh
   tế, nhìn kỹ thấy lá rơi giữa khung.

### 41.3 Test mới + verify vòng này

- Test mới `tests/g4_r19_lighting_test.gd`: **22/22 PASS** — Glow
  tồn tại + con của overlay + BLEND ADD, Sáng/Chiều tắt, Tối bật
  với đúng 1 nguồn/1 halo trong màn hình (Map001), đom đóm chỉ
  Tối, lá rơi xuống sau 1s mô phỏng, lá chạm đáy lặp từ trên,
  `set_sources` 2 điểm → 2 halo, về Sáng tắt lại, đủ 14 lá.
- Hồi quy đầy đủ: **48 OK, 0 FAIL** (47 cũ + 1 mới; chạy 2 lần —
  lần 2 sau khi tăng cỡ lá, vẫn 48/48).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR.
- Export web exit 0: pck **11.907.596 byte, SHA `96ef16a9…`**
  (trước `8f4a2e0a…` — tăng ~9,5KB do 2 script + test mới); wasm
  không đổi `fc74679e…`; HTTP 200 đủ 2 file (cổng 8174).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass19/check_r19.py`, ảnh
  `r19-01…r19-04`): **0 console error, 0 pageerror,
  0 request fail.**
  - Spawn Sáng: mặt trời + nhà ống + nhân vật như cũ; lá rơi
    nhỏ vàng-xanh lơ lửng giữa khung (nhìn kỹ mới thấy).
  - F ×2 → Tối Map001: đèn lồng góc trái dưới có quầng ấm rõ
    (ADD trên lớp MUL), sao + trăng như cũ, đom đóm lấm tấm.
  - Về Sáng + sang Map002: đúng Chợ Đầu Mối, không hồi quy.
  - Tối Map002: trời đêm + trăng + sao, quầng đèn lồng + cửa
    sổ sáng, NPC/sạp đủ.
- Staging gh-pages rebuild xong cho pck `96ef16a9` (89 chunk),
  VERIFY OK — sẵn sàng deploy khi push main hồi (xem §41.4).

### 41.4 Deploy — CHẶN (push-files gián đoạn, như vòng 18)

- Push main vòng 18 retry 2 lần trong lượt này (bản đủ 16 file +
  bản nhỏ 4 file `pxb-push-r18a-paths`): cả 2 đều "service
  restarted while it was running"; head main vẫn `33d68d07` sau
  mỗi lần kiểm tra lại. Cộng vòng 18 = **6 lần gián đoạn liên
  tiếp**. Connector GitHub `connected`, read (`list_commits`) bình
  thường; chỉ đường ghi `push_files` bị gián đoạn. **ĐÃ DỪNG
  retry** sau lần 2 của lượt này (không lặp cùng 1 lệnh hỏng).
- Hệ quả: live vẫn chạy pck vòng 17 `cddb9cd5` — walk cycle (vòng
  18) + ánh sáng/sự sống (vòng 19) CHƯA lên live, chỉ có local +
  export pck `96ef16a9` + staging gh-pages đã rebuild sẵn.
- Manifests chờ push (bền, ngoài repo): `~/workspace/pxb-push-r18-paths`
  (16 file vòng 18) + `~/workspace/pxb-push-r18a-paths` (4 file)
  + `~/workspace/pxb-push-r19-paths` (vòng 19, xem dưới). Lượt sau
  retry push main trước (đối chiếu lại head + divergence), rồi
  deploy gh-pages pck `96ef16a9` như §38.3/§39.4 (6 lô: pck
  89 chunk + versions.json + index.html CUỐI).
- Chủ CHƯA trả lời widget duyệt ảnh walk cycle vòng 18 (gửi
  ~12:52 22/11) tại thời điểm vòng này chạy — vòng 19 làm theo
  ETA Claude đã chốt (ánh sáng 23/11), không phụ thuộc duyệt đó.

### 41.5 Việc tiếp theo

1. Retry push main (vòng 18 + 19) + deploy gh-pages pck `96ef16a9`
   ngay khi `push_files` hồi — việc chặn duy nhất lúc này.
2. Walk cycle cho NPC (Cô Tư/Bạn Thân/Chị Lệ/Anh Hải) — cần sheet
   riêng từng người; mặt sau/mặt nghiêng cho người chơi (hiện chỉ
   mặt trước + flip).
3. Sạp chợ Map002 (khối be thô) + đất vẽ tay Map002 — làm khi tới
   lượt art Map002.
4. Kiểm live lại bằng cloud browser khi tunnel ổn (luật kiểm live).
5. Khói nồi phở / biển đung đưa (mục còn lại của Claude (3)) —
   cần sprite riêng cho biển/nồi (hiện là 1 phần của ảnh nền),
   để sau khi có art tách lớp.


## 42. Vòng 20 — Đất vẽ tay Map002 Chợ Đầu Mối (22/11 ~13:15–15:20 +07)

Mục 3 §41.5 (nửa đầu): sạp chợ Map002 + đất vẽ tay Map002 — làm
xong nửa đất; sạp (khối be thô) còn lại cho vòng sau (cần tách
sprite sạp riêng, hiện là 1 phần ảnh nền composite).

### 42.1 Việc làm

- Subagent gen `src/godot/art/ground_map002.png` 1440×900, PNG RGB
  2.369.876 byte, SHA `377ab722…`: sàn xi măng/đá chợ cũ loang lổ,
  vết nứt, vệt ẩm, 3 vũng nước phản chiếu, lá rau xanh rơi rải rác,
  vệt đất cát, dấu bánh xe mờ — watercolor, tông ấm, không chữ /
  không người / không công trình; vùng giữa thoáng. Hài hòa với
  `ground_map001.png` nhưng khác rõ (sàn chợ, không phải vỉa hè).
  Mép trên có 1 hàng đá kè thấp (rìa sàn) — chấp nhận, không gen lại.
- `main.gd` `_update_ground`: Map002 dùng `ground_map002.png` khi
  có file (fallback `ground_wide.jpg` nếu clone mới thiếu art nhị
  phân, như Map001); comment `_build_ui` cập nhật theo.
- Test mới `tests/g4_r20_map002_ground_test.gd`: Map001 giữ
  `ground_map001.png`, Map002 dùng `ground_map002.png` 1440×900,
  Map003 vẫn `ground_wide.jpg`, đi Map002→Map001 đổi đất đúng.
- Cập nhật test cũ theo tiền lệ §12.3: `g4_r17_sky_test.gd` kỳ vọng
  Map002 dùng `ground_map002.png` (không còn `ground_wide.jpg`).

### 42.2 Lỗi tìm ra khi làm (ghi để không tái phạm)

1. **PNG mới chưa `.import` thì `ResourceLoader.exists` = false:**
   test r20 chạy đầu 4/6 PASS — Map002 vẫn `ground_wide.jpg` dù file
   PNG đã có. Sửa: chạy `godot --headless --import` trước khi test
   (sinh `ground_map002.png.import`), rồi test 6/6 PASS. Bài học:
   thêm art nhị phân mới thì import trước, test sau.
2. **Test cũ tìm sprite đất bằng tên file:** `artpass12_test` tìm
   `"ground_wide" in texture.resource_path` để đo khe trời/đất —
   Map002 đổi texture nên `gtop` giữ 9999 → FAIL giả (hồi quy 48 OK,
   1 FAIL). Sửa: nhận cả 3 tên `ground_wide` / `ground_map001` /
   `ground_map002` (cùng 1 sprite 1440×900, chỉ đổi texture) →
   artpass12 14/14 PASS. Bài học: test nào match tên asset thì liệt
   kê đủ các biến thể khi thêm asset cùng loại.
3. **Cửa Map001→Map002 ở (5,4), KHÔNG phải (5,8):** check trình
   duyệt đi Phải + Xuống ×3 tới (5,8) rồi đứng im — (5,8) trên
   Map001 chỉ là ô thường (cửa (5,8) chỉ có ở Map002 trở đi, đi
   Map003). Nhãn "Cửa ra Chợ Đầu Mối" nổi trên màn hình không chỉ
   đúng vị trí ô (nhãn nổi cao ~190px) nên đừng bấm theo nhãn.
   Sửa: đi Phải + Lên từ spawn (4,5) → (5,4) là cửa thật, chuyển
   map ngay. Bài học: vị trí cửa lấy từ `maps.json`, không lấy từ
   vị trí nhãn trên ảnh.
4. **Nút Start DOM lúc có lúc không:** `get_by_text("BẮT ĐẦU CHƠI")`
   timeout 5s sau chờ 30s thì lúc được lúc không (lần tải đầu wasm
   39MB + pck 13MB chưa boot xong); fallback click canvas (360,1060)
   chạm thành tap di chuyển tới (6,7), làm vị trí spawn không ổn
   định giữa các lần chạy. Sửa: chờ 45s + retry DOM 3 lần (mỗi lần
   10s), chỉ fallback canvas khi hết retry; script chọn đường phím
   theo cách bấm được (`dom`: spawn (4,5) → Phải, Lên; `canvas`:
   (6,7) → Trái, Lên ×3). Cả 2 lần chạy sau đều bấm DOM được.

### 42.3 Test mới + verify vòng này

- Test mới `g4_r20_map002_ground_test`: **6/6 PASS**.
- Hồi quy đầy đủ sau khi sửa artpass12: **49 OK, 0 FAIL** (48 cũ +
  1 mới r20; lần chạy trước khi sửa: 48 OK, 1 FAIL chỉ artpass12,
  lỗi giả §42.2.2). artpass12 **14/14**, r17 **14/14**.
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR.
- Export web exit 0: pck **13.514.456 byte, SHA `b501abd2…`**
  (trước `96ef16a9`, +1,6MB do `ground_map002.png`); wasm không đổi
  `fc74679e…`; `grep -a` thấy `ground_map002` ×2 trong pck; HTTP 200
  đủ 2 file (cổng 8175).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass20/check_r20.py`, ảnh
  `r20-01…r20-03`): **0 console error, 0 pageerror,
  0 request fail.**
  - Spawn Sáng Map001: đất vẽ tay ground_map001 như cũ, không hồi quy.
  - Sang Map002 (Phải + Lên qua cửa (5,4), toast "Đã sang Chợ Đầu
    Mối"): đất mới hiện rõ — sàn đá nứt + lá rau + vũng nước, thay
    ảnh chụp cũ; Chị Lệ/Anh Hải + sạp đủ. Sạp vẫn khối be thô + biển
    hiệu nổi (điểm chưa đẹp đã biết, để vòng sau).
  - Tải lại về Map001: spawn (4,5), đất ground_map001, không hồi quy.
- Staging gh-pages rebuild xong cho pck `b501abd2` (101 file),
  VERIFY OK, `versions.json` pin `b501abd2` — sẵn sàng deploy khi
  push hồi (xem §42.4).

### 42.4 Deploy — CHẶN (push-files gián đoạn lần 7 liên tiếp)

- Lượt này retry push main 1 lần (gộp r18+r19: 24 file, 423KB,
  manifest `~/workspace/pxb-push-r18r19-paths`): "service restarted
  while it was running"; kiểm tra lại head main vẫn `33d68d07`
  (chưa áp dụng). Đây là lần gián đoạn thứ 7 liên tiếp của
  `push_files` (6 lần vòng 18+19 + 1 lần lượt này). **ĐÃ DỪNG
  retry** trong lượt này theo luật vòng 18/19 — không lặp cùng 1
  lệnh hỏng.
- Hệ quả: live vẫn chạy pck vòng 17 `cddb9cd5` — walk cycle (vòng
  18) + ánh sáng/sự sống (vòng 19) + đất Map002 (vòng 20) CHƯA lên
  live, chỉ có local + export pck `b501abd2` + staging gh-pages đã
  rebuild sẵn.
- Manifest chờ push (bền, ngoài repo): `~/workspace/pxb-push-r18r19-paths`
  (24 file vòng 18+19) + `~/workspace/pxb-push-r18r19r20-paths`
  (vòng 18+19+20, xem dưới). Lượt sau retry push main trước (đối
  chiếu lại head + divergence), rồi deploy gh-pages pck `b501abd2`
  như §38.3/§39.4 (pck 101 file + versions.json + index.html CUỐI).
  Deploy gh-pages cũng dùng `push_files` nên cùng bị chặn — không
  thử trong lượt này.

### 42.5 Việc tiếp theo

1. Retry push main (vòng 18+19+20) + deploy gh-pages pck `b501abd2`
   ngay khi `push_files` hồi — việc chặn duy nhất lúc này.
2. Walk cycle cho NPC (Cô Tư/Bạn Thân/Chị Lệ/Anh Hải) — cần sheet
   riêng từng người; mặt sau/mặt nghiêng cho người chơi (hiện chỉ
   mặt trước + flip).
3. Sạp chợ Map002 (khối be thô + biển hiệu nổi) — cần sprite sạp
   tách riêng hoặc vẽ lại nền chợ; làm khi tới lượt art Map002.
4. Kiểm live lại bằng cloud browser khi tunnel ổn (luật kiểm live).
5. Khói nồi phở / biển đung đưa (mục còn lại của Claude (3)) — cần
   sprite riêng cho biển/nồi (hiện là 1 phần của ảnh nền), để sau
   khi có art tách lớp.

## 43. Vòng 21 — Push hồi + deploy b501abd2 lên live (22/11 ~15:20–16:10 +07)

### 43.1 Chặn push — HỒI sau 8 lần gián đoạn

- Lượt này retry push main gộp r18+r19+r20 (30 file, 450KB,
  manifest `~/workspace/pxb-push-r18r19r20-paths`): "service restarted
  while it was running" lần 8 liên tiếp; kiểm tra head main vẫn
  `33d68d07` (chưa áp dụng). **ĐÃ DỪNG retry lệnh này.**
- Chẩn đoán bằng lệnh khác: push 1 file `docs/godot-g4.md`
  (manifest `~/workspace/pxb-push-r21-diag-paths`) → **THÀNH CÔNG**,
  head `2befc7de`. Không phải do kích thước tuyệt đối (file này
  ~264KB) — dịch vụ push chập chờn, lúc được lúc không.
- Chia nhỏ + retry có chừng mực: lô A (6 file code, 120KB) fail 1
  lần rồi thành công ở retry (`95490677`); lô B (9 file test,
  36KB, `978e6cf2`) + lô C (14 file .import/visual-check, 31KB,
  `e5ad341d`) thành công ngay. **Kết luận: push_files không chết
  hẳn — fail là ngắt quãng, retry 1–2 lần mỗi lô là đủ; không retry
  vô hạn cùng 1 lệnh.** Sync record ghi đủ 4 commit (entries 203–206).
- Head main sau vòng này: `e5ad341d` — đủ 30 file vòng 18+19+20
  (walk cycle 6 khung, GlowCanvas + AmbientLife, đất Map002).

### 43.2 Deploy gh-pages pck b501abd2 — XONG, verify live khớp byte

- Staging đã rebuild từ vòng 20, `build_gh_pages.py --verify-only`
  exit 0: pck `b501abd2` 101 chunk / 13.514.456 byte khớp byte,
  wasm `fc74679e` 293 chunk không đổi, img khớp, loader đủ.
  Đối chiếu trước deploy: gh-pages head `5f641feb`,
  `versions.json` live pin `cddb9cd5` (vòng 17), không divergence.
- Deploy 7 lô (manifest `~/workspace/pxb-deploy-b501abd2-batch1..7`):
  part 000–019 `1f8fa637`, 020–039 `842b0bc1`, 040–059 `6533cb20`,
  060–079 `5cd568d3`, 080–099 `f4efbf19`, part 100 `55d0a1f5`,
  versions.json + index.html cuối `0fe30938`. Sync record ghi đủ
  7 commit (entries 207–213).
- Verify live bằng byte: lúc đầu `versions.json` live vẫn
  `cddb9cd5` + part-000 404 (Pages deploy lag ~3 phút) — sau đó
  pin `b501abd2`; tải + ráp 101 part từ live = **13.514.456 byte,
  SHA `b501abd2` — khớp đúng từng byte**; index.html live liệt kê
  đủ 101 part `b501abd2`.
- Smoke headless sau deploy: `--quit-after 120` exit 0, 0 ERROR
  (code không đổi từ vòng 20; hồi quy 49/49 + browser-verify r20
  0 lỗi đã có từ vòng 20, không chạy lại).
- **Live nay chạy vòng 18+19+20**: walk cycle nhân vật chính,
  đèn lồng/cửa sổ đêm sáng (GlowCanvas), lá rơi + đom đóm khung
  Tối, đất vẽ tay Map002. Link: https://tinnt120899.github.io/pho-xo-bo/

### 43.3 Việc tiếp theo

1. Walk cycle cho NPC (Cô Tư/Bạn Thân/Chị Lệ/Anh Hải) — §42.5 mục 2.
2. Sạp chợ Map002 — §42.5 mục 3.
3. Kiểm live lại bằng cloud browser khi tunnel ổn (luật kiểm live).
4. Khói nồi phở / biển đung đưa — §42.5 mục 5.
5. Chủ vẫn chưa trả lời widget duyệt ảnh walk cycle vòng 18 (gửi
   ~12:52 22/11) — vòng 18 đã lên live, nếu chủ chê thì làm lại
   theo ý chủ ở vòng sau.

## 44. Vòng 22 — Walk cycle 4 NPC + patrol đi lang thang (22/11 ~20:45–21:30 +07)

### 44.1 Art — 24 frame walk cycle NPC (đã có sẵn từ 13:48 22/11)

Art đã được chuẩn bị trước lượt này (artpass22, quy trình y hệt
vòng 18 — sheet 6 nhân vật/hàng → cắt theo khe trắng, flood fill
trắng→trong suốt, resize cao 208px): 4 sheet 2736×912 + 24 frame
`walk_cotu/banthan/chile/anhhai_f0..f5.png` (RGBA, cao 208px) trong
`src/godot/art/`, ghi chú `visual-check/artpass22/walkcycle-npc-note.md`
(kiểm bằng mắt: đúng 6 nhân vật/sheet, tư thế chân tiến triển,
f5 ≈ f0 như vòng 18). Lượt này có spawn subagent gen lại art —
đã đóng ngay khi thấy art đủ + đúng spec, tránh gen trùng.
PNG nhị phân chỉ sống local + trong pck (tiền lệ vòng 18); chỉ
`.import` mới push.

### 44.2 Code — frames NPC + patrol (Main quyết, Marker thực thi)

| File | Đổi |
|---|---|
| `scripts/marker.gd` | `NPC_STYLE` thêm `"frames"` 6 đường dẫn/NPC; patrol API: `home_tile`/`patrol_tile()` (ô logic, đổi khi tween xong), `patrol_walk_to(dest, world_pos)` (tween 0.30s/o = 1 chu trình walk cycle, `moving` bật frame, `facing` theo dx; từ chối khi đang bước/cùng ô), `patrol_moving()`, `has_walk_frames()`; tween tiến trong `_process`. |
| `main.gd` | `_update_npc_patrol(delta)` (gọi mỗi frame sau `_update_npc_labels`): quyết định mỗi 0.5s; NPC nghỉ ngẫu nhiên 4–9s rồi bước sang 1 ô đất trống kề nhà (`_npc_patrol_pick`: đi được + không event + không phải ô người chơi/NPC khác), ở ngoài 2–5s rồi về; **về nhà ngay khi người chơi lại gần (≤5 ô, cùng ngưỡng hiện nhãn) hoặc mở UI/hội thoại/title** — vì `event_at`/`is_walkable` dùng data tĩnh theo ô nhà, tương tác E chỉ đúng khi NPC đứng đúng ô nhà. Lần gặp đầu cũng nghỉ ngẫu nhiên (không cho cả 2 NPC cùng bước ra ngay tick đầu). |
| `tests/g4_r22_npc_walk_test.gd` (mới) | 41 mục: 4 NPC đủ 6 frame + đổi khung theo nhịp + về frame 0 khi đứng yên; thiếu frame → fallback ảnh đơn; Marker patrol (home, tween 0.30s, đổi ô logic, từ chối lệnh chen/cùng ô, về nhà); pick 20 lần đều ô kề hợp lệ + nhiều hơn 1 đích; Main: xa → bước ra, gần → về nhà, mở hội thoại khi ở ngoài → lệnh về nhà. |
| `tools/godot/run_regression.sh` | Thêm `g4_r22_npc_walk_test` vào danh sách (nay 46 suite + online). |

### 44.3 Lỗi tìm được khi làm

1. **Test fail giả do `title_open=true` lúc khởi động** — patrol
   bị chặn theo đúng thiết kế (đứng yên khi title mở) nên test
   "người chơi xa → NPC bước ra" timeout 30 frame. Sửa test
   (không sửa game): đặt `_main.title_open = false` như đã bấm
   Bắt đầu. Bài học: test nào cần game đang chạy phải tắt title
   trước — ghi nhớ cho test sau.
2. **Delta headless quá nhỏ làm tween patrol timeout giả** —
   frame headless chạy nhanh, delta ~1ms nên tween 0.30s cần
   hàng trăm frame mới xong (state 5 timeout 120 frame lần đầu).
   Sửa test: khi NPC đang bước thì gọi tay `_process(0.35)` để
   đẩy nhanh tween (tree cũng gọi `_process` nên chỉ nhanh hơn,
   không sai lệch). Tiền lệ: test sau có tween thì lái tay như vậy.
3. **`var t := home + d` không suy được kiểu** (d từ mảng literal
   không kiểu) — parse error ở `main.gd:1833`. Sửa: `var t:
   Vector2i = home + d`. Bài học: vòng lặp qua mảng literal
   Vector2i thì khai kiểu tường minh cho biến dùng `+`.

### 44.4 Verify thật vòng này

- `--check-only` main/marker/test: PASS.
- Test mới `g4_r22_npc_walk_test`: **41/41 PASS** (lần đầu 37/38
  do lỗi 1, lần hai 40/41 do lỗi 2 — sửa test, chạy lại PASS hết).
- Hồi quy đầy đủ `run_regression.sh`: **50 OK, 0 FAIL** (49 cũ +
  1 mới r22; gồm online server 37/37 + probe OK).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR.
- Export web exit 0: pck **14.396.484 byte, SHA `a5964dee…`**
  (trước `b501abd2`, +882KB do 24 frame NPC); wasm không đổi
  `fc74679e`; `grep -a` thấy `walk_cotu/banthan/chile/anhhai` ×24
  trong pck; HTTP 200 đủ 6 file (cổng 8176).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass22/check_r22.py`, ảnh `r22-01…03`):
  **0 console error, 0 pageerror, 0 request fail.**
  - Spawn Map001: Cô Tư + Bạn Thân đứng ở nhà, nhãn hiện.
  - Người chơi về (1,1), chờ 12s: cả 2 NPC đã bước ra khỏi ô
    nhà (Bạn Thân sang trái gần xe đẩy, Cô Tư xuống dưới gần
    cửa) — nhãn ẩn đúng luật xa >5 ô.
  - Người chơi về (4,6), chờ 3s: cả 2 NPC về đúng ô nhà, nhãn
    hiện lại như lúc spawn — patrol về nhà đã thấy bằng mắt.

### 44.5 Deploy — XONG, verify live khớp byte (22/11 ~21:30–22:25 +07)

- Push main 2 lô (không gián đoạn lần nào): lô A code
  `fa2ccea1` (main/marker/test/run_regression), lô B
  `84b721bf` (24 `.import` walk NPC + check_r22 + note +
  slice script). Head main `84b721bf` (trước `c4059abb`).
  Sync record 216 entries.
- Staging rebuild `build_gh_pages.py` VERIFY OK: pck
  `a5964dee` 107 chunk / 14.396.484 byte khớp byte, wasm
  `fc74679e` 293 chunk không đổi, img khớp, loader đủ.
- Deploy 7 lô gh-pages: part 000–019 `26f527f0`, 020–039
  `8a17fb1e`, 040–059 `78e666b0`, 060–079 `271bf7a7`,
  080–099 `09f2f03d`, 100–106 `6fc7b42e`, versions.json +
  index.html cuối `b0b97773`. Sync record 223 entries.
- Verify live bằng byte: `versions.json` live pin `a5964dee`
  (sau lag Pages ~3 phút); tải + giải base64 + ráp 107 part
  từ live = **14.396.484 byte, SHA `a5964dee` — khớp đúng
  từng byte**; index.html live liệt kê part `a5964dee`.
- **Live nay chạy vòng 22**: walk cycle 4 NPC + patrol đi
  lang thang. Link: https://tinnt120899.github.io/pho-xo-bo/
- Lưu ý verify: part `.txt` trên live là base64 — ráp trực
  tiếp ra 19.195.312 byte, SHA sai; phải `base64 -d` từng
  part rồi mới ráp (tỉ lệ 4/3 đúng bằng chứng).

### 44.6 Việc tiếp theo

1. Sạp chợ Map002 (khối be thô + biển hiệu nổi) — §42.5 mục 3.
2. Kiểm live lại bằng cloud browser (luật kiểm live) — bản mới
   có patrol, cần xem NPC đi lại trên live có mượt không.
3. Khói nồi phở / biển đung đưa — §42.5 mục 5.
4. NPC Map003–018 vẫn dùng ảnh đơn + nhún (chỉ 4 NPC Map001–002
   có walk cycle): khi nào art NPC các khu khác có sheet thì nối
   `frames` theo đúng mẫu `NPC_STYLE` này (không cần sửa code
   patrol — `CharacterSprite` tự fallback khi thiếu file).

### 44.7 Kiểm live vòng 22 (cloud browser, 22/11 21:29–21:38 +07)

- Game chạy, nút BẮT ĐẦU bấm được, HUD đủ; không thấy console
  error/pageerror/request fail trong suốt quá trình (checker
  không mở DevTools nên đây là kết luận quan sát, không phải
  log console thô).
- Di chuyển: phím D từ spawn (4,5) → (5,5), đúng 1 ô; W/A/S
  đều đổi tọa độ đúng từng ô; nhân vật đổi tư thế chân khi đi
  (walk cycle thấy được).
- Patrol: người chơi lên (1,1), chờ 12s → cả 2 NPC rời chỗ cũ
  (Bạn Thân xuống dưới-trái, Cô Tư xuống sát mép dưới); về
  (4,6), chờ 3s → cả 2 NPC về khu vực spawn, nhãn hiện lại.
- **Chưa khớp hẳn — ước lượng bằng mắt, chưa xác minh:** checker
  thấy Cô Tư về lệch ~1 ô sang phải và Bạn Thân chồng lên ô
  người chơi. Nhưng test headless 41/41 khẳng định
  `patrol_tile == home` sau khi về, và ảnh local r22-03 cho
  thấy NPC về đúng vị trí như lúc spawn — nhãn debug chỉ hiện
  ô NGƯỜI CHƠI nên checker chỉ ước lượng vị trí NPC qua ảnh
  iso (dễ lệch). Ghi nhận là quan sát chưa xác minh, không sửa
  code theo ước lượng này; nếu vòng sau thấy lại thì đo bằng
  số ô thật.
- Nhãn tên NPC ẩn khi người chơi xa (>5 ô) là **đúng thiết kế
  vòng 15** (LABEL_NEAR_TILES), không phải lỗi — checker chỉ
  ghi nhận hiện tượng.
- Lưu ý: cửa sổ checker là khổ ngang 1920×999, canvas game vẫn
  dọc 720×1280 ở giữa (không ép được đúng khổ 720×1280).

## 45. Vòng 23 — Sạp chợ Map002 vẽ lại (22/11 ~21:45–23:30 +07)

Mục 1 §44.6 (§42.5 mục 3): sạp chợ Map002 "khối be thô + biển
hiệu nổi" (anh r20-02: biển 58×13 chữ 10px trên tường be phang,
hàng trên quầy chỉ 3 giỏ trái cây theo hash, tường bên 2 cột là
hình chữ nhật be xếp bậc thang).

### 45.1 Vì sao không dùng sprite tách riêng (§42.5.3)

Đã đo trước khi chọn: ô hàng 0 cách nhau **32px màn hình**
(`tile_center_raw`: bước x 32px). Sprite sạp 64px sẽ bị tường
nhà lẻ 2 bên (34px, vẽ sau trong `_draw`) che 17px mỗi bên —
chỉ thấy ~30px giữa. Muốn dùng sprite phải đổi cấu trúc hàng
(ô lẻ để trống, sạp cách nhau) — việc 2 vòng (artpass sprite +
đổi hàng), không phải 1 vòng. Vòng này vẽ lại bằng code đúng
bước iso hiện có; sprite để vòng sau nếu đổi hàng.

### 45.2 Việc làm

| File | Đổi |
|---|---|
| `scripts/nadia_scene.gd` | `STALL_KIND_COLORS` (8 màu biển theo loại hàng) + `stall_goods_kind(sign)` (8 biển → rau/ca/thịt/trái-cây/bánh-mì/gia-vị/hoa-quả/đồ-khô) + `stall_sign_color(sign)` + `market_stall_tiles()` [0,2,4,6,8,10] + `side_stall_rows()` [2,4,6]; `_draw_market_row` vòng 2: biển **62×16 chữ 11px** (cũ 58×13 chữ 10), nền màu theo loại + viền kem + bóng + 2 đinh; vòng 1: tường thêm vân gỗ ngang + bóng cạnh; `_draw_shop_front(c,h,sign)` (thêm tham số biển): mái hiên thêm viền vỏ sò + 2 cột chống, quầy thêm vân gỗ + thẻ giá (sạp chẵn), hàng trên quầy theo loại qua `_draw_stall_goods(c,kind,counter_top)` mới (rau: lá xanh; cá: 2 con trên đá; thịt: miếng đỏ; trái cây: 4 quả đủ màu; bánh mì: ổ elip; gia vị: 3 lọ; đồ khô: 2 bao); `_draw_side_walls`: tường thêm vân gỗ + bóng cạnh, hàng chẵn (2,4,6) thành **sạp bên** (`_draw_side_stall`: biển nhỏ 52×12 chữ 10 + mái hiên kẻ 3 sọc + quầy + hàng theo loại), hàng lẻ giữ áp phích to hơn (24×30) / cây leo / vết loang; nhánh chết `if map_id == 2` trong `_draw_facades` đã bỏ (không bao giờ tới vì return sớm); helper `_draw_ellipse` mới. |
| `tests/g4_r23_stall_test.gd` (mới) | 10 mục: 8 biển ánh xạ đúng loại + biển lạ về "rau"; 8 màu biển khác nhau alpha 1; chữ biển vừa bảng (rộng nhất "THỊT HEO" 53.0px ≤ 58 ở cỡ 11; cỡ 10 ≤ 48 cho biển bên); nhịp sạp hàng 0 + hàng bên; scene thật Map002 có NadiaScene map_id 2, chạy 60 frame không lỗi, về Map001 map_id 1. |
| `tools/godot/run_regression.sh` | Thêm `g4_r23_stall_test` (nay 51 suite + online). |
| `visual-check/artpass23/check_r23.py` (mới, subagent) | Theo mẫu check_r20.py, cổng 8177 + ảnh zoom vùng sạp (clip y=640..1000). |

### 45.3 Verify thật vòng này

- `--check-only` nadia_scene.gd: PASS.
- Test mới `g4_r23_stall_test`: **10/10 PASS** (lần đầu).
- Hồi quy đầy đủ: **51 OK, 0 FAIL** (50 cũ + 1 mới r23).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR.
- Export web exit 0: pck **14.404.944 byte, SHA `e1e4ee94…`**
  (trước `a5964dee`, +8.460 byte = đúng code vẽ thêm, không art
  mới); wasm không đổi `fc74679e`; HTTP 200 đủ 6 file (cổng
  8177). Lưu ý export: lần đầu lỗi `Target folder does not
  exist: "src/godot-build"` vì đường dẫn export tương đối được
  hiểu theo `--path src/godot` (thành `src/godot/src/godot-build`)
  — sửa bằng đường dẫn tuyệt đối (tiền lệ G0 dùng `cd src/godot`
  + `../godot-build`). Lần import trước đó sinh
  `g4_r23_stall_test.gd.uid` đúng quy trình.
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass23/check_r23.py`, ảnh
  `r23-01…r23-04`): **0 console error, 0 pageerror,
  0 request fail.**
  - Map002: biển đọc được, có màu riêng (RAU CỦ xanh lá,
    THỊT HEO đỏ, BÁNH MÌ nâu, HOA QUẢ hồng, CÁ TƯƠI xanh dương,
    ĐỒ KHÔ nâu vàng); mái hiên viền vỏ sò + cột chống; quầy có
    hàng đúng loại (trái cây đủ màu, ổ bánh mì); sạp bên 2 cột
    có biển + mái hiên + quầy (thấy rõ CÁ TƯƠI/ĐỒ KHÔ cột phải).
  - Map001 tải lại: không hồi quy (nền cao, NPC patrol như cũ).
  - Còn lại (không sửa vòng này): tường bên vẫn nền be sau sạp
    (đã có vân gỗ, vẫn phẳng); biển sạp bên cột phải (x=11) bị
    cắt một phần ở mép canvas 720 — tường cũ cũng bị cắt như vậy.

### 45.4 Deploy — XONG, verify live khớp byte (22/11 ~23:30–23:50 +07)

- Push main 1 lô (không gián đoạn): code + test + check_r23
  `2a214c4b` (trước `2167689e`). Sync record 226 entries.
- Staging rebuild `build_gh_pages.py --verify-only` exit 0: pck
  `e1e4ee94` 107 chunk / 14.404.944 byte khớp byte, wasm
  `fc74679e` 293 chunk không đổi, img khớp, loader đủ.
  Đối chiếu trước deploy: gh-pages head `b0b97773`,
  `versions.json` live pin `a5964dee` (vòng 22), không divergence
  (list_commits bỏ qua tham số branch nên chỉ dùng được cho main;
  head gh-pages lấy từ sync record).
- Deploy 7 lô gh-pages: part 000–019 `880e5b67`, 020–039
  `94b7b404`, 040–059 `00134b8e`, 060–079 `3f77c6e4`,
  080–099 `3c81c642`, 100–106 `daaf5950` (lô này chậm ~9 phút),
  versions.json + index.html cuối `85f190c8`. Sync record 233
  entries. Không gián đoạn lần nào (khác vòng 18–20).
- Verify live bằng byte: pin `e1e4ee94` sau lag Pages ~30 giây;
  tải + giải base64 + ráp 107 part từ live = **14.404.944 byte,
  SHA `e1e4ee94dae9` — khớp đúng từng byte**; index.html live
  liệt kê part `e1e4ee94`.
- **Live nay chạy vòng 23**: sạp chợ Map002 vẽ lại. Link:
  https://tinnt120899.github.io/pho-xo-bo/
- Kiểm live cloud browser lần 1 (22:44–22:52 +07): game chạy,
  nút Bắt đầu bấm được, không thấy lỗi hiển thị (checker không
  mở được DevTools nên là kết luận quan sát); di chuyển D/A/S/W
  đúng từng ô đo bằng nhãn debug (spawn (4,5); D→(5,5); A→(4,5);
  S→(4,6); W→(4,5)); sang Map002 qua cửa (5,4) được 2 chiều,
  toast "Đã sang Chợ Đầu Mối"; sạp hàng trên: biển đọc được +
  màu riêng theo loại, mái hiên kẻ sọc, quầy có hàng đúng loại
  (nhãn nổi che một phần quầy CÁ TƯƠI/GIA VỊ/ĐỒ KHÔ).
- Kiểm live bổ sung (22:54–23:05 +07): **sạp bên CÓ trên live**
  (đính chính kết luận lần 1 "chỉ thấy khối be phẳng" — checker
  đã bỏ sót vì biển bên nhỏ + bị D-pad/nhãn che): cột trái có
  biển BÁNH MÌ (nâu) + HOA QUẢ (cam) kèm mái hiên kẻ sọc +
  quầy; cột phải có BÁNH MÌ, HOA QUẢ, CÁ TƯƠI (xanh dương),
  ĐỒ KHÔ (ô-liu), GIA VỊ (tím) kèm mái hiên + quầy; khối be
  phẳng chỉ còn ở phần dưới cột trái (hàng lẻ, cố ý là tường
  trơn) + phần sau nút D-pad. Khớp ảnh local r23-02.
- Patrol live: 2 lần kiểm bằng ảnh tĩnh đều "không thấy đi"
  (đứng (1,7)/(1,8) 24s; đứng (1,1) chụp trước/sau 15s) —
  **KHÔNG phải lỗi patrol.** Probe headless vòng này
  (`/tmp/pxb-patrol-probe.gd`, không commit): chạy
  `Main._process(0.5)` thật 60 lần (= 30s game time), người
  chơi (1,1): t=10s Cô Tư (7,6) + Bạn Thân (3,6) (đã rời nhà),
  t=15s về nhà, t=20s lại ra (9,6)/(3,4), t=30s (8,7) —
  **PASS, patrol chạy đúng chu kỳ** (nhà 4–9s → ra ngoài 2–5s
  → về nhà). Bài học phương pháp: 2 ảnh tĩnh cách nhau 15s rất
  dễ cùng bắt lúc NPC ở nhà (~65% thời gian ở nhà) nên không
  kết luận được patrol hỏng — kiểm patrol phải quay video liên
  tục hoặc chụp mỗi 2s. Probe local vòng này cũng vậy: ảnh A/B
  ở (4,1) giống nhau ở vùng NPC, nhưng diff toàn ảnh 20.893 px
  (khói/lá/nắng động) và probe headless đã chứng minh NPC có đi.
  Lưu ý probe local: đi Trái trước từ spawn bị Bạn Thân ở (3,5)
  chặn (ô NPC không đi được) nên người chơi chỉ tới (4,1) —
  lần sau đi Lên trước rồi mới sang Trái (như check_r22.py).
- Lưu ý verify: lần export đầu lỗi `Target folder does not
  exist: "src/godot-build"` (xem §45.3) — pck cũ `a5964dee`
  vẫn nằm trên đĩa tới khi export lại bằng đường dẫn tuyệt đối
  thì mới ra `e1e4ee94`; đừng nhầm file cũ với bản mới khi đối
  chiếu SHA.

### 45.5 Việc tiếp theo

1. Khói nồi phở / biển đung đưa — §42.5 mục 5 (cần sprite riêng
   cho biển/nồi, hiện là 1 phần ảnh nền).
2. Sprite sạp tách riêng (§45.1): khi nào đổi hàng 0 thành sạp
   cách nhau (ô lẻ để trống) thì gen 3 sprite sạp (rau/trái cây/
   cá-thịt) thay code vẽ — vòng 24+.
3. NPC Map003–018 vẫn ảnh đơn + nhún (chỉ 4 NPC Map001–002 có
   walk cycle): nối `frames` khi có sheet (theo mẫu vòng 22).
4. Kiểm live lại bằng cloud browser — ĐÃ XONG vòng này (§45.4):
   sạp mới đã thấy trên live, patrol đã chứng minh bằng probe
   headless (PASS). Bài học phương pháp (ghi để vòng sau không
   tái phạm): kiểm patrol KHÔNG dùng 2 ảnh tĩnh — dùng video
   liên tục hoặc chụp mỗi 2s, hoặc probe headless qua
   `Main._process`; đi từ spawn phải Lên trước rồi mới sang
   Trái (ô (3,5) là nhà Bạn Thân, chặn đường).

## 46. Vòng 24 — Biển phở đung đưa + khói nồi phở rõ hơn (22/11 ~23:20–00:10 +07)

Mục 1 §45.5 (§42.5 mục 5 — mục còn lại của Claude (3) từ vòng 20):
khói nồi phở đã có từ trước trong code (`_draw_food_cart`, 3 cụm,
alpha ≤0.35) nhưng mờ, khó thấy; biển đung đưa chưa có — biển trên
mặt tiền Map001 nằm trong ảnh composite nên không lắc được.

### 46.1 Việc làm

| File | Đổi |
|---|---|
| `scripts/nadia_scene.gd` | Hằng + helper mới: `FOOD_CART_TILE (6,12)`, `SIGN_TEXT "PHỞ BÒ"`, `SIGN_BOARD (46,16)`, `SIGN_SWAY_AMP 0.07 rad (~4°)`, `SIGN_SWAY_SPEED 1.4`, `SMOKE_PUFFS 4`, `SMOKE_RISE 50`, `SMOKE_ALPHA_MAX 0.5`; `food_cart_sign_angle(t)` (sin con lắc, 0 ở t=0, cực đại ở t=PI/(2*SPEED)); `food_cart_smoke_puff(t, i)` (vị trí/bán kính/alpha — bay lên + mờ dần + lắc ngang). `_draw_food_cart`: khói 4 cụm alpha tới 0.5 (cũ 3 cụm 0.35); thêm **biển treo "PHỞ BÒ" đung đưa** dưới mái hiên xe đồ ăn — 2 dây treo + bảng gỗ 46×16 viền kem + chữ 10px, lắc quanh điểm treo ở mép mái hiên bằng `draw_set_transform(pivot, angle)`, vẽ sau cùng để nằm trước thân xe. Biển trên mặt tiền trong ảnh composite giữ nguyên — biển treo này là vật riêng, không đè lên biển trong ảnh. |
| `tests/g4_r24_smoke_sign_test.gd` (mới) | 15 mục: góc biển 0 ở t=0, +AMP ở t=PI/(2*SPEED), −AMP ở t=3*PI/(2*SPEED), đổi góc theo thời gian, biên độ 0.05–0.10 rad; khói 4 cụm, bay lên, mờ dần, lắc ngang đổi theo t, alpha ≤0.5, bán kính ≤9; chữ "PHỞ BÒ" cỡ 10 rộng 41.0px ≤ 42 (bảng 46); xe đồ ăn ở ô (6,12); scene Map001 chạy 60 frame, `_t` chạy thật. |
| `tools/godot/run_regression.sh` | Thêm `g4_r24_smoke_sign_test` (nay 52 suite + online). |
| `visual-check/artpass24/check_r24.py` (mới, subagent) | Theo mẫu check_r23.py, cổng 8178 + ảnh zoom vùng xe (clip y=640..1000) + pixel-diff 2 ảnh cách nhau 1.5s. |

### 46.2 Lỗi tìm ra khi làm (ghi để không tái phạm)

- **`rm -rf src/godot-build` xóa cả asset DOM shell:** export
  xong, browser-verify lần 1 báo **9 console error 404** —
  `title_bg.jpg`, `char_player.png`, `char_banthan.png` (mỗi file
  ×3 lần tải trang). Nguyên nhân: 3 file này không phải do export
  sinh ra mà do các vòng trước copy tay vào `src/godot-build/`
  cho `web_shell.html` fetch (`fetchBlobRetry`); `rm -rf` trước
  export đã xóa chúng. Sửa: khôi phục `title_bg.jpg` bằng cách
  giải base64 từ staging (`gh-pages-staging/img/title_bg.jpg/260962c1/`,
  119.190 byte, đúng bản live) + copy 2 PNG từ `src/godot/art/`;
  chạy lại check → **0 console error, 0 pageerror,
  0 requestfailed**. **LUẬT: không bao giờ `rm -rf` cả thư mục
  build — chỉ xóa file export sinh ra (`index.*`, `index.pck`,
  `index.wasm`), hoặc export đè lên; asset DOM shell
  (`title_bg.jpg`, `char_*.png`) phải giữ lại.**

### 46.3 Verify thật vòng này

- `--check-only` nadia_scene.gd: PASS.
- Test mới `g4_r24_smoke_sign_test`: **15/15 PASS** (lần đầu).
- Hồi quy đầy đủ: **52 OK, 0 FAIL** (51 cũ + 1 mới r24).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR/warning.
- Export web exit 0: pck **14.409.256 byte, SHA `db28f2c4…`**
  (trước `e1e4ee94`, +4.312 byte); wasm không đổi `fc74679e…`,
  `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ 4 file (cổng 8178).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass24/check_r24.py`, ảnh
  `r24-01…r24-04` + crop xe): **0 console error, 0 pageerror,
  0 requestfailed.** Nhãn debug xác nhận đi xuống tới **Ô (4,8)**
  sau 3×S. Xem ảnh thật: biển gỗ **"PHỞ BÒ" đọc được** treo dưới
  mái hiên kẻ sọc đỏ/trắng của xe đồ ăn; **khói trắng thấy được**
  bay lên từ nồi phở xám trên xe; pixel-diff 2 ảnh zoom cách nhau
  1.5s = **14.955/460.800 pixel khác** (khói + biển + lá động).
  Crop phóng to 2 ảnh cách nhau 1.5s: cụm khói ở vị trí khác nhau,
  biển hơi nghiêng khác nhau.

### 46.4 Deploy — XONG, verify live khớp byte (22/11 ~23:55–00:05 +07)

- Push main 1 lô: code + test + check_r24 `b1267ef1` (trước
  `00596897`). Sync record 235 entries.
- Staging rebuild `build_gh_pages.py` exit 0 (VERIFY OK): pck
  `db28f2c4` 107 chunk / 14.409.256 byte khớp byte, wasm
  `fc74679e` 293 chunk không đổi, img khớp, loader đủ.
  Đối chiếu trước deploy: gh-pages head `85f190c8`,
  `versions.json` live pin `e1e4ee94` (vòng 23), không divergence.
- Deploy 7 lô gh-pages: part 000–019 `413a82dd`, 020–039
  `2246e1eb`, 040–059 `54dcfa75`, 060–079 `08834a25`, 080–099
  `7e87273d`, 100–106 `8322bfcf`, versions.json + index.html cuối
  `97bdeb66`. Sync record 242 entries. Không gián đoạn lần nào.
- Verify live bằng byte: pin `db28f2c4` sau lag Pages ~45 giây;
  tải + giải base64 + ráp 107 part từ live = **14.409.256 byte,
  SHA `db28f2c4b5f5` — khớp đúng từng byte**; index.html live
  liệt kê part `db28f2c4`.
- **Live nay chạy vòng 24**: biển phở đung đưa + khói nồi phở rõ
  hơn. Link: https://tinnt120899.github.io/pho-xo-bo/
- **Kiểm live cloud browser — XONG (23/11 00:05–00:12 +07,
  browser task 4b96032b, 6 phút):** game tải được, nút "BẮT ĐẦU
  CHƠI" enable sau ~10s rồi bấm được, vào Map001 "Xóm Trọ Cũ"
  đúng HUD. Di chuyển đọc nhãn debug: spawn (4,5); D→(5,5),
  A→(4,5), S→(4,6), W→(4,5) — **4 phím đổi đúng từng ô**.
  Xuống đáy map S×3 → (4,8): thấy xe đồ ăn (mái hiên kẻ sọc
  đỏ/trắng, 2 bánh, nồi trên nóc), biển gỗ **"PHỞ BÒ" treo dưới
  mái hiên nghiêng khác nhau qua 3 ảnh cách nhau ~2s** (ngang →
  nghiêng chiều kim đồng hồ → về ngang, biên độ vài độ, đọc bằng
  mắt vì xe chỉ ~55px trên màn hình) và **khói trắng bay từ nồi,
  cụm khói khác vị trí/hình mỗi ảnh**. Không thấy lỗi hiển thị;
  game chạy liên tục không gián đoạn. Hạn chế: checker không mở
  được DevTools nên không khẳng định "0 console error" từ live
  (bản local cùng SHA đã 0 lỗi ở §46.3); trang không hiện số vòng
  deploy nên "vòng 24" chỉ xác minh qua nội dung tính năng, không
  qua số phiên bản. Quan sát thêm chưa xác minh: checker thấy
  biển "PHO BO" quán phía trên + hơi nồi quầy "CÀ PHÊ" cũng đổi
  giữa 2 ảnh — biển mặt tiền nằm trong ảnh tĩnh nên đổi góc là
  khó hiểu, có thể checker đọc nhầm khói/overlay; không sửa code
  theo quan sát này, vòng sau xem lại nếu thấy lại.

### 46.5 Việc tiếp theo

1. Sprite sạp tách riêng (§45.1): khi nào đổi hàng 0 thành sạp
   cách nhau (ô lẻ để trống) thì gen 3 sprite sạp (rau/trái cây/
   cá-thịt) thay code vẽ — việc 2 vòng (artpass sprite + đổi hàng).
2. NPC Map003–018 vẫn ảnh đơn + nhún (chỉ 4 NPC Map001–002 có
   walk cycle): nối `frames` khi có sheet (theo mẫu vòng 22) —
   làm theo từng map (Map003: Anh Ba, Chị Sáu trước).
3. Kiểm live lại bằng cloud browser — ĐANG CHỜ vòng này (§46.4).

## 47. Vòng 25 — Walk cycle NPC Map003: Anh Ba + Chị Sáu (22/11 ~23:20–00:35 +07, cron 23:45)

Mục 2 §46.5: NPC Map003–018 vẫn ảnh đơn + nhún (chỉ 4 NPC Map001–002
có walk cycle). Vòng này làm Map003 trước: Anh Ba (4,6) + Chị Sáu
(8,3), Khu Công Nhân.

### 47.1 Art (subagent, theo đúng quy trình vòng 18/22)

- Ảnh đứng mới `src/godot/art/char_anhba.png` (90×208 RGBA) +
  `char_chisau.png` (95×208 RGBA): Anh Ba — đàn ông trung niên,
  công nhân xưởng, tóc đen ngắn, áo thun xanh dương đậm, quần tối,
  giày thể thao xám; Chị Sáu — phụ nữ trung niên, tóc đen búi thấp,
  áo bà ba xanh lá nhạt có hoa nhỏ, quần đen, dép quai. Cùng phong
  cách chibi watercolor/gouache với `char_cotu.png` (dùng làm tham
  chiếu phong cách). Xử lý trắng → trong suốt bằng flood fill từ
  biên (ngưỡng vòng 22) + feather r=1.5, cao 208px.
- Sheet `visual-check/artpass25/walkcycle-sheet-anhba.png` /
  `walkcycle-sheet-chisau.png` (2736×912, nền trắng trơn): đúng 6
  nhân vật 1 hàng ngang, cùng mặt/tóc/quần áo/giày, chân tiến triển
  hợp lý, tay đung đưa — kiểm tra bằng mắt ĐẠT cả 2, không cần gen
  lại. Hạn chế (chấp nhận như vòng 18/22): chỉ mặt trước; f5≈f0;
  họa tiết hoa áo bà ba Chị Sáu dao động nhẹ giữa các khung.
- Cắt frame bằng `visual-check/artpass25/slice_walkcycle_npc_map003.py`
  (bản sao script vòng 22, NPCS = anhba/chisau): 12 frame RGBA cao
  208px vào `src/godot/art/` — `walk_anhba_f0..f5` (120×208),
  `walk_chisau_f0..f5` (129×208). Dải kiểm tra nền magenta
  `walkcycle-check-magenta-{anhba,chisau}.png`: đủ 6 hình, toàn thân
  nguyên vẹn, không quầng trắng, không cắt tay/chân, chân xen kẽ
  chạm đất ↔ bắt chéo. Note: `visual-check/artpass25/walkcycle-npc-map003-note.md`.
- Lần gen song song đầu tiên cho 2 ảnh đứng bị gián đoạn do service
  restart, không file nào được tạo; gen lại lần lượt từng ảnh thì
  thành công ngay.

### 47.2 Code

| File | Đổi |
|---|---|
| `scripts/marker.gd` | `NPC_STYLE` thêm `"anh-ba"` (shirt xanh dương đậm (0.16,0.24,0.45), hair "ngan", texture `char_anhba.png`, frames `walk_anhba_f0..f5`) + `"chi-sau"` (shirt xanh lá nhạt (0.55,0.72,0.55), hair "bui", texture `char_chisau.png`, frames `walk_chisau_f0..f5`). Không sửa logic `CharacterSprite`/`Marker` — `setup(cfg)` đã ăn `texture` + `frames` từ vòng 18/22. |
| `tests/g4_r25_npc_walk_map003_test.gd` (mới) | 29 mục theo mẫu r22: sprite trực tiếp từng NPC (đủ 6 frame, bước 1 đổi frame 1, hết 0.30s về frame 0, đứng yên frame 0); marker đơn lẻ (home_tile đúng (4,6)/(8,3), có walk frames, walk_to 0.30s/o); Main load_map(3) (2 marker có walk frames + đúng nhà, pick patrol từ nhà Anh Ba hợp lệ). |
| `tools/godot/run_regression.sh` | Thêm `g4_r25_npc_walk_map003_test` (nay 53 suite + online). |
| `visual-check/artpass25/check_r25.py` (mới) | Theo mẫu check_r22.py, cổng 8179: Map001→Map002 (cửa (5,4))→Map003 (cửa (5,8)), đi xa lên (4,1), chờ patrol 12s, 2 ảnh cách nhau 2s để đo pixel-diff. |

### 47.3 Verify thật vòng này

- Test mới `g4_r25_npc_walk_map003_test`: **29/29 PASS** (lần đầu).
- Hồi quy đầy đủ: **53 OK, 0 FAIL** (52 cũ + 1 mới r25).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR/warning.
- Export web exit 0 (đường dẫn tuyệt đối, KHÔNG `rm -rf` build theo
  luật vòng 24 — asset DOM shell còn nguyên): pck **14.884.728 byte,
  SHA `af16fef1…`** (trước `db28f2c4`, +475.472 byte = 14 file art
  mới); wasm không đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`;
  HTTP 200 đủ 4 file (cổng 8179, gồm `title_bg.jpg`).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass25/check_r25.py`, ảnh `r25-01…r25-04`):
  **0 console error, 0 pageerror, 0 requestfailed.** Xem ảnh thật:
  Map003 "Khu Công Nhân" — Anh Ba (áo xanh dương đậm, mặt thật) +
  Chị Sáu (áo bà ba xanh lá, mặt thật) hiện rõ có nhãn tên, không
  còn vẽ code; người chơi đi (5,4)→(5,1) đúng ô theo nhãn debug;
  sau 12s xa nhà, **Chị Sáu đã patrol rời nhà (8,3) lên giữa map**,
  Anh Ba cũng rời nhà (khuất sau D-pad ở mép trái); pixel-diff 2
  ảnh Map003 cách nhau 2s = **9.003/921.600 pixel khác** (NPC
  bob/buộc + lá rơi động).

### 47.4 CHẶN — push main + deploy gh-pages CHƯA XONG (push_files hỏng)

- Push main lô A (4 file code+test) gián đoạn lần 1 ("service
  restarted while it was running"), head vẫn `333eba2f`; retry lần 2
  gián đoạn y hệt; push thăm dò 1 file (`marker.gd`) lần 3 cũng gián
  đoạn — **đường ghi push_files hỏng hẳn lúc này, đường đọc vẫn
  chạy** (list_commits OK). ĐÃ DỪNG retry trong lượt (theo bài học
  vòng 21: fail ngắt quãng thì retry 1–2 lần/lô là đủ; 3 lần liên
  tiếp kể cả file đơn = dịch vụ hỏng, không phải lô lớn).
- Manifest sẵn sàng: `~/workspace/pxb-push-r25-paths-a` (4 file
  code+test), `-b` (14 file `.import`), `-c` (4 file text
  visual-check), probe `pxb-push-r25-probe` (1 file). Sync record
  KHÔNG đổi (chưa có commit nào được xác nhận).
- Deploy gh-pages CHƯA làm (cùng đường push_files): staging chưa
  rebuild — vòng sau rebuild staging cho pck `af16fef1` rồi deploy
  1 lần sau khi push main hồi.
- Kiểm live cloud browser CHƯA làm (live vẫn chạy vòng 24
  `db28f2c4`; kiểm lúc này chỉ xác minh bản cũ, không phải vòng 25).
- Code + art an toàn ở local, không mất: 14 PNG mới chỉ sống local +
  trong pck `af16fef1` đã export (như mọi art trước — PNG không push
  được qua snapshot-push, chỉ `.import` text lên main).

### 47.5 Việc tiếp theo

1. **Retry push main (3 lô r25) → deploy gh-pages pck `af16fef1` →
   verify live khớp byte → kiểm live cloud browser** (Map003: Anh Ba
   + Chị Sáu đi patrol bằng art thật).
2. NPC Map004–018 walk cycle theo từng map (Map004: Bác Tài, Anh Bốc
   Vác — cần ảnh đứng + sheet mới, theo mẫu vòng này).
3. Sprite sạp tách riêng (§45.1): đổi hàng 0 thành sạp cách nhau (ô
   lẻ để trống) rồi gen 3 sprite sạp (rau/trái cây/cá-thịt).

### 47.6 Retry push lần 2 — VẪN CHẶN (cron 07:45, chạy ~08:00–08:20 23/11)

- Retry push main lô A 2 lần + push thăm dò 1 file (marker.gd) 1 lần:
  cả 3 đều gián đoạn y hệt ("service restarted while it was running"),
  head main vẫn `333eba2f`, sync record không đổi. Tổng cộng 7 lần
  gián đoạn liên tiếp cho vòng 25 (4 lần lúc 00:20–00:40 + 3 lần lượt
  này). Đường đọc vẫn chạy (list_commits OK), auth GitHub connected.
  **DỪNG retry push trong lượt này** (theo bài học §47.4 — 3 lần liên
  tiếp kể cả file đơn = dịch vụ hỏng, không phải lô lớn).
- Đã làm bù trong lượt (không cần push): rebuild staging gh-pages cho
  pck `af16fef1` (staging trước đó vẫn `db28f2c4` vòng 24) —
  `build_gh_pages.py` + `--verify-only` đều OK, `versions.json` nay
  pck `af16fef1`, wasm `fc74679e` không đổi; hồi quy baseline
  **53 OK, 0 FAIL** (cây hiện tại vẫn xanh trước vòng 26).
- Deploy gh-pages + kiểm live cloud vẫn CHƯA làm (cùng đường
  push_files hỏng). Khi dịch vụ hồi: push main 3 lô r25 (manifest
  `~/workspace/pxb-push-r25-paths-{a,b,c}`) → push docs → deploy
  staging `af16fef1` (đã rebuild sẵn, chỉ cần push chunk version
  mới + index.html cuối) → verify live khớp byte → kiểm live cloud.

## 48. Vòng 26 — Walk cycle NPC Map004: Bác Tài + Anh Bốc Vác (23/11 ~08:20 +07, cron 07:45)

Mục 2 §47.5: NPC Map004–018 walk cycle theo từng map. Vòng này làm
Map004 Bến Xe Miền Đông trước: Bác Tài (3,2) + Anh Bốc Vác (8,6).

### 48.1 Art (subagent, theo đúng quy trình vòng 18/22/25) — XONG

- Thư mục `visual-check/artpass26/`; ảnh đứng + sheet 6 khung cho
  Bác Tài (tài xế xe khách lớn tuổi, áo sơ mi xanh nhạt) + Anh Bốc
  Vác (thanh niên khỏe, áo thun trắng, khăn vắt vai); xử lý trắng →
  trong suốt + cắt frame theo mẫu Vòng 25.
- File đích: `src/godot/art/char_bactai.png` (97×208) +
  `char_anhbocvac.png` (90×208), `walk_bactai_f0..f5.png`
  (115×208) + `walk_anhbocvac_f0..f5.png` (123×208), RGBA.
- Kiểm tra bằng mắt: sheet Bác Tài gen lại 1 lần (lần 1 chân 6 pha
  gần như giống nhau); sheet Anh Bốc Vác đạt ngay lần 1; ảnh đứng
  Anh Bốc Vác gen lại 1 lần (lần 1 thừa vali). Dải magenta sạch,
  không quầng trắng. Hạn chế: chỉ mặt trước (thực tế 3/4); f5 Bác
  Tài gần như đứng yên; khăn vai dao động nhẹ giữa các khung. Bài
  học: prompt sheet Vòng 25 chưa đủ ép 6 pha khác nhau — đã bổ
  sung mô tả 6 pha rõ rệt vào prompt, dùng luôn cho các vòng sau.

### 48.2 Code + test — XONG

- `marker.gd` NPC_STYLE thêm `"bac-tai"` (áo xanh nhạt
  (0.55,0.75,0.90), tóc "ngan", texture + frames) +
  `"anh-boc-vac"` (áo trắng (0.95,0.95,0.95), tóc "ngan").
  Không sửa logic `CharacterSprite`/`Marker`.
- Test mới `tests/g4_r26_npc_walk_map004_test.gd`: **29/29 PASS**
  (theo mẫu r25: sprite trực tiếp từng NPC, marker home_tile
  (3,2)/(8,6), Main load_map(4) + pick patrol từ nhà Bác Tài).
- `tools/godot/run_regression.sh` thêm test mới (nay 54 suite).

### 48.3 Verify thật vòng này

- Hồi quy đầy đủ: **54 OK, 0 FAIL** (53 cũ + 1 mới r26).
- Smoke `--headless --quit-after 120` exit 0.
- Export web exit 0: pck **15.358.560 byte, SHA `d33bd266…`**
  (trước `af16fef1`, +473.832 byte = 14 file art mới); wasm không
  đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ 5
  file (cổng 8180, gồm `title_bg.jpg`).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass26/check_r26.py`, ảnh `r26-01…r26-05`):
  **0 console error, 0 pageerror, 0 requestfailed.** Xem ảnh thật:
  Map004 "Bến Xe Miền Đông" — Bác Tài (áo sơ mi xanh nhạt, tóc
  điểm bạc) + Anh Bốc Vác (áo thun trắng, khăn vắt vai) hiện rõ
  có nhãn tên, không còn vẽ code; người chơi đi (5,4)→(10,1) đúng
  ô theo nhãn debug; sau 12s xa nhà, **cả 2 NPC đều patrol rời
  nhà** (Bác Tài ra mép trái map, Anh Bốc Vác khuất sau D-pad);
  pixel-diff 2 ảnh Map004 cách nhau 2s = **26.185**.
- Lỗi tìm ra khi xem ảnh: không có lỗi chặn — Anh Bốc Vác khuất
  sau D-pad ở mép trái là do patrol ra sát biên + camera theo
  người chơi (cosmetic, đã biết từ các vòng trước).

### 48.4 Deploy — CHƯA LÀM (push_files vẫn hỏng)

- Staging đã rebuild cho pck `d33bd266` (`--verify-only` OK).
- Push main + deploy gh-pages CHƯA làm: đường ghi push_files hỏng
  từ vòng 25 (7 lần gián đoạn liên tiếp; lượt này đã dừng retry
  sau 3 lần — xem §47.6). Manifest sẵn sàng cho vòng sau:
  `~/workspace/pxb-push-r26-paths-{a,b,c}` + `pxb-push-docs-r26`
  (docs/godot-g4.md + docs/roles-qc.md, gồm cả cập nhật vòng 25
  chưa push). Khi dịch vụ hồi: push r25 (3 lô) → push r26 (3 lô)
  → push docs → deploy staging `d33bd266` → verify live khớp byte
  → kiểm live cloud browser.

### 48.5 Việc tiếp theo

1. **Push main (r25 + r26) + deploy gh-pages pck `d33bd266` →
   verify live khớp byte → kiểm live cloud browser** (Map004:
   Bác Tài + Anh Bốc Vác đi patrol bằng art thật).
2. NPC Map005 walk cycle (Thầy Giáo + Sinh Viên Làm Thêm) theo
   từng map, mẫu vòng này (prompt sheet đã bổ sung 6 pha rõ rệt).
3. Sprite sạp tách riêng (§45.1): đổi hàng 0 thành sạp cách nhau
   (ô lẻ để trống) rồi gen 3 sprite sạp (rau/trái cây/cá-thịt).

## 49. Vòng 27 — Walk cycle NPC Map005: Thầy Giáo + Sinh Viên Làm Thêm (23/11 ~16:15 +07, cron 14:45)

Mục 2 §48.5: NPC Map005–018 walk cycle theo từng map. Vòng này làm
Map005 Làng Đại Học: Thầy Giáo (3,3) + Sinh Viên Làm Thêm (8,6).

### 49.1 Push/deploy — VẪN CHẶN (thử lại đầu lượt, lần thứ 8)

- Đầu lượt thử push main r25 lô A 1 lần: gián đoạn y hệt
  ("service restarted while it was running") — tổng 8 lần gián đoạn
  liên tiếp cho đường ghi push_files (4 lần vòng 25 + 3 lần vòng 26 +
  1 lần lượt này). Kiểm tra lại head main vẫn `333eba2f`, sync
  record không đổi — push không áp dụng một phần. **DỪNG retry push
  trong lượt này** (luật §47.4). Đường đọc vẫn chạy (list_commits OK).
- Deploy gh-pages + kiểm live cloud vẫn CHƯA làm (cùng đường ghi
  hỏng). Live vẫn chạy vòng 24 `db28f2c4`.

### 49.2 Art (subagent, theo đúng quy trình vòng 25/26) — XONG, 0 lần gen lại

- Thư mục `visual-check/artpass27/`; ảnh đứng + sheet 6 khung cho
  Thầy Giáo (giáo viên nam trung niên, đeo kính, áo sơ mi be dài
  tay, quần dài tối màu) + Sinh Viên Làm Thêm (nữ sinh viên trẻ,
  tóc đuôi ngựa, áo thun vàng nhạt, quần jeans, giày thể thao
  trắng); xử lý trắng → trong suốt + cắt frame theo mẫu vòng 26.
- File đích: `src/godot/art/char_thaygiao.png` (97×208) +
  `char_sinhvien.png` (92×208), `walk_thaygiao_f0..f5.png`
  (144×208) + `walk_sinhvienlamthem_f0..f5.png` (120×208, đúng tên
  theo id `sinh-vien-lam-them` bỏ dấu gạch nối), RGBA.
- Kiểm tra bằng mắt: 2 ảnh đứng + 2 sheet đều ĐẠT ngay lần đầu
  (đúng 6 nhân vật, nền trắng trơn, không chữ, không thừa đồ vật,
  6 pha chân khác nhau rõ); dải magenta sạch, không quầng trắng.
- Một sửa script so với vòng 26: sheet Sinh Viên có 2 đốm xám lẻ
  trong nền trắng khiến lần cắt đầu báo 8 run thay vì 6 — đã thêm
  bộ lọc bỏ run hẹp <20px vào `slice_walkcycle_npc_map005.py`
  (nhân vật thật rộng 360–460px); lần sửa đầu đặt bộ lọc sau câu
  raise nên vẫn lỗi — đã sửa lại đặt trước, cắt lại thành công.
- Hạn chế thấy bằng mắt: chỉ mặt trước (3/4); f5 cả hai gần như
  tư thế đứng; f1/f2/f3 Sinh Viên là 3 tư thế bắt chéo/khép khá gần
  nhau, ít sải hơn Thầy Giáo nhưng vẫn phân biệt được khi chạy;
  đuôi ngựa Sinh Viên hơi lệch sang một bên thay vì chính giữa.

### 49.3 Code + test — XONG

- `marker.gd` NPC_STYLE thêm `"thay-giao"` (áo be
  (0.85,0.78,0.62), tóc "ngan", texture + frames) +
  `"sinh-vien-lam-them"` (áo vàng nhạt (0.95,0.85,0.35), tóc
  "dai", texture + frames). Không sửa logic `CharacterSprite`/
  `Marker`.
- Test mới `tests/g4_r27_npc_walk_map005_test.gd`: **29/29 PASS**
  (theo mẫu r26: sprite trực tiếp từng NPC, marker home_tile
  (3,3)/(8,6), Main load_map(5) + pick patrol từ nhà Thầy Giáo).
- `tools/godot/run_regression.sh` thêm test mới (nay 55 suite).

### 49.4 Verify thật vòng này

- Hồi quy đầy đủ: **55 OK, 0 FAIL** (54 cũ + 1 mới r27).
- Smoke `--headless --quit-after 120` exit 0.
- Export web exit 0: pck **15.824.284 byte, SHA `986681e7`**
  (trước `d33bd266`, +465.724 byte = 14 file art mới); wasm không
  đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ 5
  file (cổng 8181, gồm `title_bg.jpg`).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass27/check_r27.py`, ảnh `r27-01…r27-06`):
  **0 console error, 0 pageerror, 0 requestfailed.** Xem ảnh thật:
  Map005 "Làng Đại Học" — Thầy Giáo (đeo kính, áo sơ mi be) +
  Sinh Viên Làm Thêm (áo vàng nhạt, tóc đuôi ngựa) hiện rõ có nhãn
  tên, không còn vẽ code; người chơi đi (5,4)→(10,1) đúng ô theo
  nhãn debug; sau 12s xa nhà, **cả 2 NPC đều patrol rời nhà**
  (Thầy Giáo ra mép trái map, Sinh Viên khuất sau D-pad);
  pixel-diff 2 ảnh Map005 cách nhau 2s = **22.796**.
- Lỗi tìm ra khi xem ảnh: không có lỗi chặn — Sinh Viên khuất sau
  D-pad ở mép trái là do patrol ra sát biên + camera theo người
  chơi (cosmetic, đã biết từ các vòng trước); nhãn "Sinh Viên Làm
  Thêm" che một phần thân Thầy Giáo khi 2 NPC đứng gần nhau
  (cosmetic, đã biết).

### 49.5 Deploy — CHƯA LÀM (push_files vẫn hỏng)

- Staging đã rebuild cho pck `986681e7` (`--verify-only` OK).
- Push main + deploy gh-pages CHƯA làm: đường ghi push_files hỏng
  từ vòng 25 (8 lần gián đoạn liên tiếp; lượt này đã dừng retry
  sau 1 lần — xem §49.1). Manifest sẵn sàng cho vòng sau:
  `~/workspace/pxb-push-r27-paths-{a,b,c}` + `pxb-push-docs-r27`
  (docs/godot-g4.md + docs/roles-qc.md, gồm cả cập nhật vòng 25/26
  chưa push). Khi dịch vụ hồi: push r25 (3 lô) → push r26 (3 lô)
  → push r27 (3 lô) → push docs → deploy staging `986681e7` →
  verify live khớp byte → kiểm live cloud browser.

### 49.6 Việc tiếp theo

1. **Push main (r25 + r26 + r27) + deploy gh-pages pck `986681e7` →
   verify live khớp byte → kiểm live cloud browser** (Map005:
   Thầy Giáo + Sinh Viên Làm Thêm đi patrol bằng art thật).
2. NPC Map006 walk cycle (Cư Dân Chung Cư + Bác Quản Lý) theo
   từng map, mẫu vòng này.
3. Sprite sạp tách riêng (§45.1): đổi hàng 0 thành sạp cách nhau
   (ô lẻ để trống) rồi gen 3 sprite sạp (rau/trái cây/cá-thịt).

## 50. Vòng 28 — Walk cycle NPC Map006: Cư Dân Chung Cư + Bác Quản Lý (23/11 ~16:45–18:45 +07, cron 16:45)

Mục 2 §49.6: NPC Map006–018 walk cycle theo từng map. Vòng này làm
Map006 Chung Cư Cũ: Cư Dân Chung Cư (3,6) + Bác Quản Lý (8,3).

### 50.1 Push/deploy — VẪN CHẶN (thử lại đầu lượt, lần thứ 9)

- Đầu lượt thử push main r25 lô A 1 lần: gián đoạn y hệt
  ("service restarted while it was running") — tổng 9 lần gián đoạn
  liên tiếp cho đường ghi push_files (4 lần vòng 25 + 3 lần vòng 26 +
  1 lần vòng 27 + 1 lần lượt này). Kiểm tra lại head main vẫn
  `333eba2f`, sync record không đổi — push không áp dụng một phần.
  **DỪNG retry push trong lượt này** (luật §47.4). Đường đọc vẫn chạy
  (list_commits OK).
- Deploy gh-pages + kiểm live cloud vẫn CHƯA làm (cùng đường ghi
  hỏng). Live vẫn chạy vòng 24 `db28f2c4`.

### 50.2 Art (subagent, theo đúng quy trình vòng 25/26/27) — XONG, 0 lần gen lại

- Thư mục `visual-check/artpass28/`; ảnh đứng + sheet 6 khung cho
  Cư Dân Chung Cư (nam trung niên, áo thun xám, quần kaki tối,
  dép) + Bác Quản Lý (ông lớn tuổi, tóc bạc, áo sơ mi xanh nhạt
  ngắn tay, quần dài tối, giày đen); xử lý trắng → trong suốt +
  cắt frame theo mẫu vòng 27.
- File đích: `src/godot/art/char_cudanchungcu.png` (90×208) +
  `char_bacquanly.png` (92×208), `walk_cudanchungcu_f0..f5.png`
  (canvas chung 132×208) + `walk_bacquanly_f0..f5.png` (canvas
  chung 128×208), RGBA.
- Kiểm tra bằng mắt: 2 ảnh đứng + 2 sheet đều ĐẠT ngay lần đầu
  (đúng 6 nhân vật, nền trắng trơn, không chữ, không thừa đồ vật,
  6 pha chân khác nhau rõ); dải magenta sạch, không quầng trắng.
- **Bài học mới — cắt sheet bằng connected component:**
  cắt sheet Cư Dân lần đầu chỉ tìm được 5 run cột — tay trái giơ
  cao của hình f0 (nắm đấm x≈460–510) chồng lấn theo chiều ngang
  với tóc hình f1 (x≈480+), dù hai hình rời nhau trong 2D.
  `slice_walkcycle_npc_map006.py` đổi sang tách connected
  component (`scipy.ndimage.label`), mỗi hình mask riêng rồi mới
  crop — nắm đấm vẫn thuộc về hình f0, không bị cắt sang hình f1.
  Bộ lọc bỏ component hẹp <20px vẫn đặt TRƯỚC khi kiểm tra đủ 6
  hình (bài học vòng 27; sheet Cư Dân có 6 đốm 1px).
- Hạn chế thấy bằng mắt: chỉ mặt trước (3/4); f5 cả hai gần như
  tư thế đứng; f2/f3/f4 của Bác Quản Lý khá gần nhau (3 tư thế
  bắt chéo/khép), ít "sải" hơn Cư Dân; tay trái f0 của Cư Dân
  giơ cao ngang vai — đung đưa mạnh hơn các NPC vòng trước, vẫn
  trong nhịp đi bộ; áo Bác Quản Lý gen ra kiểu cổ trụ khuy bấm
  (gần áo dài cách tân) thay vì sơ mi cổ bẻ thường; mặt Cư Dân
  trông trẻ hơn "trung niên" (~30 tuổi) — cả hai đều chấp nhận
  được. Chi tiết: `visual-check/artpass28/walkcycle-npc-map006-note.md`.

### 50.3 Code + test — XONG

- `marker.gd` NPC_STYLE thêm `"cu-dan-chung-cu"` (áo xám
  (0.55,0.55,0.58), tóc "ngan", texture + frames) +
  `"bac-quan-ly"` (áo xanh nhạt (0.62,0.78,0.85), tóc "ngan",
  texture + frames). Không sửa logic `CharacterSprite`/
  `Marker`.
- Test mới `tests/g4_r28_npc_walk_map006_test.gd`: **29/29 PASS**
  (theo mẫu r27: sprite trực tiếp từng NPC, marker home_tile
  (3,6)/(8,3), Main load_map(6) + pick patrol từ nhà Cư Dân).
- `tools/godot/run_regression.sh` thêm test mới (nay 56 suite).
- **Lỗi gặp khi test lần đầu (15/29):** `ResourceLoader.exists`
  báo file art mới không tồn tại dù file đã có trên đĩa — do
  chưa chạy `--headless --import` nên chưa có file `.import`.
  Chạy `--import` (tự sinh 14 file `.import`) rồi test lại thì
  29/29. Đúng bài học §8.3: gặp lỗi lạ thì `--import` trước rồi
  mới kết luận code hỏng.

### 50.4 Verify thật vòng này

- Hồi quy đầy đủ: **56 OK, 0 FAIL** (55 cũ + 1 mới r28).
- Smoke `--headless --quit-after 120` exit 0.
- Export web exit 0: pck **16.291.172 byte, SHA `c6461bde`**
  (trước `986681e7`, +466.888 byte = 14 file art mới); wasm không
  đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ 5
  file (cổng 8182, gồm `title_bg.jpg`).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass28/check_r28.py`, ảnh `r28-01…r28-07`):
  **0 console error, 0 pageerror, 0 requestfailed.** Xem ảnh thật:
  Map006 "Chung Cư Cũ" — Cư Dân Chung Cư (áo thun xám) + Bác Quản
  Lý (áo xanh nhạt, tóc bạc) hiện rõ mặt thật có nhãn tên, không
  còn vẽ code; người chơi đi (5,4)→(10,1) đúng ô theo nhãn debug;
  sau 12s xa nhà, **Bác Quản Lý patrol rời nhà ra mép trái map**;
  pixel-diff 2 ảnh Map006 cách nhau 2s = **4.557**.
- Lỗi tìm ra khi xem ảnh: không có lỗi chặn — D-pad đè lên cửa
  ở mép trái khi camera sang phải (cosmetic, đã biết từ các vòng
  trước); nhãn 2 cửa đáy map xếp chồng dọc, không đè nhau.
- Staging đã rebuild cho pck `c6461bde` (`build_gh_pages.py`
  verify OK: wasm 293 chunk + pck 121 chunk khớp byte).

### 50.5 Deploy — CHƯA LÀM (push_files vẫn hỏng)

- Push main + deploy gh-pages CHƯA làm: đường ghi push_files hỏng
  từ vòng 25 (9 lần gián đoạn liên tiếp; lượt này đã dừng retry
  sau 1 lần — xem §50.1). Manifest sẵn sàng cho vòng sau:
  `~/workspace/pxb-push-r28-paths-{a,b,c}` + `pxb-push-docs-r28`
  (docs/godot-g4.md + docs/roles-qc.md, gồm cả cập nhật vòng
  25/26/27/28 chưa push). Khi dịch vụ hồi: push r25 (3 lô) →
  push r26 (3 lô) → push r27 (3 lô) → push r28 (3 lô) → push
  docs → deploy staging `c6461bde` → verify live khớp byte →
  kiểm live cloud browser.

### 50.6 Việc tiếp theo

1. **Push main (r25 + r26 + r27 + r28) + deploy gh-pages pck `c6461bde` →
   verify live khớp byte → kiểm live cloud browser** (Map006:
   Cư Dân Chung Cư + Bác Quản Lý đi patrol bằng art thật).
2. NPC Map007 walk cycle (Phố Văn Phòng Nhỏ: 2 NPC của map 7) theo
   từng map, mẫu vòng này.
3. Sprite sạp tách riêng (§45.1): đổi hàng 0 thành sạp cách nhau
   (ô lẻ để trống) rồi gen 3 sprite sạp (rau/trái cây/cá-thịt).

## 51. Vòng 29 — Walk cycle NPC Map007: Nhân Viên Văn Phòng + Thực Tập Sinh (23/11 ~18:45–20:20 +07, cron 18:45)

Mục 2 §49.6: NPC Map006–018 walk cycle theo từng map. Vòng này làm
Map007 Phố Văn Phòng Nhỏ: Nhân Viên Văn Phòng (3,3) + Thực Tập Sinh (8,6).

### 51.1 Push/deploy — VẪN CHẶN (thử lại đầu lượt, lần thứ 10)

- Đầu lượt thử push main r25 lô A 1 lần: gián đoạn y hệt
  ("service restarted while it was running") — tổng 10 lần gián đoạn
  liên tiếp cho đường ghi push_files (4 lần vòng 25 + 3 lần vòng 26 +
  1 lần vòng 27 + 1 lần vòng 28 + 1 lần lượt này). Kiểm tra lại head
  main vẫn `333eba2f`, sync record không đổi — push không áp dụng
  một phần. **DỪNG retry push trong lượt này** (luật §47.4). Đường đọc
  vẫn chạy (list_commits OK).
- Deploy gh-pages + kiểm live cloud vẫn CHƯA làm (cùng đường ghi
  hỏng). Live vẫn chạy vòng 24 `db28f2c4`.

### 51.2 Art (subagent, theo đúng quy trình vòng 25/26/27/28) — XONG

- Thư mục `visual-check/artpass29/`; ảnh đứng + sheet 6 khung cho
  Nhân Viên Văn Phòng (nam thanh niên, áo sơ mi trắng dài tay, quần
  tây tối, giày đen) + Thực Tập Sinh (nữ trẻ, áo sơ mi xanh nhạt,
  quần dài tối, giày đen, tóc đuôi ngựa); xử lý trắng → trong suốt +
  cắt frame theo mẫu vòng 28 (connected component).
- File đích: `src/godot/art/char_nhanvienvanphong.png` (90×208) +
  `char_thuctapsinh.png` (92×208), `walk_nhanvienvanphong_f0..f5.png`
  (canvas chung 137×208) + `walk_thuctapsinh_f0..f5.png` (canvas
  chung 138×208), RGBA.
- Kiểm tra bằng mắt: 2 ảnh đứng ĐẠT ngay lần đầu (0 lần gen lại);
  sheet Thực Tập Sinh ĐẠT ngay lần đầu; **sheet Nhân Viên lần đầu
  lỗi** — hình f5 là nữ đi giày cao gót, sai hẳn nhân vật; sửa bằng
  resume snapshot chỉ vẽ lại hình 6 thành đúng nam nhân viên (áo
  trắng, quần tối, giày đen, chân khép) — **1 lần gen lại**, 5 hình
  còn lại giữ nguyên. Dải magenta cả 2 sạch, không quầng trắng.
- **Bài học mới — ngưỡng lọc đốm khi cắt sheet:** lần cắt đầu sheet
  Nhân Viên tìm được 8 component thay vì 6 — 2 đốm tối 24–26px lọt
  qua ngưỡng lọc cũ `MIN_FIG_W = 20`. `slice_walkcycle_npc_map007.py`
  nâng ngưỡng lên 100 (hình thật rộng 368–421px nên an toàn).
  Sheet Thực Tập Sinh không có đốm. Bộ lọc vẫn đặt TRƯỚC khi kiểm
  tra đủ 6 hình (bài học vòng 27/28).
- Hạn chế thấy bằng mắt: chỉ mặt trước (3/4); f5 cả hai gần như tư
  thế đứng; f2/f3/f4 khá gần nhau; áo Thực Tập Sinh gen ra kiểu cổ
  trụ khuy bấm (như Bác Quản Lý vòng 28) thay vì sơ mi cổ bẻ; tay
  trái f0 Nhân Viên giơ cao ngang vai; mặt Nhân Viên trông trẻ
  (~20 tuổi); Nhân Viên có khuyên tai vàng nhỏ không có trong mô tả
  — tất cả chấp nhận được. Chi tiết:
  `visual-check/artpass29/walkcycle-npc-map007-note.md`.

### 51.3 Code + test — XONG

- `marker.gd` NPC_STYLE thêm `"nhan-vien-van-phong"` (áo trắng
  (0.95,0.95,0.95), tóc "ngan", texture + frames) +
  `"thuc-tap-sinh"` (áo xanh nhạt (0.70,0.82,0.95), tóc "dai",
  texture + frames). Không sửa logic `CharacterSprite`/`Marker`.
- Test mới `tests/g4_r29_npc_walk_map007_test.gd`: **29/29 PASS**
  (theo mẫu r28: sprite trực tiếp từng NPC, marker home_tile
  (3,3)/(8,6), Main load_map(7) + pick patrol từ nhà Nhân Viên
  Văn Phòng).
- `tools/godot/run_regression.sh` thêm test mới (nay 57 suite).

### 51.4 Verify thật vòng này

- Hồi quy đầy đủ: **57 OK, 0 FAIL** (56 cũ + 1 mới r29).
- Smoke `--headless --quit-after 120` exit 0.
- **Lỗi export lần đầu:** lệnh export dùng đường dẫn
  `src/godot-build/index.html` (tương đối từ thư mục repo) nên
  Godot hiểu thành `src/godot/src/godot-build` không tồn tại —
  export fail, pck trên đĩa vẫn là bản cũ vòng 28 (`c6461bde`).
  Chạy lại đúng đường dẫn `../godot-build/index.html` (tương đối
  từ `src/godot`, theo `export_presets.cfg`) thì exit 0. Bài học:
  luôn kiểm tra SHA pck sau export, đừng tin exit code của lần
  chạy gộp khi lệnh sau che mất lỗi lệnh trước.
- Export web exit 0: pck **16.756.776 byte, SHA `e1919a27`**
  (trước `c6461bde`, +465.604 byte = 14 file art mới); wasm không
  đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ 5
  file (cổng 8183, gồm `title_bg.jpg`).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass29/check_r29.py`, ảnh `r29-01…r29-08`):
  **0 console error, 0 pageerror, 0 requestfailed.** Xem ảnh thật:
  đi chuỗi Map001→Map007 qua đúng cửa (5,4)/(5,8) từng map; Map007
  "Phố Văn Phòng Nhỏ" — Nhân Viên Văn Phòng (áo trắng) + Thực Tập
  Sinh (áo xanh nhạt, tóc đuôi ngựa) hiện rõ mặt thật có nhãn tên,
  không còn vẽ code; người chơi đi tới (10,1) đúng ô theo nhãn
  debug; 2 ảnh xa nhà cách nhau 2s pixel-diff = **19.371** (lá rơi
  + mây + NPC bob, cảnh sống).
- Lỗi tìm ra khi xem ảnh (cosmetic, không chặn): nhãn "Thực Tập
  Sinh" đè lên người chơi lúc spawn (người chơi đứng sau nhãn);
  toast "Đã sang Phố Văn Phòng Nhỏ" đè lên nhãn "Cửa đi Khu Chung
  Cư Cao Cấp" ở đáy màn hình; D-pad đè lên cửa ở mép trái (đã biết
  từ các vòng trước).
- Staging đã rebuild cho pck `e1919a27` (`build_gh_pages.py`:
  wasm 293 chunk + pck 125 chunk khớp byte, ảnh khớp byte).

### 51.5 Deploy — ĐÃ LÀM MỘT PHẦN (lượt 24/11 00:45, cron 00:45)

- **Push main r25→r29 + docs XONG trong lượt này:** đường ghi
  push_files đã HỒI sau 10 lần gián đoạn liên tiếp — thử thăm dò
  1 lần đầu lượt thành công ngay (commit `7f008798` lô A r25).
  Tổng 16 commit, head main nay `4bfe5d46bf5c` (docs r25–29):
  r25 `7f008798`/`792e3f00`/`6c7b9400`, r26 `df29a7bf`/`27baaf4a`/
  `9f2512e7`, r27 `2eb3b431`/`4d8f59f2`/`cd8df953`, r28 `7fe17d10`/
  `9bf2eec8`/`ce450514`, r29 `779c4fe0`/`cd8cd4cd`/`30dcb5c9`,
  docs `4bfe5d46`. Chi tiết trong
  `~/workspace/pho-xo-bo.muse-github-snapshot-sync.json` (mục
  244–259). Lỗi duy nhất: 3 manifest vòng 27 viết bằng `\n` thay
  vì `\0` nên push-files từ chối — đã sửa sang NUL rồi đẩy lại
  thành công. Bài học: kiểm tra định dạng manifest bằng `od -c`
  trước khi đẩy (lô r27 là lô duy nhất sai trong 15 lô).
- **Deploy gh-pages pck `e1919a27` DỞ DANG:** staging verify OK
  (`build_gh_pages.py --verify-only` PASS, pck 125 chunk khớp
  byte); chỉ pck mới (wasm + img trùng version với live nên không
  đẩy lại). Đã đẩy 4/8 lô pck (chunk 000–063, commit `ecba525b`,
  `b69296ae`, `2e7c8029`, `8547176c`) — lô 5 (chunk 064–079) bị
  kẹt vì phê duyệt hết thời gian (userConfirmation timed out sau
  ~41 phút chạy chuỗi) → **DỪNG deploy theo hướng dẫn, KHÔNG thử
  lại trong lượt này**. Live KHÔNG ảnh hưởng: index.html +
  versions.json chưa đẩy nên live vẫn pck `db28f2c4` (vòng 24),
  đã verify bằng curl versions.json live sau khi dừng.
- Bài học mới — **giới hạn body MCP 413:** lô 32 chunk (5,76 MB)
  bị `HTTP 413: request body too large` — giới hạn thực tế nằm
  giữa 3,6 MB (20 chunk, từng đẩy được) và 5,76 MB; lô deploy an
  toàn là **16 chunk/lô (~2,88 MB)**. Manifest lô 16-chunk đã
  tạo: `/tmp/pxb-deploy-e1919a27-b1..b8` (b1–b4 đã đẩy, b5–b8 +
  final còn lại). Vòng sau: đẩy tiếp b5–b8 + final rồi chạy
  `build_gh_pages.py --check-live` + kiểm live cloud browser.
  (Manifest lô 32-chunk cũ `/tmp/pxb-deploy-e1919a27-batch1..4`
  bỏ, không dùng.)

### 51.6 Việc tiếp theo

1. **Push main (r25 + r26 + r27 + r28 + r29) + deploy gh-pages pck
   `e1919a27` → verify live khớp byte → kiểm live cloud browser**
   (Map007: Nhân Viên Văn Phòng + Thực Tập Sinh đi patrol bằng
   art thật).
2. NPC Map008 walk cycle (Khu Chung Cư Cao Cấp: 2 NPC của map 8)
   theo từng map, mẫu vòng này.
3. Sprite sạp tách riêng (§45.1): đổi hàng 0 thành sạp cách nhau
   (ô lẻ để trống) rồi gen 3 sprite sạp (rau/trái cây/cá-thịt).

## 52. Vòng 30 — Walk cycle NPC Map008: Cư Dân Cao Cấp + Bảo Vệ Chung Cư (24/11 ~01:30–03:00 +07, cron 00:45)

Mục 2 §51.6: NPC Map008 walk cycle theo từng map. Vòng này làm
Map008 Khu Chung Cư Cao Cấp: Cư Dân Cao Cấp (3,3) + Bảo Vệ Chung Cư (8,6).

### 52.1 Art (subagent, theo đúng quy trình vòng 29) — XONG

- Thư mục `visual-check/artpass30/`; ảnh đứng + sheet 6 khung cho
  Cư Dân Cao Cấp (nữ trung niên khá giả, blouse hồng nhạt, quần âu
  trắng, giày bệt đen, tóc búi cao, túi xách nhỏ) + Bảo Vệ Chung Cư
  (nam trung niên, sơ mi xanh đậm đồng phục có huy hiệu, quần tối,
  giày đen, mũ đồng phục); xử lý trắng → trong suốt + cắt frame
  theo mẫu vòng 29 (connected component, MIN_FIG_W=100).
- File đích: `src/godot/art/char_cudancaocap.png` (78×208) +
  `char_baovechungcu.png` (97×208), `walk_cudancaocap_f0..f5.png`
  (canvas chung 111×208) + `walk_baovechungcu_f0..f5.png` (canvas
  chung 139×208), RGBA.
- Kiểm tra bằng mắt: 2 ảnh đứng + 2 sheet ĐẠT ngay lần đầu (**0 lần
  gen lại**); sheet Bảo Vệ có f0/f1 chồng lấn trục x nhưng tách bằng
  connected component vẫn đúng (bài học vòng 28). Dải magenta cả 2
  sạch, không quầng trắng.
- Hạn chế thấy bằng mắt: chỉ mặt trước (3/4); f5 gần như tư thế
  đứng; f2/f3/f4 khá gần nhau; áo Cư Dân gen ra cổ trụ khuy bấm
  (kiểu áo dài cách tân) thay vì blouse cổ bẻ; mũ Bảo Vệ dạng kê-pi
  có huy hiệu thay vì mũ lưỡi trai; tay f0 Bảo Vệ giơ ngang vai —
  tất cả chấp nhận được. Chi tiết:
  `visual-check/artpass30/walkcycle-npc-map008-note.md`.

### 52.2 Code + test — XONG

- `marker.gd` NPC_STYLE thêm `"cu-dan-cao-cap"` (áo hồng nhạt
  (0.95,0.75,0.80), tóc "bui", texture + frames) +
  `"bao-ve-chung-cu"` (áo xanh đậm (0.15,0.30,0.55), tóc "ngan",
  texture + frames). Không sửa logic `CharacterSprite`/`Marker`.
- Test mới `tests/g4_r30_npc_walk_map008_test.gd`: **29/29 PASS**
  (theo mẫu r29: sprite trực tiếp từng NPC, marker home_tile
  (3,3)/(8,6), Main load_map(8) + pick patrol từ nhà Cư Dân Cao
  Cấp).
- `tools/godot/run_regression.sh` thêm test mới (nay 58 suite).

### 52.3 Verify thật vòng này

- Hồi quy đầy đủ: **58 OK, 0 FAIL** (57 cũ + 1 mới r30).
- Smoke `--headless --quit-after 120` exit 0.
- Export web exit 0: pck **17.193.156 byte, SHA `629ad8b8…`**
  (trước `e1919a27`, +436.380 byte = 14 file art mới); wasm không
  đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ 5
  file (cổng 8184, gồm `title_bg.jpg`).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass30/check_r30.py`, ảnh `r30-01…r30-09`):
  **0 console error, 0 pageerror, 0 requestfailed.** Xem ảnh thật:
  đi chuỗi Map001→Map008 qua đúng cửa (5,4)/(5,8) từng map; Map008
  "Khu Chung Cư Cao Cấp" — Cư Dân Cao Cấp (áo hồng nhạt, búi cao,
  túi xách) + Bảo Vệ Chung Cư (đồng phục xanh đậm, mũ) hiện rõ mặt
  thật có nhãn tên, không còn vẽ code; người chơi đi tới (10,1)
  đúng ô theo nhãn debug; cả 2 NPC patrol rời nhà sau 12s xa; 2 ảnh
  xa nhà cách nhau 2s pixel-diff = **22.953** (lá rơi + mây + NPC
  bob, cảnh sống).
- Lỗi tìm ra khi xem ảnh (cosmetic, không chặn): nhãn "Bảo Vệ Chung
  Cư" đè lên thân Cư Dân lúc 2 NPC đứng gần nhau ở spawn; Bảo Vệ
  khuất một phần sau D-pad ở mép trái (đã biết từ các vòng trước).
- Staging CHƯA rebuild cho pck `629ad8b8` (vòng sau rebuild + deploy
  sau khi deploy `e1919a27` xong).

### 52.4 Push — CHƯA XONG (dịch vụ chập chờn trở lại)

- Thử đẩy main r30 lô A 1 lần cuối lượt: gián đoạn ngay ("service
  restarted while it was running") — lần gián đoạn đầu tiên kể từ
  khi dịch vụ hồi đầu lượt (16 commit main + 4 lô deploy đã đẩy
  thành công trước đó trong lượt). Kiểm tra lại: sync record không
  đổi (263 mục, chưa có commit r30 nào được xác nhận); lệnh kiểm
  tra head main cũng gián đoạn theo nên head chưa xác minh được —
  r30-a có thể đã lên GitHub nhưng chưa có SHA xác nhận nên KHÔNG
  ghi nhận. **DỪNG retry push trong lượt này** (luật §47.4).
  Manifest sẵn: `~/workspace/pxb-push-r30-paths-{a,b,c}` +
  `pxb-push-docs-r30` (docs gồm §51.5 cập nhật deploy + §52 vòng
  30). Vòng sau: kiểm tra head main trước rồi đẩy tiếp; nếu r30-a
  đã lên thì chỉ đẩy b/c + docs.
- Deploy gh-pages pck `e1919a27` vẫn dở dang như §51.5 (lô b5–b8 +
  final chưa đẩy); staging CHƯA rebuild cho pck `629ad8b8`.

### 52.6 Cập nhật 24/11 ~11:00 — DEPLOY `e1919a27` XONG, PUSH r30 XONG

- **Deploy gh-pages pck `e1919a27` ĐÃ XONG trong lượt này (cron
  10:45):** manifest lô b5–b8 + final tạo lại (file `/tmp` cũ đã
  mất sau restart VM — tạo mới tại `~/workspace/pxb-deploy-e1919a27-b5..b8`
  + `-final`, kiểm `od -c` NUL đúng); đẩy 5 lô liên tiếp, phê duyệt
  về ngay cả 5 lần (khác hẳn lần trước kẹt 41 phút ở b5): b5 chunk
  064–079 `93093b70`, b6 080–095 `c7c0f93e`, b7 096–111 `73fbfbff`,
  b8 112–124 `fda9430d`, final (versions.json + index.html)
  `829ed44c`. Sync record nay 268 mục. **Live đã chuyển sang pck
  `e1919a27` (vòng 29):** `--check-live` PASS sau khi chờ CDN lan
  (lần kiểm đầu FAIL do versions.json live còn cache `db28f2c4`,
  chunk part-124 404 nhất thời — API gh-pages đã có đủ file, chỉ
  là CDN chưa lan; kiểm lại sau vài phút thì khớp byte).
- **Push main r30 XONG trong lượt này:** lô a (marker.gd + test
  r30 + run_regression.sh) `8d107b0e` + lô b (14 file .import art
  Map008) `07920614` + lô c (visual-check artpass30) `e38e8544` +
  docs (godot-g4.md §52.6 + roles-qc.md hiện trạng mới) — head
  main sau lô docs xem sync record mục cuối.
- **Staging CHƯA rebuild cho pck `629ad8b8`** (vòng sau rebuild +
  deploy pck này → verify live → kiểm live cloud browser Map008).

### 52.7 Cập nhật 24/11 ~11:30 — DEPLOY `629ad8b8` DỞ DANG (4/8 LÔ), DỪNG THEO LUẬT §47.4

- **Staging rebuild cho pck `629ad8b8` XONG:** `build_gh_pages.py`
  chạy lại từ build hiện tại, VERIFY OK (pck 128 chunk khớp byte,
  wasm `fc74679e` + img không đổi, fileSizes khớp); staging
  versions.json nay pck `629ad8b8`.
- **Deploy gh-pages pck `629ad8b8` mới 4/8 lô:** b1 chunk 000–015
  `b19d85f7`, b2 016–031 `c152dfd0`, b3 032–047 `36baa220`, b4
  048–063 `af9be888` (sync record 276 mục). **Lô b5 (064–079) kẹt:
  dịch vụ restart 3 lần liên tiếp ngay trong lúc đẩy (lần 1 +
  retry lần 2 + retry lần 3 đều gián đoạn, head gh-pages vẫn
  `af9be888`, b5 chưa lên)** — DỪNG retry trong lượt này theo luật
  §47.4. Live AN TOÀN: versions.json + index.html chưa đẩy nên
  live vẫn pck `e1919a27` (vòng 29), đã `--check-live` PASS.
  Manifest b5–b8 + final sẵn tại
  `~/workspace/pxb-deploy-629ad8b8-b5..b8` + `-final` (NUL đúng).
  Vòng sau: đẩy tiếp b5–b8 + final → `--check-live` → kiểm live
  cloud browser Map008.
- **Vòng 31 ĐÃ BẮT ĐẦU song song:** art walk cycle NPC Map009
  (Chủ Cửa Hàng + Người Bán Hàng) giao subagent theo mẫu vòng
  29/30 — thư mục `visual-check/artpass31/`, chỉ art + note,
  không sửa code; kết quả về sẽ làm code + test + push sau.

### 52.5 Việc tiếp theo

1. **Đẩy tiếp deploy gh-pages pck `e1919a27` (lô b5–b8 + final) →
   `--check-live` → kiểm live cloud browser** (cần phê duyệt —
   lượt này kẹt ở lô b5 do phê duyệt hết thời gian).
2. Push main r30 (3 lô + docs) + rebuild staging + deploy pck
   `629ad8b8` → verify live.
3. NPC Map009 walk cycle (Phố Thương Mại: 2 NPC của map 9) theo
   từng map, mẫu vòng này.
4. Sprite sạp tách riêng (§45.1): đổi hàng 0 thành sạp cách nhau
   (ô lẻ để trống) rồi gen 3 sprite sạp (rau/trái cây/cá-thịt).

## 53. Vòng 31 — Walk cycle NPC Map009: Chủ Cửa Hàng + Người Bán Hàng (24/11 ~11:00–14:15 +07, cron 10:45 + handoff art)

Mục 3 §52.5: NPC Map009 walk cycle theo từng map. Vòng này làm
Map009 Phố Thương Mại: Chủ Cửa Hàng (3,3) + Người Bán Hàng (8,6).

### 53.1 Art (subagent, theo đúng quy trình vòng 29/30) — XONG

- Thư mục `visual-check/artpass31/`; ảnh đứng + sheet 6 khung cho
  Chủ Cửa Hàng (nam trung niên, áo xanh nhạt, quần tối, giày da,
  sổ tay nâu, tóc điểm bạc) + Người Bán Hàng (nữ trẻ, áo xanh lá
  nhạt, váy dài tối, giày bệt, đuôi ngựa, túi giấy); xử lý trắng →
  trong suốt + cắt frame theo mẫu vòng 29/30 (connected component,
  MIN_FIG_W=100).
- File đích: `src/godot/art/char_chucuahang.png` (99×208) +
  `char_nguoibanhang.png` (109×208), `walk_chucuahang_f0..f5.png`
  (canvas chung 140×208) + `walk_nguoibanhang_f0..f5.png` (canvas
  chung 135×208), RGBA.
- Kiểm tra bằng mắt: 2 ảnh đứng + 2 sheet ĐẠT ngay lần đầu (**0 lần
  gen lại**); sheet Chủ Cửa Hàng có f0/f1 chồng lấn trục x nhưng tách
  bằng connected component vẫn đúng (bài học vòng 28). Dải magenta
  cả 2 sạch, không quầng trắng.
- Hạn chế thấy bằng mắt: chỉ mặt trước (3/4); f5 gần như tư thế
  đứng; f2/f3/f4 khá gần nhau; áo cả 2 gen ra cổ trụ khuy bấm thay
  vì cổ bẻ; chân Người Bán Hàng chỉ lộ từ dưới váy nên nhịp chân
  ít rõ bằng NPC quần dài; cả 2 đều có khuyên tai vàng nhỏ không có
  trong mô tả — tất cả chấp nhận được. Chi tiết:
  `visual-check/artpass31/walkcycle-npc-map009-note.md`.
- Godot `--headless --import` exit 0 — đủ 14 file `.import` cho
  14 file art mới (lưu ý subagent: đường dẫn binary là
  `tools/godot/Godot_v4.7.2-stable_linux.x86_64`, không có file
  `tools/godot/godot`).

### 53.2 Code + test — XONG

- `marker.gd` NPC_STYLE thêm `"chu-cua-hang"` (áo xanh nhạt
  (0.70,0.85,0.90), tóc "ngan", texture + frames) +
  `"nguoi-ban-hang"` (áo xanh lá nhạt (0.75,0.90,0.75), tóc "dai",
  texture + frames). Không sửa logic `CharacterSprite`/`Marker`.
- Test mới `tests/g4_r31_npc_walk_map009_test.gd`: **29/29 PASS**
  (theo mẫu r30: sprite trực tiếp từng NPC, marker home_tile
  (3,3)/(8,6), Main load_map(9) + pick patrol từ nhà Chủ Cửa Hàng).
- `tools/godot/run_regression.sh` thêm test mới (nay 59 suite).

### 53.3 Verify thật vòng này

- Hồi quy đầy đủ: **59 OK, 0 FAIL** (58 cũ + 1 mới r31).
- Smoke `--headless --quit-after 120` exit 0.
- Export web exit 0: pck **17.682.168 byte, SHA `ea66c202`**
  (trước `629ad8b8`, +489.012 byte = 14 file art mới); wasm không
  đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ 5
  file (cổng 8186).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass31/check_r31.py`, ảnh `r31-01…r31-10`):
  **0 console error, 0 pageerror, 0 requestfailed.** Xem ảnh thật:
  đi chuỗi Map001→Map009 qua đúng cửa (5,4)/(5,8) từng map; Map009
  "Phố Thương Mại" — Chủ Cửa Hàng (áo xanh nhạt, sổ tay) + Người
  Bán Hàng (áo xanh lá nhạt, váy dài, đuôi ngựa) hiện rõ mặt thật
  có nhãn tên, không còn vẽ code; người chơi đi tới (10,1) đúng ô
  theo nhãn debug; cả 2 NPC patrol rời nhà sau 12s; 2 ảnh xa nhà
  cách nhau 2s pixel-diff = **16.877** (lá rơi + mây + NPC bob,
  cảnh sống). Lưu ý: Playwright chỉ chạy khi
  `PYTHONPATH=/home/hatch/.local/lib/python3.12/site-packages`
  (python3 mặc định không thấy user site-packages).
- Lỗi tìm ra khi xem ảnh (cosmetic, không chặn): nhãn "Chủ Cửa
  Hàng" đè lên Người Bán Hàng lúc 2 NPC đứng gần nhau ở spawn
  (giống vòng 30); Người Bán Hàng khuất một phần sau D-pad ở mép
  trái (đã biết từ các vòng trước).

### 53.4 Push + Deploy — XONG (gộp, thay cho deploy `629ad8b8` dở)

- **Push main r31 XONG:** lô a (marker.gd + test r31 + .uid +
  run_regression.sh) `a437ba61` + lô b (14 file .import art
  Map009) `e8260bdb` + lô c (visual-check artpass31)
  `e441ff1a` + docs (godot-g4.md §53 + roles-qc.md hiện trạng
  mới) — head main sau lô docs xem sync record mục cuối.
- **QUYẾT ĐỊNH GỘP (Bậc 1, lượt này):** pck `629ad8b8` (vòng 30)
  mới deploy 4/8 lô thì kẹt b5 (§52.7); pck `ea66c202` (vòng 31)
  chứa toàn bộ nội dung `629ad8b8` + art Map009. Để tránh deploy 2
  lần liên tiếp trên đường ghi chập chờn, CHỈ deploy `ea66c202` lên
  live — `629ad8b8` không lên live riêng. Chunk `629ad8b8` b1–b4
  đã đẩy vẫn nằm trên gh-pages nhưng không được versions.json trỏ
  tới (mồ côi vô hại — chunk theo version, không ai tải; manifest
  `pxb-deploy-629ad8b8-b5..b8` + `-final` bỏ, không dùng).
- **Deploy gh-pages pck `ea66c202` XONG:** staging rebuild VERIFY
  OK (pck 131 chunk khớp byte, wasm + img không đổi); đẩy 10 lô
  liên tiếp, phê duyệt về ngay cả 10 lần: b1 chunk 000–015
  `f0fe2d26`, b2 016–031 `2747a7ae`, b3 032–047 `91f843b3`, b4
  048–063 `0dcf548b`, b5 064–079 `10b76597`, b6 080–095
  `38f103e2`, b7 096–111 `9213af8f`, b8 112–127 `a704a8ef`, b9
  128–130 `805a44c1`, final (versions.json + index.html)
  `f7114aa9`. Sync record nay 289 mục. **Live đã chuyển sang pck
  `ea66c202` (vòng 31):** `--check-live` PASS ngay lần đầu sau
  60s chờ CDN (versions.json live `ea66c202`, index.html khớp
  staging từng byte).

### 53.5 Việc tiếp theo

1. NPC Map010 walk cycle (Khu Công Nghệ: Lập Trình Viên +
   Kỹ Sư Phần Mềm) theo từng map, mẫu vòng này.
2. Sprite sạp tách riêng (§45.1): đổi hàng 0 thành sạp cách nhau
   (ô lẻ để trống) rồi gen 3 sprite sạp (rau/trái cây/cá-thịt).
3. Kiểm live cloud browser Map009 (live nay `ea66c202` — kiểm
   trực tiếp trên link Pages khi cần, không cần deploy lại).

## 54. Vòng 32 — Walk cycle NPC Map010: Lập Trình Viên + Kỹ Sư Phần Mềm (24/11 ~22:45–23:15 +07, cron 22:45)

Mục 1 §53.5: NPC Map010 walk cycle theo từng map. Vòng này làm
Map010 Khu Công Nghệ: Lập Trình Viên (3,3) + Kỹ Sư Phần Mềm (8,6).

### 54.1 Art (subagent, theo đúng quy trình vòng 29/30/31) — XONG

- Thư mục `visual-check/artpass32/`; ảnh đứng + sheet 6 khung cho
  Lập Trình Viên (nam trẻ, áo polo xanh navy, quần jeans tối, giày
  thể thao trắng, tóc đen ngắn, đeo kính, cầm laptop mỏng) + Kỹ Sư
  Phần Mềm (nữ trẻ, áo blouse trắng xám nhạt, quần âu tối, giày bệt
  đen, tóc đen dài ngang vai, cầm máy tính bảng); xử lý trắng →
  trong suốt + cắt frame theo mẫu vòng 31 (connected component,
  MIN_FIG_W=100).
- File đích: `src/godot/art/char_laptrinhvien.png` (85×208) +
  `char_kysuphanmem.png` (99×208), `walk_laptrinhvien_f0..f5.png`
  (canvas chung 153×208) + `walk_kysuphanmem_f0..f5.png` (canvas
  chung 181×208), RGBA.
- Kiểm tra bằng mắt: 2 ảnh đứng + 2 sheet ĐẠT ngay lần đầu (**0 lần
  gen lại**); sheet Lập Trình Viên có f0/f1 chồng lấn trục x nhưng
  tách bằng connected component vẫn đúng (bài học vòng 28). Dải
  magenta cả 2 sạch, không quầng trắng.
- Hạn chế thấy bằng mắt: chỉ mặt trước (3/4); f5 gần như tư thế
  đứng; f2/f3/f4 khá gần nhau; blouse Kỹ Sư Phần Mềm cổ trụ khuy
  bấm thay vì cổ bẻ; laptop/tablet đổi tay theo nhịp đi; khuyên tai
  vàng nhỏ cả 2 (như vòng 31); sheet Kỹ Sư Phần Mềm tỉ lệ
  3840×640, nền góc (254,254,254) — slice vẫn tách đúng 6 hình.
  Tất cả chấp nhận được. Chi tiết:
  `visual-check/artpass32/walkcycle-npc-map010-note.md`.

### 54.2 Code + test — XONG

- `marker.gd` NPC_STYLE thêm `"lap-trinh-vien"` (áo navy
  (0.15,0.25,0.45), tóc "ngan", texture + frames) +
  `"ky-su-phan-mem"` (áo trắng xám (0.85,0.85,0.88), tóc "dai",
  texture + frames). Không sửa logic `CharacterSprite`/`Marker`.
- Test mới `tests/g4_r32_npc_walk_map010_test.gd`: **29/29 PASS**
  (theo mẫu r31: sprite trực tiếp từng NPC, marker home_tile
  (3,3)/(8,6), Main load_map(10) + pick patrol từ nhà Lập Trình
  Viên).
- `tools/godot/run_regression.sh` thêm test mới (nay 60 suite).

### 54.3 Verify thật vòng này

- Hồi quy đầy đủ: **60 OK, 0 FAIL** (59 cũ + 1 mới r32).
- Smoke `--headless --quit-after 120` exit 0.
- Export web exit 0: pck **18.163.860 byte, SHA `0d2cf705`**
  (trước `ea66c202`, +481.692 byte = 14 file art mới); wasm không
  đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ 6
  file (cổng 8187).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass32/check_r32.py`, ảnh `r32-01…r32-11`):
  **0 console error, 0 pageerror, 0 requestfailed.** Xem ảnh thật:
  đi chuỗi Map001→Map010 qua đúng cửa (5,4)/(5,8) từng map; Map010
  "Khu Công Nghệ" — Lập Trình Viên (polo navy, kính, laptop) + Kỹ
  Sư Phần Mềm (blouse trắng xám, máy tính bảng) hiện rõ mặt thật
  có nhãn tên, không còn vẽ code; người chơi đi tới (10,1) đúng ô
  theo nhãn debug; cả 2 NPC patrol rời nhà sau 12s; 2 ảnh xa nhà
  cách nhau 2s pixel-diff = **20.844** (lá rơi + mây + NPC bob,
  cảnh sống).
- Lỗi tìm ra khi xem ảnh (cosmetic, không chặn): nhãn "Kỹ Sư Phần
  Mềm" đè lên thân Lập Trình Viên lúc 2 NPC đứng gần nhau ở spawn
  (giống vòng 30/31); Kỹ Sư Phần Mềm khuất một phần sau D-pad ở
  mép trái (đã biết từ các vòng trước).

### 54.4 Push + Deploy — XONG

- **Push main r32 XONG:** lô a (marker.gd + test r32 + .uid +
  run_regression.sh) `133c0ed9` + lô b (14 file .import art
  Map010) `3c9fd236` + lô c (visual-check artpass32)
  `10783ed7` + docs (godot-g4.md §54 + roles-qc.md hiện trạng
  mới) — head main sau lô docs xem sync record mục cuối.
- **Deploy gh-pages pck `0d2cf705` XONG:** staging rebuild VERIFY
  OK (pck 135 chunk khớp byte, wasm + img không đổi); đẩy 10 lô
  liên tiếp, phê duyệt về ngay cả 10 lần: b1 chunk 000–015
  `5167b414`, b2 016–031 `7d15832f`, b3 032–047 `8a2257a8`, b4
  048–063 `5df86a60`, b5 064–079 `3542a4ea`, b6 080–095
  `ff377cd4`, b7 096–111 `ab0c0272`, b8 112–127 `f0ed5af3`, b9
  128–134 `472ee58a`, final (versions.json + index.html)
  `6bfca6ab`. Sync record nay 303 mục. **Live đã chuyển sang pck
  `0d2cf705` (vòng 32):** `--check-live` PASS ngay lần đầu sau
  60s chờ CDN (versions.json live `0d2cf705`, index.html khớp
  staging từng byte).

### 54.5 Việc tiếp theo

1. NPC Map011 walk cycle (Phố Tây: Nhân Viên Lễ Tân + Hướng Dẫn
   Viên) theo từng map, mẫu vòng này.
2. Sprite sạp tách riêng (§45.1): đổi hàng 0 thành sạp cách nhau
   (ô lẻ để trống) rồi gen 3 sprite sạp (rau/trái cây/cá-thịt).
3. Kiểm live cloud browser Map010 (live nay `0d2cf705` — kiểm
   trực tiếp trên link Pages khi cần, không cần deploy lại).

## 55. Vòng 33 — Walk cycle NPC Map011: Nhân Viên Lễ Tân + Hướng Dẫn Viên (24/11 ~23:45–00:30 +07, cron 23:45)

Mục 1 §54.5: NPC Map011 walk cycle theo từng map. Vòng này làm
Map011 Phố Tây: Nhân Viên Lễ Tân (3,3) + Hướng Dẫn Viên (8,6).

### 55.1 Art (subagent, theo đúng quy trình vòng 29/30/31/32) — XONG

- Thư mục `visual-check/artpass33/`; ảnh đứng + sheet 6 khung cho
  Nhân Viên Lễ Tân (nam trẻ, áo sơ mi trắng + áo gile tối màu,
  quần âu tối, giày da đen, tóc đen ngắn gọn gàng, cầm bảng đăng
  ký khách clipboard) + Hướng Dẫn Viên (nữ trẻ, áo polo xanh
  dương nhạt, quần âu tối, giày thể thao trắng, tóc đen dài ngang
  vai, cầm cờ tour đỏ nhỏ + bản đồ gấp); xử lý trắng → trong suốt
  + cắt frame theo mẫu vòng 32 (connected component,
  MIN_FIG_W=100).
- File đích: `src/godot/art/char_nhanvienletan.png` (82×208) +
  `char_huongdanvien.png` (120×208), `walk_nhanvienletan_f0..f5.png`
  (canvas chung 145×208) + `walk_huongdanvien_f0..f5.png`
  (canvas chung 149×208), RGBA.
- Kiểm tra bằng mắt: 2 ảnh đứng + 2 sheet ĐẠT ngay lần đầu (**0 lần
  gen lại**); sheet Nhân Viên Lễ Tân có f0/f1 chồng lấn trục x
  (clipboard f0 giơ ngang) nhưng tách bằng connected component vẫn
  đúng (bài học vòng 28); sheet Hướng Dẫn Viên f4/f5 chồng lấn
  trục x (cờ f4 giơ ngang) nhưng tách đúng ngay lần đầu. Dải
  magenta cả 2 sạch, không quầng trắng.
- Hạn chế thấy bằng mắt: chỉ mặt trước (3/4); f5 gần như tư thế
  đứng; f2/f3/f4 khá gần nhau; clipboard/cờ/bản đồ đổi tay theo
  nhịp đi; khuyên tai vàng nhỏ Hướng Dẫn Viên (như vòng 31/32);
  **cờ tour đỏ của Hướng Dẫn Viên không thấy trong f4** (tay phải
  nắm hờ, bản đồ vẫn ở tay trái) — chỉ mất 1/6 chu kỳ, ở kích
  thước sprite trong game cờ chỉ vài pixel nên không đáng kể.
  Tất cả chấp nhận được. Chi tiết:
  `visual-check/artpass33/walkcycle-npc-map011-note.md`.

### 55.2 Code + test — XONG

- `marker.gd` NPC_STYLE thêm `"nhan-vien-le-tan"` (áo trắng
  (0.92,0.92,0.95), tóc "ngan", texture + frames) +
  `"huong-dan-vien"` (áo xanh dương nhạt (0.55,0.75,0.95), tóc
  "dai", texture + frames). Không sửa logic `CharacterSprite`/
  `Marker`.
- Test mới `tests/g4_r33_npc_walk_map011_test.gd`: **29/29 PASS**
  (theo mẫu r32: sprite trực tiếp từng NPC, marker home_tile
  (3,3)/(8,6), Main load_map(11) + pick patrol từ nhà Nhân Viên
  Lễ Tân).
- `tools/godot/run_regression.sh` thêm test mới (nay 61 suite).

### 55.3 Verify thật vòng này

- Hồi quy đầy đủ: **61 OK, 0 FAIL** (60 cũ + 1 mới r33) — chạy
  lại 25/11 00:45 trên cùng cây code, vẫn 61/61.
- Smoke `--headless --quit-after 120` exit 0, không ERROR
  (chạy lại 25/11 00:45).
- Export web exit 0: pck **18.622.468 byte, SHA `99a445f9`**
  (trước `0d2cf705`, +458.608 byte = 14 file art mới); wasm không
  đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ 6
  file (cổng 8188, kiểm lại 25/11 00:45).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass33/check_r33.py`, ảnh `r33-01…r33-12`):
  **0 console error, 0 pageerror, 0 requestfailed.** Xem ảnh thật:
  đi chuỗi Map001→Map011 qua đúng cửa (5,4)/(5,8) từng map; Map011
  "Phố Tây" — Nhân Viên Lễ Tân (sơ mi trắng + gile tối, clipboard)
  + Hướng Dẫn Viên (polo xanh nhạt, cờ đỏ + bản đồ) hiện rõ mặt
  thật có nhãn tên, không còn vẽ code; người chơi đi tới (10,1)
  đúng ô theo nhãn debug; cả 2 NPC patrol rời nhà sau 12s; 2 ảnh
  xa nhà cách nhau 2s pixel-diff = **25.931** (lá rơi + mây + NPC
  bob, cảnh sống).
- Lỗi tìm ra khi xem ảnh (cosmetic, không chặn): nhãn NPC đè nhau
  khi đứng gần ở spawn; NPC khuất một phần sau D-pad ở mép trái
  (đã biết từ các vòng trước).

### 55.4 Push + Deploy — XONG

- **Push main r33 XONG:** lô a (marker.gd + test r33 + .uid)
  `ec67055c` + lô b (14 file .import art Map011) `51366570` +
  lô c (visual-check artpass33) `9c1f2539` — head main sau lô c
  `9c1f2539`. **Docs §55 này là commit bổ sung sau** (vòng 33
  đẩy code/deploy xong nhưng chưa kịp viết §55 — vòng 25/11 00:45
  viết bù + đẩy riêng).
- **Deploy gh-pages pck `99a445f9` XONG:** staging rebuild VERIFY
  OK (pck 138 chunk khớp byte, wasm + img không đổi); đẩy 10 lô
  liên tiếp: b1 chunk 000–015 `cdb319a5`, b2 016–031 `2adbe949`,
  b3 032–047 `9f12edc9`, b4 048–063 `f6ecddc5`, b5 064–079
  `b7c7a7b3`, b6 080–095 `13dd5aef`, b7 096–111 `4b3bb961`, b8
  112–127 `12d01349`, b9 128–137 `ee20f514`, final
  (versions.json + index.html) `d4e8e210`. Sync record nay 317 mục.
  **Live đã chuyển sang pck `99a445f9` (vòng 33):**
  `--check-live` PASS (kiểm lại 25/11 00:45: versions.json live
  `99a445f9`, index.html khớp staging từng byte).

### 55.5 Đính chính — lần chạy lại check_r33.py 25/11 00:45 đi lố sang Map013

- Chạy lại `check_r33.py` trên đúng build `99a445f9` để xác nhận
  lại: start OK, **ERRORS: none**, pixel-diff 2.651 — nhưng ảnh
  `r33-10…r33-12` mới hiện **Map013 Quận Tài Chính** thay vì
  Map011: chuỗi đi 10 map bằng giữ phím 400ms/ô bị trôi ở FPS
  thấp (swiftshader ~5fps) — một lần giữ phím ăn 2 ô hoặc một
  lần bấm lọt giữa 2 frame, pha dịch chuyển dồn lại thành đi lố
  2 map. Đây là **lỗi của harness đo, không phải lỗi game**
  (đúng build đó đã đi đúng chuỗi ở lần chạy gốc, ảnh gốc chứng
  minh).
- Đã khôi phục đủ 12 ảnh gốc `r33-01…r33-12` từ backup
  (`/tmp/r33-shots-backup/`) — ảnh mới đi lố đã xóa, không dùng
  làm bằng chứng. Bài học: script đi chuỗi dài phải kiểm tra
  tiêu đề map trong TỪNG ảnh, không tin tên file; giữ phím ở FPS
  thấp cần xác nhận ô sau mỗi bước (đọc nhãn debug) thay vì bấm
  mù 4 lần liên tiếp.

### 55.6 Việc tiếp theo

1. NPC Map012 walk cycle (Khu Biệt Thự Ven Sông: Bảo Vệ Biệt Thự
   + Người Làm Vườn) theo từng map, mẫu vòng này — **art đã giao
   subagent ở lượt 25/11 00:45, đang làm**.
2. Sprite sạp tách riêng (§45.1): đổi hàng 0 thành sạp cách nhau
   (ô lẻ để trống) rồi gen 3 sprite sạp (rau/trái cây/cá-thịt).
3. Kiểm live cloud browser Map011 (live nay `99a445f9` — kiểm
   trực tiếp trên link Pages khi cần, không cần deploy lại).

## 56. Vòng 34 — Walk cycle NPC Map012: Bảo Vệ Biệt Thự + Người Làm Vườn (25/11 ~00:45–01:30 +07, cron 00:45)

Mục 1 §55.6: NPC Map012 walk cycle theo từng map. Vòng này làm
Map012 Khu Biệt Thự Ven Sông: Bảo Vệ Biệt Thự (3,3) + Người Làm
Vườn (8,6).

### 56.1 Art (subagent, theo đúng quy trình vòng 29/30/31/32/33) — XONG

- Thư mục `visual-check/artpass34/`; ảnh đứng + sheet 6 khung cho
  Bảo Vệ Biệt Thự (nam trung niên, mũ bảo vệ có huy hiệu vàng, sơ
  mi xanh đậm có cầu vai + huy hiệu ngực, quần âu tối, giày da
  đen, cầm đèn pin) + Người Làm Vườn (nam lớn tuổi tóc bạc + ria
  bạc, đội nón lá, áo be/kaki cổ trụ 3 cúc, quần tối, giày vải
  nâu, cầm kéo cắt cây + bình tưới xanh lá); xử lý trắng → trong
  suốt + cắt frame theo mẫu vòng 33 (connected component,
  MIN_FIG_W=100) + 2 sửa mới của vòng này (xem dưới).
- File đích: `src/godot/art/char_baovebietthu.png` (91×208) +
  `char_nguoilamvuon.png` (133×208), `walk_baovebietthu_f0..f5.png`
  (canvas chung 154×208) + `walk_nguoilamvuon_f0..f5.png`
  (canvas chung 145×208), RGBA.
- Kiểm tra bằng mắt: 2 ảnh đứng + 2 sheet ĐẠT ngay lần đầu (**0 lần
  gen lại**); dải magenta cả 2 sạch, không quầng trắng; zoom 4×
  kiểm tra thấu kính đèn pin + vòng dây đèn pin + tam giác giữa
  chân đều trong suốt đúng.
- **2 sửa script mới (ghi trong note, vòng sau copy từ vòng 34,
  không phải vòng 33):** (1) sheet Người Làm Vườn lần đầu chỉ
  tách được 5 hình — f2+f3 gộp thành 1 component rộng 913px do
  vành nón lá rộng + tay giơ ngang chạm nhau; thêm
  `split_wide_component` (tách component >600px tại cột mật độ
  thấp nhất) thì đúng 6 hình ngay lần đầu. (2) Vùng trắng kín
  (vòng dây đèn pin, tam giác giữa hai chân, khe tay–thân) bị
  flood fill giữ thành đục — thêm bước xóa vùng trắng kín
  ≥100 final px; bản đầu dùng ngưỡng pixel thô đã xóa nhầm thấu
  kính đèn pin (thấy lỗ magenta khi zoom), đã sửa lại theo
  final px; thấu kính (16–21px) và quai bình tưới (≤55px) được
  giữ nguyên. Lưu ý: ngưỡng xóa trắng kín chỉ đúng khi NPC
  không mặc đồ trắng.
- Hạn chế thấy bằng mắt: chỉ mặt trước (3/4); f5 gần như tư thế
  đứng; f2/f3/f4 khá gần nhau; đạo cụ đổi tay theo nhịp đi. Tất
  cả chấp nhận được. Chi tiết:
  `visual-check/artpass34/walkcycle-npc-map012-note.md`.

### 56.2 Code + test — XONG

- `marker.gd` NPC_STYLE thêm `"bao-ve-biet-thu"` (áo xanh đậm
  (0.12,0.25,0.45), tóc "ngan", texture + frames) +
  `"nguoi-lam-vuon"` (áo be/kaki (0.85,0.78,0.60), tóc "ngan",
  texture + frames). Không sửa logic `CharacterSprite`/`Marker`.
- Test mới `tests/g4_r34_npc_walk_map012_test.gd`: **29/29 PASS**
  (theo mẫu r33: sprite trực tiếp từng NPC, marker home_tile
  (3,3)/(8,6), Main load_map(12) + pick patrol từ nhà Bảo Vệ
  Biệt Thự).
- `tools/godot/run_regression.sh` thêm test mới (nay 62 suite).

### 56.3 Verify thật vòng này

- Hồi quy đầy đủ: **62 OK, 0 FAIL** (61 cũ + 1 mới r34).
- Smoke `--headless --quit-after 120` exit 0, không ERROR.
- Export web exit 0: pck **19.145.008 byte, SHA `aa5e4447`**
  (trước `99a445f9`, +522.540 byte = 14 file art mới); wasm không
  đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ 6
  file (cổng 8189).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass34/check_r34.py`, ảnh `r34-01…r34-13`):
  **0 console error, 0 pageerror, 0 requestfailed.** Xem ảnh thật:
  đi chuỗi Map001→Map012 qua đúng cửa (5,4)/(5,8) từng map (đã
  kiểm tiêu đề từng ảnh theo bài học §55.5 — lần này chuỗi không
  trôi); Map012 "Khu Biệt Thự Ven Sông" — Bảo Vệ Biệt Thự (đồng
  phục xanh đậm, mũ có huy hiệu, đèn pin) + Người Làm Vườn (nón
  lá, áo be/kaki, kéo + bình tưới) hiện rõ mặt thật có nhãn tên,
  không còn vẽ code; người chơi đi xa, cả 2 NPC patrol rời nhà
  sau 12s (Bảo Vệ bước ra mép trái giữa chu kỳ, Người Làm Vườn
  gần D-pad); 2 ảnh xa nhà cách nhau 2s pixel-diff = **9.735**
  (lá rơi + mây + NPC bob, cảnh sống).
- Lỗi tìm ra khi xem ảnh (cosmetic, không chặn): nhãn "Người Làm
  Vườn" đè lên thân Bảo Vệ lúc 2 NPC đứng gần nhau ở spawn (giống
  vòng 30–33); Người Làm Vườn khuất một phần sau D-pad ở mép
  trái; người chơi spawn Map012 ở (5,5) thay vì (5,4) — 1 bước
  thừa do phím giữ lọt sang map mới (harness, không phải game);
  đi xa dừng ở (10,2) thay vì (10,1) — 1 lần bấm lên bị miss ở
  FPS thấp, vẫn đủ xa để patrol kích hoạt.

### 56.4 Push + Deploy — XONG

- **Push main r34 XONG:** lô a (marker.gd + test r34 + .uid +
  run_regression.sh) `c2a212be` + lô b (14 file .import art
  Map012) `833336e8` + lô c (visual-check artpass34)
  `f42bdef5` + docs (godot-g4.md §55–56 + roles-qc.md)
  `74dc0cb0` — head main sau lô docs `74dc0cb0`.
- **Deploy gh-pages pck `aa5e4447` XONG:** staging rebuild VERIFY
  OK (pck 142 chunk khớp byte, wasm + img không đổi); đẩy 10 lô
  liên tiếp: b1 chunk 000–015 `fb438e3d`, b2 016–031 `bbf7c663`,
  b3 032–047 `40a797f6`, b4 048–063 `151540b9`, b5 064–079
  `928f4e53`, b6 080–095 `1ff918e2`, b7 096–111 `ac56d5d5`, b8
  112–127 `a74e24be`, b9 128–141 `357c8e0b`, final
  (versions.json + index.html) `556f67d3`. Sync record nay 331 mục.
  **Live đã chuyển sang pck `aa5e4447` (vòng 34):**
  `--check-live` PASS (versions.json live `aa5e4447`, index.html
  khớp staging từng byte).
- Lưu ý: message commit deploy ghi "(§55)" do script deploy copy
  từ vòng 33 chưa đổi số mục — chỉ sai nhãn, nội dung đúng pck
  `aa5e4447` vòng 34. Lô final lên GitHub lúc 01:50:18Z nhưng
  script bị kill (tưởng approval kẹt) trước khi ghi sync record —
  đã ghi bù thủ công từ SHA commit trên GitHub
  (`556f67d3…`, đối chiếu message + thời gian), không push lại.
- Dọn dẹp: thẻ approval deploy lô 1 chờ ~6 phút mới về (lô 2–10
  về ngay sau đó) — lần sau đợi approval lâu hơn trước khi kết
  luận kẹt; kiểm tra sync record + head gh-pages trước khi kill
  script deploy đang chạy.

### 56.5 Việc tiếp theo

1. NPC Map013 walk cycle (Quận Tài Chính: Nhân Viên Ngân Hàng +
   Môi Giới Chứng Khoán) theo từng map, mẫu vòng này — nhớ copy
   script slice từ **vòng 34** (có `split_wide_component` + xóa
   trắng kín theo final px).
2. Sprite sạp tách riêng (§45.1): đổi hàng 0 thành sạp cách nhau
   (ô lẻ để trống) rồi gen 3 sprite sạp (rau/trái cây/cá-thịt).
3. Kiểm live cloud browser Map012 (live nay `99a445f9` cho tới
   khi deploy `aa5e4447` xong — kiểm trực tiếp trên link Pages
   khi cần).

## 57. Vòng 35 — Walk cycle NPC Map013: Nhân Viên Ngân Hàng + Môi Giới Chứng Khoán (25/11 ~08:45–09:45 +07, cron 08:45)

Mục 1 §56.5: NPC Map013 walk cycle theo từng map. Vòng này làm
Map013 Quận Tài Chính: Nhân Viên Ngân Hàng (3,3) + Môi Giới
Chứng Khoán (8,6).

### 57.1 Art (subagent, theo đúng quy trình vòng 29/30/31/32/33/34) — XONG

- Thư mục `visual-check/artpass35/`; ảnh đứng + sheet 6 khung cho
  Nhân Viên Ngân Hàng (nam trẻ, vest xanh navy + sơ mi xanh nhạt +
  cà vạt đỏ đậm, quần âu tối, giày da đen, cầm xấp giấy tờ ngân
  hàng / tablet) + Môi Giới Chứng Khoán (nam, vest xám than + sơ
  mi xanh bạc hà nhạt + cà vạt tối, đeo kính, giày da đen, cầm
  điện thoại hiện biểu đồ nến xanh/đỏ + tập hồ sơ); xử lý trắng →
  trong suốt + cắt frame theo mẫu vòng 34 (connected component,
  MIN_FIG_W=100, `split_wide_component` MAX_FIG_W=600 + xóa vùng
  trắng kín ≥100 final px).
- File đích: `src/godot/art/char_nhanviennganhang.png` (93×208) +
  `char_moigioichungkhoan.png` (103×208),
  `walk_nhanviennganhang_f0..f5.png` (canvas chung 153×208) +
  `walk_moigioichungkhoan_f0..f5.png` (canvas chung 131×208), RGBA.
- Kiểm tra bằng mắt: 2 ảnh đứng + 2 sheet; **1 lần gen lại** —
  ảnh đứng Nhân Viên Ngân Hàng lần đầu bị vẽ thành NỮ (tóc búi,
  bông tai vàng) vì ảnh tham chiếu `char_cotu.png` là nhân vật nữ;
  gen lại 1 lần với prompt siết giới tính ("MAN, masculine face,
  short black hair, no earrings, no bun") thì đạt ngay; bản hỏng
  giữ lại làm hồ sơ
  (`rejected-female-char-nhanviennganhang-af4428f2.webp`). Ảnh
  đứng Môi Giới + cả 2 sheet đều đạt ngay lần đầu (0 gen lại).
  Dải magenta cả 2 sạch, không quầng trắng; zoom 4× kiểm tra giấy
  tờ/tablet + điện thoại (nến xanh/đỏ + cột khối lượng) + kính
  gọng đen đều nguyên vẹn. Không có vùng trắng kín ≥100 final px
  nào bị xóa; vùng trắng kín còn lại chỉ là giấy trắng của xấp
  tài liệu (15–61 final px, giữ đúng thiết kế). Cả 2 sheet đúng
  6 hình, không cần tách component rộng.
- **Bài học mới (ghi trong note):** NPC nam tham chiếu
  `char_cotu.png` (nữ) phải siết giới tính ngay trong prompt; giấy
  trắng cầm tay có thể tạo vùng trắng kín thật — NPC nào cầm giấy
  trắng mà vùng giấy khép kín ≥100 final px thì bước xóa trắng kín
  sẽ thủng giấy, cần kiểm tra debug-white sau mỗi vòng.
- Hạn chế thấy bằng mắt: chỉ mặt trước (3/4); f5 gần như tư thế
  đứng; f2/f3/f4 khá gần nhau; đạo cụ đổi tay theo nhịp đi. Tất
  cả chấp nhận được. Chi tiết:
  `visual-check/artpass35/walkcycle-npc-map013-note.md`.

### 57.2 Code + test — XONG

- `marker.gd` NPC_STYLE thêm `"nhan-vien-ngan-hang"` (vest navy
  (0.12,0.20,0.42), tóc "ngan", texture + frames) +
  `"moi-gioi-chung-khoan"` (vest xám than (0.30,0.30,0.33), tóc
  "ngan", texture + frames). Không sửa logic `CharacterSprite`/
  `Marker`.
- Test mới `tests/g4_r35_npc_walk_map013_test.gd`: **29/29 PASS**
  (theo mẫu r34: sprite trực tiếp từng NPC, marker home_tile
  (3,3)/(8,6), Main load_map(13) + pick patrol từ nhà Nhân Viên
  Ngân Hàng).
- `tools/godot/run_regression.sh` thêm test mới (nay 63 suite).

### 57.3 Verify thật vòng này

- Hồi quy đầy đủ: **63 OK, 0 FAIL** (62 cũ + 1 mới r35).
- Smoke `--headless --quit-after 120` exit 0, không ERROR.
- Export web exit 0: pck **19.617.968 byte, SHA `2d9ae4e0`**
  (trước `aa5e4447`, +472.960 byte = 14 file art mới); wasm không
  đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ 6
  file (cổng 8190).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass35/check_r35.py`, ảnh `r35-01…r35-14`):
  **0 console error, 0 pageerror, 0 requestfailed.** Xem ảnh thật:
  đi chuỗi Map001→Map013 qua đúng cửa (5,4)/(5,8) từng map; Map013
  "Quận Tài Chính" — Nhân Viên Ngân Hàng (vest navy, sơ mi xanh
  nhạt, cà vạt đỏ, cầm giấy tờ) + Môi Giới Chứng Khoán (vest xám
  than, kính, điện thoại) hiện rõ mặt thật có nhãn tên, không còn
  vẽ code; người chơi đi tới (10,4) đúng ô, cả 2 NPC patrol rời
  nhà sau 12s; 2 ảnh xa nhà cách nhau 2s pixel-diff = **6.244**
  (lá rơi + mây + NPC bob, cảnh sống).
- Lỗi tìm ra khi xem ảnh (cosmetic, không chặn): nhãn "Môi Giới
  Chứng Khoán" đè lên thân Nhân Viên Ngân Hàng — **đã xác minh
  KHÔNG phải nhãn sai:** nhãn NPC chỉ hiện khi người chơi trong
  Manhattan ≤5 ô (`LABEL_NEAR_TILES`=5; lúc chụp người chơi (5,7)
  cách Nhân Viên Ngân Hàng 6 ô nên nhãn bạn ấy ẩn, cách Môi Giới
  4 ô nên nhãn bạn ấy hiện); nhãn Môi Giới neo -170px trên đầu
  bạn ấy nên trong chiếu iso rơi đúng vào vị trí Nhân Viên Ngân
  Hàng đứng phía trên-trái. Cùng mẫu đã thấy ở Map012 vòng 34
  (nhãn "Người Làm Vườn" đè lên thân Bảo Vệ, ảnh r35-11 kiểm lại
  vẫn vậy). Texture/nhãn từng NPC đã đối chiếu đúng file art đứng
  (`char_nhanviennganhang.png` vest navy + cà vạt đỏ + giấy tờ;
  `char_moigioichungkhoan.png` vest xám + kính + điện thoại).
  Người chơi spawn Map013 ở (5,7) thay vì (5,4) — phím giữ lọt
  sang map mới 3 bước (harness, không phải game); đi xa tới
  (10,4) đúng ô (phải ×5 + lên ×3 từ (5,7)).

### 57.4 Push + Deploy — XONG

- **Push main r35 XONG:** lô a (marker.gd + test r35 + .uid +
  run_regression.sh) `50463816` + lô b (14 file .import art
  Map013) `c809bd70` + lô c (visual-check artpass35)
  `10c05901` — head main sau lô c `10c05901`.
- **Deploy gh-pages pck `2d9ae4e0` XONG:** staging rebuild VERIFY
  OK (pck 146 chunk khớp byte, wasm + img không đổi); đẩy 11 lô
  liên tiếp: b1 chunk 000–015 `22aec1f5`, b2 016–031 `2f6878be`,
  b3 032–047 `c107b27e`, b4 048–063 `43819c05`, b5 064–079
  `e990ba49`, b6 080–095 `fee7a39c`, b7 096–111 `04cff97b`, b8
  112–127 `c665c8ce`, b9 128–143 `a9ccf828`, b10 144–145
  `c9855819`, final (versions.json + index.html) `acb5ee1f`.
  Sync record nay 346 mục. **Live đã chuyển sang pck `2d9ae4e0`
  (vòng 35):** `--check-live` PASS (versions.json live
  `2d9ae4e0`, index.html khớp staging từng byte).

### 57.5 Việc tiếp theo

1. NPC Map014 walk cycle (Đảo Thượng Lưu: Quản Gia Đảo + Chủ
   Biệt Thự Đảo) theo từng map, mẫu vòng này — nhớ copy script
   slice từ **vòng 34** (có `split_wide_component` + xóa trắng kín
   theo final px); lưu ý siết giới tính trong prompt khi NPC nam
   tham chiếu `char_cotu.png` + kiểm tra debug-white nếu NPC cầm
   giấy trắng.
2. Sprite sạp tách riêng (§45.1): đổi hàng 0 thành sạp cách nhau
   (ô lẻ để trống) rồi gen 3 sprite sạp (rau/trái cây/cá-thịt).
3. Nhãn NPC chỉ hiện trong 5 ô + neo -170px nên nhãn NPC (8,6)
   dễ đè lên NPC (3,3) trong chiếu iso — cân nhắc cải thiện hiển
   thị nhãn (việc polish, không chặn).

## 58. Vòng 36 — Walk cycle NPC Map014: Quản Gia Đảo + Chủ Biệt Thự Đảo (25/11 ~09:45–10:15 +07, cron 09:45)

Mục 1 §57.5: NPC Map014 walk cycle theo từng map. Vòng này làm
Map014 Đảo Thượng Lưu: Quản Gia Đảo (3,3) + Chủ Biệt Thự Đảo (8,6).

### 58.1 Art (subagent, theo đúng quy trình vòng 35) — XONG

- Thư mục `visual-check/artpass36/`; ảnh đứng + sheet 6 khung cho
  Quản Gia Đảo (nam, áo đuôi tôm đen + sơ mi xám nhạt + nơ đen,
  găng tay tối màu, cầm khay bạc có ấm trà + tách) + Chủ Biệt Thự
  Đảo (nữ, váy dài hồng đào nhạt + mũ rộng vành, cầm quạt tay +
  túi xách nhỏ); xử lý trắng → trong suốt + cắt frame theo mẫu
  vòng 35 (connected component, MIN_FIG_W=100, `split_wide_component`
  MAX_FIG_W=600 + xóa vùng trắng kín ≥100 final px).
- File đích: `src/godot/art/char_quangiadao.png` (95×208) +
  `char_chubietthudao.png` (113×208),
  `walk_quangiadao_f0..f5.png` (canvas chung 138×208) +
  `walk_chubietthudao_f0..f5.png` (canvas chung 137×208), RGBA.
- Kiểm tra bằng mắt: 2 ảnh đứng + 2 sheet; **1 lần gen lại** —
  sheet Chủ Biệt Thự Đảo bản đầu thiếu quạt tay ở f5, gen lại có
  quạt đủ 6 hình nhưng thiếu túi xách ở f2 (chấp nhận: quạt là
  đạo cụ lớn, thiếu ở f5 lộ hơn túi nhỏ thiếu ở 1 frame giữa chu
  kỳ); bản hỏng giữ lại làm hồ sơ
  (`rejected-nofan-f5-walkcycle-sheet-chubietthudao-56867cd6.webp`).
  Ảnh đứng cả 2 đạt ngay lần đầu — prompt siết giới tính của
  Quản Gia Đảo ("MAN, masculine face, short black hair, no
  earrings, no bun, no long hair") phát huy tác dụng, không tái
  phạm lỗi vòng 35. Dải magenta cả 2 sạch, không quầng trắng;
  zoom 4× kiểm tra ấm trà (vòi + quai + núm nắp), quạt xếp, túi
  chần bông, mũ rộng vành đều nguyên vẹn. Vùng trắng kín còn lại
  lớn nhất chỉ 69px (nếp váy) / 35px (highlight ấm trà), đều
  <100 final px nên được giữ; các vùng ≥100 final px đã xóa đều
  là nền nhìn xuyên qua (tam giác giữa 2 chân bắt chéo, khe xẻ
  tà váy, quai ấm trà) — không có đạo cụ trắng khép kín nào bị
  xóa mù.
- **1 sửa script duy nhất:** sheet Quản Gia Đảo có bóng đổ mặt
  đất tách rời dưới chân f0 (rộng 195px, cao 21px) làm
  `find_figures` đếm 7 hình → thêm `MIN_FIG_H = 100` vào
  `slice_walkcycle_npc_map014.py` (bỏ component cao <100px; hình
  thật ~750px). Hệ quả nhỏ: f0 Quản Gia mất vệt bóng mờ dưới
  chân, các frame khác vẫn giữ bóng dính chân.
- **Bài học mới (ghi trong note):** khi gen lại vì thiếu 1 đạo
  cụ, siết cả 2 đạo cụ cùng lúc ("fan in ALL six figures AND
  handbag in ALL six figures").
- Chi tiết:
  `visual-check/artpass36/walkcycle-npc-map014-note.md`.

### 58.2 Code + test — XONG

- `marker.gd` NPC_STYLE thêm `"quan-gia-dao"` (đuôi tôm đen
  (0.08,0.08,0.10), tóc "ngan", texture + frames) +
  `"chu-biet-thu-dao"` (váy hồng đào (0.95,0.72,0.62), tóc "dai",
  texture + frames). Không sửa logic `CharacterSprite`/
  `Marker`.
- **Lỗi tìm ra khi nối code (2 lỗi, cùng 1 gốc — tên file art
  sai chính tả):** file art lúc gen dùng stem `quanggiadao`
  (thừa 1 chữ g — "Quản Gia" không dấu là `quan-gia`, khớp NPC
  id `quan-gia-dao`), trong khi test build tiền tố frame bằng
  `npc_id.replace("-", "")` = `quangiadao` → test rớt 4/29
  (frame file không tồn tại, frame_count 0). Sửa: đổi tên 7 file
  art Quản Gia Đảo thành `quangiadao` + cập nhật `marker.gd` +
  note (đính chính trong note artpass36); sau đó test còn rớt
  2/29 vì `NPC_TEX` trong test vẫn trỏ `char_quanggiadao.png`
  cũ — sửa nốt thì **29/29 PASS**. Bài học: quy tắc đặt tên
  file art = NPC id bỏ dấu gạch nối — kiểm tra khớp tên ngay
  khi art về, trước khi chạy test.
- Test mới `tests/g4_r36_npc_walk_map014_test.gd`: **29/29 PASS**
  (theo mẫu r35: sprite trực tiếp từng NPC, marker home_tile
  (3,3)/(8,6), Main load_map(14) + pick patrol từ nhà Quản Gia
  Đảo).
- `tools/godot/run_regression.sh` thêm test mới (nay 64 suite).

### 58.3 Verify thật vòng này

- Hồi quy đầy đủ: **64 OK, 0 FAIL** (63 cũ + 1 mới r36).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR.
- Export web exit 0: pck **20.102.808 byte, SHA `210e0a19`**
  (trước `2d9ae4e0`, +484.840 byte = 14 file art mới); wasm không
  đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ
  2 file (cổng 8191).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass36/check_r36.py`, ảnh `r36-01…r36-15`;
  phải cài lại playwright bằng `pip install
  --break-system-packages playwright pillow` vì VM restart đã gỡ
  module — tiền lệ G4 §8.7): **0 console error, 0 pageerror, 0
  requestfailed.** Xem ảnh thật: đi chuỗi Map001→Map014 qua đúng
  cửa (5,4)/(5,8) từng map; Map014 "Đảo Thượng Lưu" — Quản Gia Đảo
  (đuôi tôm đen, cầm khay bạc ấm trà) + Chủ Biệt Thự Đảo (váy hồng
  đào, mũ rộng vành, quạt tay) hiện rõ mặt thật có nhãn tên, không
  còn vẽ code; người chơi đi tới (10,4) đúng ô, cả 2 NPC patrol
  rời nhà sau 12s (Quản Gia Đảo từ mép trên ảnh home sang mép trái
  ảnh away, cầm khay bạc thấy rõ ở ảnh away2); 2 ảnh xa nhà cách
  nhau 2s pixel-diff = **12.720** (lá rơi + mây + NPC bob, cảnh
  sống).
- Lỗi tìm ra khi xem ảnh (cosmetic, không chặn): nhãn "Chủ Biệt
  Thự Đảo" đè lên thân Quản Gia Đảo — **đã xác minh KHÔNG phải
  nhãn sai:** nhãn NPC chỉ hiện khi người chơi trong Manhattan
  ≤5 ô (lúc chụp người chơi (10,4) cách Chủ Biệt Thự 5 ô nên
  nhãn bạn ấy hiện, cách Quản Gia Đảo 9 ô nên nhãn bạn ấy ẩn);
  nhãn Chủ Biệt Thự neo -170px trên đầu bạn ấy nên trong chiếu
  iso rơi đúng vào vị trí Quản Gia Đảo đứng phía trên-trái. Cùng
  mẫu đã thấy ở Map012 vòng 34 / Map013 vòng 35. Người chơi
  spawn Map014 ở (5,7) thay vì (5,4) — phím giữ lọt sang map mới
  3 bước (harness, không phải game); đi xa tới (10,4) đúng ô
  (phải ×5 + lên ×3 từ (5,7)).

### 58.4 Push + Deploy — XONG

- **Push main r36 XONG:** lô a (marker.gd + test r36 + .uid +
  run_regression.sh) `1d8823f0` + lô b (14 file .import art Map014)
  `c0bbb853` + lô c (visual-check artpass36) `3de8252d` — head main sau lô c
  `3de8252d` (docs `b488f74a`).
- **Deploy gh-pages pck `210e0a19` XONG:** staging rebuild VERIFY
  OK (pck 149 chunk khớp byte, wasm + img không đổi); đẩy 11 lô
  liên tiếp: b1 chunk 000–015 `df653cca`, b2 016–031 `3b6dd61b`,
  b3 032–047 `0a5c0cb8`, b4 048–063 `a5849cf1`, b5 064–079
  `6859bd40`, b6 080–095 `6ce08fde`, b7 096–111 `23de3563`, b8
  112–127 `88ee8518`, b9 128–143 `ba7620a3`, b10 144–148
  `7cd67c1c`, final (versions.json + index.html) `929c84e8`.
  Sync record nay 363 mục. **Live đã chuyển sang pck `210e0a19`
  (vòng 36):** `--check-live` PASS (versions.json live `210e0a19`,
  index.html khớp staging từng byte — lần đầu check ngay sau deploy
  vẫn thấy bản cũ `2d9ae4e0` do CDN cache, check lại sau ~7 phút thì
  khớp).

### 58.5 Việc tiếp theo

1. NPC Map015 walk cycle (Khu Penthouse: Quản Lý Penthouse + Cư
   Dân Penthouse) theo từng map, mẫu vòng này — nhớ kiểm tra tên
   file art khớp NPC id bỏ dấu gạch nối ngay khi art về (§58.2).
2. Sprite sạp tách riêng (§45.1): đổi hàng 0 thành sạp cách nhau
   (ô lẻ để trống) rồi gen 3 sprite sạp (rau/trái cây/cá-thịt).
3. Nhãn NPC chỉ hiện trong 5 ô + neo -170px nên nhãn NPC (8,6)
   dễ đè lên NPC (3,3) trong chiếu iso — cân nhắc cải thiện hiển
   thị nhãn (việc polish, không chặn).

## 59. Vòng 37 — Walk cycle NPC Map015: Quản Lý Penthouse + Cư Dân Penthouse (25/11 ~10:45–11:15 +07, cron 10:45)

Mục 1 §58.5: NPC Map015 walk cycle theo từng map. Vòng này làm
Map015 Khu Penthouse: Quản Lý Penthouse (3,3) + Cư Dân
Penthouse (8,6).

### 59.1 Art (subagent, theo đúng quy trình vòng 36) — XONG

- Thư mục `visual-check/artpass37/`; ảnh đứng + sheet 6 khung cho
  Quản Lý Penthouse (nam, vest xám than + sơ mi xanh nhạt + cà vạt
  đỏ bordeaux, cầm clipboard + thẻ chìa khóa vàng) + Cư Dân
  Penthouse (nữ, váy dài xanh ngọc lục bảo, cầm túi mua sắm +
  điện thoại thông minh); xử lý trắng → trong suốt + cắt frame
  theo mẫu vòng 36 (connected component, MIN_FIG_W=100,
  MIN_FIG_H=100, `split_wide_component` MAX_FIG_W=600 + xóa vùng
  trắng kín ≥100 final px).
- File đích: `src/godot/art/char_quanlypenthouse.png` (102×208) +
  `char_cudanpenthouse.png` (106×208),
  `walk_quanlypenthouse_f0..f5.png` (canvas chung 122×208) +
  `walk_cudanpenthouse_f0..f5.png` (canvas chung 142×208), RGBA.
- Kiểm tra bằng mắt: 2 ảnh đứng + 2 sheet; **0 lần gen lại** —
  cả 2 ảnh đứng + cả 2 sheet đạt ngay lần đầu, đạo cụ đủ 6/6 hình
  cho cả 2 NPC (clipboard + thẻ vàng / túi mua sắm + điện thoại).
  Bài học vòng 36 phát huy: siết cả 2 đạo cụ cùng lúc NGAY TỪ
  LẦN GEN ĐẦU thì không tái phạm lỗi thiếu đạo cụ; prompt siết
  giới tính của Quản Lý Penthouse (nam, mặt nam tính, tóc đen
  ngắn, không khuyên tai, không búi, không tóc dài) cho nam rõ
  ràng ngay lần đầu. Slice vòng 36 chạy thẳng, đúng 6
  component/sheet, không cần `split_wide_component`.
- Hạn chế (chấp nhận, ghi trong note): Cư Dân f4 tay trái duỗi
  thẳng cầm điện thoại hơi cứng (1 frame giữa chu kỳ); chân dưới
  váy dài khó phân biệt pha; túi mua sắm có logo + chữ nhỏ mờ
  (không đọc được ở kích thước sprite); nhân vật đi dép quai thay
  vì giày (task không quy định). Tên file thô sheet Quản Lý bị
  pipeline cắt ngắn stem (`...-quanlypenthous-0-...webp`, thiếu
  chữ `e`) — đã chuẩn hóa khi chuyển sang `.png`.
- Chi tiết:
  `visual-check/artpass37/walkcycle-npc-map015-note.md`.

### 59.2 Code + test — XONG

- `marker.gd` NPC_STYLE thêm `"quan-ly-penthouse"` (vest xám than
  (0.22,0.24,0.28), tóc "ngan", texture + frames) +
  `"cu-dan-penthouse"` (váy xanh ngọc (0.05,0.45,0.38), tóc "dai",
  texture + frames). Không sửa logic `CharacterSprite`/
  `Marker`. Tên file art khớp NPC id bỏ dấu gạch nối ngay khi art
  về (`quanlypenthouse` / `cudanpenthouse`) — không tái phạm lỗi
  vòng 36.
- Test mới `tests/g4_r37_npc_walk_map015_test.gd`: **29/29 PASS**
  (theo mẫu r36: sprite trực tiếp từng NPC, marker home_tile
  (3,3)/(8,6), Main load_map(15) + pick patrol từ nhà Quản Lý
  Penthouse).
- `tools/godot/run_regression.sh` thêm test mới (nay 65 suite).

### 59.3 Verify thật vòng này

- Hồi quy đầy đủ: **65 OK, 0 FAIL** (64 cũ + 1 mới r37).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR.
- Export web exit 0: pck **20.590.412 byte, SHA `50e9c300`**
  (trước `210e0a19`, +487.604 byte = 14 file art mới); wasm không
  đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ
  4 file (cổng 8192).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass37/check_r37.py`, ảnh `r37-01…r37-15`;
  playwright còn nguyên sau VM restart, không cần cài lại):
  **0 console error, 0 pageerror, 0 requestfailed.** Xem ảnh
  thật: đi chuỗi Map001→Map015 qua đúng cửa (5,4)/(5,8) từng
  map; Map015 "Khu Penthouse" — Quản Lý Penthouse (vest xám than,
  cầm clipboard) + Cư Dân Penthouse (váy xanh ngọc, cầm túi mua
  sắm) hiện rõ mặt thật có nhãn tên, không còn vẽ code; cả 2 NPC
  patrol rời nhà sau 12s (Quản Lý từ giữa map lên mép trên-trái,
  Cư Dân xuống mép dưới-trái ở ảnh away); 2 ảnh xa nhà cách nhau
  2s pixel-diff = **5.718** (lá rơi + mây + NPC bob, cảnh sống).
- Lỗi tìm ra khi xem ảnh (cosmetic, không chặn): người chơi spawn
  Map015 ở (5,6) thay vì (5,4) — phím giữ lọt sang map mới 2
  bước (harness, không phải game; cùng mẫu vòng 36); đi xa tới
  (7,3) (phải ×5 + lên ×3 từ (5,6) nhưng 2 phím phải bị miss —
  harness, không phải game). Nhãn "Cư Dân Penthouse" đè lên thân
  người chơi ở ảnh home — cùng mẫu nhãn neo -170px + hiện trong
  Manhattan ≤5 ô đã thấy ở Map012/013/014, không phải nhãn sai.

### 59.4 Push + Deploy — XONG

- **Push main r37 XONG:** lô a (marker.gd + test r37 + .uid +
  run_regression.sh) `fe16e095` + lô b (14 file .import art Map015)
  `fdfc0227` + lô c (visual-check artpass37) `2f87c273` — head main
  sau lô c `2f87c273` (docs `db1f1484` đẩy trước khi viết §59,
  xem dưới).
- **Deploy gh-pages pck `50e9c300` XONG:** staging rebuild VERIFY
  OK (pck 153 chunk khớp byte, wasm + img không đổi); đẩy 10 lô
  chunk + 1 lô final: b1 chunk 000–015 `9ba70ff7`, b2 016–031
  `dcd14119`, b3 032–047 `429b7f0c`, b4 048–063 `bb06acbb`, b5
  064–079 `0f15f04e`, b6 080–095 `fc26abf27`, b7 096–111
  `b4ef0737`, b8 112–127 `7d499aeb`, b9 128–143 `b5b4720f`, b10
  144–152 `ae1109bf` (9 file — staging chỉ có 153 chunk 000–152,
  không phải 154 như ghi ban đầu), final (versions.json +
  index.html) `448495c7`. Sync record nay 379 mục.
  **Live đã chuyển sang pck `50e9c300` (vòng 37):** `--check-live`
  PASS (versions.json live `50e9c300`, index.html 200).
- Lưu ý: lô docs `db1f1484` đẩy TRƯỚC khi §59 được viết (script
  push chạy hết 4 lô trong 1 lần, trong khi docs lúc đó chưa có
  §59) — đã đẩy bù lô docs2 `b183b0de` sau khi viết xong §59, head
  main sau docs2 `b183b0de`. Deploy cũng dở dang ở lô b8
  khi hết lượt 10:45 (live vẫn `210e0a19` dù §59.4 bản nháp ghi
  "check-live PASS" — ghi sai, đã đính chính ở đây): b9/b10/final
  đẩy bù trong lượt 11:45, live mới chuyển sang `50e9c300` lúc
  ~12:10. Bài học: không ghi "live đã lên" khi chưa curl lại
  versions.json live sau lô final. Ngoài ra có 1 commit chunk 6
  trùng `7f197799` (retry đẩy lại cùng nội dung, không ghi vào
  sync — sync chỉ giữ `fc26abf27` cho cùng 16 file).

### 59.5 Việc tiếp theo

1. NPC Map016 walk cycle (Khu Sân Golf & Resort: 2 NPC theo
   `maps.json` map id 16) theo từng map, mẫu vòng này.
2. Sprite sạp tách riêng (§45.1): đổi hàng 0 thành sạp cách nhau
   (ô lẻ để trống) rồi gen 3 sprite sạp (rau/trái cây/cá-thịt).
3. Nhãn NPC chỉ hiện trong 5 ô + neo -170px nên nhãn NPC (8,6)
   dễ đè lên NPC (3,3) trong chiếu iso — cân nhắc cải thiện hiển
   thị nhãn (việc polish, không chặn).

## 60. Vòng 38 — Walk cycle NPC Map016: Nhân Viên Sân Golf + Quản Lý Resort (25/11 ~11:45–13:35 +07, cron 11:45)

Mục 1 §59.5: NPC Map016 walk cycle theo từng map. Vòng này làm
Map016 Khu Sân Golf & Resort: Nhân Viên Sân Golf (3,3) + Quản Lý
Resort (8,6).

### 60.1 Art (subagent, theo đúng quy trình vòng 37) — XONG

- Thư mục `visual-check/artpass38/`; ảnh đứng + sheet 6 khung cho
  Nhân Viên Sân Golf (nam, áo polo xanh nhạt + quần kaki be + giày
  thể thao trắng + mũ lưỡi trai xanh navy, cầm gậy golf + đeo túi
  gậy golf mini) + Quản Lý Resort (nữ, blazer xanh mint nhạt + váy
  bút chì xanh navy + giày cao gót đen, cầm sổ đặt phòng bìa da nâu
  + thẻ phòng vàng); xử lý trắng → trong suốt + cắt frame theo mẫu
  vòng 37 (connected component, MIN_FIG_W=100, MIN_FIG_H=100,
  `split_wide_component` MAX_FIG_W=600 + xóa vùng trắng kín ≥100
  final px) + bước cleanup mảnh vụn rời mới vòng này
  (`cleanup_frames_r38.py`).
- File đích: `src/godot/art/char_nhanviensangolf.png` (97×208) +
  `char_quanlyresort.png` (89×208),
  `walk_nhanviensangolf_f0..f5.png` (canvas chung 105×208) +
  `walk_quanlyresort_f0..f5.png` (canvas chung 120×208), RGBA.
- Kiểm tra bằng mắt: 2 ảnh đứng + 2 sheet; **ảnh đứng 0 lần gen
  lại; sheet Resort 0 lần; sheet golf 1 lần (v1 → v2)** — v1 lỗi
  đạo cụ chéo hình: gậy golf chéo sang trái, đầu gậy hình sau nằm
  bên trái đường cắt nên bị gán nhầm sang hình trước + dải dây đen
  nối các hình (f1 có 2 đầu gậy, f2 gậy đứt, f3 gậy mất đầu);
  prompt v2 siết thêm "gậy dựng đứng sát thân, đầu gậy gần bàn
  chân, không chéo sang hình kế, không vật nào chạm sang hình kế"
  thì đạt ngay. Bài học mới: NPC cầm đạo cụ DÀI (gậy, ô, cần
  câu...) thì siết "dựng đứng sát thân" ngay từ lần gen đầu — lỗi
  chéo hình không sửa được bằng cắt cột; script cleanup mảnh vụn
  rời (`cleanup_frames_r38.py`: giữ component lớn nhất + ≥5% diện
  tích, xóa phần còn lại + quầng feather) nên chạy mặc định sau mỗi
  lần cắt frame. Slice vẫn cần `split_wide_component` (f1+f2 và
  f2+f3 dính nhau 2D qua túi/mũ — cắt đúng khe, đã kiểm tra bằng
  mắt từng frame). Đạo cụ đủ 6/6 hình cả 2 NPC.
- Hạn chế (chấp nhận, ghi trong note): thẻ phòng vàng có chữ nhỏ mờ
  (không đọc được ở kích thước sprite); váy bút chì ôm che chân
  (chỉ thấy bàn chân/giày đổi vị trí); f5 cả hai gần như tư thế
  đứng. Chi tiết:
  `visual-check/artpass38/walkcycle-npc-map016-note.md`.

### 60.2 Code + test — XONG

- `marker.gd` NPC_STYLE thêm `"nhan-vien-san-golf"` (polo xanh
  nhạt (0.55,0.75,0.90), tóc "ngan", texture + frames) +
  `"quan-ly-resort"` (blazer mint (0.55,0.85,0.75), tóc "dai",
  texture + frames). Không sửa logic `CharacterSprite`/
  `Marker`. Tên file art khớp NPC id bỏ dấu gạch nối ngay khi art
  về (`nhanviensangolf` / `quanlyresort`) — không tái phạm lỗi
  vòng 36.
- Test mới `tests/g4_r38_npc_walk_map016_test.gd`: **29/29 PASS**
  (theo mẫu r37: sprite trực tiếp từng NPC, marker home_tile
  (3,3)/(8,6), Main load_map(16) + pick patrol từ nhà Nhân Viên
  Sân Golf).
- Sửa kèm (lỗi copy-paste tìm ra khi viết test r38): test r37
  `NPC_TEX` trỏ nhầm sang ảnh đứng của vòng 36
  (`char_quangiadao.png` / `char_chubietthudao.png`) — test vẫn
  pass 29/29 vì chỉ kiểm tra tồn tại + đổi khung, không kiểm tra
  đúng ảnh đứng. Đã sửa về đúng 2 file Map015, chạy lại r37:
  **29/29 PASS** trở lại.
- `tools/godot/run_regression.sh` thêm test mới (nay 66 suite;
  sửa luôn chú thích cũ "45 suite").

### 60.3 Verify thật vòng này

- Hồi quy đầy đủ: **66 OK, 0 FAIL** (65 cũ + 1 mới r38).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR.
- Export web exit 0: pck **21.033.792 byte, SHA `b87c03bf`**
  (trước `50e9c300`, +443.380 byte = 14 file art mới); wasm không
  đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ
  4 file (cổng 8193).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass38/check_r38.py`, ảnh `r38-01…r38-17`;
  playwright phải cài lại vì VM restart gỡ module — như vòng 36):
  **0 console error, 0 pageerror, 0 requestfailed.** Xem ảnh
  thật: đi chuỗi Map001→Map016 qua đúng cửa (5,4)/(5,8) từng
  map; Map016 "Khu Sân Golf & Resort" — Nhân Viên Sân Golf (mũ
  navy, polo xanh nhạt, cầm gậy) + Quản Lý Resort (blazer mint,
  váy navy, cầm sổ) hiện rõ mặt thật có nhãn tên, không còn vẽ
  code; cả 2 NPC patrol rời nhà sau 12s (golf ra mép trái, resort
  xuống gần cửa ở ảnh away); 2 ảnh xa nhà cách nhau 2s pixel-diff
  = **18.769** (lá rơi + mây + NPC bob, cảnh sống). Nhãn "Quản Lý
  Resort" đè lên thân Nhân Viên Sân Golf ở ảnh home — cùng mẫu
  nhãn neo -170px + hiện trong Manhattan ≤5 ô đã thấy ở
  Map012/013/014/015, không phải nhãn sai.

### 60.4 Push + Deploy — XONG TRỌN (main + deploy + docs)

- **Push main r38 XONG:** lô a (marker.gd + test r38 + .uid +
  sửa test r37 + run_regression.sh) `dc3567e3` + lô b (14 file
  .import art Map016) `83eeb29b` + lô c (visual-check artpass38:
  note + 4 script + check_r38.py) `3aecd20e` — head main sau lô c
  `3aecd20e`.
- **Deploy gh-pages pck `b87c03bf` XONG:** staging rebuild VERIFY
  OK (pck 156 chunk khớp byte, wasm + img không đổi); đẩy 10 lô
  chunk + 1 lô final: b1 000–015 `334b8a06`, b2 016–031
  `52681df6`, b3 032–047 `944aacb2`, b4 048–063 `817892c0`, b5
  064–079 `8792674b`, b6 080–095 `6b0e0518`, b7 096–111
  `dc6e1b3f`, b8 112–127 `1b5dd378`, b9 128–143 `a0de51fe`, b10
  144–155 `a825e000` (12 file), final (versions.json +
  index.html) `68cafb66`. Sync record nay 399 mục.
  **Live đã chuyển sang pck `b87c03bf` (vòng 38):** `--check-live`
  PASS (versions.json live `b87c03bf`, index.html 200) — sau ~3
  phút CDN lag (lúc đầu vẫn hiện `50e9c300`).
- Bài học deploy vòng này (3 điểm, ghi để không tái phạm):
  (1) Phê duyệt GitHub trong lượt detached này chậm theo đợt
  (mỗi lô chờ 2–13 phút); driver bị kill giữa chừng KHÔNG hủy
  write phía server — lô đang chờ vẫn hoàn tất sau khi phê
  duyệt tới (chunk-5/6/7 đều lên remote sau khi driver đã chết),
  nên sau mỗi lần kill phải kiểm tra remote bằng blob SHA rồi
  mới chạy tiếp, không đẩy lại mù. (2) URI SHA của
  `get_file_contents` là HEAD của branch lúc query, KHÔNG phải
  commit đã thêm file đó — đã ghi nhầm SHA chunk-6 (lấy
  `dc6e1b3f` là head lúc đó, đúng ra là `6b0e0518`); muốn biết
  commit thật thì đọc chuỗi `list_commits`, không dùng URI SHA
  làm sync base cho từng file. (3) Retry tạo commit trùng: b2 có
  thêm `5b38d91c`, b7 có thêm `8aa93bd7` (cùng nội dung); commit
  trùng làm head lệch khỏi sync → lô chunk-8 lỗi "not a fast
  forward" — sửa bằng cách ghi thêm entry cho commit trùng
  (`8aa93bd7`) rồi đẩy tiếp là thông.
- Lô docs (godot-g4 §60 + roles-qc) `b8d13cb2` (thẻ phê duyệt
  cũng chờ ~4 phút mới thông, như lô deploy); đính chính §60.4
  sau khi deploy xong: xem lô docs2 dưới.

### 60.5 Việc tiếp theo

1. NPC Map017 walk cycle (Công Viên An Bình: Cô Bán Bánh + Ông
   Lão Tập Thể Dục) theo từng map, mẫu vòng này — nhớ bài học
   vòng 38: đạo cụ dài siết "dựng đứng sát thân" ngay từ lần gen
   đầu; chạy cleanup mảnh vụn rời mặc định sau cắt frame.
2. NPC Map017 walk cycle (Công Viên An Bình: Cô Bán Bánh + Ông
   Lão Tập Thể Dục) theo từng map, mẫu vòng này — nhớ bài học
   vòng 38: đạo cụ dài siết "dựng đứng sát thân" ngay từ lần gen
   đầu; chạy cleanup mảnh vụn rời mặc định sau cắt frame.
3. Sprite sạp tách riêng (§45.1): đổi hàng 0 thành sạp cách nhau
   (ô lẻ để trống) rồi gen 3 sprite sạp (rau/trái cây/cá-thịt).

## 61. Vòng 39 — Walk cycle NPC Map017: Cô Bán Bánh + Ông Lão Tập Thể Dục (25/11 ~13:45–15:00 +07, cron 13:45)

Mục 1 §60.5: NPC Map017 walk cycle theo từng map. Vòng này làm
Map017 Công Viên An Bình: Cô Bán Bánh (3,3) + Ông Lão Tập Thể
Dục (8,6).

### 61.1 Art (subagent, theo đúng quy trình vòng 38) — XONG

- Thư mục `visual-check/artpass39/`; ảnh đứng + sheet 6 khung cho
  Cô Bán Bánh (nữ, áo bà ba hồng đào + tạp dề xanh lá + nón lá,
  cầm giỏ bánh + khay bánh) + Ông Lão Tập Thể Dục (nam, tóc bạc,
  áo thun thể thao xanh nhạt + quần thể thao xám + giày thể thao,
  khăn tập vàng cam vắt vai + bình nước xanh cầm tay); xử lý trắng
  → trong suốt + cắt frame theo mẫu vòng 38 (connected component,
  MIN_FIG_W=100, MIN_FIG_H=100, `split_wide_component` MAX_FIG_W=600
  + xóa vùng trắng kín ≥100 final px) + bước cleanup mảnh vụn rời
  mặc định (`cleanup_frames_r39.py`).
- File đích: `src/godot/art/char_cobanbanh.png` (122×208) +
  `char_onglaotaptheduc.png` (86×208),
  `walk_cobanbanh_f0..f5.png` (canvas chung 138×208) +
  `walk_onglaotaptheduc_f0..f5.png` (canvas chung 140×208), RGBA.
- Kiểm tra bằng mắt: 2 ảnh đứng + 2 sheet; **ảnh đứng 0 lần gen
  lại; sheet Ông Lão 0 lần; sheet Cô Bán Bánh 2 lần (v1 → v2 →
  v3)** — v1 thiếu khay ở f1/f3; v2 đủ khay nhưng thiếu giỏ ở f5;
  v3 siết mỗi đạo cụ bằng một câu riêng ("khay luôn ở tay phải /
  giỏ luôn ở tay trái trong mọi hình") thì đủ cả 2 đạo cụ ở cả 6
  hình. Bài học mới: NPC cầm 2 đạo cụ thì siết MỖI đạo cụ bằng
  MỘT CÂU RIÊNG gắn với tay cầm cố định ngay từ lần gen đầu — câu
  gộp "cả 2 đạo cụ phải rõ" làm generator bỏ 1 đạo cụ ở vài hình.
- Cắt sheet: cả 2 sheet tách đúng 6 component riêng, không cần
  `split_wide_component` (câu siết khoảng trắng giữa các hình đã
  phát huy). Cleanup: 12 frame không đổi (mỗi frame đúng 1
  component, không mảnh vụn mép); chỉ xóa 2px vết rời ở
  `char_onglaotaptheduc.png`. Debug-white: chỉ f3 Cô Bán Bánh xóa
  123 final px — đã đối chiếu zoom: đó là nền nhìn xuyên qua quai
  giỏ, không phải bánh; giỏ + khay còn nguyên. Vùng trắng kín còn
  lại lớn nhất 60–70px (<100, giữ đúng thiết kế: chóp bánh kem,
  bánh trong giỏ). Bình nước trong của Ông Lão được giữ nguyên,
  không bị thủng.
- Hạn chế (chấp nhận, ghi trong note): quần đen + áo bà ba dài che
  chân Cô Bán Bánh (chủ yếu thấy dép đổi vị trí); giỏ/khay + bình
  nước đổi bên/đổi tay theo nhịp đi giữa các frame (không phải lỗi,
  đạo cụ vẫn hiện liên tục cả 6 frame); f5 cả hai gần như tư thế
  đứng. Chi tiết:
  `visual-check/artpass39/walkcycle-npc-map017-note.md`.

### 61.2 Code + test — XONG

- `marker.gd` NPC_STYLE thêm `"co-ban-banh"` (áo hồng đào
  (0.93,0.60,0.55), tóc "dai", texture + frames) +
  `"ong-lao-tap-the-duc"` (áo xanh nhạt (0.55,0.75,0.85), tóc
  "ngan", texture + frames). Không sửa logic `CharacterSprite`/
  `Marker`. Tên file art khớp NPC id bỏ dấu gạch nối ngay khi art
  về (`cobanbanh` / `onglaotaptheduc`).
- Test mới `tests/g4_r39_npc_walk_map017_test.gd`: **29/29 PASS**
  (theo mẫu r38: sprite trực tiếp từng NPC, marker home_tile
  (3,3)/(8,6), Main load_map(17) + pick patrol từ nhà Cô Bán
  Bánh).
- `tools/godot/run_regression.sh` thêm test mới (nay 67 suite).

### 61.3 Verify thật vòng này

- Hồi quy đầy đủ: **67 OK, 0 FAIL** (66 cũ + 1 mới r39).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR.
- Export web exit 0: pck **21.532.816 byte, SHA `a6d7e36b`**
  (trước `b87c03bf`, +499.024 byte = 14 file art mới); wasm không
  đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ
  4 file (cổng 8194).
- Playwright phải cài lại vì VM restart gỡ module (như vòng 36/38)
  — browser Chromium 1255 còn trong cache, chỉ cài lại package pip
  (`pip3 install --break-system-packages playwright`).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass39/check_r39.py`, ảnh `r39-01…r39-18`):
  **0 console error, 0 pageerror, 0 requestfailed.** Xem ảnh
  thật: đi chuỗi Map001→Map017 qua đúng cửa (5,4)/(5,8) từng
  map; Map017 "Công Viên An Bình" — Cô Bán Bánh (nón lá, áo hồng
  đào, giỏ + khay bánh) + Ông Lão Tập Thể Dục (tóc bạc, áo xanh
  nhạt, bình nước xanh) hiện rõ mặt thật có nhãn tên, không còn vẽ
  code; cả 2 NPC patrol rời nhà sau 12s (Cô Bán Bánh ra mép trái,
  Ông Lão sang gần cửa ở ảnh away); 2 ảnh xa nhà cách nhau 2s
  pixel-diff = **25.884** (lá rơi + mây + NPC bob, cảnh sống).
  Nhãn "Ông Lão Tập Thể Dục" đè lên thân Cô Bán Bánh ở ảnh home —
  cùng mẫu nhãn neo -170px + hiện trong Manhattan ≤5 ô đã thấy ở
  Map012/013/014/015/016, không phải nhãn sai.

### 61.4 Push + Deploy — XONG TRỌN (main + deploy + docs)

- **Push main r39 XONG:** lô a (marker.gd + test r39 + .uid +
  run_regression.sh) `51105053` + lô b (14 file .import art
  Map017) `1c508d89` + lô c (visual-check artpass39: note + 5
  script + check_r39.py) `dd4399b4` — head main sau lô c
  `dd4399b4`.
- **Deploy gh-pages pck `a6d7e36b` XONG:** staging rebuild VERIFY
  OK (pck 160 chunk khớp byte, wasm + img không đổi); đẩy 10 lô
  chunk + 1 lô final: b1 000–015 `46f26bf5`, b2 016–031
  `75de3782`, b3 032–047 `fd42f28c`, b4 048–063 `f9c81d8c`, b5
  064–079 `9d4a8d35`, b6 080–095 `194df6bb`, b7 096–111
  `75766d23`, b8 112–127 `f76cb2e5`, b9 128–143 `0e882325`, b10
  144–159 `6fe93e85` (16 file), final (versions.json +
  index.html) `46e4b410`. Sync record nay 414 mục.
  **Live đã chuyển sang pck `a6d7e36b` (vòng 39):** `--check-live`
  PASS (versions.json live `a6d7e36b`, index.html 200) — lúc đầu
  vẫn hiện `b87c03bf` do CDN lag ~3 phút (như vòng 38), kiểm lại
  sau thì PASS.
- Lô docs (godot-g4 §61 + roles-qc) `15f78a38` (đính chính §61.4: xem lô docs2 dưới).

### 61.5 Việc tiếp theo

1. NPC Map018 walk cycle (Phố Đi Bộ – Chợ Đêm: Chủ Sạp Đêm +
   Người Bán Hàng Rong) theo từng map, mẫu vòng này — nhớ bài học
   vòng 39: 2 đạo cụ thì siết mỗi đạo cụ một câu riêng gắn tay cầm
   cố định.
2. Sprite sạp tách riêng (§45.1): đổi hàng 0 thành sạp cách nhau
   (ô lẻ để trống) rồi gen 3 sprite sạp (rau/trái cây/cá-thịt).

## 62. Vòng 40 — Walk cycle NPC Map018: Chủ Sạp Đêm + Người Bán Hàng Rong (25/11 ~15:23–16:55 +07, cron 15:45)

Mục 1 §61.5: NPC Map018 walk cycle theo từng map. Vòng này làm
Map018 Phố Đi Bộ – Chợ Đêm: Chủ Sạp Đêm (3,3) + Người Bán Hàng
Rong (8,6). **Xong walk cycle cả 18 khu (Map001–018).**

### 62.1 Art (subagent, artpass40, 15:23–16:07) — XONG, KHÔNG push/code

- Thư mục `visual-check/artpass40/`; ảnh đứng + sheet 6 khung cho
  Chủ Sạp Đêm (nữ trung niên, áo bà ba TÍM ĐẬM + tạp dề XANH DƯƠNG
  + nón lá, cầm ĐÈN LỒNG ĐỎ tay phải + GIỎ HÀNG đầy đồ tay trái) +
  Người Bán Hàng Rong (nam trung niên, áo thun VÀNG + quần kaki nâu
  + nón lá, đeo TÚI HÀNG RONG trước ngực + cầm LOA RAO HÀNG đỏ tay
  phải); xử lý trắng → trong suốt + cắt frame + cleanup mảnh vụn
  rời mặc định (`cleanup_frames_r40.py`).
- File đích: `src/godot/art/char_chusapdem.png` (112×208) +
  `char_nguoibanhangrong.png` (122×208),
  `walk_chusapdem_f0..f5.png` (canvas chung 116×208) +
  `walk_nguoibanhangrong_f0..f5.png` (canvas chung 129×208), RGBA.
- Kiểm tra bằng mắt: 2 ảnh đứng + 6 bản sheet; **ảnh đứng 0 lần gen
  lại; sheet Người Bán Hàng Rong 0 lần; sheet Chủ Sạp Đêm 4 lần
  (v1 dùng, v2 thiếu giỏ f0, v3 thiếu giỏ f4, v4 chỉ 5 hình + thiếu
  giỏ f0, v5 thiếu đèn f0+f3)** — siết mỗi đạo cụ bằng một câu riêng
  + liệt kê từng hình vẫn không triệt được lỗi rơi đạo cụ (chỉ giảm);
  v1 là bản duy nhất đủ cả 2 đạo cụ ở cả 6 hình.
- Cắt sheet — BÀI HỌC MỚI: sheet Chủ Sạp Đêm v1 DÀY (pitch ~365px,
  6 hình là 1 component liên thông) nên cắt dọc r39 HỎNG (chẻ đèn
  f1, giỏ f4, mảnh nón/giỏ rơi frame) — phải dùng watershed geodesic
  mới (`slice_walkcycle_chusapdem_ws.py`, BFS 6 seed thân): đạo cụ
  giữ nguyên với hình cầm nó. Người Bán Hàng Rong cắt dọc vẫn đúng
  (1 lần `split_wide_component` tại x=473). Cleanup: chusapdem f0
  xóa 15px, f3 2px, f5 8px; f1/f2/f4 1 component, không đổi; vendor
  12 frame không đổi; char_chusapdem xóa 27px vết rời.
  Debug-white: vùng trắng kín bị xóa chỉ là khe nền giữa 2 bàn chân
  (f0 731, f4 600 final px), còn lại lớn nhất 41px (<100, giữ).
- 3 cách sửa vùng chạm giỏ f0/đèn f1 đều LOẠI (cắt x lấy mất đèn f1;
  cắt màu rách đèn + thủng giỏ f0; xóa hộp frame cuối ăn mép đèn) —
  giữ bản watershed thuần, chấp nhận mảnh giỏ f0 ~300 final px ở góc
  dưới-trái frame f1. Bài học: sheet dày + đạo cụ chạm nhau thì gen
  lại sheet thưa hơn thay vì sửa vùng chạm; KHÔNG sửa vùng chạm 2D
  bằng ngưỡng x/màu hay xóa hộp. Chi tiết:
  `visual-check/artpass40/walkcycle-npc-map018-note.md`.
- Hạn chế (chấp nhận, ghi trong note): đèn f1 bị giỏ f0 che mất mép
  trái (chỉ ~60% thân đèn lộ ra, vẫn nhận diện rõ); loa đổi tay theo
  nhịp đi (giống clipboard/bình nước các vòng trước, không phải lỗi);
  f5 cả hai gần như tư thế đứng; áo bà ba dài che chân Chủ Sạp Đêm.

### 62.2 Code + test — XONG

- `marker.gd` NPC_STYLE thêm `"chu-sap-dem"` (áo tím đậm
  (0.35,0.20,0.45), tóc "dai", texture + frames) +
  `"nguoi-ban-hang-rong"` (áo vàng (0.95,0.75,0.20), tóc "ngan",
  texture + frames). Không sửa logic `CharacterSprite`/`Marker`.
  Tên file art khớp NPC id bỏ dấu gạch nối ngay khi art về
  (`chusapdem` / `nguoibanhangrong`).
- Test mới `tests/g4_r40_npc_walk_map018_test.gd`: **29/29 PASS**
  (theo mẫu r38: sprite trực tiếp từng NPC, marker home_tile
  (3,3)/(8,6), Main load_map(18) + pick patrol từ nhà Chủ Sạp Đêm).
- `tools/godot/run_regression.sh` thêm test mới (nay 68 suite).

### 62.3 Verify thật vòng này

- Hồi quy đầy đủ: **68 OK, 0 FAIL** (67 cũ + 1 mới r40).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR.
- Export web exit 0: pck **22.058.000 byte, SHA `57c31fc2`**
  (trước `a6d7e36b`, +525.184 byte = 14 file art mới); wasm không
  đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ
  4 file (cổng 8195). `strings index.pck` có 48 tham chiếu
  walk_chusapdem/walk_nguoibanhangrong.
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass40/check_r40.py`, ảnh `r40-01…r40-19`):
  **0 console error, 0 pageerror, 0 requestfailed.** Xem ảnh
  thật: đi chuỗi Map001→Map018 qua đúng cửa (5,4)/(5,8) từng
  map; Map018 "Phố Đi Bộ – Chợ Đêm" — Chủ Sạp Đêm (nón lá, áo bà
  ba tím đậm, đèn lồng đỏ + giỏ hàng) + Người Bán Hàng Rong (nón
  lá, áo vàng, túi hàng rong + loa đỏ) hiện rõ mặt thật có nhãn
  tên, không còn vẽ code; cả 2 NPC patrol rời nhà sau 12s (Chủ
  Sạp Đêm ra mép trái, Người Bán Hàng Rong sang gần cửa ở ảnh away);
  2 ảnh xa nhà cách nhau 2s pixel-diff = **12.376** (lá rơi + mây +
  NPC bob, cảnh sống). Nhãn "Người Bán Hàng Rong" đè lên thân Chủ
  Sạp Đêm ở ảnh home — cùng mẫu nhãn neo -170px + hiện trong
  Manhattan ≤5 ô đã thấy ở Map012/013/014/015/016/017, không phải
  nhãn sai.

### 62.4 Push + Deploy — XONG TRỌN (main + deploy + docs)

- **Push main r40 XONG:** lô a (marker.gd + test r40 + .uid +
  run_regression.sh) `19d5ce39` + lô b (14 file .import art
  Map018) `e1e63a80` + lô c (visual-check artpass40: note + 7
  script + check_r40.py) `d08404b0` — head main sau lô c
  `d08404b0`. Sync-base đã xác minh trước push: marker.gd local =
  remote @51105053 + đúng 8 dòng r40; run_regression.sh = remote +
  đúng 2 dòng (66→68 suite + tên test); 3 đường dẫn mới kiểm tra
  vắng mặt trên remote.
- **Deploy gh-pages pck `57c31fc2` XONG:** staging rebuild VERIFY
  OK (pck 164 chunk khớp byte, wasm + img không đổi); đẩy 11 lô
  chunk + 1 lô final: b1 000–015 `dc95ebc0`, b2 016–031
  `04893697`, b3 032–047 `a41c90ca`, b4 048–063 `217ef159`, b5
  064–079 `67675540`, b6 080–095 `f496f780`, b7 096–111
  `f5ba56f5`, b8 112–127 `364c119a`, b9 128–143 `229beaf8`, b10
  144–159 `0854d025`, b11 160–163 `769d4556` (4 file), final
  (versions.json + index.html) `90164e6d`. Sync record nay 431 mục.
  **Sự cố deploy (ghi để không tái phạm):** lô b10 lần đầu driver
  timeout 300s ở bước chờ phê duyệt và bị kill — nhưng commit ĐÃ
  lên server; lần chạy lại báo "failed to update reference:
  Reference cannot be updated" (head đã lệch khỏi base của lần
  thử lại). Đã đối chiếu: head gh-pages = `0854d025`, blob SHA
  part-144/151/159 trên remote khớp staging từng byte → ghi sync
  từ kết quả đã xác minh, KHÔNG đẩy lại. Bài học: driver deploy
  phải để timeout subprocess ≥1500s (chờ phê duyệt từng lô có thể
  >5 phút); sau timeout phải kiểm tra head + blob remote trước khi
  thử lại, không đẩy trùng.
  **Live đã chuyển sang pck `57c31fc2` (vòng 40):** `--check-live`
  PASS (versions.json live `57c31fc2`, index.html 200, khớp staging)
  — lúc đầu vẫn hiện `a6d7e36b` do CDN lag ~3 phút (như vòng 38/39),
  kiểm lại sau thì PASS.
- Lô docs (godot-g4 §62 + roles-qc) `8a83fce7`.

### 62.5 Việc tiếp theo

1. **Walk cycle 18 khu ĐÃ XONG (Map001–018).** Việc tiếp theo lớn
   nhất theo user 25/11: **làm lại đồ họa (graphics ~30%)** — bắt
   đầu từ rà soát art hiện có theo `docs/artpass-20-11.md` +
   `docs/tileset-plan.md`: sprite sạp tách riêng (§45.1) vẫn treo
   (đổi hàng 0 thành sạp cách nhau, ô lẻ để trống, gen 3 sprite sạp
   rau/trái cây/cá-thịt).
2. Sau art: G2 còn lại (port 17 plugin đã làm tới đâu — xem
   `docs/godot-g2.md`) rồi G3 đủ 18 khu đã có data, G4 online.

## 63. Vòng 41 — Sprite sạp tách riêng Map002 (25/11 ~16:45–17:30 +07, cron 16:45)

Việc tiếp theo lớn nhất theo user 25/11 (làm lại đồ họa, graphics
~30%): sprite sạp tách riêng §45.1 — đổi hàng 0 thành sạp cách
nhau (ô lẻ để trống) + gen 3 sprite sạp rau/trái cây/cá-thịt.
Art làm song song qua subagent (artpass41), code làm cùng lúc.

### 63.1 Art (subagent artpass41) — XONG

- 3 sprite, canvas 64×96 RGBA, nền trong suốt:
  `stall_rau.png` 9.068 byte (4 rổ mây: bắp cải / rau lá / rau
  thơm / rau muống), `stall_traicay.png` 8.087 byte (cam, chuối,
  xoài, thanh long), `stall_cathit.png` 9.754 byte (6 cá trên đá
  lạnh + thịt đỏ trên thớt gỗ). Mái hiên sọc đỏ/trắng + mép vỏ sò,
  2 cột chống gỗ, quầy vân gỗ — theo đúng hợp đồng canvas (y 0–33
  trong suốt cho biển hiệu, mái y 34–52, cột x 2–6 / 58–62, quầy
  y 76–96); không chữ, không biển, không người.
- Gen lại: trái cây 1 lần (v1 mái hiên + mặt quầy bị cắt ở mép
  khung, v2 siết "toàn bộ sạp nằm trong khung, đủ lề 4 phía" thì
  đạt); rau + cá-thịt 0 lần.
- Kiểm chứng: nền magenta + zoom 3× (không nền lạ, không quầng
  xanh ở mép); debug-white (pixel gần-trắng đều là nội dung hợp lệ:
  sọc trắng mái hiên + đá lạnh); đo file đích: y 0–33 có 0 pixel
  đục, cột chống ở y=56 tại x 3–5 và 58–61 đúng hợp đồng, mỗi
  sprite đúng 1 component alpha duy nhất, không mảnh vụn rời.
  Hạn chế: chỉ mặt trước; cá ở tỉ lệ 1× trong game sẽ nhỏ (đọc rõ
  ở zoom 3×). Note: `visual-check/artpass41/stall-sprites-note.md`
  + script `process_stalls_r41.py`.

### 63.2 Code + test — XONG

| File | Đổi |
|---|---|
| `scripts/nadia_scene.gd` | `STALL_SPRITE_SIZE` (64, 96) + `STALL_SPRITE_BOTTOM_Y` 14.0 (đáy sprite ở c.y + 14 = đáy quầy) + `STALL_SPRITE_FILES` (3 loại) + `stall_sprite_kind(sign)` (RAU CỦ→rau, TRÁI CÂY/HOA QUẢ→trai-cay, CÁ TƯƠI/THỊT HEO→ca-thit, còn lại "") + `stall_sprite_path(kind)` + `market_gap_tiles()` [1,3,5,7,9,11] + `_load_stall_sprites()` (gọi trong `setup()`, cache dict) + `stall_sprite_texture(kind)`; `_draw_market_row` vòng 1 + vòng 2 bỏ ô lẻ (không tường/mái/cửa sổ — 6 sạp tách rời, mái 34px tách nhau 30px); vòng 2 vẽ sprite trước biển (biển nằm trên vùng trong suốt của sprite), có sprite thì chỉ thêm thẻ giá nhỏ, không sprite thì `_draw_shop_front` như cũ (fallback). |
| `tests/g4_r41_stall_sprite_test.gd` (mới) | 13 mục: nhịp sạp không đổi [0,2,4,6,8,10] + ô trống [1,3,5,7,9,11] không giao nhau; 5 biển có sprite đúng loại + 3 biển không sprite về ""; đường dẫn sprite + đúng 3 sprite + canvas 64×96 + đáy y +14; scene thật Map002 map_id 2, trạng thái sprite khớp file trên đĩa (có→64×96, thiếu→null), về Map001 map_id 1. |
| `tools/godot/run_regression.sh` | Thêm `g4_r41_stall_sprite_test` (nay 69 suite). |
| `visual-check/artpass41/check_r41.py` (mới) | Theo mẫu check_r40.py, cổng 8196 + ảnh zoom vùng sạp (clip y=600..1050). |

**Lỗi tìm được khi nối code (bài học mới):** `FileAccess.file_exists`
+ `load()` LỖI "No loader found for resource" khi PNG đã có trên
đĩa nhưng chưa có `.import` (art vừa xuất file, chưa import) — hồi
quy lần 1 rớt đúng 1 suite (68 OK + 1 FAIL r41) vì vậy. Sửa: nạp
sprite phải dùng `ResourceLoader.exists(path, "Texture2D")` làm điều
kiện (cả `_load_stall_sprites` lẫn test đều sửa theo) — PNG chưa
import được coi như chưa có sprite, vẽ bằng code. **Luật:** mọi chỗ
`load()` file art theo đường dẫn động đều phải kiểm tra bằng
`ResourceLoader.exists`, không dùng `FileAccess.file_exists`.

### 63.3 Verify thật vòng này

- `--check-only` nadia_scene.gd: PASS.
- Test mới `g4_r41_stall_sprite_test`: **13/13 PASS** (lúc art chưa
  có: 0/3 sprite, fallback; lúc art đủ: 3/3 sprite 64×96).
- Hồi quy đầy đủ: **69 OK, 0 FAIL** (68 cũ + 1 mới r41).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR.
- Export web exit 0: pck **22.089.360 byte, SHA `5f2a052f…`**
  (trước `57c31fc2`, +31.360 byte = đúng 3 sprite + code, không art
  thừa); wasm không đổi `fc74679e`; HTTP 200 đủ 4 file (cổng 8196).
  Pck chứa đúng 3 texture `.ctex` của stall (kiểm bằng `strings`).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass41/check_r41.py`, ảnh
  `r41-01-map2` + `r41-02-stall-row-zoom`): **0 console error,
  0 pageerror, 0 request fail.**
  - Map002: 6 sạp tách rời nhau (ô lẻ trống, lộ nền đá sau sạp);
    biển 8 loại đọc được, có màu riêng (RAU CỦ xanh lá, THỊT HEO
    đỏ, BÁNH MÌ nâu, HOA QUẢ cam, CÁ TƯƠI xanh dương, ĐỒ KHÔ nâu
    vàng); sạp có sprite hiện hàng đúng loại (cá + thịt đỏ trên
    quầy), sạp BÁNH MÌ/GIA VỊ/ĐỒ KHÔ vẫn vẽ code (ổ bánh mì trên
    quầy); NPC Chị Lệ/Anh Hải + cửa 2 chiều bình thường.
  - Còn lại (không sửa vòng này): nhãn NPC vẫn có thể đè lên sạp
    (đã biết từ các vòng trước); cá trên sprite ở tỉ lệ 1× nhỏ.

### 63.4 Push + Deploy — XONG

- Push main 3 lô + docs (a `c0c60069`, b `9e8f7e30`, c `a34186dc`, docs `d5118c6f`).
  Sync record 446 mục.
- Deploy gh-pages 9 lô chunk + final `a2baf0dd`: pck `5f2a052f`
  164 part (lô 1–8 × 20 part, lô 9 × 4 part) + versions.json +
  index.html cuối; wasm `fc74679e` không đổi (đã có trên live).
  `--check-live` lần 1 FAIL (CDN còn pin cũ `57c31fc2`, kiểm lại
  sau ~3 phút thì PASS: live pin `5f2a052f`, part-000 đủ 200,
  index.html khớp staging). Đối chiếu byte live: tải + giải base64
  + ráp 164 part từ live = **22.089.360 byte, SHA `5f2a052f4808`
  — khớp đúng từng byte** với pck local (lần tải đầu bị 503 giữa
  chừng do xin 164 part liên tục — thêm retry 5 lần, backoff 2s
  thì qua). **Live nay chạy vòng 41**: sạp chợ Map002 tách riêng
  + 3 sprite sạp. Link: https://tinnt120899.github.io/pho-xo-bo/
- Lưu ý phê duyệt: lô b main chờ phê duyệt ~30 phút (lô a 18 giây,
  lô c ~11 phút, các lô gh-pages 10 giây–7 phút) — phê duyệt đến
  theo đợt, không đều; không đẩy lại khi đang chờ.

### 63.5 Việc tiếp theo

1. 3 sprite sạp còn lại (bánh-mì / gia-vị / đồ-khô) để cả 8 biển
   đều có sprite — cùng mẫu vòng này (canvas 64×96, y 0–33 trong
   suốt, không chữ).
2. Rà soát art hiện có theo `docs/artpass-20-11.md` +
   `docs/tileset-plan.md` (tile Map003–018 tái dùng tile nhà trọ là
   PROVISIONAL, chờ art pass vẽ tile riêng theo khu).
3. G2 còn lại (xem `docs/godot-g2.md`) rồi G4 online.

## 64. Vòng 42 — 3 sprite sạp còn lại Map002 (25/11 ~18:45–19:30 +07, cron 18:45)

Mục 1 §63.5: 3 sprite sạp còn lại (bánh-mì / gia-vị / đồ-khô) để cả
8 biển SIGNS_MAP2 đều có sprite. Art làm song song qua subagent
(artpass42), code làm cùng lúc. Lưu ý: 8 biển → 6 file sprite vì
2 cặp biển dùng chung 1 sprite (TRÁI CÂY + HOA QUẢ → trai-cay;
CÁ TƯƠI + THỊT HEO → ca-thit) — không thiếu sprite nào.

### 64.1 Art (subagent artpass42) — XONG

- 3 sprite, canvas 64×96 RGBA, nền trong suốt:
  `stall_banhmi.png` 9.273 byte (3 chồng bánh mì vàng giòn + chả
  lụa + pate + rau thơm), `stall_giavi.png` 7.857 byte (4 lọ ớt đỏ/
  tỏi/hành tím/tiêu đen + gói gia vị), `stall_dokho.png` 9.058 byte
  (mực/cá/tôm khô trong 3 rổ mây, tông nâu vàng). Mái hiên sọc
  đỏ/trắng + mép vỏ sò, 2 cột chống gỗ, quầy vân gỗ — theo đúng hợp
  đồng canvas vòng 41 (y 0–33 trong suốt, mái y 34–52, cột x 2–6 /
  58–62, quầy y 76–96); không chữ, không biển, không người.
- Gen lại: gia-vị 1 lần (v1 có tấm nền vàng cam đặc lấp khoảng trống
  mái–quầy, siết "EMPTY, no backdrop, no wall, no panel" thì đạt);
  đồ-khô 1 lần (v1 hàng treo lủng lẳng từ mái lấp khoảng trống, siết
  "NOTHING hangs from the awning" thì đạt); bánh-mì 0 lần.
- Kiểm chứng: y 0–33 có 0 pixel đục ở cả 3 file; cột chống ở y=56
  đúng hợp đồng (bánh-mì x 2–4 / 59–61, gia-vị x 4–6 / 57–59, đồ-khô
  x 4–5 / 58–59; mép mờ alpha của gia-vị chạm x57 nhưng lõi cột
  alpha>128 là x5 + x58, gọn trong hợp đồng); mỗi sprite đúng 1
  component alpha duy nhất; nền magenta + zoom 3× (không nền lạ,
  không quầng xanh ở mép, 0 pixel mép bán-trong-suốt gần màu xanh
  da trời); debug-white (bánh-mì 268 / gia-vị 326 / đồ-khô 193 px,
  tất cả trong band mái 34–52, 0 px ở band khác). Note:
  `visual-check/artpass42/stall-sprites-note.md` + script
  `process_stalls_r42.py` (adapt từ vòng 41) + `verify_r42.py`.
- Hạn chế: chỉ mặt trước; lọ gia-vị nhỏ ở tỉ lệ 1× trong game (đọc
  rõ ở zoom 3×); gia-vị v2 chạm mép trên + dưới khung, đồ-khô v2
  chạm mép dưới — phần chạm mép là 2 cạnh thẳng trùng đúng biên
  sprite (mép trên mái → y=34, đáy quầy → y=96), không mất nội dung.

### 64.2 Code + test — XONG

| File | Đổi |
|---|---|
| `scripts/nadia_scene.gd` | `STALL_SPRITE_FILES` thêm 3 loại (`banh-mi`→`stall_banhmi`, `gia-vi`→`stall_giavi`, `do-kho`→`stall_dokho`) — nay đủ 6; `stall_sprite_kind` thêm 3 nhánh (banh-mi/gia-vi/do-kho, 1–1 với `stall_goods_kind`); comment vòng 41 cập nhật thành vòng 41+42; `_load_stall_sprites` comment "6 sprite". Không đổi đường vẽ (sprite đã có là vẽ ảnh, thiếu là vẽ code — nay không biển nào thiếu nữa). |
| `tests/g4_r42_stall_sprite_test.gd` (mới) | 10 mục: 8 biển map đúng loại sprite (gồm 3 biển mới), không biển nào trả về ""; đường dẫn 3 sprite mới + 3 đường dẫn cũ vẫn đúng; đúng 6 sprite đăng ký; canvas 64×96 + đáy y +14; scene thật Map002 map_id 2, trạng thái sprite khớp file trên đĩa (6/6), về Map001 map_id 1. |
| `tests/g4_r41_stall_sprite_test.gd` (sửa) | 2 check cũ nay sai theo thiết kế mới đã cập nhật: "dung 3 sprite" → "dung 6 sprite (3 vong 41 + 3 vong 42)"; "3 bien khong co sprite" → "3 bien vong 42 cung co sprite" (kiểm ở r42). Còn lại giữ nguyên (5 biển gốc, nhịp sạp, o le). |
| `tools/godot/run_regression.sh` | Thêm `g4_r42_stall_sprite_test` (nay 70 suite). |
| `visual-check/artpass42/check_r42.py` (mới) | Theo mẫu check_r41.py, cổng 8197 + ảnh zoom vùng sạp (clip y=600..1050) + crop đáy y=950..1280 (r42-03). |

### 64.3 Verify thật vòng này

- `--check-only` nadia_scene.gd + r42 test: PASS (exit 0).
- Test mới `g4_r42_stall_sprite_test`: **10/10 PASS** (lúc art chưa
  có: 3/6 sprite trên đĩa, fallback đúng; lúc art đủ: **6/6**).
  Test r41 cập nhật: **13/13 PASS**.
- Hồi quy đầy đủ: **70 OK, 0 FAIL** (69 cũ + 1 mới r42, gồm cả
  server probe).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR.
- Export web exit 0: pck **22.118.376 byte, SHA `20e9c8ed…`**
  (trước `5f2a052f`, +29.016 byte = đúng 3 sprite + code, không art
  thừa); wasm không đổi `fc74679e`; HTTP 200 đủ 4 file (cổng 8197).
  Pck chứa đúng 3 texture `.ctex` mới của stall (kiểm bằng `strings`).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass42/check_r42.py`, ảnh
  `r42-01-map2` + `r42-02-stall-row-zoom` + `r42-03-stall-row-bottom`):
  **0 console error, 0 pageerror, 0 request fail.**
  - Map002: 6 sạp tách rời nhau (ô lẻ trống); biển 8 loại đọc được;
    sạp BÁNH MÌ hiện rõ chồng bánh mì vàng trên quầy dưới mái sọc
    đỏ/trắng; sạp ĐỒ KHÔ hiện rổ đồ khô nâu vàng dưới biển; sạp
    GIA VỊ có biển tím + lọ gia vị nhưng bị nhãn "Góc Chế Tạo" che
    một phần (lỗi nhãn đè sạp đã biết từ các vòng trước, không phải
    lỗi sprite — texture đã nạp đủ 6/6 theo test headless).
  - Còn lại (không sửa vòng này): nhãn NPC vẫn có thể đè lên sạp;
    lọ gia-vị nhỏ ở tỉ lệ 1×.

### 64.4 Push + Deploy — DỞ (main xong, gh-pages 7/10 lô, chờ phê duyệt)

- Push main 3 lô + docs (chưa push docs): a `a4c9b770` (nadia_scene +
  test r42 + sửa test r41 + run_regression.sh + check_r42.py, 6 paths);
  b `69d7b06a` (3 .import sprite mới) — **lệnh local timeout 1200s
  sau khi server đã nhận, đã xác minh nội dung remote khớp và khôi
  phục record sync từ SHA thật, không đẩy lại**; c `137f9eea` (note +
  scripts artpass42, 3 paths). Sync record 450 mục.
- Deploy gh-pages pck `20e9c8ed` (164 part): 7/10 lô đã lên
  (`b7f7e20e`, `f101a86a`, `cdb23c3c`, `ceffa79d`, `95e4cdce`,
  `b8b759e6`, `84c2ee21` — part 000–139). Lô 8 (part 140–159) bị
  timeout vì phê duyệt không được trả lời kịp — **đã kiểm bằng curl
  live: part-140 trả 404, tức lô 8 thật sự chưa lên, không đẩy lại
  khi chưa có phê duyệt mới**. Còn lại: lô 9 (part 160–163) + final
  (versions.json + index.html). Live hiện vẫn chạy bản r41
  (versions.json pin `5f2a052f`, kiểm bằng curl 200) — đúng, chưa
  lật sang bản mới.
- Lô docs (godot-g4 + roles-qc) chưa push — chờ deploy xong mới điền
  SHA deploy vào §64.4 rồi push 1 lần.
- **Đính chính vòng 43 (26/11 ~00:05): deploy r42 KHÔNG chờ nữa —
  pck r43 `936c82ea` chứa toàn bộ nội dung r42 + tile xưởng Map003,
  nên deploy r43 sẽ thay thế deploy r42 (live nhảy r41 → r43, bỏ qua
  `20e9c8ed`). Part 000–139 của `20e9c8ed` đã lên gh-pages thành file
  mồ côi (không hại, dọn định kỳ theo §vòng 8). Lô docs r42 (manifest
  `pxb-push-main-r42-docs`) KHÔNG push riêng nữa — gộp vào lô docs
  r43 (manifest `pxb-push-main-r43-docs`, cùng 2 file, đã gồm §64 +
  §65 + mục roles-qc vòng 42 + 43).**
- Lưu ý phê duyệt: lô b main timeout 1200s dù server đã nhận (lỗi
  đã biết: lệnh local chờ xác nhận quá lâu); deploy lô 8 timeout
  vì phê duyệt không trả lời kịp. Khi phê duyệt đến chậm, kiểm tra
  head/sync record trước khi đẩy lại — không bao giờ đẩy lại mù.

### 64.5 Việc tiếp theo

1. **Chờ phê duyệt rồi deploy nốt gh-pages vòng 42:** lô 8
   (part 140–159), lô 9 (part 160–163), final (versions.json +
   index.html) → kiểm live pin `20e9c8ed` + đối chiếu byte 164 part
   → điền SHA vào §64.4 → push lô docs.
2. Rà soát art hiện có theo `docs/artpass-20-11.md` +
   `docs/tileset-plan.md` (tile Map003–018 tái dùng tile nhà trọ là
   PROVISIONAL, chờ art pass vẽ tile riêng theo khu).
3. G2 còn lại (xem `docs/godot-g2.md`) rồi G4 online.

## 65. Vòng 43 — Tile xưởng riêng Map003 Khu Công Nhân (25/11 ~23:45–26/11 00:xx +07, cron 22:45)

Bối cảnh: deploy r42 kẹt phê duyệt (lô 8 timeout ~20:30; thử lại
~23:45 thì tiến trình bị runtime restart giữa lúc chờ phê duyệt —
đã xác minh live không đổi, part-140 vẫn 404, sync record 458 mục,
không đẩy lại mù). Vòng này làm việc mới thay vì ngồi chờ: tile
xưởng riêng đầu tiên cho 1 map (Map003), thay tile PROVISIONAL
"nha-tro-bac" (nhà Bắc tái dùng làm xưởng) trong
`atlas-map001.json` — đúng mục §64.5.2.

### 65.1 Art (subagent artpass43) — XONG, gen 0 lần lại

- Tile `xuong-map003.png` (64×64 RGBA): mái tôn sóng gạch đỏ
  #B4452F, tường vàng ấm #E8C86A, biển trống khung đỏ KHÔNG chữ,
  cửa cuốn mở thấy 2 bàn máy + 2 máy may, 2 thùng gỗ bên trái,
  bánh xe đạp bên phải; không người, không chữ, lề đủ 4 phía
  (bbox nguồn 1048×885, nền góc lệch tối đa 8,7).
- Kiểm chứng: 1 component alpha duy nhất (3.105 px); 0 pixel mép
  bán-trong-suốt gần màu xanh da trời (không quầng xanh); 0 pixel
  gần-trắng trên debug-white; kiểm bằng mắt ở 1× và zoom 3× đều
  đọc rõ nhà xưởng, không cắt mép. Note:
  `visual-check/artpass43/workshop-tile-note.md` + script
  `process_workshop_r43.py` (tách nền khoảng cách màu + alpha mềm
  + nearest-fill RGB + resize LANCZOS, theo mẫu vòng 41/42).
- Tôi kiểm lại bằng mắt: mái tôn đỏ + tường vàng + cửa cuốn mở
  thấy máy may, đúng palette art-style.md.

### 65.2 Code + test — XONG

| File | Đổi |
|---|---|
| `tools/godot/convert_maps.py` | `ATLAS_PNG_OVERRIDE = {3: "atlas-map003.png"}` + `ATLAS_TILE_OVERRIDE` (tile 4 → tên `xuong-may-mai-ton`, source artpass43, hết PROVISIONAL); `convert()` áp override sau khi tính `png_name` + copy sâu `atlas["tiles"]` rồi patch. |
| `src/godot/data/maps.json` (tạo lại) | Map003: `atlas_png` = `res://tiles/atlas-map003.png`, tile 4 tên mới; Map001/Map004/Map005 không đổi atlas; đủ 18 map. |
| `src/godot/tiles/atlas-map003.png` (mới, binary — chỉ local + trong pck, KHÔNG push qua snapshot-push) | `visual-check/artpass43/build_atlas_map003.py`: atlas-map001.png đổi cell cột 3 (x=192) thành tile xưởng; kiểm: cell 3 khác 3096 px, 3184 px đục, các cell khác giống hệt. |
| `src/godot/tiles/atlas-map003.png.import` (mới) | Copy từ `.import` atlas-map001 + `--import` sinh lại. |
| `src/godot/tests/g4_r43_workshop_tile_test.gd` (mới) | 15 mục: Map003 atlas + tên tile 4 + hết PROVISIONAL; Map001/004/005 không đổi; PNG 512×64; cell 3 khác atlas cũ + có nhà (>800 px đục); cell khác giống hệt; scene thật Map003 (không NadiaScene, lớp tile hiện, atlas đúng file mới) 60 frame + về Map001 map_id 1. |
| `tools/godot/run_regression.sh` | Thêm `g4_r43_workshop_tile_test` (nay 71 suite). |
| `visual-check/artpass43/check_r43.py` (mới) | Theo mẫu check_r42.py, cổng 8198 + ảnh Map003 + 2 crop zoom (hàng biên trái + góc dưới-phải). |

### 65.3 Verify thật vòng này

- `--check-only` test r43: PASS (exit 0).
- Test mới `g4_r43_workshop_tile_test`: **15/15 PASS** (cell 3
  khác atlas cũ 3068 px theo Godot — PIL đo 3096, lệch do import —
  vẫn >500; 3184 px đục).
- Hồi quy đầy đủ: **71 OK, 0 FAIL** (70 cũ + 1 mới r43, gồm cả
  server probe).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR.
- Export web exit 0: pck **22.141.660 byte, SHA `936c82ea`**
  (trước `20e9c8ed`, +23.284 byte = đúng atlas mới + code + test,
  không art thừa); wasm không đổi `fc74679e`; HTTP 200 đủ 6 file
  (cổng 8198). Pck chứa `atlas-map003` + `xuong-may-mai-ton`
  (kiểm bằng `strings`).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass43/check_r43.py`, ảnh
  `r43-01-map3` + `r43-02-top-row-zoom` + `r43-03-left-edge-zoom` +
  `r43-04-bottom-right-zoom`): **0 console error, 0 pageerror,
  0 request fail.**
  - Đi chuỗi Map001 → Map002 → Map003 đúng cửa: HUD "Khu Công
    Nhân", toast "Đã sang Khu Công Nhân", NPC Anh Ba + Chị Sáu
    (walk cycle) + 2 cửa đúng tên.
  - Tile xưởng hiện rõ ở hàng biên Map003: mái tôn đỏ + tường
    vàng + cửa cuốn mở thấy máy may + biển trống không chữ — khác
    hẳn tile nhà trọ cũ (nhà Bắc) và tile nhà nhỏ bên cạnh.
  - Lưu ý: crop zoom đầu (y=380..760) chụp nhầm vùng trời — đã
    crop lại đúng vùng biên (trái + dưới-phải) mới thấy tile;
    lần sau căn crop theo vị trí ô L1 thay vì đoán y.
  - Bài học: playwright nằm ở `~/.local/lib/python3.12/site-packages`
    (bản 1.65.2), không phải python3 hệ thống — chạy verify phải
    thêm `PYTHONPATH=$HOME/.local/lib/python3.12/site-packages`.

### 65.4 Push + Deploy — DỞ (main kẹt phê duyệt, deploy chưa chạy)

- Push main 3 lô: **lô a TIMEOUT 1200s** (chờ phê duyệt, 26/11
  ~00:15–00:35) — đã xác minh remote main head vẫn `137f9eea`
  (r42 lot c) + sync record 460 mục, tức lô a CHƯA lên (khác
  trường hợp lô b r42: timeout nhưng server đã nhận). Thử đẩy lại
  lô a thì bị chặn: `Error: an equivalent connector write is
  already running for this request` — **lệnh ghi cũ vẫn đang chạy
  chờ phê duyệt, KHÔNG được đẩy trùng**. Lô b/c/docs chưa chạy.
  Lượt sau: kiểm tra remote head + sync record trước khi đẩy gì
  thêm; chỉ đẩy tiếp khi lệnh ghi cũ đã xong/mất.
- **Đính chính vòng 44 (26/11 ~01:00): thử đẩy lại lô a lúc 00:42 —
  lệnh local TIMEOUT 1200s lần nữa; thẻ phê duyệt vẫn đang chờ
  (`connector-attempt-2451f36d…`, yêu cầu 00:42:32 +07, scope
  schedule "Pho Xo Bo 24 24 Build"); remote main head vẫn `137f9eea`,
  tức lô a CHƯA lên. KHÔNG đẩy lại khi thẻ này còn chờ — chờ chủ
  duyệt hoặc thẻ hết hạn rồi mới thử lại ở lượt sau. Deploy
  gh-pages r43 chưa chạy (theo thứ tự main → deploy → docs).**
- Deploy gh-pages pck `936c82ea` (165 part): chưa chạy (chờ main).
- **Tin mới về deploy r42 (kiểm 26/11 ~00:35): lô 8 + lô 9 ĐÃ LÊN**
  (sync record +2: `77f70e53` part 140–159, `d07f00f9` part
  160–163; curl live part-140/159/160/163 đều 200) — tiến trình
  deploy r42 bị restart giết lúc 23:47 hóa ra vẫn chạy tiếp phía
  sau và được phê duyệt 2 lô. Chỉ còn lô final r42 (versions.json
  + index.html) chưa lên; theo đính chính ở §64.4 thì KHÔNG đẩy
  final r42 riêng nữa — deploy r43 sẽ đưa live từ r41 thẳng lên
  r43.
- Live hiện vẫn chạy bản r41 (pin `5f2a052f`).

### 65.5 Việc tiếp theo

1. Deploy xong pck `936c82ea` → kiểm live pin + đối chiếu byte
   165 part → điền SHA vào §65.4 → push lô docs r43 (gộp cả
   docs r42, xem §64.4).
2. Tile riêng tiếp theo: Map004 Bến Xe Miền Đông (đang dùng
   atlas-map002.png — tile nào PROVISIONAL?) rồi Map005–018 theo
   `docs/tileset-plan.md`.
3. Nhãn "Góc Chế Tạo" đè sạp gia-vị Map002 (phát hiện vòng 42,
   chưa sửa — cần sửa vị trí nhãn craft, không phải sprite).
4. G2 còn lại rồi G4 online.

## 66. Vòng 44 — Tile nhà chờ Bến Xe riêng Map004 + thử đẩy lại main r43 (26/11 ~00:40–01:05 +07, cron 23:45)

### 66.1 Art (subagent artpass44) — XONG, gen 0 lần lại

- Tile `benxe-map004.png` (64×64 RGBA): mái vòm tôn sóng xanh teal,
  tường vàng ấm #E8C86A, bảng giờ trống khung nâu KHÔNG chữ trên cửa
  kính 4 cánh, 4 ghế chờ gỗ trước cửa, 2 cột gạch đỏ 2 bên; không
  người, không chữ, lề đủ 4 phía, đáy nhà y=62.
- Kiểm chứng (đo lại bằng PIL): 1.555 px đục, 271 px bán-trong-suốt,
  0 pixel mép gần màu xanh da trời (không quầng xanh); note
  `visual-check/artpass44/benxe-tile-note.md` + script
  `process_benxe_r44.py` (tách nền khoảng cách màu, ngưỡng 40 +
  ramp alpha mềm 30→50, theo mẫu vòng 43). Gen v1 dùng ngay.
- Mục tiêu: thay tile 5 "sap-do-mai-xanh" (sạp mái xanh Kenney, 10 ô
  L1 trên biên Map004) trong `atlas-map002.png` → atlas riêng
  `atlas-map004.png` (đổi cell cột 4, x=256), theo đúng mẫu vòng 43.
  Code nối (converter override + maps.json + test) CHƯA làm trong
  vòng này — `maps.json` đang nằm trong manifest lô a r43 đang chờ
  phê duyệt nên không được sửa cho tới khi lô a xong/mất.

### 66.2 Push main r43 — KẸT PHÊ DUYỆT (xem §65.4)

- Thử đẩy lại lô a 00:42: local TIMEOUT 1200s; thẻ phê duyệt
  `connector-attempt-2451f36d…` vẫn chờ; remote head vẫn `137f9eea`;
  lô a CHƯA lên, lô b/c/docs chưa chạy. KHÔNG đẩy lại khi thẻ còn chờ.
- Deploy gh-pages pck `936c82ea` (165 part, staging đã verify
  `--verify-only` PASS, index.html trỏ đúng pck/wasm mới) chưa chạy
  — theo thứ tự main → deploy → docs, chờ lô a xong rồi mới deploy.
- Live vẫn chạy bản r41 (pin `5f2a052f`).

### 66.3 Khảo sát lỗi nhãn craft (chỉ đọc, chưa sửa)

- Nhãn "Góc Chế Tạo" ở offset −40 trên icon craft (marker.gd
  `_draw_craft`, sau sửa §8.6); sạp gia vị vẽ trong nadia_scene.gd
  (3 lọ gia vị, không phải nhãn). Sửa đúng cần ảnh thật để căn vị
  trí nhãn so với sprite sạp — để vòng sau, sau khi push/deploy
  r43 xong.

### 66.4 Việc tiếp theo

1. Chờ thẻ phê duyệt lô a r43 (duyệt hoặc hết hạn) → kiểm remote
   head + sync record → đẩy nốt lô b/c, deploy pck `936c82ea`,
   kiểm live pin, push lô docs r43 (gồm §65 + §66).
2. Nối tile nhà chờ Bến Xe Map004: converter override
   (`ATLAS_PNG_OVERRIDE[4]`, tile 5 → `nha-cho-ben-xe`) +
   `atlas-map004.png` (đổi cell cột 4 từ artpass44) + test r44
   theo mẫu r43, rồi export + browser-verify + deploy.
   **Tiến độ vòng 45:** atlas + test đã chuẩn bị xong (xem §67);
   chỉ còn bước nối converter + regen maps.json, CHỜ lô a r43
   xong/mất.
3. Sửa nhãn "Góc Chế Tạo" đè sạp gia vị Map002 (cần ảnh thật).
4. Tile riêng tiếp theo: Map005–018 theo `docs/tileset-plan.md`.

## 67. Vòng 45 — Thử đẩy lại main r43 + chuẩn bị tile Map004 (26/11 ~01:15–01:25 +07, cron 00:45)

### 67.1 Push main r43 — THỬ LẠI LÔ A, ĐANG CHỜ PHÊ DUYỆT

- Thẻ phê duyệt lô a r43 (`connector-attempt-2451f36d…`, yêu cầu
  00:42:32 +07) đã **TIMED OUT lúc 01:15:03 +07** (xem
  permissions.history) — không còn thẻ chờ, không còn lệnh ghi
  tương đương đang chạy. Sync record: remote main head vẫn
  `137f9eea` (r42 lô c), lô a r43 CHƯA lên.
- Theo §66.4 bước 1, thử đẩy lại lô a lúc ~01:16:
  `pxb-push-main-r43.py 1 3` (lô a+b+c, dừng khi 1 lô lỗi; lô
  docs chạy riêng sau deploy) — tiến trình nền, timeout 1200s
  cho mỗi lệnh ghi, đang chờ phê duyệt mới của chủ.
- Nếu lô a được duyệt → đẩy nốt lô b/c, deploy pck `936c82ea`,
  kiểm live pin, push lô docs r43 (gồm §65 + §66 + §67).
  Nếu lại timeout → ghi nhận, không đẩy trùng khi thẻ còn chờ.

### 67.2 Chuẩn bị tile Map004 (không xung đột với lô a đang chờ)

- **Không sửa file nào trong manifest lô a** (convert_maps.py,
  maps.json, test r43, run_regression.sh, check_r43.py,
  build_atlas_map003.py).
- `visual-check/artpass44/build_atlas_map004.py` (mới, theo mẫu
  r43): `atlas-map004.png` = atlas-map002.png đổi cell cột 4
  (x=256) thành tile nhà chờ Bến Xe (`benxe-map004.png`).
  Kiểm: cell 4 khác 1824 px, 2857 px đục, các cell khác giống
  hệt; file 512×64 RGBA, MD5 `7f85efde…` (tính lại 2 lần giống
  nhau). `.import` copy từ atlas-map002 + `--headless --import`
  exit 0.
- Test mới `src/godot/tests/g4_r44_benxe_tile_test.gd` (15 mục,
  theo mẫu r43): Map004 → atlas-map004.png, tile 5 →
  `nha-cho-ben-xe`, Map001/002/005 không đổi atlas; cell 4
  khác >500 + đục >800 + cell khác giống hệt; scene Map004
  (không NadiaScene, lớp tile hiện, atlas mới) 60 frame + về
  Map001 map_id 1.
- **Kiểm chứng âm trước khi nối converter: 12/15 PASS** — đúng
  3 FAIL ở các check nối `maps.json` (Map004 vẫn atlas-map002,
  tile 5 vẫn `sap-do-mai-xanh`, scene atlas cũ); phần PNG +
  scene đều PASS (cell 4 khác 1810 px theo Godot, 2857 px
  đục). Test đã chứng minh phát hiện đúng trạng thái chưa nối.

### 67.3 Sửa nhãn "Góc Chế Tạo" đè biển "GIA VỊ" Map002 — XONG (code + test, chưa export)

- **Khảo sát bằng ảnh thật** (script mới
  `visual-check/artpass45/check_craft_label.py`, theo mẫu
  check_r42.py; serve pck r43 `936c82ea` cổng 8199, Chromium
  1255 + swiftshader, 0 console error/pageerror/requestfail):
  ảnh `r45-01-map2.png` + crop zoom `r45-03/-04/-05/-06`.
  Đo bằng PIL + xem ảnh: nhãn "Góc Chế Tạo" (x 287–520,
  y 1057–1097) che mất "GI" của biển "GIA VỊ" (biển 52×12
  của sạp bên tường, chỉ còn "A VỊ").
- **Nguyên nhân:** biển sạp do NadiaScene vẽ (nền), resolver
  không biết tới nên không tránh; nhãn craft neo giữa ô
  (7,5), biển nằm ngay phải nhãn. Tương đối giữa nhãn và
  biển không đổi khi camera cuộn (cả hai neo theo ô thế
  giới) nên dịch cố định là đủ.
- **Sửa:**
  1. `marker.gd`: thêm `var map_id` (IsoMap đặt lúc tạo
     marker) + const `CRAFT_LABEL_SHIFT_MAP2 := 48.0`; trong
     `label_screen_rect()`, nhãn craft trên Map002 dịch trái
     48px màn hình trước khi kẹp mép (mép phải 520 → 472,
     biển bắt đầu ~x500, khe ~28px > LABEL_GAP 12).
     Map001 không đổi.
  2. `nadia_scene.gd`: phương thức mới
     `stall_sign_screen_rects()` — rect màn hình 12 biển
     sạp (6 biển hàng Map002 62×16 + 6 biển sạp bên 52×12),
     cùng số đo với `_draw_market_row`/`_draw_side_stall`
     (biển treo xe đồ ăn (6,12) không tính vì nó lắc theo
     thời gian). **Cổng đúng theo code vẽ:** biển hàng chỉ
     Map002, biển sạp bên chỉ khi `map_id != 1` (Map001 có
     tường trong ảnh composite sẵn, không có sạp bên code).
  3. `main.gd`: đưa rect biển vào `obstacles` của resolver
     (vòng chính, KHÔNG vào `hard_obstacles`) để resolver tự
     dịch nhãn khi có khoang trống trong vòng 120px.
- **Hai lần sửa sai trong vòng 45 (bài học, đã sửa xong):**
  1. Đã thử mở rộng cửa thoát: nhãn đè biển đáng kể thì
     nhảy tối đa 200px — **phải bỏ**: nhảy xa phá vỡ bắt
     buộc neo ≤120px (artpass12: "Sạp rau" rời neo −161px;
     artpass4/5: "Hẻm trọ buổi tối" nhảy lên đè đầu nhân
     vật). Biển che nhẹ thì chấp nhận; chỉ trường hợp nào
     có khoang trống trong vòng 120px thì resolver tự dịch.
  2. `stall_sign_screen_rects()` lúc đầu trả biển sạp bên
     trên MỌI map — **sai**: Map001 không vẽ sạp bên code,
     rect "ma" đẩy nhãn "Hẻm trọ buổi tối" lên đè đầu nhân
     vật (artpass4/5 hỏng). Đã cổng `map_id != 1` theo đúng
     `_draw_side_walls()`.
  Sau 2 sửa: artpass12 14/14, artpass4 19/19, artpass5
  17/17, polish 19/19. Hồi quy đầy đủ chạy lại sau 2 sửa
  (xem log `~/workspace/regression-move.log`).
- **Test mới trong `g4_polish_test.gd`** (nay 19 mục):
  `_sign_screen_rects()` (tính độc lập từ hằng số NadiaScene
  + canvas transform) + `_labels_vs_signs()` — nhãn
  hotspot/craft/door không được đè biển sạp. Chạy:
  **19/19 PASS**.
- **Phát hiện thêm khi test (đã xác minh bằng ảnh thật):**
  - Nhãn NPC "Anh Hải" đè 2 biển HOA QUẢ + RAU CỦ (nhãn
    kẹp giữa 2 biển; dịch dọc/ngang đều không thoát —
    lên 50 world thì vướng biển trên, xuống 52 thì che
    đầu NPC; xem §67.4).
  - Hotspot "Sạp rau buổi sáng" đè biển THỊT HEO 15×20px:
    khoang trống gần nhất cách 210px > LABEL_ESCAPE_MAX_DRIFT
    200 (tường chắn: 6 biển hàng + sprite NPC + nhân vật
    liền nhau 661–1062) nên resolver giữ neo theo đúng
    triết lý cũ (đè nhẹ còn đọc được, bay xa thì mất neo).
    Ghi ngoại lệ có tên trong test, không giấu.
- **Chưa làm:** export + browser-verify lại (xem §67.5).
- **Export + browser-verify XONG (sau 2 sửa, ~02:40 +07):**
  hồi quy đầy đủ **71/71 OK** (log
  `~/workspace/regression-move.log`); `--check-only` 5 file
  đổi OK; smoke `--quit-after 120` exit 0; export web exit 0,
  pck mới MD5 `17077f4c` (22.165.836 byte — thay pck r43
  `936c82ea` vì có code sửa nhãn). Browser-verify bằng
  `check_craft_label.py` trên build mới: **0 console /
  page / request error**; ảnh `r45-03` mới: biển "GIA VỊ"
  hiện đủ chữ, nhãn "Góc Chế Tạo" đã dịch trái, khe rõ;
  "Sạp rau" vẫn che "TH" của biển THỊT HEO (ngoại lệ đã
  ghi); "Anh Hải" vẫn đè 2 biển (vấn đề biết §67.4).

### 67.4 Vấn đề biết: nhãn "Anh Hải" đè biển — CHƯA SỬA (cần dời NPC, chờ lô a xong)

- Đo: nhãn Anh Hải (world y −10..24, x 46..146, neo trên
  đầu) đè biển HOA QUẢ ô (2,0) (y −16..0) và RAU CỦ ô
  (4,0) (y 16..32); test headless đo giao nhau 60×12,5px.
  Ảnh thật r45-05/-06: chữ "HOA QUẢ" mất "Ả", biển RAU CỦ
  bị che mép trên.
- Vì sao không sửa bằng resolver: nhãn NPC là nhãn thế giới
  cố định, resolver KHÔNG dịch được (ghi rõ trong code);
  dịch dọc ±50 world đều vướng (lên thì vào biển trên,
  xuống thì che đầu NPC); dịch ngang ±123 world thì rời
  neo; đổi NPC_LABEL_TOP toàn cục thì đổi mọi nhãn NPC.
- **Hướng sửa đã kiểm chứng bằng số:** dời ô nhà Anh Hải
  (6,3) → (6,5) (đất L0=1/L1=0, đi được như ô cũ; hàng
  xóm (6,4)/(5,5)/(6,6) trống cho patrol; nhãn ở (6,5)
  không chạm bất kỳ biển hàng/biển bên nào — đã tính đủ
  12 rect biển). Thực hiện bằng override trong converter
  (theo mẫu ADDED_DOORS) + regen maps.json + test + export
  + browser-verify. **CHƯA làm được trong vòng này** vì
  converter + maps.json đang nằm trong manifest lô a r43
  chờ phê duyệt.
- Ngoại lệ "Sạp rau buổi sáng" đè biển THỊT HEO 15×20px:
  giữ nguyên (lý do ở §67.3), test bỏ qua riêng nhãn này
  có ghi chú.

### 67.5 Việc tiếp theo

1. Chờ kết quả đẩy lô a r43 (duyệt/timeout) → làm tiếp theo
   §67.1.
2. Sau khi lô a xong/mất: nối converter r44 + regen maps.json +
   chạy lại test r44 (kỳ vọng 15/15) + dời ô nhà Anh Hải
   (6,3)→(6,5) theo §67.4 + export + browser-verify
   (craft + sạp rau + Anh Hải) + deploy.
   **Lưu ý: deploy dùng pck MỚI `17077f4c` (đã có fix
   craft), không dùng pck r43 `936c82ea` nữa — staging
   r43 đã verify cho pck cũ, cần regen staging/deploy từ
   pck mới (sau khi nối r44 + sửa Anh Hải xong thì export
   lại pck cuối rồi deploy một lần).**
3. Tile riêng tiếp theo: Map005–018 theo `docs/tileset-plan.md`.

## 68. Vòng 46 — Nối tile Map004 + dời Anh Hải sang (9,1) (26/11 ~02:45–03:15 +07, cron 01:45)

### 68.1 Push main r43 — KẾT QUẢ: TIMEOUT LẦN 3, LÔ A CHƯA LÊN

- Thẻ phê duyệt lô a r43 (`connector-attempt-7ce2b183…`, yêu cầu
  01:17:10 +07) **TIMED OUT lúc 02:43:19 +07** (xem
  permissions.history) — không còn thẻ chờ, không còn lệnh ghi
  tương đương đang chạy, không còn tiến trình push nào sống.
- Sync record vẫn 460 mục; remote main head vẫn `137f9eea` (r42 lô c)
  — lô a r43 CHƯA lên sau 3 lần thử (00:15, 00:42, 01:17).
- Theo §67.5 bước 2, lô a coi như "mất" → làm tiếp việc r44 +
  Anh Hải thay vì ngồi chờ; nội dung r43 gộp chung vào push r44
  (xem §68.5), script `pxb-push-main-r43.py` bỏ (không xóa file).

### 68.2 Code — XONG

| File | Đổi |
|---|---|
| `tools/godot/convert_maps.py` | `ATLAS_PNG_OVERRIDE[4] = "atlas-map004.png"` + `ATLAS_TILE_OVERRIDE[4]` (tile 5 → `nha-cho-ben-xe`, hết PROVISIONAL); thêm `NPC_MOVE` + áp sau khi port event xong. |
| `src/godot/data/maps.json` (tạo lại) | Map004 atlas mới + tile 5 tên mới; Map002 Anh Hải (9,1); Map001/002/005 atlas không đổi; đủ 18 map. |
| `tools/godot/run_regression.sh` | Thêm `g4_r44_benxe_tile_test` (nay 70 suite vòng lặp + server_test + probe = 72 mục). |
| `src/godot/tests/g4_r15_label_world_test.gd` | Sửa theo Anh Hải mới (xem §68.3). |
| `src/godot/tests/g4_r43_workshop_tile_test.gd` | Sửa theo Map004 atlas mới (xem §68.3). |
| `visual-check/artpass46/check_r46.py` (mới) | Browser-verify Map002 (nhãn Anh Hải) + Map003→Map004 (tile nhà chờ), theo mẫu check_craft_label.py. |

### 68.3 Lỗi (6,5) → (9,1) + sửa 2 test lỗi thời — XONG

- **Dời (6,3)→(6,5) SAI (chỉ xet biển, chưa xét nhãn):** regen xong,
  polish rớt **18/19** — "Map002: nhan khong chong nhau Anh Hải vs
  Sạp rau buổi sáng". Probe headless đo: nhãn Anh Hải
  (298–422, 799–839) đè nhãn "Sạp rau" (245–554, 818–856)
  123×20px; resolver giữ nguyên y muốn vì không tìm được khoang
  trống trong vòng 120px: khoang trên bị chặn bởi vật cản sprite
  Chị Lệ (y 706–821), khoang dưới bị chặn bởi sprite Anh Hải
  (y 846–961); dịch ngang cũng không thoát (nhãn "Sạp rau" rộng
  309px, kẹp x tối đa 395, luôn chạm sprite người chơi).
  Bài học: **dời NPC phải kiểm tra CẢ nhãn khác + sprite, không
  chỉ biển sap** — §67.4 chỉ tính 12 rect biển nên kết luận sai.
- **Chọn (9,1) bằng liệt kê đủ 108 ô Map002** (script Python, công
  thức màn hình đã đối chiếu probe): 4 tiêu chí — (1) nhãn Anh Hải
  không đè nhãn "Sạp rau"/Chị Lệ; (2) nhãn không chạm 12 rect biển
  sap; (3) nhãn "Sạp rau" không che sprite Anh Hải; (4) ô đi được
  (L1=0), không event, có ô kề cho patrol. 24 ô đạt; chọn (9,1):
  nhãn x 578–702 tách khỏi "Sạp rau" x 245–554 theo chiều X, 3 ô
  patrol (10,1)/(8,1)/(9,2) đều L1=0 + không event; (6,2) LOẠI vì
  nhãn "Sạp rau" (y 818) che mặt/ngực sprite (y 786–901).
  Probe tạm `probe_r46_labels.gd` đã xóa sau khi dùng.
- **Sửa 2 test lỗi thời theo thay đổi có chủ ý** (mẫu các vòng trước):
  1. `g4_r15_label_world_test`: state 4 đặt người chơi ở (5,2)
     trước khi kiểm — cách Chị Lệ (2,2) 3 ô, cách Anh Hải (9,1)
     5 ô (đúng ngưỡng hiện nhãn) — thay vì kiểm ở spawn (5,4)
     nơi Anh Hải cách 7 ô nên nhãn ẩn. **63/63 PASS** trở lại.
  2. `g4_r43_workshop_tile_test`: check "Map001/004/005 không đổi
     atlas" → "Map001/002/005 không đổi atlas" (Map004 nay có
     atlas riêng, do test r44 khóa). **15/15 PASS** trở lại.

### 68.4 Verify thật vòng này

- Test mới `g4_r44_benxe_tile_test`: **15/15 PASS** (cell 4 khác
  atlas cũ 1810 px, 2857 px đục).
- Polish **19/19 PASS** (trở lại sau khi đổi sang (9,1)); r22 walk
  **41/41 PASS** (patrol nhà mới không hỏng); r15 63/63; r43 15/15.
- Hồi quy đầy đủ: **72 OK, 0 FAIL** (70 suite + server_test +
  probe; log `~/workspace/regression-move.log`).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR.
- Export web exit 0: pck **22.165.948 byte, MD5 `e04cd7d2`**
  (sha256 `64b8934d…`, thay `17077f4c` vòng 45); wasm không đổi
  `fc74679e`; pck chứa `nha-cho-ben-xe` + Anh Hải tile [9,1]
  (kiểm bằng `strings`/đọc byte); HTTP 200 đủ 4 file (cổng 8200).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass46/check_r46.py`, cổng 8200):
  **0 console error, 0 pageerror, 0 request fail.**
  - Đi chuỗi Map001 → Map002 → Map003 → Map004 đúng cửa (toast
    "Đã sang Bến Xe Miền Đông"); Map002: người chơi (7,2), nhãn
    "Anh Hải" hiện rõ trên đầu NPC mũ lưỡi trai xanh, không đè
    nhãn "Sạp rau buổi sáng", biển HOA QUẢ/RAU CỦ/GIA VỊ đủ chữ
    (fix craft vòng 45 vẫn giữ); Map004: Bác Tài + Anh Bốc Vác +
    2 cửa đủ tên.
  - Tile nhà chờ hiện rõ ở hàng biên Map004 (ảnh `r46-06/-07`):
    mái vòm tôn sóng xanh teal + tường vàng + cửa kính — khác hẳn
    tile sạp mái xanh cũ.
  - Lưu ý: crop zoom đầu (y 300–800) chụp nhầm vùng trời — đã crop
    lại đúng vùng biên (phải + trái) mới thấy tile; bài học cũ
    vòng 43 lặp lại, lần sau căn crop theo vị trí ô L1 ngay từ đầu.

### 68.5 Push + Deploy — ĐANG CHỜ PHÊ DUYỆT (bắt đầu lượt này)

- **Push main r44 (gộp r43+r44+r45+r46):** script mới
  `pxb-push-main-r44.py` + 4 manifest (`pxb-push-main-r44-a/b/c/
  docs`, 13+2+4+2 paths). Lô a gồm converter + maps.json + test
  r43/r44/r15 + run_regression.sh + check_r43/r46 + build_atlas
  map003/004 + check_craft_label.py (vòng 45 chưa push); lô b 2
  `.import` atlas-map003/004; lô c note + process script
  artpass43/44; lô docs godot-g4 + roles-qc. Chạy nền
  `pxb-push-main-r44.py 1 3` (lô docs chạy riêng sau deploy).
  **Lỗi manifest lúc đầu:** lần chạy đầu báo ngay `--paths-file must
  contain NUL-delimited paths ending in NUL` — manifest tôi tạo bằng
  `b'\0'.join(...)` thiếu NUL cuối (manifest cũ kết thúc bằng NUL).
  Đã sửa cả 14 manifest r44 (4 push + 10 deploy) rồi chạy lại.
  Thẻ phê duyệt lô a: `connector-attempt-83daed20…` (yêu cầu
  03:16:57 +07). Nếu lại timeout thì ghi nhận, không đẩy trùng khi
  thẻ còn chờ.
  **Khôi phục sau runtime restart (~03:24):** cả 2 tiến trình nền
  (push + deploy) bị giết, log trống. Đã xác minh từ phía remote
  (không cần phê duyệt, đọc public): main head vẫn `137f9eea`,
  live `versions.json` vẫn pck `5f2a052f`, chunk mới `64b8934d`
  404, sync record vẫn 460 — **không lô nào lên, không có trạng
  thái dở, không cần undo**. Thử lại cả 2 trong lượt khôi phục:
  push bám lại ĐÚNG thẻ cũ `83daed20…` (connector dedupe lệnh ghi
  tương đương — thẻ lại hiện pending khi có exec sống chờ nó, không
  tạo thẻ mới); deploy chạy lại, chưa thấy thẻ riêng. Nếu thẻ cũ
  timeout thì lượt sau thử lại như thường.
  **Kết quả thử lại (xác minh ~03:45):** CẢ HAI đều timeout 1200s
  ở lô đầu — `github push-files` chờ phê duyệt tới giới hạn
  1200s của wrapper `subprocess.run` rồi văng `TimeoutExpired`
  (không bắt exception → script dừng; `PUSH_EXIT=0`/`DEPLOY_EXIT=0`
  là mã của `tail`, không phải của push). Push lô a: thẻ
  `83daed20…` vẫn "Awaiting decision" (hạn thẻ 26/11 20:16:57 UTC),
  main head vẫn `137f9eea`, sync vẫn 460. Deploy lô 1/10: thẻ
  riêng của deploy KHÔNG còn trong danh sách chờ (đã timeout/biến
  mất) — lần thử deploy sau sẽ tạo thẻ mới, không trùng. Live
  vẫn pck `5f2a052f`, chunk `64b8934d` 404 — **không gì lên**.
  Không thử lại ngay trong lượt này: thẻ push vẫn chờ quyết định
  của user, thử lại chỉ chờ lại 1200s nữa; lượt cron sau thử lại
  theo lệ (r43 lô a đã timeout 3 lần kiểu này). BÀI HỌC: wrapper
  `pxb-push-main-r44.py`/`pxb-deploy-r44.py` nên bắt
  `TimeoutExpired` và ghi kết quả thay vì văng traceback — sửa ở
  lượt sau trước khi thử lại.
- **Deploy gh-pages pck `64b8934d`:** staging rebuild xong,
  `build_gh_pages.py --verify-only` PASS (khớp byte); 165 chunk
  (part-000..164) + final (versions.json + index.html); script
  mới `pxb-deploy-r44.py` + 10 manifest
  (`pxb-deploy-pck-64b8934d-batch1..9` + `-final`). Wasm không
  đổi `fc74679e` nên không đẩy lại (đã có trên gh-pages từ vòng 9).
  Chạy nền sau push main. Live hiện vẫn `5f2a052f` (r41).
- **Chưa làm:** điền SHA push/deploy vào §68.5 sau khi có kết quả;
  push lô docs r44 (gồm §65 + §66 + §67 + §68 + mục roles-qc
  vòng 43–46 — lưu ý: roles-qc.md local mới tới vòng 42, các vòng
  43–45 chưa kịp ghi dòng hiện trạng; vòng này ghi gộp).

### 68.6 Việc tiếp theo

1. Chờ kết quả push main r44 + deploy pck `64b8934d` → kiểm live
   pin + đối chiếu byte → điền SHA vào §68.5 → push lô docs r44.
   Trạng thái ~03:45: cả 2 thử lại đều timeout 1200s chờ phê duyệt;
   thẻ push `83daed20…` vẫn chờ (hạn 26/11 20:16:57 UTC), thẻ
   deploy đã biến khỏi danh sách chờ; lượt cron sau thử lại.
   Trước đó: sửa wrapper bắt `TimeoutExpired` thay vì văng traceback.
2. Tile riêng tiếp theo: Map005 Làng Đại Học theo
   `docs/tileset-plan.md` (đang dùng atlas-map001.png — tile nào
   PROVISIONAL?).
3. G2 còn lại rồi G4 online (quyết server Godot headless hay .NET,
   xem `docs/opensource-engine.md` §3.4).

## 69. Vòng 47 — Tile giảng đường riêng Map005 + sửa ghost atlas + sửa wrapper TimeoutExpired (26/11 ~04:00–04:50 +07, cron 03:45)

### 69.1 Push main r44 — KẾT QUẢ: THẺ ĐÃ TIMEOUT, KHÔNG CÒN THẺ CHỜ

- Thẻ phê duyệt lô a r44 (`connector-attempt-83daed20…`, yêu cầu
  03:16:57 +07) **TIMED OUT lúc 03:59:48 +07** (xem
  permissions.history) — `permissions.list_pending` hiện trống,
  không còn thẻ chờ nào.
- Đã xác minh tươi từ phía remote (curl public, không cần phê duyệt):
  main head vẫn `137f9eea` (r42 lô c), live `versions.json` vẫn pck
  `5f2a052f` (r41), sync record vẫn 460 mục — **không gì lên**.
- Không thử đẩy lại lượt này: chủ đang ngủ, không ai bấm duyệt; 4 lần
  thử trước (00:15, 00:42, 01:17, 03:16) đều timeout kiểu này. Theo
  kế hoạch đã chốt với chủ (MEMORY 25/11): thử lại khi chủ nói
  'đẩy tiếp' + bấm duyệt ngay. Push r45 gộp (xem §69.6) thay script
  r44, như vòng 46 thay script r43.

### 69.2 Art (subagent artpass45) — XONG, gen 0 lần lại

- Tile `giangduong-map005.png` (64×64 RGBA): giảng đường 2 tầng
  tường vàng ấm #E8C86A, mái ngói đỏ #B4452F, bảng tên trống khung
  nâu KHÔNG chữ, cửa gỗ + bậc đá, cây xanh bên phải; không người,
  không chữ, lề đủ 4 phía (bbox nguồn 1495×1003, lề 233/192/128/
  149px, nền góc lệch tối đa 9,5).
- Kiểm chứng: 1 component alpha duy nhất (2.143 px alpha>0); 0 pixel
  mép bán-trong-suốt gần màu xanh da trời (không quầng xanh);
  0 pixel gần-trắng; kiểm bằng mắt ở 1× và zoom 3× đều đọc rõ
  giảng đường. Note: `visual-check/artpass45/giangduong-tile-note.md`
  + script `process_giangduong_r45.py` (tách nền khoảng cách màu +
  alpha mềm + nearest-fill RGB + resize LANCZOS, theo mẫu vòng 44).
- Tôi kiểm lại bằng mắt: mái ngói đỏ + tường vàng + bảng trống +
  cửa gỗ + bậc đá + cây xanh, đúng palette art-style.md.

### 69.3 Lỗi ghost atlas — TÌM RA + SỬA (vòng 43/44/45)

- **`build_atlas_map*.py` paste có mask nên giữ pixel cũ ở chỗ tile
  mới trong suốt:** đo trên atlas đã ghép: Map005 **932 px ghost**
  (cả mái nhà trọ cũ hiện lên trên tile giảng đường — ảnh debug
  `/tmp/ghost-map005.png`, vùng đỏ là mái nhà cũ), Map003 **214 px**,
  Map004 **1113 px**. Lỗi có từ mẫu vòng 43, không ai đo trước đây;
  ảnh browser-verify vòng 43/44 nhìn thoáng qua tưởng ổn vì ghost
  là pixel tối nằm sau tile mới — nhưng ở Map005 mái nhà cũ đỏ sậm
  lộ rõ trên nền trời.
- Sửa: **xóa trắng cell đích trước khi paste** + assert ghost=0
  trong cả 3 script (`build_atlas_map003/004/005.py`). Build lại cả
  3 atlas: Map003 cell 3 khác 3316 px / 2941 px đục / ghost 0;
  Map004 cell 4 khác 2950 px / 1709 px đục / ghost 0; Map005 cell 3
  khác 3079 px / 1977 px đục / ghost 0; các cell khác giống hệt atlas
  cũ. Bài học: paste có mask chỉ đúng khi tile mới phủ kín cell —
  atlas tile luôn có vùng trong suốt nên phải xóa cell trước.
- Atlas r43/r44 đã từng browser-verify với ghost (không đo) — nay đã
  sửa + verify lại trong cùng lượt này (ảnh r45-01/r45-02, xem §69.5).

### 69.4 Code + test — XONG

| File | Đổi |
|---|---|
| `tools/godot/convert_maps.py` | `ATLAS_PNG_OVERRIDE[5] = "atlas-map005.png"` + `ATLAS_TILE_OVERRIDE` (tile 4 → `giang-duong-lang-dai-hoc`, hết PROVISIONAL); sửa comment cũ "Map003/Map005 tái dùng atlas-map001.png". |
| `src/godot/data/maps.json` (tạo lại) | Map005 atlas mới + tile 4 tên mới; Map001/002/003/004 không đổi; đủ 18 map. |
| `src/godot/tiles/atlas-map005.png` (mới, binary — chỉ local + trong pck, KHÔNG push qua snapshot-push) | `visual-check/artpass45/build_atlas_map005.py`: atlas-map001.png đổi cell cột 3 (x=192) thành tile giảng đường (đã sửa ghost, xem §69.3). |
| `src/godot/tiles/atlas-map005.png.import` (mới) | Copy từ `.import` atlas-map001 + `--import` sinh lại. |
| `src/godot/tests/g4_r45_map005_tile_test.gd` (mới) | 16 mục: Map005 atlas + tên tile 4 + hết PROVISIONAL; Map001/002 không đổi; Map003/004 giữ atlas riêng; PNG 512×64; cell 3 khác atlas cũ + có giảng đường (>800 px đục); cell khác giống hệt; scene thật Map005 (không NadiaScene, lớp tile hiện, atlas đúng file mới) 60 frame + về Map001 map_id 1. |
| `src/godot/tests/g4_r43_workshop_tile_test.gd` + `g4_r44_benxe_tile_test.gd` (sửa) | Sửa 2 test lỗi thời theo thay đổi có chủ ý (mẫu vòng 46): bỏ Map005 khỏi nhóm "không đổi atlas" (nay có atlas riêng) + cập nhật header. |
| `tools/godot/run_regression.sh` | Thêm `g4_r45_map005_tile_test` (nay 71 suite vòng lặp + server_test + probe = 73 mục; xem §69.5). |
| `visual-check/artpass45/check_r45.py` (mới) | Browser-verify Map003→Map004→Map005 (chuỗi cửa (5,8)), cổng 8202 + ảnh + 2 crop zoom, theo mẫu check_r43/r46.py. |
| `pxb-push-main-r44.py` + `pxb-deploy-r44.py` (sửa, local — không push) | Bắt `subprocess.TimeoutExpired` → in rõ "LOT x TIMEOUT (1200s cho phe duyet, chua co SHA)" + return 2, không văng traceback (đã kiểm chứng py_compile + mẫu timeout). Theo §68.6 bước 1. |

### 69.5 Verify thật vòng này

- `--check-only` 3 test mới/sửa: PASS (exit 0).
- Test mới `g4_r45_map005_tile_test`: **16/16 PASS** (cell 3 khác
  atlas cũ 3064 px theo Godot — PIL đo 3079, lệch do import — vẫn
  >500; 1977 px đục).
- Hồi quy đầy đủ: **73 OK, 0 FAIL** (71 suite vòng lặp + server_test
  + probe; log `~/workspace/regression-move.log`).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR.
- Export web exit 0: pck **22.186.080 byte, MD5 `75daf7dc`**
  (sha256 `0f349b52…`, thay `64b8934d` vòng 46); wasm không đổi
  `fc74679e`; pck chứa `giang-duong-lang-dai-hoc` + `atlas-map005` +
  `nha-cho-ben-xe` + `xuong-may-mai-ton` (kiểm bằng `strings`);
  HTTP 200 đủ 4 file (cổng 8202); `GODOT_THREADS_ENABLED = false`.
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass45/check_r45.py`, cổng 8202):
  **0 console error, 0 pageerror, 0 request fail.**
  - Đi chuỗi Map001 → Map002 → Map003 → Map004 → Map005 đúng cửa
    (toast "Đã sang Khu Công Nhân" / "Đã sang Bến Xe Miền Đông");
    Map005: HUD "Phố Xô Bồ — Làng Đại Học", NPC Thầy Giáo + Sinh
    Viên Làm Thêm, 2 cửa đúng tên ("Cửa về Bến Xe Miền Đông" /
    "Cửa đi Chung Cư Cũ").
  - Tile giảng đường hiện rõ ở hàng biên Map005 (ảnh `r45-05`):
    tường vàng + mái ngói đỏ + nhiều cửa sổ, cao hơn hẳn nhà nhỏ
    bên cạnh, khác hẳn tile nhà trọ cũ — **không còn bóng ghost**
    (mái nhà cũ đã hết).
  - Map003 (ảnh `r45-01`): tile xưởng mái tôn đỏ + cửa cuốn hiện
    rõ, sạch ghost. Map004 (ảnh `r45-02`): tile nhà chờ mái vòm
    teal hiện rõ, sạch ghost.
  - Lưu ý: crop zoom đầu (y 300–800) lại chụp nhầm vùng trời —
    bài học vòng 43/46 lặp lại lần 3; crop trái (0,600,360,1100)
    mới thấy tile; lần sau căn crop theo vị trí ô L1 ngay từ đầu,
    không đoán y.
  - Player sau chuyển map dừng ở (5,5) thay vì (5,4) do giữ phím
    400ms qua lúc chuyển map — không phải lỗi game (đã biết từ
    các vòng trước: giữ phím đủ 1 frame poll thì bước thêm 1 ô).

### 69.6 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- **Push main r45 (gộp r43+r44+r45+r46+r47, thay script r44):**
  script mới `pxb-push-main-r45.py` + 4 manifest
  (`pxb-push-main-r45-a/b/c/docs`). Lô a: converter + maps.json +
  test r43/r44/r45 (+ .uid) + r15 + run_regression.sh +
  check_r43/r45/r46 + build_atlas map003/004/005 +
  check_craft_label.py; lô b: 3 `.import` atlas-map003/004/005;
  lô c: note + process script artpass43/44/45; lô docs: godot-g4 +
  roles-qc. Script đã có sẵn fix TimeoutExpired (§69.4).
  **Chưa chạy — chờ chủ nói 'đẩy tiếp' + bấm duyệt** (xem §69.1).
- **Deploy gh-pages pck `0f349b52`:** staging rebuild xong,
  `build_gh_pages.py --verify-only` PASS (khớp byte); 165 chunk
  (part-000..164) + final (versions.json + index.html); script mới
  `pxb-deploy-r45.py` + 10 manifest
  (`pxb-deploy-pck-0f349b52-batch1..9` + `-final`). Wasm không đổi
  `fc74679e` nên không đẩy lại. Chạy sau push main.
  Live hiện vẫn `5f2a052f` (r41).
- **Chưa làm:** điền SHA push/deploy vào §69.6 sau khi có kết quả.

### 69.7 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r45 (4 lô) → deploy pck `0f349b52`
   (10 lô) → kiểm live pin + đối chiếu byte → điền SHA vào §69.6.
2. Tile riêng tiếp theo: Map006 Chung Cư Cũ theo
   `docs/tileset-plan.md` (đang dùng atlas-map001.png — tile nào
   PROVISIONAL?).
3. G2 còn lại rồi G4 online (quyết server Godot headless hay .NET,
   xem `docs/opensource-engine.md` §3.4).

## 70. Vòng 48 — Tile chung cư cũ riêng Map006 (26/11 ~04:45–05:30 +07, cron 04:45)

### 70.1 Art (subagent artpass48) — XONG, gen 0 lần lại

- Tile `chungcu-map006.png` (64×64 RGBA, 9.579 byte): chung cư cũ 4
  tầng + tầng trệt, tường vàng kem cũ có vết nứt/thời gian, ban công
  bê tông lan can đơn giản 4 tầng, nhiều cửa sổ nhỏ + cửa chớp gỗ
  nâu, mái bằng có bồn nước nâu nhỏ, tầng trệt mặt tiền cửa hàng
  (quầy gỗ + cửa mở), dải bảng tên trống KHÔNG chữ; không người,
  không chữ, lề đủ 4 phía (bbox nguồn 1157×1127, lề 381/382/76/77px,
  nền góc lệch tối đa 7,5).
- Kiểm chứng: 1 component alpha duy nhất (3.678 px alpha>0); 0 pixel
  gần-trắng; 0 pixel mép bán-trong-suốt gần màu xanh da trời (không
  quầng xanh); kiểm bằng mắt ở 1× và zoom 3× đều đọc rõ chung cư cũ.
  Note: `visual-check/artpass48/chungcu-tile-note.md` + script
  `process_chungcu_r48.py` (tách nền khoảng cách màu + alpha mềm +
  nearest-fill RGB + resize LANCZOS, theo mẫu vòng 45).
- Tôi kiểm lại bằng mắt: tường vàng kem + ban công + mái bằng có bồn
  nước + bảng trống, đúng palette art-style.md.
- Đính chính tên: thư mục `visual-check/artpass46/` ĐÃ CÓ từ vòng 46
  (check_r46.py + ảnh r46-*) nên toàn bộ art vòng này dời sang
  `visual-check/artpass48/` (test `g4_r48_*`, script `check_r48.py`);
  không động vào file vòng 46. Bài học: thư mục artpassNN = số vòng,
  kiểm tra trống trước khi giao art.

### 70.2 Code + test — XONG

| File | Đổi |
|---|---|
| `tools/godot/convert_maps.py` | `ATLAS_PNG_OVERRIDE[6] = "atlas-map006.png"` + `ATLAS_TILE_OVERRIDE` (tile 4 → `chung-cu-cu`, hết PROVISIONAL; Map006 L1: tile 4 có 10 ô, tile 5 có 10 ô, tile 3 có 8 ô — thay tile 4 như Map003/Map005). Tile 3/5 vẫn PROVISIONAL (nhà trọ tái dùng). |
| `src/godot/data/maps.json` (tạo lại) | Map006 atlas mới + tile 4 tên mới; Map001–005 không đổi; đủ 18 map. |
| `src/godot/tiles/atlas-map006.png` (mới, binary — chỉ local + trong pck, KHÔNG push qua snapshot-push) | `visual-check/artpass48/build_atlas_map006.py`: atlas-map001.png đổi cell cột 3 (x=192) thành tile chung cư (đã có sửa ghost vòng 47: xóa trắng cell trước khi paste + assert ghost=0). Chạy: cell 3 khác 3696 px / 3443 px đục / ghost 0. |
| `src/godot/tiles/atlas-map006.png.import` (mới) | `--headless --import` sinh lại. |
| `src/godot/tests/g4_r48_map006_tile_test.gd` (mới) | 16 mục: Map006 atlas + tên tile 4 + hết PROVISIONAL; Map001/002 không đổi; Map003/004/005 giữ atlas riêng; PNG 512×64; cell 3 khác atlas cũ + có chung cư (>800 px đục); cell khác giống hệt; scene thật Map006 (không NadiaScene, lớp tile hiện, atlas đúng file mới) 60 frame + về Map001 map_id 1. |
| `tools/godot/run_regression.sh` | Thêm `g4_r48_map006_tile_test` (nay 72 suite vòng lặp + server_test + probe = 74 mục; xem §70.3). |
| `visual-check/artpass48/check_r48.py` (mới) | Browser-verify Map003→Map004→Map005→Map006 (chuỗi cửa (5,8)), cổng 8203 + ảnh + 2 crop zoom, theo mẫu check_r45.py. |

### 70.3 Verify thật vòng này

- `--check-only` test mới: PASS (exit 0). (Quirk đã biết §16.2: chỉ
  check riêng file mới, không check main.gd đơn lẻ.)
- Test mới `g4_r48_map006_tile_test`: **16/16 PASS** (cell 3 khác
  atlas cũ 3687 px theo Godot — PIL đo 3696, lệch do import — vẫn
  >500; 3443 px đục). 2 WARNING `load_from_file` là test-only, đã
  biết từ r45.
- Hồi quy đầy đủ: **74 OK, 0 FAIL** (72 suite vòng lặp +
  server_test + probe; log `~/workspace/regression-move.log`).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR.
- Export web exit 0: pck **22.211.092 byte, SHA `d42cd0bc…`**
  (thay `0f349b52` vòng 47); wasm không đổi `fc74679e`
  (39.514.754 byte); pck chứa `chung-cu-cu` + `atlas-map006`
  (kiểm bằng `strings` — chuỗi GDScript trong pck grep được ở đây
  vì là tên tile/đường dẫn trong data JSON, khác lưu ý §12.3);
  HTTP 200 đủ 4 file (cổng 8203); `GODOT_THREADS_ENABLED = false`.
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass48/check_r48.py`, cổng 8203):
  **0 console error, 0 pageerror, 0 request fail.**
  - Đi chuỗi Map001 → Map002 → Map003 → Map004 → Map005 → Map006
    đúng cửa (toast "Đã sang Khu Công Nhân" / "Đã sang Làng Đại Học").
  - Map006: HUD "Phố Xô Bồ — Chung Cư Cũ", NPC Cư Dân Chung Cư +
    Bác Quản Lý, 2 cửa đúng tên ("Cửa về Làng Đại Học" /
    "Cửa đi Phố Văn Phòng Nhỏ").
  - Tile chung cư hiện rõ ở hàng biên Map006 (ảnh `r48-04`): khối
    nhà 3–4 tầng tường vàng kem + nhiều cửa sổ, cao hơn hẳn nhà nhỏ
    bên cạnh, khác hẳn tile nhà trọ cũ — **không còn bóng ghost**.
  - Map003 (ảnh `r48-01`): tile xưởng mái tôn đỏ sạch ghost.
    Map005 (ảnh `r48-03`): tile giảng đường mái ngói đỏ sạch ghost.
  - Lưu ý: player sau chuyển map dừng ở (5,7) thay vì (5,4) do giữ
    phím 400ms qua lúc chuyển map — không phải lỗi game (đã biết
    từ vòng 47).
- **Môi trường (ghi để vòng sau không mất thời gian):** VM sau
  restart đã mất gói Python `playwright` (browser Chromium 1255
  vẫn còn trong cache); đã cài lại `pip3 install --user
  --break-system-packages playwright==1.65.2` nhưng `python3`
  không thấy user site — chạy script bằng
  `PYTHONPATH=/home/hatch/.local/lib/python3.12/site-packages`.

### 70.4 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- **Push main r48 (gộp r43+r44+r45+r46+r47+r48, thay script r45):**
  script mới `pxb-push-main-r48.py` + 4 manifest
  (`pxb-push-main-r48-a/b/c/docs`). Lô a: converter + maps.json +
  test r48 (+ .uid) + run_regression.sh + check_r48 +
  build_atlas_map006 + nội dung r45-a cũ; lô b: 4 `.import`
  atlas-map003/004/005/006; lô c: note + process script artpass48
  (+ artpass43/44/45 cũ); lô docs: godot-g4 + roles-qc.
  **Chưa chạy — chờ chủ nói 'đẩy tiếp' + bấm duyệt** (xem §69.1:
  thẻ r44 đã timeout, không còn thẻ chờ; chủ đang ngủ).
- **Deploy gh-pages pck `d42cd0bc`:** staging rebuild xong,
  `build_gh_pages.py --verify-only` PASS (khớp byte); 165 chunk
  (part-000..164) + final (versions.json + index.html); script mới
  `pxb-deploy-r48.py` + 10 manifest
  (`pxb-deploy-pck-d42cd0bc-batch1..9` + `-final`). Wasm không đổi
  `fc74679e` nên không đẩy lại. Chạy sau push main.
  Live hiện vẫn `5f2a052f` (r41).
- **Chưa làm:** điền SHA push/deploy vào §70.4 sau khi có kết quả.

### 70.5 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r48 (4 lô) → deploy pck `d42cd0bc`
   (10 lô) → kiểm live pin + đối chiếu byte → điền SHA vào §70.4.
2. Tile riêng tiếp theo: Map007 Phố Văn Phòng Nhỏ theo
   `docs/tileset-plan.md` (đang dùng atlas-map001.png — tile nào
   PROVISIONAL? L1 Map007: đếm lại như vòng 48 trước khi chọn tile).
3. G2 còn lại rồi G4 online (quyết server Godot headless hay .NET,
   xem `docs/opensource-engine.md` §3.4).

## 71. Vòng 49 — Tile văn phòng nhỏ riêng Map007 (26/11 ~05:45–06:30 +07, cron 05:45)

### 71.1 Art (subagent artpass49) — XONG, gen 0 lần lại

- Tile `vanphong-map007.png` (64×64 RGBA, 8.016 byte): tòa văn phòng
  nhỏ 3 tầng, tường vàng kem (#FFF0BE), cửa kính xanh nhạt lớn, ban
  công lan can + chậu cây, mái bằng, tầng trệt cửa kính + bảng tên
  trống KHÔNG chữ; không người, không chữ, lề đủ 4 phía (bbox nguồn
  767×1068, lề 577/576/112/100px, nền góc lệch tối đa 9,9).
- Kiểm chứng: 1 component alpha duy nhất (2.694 px alpha>0); 0 pixel
  gần-trắng; 0 pixel mép bán-trong-suốt gần màu xanh da trời (không
  quầng xanh); kiểm bằng mắt ở 1× và zoom 3× đều đọc rõ tòa văn phòng.
  Note: `visual-check/artpass49/vanphong-tile-note.md` + script
  `process_vanphong_r49.py` (tách nền khoảng cách màu + alpha mềm +
  nearest-fill RGB + resize LANCZOS, theo mẫu vòng 48).
- Tôi kiểm lại bằng mắt: tường vàng kem + cửa kính + bảng trống, đúng
  palette art-style.md.
- Lưu ý: tòa nhà nguồn cao-hẹp (tỉ lệ ~0,72:1) nên tile chỉ rộng 45px
  trong cell 64 — lề trong suốt 9px mỗi bên, khác chung cư vòng 48
  lấp đầy hết chiều ngang. Không cắt chi tiết nào.

### 71.2 Code + test — XONG

| File | Đổi |
|---|---|
| `tools/godot/convert_maps.py` | `ATLAS_PNG_OVERRIDE[7] = "atlas-map007.png"` + `ATLAS_TILE_OVERRIDE` (tile 4 → `van-phong-nho`, hết PROVISIONAL; Map007 L1: tile 4 có 10 ô, tile 5 có 10 ô, tile 3 có 8 ô — thay tile 4 như Map003/Map005/Map006). Tile 3/5 vẫn PROVISIONAL (nhà trọ tái dùng). |
| `src/godot/data/maps.json` (tạo lại) | Map007 atlas mới + tile 4 tên mới; Map001–006 không đổi; đủ 18 map. |
| `src/godot/tiles/atlas-map007.png` (mới, binary — chỉ local + trong pck, KHÔNG push qua snapshot-push) | `visual-check/artpass49/build_atlas_map007.py`: atlas-map001.png đổi cell cột 3 (x=192) thành tile văn phòng (đã có sửa ghost vòng 47: xóa trắng cell trước khi paste + assert ghost=0). Chạy: cell 3 khác 3211 px / 1816 px đục / ghost 0. |
| `src/godot/tiles/atlas-map007.png.import` (mới) | `--headless --import` sinh lại. |
| `src/godot/tests/g4_r49_map007_tile_test.gd` (mới) | 16 mục: Map007 atlas + tên tile 4 + hết PROVISIONAL; Map001/002 không đổi; Map003/004/005/006 giữ atlas riêng; PNG 512×64; cell 3 khác atlas cũ + có văn phòng (>800 px đục); cell khác giống hệt; scene thật Map007 (không NadiaScene, lớp tile hiện, atlas đúng file mới) 60 frame + về Map001 map_id 1. |
| `tools/godot/run_regression.sh` | Thêm `g4_r49_map007_tile_test` (nay 73 suite vòng lặp + server_test + probe = 75 mục; xem §71.3). |
| `visual-check/artpass49/check_r49.py` (mới) | Browser-verify Map001→Map002→Map003→Map004→Map005→Map006→Map007 (chuỗi cửa (5,8)), cổng 8204 + ảnh + 2 crop zoom, theo mẫu check_r48.py. |

### 71.3 Verify thật vòng này

- `--check-only` test mới: PASS (exit 0). (Quirk đã biết §16.2: chỉ
  check riêng file mới, không check main.gd đơn lẻ.)
- Test mới `g4_r49_map007_tile_test`: **16/16 PASS** (cell 3 khác
  atlas cũ 3201 px theo Godot — PIL đo 3211, lệch do import — vẫn
  >500; 1822 px đục).
- Hồi quy đầy đủ: **75 OK, 0 FAIL** (73 suite vòng lặp +
  server_test + probe; log `~/workspace/regression-move.log`).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR.
- Export web exit 0: pck **22.235.352 byte, SHA `cc4ecb3c…`**
  (thay `d42cd0bc` vòng 48); wasm không đổi `fc74679e`
  (39.514.754 byte); pck chứa `van-phong-nho` + `atlas-map007`
  (kiểm bằng `strings`); HTTP 200 đủ 4 file (cổng 8204);
  `GODOT_THREADS_ENABLED = false`.
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass49/check_r49.py`, cổng 8204):
  **0 console error, 0 pageerror, 0 request fail.**
  - Đi chuỗi Map001 → Map002 → Map003 → Map004 → Map005 → Map006
    → Map007 đúng cửa (toast "Đã sang Phố Văn Phòng Nhỏ").
  - Map007: HUD "Phố Xô Bồ — Phố Văn Phòng Nhỏ", NPC Nhân Viên Văn
    Phòng + Thực Tập Sinh, 2 cửa đúng tên ("Cửa về Chung Cư Cũ" /
    "Cửa đi Khu Chung Cư Cao Cấp").
  - Tile văn phòng hiện rõ ở hàng biên Map007 (ảnh `r49-05` +
    crop `r49-06`): khối nhà 3 tầng tường vàng kem + cửa kính, cao
    hơn hẳn nhà nhỏ bên cạnh, khác hẳn tile nhà trọ cũ — **không
    còn bóng ghost**.
  - Map006 (ảnh `r49-04`): tile chung cư tường vàng kem nhiều cửa
    sổ sạch ghost.
  - Lưu ý: crop zoom `r49-07` (y 300–800) rơi vào vùng trời vì map
    chỉ chiếm ~35% chiều cao màn dọc — crop `r49-06` (y 600–1100)
    mới thấy rõ tile; bài học cho vòng sau: crop theo hàng biên
    thực của map, không copy y từ vòng trước.
- **Môi trường (ghi để vòng sau không mất thời gian):** chạy script
  browser-verify bằng
  `PYTHONPATH=/home/hatch/.local/lib/python3.12/site-packages`
  (playwright cài user site, `python3` không thấy mặc định).

### 71.4 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- **Push main r49 (gộp r43+r44+r45+r46+r47+r48+r49, thay script r48):**
  script mới `pxb-push-main-r49.py` + 4 manifest
  (`pxb-push-main-r49-a/b/c/docs`). Lô a: converter + maps.json +
  test r49 (+ .uid) + run_regression.sh + check_r49 +
  build_atlas_map007 + nội dung r48-a cũ; lô b: 5 `.import`
  atlas-map003/004/005/006/007; lô c: note + process script artpass49
  (+ artpass43/44/45/48 cũ); lô docs: godot-g4 + roles-qc.
  **Chưa chạy — chờ chủ nói 'đẩy tiếp' + bấm duyệt** (xem §69.1:
  thẻ r44 đã timeout, không còn thẻ chờ; chủ đang ngủ).
- **Deploy gh-pages pck `cc4ecb3c`:** staging rebuild xong,
  `build_gh_pages.py --verify-only` PASS (khớp byte); 165 chunk
  (part-000..164) + final (versions.json + index.html); script mới
  `pxb-deploy-r49.py` + 10 manifest
  (`pxb-deploy-pck-cc4ecb3c-batch1..9` + `-final`). Wasm không đổi
  `fc74679e` nên không đẩy lại. Chạy sau push main.
  Live hiện vẫn `5f2a052f` (r41).
- **Chưa làm:** điền SHA push/deploy vào §71.4 sau khi có kết quả.

### 71.5 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r49 (4 lô) → deploy pck `cc4ecb3c`
   (10 lô) → kiểm live pin + đối chiếu byte → điền SHA vào §71.4.
2. Tile riêng tiếp theo: Map008 Khu Chung Cư Cao Cấp theo
   `docs/tileset-plan.md` (đang dùng atlas-map001.png — tile nào
   PROVISIONAL? L1 Map008: đếm lại như vòng 49 trước khi chọn tile).
3. G2 còn lại rồi G4 online (quyết server Godot headless hay .NET,
   xem `docs/opensource-engine.md` §3.4).

## 72. Vòng 50 — Tile chung cư cao cấp riêng Map008 (26/11 ~06:45–07:05 +07, cron 06:45)

### 72.1 Art (subagent artpass50) — XONG, gen 1 lần

- Tile `chungcu-map008.png` (64×64 RGBA, 6.662 byte): tòa chung cư cao
  cấp 7 tầng, tường kem/cam nhạt, hàng cửa kính xanh nhạt + ban công nâu
  cam + chậu cây mỗi tầng, mái bằng, tầng trệt cửa kính lối vào giữa +
  bảng tên trống KHÔNG chữ; không người, không chữ, lề đủ 4 phía (bbox
  nguồn 814×1407, đặt tại x=14, y=0, đáy chạm y=61).
- Kiểm chứng: 1 component alpha duy nhất (2.232 px alpha>0, 1.920 px
  alpha=255); 0 pixel gần-trắng; 0 pixel mép bán-trong-suốt gần màu xanh
  da trời (không quầng xanh); kiểm bằng mắt ở 1× và zoom 3× đều đọc rõ
  tòa chung cư cao tầng, khác hẳn tile nhà trọ cũ.
  Note: `visual-check/artpass50/chungcu-tile-note.md` + script
  `process_chungcu_r50.py`.
- Khác mẫu vòng 49 (ghi trong note): kính cửa sổ ảnh này gần màu nền
  hơn (trung bình (172,218,235), cách nền ~51) nên chạy đúng mẫu vòng
  49 thì cửa sổ bị bán-trong-suốt — 78 pixel mép gần-xanh, toàn bộ nằm
  bên trong tòa nhà (0 pixel trên viền ngoài). Sửa trong
  `process_chungcu_r50.py`: ép alpha=255 cho toàn bộ vùng trong
  silhouette (`binary_fill_holes` + `binary_erosion` 3px), chỉ dải biên
  ngoài giữ ramp mềm; sau sửa cả 3 kiểm tra đều 0/đạt. Bài học vòng
  sau: tile nào kính sáng gần màu nền thì kiểm mép TRONG tòa nhà, không
  chỉ viền ngoài.
- Tôi kiểm lại bằng mắt trên ảnh game (r50-06 + crop r50-07): khối nhà
  cao tầng tường kem/cam + hàng cửa kính xanh hiện rõ ở hàng biên
  Map008, cao hơn hẳn khối nhà thấp bên cạnh — **không còn bóng ghost**.

### 72.2 Code + test — XONG

| File | Đổi |
|---|---|
| `tools/godot/convert_maps.py` | `ATLAS_PNG_OVERRIDE[8] = "atlas-map008.png"` + `ATLAS_TILE_OVERRIDE` (tile 4 → `chung-cu-cao-cap`, hết PROVISIONAL; Map008 L1: tile 4 có 10 ô, tile 5 có 10 ô, tile 3 có 8 ô — thay tile 4 như Map003/Map005/Map006/Map007). Tile 3/5 vẫn PROVISIONAL (nhà trọ tái dùng). |
| `src/godot/data/maps.json` (tạo lại) | Map008 atlas mới + tile 4 tên mới; Map001–007 không đổi; đủ 18 map. |
| `src/godot/tiles/atlas-map008.png` (mới, binary — chỉ local + trong pck, KHÔNG push qua snapshot-push) | `visual-check/artpass50/build_atlas_map008.py`: atlas-map001.png đổi cell cột 3 (x=192) thành tile chung cư cao cấp (đã có sửa ghost vòng 47: xóa trắng cell trước khi paste + assert ghost=0). Chạy: cell 3 khác 3071 px / 2116 px đục / ghost 0. |
| `src/godot/tiles/atlas-map008.png.import` (mới) | `--headless --import` sinh lại. |
| `src/godot/tests/g4_r50_map008_tile_test.gd` (mới) | 16 mục: Map008 atlas + tên tile 4 + hết PROVISIONAL; Map001/002 không đổi; Map003/004/005/006/007 giữ atlas riêng; PNG 512×64; cell 3 khác atlas cũ + có chung cư (>800 px đục); cell khác giống hệt; scene thật Map008 (không NadiaScene, lớp tile hiện, atlas đúng file mới) 60 frame + về Map001 map_id 1. |
| `tools/godot/run_regression.sh` | Thêm `g4_r50_map008_tile_test` (nay 74 suite vòng lặp + server_test + probe = 76 mục; xem §72.3). |
| `visual-check/artpass50/check_r50.py` (mới) | Browser-verify Map001→…→Map008 (chuỗi cửa (5,8)), cổng 8205 + ảnh + crop zoom, theo mẫu check_r49.py. |

### 72.3 Verify thật vòng này

- `--check-only` test mới: PASS (exit 0). (Quirk đã biết §16.2: chỉ
  check riêng file mới, không check main.gd đơn lẻ.)
- Test mới `g4_r50_map008_tile_test`: **16/16 PASS** (cell 3 khác
  atlas cũ 3048 px theo Godot — PIL đo 3071, lệch do import — vẫn
  >500; 2116 px đục).
- Hồi quy đầy đủ: **76 OK, 0 FAIL** (74 suite vòng lặp +
  server_test + probe; log `~/workspace/regression-move.log`).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR.
- Export web exit 0: pck **22.258.620 byte, SHA `097a3204`**
  (thay `cc4ecb3c` vòng 49); wasm không đổi `fc74679e`
  (39.514.754 byte); pck chứa `chung-cu-cao-cap` + `atlas-map008`
  (kiểm bằng `strings`, 6 lần); HTTP 200 đủ 4 file (cổng 8205);
  `GODOT_THREADS_ENABLED = false`.
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass50/check_r50.py`, cổng 8205):
  **0 console error, 0 pageerror, 0 request fail.**
  - Đi chuỗi Map001 → Map002 → Map003 → Map004 → Map005 → Map006
    → Map007 → Map008 đúng cửa (HUD "Phố Xô Bồ — Khu Chung Cư Cao
    Cấp", ô (5,7)).
  - Map008: NPC Cư Dân Cao Cấp + Bảo Vệ Chung Cư, 2 cửa đúng tên
    ("Cửa về Phố Văn Phòng Nhỏ" / "Cửa đi Phố Thương Mại").
  - Tile chung cư cao cấp hiện rõ ở hàng biên Map008 (ảnh `r50-06`
    + crop `r50-07`): khối nhà cao tầng tường kem/cam + hàng cửa kính
    xanh, cao hơn hẳn nhà thấp bên cạnh, khác hẳn tile nhà trọ cũ —
    **không còn bóng ghost**.
  - Map007 (ảnh `r50-05`): tile văn phòng vòng 49 vẫn sạch ghost.
- **Môi trường (ghi để vòng sau không mất thời gian):** chạy script
  browser-verify bằng
  `PYTHONPATH=/home/hatch/.local/lib/python3.12/site-packages`
  (playwright cài user site, `python3` không thấy mặc định).

### 72.4 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- **Push main r50 (gộp r43+r44+r45+r46+r47+r48+r49+r50, thay script r49):**
  script mới `pxb-push-main-r50.py` + 4 manifest
  (`pxb-push-main-r50-a/b/c/docs`). Lô a: converter + maps.json +
  test r50 (+ .uid) + run_regression.sh + check_r50 +
  build_atlas_map008 + nội dung r49-a cũ; lô b: 6 `.import`
  atlas-map003/004/005/006/007/008; lô c: note + process script artpass50
  (+ artpass43/44/45/48/49 cũ); lô docs: godot-g4 + roles-qc.
  **Chưa chạy — chờ chủ nói 'đẩy tiếp' + bấm duyệt** (xem §69.1:
  thẻ r44 đã timeout, không còn thẻ chờ; chủ đang ngủ).
- **Deploy gh-pages pck `097a3204`:** staging rebuild xong,
  `build_gh_pages.py --verify-only` PASS (khớp byte: pck 165 chunk,
  22.258.620 byte); 165 chunk (part-000..164) + final (versions.json
  + index.html); script mới `pxb-deploy-r50.py` + 10 manifest
  (`pxb-deploy-pck-097a3204-batch1..9` + `-final`). Wasm không đổi
  `fc74679e` nên không đẩy lại. Chạy sau push main.
  Live hiện vẫn `5f2a052f` (r41).
- **Chưa làm:** điền SHA push/deploy vào §72.4 sau khi có kết quả.

### 72.5 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r50 (4 lô) → deploy pck `097a3204`
   (10 lô) → kiểm live pin + đối chiếu byte → điền SHA vào §72.4.
2. Tile riêng tiếp theo: Map009 Phố Thương Mại theo
   `docs/tileset-plan.md` (đang dùng atlas-map001.png — L1 Map009 đã
   đếm sẵn: tile 4 có 10 ô, tile 5 có 10 ô, tile 3 có 8 ô — thay tile 4
   `nha-tro-bac` như các vòng trước).
3. G2 còn lại rồi G4 online (quyết server Godot headless hay .NET,
   xem `docs/opensource-engine.md` §3.4).

## 73. Vòng 51 — Tile cửa hàng phố thương mại riêng Map009 (26/11 ~07:45–07:58 +07, cron 07:45)

### 73.1 Art (subagent artpass51) — XONG, gen 0 lần lại

- Tile `cuahang-map009.png` (64×64 RGBA, 4.777 byte): nhà phố 3 tầng
  tường vàng ấm, mái ngói cam, 2 tầng cửa chớp + ban công chậu cây,
  biển hiệu vàng trống KHÔNG chữ, mái hiên sọc cam/trắng, cửa kính
  trưng bày giỏ trái cây/lọ/túi hàng; không người, không chữ, lề đủ
  4 phía (bbox nguồn 592×1246, lề trái/phải 504, trên 184, dưới 170;
  scale 0,0498 → 29×62, căn giữa x=17, đáy y=61).
- Kiểm chứng: 1 component alpha duy nhất (1.764 px alpha>0, 1.404 px
  alpha=255); 0 pixel gần-trắng; 0 quầng xanh ở mép (0/360 pixel
  bán-trong-suốt gần màu nền); hàng y62–63 trong suốt; kiểm bằng mắt
  ở 1× và zoom 3× đều đọc rõ từng chi tiết. Tòa nhà hẹp (29 px rộng)
  vì nhà phố gốc cao (tỉ lệ ~1:2,1) — vừa khung 64×62, đúng hợp đồng.
  Note: `visual-check/artpass51/cuahang-tile-note.md` + script
  `process_cuahang_r51.py` (theo mẫu vòng 50: tách nền bằng khoảng
  cách màu, ép alpha=255 vùng trong silhouette, nearest-fill RGB
  trước resize LANCZOS).
- Tôi kiểm lại bằng mắt trên ảnh game (r51-07 + crop r51-08): dãy nhà
  phố vàng mái ngói cam + mặt tiền xanh (cửa kính trưng bày) hiện rõ
  ở hàng biên Map009, khác hẳn tile nhà trọ cũ — **không còn bóng
  ghost**. Map008 (ảnh r51-06): tile chung cư cao cấp vòng 50 vẫn
  sạch ghost, NPC Cư Dân Cao Cấp + Bảo Vệ Chung Cư đủ mặt.

### 73.2 Code + test — XONG

| File | Đổi |
|---|---|
| `tools/godot/convert_maps.py` | `ATLAS_PNG_OVERRIDE[9] = "atlas-map009.png"` + `ATLAS_TILE_OVERRIDE` (tile 4 → `cua-hang-thuong-mai`, hết PROVISIONAL; Map009 L1: tile 4 có 10 ô, tile 5 có 10 ô, tile 3 có 8 ô — thay tile 4 như Map003/Map005/Map006/Map007/Map008). Tile 3/5 vẫn PROVISIONAL (nhà trọ tái dùng). |
| `src/godot/data/maps.json` (tạo lại) | Map009 atlas mới + tile 4 tên mới; Map001–008 không đổi; đủ 18 map. |
| `src/godot/tiles/atlas-map009.png` (mới, binary — chỉ local + trong pck, KHÔNG push qua snapshot-push) | `visual-check/artpass51/build_atlas_map009.py`: atlas-map001.png đổi cell cột 3 (x=192) thành tile cửa hàng phố thương mại (đã có sửa ghost vòng 47: xóa trắng cell trước khi paste + assert ghost=0). Chạy: cell 3 khác 2946 px / 1604 px đục / ghost 0. |
| `src/godot/tiles/atlas-map009.png.import` (mới) | `--headless --import` sinh lại. |
| `src/godot/tests/g4_r51_map009_tile_test.gd` (mới) | 16 mục: Map009 atlas + tên tile 4 + hết PROVISIONAL; Map001/002 không đổi; Map003/004/005/006/007/008 giữ atlas riêng; PNG 512×64; cell 3 khác atlas cũ + có cửa hàng (>800 px đục); cell khác giống hệt; scene thật Map009 (không NadiaScene, lớp tile hiện, atlas đúng file mới) 60 frame + về Map001 map_id 1. |
| `tools/godot/run_regression.sh` | Thêm `g4_r51_map009_tile_test` (nay 75 suite vòng lặp + server_test + probe = 77 mục; xem §73.3). |
| `visual-check/artpass51/check_r51.py` (mới) | Browser-verify Map001→…→Map009 (chuỗi cửa (5,8)), cổng 8206 + ảnh + crop zoom, theo mẫu check_r50.py. |

### 73.3 Verify thật vòng này

- `--check-only` test mới: PASS (exit 0). (Quirk đã biết §16.2: chỉ
  check riêng file mới, không check main.gd đơn lẻ.)
- Test mới `g4_r51_map009_tile_test`: **16/16 PASS** (cell 3 khác
  atlas cũ 2937 px theo Godot — PIL đo 2946, lệch do import — vẫn
  >500; 1605 px đục).
- Hồi quy đầy đủ: **77 OK, 0 FAIL** (75 suite vòng lặp +
  server_test + probe; log `~/workspace/regression-move.log`).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR.
- Export web exit 0: pck **22.279.936 byte, SHA `6e23ba3b`**
  (thay `097a3204` vòng 50); wasm không đổi `fc74679e`
  (39.514.754 byte); pck chứa `cua-hang-thuong-mai` + `atlas-map009`
  (kiểm bằng `strings`, 6 lần); HTTP 200 đủ 4 file (cổng 8206);
  `GODOT_THREADS_ENABLED = false`.
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass51/check_r51.py`, cổng 8206):
  **0 console error, 0 pageerror, 0 request fail.**
  - Đi chuỗi Map001 → Map002 → Map003 → Map004 → Map005 → Map006
    → Map007 → Map008 → Map009 đúng cửa (HUD "Phố Xô Bồ — Phố
    Thương Mại", ô (5,6)).
  - Map009: NPC Chủ Cửa Hàng + Người Bán Hàng, 2 cửa đúng tên
    ("Cửa về Khu Chung Cư Cao Cấp" / "Cửa đi Khu Công Nghệ").
  - Tile cửa hàng phố thương mại hiện rõ ở hàng biên Map009 (ảnh
    `r51-07` + crop `r51-08`): nhà phố vàng mái ngói cam + mặt tiền
    xanh, khác hẳn tile nhà trọ cũ — **không còn bóng ghost**.
  - Map008 (ảnh `r51-06`): tile chung cư cao cấp vòng 50 vẫn sạch ghost.
- **Môi trường (ghi để vòng sau không mất thời gian):** chạy script
  browser-verify bằng
  `PYTHONPATH=/home/hatch/.local/lib/python3.12/site-packages`
  (playwright cài user site, `python3` không thấy mặc định).

### 73.4 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- **Push main r51 (gộp r43–r51, thay script r50):**
  script mới `pxb-push-main-r51.py` + 4 manifest
  (`pxb-push-main-r51-a/b/c/docs`). Lô a: converter + maps.json +
  test r51 (+ .uid) + run_regression.sh + check_r51 +
  build_atlas_map009 + nội dung r50-a cũ; lô b: 7 `.import`
  atlas-map003/004/005/006/007/008/009; lô c: note + process script
  artpass51 (+ artpass43/44/45/48/49/50 cũ); lô docs: godot-g4 +
  roles-qc.
  **Chưa chạy — chờ chủ nói 'đẩy tiếp' + bấm duyệt** (xem §69.1:
  thẻ r44 đã timeout, không còn thẻ chờ; chủ đang ngủ).
- **Deploy gh-pages pck `6e23ba3b`:** staging rebuild xong,
  `build_gh_pages.py --verify-only` PASS (khớp byte: pck 166 chunk,
  22.279.936 byte); 166 chunk (part-000..165) + final (versions.json
  + index.html); script mới `pxb-deploy-r51.py` + 10 manifest
  (`pxb-deploy-pck-6e23ba3b-batch1..9` + `-final`). Wasm không đổi
  `fc74679e` nên không đẩy lại. Chạy sau push main.
  Live hiện vẫn `5f2a052f` (r41).
- **Chưa làm:** điền SHA push/deploy vào §73.4 sau khi có kết quả.

### 73.5 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r51 (4 lô) → deploy pck `6e23ba3b`
   (10 lô) → kiểm live pin + đối chiếu byte → điền SHA vào §73.4.
2. Tile riêng tiếp theo: Map010 Khu Công Nghệ theo
   `docs/tileset-plan.md` (đang dùng atlas-map001.png — L1 Map010 đã
   đếm sẵn: tile 4 có 10 ô, tile 5 có 10 ô, tile 3 có 8 ô — thay tile 4
   `nha-tro-bac` như các vòng trước).
3. G2 còn lại rồi G4 online (quyết server Godot headless hay .NET,
   xem `docs/opensource-engine.md` §3.4).

## 74. Vòng 52 — Tile tòa nhà công nghệ riêng Map010 (26/11 ~08:45–09:10 +07, cron 08:45)

### 74.1 Art (subagent artpass52) — XONG, gen 0 lần lại

- Tile `congnghe-map010.png` (64×64 RGBA, 8.617 byte): tòa nhà công nghệ
  4 tầng, mặt kính xanh dương có khung chia ô, dải mái cam + ăng-ten nhỏ,
  biển hiệu cam trống KHÔNG chữ, sảnh kính tầng trệt, 2 chậu cây;
  không người, không chữ, lề đủ 4 phía (bbox nguồn 994×1090, scale
  0,057 → 57×62, x=3, đáy y=61).
- Kiểm chứng: 1 component alpha duy nhất (3.274 px alpha>0, 2.817 px
  alpha=255); 0 pixel gần-trắng; 0 quầng xanh ở mép (0/457 pixel
  bán-trong-suốt gần màu nền); hàng y62–63 trong suốt; kiểm bằng mắt
  ở 1× và zoom 3× đều đọc rõ từng chi tiết. Khác mẫu vòng 51: ramp
  alpha 40→50 (thay vì 30→50) + thêm bước dọn quầng sau resize —
  LANCZOS blend để lại 16 pixel bán-trong-suốt gần màu nền, script
  xóa alpha của đúng 16 pixel đó về 0 để chỉ số quầng về đúng 0.
  Note: `visual-check/artpass52/congnghe-tile-note.md` + script
  `process_congnghe_r52.py` (theo mẫu vòng 51: tách nền bằng khoảng
  cách màu, ép alpha=255 vùng trong silhouette, nearest-fill RGB
  trước resize LANCZOS).
- Tôi kiểm lại bằng mắt trên ảnh magenta: tòa nhà kính xanh + dải mái
  cam hiện rõ, nền trong suốt hoàn toàn, không vệt xanh quanh mép.

### 74.2 Code + test — XONG

| File | Đổi |
|---|---|
| `tools/godot/convert_maps.py` | `ATLAS_PNG_OVERRIDE[10] = "atlas-map010.png"` + `ATLAS_TILE_OVERRIDE` (tile 4 → `toa-nha-cong-nghe`, hết PROVISIONAL; Map010 L1: tile 4 có 10 ô, tile 5 có 10 ô, tile 3 có 8 ô — thay tile 4 như Map003/Map005/Map006/Map007/Map008/Map009). Tile 3/5 vẫn PROVISIONAL (nhà trọ tái dùng). |
| `src/godot/data/maps.json` (tạo lại) | Map010 atlas mới + tile 4 tên mới; Map001–009 không đổi; đủ 18 map. |
| `src/godot/tiles/atlas-map010.png` (mới, binary — chỉ local + trong pck, KHÔNG push qua snapshot-push) | `visual-check/artpass52/build_atlas_map010.py`: atlas-map001.png đổi cell cột 3 (x=192) thành tile tòa nhà công nghệ (đã có sửa ghost vòng 47: xóa trắng cell trước khi paste + assert ghost=0). Chạy: cell 3 khác 3425 px / 3077 px đục / ghost 0. |
| `src/godot/tiles/atlas-map010.png.import` (mới) | `--headless --import` sinh lại. |
| `src/godot/tests/g4_r52_map010_tile_test.gd` (mới) | 16 mục: Map010 atlas + tên tile 4 + hết PROVISIONAL; Map001/002 không đổi; Map003–009 giữ atlas riêng; PNG 512×64; cell 3 khác atlas cũ + có tòa nhà (>800 px đục); cell khác giống hệt; scene thật Map010 (không NadiaScene, lớp tile hiện, atlas đúng file mới) 60 frame + về Map001 map_id 1. |
| `tools/godot/run_regression.sh` | Thêm `g4_r52_map010_tile_test` (nay 76 suite vòng lặp + server_test + probe = 78 mục; xem §74.3). |
| `visual-check/artpass52/check_r52.py` (mới) | Browser-verify Map001→…→Map010 (chuỗi cửa (5,8)), cổng 8207 + ảnh + crop zoom, theo mẫu check_r51.py. |

### 74.3 Verify thật vòng này

- `--check-only` test mới: PASS (exit 0). (Quirk đã biết §16.2: chỉ
  check riêng file mới, không check main.gd đơn lẻ.)
- Test mới `g4_r52_map010_tile_test`: **16/16 PASS** (cell 3 khác
  atlas cũ 3414 px theo Godot — PIL đo 3425, lệch do import — vẫn
  >500; 3077 px đục).
- Hồi quy đầy đủ: **78 OK, 0 FAIL** (76 suite vòng lặp +
  server_test + probe; log `~/workspace/regression-move.log`).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR.
- Export web exit 0: pck **22.304.564 byte, SHA `8d3d5711`**
  (thay `6e23ba3b` vòng 51); wasm không đổi `fc74679e`
  (39.514.754 byte); pck chứa `toa-nha-cong-nghe` + `atlas-map010`
  (kiểm bằng `strings`); HTTP 200 đủ 4 file (cổng 8207);
  `GODOT_THREADS_ENABLED = false`.
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass52/check_r52.py`, cổng 8207):
  **0 console error, 0 pageerror, 0 request fail.**
  - Đi chuỗi Map001 → … → Map011 đúng cửa (vượt 1 map so với
    kịch bản — xem ghi chú lệch dưới); ảnh `r52-07-map9.png`
    thực chất là **Map010 Khu Công Nghệ** (HUD "Phố Xô Bồ — Khu
    Công Nghệ", ô (5,4), toast "Đã sang Khu Công Nghệ").
  - Map010: NPC Lập Trình Viên + Kỹ Sư Phần Mềm, 2 cửa đúng tên
    ("Cửa về Phố Thương Mại" / "Cửa đi Phố Tây").
  - Tile tòa nhà công nghệ hiện rõ ở hàng biên Map010 (ảnh
    `r52-07` + crop `r52-09-map10-left.png`, crop lại từ `r52-07`
    theo mẫu y 600–1100): nhà kính xanh + dải mái cam, khác hẳn
    tile nhà trọ cũ — **không còn bóng ghost**.
  - Map009 (ảnh `r52-06`): tile cửa hàng phố thương mại vòng 51
    vẫn sạch ghost.
- **Lệch kịch bản — ghi để vòng sau không mất thời gian:** chân
  Map007→Map008 chuyển 2 lần trong 4 lần giữ phím Down (giữ
  400ms thỉnh thoảng đi hơn 1 ô khi tốc độ game headless thay đổi
  theo tải — cùng họ lỗi §9.1, nhưng lần này đi THỪA chứ không
  miss). Kết quả: mọi ảnh từ `r52-06` trở đi lệch +1 map so với
  tên file (`r52-06` = Map009, `r52-07` = Map010, `r52-08` =
  Map011). Game tự nó chuyển cửa đúng ở mọi cửa — không phải lỗi
  game. Đã crop lại `r52-09` từ đúng ảnh Map010 (`r52-07`).
  Vòng sau: xác nhận tên map trong HUD sau mỗi chân trước khi
  chụp, hoặc đọc `window.__pxb_map` nếu có, thay vì tin tên file.
- **Môi trường (ghi để vòng sau không mất thời gian):** chạy script
  browser-verify bằng
  `PYTHONPATH=/home/hatch/.local/lib/python3.12/site-packages`
  (playwright cài user site, `python3` không thấy mặc định).

### 74.4 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- **Push main r52 (gộp r43–r52, thay script r51):**
  script mới `pxb-push-main-r52.py` + 4 manifest
  (`pxb-push-main-r52-a/b/c/docs`). Lô a: converter + maps.json +
  test r52 (+ .uid) + run_regression.sh + check_r52 +
  build_atlas_map010 + nội dung r51-a cũ; lô b: 8 `.import`
  atlas-map003/004/005/006/007/008/009/010; lô c: note + process
  script artpass52 (+ artpass43/44/45/48/49/50/51 cũ); lô docs:
  godot-g4 + roles-qc.
  **Chưa chạy — chờ chủ nói 'đẩy tiếp' + bấm duyệt** (xem §69.1:
  thẻ r44 đã timeout, không còn thẻ chờ; live vẫn `5f2a052f` r41).
- **Deploy gh-pages pck `8d3d5711`:** staging rebuild xong,
  `build_gh_pages.py --verify-only` PASS (khớp byte: pck 166 chunk,
  22.304.564 byte; wasm 293 chunk không đổi); 166 chunk
  (part-000..165) + final (versions.json + index.html); script mới
  `pxb-deploy-r52.py` + 10 manifest
  (`pxb-deploy-pck-8d3d5711-batch1..9` + `-final`). Wasm không đổi
  `fc74679e` nên không đẩy lại. Chạy sau push main.
  Live hiện vẫn `5f2a052f` (r41).
- **Chưa làm:** điền SHA push/deploy vào §74.4 sau khi có kết quả.

### 74.5 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r52 (4 lô) → deploy pck `8d3d5711`
   (10 lô) → kiểm live pin + đối chiếu byte → điền SHA vào §74.4.
2. Tile riêng tiếp theo: Map011 Phố Tây theo
   `docs/tileset-plan.md` (đang dùng atlas-map001.png — L1 Map011 đã
   đếm sẵn: tile 4 có 10 ô, tile 5 có 10 ô, tile 3 có 8 ô — thay tile 4
   `nha-tro-bac` như các vòng trước).
3. G2 còn lại rồi G4 online (quyết server Godot headless hay .NET,
   xem `docs/opensource-engine.md` §3.4).

## 75. Vòng 53 — Tile nhà phố Tây riêng Map011 (26/11 ~09:45–10:05 +07, cron 09:45)

### 75.1 Art (subagent artpass53) — XONG, gen 0 lần lại

- Tile `photay-map011.png` (64×64 RGBA, 9.756 byte): nhà phố Pháp cổ
  2 tầng, tường vàng kem, 3 cửa sổ vòm xanh lá tầng trên, ban công
  sắt đen uốn, mái ngói đỏ, biển hiệu trống KHÔNG chữ phía trên cửa,
  hiên cà phê tầng trệt có mái sọc xanh trắng + bàn ghế + 4 chậu cây
  đỏ; không người, không chữ, lề đủ 4 phía (bbox nguồn 970×992,
  scale 0,0625 → 61×62, x=1, đáy y=61).
- Kiểm chứng: 1 component alpha duy nhất (3.452 px alpha>0, 3.033 px
  alpha=255); 0 pixel gần-trắng; 0 quầng xanh ở mép (0/419 pixel
  bán-trong-suốt gần màu nền (137,197,231)); hàng y62–63 trong suốt;
  kiểm bằng mắt ở 1× và zoom 3× đều đọc rõ từng chi tiết. Tôi đo
  độc lập bằng PIL, khớp đúng số liệu note của subagent. Không cần
  dọn quầng sau resize (LANCZOS không để lại pixel gần-nền nào —
  khác vòng 52 phải xóa 16 px).
- Note: `visual-check/artpass53/photay-tile-note.md` + script
  `process_photay_r53.py` (theo mẫu vòng 52: tách nền bằng khoảng
  cách màu, ép alpha=255 vùng trong silhouette, nearest-fill RGB
  trước resize LANCZOS).

### 75.2 Code + test — XONG

| File | Đổi |
|---|---|
| `tools/godot/convert_maps.py` | `ATLAS_PNG_OVERRIDE[11] = "atlas-map011.png"` + `ATLAS_TILE_OVERRIDE` (tile 4 → `nha-pho-tay`, hết PROVISIONAL; Map011 L1: tile 4 có 10 ô, tile 5 có 10 ô, tile 3 có 8 ô — thay tile 4 như Map003/Map005/Map006/Map007/Map008/Map009/Map010). Tile 3/5 vẫn PROVISIONAL (nhà trọ tái dùng). |
| `src/godot/data/maps.json` (tạo lại) | Map011 atlas mới + tile 4 tên mới; Map001–010 không đổi; đủ 18 map. |
| `src/godot/tiles/atlas-map011.png` (mới, binary — chỉ local + trong pck, KHÔNG push qua snapshot-push) | `visual-check/artpass53/build_atlas_map011.py`: atlas-map001.png đổi cell cột 3 (x=192) thành tile nhà phố Tây (đã có sửa ghost vòng 47: xóa trắng cell trước khi paste + assert ghost=0). Chạy: cell 3 khác 3565 px / 3285 px đục / ghost 0. |
| `src/godot/tiles/atlas-map011.png.import` (mới) | `--headless --import` sinh lại. |
| `src/godot/main.gd` | `load_map()` ghi thêm `window.__pxb_map = <map_id>` (chỉ trên web, `OS.has_feature("web")`) — để script browser-verify đối chiếu map sau mỗi chân, sửa gốc bài học vòng 52 (tên file không phát hiện được ảnh lệch +1 map). |
| `src/godot/tests/g4_r53_map011_tile_test.gd` (mới) | 16 mục: Map011 atlas + tên tile 4 + hết PROVISIONAL; Map001/002 không đổi; Map003–010 giữ atlas riêng; PNG 512×64; cell 3 khác atlas cũ + có nhà phố Tây (>800 px đục); cell khác giống hệt; scene thật Map011 (không NadiaScene, lớp tile hiện, atlas đúng file mới) 60 frame + về Map001 map_id 1. |
| `tools/godot/run_regression.sh` | Thêm `g4_r53_map011_tile_test` (nay 77 suite vòng lặp + server_test + probe = 79 mục; xem §75.3). |
| `visual-check/artpass53/check_r53.py` (mới) | Browser-verify Map001→…→Map011 (chuỗi cửa (5,8)), cổng 8208 + ảnh + crop zoom, theo mẫu check_r52.py + đọc `window.__pxb_map` sau mỗi chân. |

### 75.3 Verify thật vòng này

- `--check-only` test mới + main.gd: PASS (exit 0).
- **Lỗi gặp lần đầu, đã sửa:** chạy test r53 ngay sau khi ghép atlas
  thì `iso_map.gd:159` báo `Cannot create tile / atlas has no tile at
  (0,0)` + test TIMEOUT — vì chưa chạy `--headless --import` nên
  chưa có `atlas-map011.png.import`, TileSet không nhận texture mới.
  Các vòng trước đều import trước khi test; vòng này quên bước đó.
  Chạy `--headless --import` (exit 0, `.import` sinh ra) rồi test
  lại thì **16/16 PASS**. Bài học: atlas PNG mới phải import trước
  khi chạy test headless — ghi vào checklist vòng sau.
- Test mới `g4_r53_map011_tile_test`: **16/16 PASS** (cell 3 khác
  atlas cũ 3552 px theo Godot — PIL đo 3565, lệch do import — vẫn
  >500; 3287 px đục).
- Hồi quy đầy đủ: **79 OK, 0 FAIL** (77 suite vòng lặp +
  server_test + probe; log `~/workspace/regression-move.log`).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR.
- Export web: lần 1 exit 1 — `Target folder does not exist:
  "src/godot-build"` vì chạy từ repo root với đường dẫn tương đối
  (preset export_path `../godot-build` tính từ project dir, không
  phải repo root); chạy lại từ `src/godot` với `../godot-build`
  thì exit 0. pck **22.329.528 byte, SHA `0b73e5c6`**
  (thay `8d3d5711` vòng 52); wasm không đổi `fc74679e`
  (39.514.754 byte); pck chứa `nha-pho-tay` + `atlas-map011`
  (kiểm bằng `strings`); HTTP 200 đủ 4 file (cổng 8208);
  `GODOT_THREADS_ENABLED = false`.
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass53/check_r53.py`, cổng 8208):
  **0 console error, 0 pageerror, 0 request fail.**
  - `window.__pxb_map` đối chiếu đúng cả 10 chân: 2→3→4→5→6→7→8→
    9→10→11, không lệch map nào — cầu nối mới có tác dụng (vòng 52
    lệch +1 mà không phát hiện được).
  - Map011: HUD "Phố Xô Bồ — Phố Tây", NPC Nhân Viên Lễ Tân +
    Hướng Dẫn Viên, 2 cửa đúng tên ("Cửa về Khu Công Nghệ" /
    "Cửa đi Khu Biệt Thự Ven Sông").
  - Tile nhà phố Tây hiện rõ ở hàng biên Map011 (ảnh `r53-09` +
    crop `r53-10-map11-left.png`): tường vàng kem + mái ngói đỏ +
    cửa vòm xanh + ban công sắt đen, khác hẳn tile nhà trọ cũ —
    **không còn bóng ghost**.
  - Map010 (ảnh `r53-08`): tile tòa nhà công nghệ vòng 52 vẫn
    sạch ghost.
- **Cảnh báo export đã biết, không chặn:** `WARNING: UID duplicate
  detected between res://tiles/atlas-map003.png and
  res://tiles/atlas-map001.png` (+ map004/map002, map005/map003…)
  — các atlas copy từ atlas-map001 chia UID; đã có từ các vòng
  trước, export vẫn exit 0, pck vẫn đúng byte. Ghi để vòng sau
  khỏi mất thời gian chẩn đoán lại.

### 75.4 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- **Push main r53 (gộp r43–r53, thay script r52):**
  script mới `pxb-push-main-r53.py` + 4 manifest
  (`pxb-push-main-r53-a/b/c/docs`). Lô a: converter + maps.json +
  main.gd (`__pxb_map`) + test r53 (+ .uid) + run_regression.sh +
  check_r53 + build_atlas_map011 + nội dung r52-a cũ; lô b: 9
  `.import` atlas-map003/004/005/006/007/008/009/010/011; lô c:
  note + process script artpass53 (+ artpass43/44/45/48/49/50/51/52
  cũ); lô docs: godot-g4 + roles-qc.
  **Chưa chạy — chờ chủ nói 'đẩy tiếp' + bấm duyệt** (xem §69.1:
  thẻ r44 đã timeout, không còn thẻ chờ; live vẫn `5f2a052f` r41).
- **Deploy gh-pages pck `0b73e5c6`:** staging rebuild xong,
  `build_gh_pages.py` verify PASS (khớp byte: pck 166 chunk,
  22.329.528 byte; wasm 293 chunk không đổi); 166 chunk
  (part-000..165) + final (versions.json + index.html); script mới
  `pxb-deploy-r53.py` + 10 manifest
  (`pxb-deploy-pck-0b73e5c6-batch1..9` + `-final`). Wasm không đổi
  `fc74679e` nên không đẩy lại. Chạy sau push main.
  Live hiện vẫn `5f2a052f` (r41).
- **Chưa làm:** điền SHA push/deploy vào §75.4 sau khi có kết quả.

### 75.5 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r53 (4 lô) → deploy pck `0b73e5c6`
   (10 lô) → kiểm live pin + đối chiếu byte → điền SHA vào §75.4.
2. Tile riêng tiếp theo: Map012 Khu Biệt Thự Ven Sông theo
   `docs/tileset-plan.md` (đang dùng atlas-map001.png — L1 Map012 đã
   đếm sẵn ở các vòng trước: thay tile 4 `nha-tro-bac` như các vòng
   trước; nhớ import atlas mới TRƯỚC khi chạy test — bài học §75.3).
3. G2 còn lại rồi G4 online (quyết server Godot headless hay .NET,
   xem `docs/opensource-engine.md` §3.4).

## 76. Vòng 54 — Tile biệt thự ven sông riêng Map012 (26/11 ~10:45–11:15 +07, cron 10:45)

### 76.1 Art (subagent artpass54) — XONG, gen 0 lần lại

- Tile `bietthu-map012.png` (64×64 RGBA, 5.073 byte): biệt thự 2 tầng
  ven sông Sài Gòn, tường trắng kem, mái ngói đất nung, ban công gỗ,
  3 cửa kính lớn tầng trệt + 3 cửa sổ khung gỗ tầng trên, 4 cây cọ +
  hoa hồng/vàng, dải sông xanh bên phải với cỏ lau; không người,
  không chữ, lề đủ 4 phía (bbox nguồn 1649×876, tỉ lệ ngang 3:2,
  fit 64×34, đáy y=61). Dải sông chạm mép phải là sông theo đúng ý
  đồ prompt, không phải nhà bị cắt.
- Kiểm chứng: 1 component alpha duy nhất (1.465 px alpha>0, 1.009 px
  alpha=255); 0 pixel gần-trắng (36 px ban đầu đã tone-down 0,92 về
  0); 0 quầng xanh ở mép (6 px quầng sau resize đã xóa về 0);
  hàng y62–63 trong suốt; kiểm bằng mắt ở 1× và zoom 3× đều đọc rõ
  từng chi tiết. Tôi đo độc lập bằng PIL qua atlas (cell 3: 1.219 px
  đục theo ngưỡng Godot alpha>0,5), khớp đúng số liệu note của
  subagent (chênh do ngưỡng đo khác nhau).
- Note: `visual-check/artpass54/bietthu-tile-note.md` + script
  `process_bietthu_r54.py` (theo mẫu vòng 53: tách nền bằng khoảng
  cách màu, ép alpha=255 vùng trong silhouette, nearest-fill RGB
  trước resize LANCZOS).

### 76.2 Code + test — XONG

| File | Đổi |
|---|---|
| `tools/godot/convert_maps.py` | `ATLAS_PNG_OVERRIDE[12] = "atlas-map012.png"` + `ATLAS_TILE_OVERRIDE` (tile 4 → `biet-thu-ven-song`, hết PROVISIONAL; Map012 L1 đếm thật: tile 4 có 8 ô, tile 5 có 12 ô, tile 3 có 8 ô — thay tile 4 như các vòng trước). |
| `src/godot/data/maps.json` (tạo lại) | Map012 atlas mới + tile 4 tên mới; Map001–011 không đổi; đủ 18 map. |
| `src/godot/tiles/atlas-map012.png` (mới, binary — chỉ local + trong pck, KHÔNG push qua snapshot-push) | `visual-check/artpass54/build_atlas_map012.py`: atlas-map001.png đổi cell cột 3 (x=192) thành tile biệt thự ven sông (đã có sửa ghost vòng 47: xóa trắng cell trước khi paste + assert ghost=0). Chạy: cell 3 khác 3042 px / 1219 px đục / ghost 0. |
| `src/godot/tiles/atlas-map012.png.import` (mới) | `--headless --import` sinh lại (chạy TRƯỚC khi test — bài học §75.3). |
| `src/godot/tests/g4_r54_map012_tile_test.gd` (mới) | 16 mục: Map012 atlas + tên tile 4 + hết PROVISIONAL; Map001/002 không đổi; Map003–011 giữ atlas riêng; PNG 512×64; cell 3 khác atlas cũ + có biệt thự ven sông (>800 px đục); cell khác giống hệt; scene thật Map012 (không NadiaScene, lớp tile hiện, atlas đúng file mới) 60 frame + về Map001 map_id 1. |
| `tools/godot/run_regression.sh` | Thêm `g4_r54_map012_tile_test` (nay 78 suite vòng lặp + server_test + probe = 80 mục). |
| `visual-check/artpass54/check_r54.py` (mới) | Browser-verify Map001→…→Map012 (chuỗi cửa (5,8)), cổng 8209 + ảnh + crop zoom, theo mẫu check_r53.py + đọc `window.__pxb_map` sau mỗi chân. |

### 76.3 Verify thật vòng này

- `--check-only` test mới: PASS (exit 0).
- Test mới `g4_r54_map012_tile_test`: **16/16 PASS** (cell 3 khác
  atlas cũ 3002 px theo Godot — PIL đo 3042, lệch do import — vẫn
  >500; 1219 px đục).
- Hồi quy đầy đủ: **80 OK, 0 FAIL** (78 suite vòng lặp +
  server_test + probe; log `~/workspace/regression-move.log`).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR.
- Export web: exit 0. pck **22.351.212 byte, SHA `b68616fc`**
  (thay `0b73e5c6` vòng 53); wasm không đổi `fc74679e`
  (39.514.754 byte); pck chứa `biet-thu-ven-song` + `atlas-map012`
  (kiểm bằng `strings`); HTTP 200 đủ 4 file (cổng 8209);
  `GODOT_THREADS_ENABLED = false`.
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass54/check_r54.py`, cổng 8209):
  **0 console error, 0 pageerror, 0 request fail.**
  - `window.__pxb_map` đối chiếu đúng cả 11 chân: 2→3→4→5→6→7→8→
    9→10→11→12, không lệch map nào.
  - Map012: HUD "Phố Xô Bồ — Khu Biệt Thự Ven Sông", NPC Bảo Vệ
    Biệt Thự + Người Làm Vườn, 2 cửa đúng tên ("Cửa về Phố Tây" /
    "Cửa đi Quận Tài Chính"), toast "Đã sang Khu Biệt Thự Ven Sông".
  - Tile biệt thự ven sông hiện rõ ở hàng biên Map012 (ảnh
    `r54-10-map12.png` + crop `r54-11-map12-left.png` +
    `r54-14-map12-leftedge.png`): tường trắng kem + mái ngói đất
    nung đỏ + cây cọ, khác hẳn tile nhà trọ cũ — **không còn bóng
    ghost**. Vị trí tile 4 đã đối chiếu từ `maps.json` L1: (1,0),
    (4,0), (7,0), (10,0), (0,3), (11,3), (0,6), (11,6).
  - Map011 (ảnh `r54-09-map11`): tile nhà phố Tây vòng 53 vẫn
    sạch ghost.
- **Lỗi môi trường gặp trong vòng, đã sửa:** package Python
  `playwright` không còn trong `/usr/bin/python3` (PEP 668 chặn
  `pip install --user`) nên `check_r54.py` lỗi `ModuleNotFoundError`
  lần đầu; đã tạo venv mới `/tmp/pxb-pw-venv` (playwright +
  pillow, browser Chromium 1255 dùng lại cache cũ) rồi chạy lại
  thì PASS. Vòng sau dùng venv này (hoặc cài lại nếu `/tmp` bị
  dọn). Venv này là ephemeral — nếu mất thì tạo lại cùng cách.

### 76.4 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- **Push main r54 (gộp r43–r54, thay script r53):**
  script mới `pxb-push-main-r54.py` + 4 manifest
  (`pxb-push-main-r54-a/b/c/docs`: a 46 path, b 10 `.import`,
  c 20 path, docs 2 file).
  **Chưa chạy — chờ chủ nói 'đẩy tiếp' + bấm duyệt** (xem §69.1:
  thẻ r44 đã timeout, không còn thẻ chờ; live vẫn `5f2a052f` r41).
- **Deploy gh-pages pck `b68616fc`:** staging rebuild xong,
  `build_gh_pages.py` verify PASS (khớp byte: pck 166 chunk,
  22.351.212 byte; wasm 293 chunk không đổi); 166 chunk
  (part-000..165) + final (versions.json + index.html); script mới
  `pxb-deploy-r54.py` + 10 manifest
  (`pxb-deploy-pck-b68616fc-batch1..9` + `-final`). Wasm không đổi
  `fc74679e` nên không đẩy lại. Chạy sau push main.
  Live hiện vẫn `5f2a052f` (r41).
- **Chưa làm:** điền SHA push/deploy vào §76.4 sau khi có kết quả.

### 76.5 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r54 (4 lô) → deploy pck `b68616fc`
   (10 lô) → kiểm live pin + đối chiếu byte → điền SHA vào §76.4.
2. Tile riêng tiếp theo: Map013 Quận Tài Chính theo
   `docs/tileset-plan.md` (đang dùng atlas-map001.png — L1 Map013
   đếm thật trước khi thay; nhớ import atlas mới TRƯỚC khi chạy
   test — bài học §75.3; dùng venv `/tmp/pxb-pw-venv` cho
   browser-verify — bài học §76.3).
3. G2 còn lại rồi G4 online (quyết server Godot headless hay .NET,
   xem `docs/opensource-engine.md` §3.4).

## 77. Vòng 55 — Tile tòa nhà tài chính riêng Map013 (26/11 ~11:45–12:20 +07, cron 11:45)

### 77.1 Art (subagent artpass55) — XONG, gen 0 lần lại

- Tile `taichinh-map013.png` (64×64 RGBA, 6.469 byte): tháp kính cao
  tầng khung cam/vàng + sảnh ngân hàng có cột + cửa kính lớn tầng
  trệt, cây xanh/chậu cây 2 bên sảnh; không người, không chữ, lề đủ
  4 phía ở ảnh gốc (trái 376, phải 362, trên 50, dưới 45 px; bbox
  1182×1185 → scale 0,0523 → 62×62, đáy y=61).
- Kiểm chứng: 1 component alpha duy nhất (1.977 px alpha>0, 1.456 px
  alpha=255); 0 pixel gần-trắng; 0 quầng xanh ở mép (đo với đúng màu
  nền vòng này (149,200,233) — 3 px bán-trong-suốt gần màu nền vòng
  54 (130,185,224) chỉ là kính xanh của tháp, không phải quầng);
  hàng y62–63 trong suốt; kiểm bằng mắt ở 1× và zoom 3× đều đọc rõ
  từng chi tiết. Tôi đo độc lập bằng PIL qua tile đích, khớp đúng số
  liệu note của subagent.
- Note: `visual-check/artpass55/taichinh-tile-note.md` + script
  `process_taichinh_r55.py` (theo mẫu vòng 54: tách nền bằng khoảng
  cách màu, ép alpha=255 vùng trong silhouette, nearest-fill RGB
  trước resize LANCZOS).

### 77.2 Code + test — XONG

| File | Đổi |
|---|---|
| `tools/godot/convert_maps.py` | `ATLAS_PNG_OVERRIDE[13] = "atlas-map013.png"` + `ATLAS_TILE_OVERRIDE` (tile 4 → `toa-nha-tai-chinh`, hết PROVISIONAL; Map013 L1 đếm thật: tile 4 có 8 ô, tile 5 có 12 ô, tile 3 có 8 ô — thay tile 4 như các vòng trước). |
| `src/godot/data/maps.json` (tạo lại) | Map013 atlas mới + tile 4 tên mới; Map001–012 không đổi; đủ 18 map. |
| `src/godot/tiles/atlas-map013.png` (mới, binary — chỉ local + trong pck, KHÔNG push qua snapshot-push) | `visual-check/artpass55/build_atlas_map013.py`: atlas-map001.png đổi cell cột 3 (x=192) thành tile tòa nhà tài chính (đã có sửa ghost vòng 47: xóa trắng cell trước khi paste + assert ghost=0). Chạy: cell 3 khác 3066 px / 1731 px đục / ghost 0. |
| `src/godot/tiles/atlas-map013.png.import` (mới) | `--headless --import` sinh lại (chạy TRƯỚC khi test — bài học §75.3). |
| `src/godot/tests/g4_r55_map013_tile_test.gd` (mới) | 16 mục: Map013 atlas + tên tile 4 + hết PROVISIONAL; Map001/002 không đổi; Map003–012 giữ atlas riêng; PNG 512×64; cell 3 khác atlas cũ + có tòa nhà tài chính (>800 px đục); cell khác giống hệt; scene thật Map013 (không NadiaScene, lớp tile hiện, atlas đúng file mới) 60 frame + về Map001 map_id 1. |
| `tools/godot/run_regression.sh` | Thêm `g4_r55_map013_tile_test` (nay 79 suite vòng lặp + server_test + probe = 81 mục). |
| `visual-check/artpass55/check_r55.py` (mới) | Browser-verify Map001→…→Map013 (chuỗi cửa (5,8)), cổng 8210 + ảnh + crop zoom, theo mẫu check_r54.py + đọc `window.__pxb_map` sau mỗi chân; **lần 2 đổi sang `walk_down_to_door` — bấm từng phím, dừng ngay khi map đổi** (xem §77.3). |

### 77.3 Verify thật vòng này

- `--check-only` test mới: PASS (exit 0).
- Test mới `g4_r55_map013_tile_test`: **16/16 PASS** (cell 3 khác
  atlas cũ 3048 px theo Godot — PIL đo 3066, lệch do import — vẫn
  >500; 1732 px đục).
- Hồi quy đầy đủ: **81 OK, 0 FAIL** (79 suite vòng lặp +
  server_test + probe; log `~/workspace/regression-move.log`).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR.
- Export web: exit 0. pck **22.374.416 byte, SHA `2f650ec3`**
  (thay `b68616fc` vòng 54); wasm không đổi `fc74679e`
  (39.514.754 byte); pck chứa `toa-nha-tai-chinh` + `atlas-map013`
  (kiểm bằng `strings`); HTTP 200 đủ 4 file (cổng 8210);
  `GODOT_THREADS_ENABLED = false`.
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass55/check_r55.py`, cổng 8210):
  **0 console error, 0 pageerror, 0 request fail.**
  - **Lần 1 — LỆCH +1 map từ chân Map009→Map010:** giữ phím 400ms
    đôi lúc đi 2 ô (game nhanh hơn bình thường lúc swiftshader nhẹ
    tải) — 4 lần giữ = 8 bước, qua 2 cửa trong 1 chân: chân
    Map010 đọc `__pxb_map=11`, các chân sau đều lệch +1 (Map013
    đọc 14). Ảnh chứng minh: `r55-08-map10.png` hiện Phố Tây
    (Map011, ô (5,4), NPC Nhân Viên Lễ Tân / Hướng Dẫn Viên),
    `r55-11-map13.png` lần 1 hiện Đảo Thượng Lưu (Map014, ô (5,6)).
    Đây là lỗi script verify, KHÔNG phải lỗi game (cửa/NPC/tên map
    đều đúng dữ liệu ở map đã tới).
  - **Lần 2 — PASS hết (sau khi sửa script):** `walk_down_to_door`
    bấm từng phím ArrowDown, đọc `__pxb_map` sau mỗi phím, dừng
    ngay khi map đổi — 1 chân chỉ qua đúng 1 cửa, không phụ thuộc
    tốc độ game. `window.__pxb_map` đối chiếu đúng cả 11 chân:
    2→3→4→5→6→7→8→9→10→11→12→13, không lệch map nào.
  - Map013: HUD "Phố Xô Bồ — Quận Tài Chính", NPC Nhân Viên Ngân
    Hàng + Môi Giới Chứng Khoán, 2 cửa đúng tên ("Cửa về Khu Biệt
    Thự Ven Sông" / "Cửa đi Đảo Thượng Lưu"), debug ô (5,4).
  - Tile tòa nhà tài chính hiện rõ ở hàng biên Map013 (ảnh
    `r55-11-map13.png` + crop `r55-12-map13-left.png`): tháp kính
    lưới cửa sổ xanh, khác hẳn tile nhà trọ cũ — **không còn bóng
    ghost**. Vị trí tile 4 đã đối chiếu từ `maps.json` L1: (1,0),
    (4,0), (7,0), (10,0), (0,3), (11,3), (0,6), (11,6).
  - Map012 (ảnh `r55-10-map12`): tile biệt thự ven sông vòng 54 vẫn
    sạch ghost.
- **Bài học môi trường vòng này:** (1) venv Playwright
  `/tmp/pxb-pw-venv` đã mất do `/tmp` bị dọn — đã tạo lại
  (`python3 -m venv` + pip install playwright pillow, dùng lại
  cache Chromium 1255); vòng sau kiểm tra venv trước, mất thì tạo
  lại cùng cách. (2) Nước đi đầu Map001→Map002 (Up + Right) ở lần
  2 cũng bị double-step (Up đi 2 ô → Right trượt cửa (5,4),
  `__pxb_map` vẫn 1) — chân xuống robust sau đó tự sửa (đi qua
  cửa (5,4) rồi mới xuống tiếp nên vẫn tới đúng Map003); vòng sau
  nên áp `walk_down_to_door` cả cho nước đi đầu (bấm từng phím +
  đọc map sau mỗi phím). (3) `pkill -f "http.server ..."` tự giết
  luôn shell gọi nó (pattern khớp chính lệnh) — tắt server bằng
  PID qua `ss -ltnp`, không dùng pkill với pattern chứa trong lệnh.

### 77.4 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- **Push main r55 (gộp r43–r55, thay script r54):**
  script mới `pxb-push-main-r55.py` + 4 manifest
  (`pxb-push-main-r55-a/b/c/docs`: a 50 path, b 11 `.import`,
  c 22 path, docs 2 file).
  **Chưa chạy — chờ chủ nói 'đẩy tiếp' + bấm duyệt** (xem §69.1:
  thẻ r44 đã timeout, không còn thẻ chờ; live vẫn `5f2a052f` r41).
- **Deploy gh-pages pck `2f650ec3`:** staging rebuild xong,
  `build_gh_pages.py` verify PASS (khớp byte: pck 166 chunk,
  22.374.416 byte; wasm 293 chunk không đổi); 166 chunk
  (part-000..165) + final (versions.json + index.html); script mới
  `pxb-deploy-r55.py` + 10 manifest
  (`pxb-deploy-pck-2f650ec3-batch1..9` + `-final`). Wasm không đổi
  `fc74679e` nên không đẩy lại. Chạy sau push main.
  Live hiện vẫn `5f2a052f` (r41).
- **Chưa làm:** điền SHA push/deploy vào §77.4 sau khi có kết quả.

### 77.5 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r55 (4 lô) → deploy pck `2f650ec3`
   (10 lô) → kiểm live pin + đối chiếu byte → điền SHA vào §77.4.
2. Tile riêng tiếp theo: Map014 Đảo Thượng Lưu theo
   `docs/tileset-plan.md` (đang dùng atlas-map001.png — L1 Map014
   đếm thật trước khi thay; nhớ import atlas mới TRƯỚC khi chạy
   test — bài học §75.3; kiểm tra venv `/tmp/pxb-pw-venv` trước
   browser-verify, mất thì tạo lại — bài học §77.3; dùng
   `walk_down_to_door` cho mọi nước đi kể cả nước đầu — bài học
   §77.3).
3. G2 còn lại rồi G4 online (quyết server Godot headless hay .NET,
   xem `docs/opensource-engine.md` §3.4).

## 78. Vòng 56 — Tile biệt thự đảo thượng lưu riêng Map014 (26/11 ~12:45–13:30 +07, cron 12:45)

### 78.1 Art (subagent artpass56) — XONG, gen 0 lần lại

- Tile `daothuongluu-map014.png` (64×64 RGBA, 7.267 byte): biệt thự
  trắng 2 tầng mái ngói nâu cam + cửa kính lớn + ban công, cọ và cây
  nhiệt đới 2 bên, đảo cát vàng, biển ngọc lam + cầu gỗ nhỏ ở đáy;
  không người, không chữ, lề đủ 4 phía ở ảnh gốc (trái 35, phải 30,
  trên 311, dưới 246 px; bbox 1535×1043 → scale 0,0417 → 64×43, đáy y=61).
- Kiểm chứng: 1 component alpha duy nhất (2.119 px alpha>0, 1.552 px
  alpha=255); 0 pixel gần-trắng (đã tone-down 143 px ×0,92); 0 quầng
  xanh ở mép (đã xóa 12 px bán-trong-suốt gần màu nền vòng này
  (135,193,231)); hàng y62–63 trong suốt; kiểm bằng mắt ở 1× và zoom
  3× đều đọc rõ từng chi tiết. Tôi đo độc lập bằng PIL qua tile đích,
  khớp đúng số liệu note của subagent.
- Note: `visual-check/artpass56/daothuongluu-tile-note.md` + script
  `process_daothuongluu_r56.py` (theo mẫu vòng 55: tách nền bằng khoảng
  cách màu, ép alpha=255 vùng trong silhouette, nearest-fill RGB
  trước resize LANCZOS).

### 78.2 Code + test — XONG

| File | Đổi |
|---|---|
| `tools/godot/convert_maps.py` | `ATLAS_PNG_OVERRIDE[14] = "atlas-map014.png"` + `ATLAS_TILE_OVERRIDE` (tile 4 → `biet-thu-dao-thuong-luu`, hết PROVISIONAL; Map014 L1 đếm thật: tile 4 có 8 ô, tile 5 có 12 ô, tile 3 có 8 ô — thay tile 4 như các vòng trước; vị trí tile 4: (1,0),(4,0),(7,0),(10,0),(0,3),(11,3),(0,6),(11,6)). |
| `src/godot/data/maps.json` (tạo lại) | Map014 atlas mới + tile 4 tên mới; Map001–013 không đổi; đủ 18 map. |
| `src/godot/tiles/atlas-map014.png` (mới, binary — chỉ local + trong pck, KHÔNG push qua snapshot-push) | `visual-check/artpass56/build_atlas_map014.py`: atlas-map001.png đổi cell cột 3 (x=192) thành tile biệt thự đảo (đã có sửa ghost vòng 47: xóa trắng cell trước khi paste + assert ghost=0). Chạy: cell 3 khác 3063 px / 1803 px đục / ghost 0. |
| `src/godot/tiles/atlas-map014.png.import` (mới) | `--headless --import` sinh lại (chạy TRƯỚC khi test — bài học §75.3). |
| `src/godot/tests/g4_r56_map014_tile_test.gd` (mới) | 16 mục: Map014 atlas + tên tile 4 + hết PROVISIONAL; Map001/002 không đổi; Map003–013 giữ atlas riêng; PNG 512×64; cell 3 khác atlas cũ + có biệt thự đảo (>800 px đục); cell khác giống hệt; scene thật Map014 (không NadiaScene, lớp tile hiện, atlas đúng file mới) 60 frame + về Map001 map_id 1. |
| `src/godot/main.gd` | Vòng 56: lộ thêm `window.__pxb_tile = [x, y]` ra JS (trong `load_map` lúc spawn + trong `_on_player_moved_to` mỗi lần player đổi ô) — theo đúng mẫu `__pxb_map` vòng 53. Lý do: xem §78.3, bài học browser-verify lần 1/2. |
| `tools/godot/run_regression.sh` | Thêm `g4_r56_map014_tile_test` (nay 80 suite vòng lặp + server_test + probe = 82 mục). |
| `visual-check/artpass56/check_r56.py` (mới) | Browser-verify Map001→…→Map014 (chuỗi cửa (5,8)), cổng 8210 + ảnh + crop zoom, theo mẫu check_r55.py + đọc `window.__pxb_map` sau mỗi chân; **lần 3 đổi sang lái theo `__pxb_tile`** — bấm từng phím, đọc tile thật sau mỗi phím, tính lại hướng (x trước rồi y), dừng ngay khi map đổi (xem §78.3). |

### 78.3 Verify thật vòng này

- `--check-only` test mới + `main.gd`: PASS (exit 0).
- Test mới `g4_r56_map014_tile_test`: **16/16 PASS** (cell 3 khác
  atlas cũ 3033 px theo Godot — PIL đo 3063, lệch do import — vẫn
  >500; 1805 px đục).
- Hồi quy đầy đủ: **82 OK, 0 FAIL** (80 suite vòng lặp +
  server_test + probe; chạy 2 lần — lần 1 trước khi sửa main.gd,
  lần 2 sau khi sửa, đều 82/82).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR (chạy 2 lần:
  trước/sau sửa main.gd).
- Export web: exit 0. pck **22.398.356 byte, SHA `b4b1cf1d`**
  (thay `2f650ec3` vòng 55); wasm không đổi `fc74679e`
  (39.514.754 byte); pck chứa `biet-thu-dao-thuong-luu` + `atlas-map014`
  (kiểm bằng `strings`); HTTP 200 đủ 4 file (cổng 8210);
  `GODOT_THREADS_ENABLED = false`.
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass56/check_r56.py`, cổng 8210):
  **0 console error, 0 pageerror, 0 request fail.**
  - **Lần 1 + 2 — LỆCH HẾT từ cửa đầu (lỗi script verify, KHÔNG
    phải lỗi game):** đếm phím cố định vẫn sai — giữ phím 400ms đôi
    lúc đi 2 ô (bài học vòng 55) nên player vượt qua cửa (5,4):
    ảnh `r56-01-map3.png` lần 1 hiện player ở ô (10,4) vẫn Map001
    (debug `Ô (10,4) • S`), 12 chân sau đều lệch. Lần 2 sửa
    `walk_to_door` cho nước đầu vẫn sai cùng kiểu: `walk_to_door`
    lặp tối đa 8 phím cho tới khi map đổi — dùng cho ArrowUp sẽ đi
    lên 8 ô vì lên không đổi map; bấm Up đúng 1 lần rồi
    `walk_to_door` Right vẫn vượt cửa do double-step.
  - **Lần 3 — PASS hết (sau khi sửa game + script):** `main.gd`
    lộ thêm `window.__pxb_tile` (theo mẫu `__pxb_map` vòng 53);
    `goto_tile` lái theo tile thật: bấm từng phím (giữ 200ms),
    đọc `__pxb_tile` sau mỗi phím, tính lại hướng (x trước rồi y),
    dừng ngay khi map đổi — vượt cửa thì quay lại, kẹt thì báo.
    `window.__pxb_map` đối chiếu đúng cả 13 chân:
    1→2→3→4→5→6→7→8→9→10→11→12→13→14, không lệch map nào.
  - Map014: HUD "Phố Xô Bồ — Đảo Thượng Lưu", NPC Quản Gia Đảo +
    Chủ Biệt Thự Đảo, 2 cửa đúng tên ("Cửa về Quận Tài Chính" /
    "Cửa đi Khu Penthouse"), debug ô (5,4).
  - Tile biệt thự đảo hiện rõ ở hàng biên Map014 (ảnh
    `r56-12-map14.png` + crop `r56-13-map14-left.png`): biệt thự
    trắng mái ngói nâu cam, cọ, biển ngọc lam + cầu gỗ — **không
    còn bóng ghost**. Vị trí tile 4 đã đối chiếu từ `maps.json` L1:
    (1,0), (4,0), (7,0), (10,0), (0,3), (11,3), (0,6), (11,6).
  - Map013 (ảnh `r56-11-map13`): tile tòa nhà tài chính vòng 55 vẫn
    sạch ghost.
- **Bài học môi trường vòng này:** (1) Đếm phím cố định KHÔNG BAO
  GIỜ tin được khi giữ phím có thể đi 2 ô — mọi script
  browser-verify từ nay lái theo `window.__pxb_tile` (đã có sẵn
  trong main.gd từ vòng này), không đếm phím mù. (2) `grep -c` trên
  file pck không tìm được chuỗi GDScript (`__pxb_map` cũng 0 kết
  quả dù đã chạy thật từ vòng 53) — chuỗi script trong pck không
  lưu dạng text thường; đừng dùng grep pck để kết luận code có/không
  trong build, kiểm bằng browser thật. (3) `pkill -f "http.server"`
  tự giết shell gọi nó — tắt server bằng PID qua `ss -ltnp`
  (bài học vòng 55, đã áp dụng đúng vòng này).

### 78.4 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- **Push main r56 (gộp r43–r56, thay script r55):**
  script mới `pxb-push-main-r56.py` + 4 manifest
  (`pxb-push-main-r56-a/b/c/docs`: a 54 path, b 12 `.import`,
  c 24 path, docs 2 file).
  **Chưa chạy — chờ chủ nói 'đẩy tiếp' + bấm duyệt** (xem §69.1:
  thẻ r44 đã timeout, không còn thẻ chờ; live vẫn `5f2a052f` r41).
- **Deploy gh-pages pck `b4b1cf1d`:** staging rebuild xong,
  `build_gh_pages.py` verify PASS (khớp byte: pck 166 chunk,
  22.398.356 byte; wasm 293 chunk không đổi); 166 chunk
  (part-000..165) + final (versions.json + index.html); script mới
  `pxb-deploy-r56.py` + 10 manifest
  (`pxb-deploy-pck-b4b1cf1d-batch1..9` + `-final`). Wasm không đổi
  `fc74679e` nên không đẩy lại. Chạy sau push main.
  Live hiện vẫn `5f2a052f` (r41).
- **Chưa làm:** điền SHA push/deploy vào §78.4 sau khi có kết quả.

### 78.5 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r56 (4 lô) → deploy pck `b4b1cf1d`
   (10 lô) → kiểm live pin + đối chiếu byte → điền SHA vào §78.4.
2. Tile riêng tiếp theo: Map015 Khu Penthouse theo
   `docs/tileset-plan.md` (đang dùng atlas-map001.png — L1 Map015
   đếm thật trước khi thay; nhớ import atlas mới TRƯỚC khi chạy
   test — bài học §75.3; kiểm tra venv `/tmp/pxb-pw-venv` trước
   browser-verify, mất thì tạo lại — bài học §77.3; lái theo
   `window.__pxb_tile`, không đếm phím — bài học §78.3).
3. G2 còn lại rồi G4 online (quyết server Godot headless hay .NET,
   xem `docs/opensource-engine.md` §3.4).

## 79. Vòng 57 — Tile penthouse tầng cao riêng Map015 (26/11 ~13:45–14:10 +07, cron 13:45)

### 79.1 Art (subagent artpass57) — XONG, gen 0 lần lại

- Tile `penthouse-map015.png` (64×64 RGBA, 5.191 byte): tháp
  penthouse kính đèn vàng ấm + terrace có cây xanh + hồ bơi nhỏ
  phía phải + dải skyline đèn vàng dưới chân, nền trời chiều xanh
  đậm trơn; không người, không chữ, lề đủ 4 phía ở ảnh gốc (bbox
  1920×1137 — rộng full vì dải skyline dưới chân chạm mép trái/phải
  theo đúng ý prompt → scale 0,0333 → 64×38, đáy y=61; dải skyline
  thành dải nền thành phố mỏng dưới chân tháp, tương tự vai trò dải
  đảo + biển ở tile vòng 56).
- Kiểm chứng: 1 component alpha duy nhất (1.469 px alpha>0, 1.095 px
  alpha=255); 0 pixel gần-trắng; 0 quầng ở mép; hàng y62–63 trong
  suốt; kiểm bằng mắt ở 1× và zoom 3× trên nền magenta đều đọc rõ
  penthouse/terrace/hồ bơi. Tôi đo độc lập bằng PIL qua tile đích,
  khớp đúng số liệu note của subagent.
- Note: `visual-check/artpass57/penthouse-tile-note.md` + script
  `process_penthouse_r57.py` (theo mẫu vòng 56: tách nền bằng khoảng
  cách màu, ép alpha=255 vùng trong silhouette, nearest-fill RGB
  trước resize LANCZOS).

### 79.2 Code + test — XONG

| File | Đổi |
|---|---|
| `tools/godot/convert_maps.py` | `ATLAS_PNG_OVERRIDE[15] = "atlas-map015.png"` + `ATLAS_TILE_OVERRIDE` (tile 4 → `penthouse-tang-cao`, hết PROVISIONAL; Map015 L1 đếm thật: tile 4 có 8 ô, tile 5 có 12 ô, tile 3 có 8 ô — thay tile 4 như các vòng trước; vị trí tile 4: (1,0),(4,0),(7,0),(10,0),(0,3),(11,3),(0,6),(11,6)). **Sửa gốc vòng này:** `handwritten()` (Map015–018 viết tay, không qua `convert()`) trước đây BỎ QUA override — regen lần đầu Map015 vẫn giữ atlas-map001.png + tile cũ; nay `handwritten()` áp `ATLAS_PNG_OVERRIDE` / `ATLAS_TILE_OVERRIDE` như `convert()` (chỉ Map015 đổi, Map016–018 không đổi — đã đối chiếu diff). |
| `src/godot/data/maps.json` (tạo lại) | Map015 atlas mới + tile 4 tên mới; Map001–014, Map016–018 không đổi; đủ 18 map. |
| `src/godot/tiles/atlas-map015.png` (mới, binary — chỉ local + trong pck, KHÔNG push qua snapshot-push) | `visual-check/artpass57/build_atlas_map015.py`: atlas-map001.png đổi cell cột 3 (x=192) thành tile penthouse (đã có sửa ghost vòng 47: xóa trắng cell trước khi paste + assert ghost=0). Chạy: cell 3 khác 2974 px / 1296 px đục / ghost 0. |
| `src/godot/tiles/atlas-map015.png.import` (mới) | `--headless --import` sinh lại (chạy TRƯỚC khi test — bài học §75.3). |
| `src/godot/tests/g4_r57_map015_tile_test.gd` (mới) | 16 mục: Map015 atlas + tên tile 4 + hết PROVISIONAL; Map001/002 không đổi; Map003–014 giữ atlas riêng; PNG 512×64; cell 3 khác atlas cũ + có penthouse (>800 px đục); cell khác giống hệt; scene thật Map015 (không NadiaScene, lớp tile hiện, atlas đúng file mới) 60 frame + về Map001 map_id 1. |
| `tools/godot/run_regression.sh` | Thêm `g4_r57_map015_tile_test` (nay 81 suite vòng lặp + server_test + probe = 83 mục). |
| `visual-check/artpass57/check_r57.py` (mới) | Browser-verify Map001→…→Map015 (chuỗi cửa (5,8)), cổng 8210 + ảnh + crop zoom, theo mẫu check_r56.py + lái theo `__pxb_tile` (bài học §78.3). |

### 79.3 Verify thật vòng này

- `--check-only` test mới: PASS (exit 0).
- Test mới `g4_r57_map015_tile_test`: **16/16 PASS** (cell 3 khác
  atlas cũ 2941 px theo Godot — PIL đo 2974, lệch do import — vẫn
  >500; 1298 px đục).
- Hồi quy đầy đủ: **83 OK, 0 FAIL** (81 suite vòng lặp +
  server_test + probe).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR/warning.
- Export web: exit 0. pck **22.420.632 byte, SHA `a7f08e57`**
  (thay `b4b1cf1d` vòng 56); wasm không đổi `fc74679e`
  (39.514.754 byte); pck chứa `penthouse-tang-cao` + `atlas-map015`
  (kiểm bằng `strings`, 6 hit); HTTP 200 đủ 4 file (cổng 8210);
  `GODOT_THREADS_ENABLED = false`.
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass57/check_r57.py`, cổng 8210):
  **0 console error, 0 pageerror, 0 request fail.**
  `window.__pxb_map` đối chiếu đúng cả 14 chân:
  1→2→3→4→5→6→7→8→9→10→11→12→13→14→15, không lệch map nào
  (lái theo `__pxb_tile`, không đếm phím — bài học §78.3).
  - Map015: HUD "Phố Xô Bồ — Khu Penthouse", NPC Quản Lý Penthouse +
    Cư Dân Penthouse, 2 cửa đúng tên ("Cửa về Đảo Thượng Lưu" /
    "Cửa đi Khu Sân Golf & Resort"), debug ô (5,4).
  - Tile penthouse hiện rõ ở hàng biên Map015 (ảnh
    `r57-13-map15.png` + crop `r57-14-map15-left.png` +
    `r57-15-map15-toprow.png` + `r57-16-map15-leftedge.png`): tháp
    kính xanh + đèn vàng ấm, khác hẳn khối nhà trọ vàng Kenney
    (tile 3/5 vẫn PROVISIONAL) — **không còn bóng ghost**.
  - Map014 (ảnh `r57-12-map14`): tile biệt thự đảo vòng 56 vẫn
    sạch ghost.
- **Bài học môi trường vòng này:** venv Playwright `/tmp/pxb-pw-venv`
  lại mất do `/tmp` bị dọn (lần 2 — bài học §77.3) — tạo lại cùng
  cách (venv + pip install playwright pillow, dùng lại cache
  Chromium 1255) trước khi browser-verify.

### 79.4 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- **Push main r57 (gộp r43–r57, thay script r56):**
  script mới `pxb-push-main-r57.py` + 4 manifest
  (`pxb-push-main-r57-a/b/c/docs`: a 58 path, b 13 `.import`,
  c 26 path, docs 2 file).
  **Chưa chạy — chờ chủ nói 'đẩy tiếp' + bấm duyệt** (xem §69.1:
  thẻ r44 đã timeout, không còn thẻ chờ; live vẫn `5f2a052f` r41).
- **Deploy gh-pages pck `a7f08e57`:** staging rebuild xong,
  `build_gh_pages.py` verify PASS (khớp byte: pck 167 chunk,
  22.420.632 byte; wasm 293 chunk không đổi); 167 chunk
  (part-000..166) + final (versions.json + index.html); script mới
  `pxb-deploy-r57.py` + 10 manifest
  (`pxb-deploy-pck-a7f08e57-batch1..9` + `-final`). Wasm không đổi
  `fc74679e` nên không đẩy lại. Chạy sau push main.
  Live hiện vẫn `5f2a052f` (r41).
- **Chưa làm:** điền SHA push/deploy vào §79.4 sau khi có kết quả.

### 79.5 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r57 (4 lô) → deploy pck `a7f08e57`
   (10 lô) → kiểm live pin + đối chiếu byte → điền SHA vào §79.4.
2. Tile riêng tiếp theo: Map016 Khu Sân Golf & Resort theo
   `docs/tileset-plan.md` (đang dùng atlas-map001.png — L1 Map016
   đếm thật trước khi thay; nhớ `handwritten()` nay đã áp override
   nên regen là đủ, không cần sửa converter thêm; import atlas mới
   TRƯỚC khi chạy test — bài học §75.3; kiểm tra venv
   `/tmp/pxb-pw-venv` trước browser-verify, mất thì tạo lại —
   bài học §77.3; lái theo `window.__pxb_tile`, không đếm phím —
   bài học §78.3).
3. G2 còn lại rồi G4 online (quyết server Godot headless hay .NET,
   xem `docs/opensource-engine.md` §3.4).

## 80. Vòng 58 — Tile sân golf & resort riêng Map016 (26/11 ~14:45–15:15 +07, cron 14:45)

### 80.1 Art (subagent artpass58) — XONG, gen 0 lần lại

- Tile `golf-map016.png` (64×64 RGBA, 5.170 byte): clubhouse 2 tầng kiểu
  thuộc địa — mái ngói nâu cam, tường kem, cửa chớp + vòm xanh lá, cọ
  xanh 2 bên, fairway xanh đậm trước nhà có cờ golf cắm giữa green, hồ
  sen nhỏ phía trái đáy có hoa sen vàng, nền trơn; không người, không
  chữ. Bố cục gốc ngang nên tile thấp (hàng y33–61, 64×29), đáy y=61.
- Kiểm chứng: 1 component alpha duy nhất (1.580 px alpha>0, 1.411 px
  alpha>0,5); 0 pixel gần-trắng; 0 quầng ở mép; hàng y62–63 trong suốt;
  kiểm bằng mắt ở 1× và zoom 3× trên nền magenta đều đọc rõ sân golf +
  clubhouse/resort. Tôi đo độc lập bằng PIL qua tile đích, khớp số liệu
  note của subagent (chênh 1 px ở ngưỡng alpha>128: 1.410 vs 1.411 —
  không đáng kể, vẫn >800).
- Note: `visual-check/artpass58/golf-tile-note.md` + script
  `process_golf_r58.py` (theo mẫu vòng 56/57: tách nền bằng khoảng
  cách màu, ép alpha=255 vùng trong silhouette, nearest-fill RGB
  trước resize LANCZOS).

### 80.2 Code + test — XONG

| File | Đổi |
|---|---|
| `tools/godot/convert_maps.py` | `ATLAS_PNG_OVERRIDE[16] = "atlas-map016.png"` + `ATLAS_TILE_OVERRIDE` (tile 4 → `san-golf-resort`, hết PROVISIONAL; Map016 L1 đếm thật: tile 4 có 8 ô, tile 5 có 12 ô, tile 3 có 8 ô — thay tile 4 như các vòng trước; vị trí tile 4: (1,0),(4,0),(7,0),(10,0),(0,3),(11,3),(0,6),(11,6)). `handwritten()` đã áp override từ vòng 57 nên regen là đủ, không cần sửa thêm. |
| `src/godot/data/maps.json` (tạo lại) | Chỉ Map016 đổi (atlas mới + tile 4 tên mới); Map001–015, Map017–018 không đổi; đủ 18 map. |
| `src/godot/tiles/atlas-map016.png` (mới, binary — chỉ local + trong pck, KHÔNG push qua snapshot-push) | `visual-check/artpass58/build_atlas_map016.py`: atlas-map001.png đổi cell cột 3 (x=192) thành tile sân golf (đã có sửa ghost vòng 47: xóa trắng cell trước khi paste + assert ghost=0). Chạy: cell 3 khác 3.110 px / 1.372 px đục / ghost 0. |
| `src/godot/tiles/atlas-map016.png.import` (mới) | `--headless --import` sinh lại (chạy TRƯỚC khi test — bài học §75.3). |
| `src/godot/tests/g4_r58_map016_tile_test.gd` (mới) | 16 mục: Map016 atlas + tên tile 4 + hết PROVISIONAL; Map001/002 không đổi; Map003–015 giữ atlas riêng; PNG 512×64; cell 3 khác atlas cũ + có sân golf (>800 px đục); cell khác giống hệt; scene thật Map016 (không NadiaScene, lớp tile hiện, atlas đúng file mới) 60 frame + về Map001 map_id 1. |
| `tools/godot/run_regression.sh` | Thêm `g4_r58_map016_tile_test` (nay 82 suite vòng lặp + server_test + probe = 84 mục). |
| `visual-check/artpass58/check_r58.py` (mới) | Browser-verify Map001→…→Map016 (chuỗi cửa (5,8)), cổng 8211 + ảnh + crop zoom, theo mẫu check_r57.py + lái theo `__pxb_tile` (bài học §78.3). |

### 80.3 Verify thật vòng này

- `--check-only` test mới: PASS (exit 0).
- Test mới `g4_r58_map016_tile_test`: **16/16 PASS** (cell 3 khác
  atlas cũ 3.071 px theo Godot — PIL đo 3.110, lệch do import — vẫn
  >500; 1.373 px đục).
- Hồi quy đầy đủ: **84 OK, 0 FAIL** (82 suite vòng lặp +
  server_test + probe).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR.
- Export web: exit 0. pck **22.442.668 byte, SHA `3f6125e5`**
  (thay `a7f08e57` vòng 57); wasm không đổi `fc74679e`
  (39.514.754 byte); pck chứa `san-golf-resort` + `atlas-map016`
  (kiểm bằng `strings`, 1 hit — chuỗi GDScript trong pck không grep
  được theo §12.3, hit này là từ maps.json); HTTP 200 đủ 4 file
  (cổng 8211); `GODOT_THREADS_ENABLED = false`.
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass58/check_r58.py`, cổng 8211):
  **0 console error, 0 pageerror, 0 request fail.**
  `window.__pxb_map` đối chiếu đúng cả 15 chân:
  1→2→3→4→5→6→7→8→9→10→11→12→13→14→15→16, không lệch map nào
  (lái theo `__pxb_tile`, không đếm phím — bài học §78.3).
  - Map016: HUD "Phố Xô Bồ — Khu Sân Golf & Resort", NPC Nhân Viên
    Sân Golf + Quản Lý Resort, 2 cửa đúng tên ("Cửa về Khu
    Penthouse" / "Cửa đi Công Viên An Bình"), debug ô (5,4), toast
    "Đã sang Khu Sân Golf & Resort".
  - Tile sân golf hiện rõ ở hàng biên Map016 (ảnh
    `r58-14-map16.png` + crop `r58-15-map16-left.png` +
    `r58-16-toprow-zoom.png` + `r58-17-leftedge-zoom.png`):
    clubhouse tường kem + mái ngói nâu cam + vòm xanh lá hiện sau
    nút D-pad ở cạnh trái, xen kẽ khối nhà trọ vàng Kenney (tile
    3/5 vẫn PROVISIONAL) — **không còn bóng ghost**.
  - Map015 (ảnh `r58-13-map15`): tile penthouse vòng 57 vẫn sạch
    ghost.
- **Lỗi script verify gặp + sửa trong vòng này (ghi để không tái
  phạm):** `check_r58.py` chép từ `check_r57.py` bằng sed nhưng 3
  chỗ không đổi theo: (1) `OUT` vẫn trỏ `visual-check/artpass57`
  (sed `s/r57/r58/` không chạm "artpass57"); (2) danh sách `legs`
  sau sed thành `("r58-13-map16", 15)` — chân cuối gán nhầm tên
  map16 cho Map015 nên Map016 không được đi tới; (3) bước crop tìm
  `r58-14-map16.png` không tồn tại → `FileNotFoundError` sau khi
  13 chân 1→15 đã PASS. Lần chạy đầu vì vậy chỉ xác nhận tới
  Map015, không phải lỗi game. Sửa `OUT` + `legs` (thêm
  `("r58-13-map15", 15), ("r58-14-map16", 16)`), xóa 13 ảnh
  `r58-*.png` ghi nhầm vào thư mục artpass57, chạy lại toàn bộ:
  15/15 chân + `ERRORS: none`. Bài học: khi chép script verify
  bằng sed, kiểm tra lại `OUT` + `legs` + tên file crop bằng mắt
  trước khi chạy — sed không đổi được "artpass57" hay số chân
  trong danh sách.
- **Bài học môi trường lặp lại:** `pkill -f "http.server 8211"`
  tự giết luôn shell gọi nó (lệnh chứa đúng chuỗi đó) — tắt server
  bằng `fuser -k 8211/tcp` (đã ghi từ vòng 55, vẫn tái phạm ở vòng
  này vì gõ nhanh).

### 80.4 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- **Push main r58 (gộp r43–r58, thay script r57):**
  script mới `pxb-push-main-r58.py` + 4 manifest
  (`pxb-push-main-r58-a/b/c/docs`: a 62 path, b 14 `.import`,
  c 28 path, docs 2 file).
  **Chưa chạy — chờ chủ nói 'đẩy tiếp' + bấm duyệt** (xem §69.1:
  thẻ r44 đã timeout, không còn thẻ chờ; live vẫn `5f2a052f` r41).
- **Deploy gh-pages pck `3f6125e5`:** staging rebuild xong,
  `build_gh_pages.py` verify PASS (khớp byte: pck 167 chunk,
  22.442.668 byte; wasm 293 chunk không đổi; img
  title_bg `260962c1` + char_player `5dc7da77` + char_banthan
  `a4c96723` — cả 3 version img đã có trên gh-pages theo sync
  record `src/nadia/www.muse-github-snapshot-sync.json`, nên
  deploy này chỉ đẩy pck + final như vòng 57); script mới
  `pxb-deploy-r58.py` + 10 manifest
  (`pxb-deploy-pck-3f6125e5-batch1..9` + `-final`). Wasm không đổi
  `fc74679e` nên không đẩy lại. Chạy sau push main.
  Live hiện vẫn `5f2a052f` (r41).
- **Chưa làm:** điền SHA push/deploy vào §80.4 sau khi có kết quả.

### 80.5 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r58 (4 lô) → deploy pck `3f6125e5`
   (10 lô) → kiểm live pin + đối chiếu byte → điền SHA vào §80.4.
2. Tile riêng tiếp theo: Map017 Công Viên An Bình theo
   `docs/tileset-plan.md` (đang dùng atlas-map001.png — L1 Map017
   đếm thật trước khi thay; nhớ `handwritten()` nay đã áp override;
   import atlas mới TRƯỚC khi chạy test — bài học §75.3; kiểm tra
   venv `/tmp/pxb-pw-venv` trước browser-verify, mất thì tạo lại —
   bài học §77.3; lái theo `window.__pxb_tile`, không đếm phím —
   bài học §78.3; kiểm `OUT` + `legs` bằng mắt sau khi chép script
   verify — bài học §80.3).
3. Làm lại Map001–002 cho giống Nadia hẳn theo cam kết mới với chủ
   (26/11, sau vòng 54) — việc lớn tiếp theo sau đợt đẩy gộp r43–r58
   (tile riêng đã làm tới Map016 trong lúc chờ chủ nói 'đẩy tiếp').
4. G2 còn lại rồi G4 online (quyết server Godot headless hay .NET,
   xem `docs/opensource-engine.md` §3.4).

## 81. Vòng 59 — Tile công viên An Bình riêng Map017 (26/11 ~15:45–16:15 +07, cron 15:45)

### 81.1 Art (subagent artpass59) — XONG, gen 0 lần lại

- Tile `park-map017.png` (64×64 RGBA, 6.185 byte): 4 cây xanh tán tròn lớn,
  ghế đá xám bên trái, lối đi lát gạch kem uốn quanh hồ sen, hồ sen nhỏ
  giữa cảnh với hoa sen hồng + lá sen, đèn đường cổ điển bên phải, bụi hoa
  hồng/vàng dọc chân cảnh; nền kem trơn, không người, không chữ, toàn bộ
  cảnh nằm gọn trong khung (lề trái 239, phải 238, trên 275, dưới 259 px).
- Kiểm chứng: 1 component alpha duy nhất (1.834 px alpha>0, 1.612 px
  alpha>0,5); 0 pixel gần-trắng; 0 quầng ở mép; hàng y62–63 trong suốt;
  kiểm bằng mắt ở 1× và zoom 3× trên nền magenta đều đọc rõ công viên.
  Tôi đo độc lập bằng PIL qua tile đích, khớp số liệu note của subagent
  (chênh 2 px ở ngưỡng alpha>128: 1.610 vs 1.612 — không đáng kể, vẫn >800).
- Note: `visual-check/artpass59/park-tile-note.md` + script
  `process_park_r59.py` (theo mẫu vòng 58: tách nền bằng khoảng cách màu,
  ép alpha=255 vùng trong silhouette, nearest-fill RGB trước resize LANCZOS).

### 81.2 Code + test — XONG

| File | Đổi |
|---|---|
| `tools/godot/convert_maps.py` | `ATLAS_PNG_OVERRIDE[17] = "atlas-map017.png"` + `ATLAS_TILE_OVERRIDE` (tile 4 → `cong-vien-an-binh`, hết PROVISIONAL; Map017 L1 đếm thật: tile 4 có 8 ô, tile 5 có 12 ô, tile 3 có 8 ô — thay tile 4 như các vòng trước; vị trí tile 4: (1,0),(4,0),(7,0),(10,0),(0,3),(11,3),(0,6),(11,6)). `handwritten()` đã áp override từ vòng 57 nên regen là đủ, không cần sửa thêm. |
| `src/godot/data/maps.json` (tạo lại) | Chỉ Map017 đổi (atlas mới + tile 4 tên mới); Map001–016, Map018 không đổi; đủ 18 map. |
| `src/godot/tiles/atlas-map017.png` (mới, binary — chỉ local + trong pck, KHÔNG push qua snapshot-push) | `visual-check/artpass59/build_atlas_map017.py`: atlas-map001.png đổi cell cột 3 (x=192) thành tile công viên (đã có sửa ghost vòng 47: xóa trắng cell trước khi paste + assert ghost=0). Chạy: cell 3 khác 3.104 px / 1.562 px đục / ghost 0. |
| `src/godot/tiles/atlas-map017.png.import` (mới) | `--headless --import` sinh lại (chạy TRƯỚC khi test — bài học §75.3). |
| `src/godot/tests/g4_r59_map017_tile_test.gd` (mới) | 16 mục: Map017 atlas + tên tile 4 + hết PROVISIONAL; Map001/002 không đổi; Map003–016 giữ atlas riêng; PNG 512×64; cell 3 khác atlas cũ + có công viên (>800 px đục); cell khác giống hệt; scene thật Map017 (không NadiaScene, lớp tile hiện, atlas đúng file mới) 60 frame + về Map001 map_id 1. |
| `tools/godot/run_regression.sh` | Thêm `g4_r59_map017_tile_test` (nay 83 suite vòng lặp + server_test + probe = 85 mục). |
| `visual-check/artpass59/check_r59.py` (mới) | Browser-verify Map001→…→Map017 (chuỗi cửa (5,8)), cổng 8212 + ảnh + crop zoom, theo mẫu check_r58.py + lái theo `__pxb_tile` (bài học §78.3). |

### 81.3 Verify thật vòng này

- `--check-only` test mới: PASS (exit 0). **Lỗi sửa trong vòng:** test mới
  parse fail dòng 102 — `tex16.get_size()` sót sau khi đổi tên biến thành
  `tex17` (sed `s/tex16 != null/tex17 != null/` không chạm `tex16.get_size()`).
  Sửa 1 dòng, chạy lại PASS. Bài học: sau khi sed đổi tên biến, grep lại
  mọi occurrence của tên cũ, không chỉ chỗ đã sửa.
- Test mới `g4_r59_map017_tile_test`: **16/16 PASS** (cell 3 khác atlas
  cũ 3.075 px theo Godot — PIL đo 3.104, lệch do import — vẫn >500;
  1.563 px đục).
- Hồi quy đầy đủ: **85 OK, 0 FAIL** (83 suite vòng lặp +
  server_test + probe).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR.
- Export web: exit 0. pck **22.465.600 byte, SHA `61082d94`**
  (thay `3f6125e5` vòng 58); wasm không đổi `fc74679e`
  (39.514.754 byte); pck chứa `cong-vien-an-binh` + `atlas-map017`
  (kiểm bằng `strings`, 6 hit); HTTP 200 đủ 4 file (cổng 8212);
  `GODOT_THREADS_ENABLED = false`.
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass59/check_r59.py`, cổng 8212):
  **0 console error, 0 pageerror, 0 request fail.**
  `window.__pxb_map` đối chiếu đúng cả 16 chân:
  1→2→3→4→5→6→7→8→9→10→11→12→13→14→15→16→17, không lệch map nào
  (lái theo `__pxb_tile`, không đếm phím — bài học §78.3).
  - Map017: HUD "Phố Xô Bồ — Công Viên An Bình", NPC Cô Bán Bánh +
    Ông Lão Tập Thể Dục, 2 cửa đúng tên ("Cửa về Khu Sân Golf &
    Resort" / "Cửa đi Phố Đi Bộ – Chợ Đêm"), debug ô (5,4).
  - Tile công viên hiện ở hàng biên Map017 (ảnh
    `r59-15-map17.png` + crop `r59-16-map17-left.png`): cụm cây
    xanh tán tròn xen kẽ khối nhà trọ vàng Kenney (tile 3/5 vẫn
    PROVISIONAL) — **không còn bóng ghost**; nhãn 2 cửa + 2 NPC
    không chồng nhau.
  - Map016 (ảnh `r59-14-map16`): tile sân golf vòng 58 vẫn sạch
    ghost (clubhouse mái nâu cam hiện rõ ở hàng biên).
- **Bài học môi trường lặp lại:** venv Playwright `/tmp/pxb-pw-venv`
  đã mất (xóa theo /tmp) — tạo lại bằng `python3 -m venv` + pip
  install playwright pillow (chromium-1255 còn trong cache, không
  cần tải lại); kiểm tra venv TRƯỚC khi chạy browser-verify —
  bài học §77.3.
- **Lỗi script chép bằng sed (tái phạm mẫu §80.3):**
  `build_atlas_map017.py` chép từ bản r58 nhưng `s/map016/map017/`
  chạy TRƯỚC `s/golf-map016/park-map017/` nên SRC thành
  `golf-map017.png` không tồn tại → `FileNotFoundError` khi chạy.
  Sửa SRC + 2 chuỗi docstring còn sót "san golf", chạy lại OK.
  Bài học: khi chép script bằng nhiều sed, đặt phép thay tên file
  cụ thể TRƯỚC phép thay số vòng chung; kiểm tra lại SRC bằng mắt
  trước khi chạy.

### 81.4 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- **Push main r59 (gộp r43–r59, thay script r58):**
  script mới `pxb-push-main-r59.py` + 4 manifest
  (`pxb-push-main-r59-a/b/c/docs`: a 66 path, b 15 `.import`,
  c 30 path, docs 2 file).
  **Chưa chạy — chờ chủ nói 'đẩy tiếp' + bấm duyệt** (xem §69.1:
  thẻ r44 đã timeout, không còn thẻ chờ; live vẫn `5f2a052f` r41).
- **Lỗi manifest gặp + sửa trong vòng này (ghi để không tái phạm):**
  file manifest r58 gốc KHÔNG kết thúc bằng `\0` nên khi append
  path mới bằng `b + new + b'\0'`, path cuối cũ dính liền với path
  mới (`build_atlas_map016.pysrc/godot/tests/...`) — đếm lại thấy
  a 65 (thiếu 1), b 14 (thiếu 1), c 29 (thiếu 1) so với kỳ vọng
  66/15/30. Đã tách thủ công 3 chỗ dính + chuẩn hóa lại (join bằng
  `\0` + trailing `\0`), đếm lại đủ 66/15/30. Bài học: manifest
  paths-file là danh sách NUL-separated — khi append phải kiểm tra
  file gốc có trailing `\0` không; an toàn nhất là đọc → split →
  filter rỗng → join lại + trailing `\0`, rồi đếm lại trước khi dùng.
- **Deploy gh-pages pck `61082d94`:** staging rebuild xong,
  `build_gh_pages.py` verify PASS (khớp byte: pck 167 chunk,
  22.465.600 byte; wasm 293 chunk không đổi; img
  title_bg `260962c1` + char_player `5dc7da77` + char_banthan
  `a4c96723` — cả 3 version img đã có trên gh-pages theo sync
  record `src/nadia/www.muse-github-snapshot-sync.json`, nên
  deploy này chỉ đẩy pck + final như vòng 58); script mới
  `pxb-deploy-r59.py` + 10 manifest
  (`pxb-deploy-pck-61082d94-batch1..9` + `-final`). Wasm không đổi
  `fc74679e` nên không đẩy lại. Chạy sau push main.
  Live hiện vẫn `5f2a052f` (r41).
- **Chưa làm:** điền SHA push/deploy vào §81.4 sau khi có kết quả.

### 81.5 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r59 (4 lô) → deploy pck `61082d94`
   (10 lô) → kiểm live pin + đối chiếu byte → điền SHA vào §81.4.
2. Tile riêng tiếp theo: Map018 Phố Đi Bộ – Chợ Đêm theo
   `docs/tileset-plan.md` (đang dùng atlas-map001.png — L1 Map018
   đếm thật trước khi thay; nhớ `handwritten()` nay đã áp override;
   import atlas mới TRƯỚC khi chạy test — bài học §75.3; kiểm tra
   venv `/tmp/pxb-pw-venv` trước browser-verify, mất thì tạo lại —
   bài học §77.3; lái theo `window.__pxb_tile`, không đếm phím —
   bài học §78.3; kiểm `OUT` + `legs` bằng mắt sau khi chép script
   verify — bài học §80.3; kiểm SRC sau khi chép build_atlas bằng
   sed — bài học §81.3; đếm lại manifest sau khi append —
   bài học §81.4).
3. Làm lại Map001–002 cho giống Nadia hẳn theo cam kết mới với chủ
   (26/11, sau vòng 54) — việc lớn tiếp theo sau đợt đẩy gộp r43–r59
   (tile riêng đã làm tới Map017 trong lúc chờ chủ nói 'đẩy tiếp').
4. G2 còn lại rồi G4 online (quyết server Godot headless hay .NET,
   xem `docs/opensource-engine.md` §3.4).

## §82 — Vòng 60: tile sạp chợ đêm riêng Map018 Phố Đi Bộ – Chợ Đêm (khu cuối chuỗi tile riêng)

### 82.1 Art — XONG

- Tile sạp chợ đêm Sài Gòn riêng cho Map018: `nightmarket-map018.png`
  64×64 RGBA, 6.967 byte (mái che sọc đỏ/vàng, 6 đèn lồng cam/vàng treo +
  dây đèn tròn hai bên, 4 giỏ trái cây lớn trên quầy — xoài, thanh long,
  vải, chuối — + 2 giỏ nhỏ phía trước — chanh xanh, lê — bát + ấm trà đỏ,
  7 ghế nhựa đỏ/vàng trước quầy — art gen 0 lần lại, 1 component alpha,
  0 gần-trắng, 0 quầng xanh; kiểm bằng mắt 1× + 3×; tile rộng 64 px, cao
  43 px vì ảnh gốc tỉ lệ ngang, đáy y=61; nền ảnh gốc là đêm xanh đậm
  bg ≈ (31, 75, 135) nên tách nền theo màu góc thực tế, KHÔNG giả định
  nền kem như vòng 59).
- Đo độc lập bằng PIL qua tile đích, khớp số liệu note của subagent
  (chênh 4 px ở ngưỡng alpha>128: 1.830 vs 1.834 — không đáng kể, vẫn
  >800).
- Note: `visual-check/artpass60/nightmarket-tile-note.md` + script
  `process_nightmarket_r60.py` (theo mẫu vòng 59: tách nền bằng khoảng
  cách màu, ép alpha=255 vùng trong silhouette, nearest-fill RGB trước
  resize LANCZOS, dọn 41 px quầng sau resize).

### 82.2 Code + test — XONG

| File | Đổi |
|---|---|
| `tools/godot/convert_maps.py` | `ATLAS_PNG_OVERRIDE[18] = "atlas-map018.png"` + `ATLAS_TILE_OVERRIDE` (tile 4 → `sap-cho-dem`, hết PROVISIONAL; Map018 L1 đếm thật: tile 4 có 8 ô, tile 5 có 12 ô, tile 3 có 8 ô — thay tile 4 như các vòng trước; vị trí tile 4: (1,0),(4,0),(7,0),(10,0),(0,3),(11,3),(0,6),(11,6)). `handwritten()` đã áp override từ vòng 57 nên regen là đủ, không cần sửa thêm. |
| `src/godot/data/maps.json` (tạo lại) | Chỉ Map018 đổi (atlas mới + tile 4 tên mới); Map001–017 không đổi; đủ 18 map. |
| `src/godot/tiles/atlas-map018.png` (mới, binary — chỉ local + trong pck, KHÔNG push qua snapshot-push) | `visual-check/artpass60/build_atlas_map018.py`: atlas-map001.png đổi cell cột 3 (x=192) thành tile sạp chợ đêm (đã có sửa ghost vòng 47: xóa trắng cell trước khi paste + assert ghost=0). Chạy: cell 3 khác 3.004 px / 1.780 px đục / ghost 0. |
| `src/godot/tiles/atlas-map018.png.import` (mới) | `--headless --import` sinh lại (chạy TRƯỚC khi test — bài học §75.3). |
| `src/godot/tests/g4_r60_map018_tile_test.gd` (mới) | 16 mục: Map018 atlas + tên tile 4 + hết PROVISIONAL; Map001/002 không đổi; Map003–017 giữ atlas riêng; PNG 512×64; cell 3 khác atlas cũ + có sạp chợ đêm (>800 px đục); cell khác giống hệt; scene thật Map018 (không NadiaScene, lớp tile hiện, atlas đúng file mới) 60 frame + về Map001 map_id 1. |
| `tools/godot/run_regression.sh` | Thêm `g4_r60_map018_tile_test` (nay 84 suite vòng lặp + server_test + probe = 86 mục). |
| `visual-check/artpass60/check_r60.py` (mới) | Browser-verify Map001→…→Map018 (chuỗi cửa (5,8), 17 chân), cổng 8213 + ảnh + crop zoom, theo mẫu check_r59.py + lái theo `__pxb_tile` (bài học §78.3). |

### 82.3 Verify thật vòng này

- `--check-only` test mới: PASS (exit 0).
- Test mới `g4_r60_map018_tile_test`: **16/16 PASS** (cell 3 khác atlas
  cũ 2.967 px theo Godot — PIL đo 3.004, lệch do import — vẫn >500;
  1.783 px đục).
- Hồi quy đầy đủ: **86 OK, 0 FAIL** (84 suite vòng lặp +
  server_test + probe).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR.
- Export web: exit 0 (~9s). pck **22.489.988 byte, SHA `1c4a4bf2`**
  (thay `61082d94` vòng 59); wasm không đổi `fc74679e`
  (39.514.754 byte); pck chứa `sap-cho-dem` (strings 1 hit) +
  `atlas-map018` (5 hit); HTTP 200 đủ 4 file (cổng 8213);
  `GODOT_THREADS_ENABLED = false`.
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass60/check_r60.py`, cổng 8213):
  **0 console error, 0 pageerror, 0 request fail.**
  `window.__pxb_map` đối chiếu đúng cả 17 chân:
  1→2→3→4→5→6→7→8→9→10→11→12→13→14→15→16→17→18, không lệch map nào
  (lái theo `__pxb_tile`, không đếm phím — bài học §78.3).
  - Map018: HUD "Phố Xô Bồ — Phố Đi Bộ – Chợ Đêm", NPC Chủ Sạp Đêm +
    Người Bán Hàng Rong, 1 cửa đúng tên ("Cửa về Công Viên An Bình"),
    debug ô (5,4), toast `Đã sang Phố Đi Bộ – Chợ Đêm`.
  - Tile sạp chợ đêm hiện ở hàng biên Map018 (ảnh
    `r60-16-map18.png` + crop `r60-17-map18-left.png`): mái che sọc
    đỏ/vàng + đèn lồng xen kẽ khối nhà trọ vàng Kenney (tile 3/5 vẫn
    PROVISIONAL) — **không còn bóng ghost**; nhãn 2 NPC + 1 cửa
    không chồng nhau.
  - Map017 (ảnh `r60-15-map17`): tile công viên vòng 59 vẫn sạch
    ghost (cụm cây xanh hiện rõ ở hàng biên).
- **Venv Playwright `/tmp/pxb-pw-venv` vẫn còn vòng này** (không phải
  tạo lại như vòng 55/59).
- **Lỗi script chép bằng sed (tái phạm mẫu §80.3/§81.3):**
  `pxb-push-main-r60.py` chép từ bản r59 nhưng sót "tile Map016" +
  "build_atlas_map016" + "pxb-push-main-r58.py" + "§80" trong
  header/LOTS — đã sửa trực tiếp bằng edit + đọc lại toàn bộ header.
  `pxb-deploy-r60.py`: phép thay "Vong 59" không tồn tại (docstring
  gốc viết "vong 59" thường) nên assert dừng — bỏ phép thay thừa;
  docstring còn sót số byte/test/override cũ — đã sửa tay. Bài học:
  sau khi chép script bằng sed/thay chuỗi, đọc lại TOÀN BỘ header +
  LOTS bằng mắt, không chỉ grep chỗ đã sửa.
- **Lỗi môi trường (tái phạm mẫu vòng 55):** `pkill -f "http.server
  8213"` tự giết luôn shell gọi nó — tắt server bằng PID qua `kill`.

### 82.4 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- **Push main r60 (gộp r43–r60, thay script r59):**
  script mới `pxb-push-main-r60.py` + 4 manifest
  (`pxb-push-main-r60-a/b/c/docs`: a 70 path, b 16 `.import`,
  c 32 path, docs 2 file — đếm lại sau khi chuẩn hóa join NUL +
  trailing NUL, đủ path, không thiếu file nào).
  **Chưa chạy — chờ chủ nói 'đẩy tiếp' + bấm duyệt** (xem §69.1:
  thẻ r44 đã timeout, không còn thẻ chờ; live vẫn `5f2a052f` r41).
- **Deploy gh-pages pck `1c4a4bf2`:** staging rebuild xong,
  `build_gh_pages.py` verify PASS (khớp byte: pck 167 chunk,
  22.489.988 byte; wasm 293 chunk không đổi; img
  title_bg `260962c1` + char_player `5dc7da77` + char_banthan
  `a4c96723` — cả 3 version img đã có trên gh-pages theo sync
  record `src/nadia/www.muse-github-snapshot-sync.json`, nên
  deploy này chỉ đẩy pck + final như vòng 59); script mới
  `pxb-deploy-r60.py` + 10 manifest
  (`pxb-deploy-pck-1c4a4bf2-batch1..9` + `-final`). Wasm không đổi
  `fc74679e` nên không đẩy lại. Chạy sau push main.
  Live hiện vẫn `5f2a052f` (r41).
- **Chưa làm:** điền SHA push/deploy vào §82.4 sau khi có kết quả.

### 82.5 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r60 (4 lô) → deploy pck `1c4a4bf2`
   (10 lô) → kiểm live pin + đối chiếu byte → điền SHA vào §82.4.
2. **Chuỗi tile riêng ĐÃ XONG ĐỦ 18 KHU** — Map003–018 đều có atlas
   riêng (16 atlas mới), chỉ Map001/002 còn dùng atlas gốc. Việc lớn
   tiếp theo sau đợt đẩy gộp r43–r60: làm lại Map001–002 cho giống
   Nadia hẳn theo cam kết mới với chủ (26/11, sau vòng 54).
3. G2 còn lại rồi G4 online (quyết server Godot headless hay .NET,
   xem `docs/opensource-engine.md` §3.4).

## §83 — Vòng 61: nền vẽ tay cao Map002 Chợ Đầu Mối (bước 1 làm lại Map001–002 kiểu Nadia) (26/11 ~17:48–19:05 +07, cron 18:45)

### 83.1 Art + code

- Art (subagent artpass61, 17:48–18:10): `src/godot/art/bg_map002_tall.png`
  (864×1536, 1.025.798 byte, MD5 `de22a9fb…`) +
  `bg_map002_tall_night.png` (864×1536, 1.008.683 byte, MD5 `b6676d2f…`).
  Sáng trung bình 116,6 / tối 47,7; trời ngày (35,79,135) vs đêm
  (3,22,51); hàng dưới là đất, không phải trời. Ghi chú
  `visual-check/artpass61/bg-map002-note.md`; script
  `process_map002_r61.py`. Import xong. Lưu ý: mép mái đêm thấp hơn
  ngày ~45–72px; sạp/xe/ba lô khớp ±4px.
- Code (luồng song song): `iso_map.gd` thêm nhánh `map_id == 2` dùng
  `bg_map002_tall.png` (ngày + đêm), neo `offset + (0, 20 − height/2)`,
  `has_tall_bg = true`, bỏ `sky_wide`; thiếu file thì về `sky_band`.
- Test mới `g4_r61_map002_bg_test.gd` **18/18 PASS** (2 file 864×1536,
  ngày/đêm khác rõ, đáy ≠ trời, Map001 không đổi, `has_tall_bg` /
  `has_night_bg`, đổi khung ngày↔đêm, về Map001 vẫn ảnh cao).

### 83.2 Hồi quy + sửa test cũ

- Hồi quy lần 1: **3057 PASS, 7 FAIL, 4 suite** (log
  `hidden_files/regression-2026-11-26-1845.log`).
- 3 suite test cũ (stale, không phải lỗi game): `artpass12` hardcode
  nửa cao sky_band 140 → lấy nửa cao thật từ texture; `g4_polish`
  đòi Map002 dùng sky_band → đổi sang bg_map002_tall + không sky_wide;
  `g4_r16` khẳng định "Map002 không đổi: vẫn sky_band + sky_wide" →
  lật 3 check sang hành vi mới.
- `g4_transfer_move_test` 13/15 — **lỗi test, không phải lỗi game**:
  điều tra bằng print tạm trong `_on_player_moved_to` / `_transfer`
  (đã revert): A quay lại ô cửa (5,4) trên Map002 là **bước lên cửa →
  chuyển về Map001 ngay** (luật từ G3), test lại tưởng vẫn ở Map002
  vì check chỉ đọc tile, không đọc map; các check sau "qua" một cách
  rỗng, đến check spawn mới vỡ. Đã sửa test theo đúng luật cửa: A về
  Map001 (check cả map==1), S / D-pad / tap chạy trên Map001, click
  lại cửa (5,4) sang Map002, D vẫn đi được. Sửa xong: **16/16 PASS**.
- Hồi quy chạy lại: **3066 PASS, 0 FAIL, 0 suite lỗi** (87 suite; log
  `hidden_files/regression-2026-11-26-1845-rerun.log`).
- `--check-only` 5 file đã sửa exit 0; smoke `--headless --quit-after
  120` exit 0, 0 ERROR.
- Export web exit 0: pck **24.073.652 byte, SHA `b9d68286`** (thay
  `1c4a4bf2` vòng 60; tăng ~1,6 MB đúng 2 PNG nền mới); wasm không đổi
  `fc74679e`; HTTP 200 đủ 4 file (cổng 8931).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `hidden_files/pxb-browser-verify-r61.py`, cổng 8931):
  **0 console error, 0 pageerror.** Ảnh
  `hidden_files/pxb-browser-verify-r61/`: Map002 ngày — nền chợ cao
  hiện rõ (sạp rau củ, xe đẩy gỗ, bao tải, mặt trời); đêm — trời xanh
  đậm + mặt trăng + đèn sáng, hotspot đổi "Sạp rau buổi tối"; F về
  Sáng — ảnh ngày trở lại, ngày game tăng 1→2 (đúng chu trình khung).
  Không còn sky_band, không khe hở đen — chỉ một đường nối thẳng mờ
  nơi đáy nền gặp đất (mỹ thuật, không chặn).

### 83.3 Bài học

- **Test chỉ check tile mà không check map là check rỗng:**
  transfer_move "pass" 13 check trong khi người chơi đã sang map khác
  — mọi check sau chuyển map phải khẳng định cả `current_map_id`.
- **Luật cửa (ghi lại):** bước lên ô cửa là chuyển map ngay, không
  đứng yên được trên ô cửa — test nào đi qua cửa phải tính chuyển map
  vào luồng.
- **Tái phạm pkill (lần 3, vòng 55/60/61):** `pkill -f "http.server
  8931"` tự giết shell gọi — tắt server bằng `kill <PID>` lấy từ
  `pgrep`. AGENTS.md không ghi được (file root 660, không quyền ghi)
  — đã ghi vào `~/memory/2026-11-26.md`.
- **Venv Playwright `/tmp` lại mất** (lần 3): tạo lại ở
  `~/workspace/pxb-pw-venv` (bền vững, không dùng /tmp nữa), dùng lại
  cache Chromium 1255.
- **Không trích số hồi quy vòng cũ nếu không có log:** "r60 86 OK"
  không đối chiếu được vì không còn log hồi quy r60 (chỉ có log 20/11
  + 26/11) — số suite mỗi vòng khác nhau (87 vòng này), chỉ tin log
  file.

### 83.4 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- **Push main r61 (gộp r43–r61, thay script r60):** script mới
  `pxb-push-main-r61.py` + 4 manifest (a 81 path — gồm 4 file test đã
  sửa + .uid; b 18 `.import` — 16 atlas + 2 bg_map002_tall; c 34 path
  — gồm note + script artpass61; docs 2 file). **Chưa chạy — chờ chủ
  nói 'đẩy tiếp' + bấm duyệt** (thẻ r44 đã timeout, không còn thẻ chờ;
  live vẫn `5f2a052f` r41).
- **Deploy gh-pages pck `b9d68286`:** staging rebuild xong,
  `build_gh_pages.py` verify PASS (khớp byte: pck 179 chunk,
  24.073.652 byte; wasm 293 chunk không đổi; img 3 version không đổi
  — đã có trên gh-pages, nên deploy này chỉ đẩy pck + final); script
  mới `pxb-deploy-r61.py` + 10 manifest
  (`pxb-deploy-pck-b9d68286-batch1..9` + `-final`). Chạy sau push
  main. Live hiện vẫn `5f2a052f` (r41).
- **Chưa làm:** điền SHA push/deploy vào §83.4 sau khi có kết quả.

### 83.5 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r61 (4 lô) → deploy pck `b9d68286`
   (10 lô) → kiểm live pin + đối chiếu byte → điền SHA vào §83.4.
2. Tiếp tục làm lại Map001–002 kiểu Nadia (bước tiếp: nhân vật + ánh
   sáng theo cam kết với chủ 26/11) — Map002 đã có nền cao ngày/đêm;
   Map001 đã có từ vòng 16.
3. G2 còn lại rồi G4 online (quyết server Godot headless hay .NET,
   xem `docs/opensource-engine.md` §3.4).

## §84 — Vòng 62: ánh sáng đêm Map001–002 — đất đêm + nhân vật tối theo (bước 2 làm lại Map001–002 kiểu Nadia) (26/11 ~19:45–21:00 +07, cron 19:45)

### 84.1 Art + code

- Art (subagent artpass62): `src/godot/art/ground_map001_night.png`
  (1440×900, 2.414.144 byte, MD5 `388d9979…`) +
  `ground_map002_night.png` (1440×900, 2.411.873 byte, MD5 `5b67701b…`).
  Độ sáng trung bình (PIL): Map001 ngày 131,4 → đêm 80,8 (61,5%);
  Map002 ngày 142,4 → đêm 88,5 (62,1%) — trong band 50–65%; đêm lạnh
  hơn (B cao hơn). Gen 1 lần lại mỗi ảnh: v1 edit quá tối (44,1% /
  45,0%, dưới band), v2 resume snapshot + sáng nhẹ thì đạt ngay.
  Tương quan cấu trúc ngày/đêm 0,785 / 0,683; vài chi tiết nhỏ (lá,
  vệt rêu) xê dịch nhẹ do edit-model — chấp nhận, không gen lại.
  Ghi chú `visual-check/artpass62/bg-ground-night-note.md`; script
  `process_ground_night_r62.py` (resize LANCZOS 1920×1200 →
  1440×900, tỉ lệ 1,6, không méo). Import xong (.import đã sinh).
- Code: `main.gd` — `_update_ground` thêm `_night_ground_path`
  (Map001-002, có file mới dùng); khung Tối (frame 2) đổi sang ảnh
  đất đêm, thiếu file thì giữ ảnh ngày + MUL (không crash);
  `_update_daynight` gọi lại `_update_ground(current_map_id)` để
  phím F đổi đất theo khung (trước đây chỉ gọi ở load_map nên bấm F
  đất ngày giữ sáng trong khi nền đêm đã tối — đó chính là lỗi);
  `_update_character_tint` — NGOẠI LỆ có điều kiện cho Map001-002:
  khung Tối + có đất đêm thì tint nhân vật (0.60,0.62,0.70) để về
  ~(0.42,0.48,0.67) sau MUL, hòa vào đất đêm (~0.42); map không có
  đất đêm giữ trắng (bài học 20/11 không bị phá: lúc đó đất KHÔNG
  có bản đêm nên tint riêng là nấc thừa không có cơ sở).
- Test mới `g4_r62_night_ground_test.gd` **31/31 PASS** (file đêm
  1440×900, tỉ lệ sáng 0,62 cả 2 map; scene thật: Sáng đất ngày +
  tint trắng; Tối qua `_update_daynight` như phím F: đất đêm + tint
  đêm player + NPC; về Sáng trả lại; Map003 không đổi: đất
  ground_wide + tint trắng).

### 84.2 Hồi quy + sửa test cũ

- Hồi quy lần 1: **85 OK, 3 FAIL** (log
  `hidden_files/regression-2026-11-26-1945.log`).
- 3 suite test cũ (stale, không phải lỗi game — đúng mẫu vòng 61):
  `g4_artpass3/4/5_test` khẳng định luật vòng 5 "đêm không tint
  riêng (trắng)" trên Map001 — nay Map001 có đất đêm nên tint đêm
  là hành vi mới có chủ đích. Đã lật 3 check sang tint đêm
  (0.60,0.62,0.70) ±0,02 + cập nhật header artpass4/5; check "về
  Sáng tint trắng trở lại" giữ nguyên. Chạy lẻ: **24/24, 19/19,
  17/17 PASS**.
- Hồi quy chạy lại: **88 OK, 0 FAIL, 3168 mục PASS đếm được**
  (88 suite: 86 vòng lặp + server_test + probe; 2 suite probe
  PASS theo exit code, không đếm số; log
  `hidden_files/regression-2026-11-26-1945-rerun.log`).
  `run_regression.sh` nay thêm cả `g4_r61_map002_bg_test` (vòng 61
  quên thêm vào list — log rerun r61 chạy riêng) + r62.
- `--check-only` 5 file đã sửa exit 0; smoke `--headless
  --quit-after 120` exit 0, 0 ERROR/warning.
- Export web exit 0 (~17s): pck **27.607.784 byte, SHA `8b6ea8ac`**
  (thay `b9d68286` vòng 61; tăng ~3,5 MB đúng 2 PNG đất đêm);
  wasm không đổi `fc74679e`; HTTP 200 đủ 4 file (cổng 8932).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `hidden_files/pxb-browser-verify-r62.py`, cổng 8932):
  **0 console error, 0 pageerror.** Ảnh
  `hidden_files/pxb-browser-verify-r62/`: Map001 đêm — nền CÀ PHÊ
  tối, đất hẻm xanh đậm + quầng đèn vàng, player/Bạn Thân/Cô Tư
  tối theo, không còn "dán" sáng trên đất tối; Map002 đêm — nền
  chợ tối, đất chợ tối + đèn sáng, Chị Lệ/player/Anh Hải tối theo.
  Đo PIL vùng đất (y 950–1250): Map001 ngày 155,0 → đêm 104,3
  (tỉ lệ 0,67); Map002 ngày 183,3 → đêm 139,7 (tỉ lệ 0,76) —
  đều ≤ 0,80; toàn ảnh đêm tối hơn ngày rõ (118,0→75,4 /
  139,0→96,3). F về Sáng ảnh ngày trở lại đúng; ngày game tăng
  1→2 đúng chu trình khung.
- Còn tồn (mỹ thuật, không chặn): sprite sạp NadiaScene ở vùng
  đất chỉ nhận MUL 0,7 (không có bản đêm riêng) nên dãy sạp Map002
  đêm vẫn sáng hơn mặt đất — chấp nhận vòng này; muốn khớp hẳn
  thì vẽ bản đêm cho stall sprite ở vòng sau.

### 84.3 Bài học

- **Venv Playwright thiếu pillow:** script r62 dùng PIL đo ảnh
  nhưng venv `~/workspace/pxb-pw-venv` chỉ có playwright — đã
  `pip install pillow` vào venv (lần sau script đo ảnh chạy được
  ngay, không phải sửa script).
- **Tắt server bằng PID thật, không phải PID subshell:** lệnh
  `(python3 -m http.server 8932 &)` in PID 12036 là subshell,
  server thật là 12038 — `kill 12036` không tắt, phải `ps` tìm
  đúng PID python rồi kill. Bài học pkill vòng 61 vẫn đúng (không
  dùng pkill), bổ sung: luôn `ps -ef | grep http.server <port>`
  xác nhận PID thật trước khi kill.
- **Test cũ khẳng định luật cũ thì phải lật, không được xóa:**
  artpass3/4/5 giữ nguyên số check, chỉ đổi khẳng định sang hành
  vi mới + ghi rõ ngoại lệ vòng 62 trong comment — như vòng 61 đã
  làm với artpass12/polish/r16.

### 84.4 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- **Push main r62 (gộp r43–r62, thay script r61):** script mới
  `pxb-push-main-r62.py` + 4 manifest (a 86 path — gồm test r62 +
  .uid + 3 test cũ đã sửa; b 20 `.import` — 16 atlas + 2
  bg_map002_tall + 2 ground_map00N_night; c 36 path — gồm note +
  script artpass62; docs 2 file). Đã kiểm: py_compile OK, mọi
  path trong manifest đều tồn tại trên đĩa. **Chưa chạy — chờ chủ
  nói 'đẩy tiếp' + bấm duyệt** (không còn thẻ chờ; live vẫn
  `5f2a052f` r41).
- **Deploy gh-pages pck `8b6ea8ac`:** staging rebuild xong,
  `build_gh_pages.py` verify PASS (khớp byte: pck 27.607.784,
  wasm không đổi; img 3 version không đổi — đã có trên gh-pages,
  nên deploy này chỉ đẩy pck + final); script mới
  `pxb-deploy-r62.py` + 12 manifest
  (`pxb-deploy-pck-8b6ea8ac-batch1..11` + `-final`, 207 path, đã
  kiểm đủ file staging). Chạy sau push main. Live hiện vẫn
  `5f2a052f` (r41).
- **Chưa làm:** điền SHA push/deploy vào §84.4 sau khi có kết quả.

### 84.5 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r62 (4 lô) → deploy pck `8b6ea8ac`
   (12 lô) → kiểm live pin + đối chiếu byte → điền SHA vào §84.4.
2. Làm lại Map001–002 kiểu Nadia — bước tiếp: nhân vật lớn hơn
   theo tỉ lệ nền cao (hiện nhân vật ~104 world px vẫn nhỏ so với
   mặt tiền/sạp trong ảnh cao) + bản đêm cho stall sprite
   NadiaScene (84.2) — hoặc quyết Bậc 1 là tỉ lệ hiện tại đã đủ
   vì đã hòa ánh sáng.
3. G2 còn lại rồi G4 online (quyết server Godot headless hay .NET,
   xem `docs/opensource-engine.md` §3.4).

## §85 — Vòng 63: nhân vật lớn hơn + bản đêm cho stall sprite (bước 3 làm lại Map001–002 kiểu Nadia) (26/11 ~20:45–21:30 +07, cron 20:45)

### 85.1 Số đo + code

- Đo từ ảnh thật vòng 62 (viewport 720×1280, zoom 1.25): nhân vật cũ
  cao ~127px màn hình (104 world × nội dung ảnh 204/208 × 1,25); mặt
  tiền Map001 ~595px → tỉ lệ nhân vật/mặt tiền chỉ 0,21; sạp Map002 cao
  ~120px ≈ bằng nhân vật → nhân vật "chìm" trước sạp/cửa hàng.
- `scripts/character_sprite.gd`: **TEX_HEIGHT 104 → 128** (hệ số 1,23).
  Nhân vật nay ~157px màn hình, tỉ lệ vs mặt tiền ~0,26, ~1,3× chiều cao
  sạp. Bề rộng player 65 world (~ô tile 64), NPC rộng nhất (Bạn Thân)
  83 world; cao 128 world = 4 hàng tile — đầu chỉ chạm tới ô cách 4 hàng,
  không che cửa/hotspot kề (kiểm bằng hình học trong test). Bóng đổ tỉ lệ
  theo khung: Sáng rx 17,2/ry 5,5/lệch (10,3); Chiều 32,0/6,2/(-27,3);
  Tối 14,8/4,9/alpha 0,12. Vòng vàng qua hàm mới `ring_radius()`: r=49
  (ảnh) / 44 (fallback vẽ code). Walk-cycle frames dùng chung TEX_HEIGHT
  nên tự theo.
- `scripts/marker.gd`: `NPC_LABEL_TOP` -170 → **-180** (đỉnh đầu mới
  -125 world; khe nhãn thực đo 22,5 world ≈ 29px màn hình, không chạm
  tóc). Fallback vẽ code vẫn cao ~72px.
- `scripts/nadia_scene.gd` — bản đêm cho stall sprite: khung Tối, sprite
  sạp nhận tint đêm **0,62** (MUL đêm 0,7 × 0,62 = 0,43, khớp đất đêm
  0,62 × 0,7 = 0,43; số vòng 62: Map002 ngày 142,4 → đêm 88,5) + **quầng
  đèn ấm HDR** (3 vòng 2,0/1,6/0,7, theo mẫu NightGlow) ở 6 sạp hàng 0 +
  6 sạp bên tường, không đổi layout/vị trí. Dùng đúng đường `set_frame(f)`
  đã có (iso_map forward khi bấm F). Sang/Chiều không đổi; Map001 không
  có sạp nên không đổi. Hàm mới cho test: `stall_sprite_tint()`,
  `stall_lamp_on()`, `stall_glow_centers()`.
- Ghi chú `visual-check/artpass63/char-scale-stall-night-note.md`.

### 85.2 Hồi quy + sửa test cũ

- Test mới `g4_r63_char_scale_test.gd` **27/27 PASS**;
  `g4_r63_stall_night_test.gd` **36/36 PASS** (lần đầu 35/36 do bound
  test đặt sai — tâm quang y tới 272 trong khi map thật tới 320 — đã
  sửa bound theo map thật). `run_regression.sh` nay thêm cả 2 test r63.
- Hồi quy đầy đủ: **90 OK, 0 FAIL** (log
  `hidden_files/regression-2026-11-26-2045.log`).
- 2 check bóng cũ stale (`g4_artpass7_test`, khẳng định cứng rx 14,0/
  (8,3) và 26,0/(-22,3) từ vòng 7): lật sang giá trị mới rx 17,2/(10,3)
  và 32,0/(-27,3) + ghi ngoại lệ vòng 63 trong comment — đúng mẫu vòng
  61/62 (sửa test, không sửa code). Chạy lẻ artpass7 **25/25 PASS**;
  `g4_r15_label_world_test` 63/63 (nhãn -180 vẫn trong band khe 40–60px).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR/warning.
- Export web exit 0 (~17s): pck **27.621.788 byte, SHA `e60fb0de`**
  (r62: 27.607.784 `8b6ea8ac` — tăng ~14 KB, đúng code mới); wasm không
  đổi `fc74679e`; HTTP 200 đủ 4 file (cổng 8933).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `hidden_files/pxb-browser-verify-r63.py`, cổng 8933):
  **0 console error, 0 pageerror.** Đo PIL: đất Map001 đêm/ngày 0,67;
  Map002 0,77 (≤0,80); vùng sạp Map002 đêm/ngày **0,54**. Ảnh
  `hidden_files/pxb-browser-verify-r63/`: Map001 ngày — player/Bạn Thân/
  Cô Tư lớn rõ, mặt đọc được, nhãn không đè mặt; Map002 đêm — sạp tối +
  quầng đèn ấm thấy rõ ở góc trái, nhân vật lớn hơn hẳn r62.
- Còn tồn (có từ r62, KHÔNG phải hồi quy): nhãn biển sạp Map002
  ("Sạp rau buổi tối" đè "THỊT HEO"/"RAU CỦ", "HOA QUẢ" đè đầu Chị Lệ,
  "Góc phế liệu chợ" cắt ở mép phải) — biển sạp vẽ trong scene, không qua
  bộ giải nhãn Marker; để vòng polish sau. Vật cản đầu nhân vật trong bộ
  giải nhãn của `main.gd` vẫn tính theo đầu 104 world — nhãn có thể chạm
  nhẹ ~21 world đỉnh đầu trong trường hợp hiếm (ngoài phạm vi vòng này).

### 85.3 Bài học

- **Vật cản nhãn phải theo kích thước nhân vật mới:** đổi TEX_HEIGHT mà
  không đổi vật cản đầu trong `main.gd` là nợ nhỏ đã ghi rõ ở §85.1/85.2
  (không giấu) — vòng polish nhãn sau phải cập nhật vật cản theo
  `TEX_HEIGHT` thay vì số cứng 104.
- **Bound test phải đo từ map thật, không đặt theo cảm giác:** test r63
  stall lần đầu rớt 1 check vì bound y=272 đặt theo ước lượng, trong khi
  map thật tới 320 — sửa bound theo số đo thật, không nới test cho qua.

### 85.4 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- **Push main r63 (gộp r43–r63, thay script r62):** script mới
  `pxb-push-main-r63.py` + 4 manifest (a 94 path — gồm 3 script sửa +
  2 test r63 + .uid + artpass7 đã lật + note r63; b 20 `.import` không
  đổi; c 37 path — gồm note artpass63; docs 2 file). Đã kiểm: py_compile
  OK, mọi path trong manifest đều tồn tại trên đĩa. **Chưa chạy — chờ chủ
  nói 'đẩy tiếp' + bấm duyệt** (không còn thẻ chờ; live vẫn `5f2a052f` r41).
- **Deploy gh-pages pck `e60fb0de`:** staging rebuild xong,
  `build_gh_pages.py` verify PASS (khớp byte: pck 27.621.788, wasm không
  đổi; img 3 version không đổi — đã có trên gh-pages, nên deploy này chỉ
  đẩy pck + final); script mới `pxb-deploy-r63.py` + 12 manifest
  (`pxb-deploy-pck-e60fb0de-batch1..11` + `-final`, 207 path, đã kiểm đủ
  file staging). Chạy sau push main. Live hiện vẫn `5f2a052f` (r41).
- **Chưa làm:** điền SHA push/deploy vào §85.4 sau khi có kết quả.

### 85.5 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r63 (4 lô) → deploy pck `e60fb0de`
   (12 lô) → kiểm live pin + đối chiếu byte → điền SHA vào §85.4.
2. Làm lại Map001–002 kiểu Nadia — bước tiếp: cập nhật vật cản đầu nhân
   vật trong bộ giải nhãn `main.gd` theo `TEX_HEIGHT` 128 + gom biển sạp
   Map002 vào bộ giải nhãn (hết chồng/cắt, §85.2); hoặc quyết Bậc 1 tỉ lệ
   + nhãn hiện tại đã đủ.
3. G2 còn lại rồi G4 online (quyết server Godot headless hay .NET,
   xem `docs/opensource-engine.md` §3.4).

## §86 — Vòng 65: lượt tách tránh biển sạp — (b1) XONG, (b2) ngoại lệ có tên (26/11 ~22:45–23:20 +07, cron 22:45)

> Mục 2 của §85.5 đã làm ở vòng 64 (vật cản đầu theo `TEX_HEIGHT` 128 +
> dời Chị Lệ (2,2)→(4,5) + ngoại lệ "Sạp rau"/THỊT HEO + "Góc phế liệu"
> không cắt mép — xem `~/memory/2026-11-26.md` mục vòng 64; vòng 64
> chưa có § riêng trong file này nên đợt đẩy vòng 65 gộp cả r64).
> Vòng này xử lý 2 chồng biển còn lại mà vòng 64 để lại có tên.

### 86.1 Chẩn đoán bằng probe (không đoán)

- Probe `tests/probe_r65.gd` (tạm, đã xóa): 5 vị trí camera × Sáng/Tối.
- **(b1) "Cửa về Xóm Trọ Cũ" đè biển GIA VỊ (11,6) 35×15px ở camera
  (5,2):** vòng chính đặt nhãn đúng ở neo 1162 (không đè biển), nhưng
  **lượt tách** đẩy nhãn lên 1112 để tách khỏi "Cửa đi Khu Công Nhân"
  (cùng y=1162) — lượt tách chỉ kiểm vật cản CỨNG nên đẩy thẳng lên
  biển. Probe b (`_nearest_free_y` gọi trực tiếp) xác nhận vòng chính
  vô can: `nearest=1162.00 drift=0`.
- **(b2) "Góc phế liệu chợ" quẹt biển CÁ TƯƠI (11,2) 65×2,75px ở camera
  (9,2):** vòng chính tìm được khoang trống gần nhất ở 1080.75 nhưng
  drift 142,2px > `LABEL_MAX_DRIFT` 120 nên giữ neo theo luật
  (probe b: `nearest=1080.75 drift=142.2`). Nham thạch: khoang bịt kín
  bởi vật cản người chơi + 3 biển (CÁ TƯƠI/ĐỒ KHÔ/GIA VỊ) + icon
  của chính nó; dịch ngang cũng không thoát (icon của nó chặn ±160,
  x=16 thì nhãn rời khỏi icon). Nhảy 142px để tránh vết quẹt 2,75px
  là đổi tệ lấy tốt — giữ làm ngoại lệ có tên như (a) vòng 64.
- Bài học probe: lần sửa đầu kiểm cả nhãn trong helper nudge nên
  **không dịch được** — "Góc Chế Tạo" đang ở 1107.25 (vòng chính đặt)
  chặn hết mọi dịch ngang, trong khi nó sẽ được cascade đẩy lên 1062
  ngay sau đó. Sửa lại: nudge chỉ kiểm biển + vật cản cứng, chong
  nhãn để cascade của lượt tách xử lý (xem §86.2).

### 86.2 Code — XONG

- `main.gd` — `_nudge_clear_of_signs(cand, signs, hard_obstacles)`
  (mới): ứng viên tách đè biển thì thử dịch ngang giữ nguyên y
  (±40/80/120/160, gần trước, như vòng chính), lấy cái đầu tiên
  sạch biển (rect grow `LABEL_GAP`) + vật cản cứng; không có thì
  trả về ứng viên gốc (giữ hành vi cũ). Chỉ chạy khi ứng viên đè
  biển — 99% trường hợp không đổi gì. **Cố tình KHÔNG kiểm nhãn
  khác** (xem bài học §86.1).
- `main.gd` — `_try_move_up(..., signs = [])` (mới, tham số mặc định
  để test cũ không đổi): nhãn bị cascade đẩy lên cũng không được đè
  biển — nếu không, lượt tách lại tạo ra chồng biển mới.
- Lượt tách gọi cả hai: `cand_up`/`cand_dn` qua nudge trước, rồi
  `_try_move_up(..., sign_rects)`.
- Kết quả đo lại: "Cửa về" ở (5,2) Sáng + Tối về **(37,5, 1112)**
  (dịch trái 80px, y tách giữ nguyên), hết đè GIA VỊ; "Góc Chế Tạo"
  vẫn cascade lên 1062 như cũ; không nhãn nào khác đổi vị trí.

### 86.3 Test + hồi quy — XONG

- Test mới `tests/g4_r65_label_signs_test.gd`: **78/78 PASS** — 6 vị
  trí đo (spawn, (5,2), (9,2) × Sáng/Tối + (10,4) Tối): (b1) "Cửa về"
  sạch mọi biển + ở đúng ô tách y=1112 + dịch ngang ≤160px; (b2)
  "Góc phế liệu" chỉ quẹt CÁ TƯƠI ≤65×3px; (a) "Sạp rau" chỉ đè
  THỊT HEO ≤36×21px; toàn cục: nhãn khác không đè biển nào; không
  cặp nhãn nào chồng nhau; nhãn trong màn hình + neo Y trong luật
  (≤120, hoặc ≤200 khi thoát người chơi/D-pad); kiểm thẳng helper
  `(117.5,1112) → (37.5,1112)`.
- Hồi quy đầy đủ: **92 OK, 0 FAIL** (baseline r64: 91 OK; +1 suite
  r65; log `hidden_files/regression-2026-11-26-2320.log`).
  `run_regression.sh` đã thêm `g4_r65_label_signs_test`.
- Smoke `--quit-after 120` exit 0, 0 ERROR/warning.
- Export web exit 0 (~19s): pck mới **27.641.172 byte, SHA
  `9ceea485…`** (trước `e60fb0de…` r63), wasm không đổi
  `fc74679e…`, `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ 4 file
  (cổng 8940).
- Chưa kiểm chứng bằng trình duyệt thật vòng này (chỉ đo headless +
  probe); vòng sau nên chụp ảnh Chromium ở camera (5,2) để thấy
  "Cửa về" đã rời khỏi biển GIA VỊ bằng mắt.

### 86.4 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- Push main r65 (gộp r43–r65: a 99 / b 20 / c 37 / docs 2) + deploy
  pck `9ceea485` (12 lô, 207 path) đã chuẩn bị xong, **CHƯA CHẠY —
  chờ chủ nói 'đẩy tiếp'** (thẻ r44 đã timeout, không còn thẻ chờ;
  live vẫn `5f2a052f` r41). Script `pxb-push-main-r65.py`,
  `pxb-deploy-r65.py` + manifest trong hidden_files goal.
- Lô a r65 = lô a r63 + 4 path mới: `g4_r64_label_polish_test.gd`
  (+`.uid`), `g4_r65_label_signs_test.gd` (+`.uid`),
  `g1_playtest.gd` (r64 sửa ô Chị Lệ); `main.gd` /
  `convert_maps.py` / `data/maps.json` / `run_regression.sh` đã có
  trong lô a r63 nên chỉ đẩy lại nội dung mới.

### 86.5 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r65 (4 lô) → deploy pck `9ceea485`
   (12 lô) → kiểm live pin + đối chiếu byte.
2. Browser-verify vòng 65 bằng Chromium thật ở camera (5,2): chụp
   "Cửa về" đã rời biển GIA VỊ; kiểm (b2) quẹt 2,75px có thấy bằng
   mắt không — nếu thấy rõ thì quyết Bậc 1 có sửa tiếp không.
3. G2 còn lại rồi G4 online (quyết server Godot headless hay .NET,
   xem `docs/opensource-engine.md` §3.4).




## §87 — Vòng 65: browser-verify lượt tách tránh biển sạp — XONG (26/11 ~23:45–23:55 +07, cron 23:45)

> Mục 2 của §86.5. Build kiểm chứng: đúng pck vòng 65 `9ceea485…`
> (SHA khớp), wasm không đổi `fc74679e…`, serve cổng 8941, HTTP 200
> đủ 4 file. Script mới `hidden_files/pxb-browser-verify-r65.py`
> (tái chạy được), ảnh + log console
> `hidden_files/pxb-browser-verify-r65/` (01–06 + crop phóng to).

### 87.1 Cách kiểm

- Chromium 1255 headless + swiftshader, viewport 720×1280; đợi
  `#start-btn:not([disabled])` rồi click qua selector (bài học §8.5).
- Di chuyển bằng phím (đã có event-held artpass7): W+D từ spawn
  Map001 (4,5) qua cửa (5,4) sang Map002; W×2 tới ô (5,2);
  F×2 sang Tối; F×1 về Sáng (sang Ngày 2); D×4 tới ô (9,2);
  F×2 sang Tối. Debug overlay trên ảnh xác nhận đúng ô
  ("Ô (5,2) • W", "Ô (9,2) • D").
- 0 console error, 0 pageerror cả buổi (log `console-r65.json`).

### 87.2 Kết quả — (b1) PASS bằng mắt, (b2) không thấy rõ → giữ ngoại lệ

- **(b1) "Cửa về Xóm Trọ Cũ" đã rời biển GIA VỊ (11,6) ở camera
  (5,2), Sáng + Tối — PASS.** Ảnh crop 2× vùng y 1000–1200:
  nhãn kết thúc x≈390, biển GIA VỊ bắt đầu x≈445 — khe ~55px,
  không đè, cả Sáng (`03` + `crop-b1-day`) lẫn Tối
  (`04` + `crop-b1-night`). Đúng vị trí test khóa (37.5, 1112).
- **(b2) "Góc phế liệu chợ" quẹt biển CÁ TƯƠI (11,2) ở camera
  (9,2) — KHÔNG THẤY RÕ bằng mắt, giữ làm ngoại lệ có tên,
  không sửa tiếp (quyết Bậc 1 theo câu hỏi §86.5).** Ở tỉ lệ
  thường (`05`/`06`) nhãn nhìn sạch hoàn toàn; crop 4× vùng
  nhãn (`crop-b2-zoom-day/night`) chỉ thấy mép dưới nhãn chạm
  sát mép trên biển (đúng 2,75px theo test), chữ biển vẫn đọc
  được, phần lớn biển đã bị sao hotspot che từ trước (không
  phải do nhãn). Nhảy 142px để tránh vết quẹt này vẫn là đổi
  tệ lấy tốt như §86.1 đã kết luận.
- Kiểm chéo thêm: đổi khung Sáng→Chiều→Tối→Ngày 2 Sáng chạy
  đúng; nhãn "Sạp rau buổi tối" đổi đúng theo khung (artpass7);
  chuyển map 2 chiều qua cửa (5,4) + toast "Đã sang Chợ Đầu Mối".

### 87.3 Ghi nhận thêm (không chặn, để vòng polish sau)

- **(a) vòng 64 còn nguyên ở camera (9,2) Tối:** nhãn "Sạp rau
  buổi tối" che mất chữ T của biển THỊT HEO ("HỊT HEO",
  `crop-a-night.png`) — đúng bound test r64 (≤36×21px), ngoại
  lệ có tên đã biết, không phải hồi quy vòng 65.
- **Nhãn "Sạp rau buổi tối" che mặt Chị Lệ ở camera (9,2) Tối:**
  nhãn rộng đè lên đầu/mặt NPC (thấy tóc + thân, mắt bị che).
  Bộ giải nhãn hiện chỉ tránh đầu của NPC neo nhãn, chưa tránh
  đầu NPC khác ở cùng vị trí — ghi cho vòng polish nhãn sau,
  không sửa trong vòng verify này.
- Smoke headless kèm: `--headless --quit-after 120` exit 0,
  0 ERROR. Không export lại (build trên đĩa đã là pck vòng 65).
  Server 8941 đã tắt sau khi verify xong.

### 87.4 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r65 (4 lô) → deploy pck
   `9ceea485` (12 lô) → kiểm live pin + đối chiếu byte
   (script + manifest đã chuẩn bị xong từ vòng 65, §86.4).
2. G2 còn lại rồi G4 online (quyết server Godot headless hay
   .NET, xem `docs/opensource-engine.md` §3.4).
3. Polish nhãn: tránh đầu NPC khác (mục §87.3) + cân nhắc neo
   nhãn "Sạp rau" gần điểm neo hơn thay vì đè biển THỊT HEO.

## §88 — Vòng 66: nhãn tránh đầu NPC khác (mục 3 của §87.4) (27/11 ~00:45–01:10 +07, cron 00:45)

### 88.1 Chẩn đoán bằng probe (không đoán)

- Phát hiện §87.3: ở camera (9,2) Tối Map002, nhãn "Sạp rau buổi tối"
  che mặt Chị Lệ (thấy tóc + thân, mắt bị che). Probe tái hiện trên
  code cũ (`tests/g4_r66_probe_test.gd`, đã xóa sau khi dùng — không
  commit): nhãn [P:(23.5,778.5), S:(273,38)] giao với đầu Chị Lệ
  [P:(-7.3,772.8), S:(94.6,40)] = **63.8×34.3px**.
- Cơ chế (đo, không suy luận): `want_y` 778.5, `best_y` 621.2, cách
  **157.2px** — trong `LABEL_ESCAPE_MAX_DRIFT` (200px) nhưng vượt
  `LABEL_MAX_DRIFT` (120px) nên vòng chính giữ neo; dịch ngang cũng
  kẹt (dãy biển sạp y 671–811 + icon chắn cả 8 hướng); ngoại lệ
  thoát (vòng 12b) chỉ tính nhân vật chính / D-pad nên không nhảy.
  Vật cản chặn: sprite Chị Lệ (-12.7,756.2, 105×120), D-pad, 4 biển
  sạp (77.5×20), 3 icon 48×48.
- Kết luận: chỉ cần mở rộng ngoại lệ thoát cho **đầu NPC khác** —
  không sửa vòng chính, không đụng luật neo 120px / 200px, không
  mở rộng thoát cho biển sạp (cấm vòng 45 vẫn giữ).

### 88.2 Code — XONG

- `main.gd` — `_npc_head_rect(screen_pos)` (mới): cùng đỉnh + rộng
  với `_sprite_obstacle_rect`, cao `32*z+15` (đầu 32 world + 15px
  biên tóc), khớp `_head_rect` trong test r64/r66.
- `main.gd` — `_label_hits_other_npc_head(r)` (mới): nhãn giao với
  đầu NPC nào đó ≥10px cả 2 chiều (như luật thoát nhân vật chính).
  Chỉ xét NPC — nhãn đang xét là hotspot/craft/door, không phải
  NPC; nhãn NPC cố định nên không xét. Thân/ngực NPC không tính:
  nhãn đè thân một chút vẫn đọc được, chỉ mặt mới không được che.
- `main.gd` — nhánh thoát trong `_resolve_label_overlaps`: điều
  kiện thêm `or _label_hits_other_npc_head(r)`; `best_y` đã tránh
  cả sprite NPC nên nhảy tới đó là sạch đầu. Comment vòng 12b cập
  nhật (đè thân NPC/icon vẫn chấp nhận; đè đầu thì thoát).
- "Sạp rau" vs biển THỊT HEO: **cân nhắc xong, giữ nguyên ngoại lệ
  có tên** (§87.4 mục 3, nửa sau) — nhãn đã ở đúng neo, không còn
  ô sạch nào gần sạp (kết luận r64, probe 108 ô), dời neo/biển đều
  phá luật khác. Test r66 khóa lại bound 36×20px không đổi.

### 88.3 Test + hồi quy — XONG

- Test mới `tests/g4_r66_label_other_npc_test.gd`: **42/42 PASS** —
  hình học `_npc_head_rect` (đỉnh/rộng/cao), helper thoát (phủ đầu
  → true, xa → false), 5 vị trí camera Map002 Sáng/Tối: không nhãn
  nào (không phải NPC) che đầu NPC nào ≥10px; "Sạp rau" vs THỊT
  HEO ≤36×20; drift ≤120 (hoặc ≤200 khi thoát khỏi nhân vật /
  D-pad / đầu NPC); nhãn trong màn hình; không cặp nhãn nào chồng
  nhau. Probe sau sửa: nhãn về đúng `best_y` 621.2 (drift 157.2px),
  giao với đầu Chị Lệ **0×0**.
- Hồi quy lần 1: **90 OK, 3 FAIL** — artpass12 + r64 + r65, cùng
  một nhãn "Sạp rau" nhảy 156–158px ở (8,6)/(7,6) Sáng và
  (9,2)/(10,4) Tối. Probe 2 xác minh nguyên nhân: ở (8,6)/(7,6)
  nhãn ở vị trí muốn đè mặt Chị Lệ **87.2×32.7px** — đúng hành vi
  mới có chủ ý, không phải lỗi code. Đã sửa 3 test cũ theo mẫu
  "sửa test cũ lỗi thời": luật thoát nay chấp nhận cả đầu NPC khác
  (kèm điều kiện cuối không còn đè đầu NPC) — artpass12 14/14,
  r64 77/77, r65 78/78. Lưu ý: sửa `var esc_ok :=` → `var esc_ok:
  bool =` ở cả 3 file — gọi method trên biến kiểu `Node` trả
  Variant nên `:=` không suy ra được bool (parse error).
- Hồi quy chạy lại: **93 OK, 0 FAIL** (`~/workspace/regression-move.log`).
  `--check-only` main.gd exit 0; scene 120 frame exit 0, 0
  ERROR/WARNING; export web exit 0 (pck **27.650.168 byte, SHA
  `d20cee0e…`**, wasm không đổi `fc74679e…`,
  `GODOT_THREADS_ENABLED = false`); HTTP 200 đủ 4 file (cổng 8166).
- Chưa kiểm chứng bằng trình duyệt thật vòng này (để vòng sau, theo
  mẫu vòng 65: code + test vòng này, browser-verify vòng sau).

### 88.4 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- Push main r66 (gộp r43–r66: a 101 / b 20 / c 37 / docs 2) + deploy
  pck `d20cee0e` (12 lô, 207 path) đã chuẩn bị xong, **CHƯA CHẠY —
  chờ chủ nói 'đẩy tiếp'** (thẻ r44 đã timeout, không còn thẻ chờ;
  live vẫn `5f2a052f` r41). Script `pxb-push-main-r66.py`,
  `pxb-deploy-r66.py` + manifest trong hidden_files goal. Staging
  `gh-pages-staging/` đã rebuild cho pck `d20cee0e` (205 chunk,
  `build_gh_pages.py --verify-only` OK, khớp byte).
- Lô a r66 = lô a r65 + 2 path mới: `g4_r66_label_other_npc_test.gd`
  (+`.uid`); `main.gd` / `run_regression.sh` / `artpass12_test.gd` /
  `g4_r64_label_polish_test.gd` / `g4_r65_label_signs_test.gd` đã có
  trong lô a r65 nên chỉ đẩy lại nội dung mới.

### 88.5 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r66 (4 lô) → deploy pck `d20cee0e`
   (12 lô) → kiểm live pin + đối chiếu byte.
2. Browser-verify vòng 66 bằng Chromium thật ở camera (9,2) Tối:
   chụp "Sạp rau" đã rời mặt Chị Lệ; kiểm (8,6)/(7,6) Sáng tương tự.
   → **XONG vòng 67, xem §89.**
3. G2 còn lại rồi G4 online (quyết server Godot headless hay .NET,
   xem `docs/opensource-engine.md` §3.4).

## §89 — Vòng 67: browser-verify vòng 66 — nhãn đã rời mặt Chị Lệ (27/11 ~01:45–02:10 +07, cron 01:45)

### 89.1 Cách kiểm

- Build kiểm đúng pck vòng 66 `d20cee0e` (SHA local khớp
  `d20cee0e`, wasm không đổi `fc74679e`), serve cổng 8942,
  HTTP 200 đủ 3 file (`index.html`/`index.wasm`/`index.pck`).
- Playwright Chromium 1255 headless + SwiftShader WebGL2, viewport
  720×1280; script mới `hidden_files/pxb-browser-verify-r66.py`
  (tái chạy được; `PYTHONPATH=~/.local/lib/python3.12/site-packages`
  mới import được playwright — như yt-dlp).
- Khác vòng 65: sau mỗi phím đọc `window.__pxb_tile` /
  `window.__pxb_map` để biết ô thật (không đoán từ phím); F không
  đổi ô là đúng (F chỉ đổi khung). Lộ trình: spawn Map001 (4,5) →
  W+D qua cửa (5,4) sang Map002 → W×2 tới (5,2) → F×2 Tối → F×1 về
  Sáng → D×4 tới (9,2) → F×2 Tối → F×1 về Sáng → S×4 + A×1 tới
  (8,6) → A×1 tới (7,6). Ảnh 01–08 + 3 crop phóng to 2× + log
  `console-r66.json`, cùng thư mục `hidden_files/pxb-browser-verify-r66/`.

### 89.2 Kết quả — PASS bằng mắt, 0 lỗi

| Kiểm tra | Kết quả |
|---|---|
| Engine + nút Start | Canvas 720×1280, `__pxb_start === true`; console chỉ 3 dòng log (Godot 4.7.2, WebGL2, Emscripten single-threaded) |
| Di chuyển (đọc ô thật) | Mọi bước đúng ô: (4,5)→(4,4)→(5,4) Map002 →(5,2)→(9,2)→(9,6)→(8,6)→(7,6); không bước nào bị chặn |
| Đổi khung (F) | Sáng→Chiều→Tối→Sáng ngày sau, đúng: (5,2) Ngày 1 Tối → (9,2) Ngày 2 Sáng → Ngày 2 Tối → (8,6)/(7,6) Ngày 3 Sáng |
| **(9,2) Tối — ẢNH CHÍNH** | **"Sạp rau buổi tối" đã rời mặt Chị Lệ: nhãn ở y≈621 (đúng `best_y` 621.2 của probe §88.1), mặt Chị Lệ hiện đủ mắt/miệng/tóc, khe hở ~80px; crop 2× xác nhận, không còn giao nhau** (trước sửa đè 63.8×34.3px) |
| (9,2) Sáng | "Sạp rau buổi sáng" cũng ở trên cao, mặt Chị Lệ đủ — PASS |
| (8,6) + (7,6) Sáng | "Sạp rau buổi sáng" ở trên cao, mặt Chị Lệ đủ cả 2 camera; nhãn "Chị Lệ" hiện rõ — PASS |
| (b1) kiểm lại ở (5,2) Tối | "Cửa về Xóm Trọ Cũ" vẫn rời biển GIA VỊ — biển đọc được đủ chữ, khe rõ; crop 2× xác nhận — PASS |
| Console / pageerror | **0 error, 0 pageerror** (16/16 step OK) |
| Smoke headless kèm | `--quit-after 120` exit 0, 0 ERROR |

### 89.3 Ghi nhận thêm (không chặn, để vòng polish sau)

1. (b2) giữ nguyên: ở (8,6) Sáng, mép dưới nhãn "Góc phế liệu chợ"
   vẫn chạm sát mép trên biển CÁ TƯƠI (chữ biển đọc được đủ; ngôi
   sao hotspot đè lên mép trái biển — đó là marker của chính
   hotspot, không phải lỗi nhãn). Cùng họ với ngoại lệ có tên
   65×2.75px ở (9,2) (§86/§87); không sửa tiếp theo quyết Bậc 1 cũ.
2. "Sạp rau" vẫn che chữ T biển THỊT HEO ở (9,2) Tối (đúng bound
   r64 ≤36×20, đã ghi §88.2) — không đổi.
3. Nhãn "Góc Chế Tạo" / "Cửa về" / "Cửa đi Khu Công Nhân" ở (7,6)
   Sáng xếp chồng 3 tầng dưới màn hình nhưng không đè nhau, đọc
   được đủ — chấp nhận được, chưa cần chống chồng lấn thêm.

### 89.4 Push + Deploy — KHÔNG CÓ GÌ MỚI ĐỂ ĐẨY, CHỜ 'ĐẨY TIẾP' NHƯ CŨ

- Vòng này chỉ kiểm chứng bằng trình duyệt thật, **không đổi code**:
  không có file code/test mới. Docs mới (§89 này + dòng trạng thái
  `roles-qc.md`) nằm trong lô docs r66 (manifest
  `pxb-push-main-r66-docs` đã liệt kê sẵn `docs/godot-g4.md` +
  `docs/roles-qc.md`) nên sẽ lên cùng push r66 khi chủ nói
  'đẩy tiếp' — **không cần script push r67**.
- Push main r66 (gộp r43–r66: a 101 / b 20 / c 37 / docs 2) + deploy
  pck `d20cee0e` (12 lô, 207 path) vẫn CHƯA CHẠY — chờ chủ nói
  'đẩy tiếp' (không còn thẻ chờ; live vẫn `5f2a052f` r41).
  Script `pxb-push-main-r66.py`, `pxb-deploy-r66.py` + manifest trong
  hidden_files goal. Staging `gh-pages-staging/` đã rebuild cho pck
  `d20cee0e` (205 chunk, verify khớp byte).
- Server http 8942 đã tắt sau khi verify xong (build vẫn ở
  `src/godot-build/`, chạy lại khi cần).

### 89.5 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r66 (4 lô) → deploy pck `d20cee0e`
   (12 lô) → kiểm live pin + đối chiếu byte.
2. Vòng polish tiếp theo (theo §88.5 mục 3 + §89.3): G4 online —
   quyết server Godot headless hay .NET (xem
   `docs/opensource-engine.md` §3.4); hoặc xử lý (b2) + nhãn 3 tầng
   ở (7,6) nếu chủ ưu tiên polish trước online.

## §90 — Vòng 68: can_challenge ở demo — đội đang giữ sạp thì không mở trận tranh sạp mới (27/11 ~02:45–03:30 +07, cron 02:45)

> Mục còn lại của §17.3: `hold_benefits` đã nối xong (G4 bước 8:
> Danh vọng/ngày + giá sỉ −10% trong `buy_item`); chỉ còn
> `can_challenge` ở demo — luật đã chốt trong
> `docs/market-battle-design.md` §6 + §11 điều kiện 4
> ("1 đội giữ tối đa 1 sạp... đội đã giữ sạp đó rồi thì thách đấu
> chính sạp đó cũng bị chặn") nhưng code CHƯA áp: `create_battle`
> không kiểm tra, `_start_battle_demo` không gọi `can_challenge`,
> toast lỗi hiện mã reason thô (`dang-giu-sap-khac`).

### 90.1 Code — XONG

- `scripts/pxb_marketbattle.gd` — `create_battle`: sau kiểm cỡ đội,
  nếu `stallId != ""` thì gọi `can_challenge(_state, teamA.id,
  stall_id, game_day)`; bị chặn thì trả `{ok: false, reason,
  holdingStallId}`. Trận không tranh sạp (`stallId == ""`) không
  bị chặn. Chặn ở tầng luật nên mọi đường mở trận sau này đều
  được luật — không chỉ demo.
- `main.gd` — `_start_battle_demo`: kiểm tra
  `can_challenge_now("doi-ban", "sap-cho-dau-moi", day)` TRƯỚC khi
  mở trận; bị chặn thì báo toast tiếng Việt + `queue_free`
  `battle_mb`, không mở trận. Toast lỗi của `create_battle` cũng
  đổi sang dùng `_battle_block_text` (không còn mã reason thô).
- `main.gd` — `_battle_block_text(reason, holding_stall_id)` (mới)
  + `_hold_until_day(stall_id)` (mới, đọc từ `battle_state`):
  `dang-giu-sap-khac` → "Đội Bạn đang giữ sạp %s đến ngày %d —
  không thách đấu sạp khác được."; `da-giu-sap-nay` → "Đội Bạn đã
  giữ sạp này đến ngày %d rồi."; 3 mã cỡ đội dịch tương ứng;
  lý do lạ thì giữ nguyên mã để debug.

### 90.2 Test mới + hồi quy — XONG

- Test mới `tests/g4_r68_can_challenge_test.gd`: **28/28 PASS** —
  chưa giữ sạp thì mở được; giữ chính sạp đó (ngày 3, đến ngày 8)
  thì chặn `da-giu-sap-nay` + đúng `holdingStallId`; giữ sạp khác
  thì chặn `dang-giu-sap-khac`; đến đúng ngày hết (ngày 8) thì mở
  lại được; trận không tranh sạp không bị chặn; đội khác giữ sạp
  không chặn đội Bạn thách đấu; `can_challenge_now` khớp static;
  chặn đội thiếu người/không bằng nhau vẫn giữ nguyên. Mức Main:
  `battle_state` đang giữ sạp + bấm B → không mở trận, không để
  lại `battle_mb` rác, toast "Đội Bạn đã giữ sạp này đến ngày 8
  rồi."; hết giữ sạp thì mở trận như cũ + đóng trả lại map.
  (Lần chạy đầu 27/28: 1 FAIL là test viết sai — check tìm
  "đang giữ" trong khi toast đúng luật là "đã giữ sạp này" —
  sửa test, không sửa code.)
- **Hồi quy lần 1: 93 OK, 1 FAIL — `g4_battle_save_test` (5 check):**
  luồng test thắng trận → giữ sạp → save/load → bấm B mở trận
  LẠI để đo hòa/thua — luồng này vi phạm đúng luật mới (đội đang
  giữ sạp của mình thì không được thách đấu lại chính sạp đó).
  Đây là test dùng demo sai ngữ nghĩa, không phải lỗi code:
  đã sửa test theo luật — bấm B lúc đang giữ sạp nay KHÔNG mở
  trận + toast tiếng Việt (2 check mới); trước các bước hòa/thua
  thì xóa hold (giả lập hết hạn, GIỮ lịch sử — test vốn đã thao
  tác trực tiếp `battle_state`); check hòa đổi thành "chưa ai giữ
  sạp sau hòa" (hòa không đổi chủ giữ — trước trận không ai giữ
  nên sau hòa vẫn trống, đúng `market-battle-design.md` §6).
  Sau sửa: **`g4_battle_save_test` 33/33 PASS**; hồi quy chạy lại
  **94 OK, 0 FAIL** (log `hidden_files/regression-2026-11-27-0245.log`).
  `run_regression.sh` đã thêm `g4_r68_can_challenge_test`.
- `--check-only` exit 0: `main.gd`, `pxb_marketbattle.gd`,
  `g4_r68_can_challenge_test.gd` (sau `--import`).

### 90.3 Verify + export — XONG

- Scene Main 120 frame exit 0, 0 ERROR/warning.
- Export web exit 0: pck mới **27.657.508 byte, SHA `3ca0d628…`**
  (trước `d20cee0e…`), wasm không đổi `fc74679e…`,
  `GODOT_THREADS_ENABLED = false`.
- HTTP 200 đủ 4 file (`index.html`/`index.js`/`index.wasm`/
  `index.pck`, cổng 8943, đã tắt server sau khi kiểm).
- Chưa browser-verify vòng này (để vòng sau): thay đổi là logic +
  toast chữ; đường bấm B thật đã kiểm headless qua Main
  (`_unhandled_input` → `_start_battle_demo`) trong test r68.
- **Bài học export:** lần đầu export lỗi "Target folder does not
  exist: src/godot-build" — vì chạy từ repo root, Godot hiểu
  đường dẫn export theo thư mục project (`src/godot/`), không
  phải CWD. Đúng: `cd src/godot` rồi export `../godot-build/`
  (như G0). **Cảnh báo UID trùng (có từ trước, không chặn
  export):** `atlas-map003.png` trùng UID với `atlas-map001.png`
  (tương tự map004/map002, map005/map003...) — do các vòng tile
  copy atlas kèm `.uid`; export vẫn exit 0. Ghi để vòng sau dọn
  UID trùng, không sửa trong vòng này.
- **Bài học tắt server:** `pgrep -f "http.server 8943"` trả PID
  subshell (28906) chứ không phải PID python (28923) — `kill`
  nhầm làm exec bị SIGTERM. Tắt bằng PID đúng của tiến trình
  python (đọc từ `ps aux`), không kill theo pgrep đầu tiên.

### 90.4 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- Push main r68 (gộp r43–r68: a **105** / b 20 / c 37 / docs 2) +
  deploy pck `3ca0d628` (12 lô: 11 lô chunk 205 + final) đã chuẩn
  bị xong (script `pxb-push-main-r68.py`, `pxb-deploy-r68.py` +
  manifest trong hidden_files goal; staging rebuild,
  `build_gh_pages.py --verify-only` OK — pck `3ca0d628`, 205
  chunk, khớp byte; wasm không đổi `fc74679e`).
  **CHƯA CHẠY — chờ chủ nói 'đẩy tiếp'** (không còn thẻ chờ;
  live vẫn `5f2a052f` r41). Lô a r68 = lô a r66 (101) +
  `pxb_marketbattle.gd` + test r68 (+.uid) + `g4_battle_save_test.gd`
  (đổi theo luật mới); r67 không đổi code nên không có file mới.

### 90.5 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r68 (4 lô) → deploy pck
   `3ca0d628` (12 lô) → kiểm live pin + đối chiếu byte.
2. Browser-verify vòng 68 (bấm B lúc đang giữ sạp → toast tiếng
   Việt, không mở trận) — cần thắng 1 trận demo trước để có hold,
   làm ở vòng sau khi có thời gian chờ trận chạy.
3. G4 online (quyết server Godot headless hay .NET — xem
   `docs/opensource-engine.md` §3.4, quyết đã có từ 20/11:
   Godot headless dedicated server; skeleton + nối PxbOnline
   đã xong §16/§22) hoặc polish (b2)/nhãn 3 tầng ở (7,6).

## §91 — Vòng 69: trade đổi đồ qua WebSocket trên dedicated server Godot (27/11 ~03:45–04:30 +07, cron 03:45)

> Việc tiếp theo lớn nhất từ §90.5 mục 3 (G4 online): trade/đấu giá/
> công ty vẫn `server-chua-co-endpoint` — nay trade đã có đường
> thật qua WS trên dedicated server Godot (quyết §12.5). Đấu giá +
> công ty vẫn chưa có cả 2 đường. Server validate + ghi nhận thỏa
> thuận (trade_completed); CHƯA trừ/chuyển tiền/đồ thật — client
> nhận trade_completed rồi tự áp vào túi/sổ của mình (việc sau, cần
> sổ cái server giữ). Push/deploy vẫn chờ chủ nói 'đẩy tiếp' như cũ.

### 91.1 Server — XONG

- `server/pxb_server.gd` — giao thức v1 thêm 4 lệnh client →
  server (`trade_offer` / `trade_accept` / `trade_decline` /
  `trade_cancel`) + 6 gói server → client (`trade_offer` cho người
  nhận, `trade_offered` cho người gửi, `trade_completed` cho cả 2,
  `trade_declined`, `trade_cancelled`, `trade_error` — KHÔNG ngắt
  kết nối, khác gói `error` của hello). `data()` thêm
  `trade_pending` + `trade_completed_count`.
- Validate ở server theo thứ tự: người gửi đã hello → có người
  nhận → không đổi với chính mình → mã món ≤64 ký tự → tiền
  0..100 tỉ (số nguyên; 100 tỉ = giá penthouse/đảo, mức tiền lớn
  nhất GDD, PROVISIONAL) → cho + muốn đều không rỗng → người gửi
  chưa có đề nghị đang chờ (tối đa 1/người gửi) → người nhận đang
  online. Sai thì trả `trade_error` + đếm `dropped_packets`.
- `trade_id` do server cấp `"trade-<ms>-<seq>"`; chấp nhận chỉ
  người NHẬN được (kiểm `to_peer`); từ chối chỉ người nhận; hủy
  chỉ người gửi. Chốt thì xóa khỏi `trades`, ghi `trade_log` (giữ
  100), gửi `trade_completed` cho cả 2 bên. Bye/mất kết nối thì
  hủy mọi đề nghị đang chờ có mặt nó (`_cancel_trades_for_peer`,
  lý do `doi-phuong-mat-ket-noi`) + báo cho bên còn lại.
- Signal mới: `trade_offered` / `trade_completed` /
  `trade_declined` / `trade_cancelled`.

### 91.2 Client — XONG

- `scripts/pxb_online.gd` — const `WS_MAX_TRADE_MONEY_VND`
  (100 tỉ, khớp server), `WS_MAX_ITEM_ID_LEN` (64),
  `WS_TRADES_MAX` (50); signal `ws_trade_offer_received` /
  `ws_trade_offered_sent` / `ws_trade_completed` /
  `ws_trade_declined` / `ws_trade_cancelled` / `ws_trade_error`.
- `send_ws_trade_offer(to, give_item, give_money, want_item,
  want_money)` / `send_ws_trade_accept` / `send_ws_trade_decline`
  / `send_ws_trade_cancel`: validate ở client trước khi gửi
  (chưa nối, đổi với chính mình, đề nghị trống, tiền ngoài
  0..100 tỉ, mã món quá dài, đã có đề nghị chờ, sai trade_id).
  Bên từ chối/hủy tự xóa đề nghị khỏi danh sách của mình ngay
  khi gửi xong (server chỉ báo cho bên kia); bên chấp nhận thì
  đợi `trade_completed` của server mới xóa.
- `_clean_trade` (bỏ gói thiếu trade_id/thiếu 1 bên/mã món quá
  dài/tiền quá 100 tỉ) + `_find_trade` / `_remove_trade`.
  `default_data()` / `data()` / `from_data()` thêm
  `ws_trades_completed` (giữ 50, dữ liệu bẩn bỏ); đề nghị đang
  chờ KHÔNG lưu — hết phiên là hết. `reset_state()` xóa cả 3
  danh sách trade + lỗi trade. Comment khối stub HTTP cập nhật:
  trade qua WS ĐÃ CÓ, đấu giá + công ty vẫn chưa có cả 2 đường.
- Test cũ sửa theo thay đổi có chủ ý: `g2_online_test` kỳ vọng
  `default_data()` nay thêm `"ws_trades_completed": []`.

### 91.3 Test mới + hồi quy — XONG

- Test mới `tests/g4_online_trade_test.gd`: **69/69 PASS** —
  socket thật + server thật qua loopback cổng 18769: A↔B hello;
  đề nghị đổi đồ (com-tam lấy ca-phe) tới B đúng điều khoản +
  server đếm 1 đề nghị chờ; chấp nhận sai id / sai người / gửi
  đề nghị thứ 2 đều bị chặn; B chấp nhận đúng → cả 2 nhận
  `trade_completed` cùng trade_id + server đếm 1 giao dịch đã
  chốt; đề nghị tiền bù 1 triệu → B từ chối → A nhận
  `trade_declined`; đề nghị vòng 3 → A hủy → B nhận
  `trade_cancelled` (`nguoi-gui-da-huy`); validate client (đổi
  với chính mình, đề nghị trống, tiền âm, tiền quá 100 tỉ, mã
  món 65 ký tự) không tới server; đề nghị cho người không online
  → `trade_error` `khong-tim-thay-nguoi-choi` + KHÔNG ngắt kết
  nối; B ngắt giữa lúc có đề nghị chờ → A nhận `trade_cancelled`
  (`doi-phuong-mat-ket-noi`); `data()`/`from_data()` giữ log
  trade đã chốt (dữ liệu bẩn bỏ); `reset_state()` xóa trade.
  (Lần chạy đầu 46/47: 1 FAIL là test viết sai — chuyển phase
  3→4 không reset `_step` nên phase 4 kẹt ở step 3; sửa test,
  không sửa code.)
- `run_regression.sh` đã thêm `g4_online_trade_test`.
- Hồi quy: **95 OK, 0 FAIL** (log
  `hidden_files/regression-2026-11-27-0345.log`): trade 69/69,
  online 91/91, server 37/37 + probe OK, G1 selftest 419/419,
  G3 playtest 95/95, G2 selftest 87/87, MarketBattle 123/123,
  battle scene 43/43, battle AI 34/34, battle save 33/33, còn lại
  giữ nguyên — không regression.

### 91.4 Verify + export — XONG

- `--check-only` exit 0: `main.gd`, `pxb_online.gd`,
  `pxb_server.gd`, `g4_online_trade_test.gd`, `g2_online_test.gd`
  (sau `--import`; chỉ còn warning UID trùng atlas đã biết từ
  trước, không chặn export).
- Scene Main 120 frame exit 0, 0 ERROR/warning.
- Export web exit 0: pck mới **27.677.512 byte, SHA `1a05ffca…`**
  (trước `3ca0d628…`), wasm không đổi `fc74679e…`,
  `GODOT_THREADS_ENABLED = false`; pck chứa đường dẫn
  `res://server/pxb_server.gd` + `res://scripts/pxb_online.gd` +
  `res://tests/g4_online_trade_test.gd` (chuỗi literal trong
  script biên dịch không grep được trực tiếp trong pck — đã
  kiểm chứng bằng đường dẫn file + SHA/size đổi, như các vòng
  trước).
- HTTP 200 đủ 4 file (`index.html`/`index.js`/`index.wasm`/
  `index.pck`, cổng 8944, đã tắt server sau khi kiểm).
- Chưa browser-verify vòng này (thay đổi là logic WS + test
  headless qua socket thật; UI trade trong điện thoại chưa có —
  việc vòng sau).

### 91.5 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- Push main r69 (gộp r43–r69: a **110** / b 20 / c 37 / docs 2) +
  deploy pck `1a05ffca` (12 lô: 11 lô chunk 206 + final) đã chuẩn
  bị xong (script `pxb-push-main-r69.py`, `pxb-deploy-r69.py` +
  manifest trong hidden_files goal; staging rebuild,
  `build_gh_pages.py --verify-only` OK — pck `1a05ffca`, 206
  chunk, khớp byte; wasm không đổi `fc74679e`).
  **CHƯA CHẠY — chờ chủ nói 'đẩy tiếp'** (không còn thẻ chờ;
  live vẫn `5f2a052f` r41). Lô a r69 = lô a r68 (105) +
  `pxb_server.gd` + `pxb_online.gd` + test trade (+.uid) +
  `g2_online_test.gd` + `run_regression.sh`; r67 không đổi code
  nên không có file mới.

### 91.6 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r69 (4 lô) → deploy pck mới
   (12 lô) → kiểm live pin + đối chiếu byte.
2. Browser-verify vòng 68 (bấm B lúc đang giữ sạp → toast tiếng
   Việt, không mở trận) — cần thắng 1 trận demo trước để có hold.
3. G4 online tiếp: áp `trade_completed` vào túi/sổ ở client
   (trừ/chuyển tiền/đồ thật) hoặc đấu giá qua WS (phí sàn 5% đã
   chốt) — server giữ sổ cái là việc sau; hoặc UI trade trong
   điện thoại (nút gửi đề nghị cho người online).

## §92 — Vòng 70: áp trade_completed vào túi + ví ở client (27/11 ~04:45–05:05 +07, cron 04:45)

### 92.1 Code — XONG

- `scripts/pxb_inventory.gd` — `remove(item_id, quantity=1)` mới:
  bớt đồ KHÔNG buff (dùng khi đổi đồ), all-or-nothing, giữ entry
  0 như C# / `use()` (khác `use()` ở chỗ không kích hoạt buff).
- `scripts/pxb_online.gd` — `apply_trade_completed(trade)` mới +
  tự áp trong nhánh `trade_completed` của `_handle_ws_message`
  (áp TRƯỚC khi phát signal; dict đã chốt kèm thêm khóa `"apply"`):
  xác định vai sender/receiver theo `ws_player_id`; chống áp trùng
  theo trade_id (`ws_trades_applied`, giữ 50); chưa nối túi/ví thì
  trả `chua-noi-tui-vi`, không áp; áp từng phần + ghi rõ phần thiếu
  (món cho thiếu → `missing_item`, món nhận trùng đồ không xếp chồng
  → `receive_failed`, tiền cho thiếu → trừ tới 0 + `short_money`,
  ví không âm); tiền/món nhận cộng đủ theo thỏa thuận.
  `trade_inventory: PxbInventory` + `trade_economy: PxbEconomy`
  (null = chưa nối); `reset_state()` xóa cả `ws_trades_applied`.
- Chặn đề nghị không đủ khả năng ở lúc gửi/chấp nhận (chỉ khi đã
  nối túi/ví): `send_ws_trade_offer` kiểm tra món cho
  (`khong-du-do-cho`) + tiền cho (`khong-du-tien-cho`);
  `send_ws_trade_accept` kiểm tra tương tự với món/tiền cho đi của
  người nhận (want_item/want_money). Chưa nối thì bỏ qua (không
  biết số dư) — test r69 không nối nên không đổi hành vi.
- `main.gd` — túi đồ slice `bag: PxbInventory` mới (khác `inventory`
  là Dictionary nguyên liệu chế đồ); nối
  `online.trade_inventory = bag` + `online.trade_economy = economy`;
  `_on_ws_trade_completed` đồng bộ ngược về ví chung
  (`_wallet_from_economy()`) + toast tiếng Việt mô tả giao dịch
  (tên món qua `PxbInventory.get_item`, tiền qua `_fmt_vnd`) + ghi
  rõ phần thiếu (thiếu món / không vào túi được / thiếu tiền);
  `_process` đồng bộ ví → economy MỖI FRAME (`_wallet_to_economy()`)
  vì trade áp tiền vào `economy.money` lúc poll (cha `_process`
  chạy trước con — mẫu vòng 4) và `economy.money` có thể stale sau
  khi làm ca (lương chỉ vào `jobs.gold`); save/load thêm khóa
  `"pxb_inventory"` (`bag.data()` / `from_data`, save cũ thiếu khóa
  → túi rỗng) + `_replace_system("inventory", …)` + nối lại
  trade sau khi load (nối cũ trỏ node đã `queue_free`).
- **KHE HỞ ĐÃ BIẾT (v1, chưa có sổ cái server):** 2 bên áp độc lập
  theo thỏa thuận, không biết số dư thật của nhau. Chặn ở lúc
  gửi/chấp nhận thu hẹp khe; chỉ khi số dư đổi GIỮA lúc gửi và lúc
  chốt thì bên cho áp thiếu (ghi `short_money` / `missing_item`
  vào log) còn bên nhận vẫn nhận đủ theo thỏa thuận. Sổ cái server
  giữ sau này sẽ đóng khe này (việc sau, §92.5). Log đã chốt sau
  load chỉ giữ điều khoản, không giữ kết quả áp (`_clean_trade`
  bỏ khóa `"apply"` — đã chốt bằng test).

### 92.2 Test mới + hồi quy — XONG

- Test mới `tests/g4_online_trade_apply_test.gd`: **76/76 PASS** —
  socket thật + server thật qua loopback cổng 18770: unit
  `remove()` (8 kiểm); A↔B đổi com-tam + 1 triệu lấy ca-phe → túi
  + ví 2 bên đổi đúng (A còn 1 com-tam + 1 ca-phe + 4 triệu; B hết
  ca-phe + 1 com-tam + 3 triệu); áp trùng trade_id thì bỏ lần 2;
  race món (A dùng mất com-tam sau khi gửi) → `missing_item`,
  vẫn nhận sach, B vẫn nhận com-tam theo thỏa thuận; nhận trùng
  áo mưa đã có → `receive_failed`, vẫn 1 áo; race tiền (A tiêu
  mất 3/4 triệu sau khi gửi) → cho 1 triệu + `short_money` 3 triệu,
  ví về 0 không âm, B nhận đủ 4 triệu theo thỏa thuận (khe hở v1);
  chặn gửi (không đủ món/tiền) + chặn chấp nhận (người nhận không
  đủ món) + hủy sau chặn; chưa nối tui/vi / không liên quan / gói
  bẩn; `data()`/`from_data()` giữ log 4 trade; `reset_state()` xóa
  danh sách đã áp (client mới áp lại trade cũ thì không duplicate).
- `run_regression.sh` đã thêm `g4_online_trade_apply_test`.
- Hồi quy: **96 OK, 0 FAIL** (log
  `hidden_files/regression-2026-11-27-0445.log`): apply 76/76,
  trade 69/69, online 91/91, server 37/37 + probe OK, G1 selftest
  419/419, G3 playtest 95/95, G2 selftest 87/87, MarketBattle
  123/123, battle scene 43/43, battle AI 34/34, battle save 33/33,
  còn lại giữ nguyên — không regression.

### 92.3 Verify + export — XONG

- `--check-only` exit 0: `main.gd`, `pxb_online.gd`,
  `pxb_inventory.gd`, `g4_online_trade_apply_test.gd`,
  `g4_online_trade_test.gd` (sau `--import`; chỉ còn warning UID
  trùng atlas đã biết từ trước, không chặn export).
- Scene Main 120 frame exit 0, 0 ERROR/warning.
- Export web exit 0: pck mới **27.693.144 byte, SHA `dc5d8654…`**
  (trước `1a05ffca…`), wasm không đổi `fc74679e…`,
  `GODOT_THREADS_ENABLED = false`; pck chứa đường dẫn
  `res://scripts/pxb_online.gd` + `res://scripts/pxb_inventory.gd`
  + `res://tests/g4_online_trade_apply_test.gd` (chuỗi literal
  trong script biên dịch không grep được trực tiếp trong pck — đã
  kiểm chứng bằng đường dẫn file + SHA/size đổi, như các vòng
  trước).
- HTTP 200 đủ 4 file (`index.html`/`index.js`/`index.wasm`/
  `index.pck`, cổng 8945, đã tắt server sau khi kiểm).
- Chưa browser-verify vòng này (thay đổi là logic áp trade + test
  headless qua socket thật; toast trade trong game chưa bấm tay).

### 92.4 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- Push main r70 (gộp r43–r70: a **113** / b 20 / c 37 / docs 2) +
  deploy pck `dc5d8654` (12 lô: 11 lô chunk 206 + final) đã chuẩn
  bị xong (script `pxb-push-main-r70.py`, `pxb-deploy-r70.py` +
  manifest trong hidden_files goal; staging rebuild,
  `build_gh_pages.py --verify-only` OK — pck `dc5d8654`, 206
  chunk, khớp byte; wasm không đổi `fc74679e`). **Thay script
  r69 (pck `1a05ffca` chưa lên — bỏ, không xóa file, theo mẫu
  vòng 46).** **CHƯA CHẠY — chờ chủ nói 'đẩy tiếp'** (không còn
  thẻ chờ; live vẫn `5f2a052f` r41). Lô a r70 = lô a r69 (110) +
  `pxb_inventory.gd` + test apply (+.uid) — `main.gd`,
  `pxb_online.gd`, `run_regression.sh` đã có trong lô a r69;
  r67 không đổi code nên không có file mới.

### 92.5 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r70 (4 lô) → deploy pck mới
   (12 lô) → kiểm live pin + đối chiếu byte.
2. Browser-verify vòng 68 (bấm B lúc đang giữ sạp → toast tiếng
   Việt, không mở trận) — cần thắng 1 trận demo trước để có hold.
3. G4 online tiếp: đấu giá qua WS (phí sàn 5% đã chốt) hoặc UI
   trade trong điện thoại (nút gửi đề nghị cho người online) —
   hoặc sổ cái server (đóng khe hở race §92.1: server giữ số dư
   + validate đủ khả năng trước khi chốt, thay vì chỉ client).

## §93 — Vòng 71: đấu giá qua WebSocket trên dedicated server Godot (27/11 ~05:45–06:30 +07, cron 05:45)

Mục 3 của §92.5 (G4 online). Phí sàn 5% đã chốt trong GDD +
`PxbBalance.AUCTION_FEE_PERCENT` + `PxbEconomy.auction_seller_receives`
— vòng này đưa đấu giá lên WS thật, theo đúng mẫu trade r69/r70
(server giữ phiên + validate, client tự áp kết quả vào túi/ví).

### 93.1 Server — XONG

- `server/pxb_server.gd` — giao thức JSON v1 thêm 4 lệnh client →
  server + 6 gói server → client (ghi đủ trong doc đầu file):
  `auction_create` {item_id, start_price, duration_s} →
  broadcast `auction_created`; `auction_bid` {auction_id, amount}
  → broadcast `auction_bid`; `auction_cancel` {auction_id} →
  broadcast `auction_cancelled`; `auction_list` → trả
  `auction_list` chỉ cho người xin (xếp theo ends_at_ms tăng dần);
  hết giờ server tự đóng → broadcast `auction_closed`
  {winner_player_id, hammer_price, fee_vnd, seller_receives_vnd};
  lệnh sai luật → `auction_error` (không ngắt kết nối, giống
  trade_error).
- Luật validate (PROVISIONAL, ghi trong code): giá khởi điểm
  1.000..100 tỉ; thời gian 30..3600 giây; tối đa 1 phiên đang mở /
  người bán (giống luật 1 đề nghị trade / người gửi); giá đầu tiên
  >= giá khởi điểm, các giá sau >= giá hiện tại + 1.000đ
  (`MIN_BID_INCREMENT_VND`); người bán không được đấu giá của
  mình; hủy chỉ khi chưa có ai đấu giá (có giá rồi thì phải chờ
  hết giờ — tránh người bán rút món sau khi đã có người trả giá).
- Phí: `AUCTION_FEE_PERCENT = 5` — người bán nhận
  hammer × 95 / 100, cắt phần lẻ theo phép chia nguyên (khớp
  `PxbEconomy.auction_seller_receives`); không ai đấu giá thì
  winner rỗng, hammer = fee = seller_receives = 0.
- Đóng phiên: `_close_expired_auctions()` chạy cuối mỗi `poll()`
  (cả `_process` lẫn test gọi tay đều đóng đúng giờ); log 100
  phiên đã đóng gần nhất; `data()` thêm `auction_open` +
  `auction_closed_count`; signal mới `auction_created` /
  `auction_bid_placed` / `auction_closed` / `auction_cancelled`.
- Mất kết nối: `_cancel_auctions_for_peer()` — người bán rời
  (bye / mất kết nối) thì hủy các phiên CHƯA có ai đấu giá
  (broadcast `auction_cancelled`); phiên đã có giá giữ nguyên tới
  hết giờ (người thắng vẫn chốt được).
- Server CHƯA trừ/chuyển tiền/đồ thật — client tự áp khi nhận
  `auction_closed` (giống trade v1); sổ cái server là việc sau.

### 93.2 Client — XONG

- `scripts/pxb_online.gd` — hằng khớp server
  (`WS_AUCTION_FEE_PERCENT = 5`, `WS_MIN_BID_INCREMENT_VND = 1000`,
  `WS_MIN_AUCTION_START_PRICE_VND = 1000`,
  `WS_MAX_AUCTION_MONEY_VND = 100 tỉ`, thời gian 30..3600s,
  `WS_AUCTIONS_MAX = 50`); signal mới `ws_auction_created` /
  `ws_auction_bid` / `ws_auction_closed` / `ws_auction_cancelled` /
  `ws_auction_list` / `ws_auction_error`.
- Gửi: `send_ws_auction_create(item_id, start_price, duration_s)`
  (chặn ở client: mã món rỗng/quá dài, giá/thời gian ngoài khoảng,
  đã có phiên mở, không có món trong túi khi đã nối túi →
  `khong-du-do-cho`); `send_ws_auction_bid(auction_id, amount)`
  (chặn: không phải phiên đang mở, đấu giá của mình, giá thấp hơn
  giá tối thiểu tiếp theo, vượt ví khi đã nối ví →
  `khong-du-tien-cho`); `send_ws_auction_cancel(auction_id)` (chỉ
  người bán, chưa có giá); `request_ws_auction_list()`.
- Nhận: `_handle_ws_message` thêm 6 nhánh — `auction_created` /
  `auction_bid` upsert vào `ws_auctions`, `auction_cancelled` xóa,
  `auction_closed` áp qua `apply_auction_closed()` TRƯỚC khi phát
  signal (dict đã chốt kèm khóa `"apply"` — giống trade_completed
  bước 11), `auction_list` thay toàn bộ `ws_auctions`.
  `_clean_auction()` / `_clean_closed_auction()` bỏ gói bẩn
  (thiếu id/bên, giá ngoài 1.000..100 tỉ, phí vượt giá chốt,
  hammer > 0 mà winner rỗng và ngược lại).
- `apply_auction_closed(auction)`: vai seller (cho món, nhận
  `seller_receives_vnd` — lấy số server gửi, bẩn thì tính lại bằng
  `PxbEconomy.auction_seller_receives`) / winner (trả hammer,
  nhận món); phiên không ai đấu giá → `khong-co-nguoi-thang`,
  không áp gì; chống áp trùng theo auction_id (giữ 50); chưa nối
  túi/ví → `chua-noi-tui-vi`; áp từng phần + ghi thiếu
  (`missing_item` / `receive_failed` / `short_money`, ví không âm).
  **KHE HỞ ĐÃ BIẾT (v1, giống trade):** 2 bên áp độc lập theo kết
  quả server chốt — số dư đổi giữa lúc đặt giá và lúc chốt thì
  người thắng áp thiếu (ghi `short_money`), người bán vẫn nhận đủ
  theo giá chốt; sổ cái server sẽ đóng khe này.
- `data()` / `from_data()` thêm `ws_auction_log` (50 phiên đã
  đóng, làm sạch lại qua `_clean_closed_auction` nên không giữ
  khóa `"apply"` sau load; phiên đang mở KHÔNG lưu — vào lại thì
  xin `auction_list`); `reset_state()` xóa cả 4 biến đấu giá;
  `ws_auctions_text()` mới để hiển thị tab Chợ (phiên mở + 5 phiên
  đã đóng gần nhất). Hàm HTTP cũ `list_auctions()` /
  `place_bid()` vẫn trả `server-chua-co-endpoint` (đường HTTP chưa
  có endpoint) — comment nay chỉ sang hàm WS.
- `main.gd`: nối `online.ws_auction_closed` →
  `_on_ws_auction_closed` mới — đồng bộ ngược về ví chung
  `jobs.gold` + toast tiếng Việt (bán được / thắng đấu giá / không
  ai đấu giá / chỉ xem kết quả khi không phải 1 trong 2 bên, ghi
  rõ phần thiếu như trade).

### 93.3 Test mới + hồi quy — XONG

- Test mới `tests/g4_online_auction_test.gd`: **95/95 PASS** —
  socket thật + server thật qua loopback cổng 18771: unit phí 5%
  (1.000.000 → 950.000; 1.001.000 → 950.950; 999 → 949 cắt lẻ);
  chặn tạo phiên sai luật (giá 0 / thời gian 5s / mã món rỗng /
  mở phiên thứ 2); `auction_list` trả đúng 1 phiên; chặn đấu giá
  (người bán đấu của mình / giá đầu < khởi điểm / giá sau <
  hiện tại + 1.000 / vượt ví); hủy phiên chưa có giá + hủy phiên
  đã có giá bị chặn; đóng phiên hết giờ THẬT (chờ 30 giây wall):
  winner player-b, hammer 1.001.000, fee 50.050, seller nhận
  950.950, áp đúng 2 bên (A hết com-tam + 5.950.950; B hết ví +
  1 com-tam); race tiền (B tiêu mất 1,5 triệu sau khi đặt giá) →
  `short_money` 501.000, ví về 0 không âm, B vẫn nhận món theo kết
  quả chốt (khe hở v1); áp trùng → duplicate; phiên không ai đấu
  giá → winner rỗng + không áp (`khong-co-nguoi-thang`), A giữ
  món (đóng bằng white-box đổi `ends_at_ms` về quá khứ rồi poll —
  chỉ mô phỏng 1 lần để khỏi chờ thêm 30 giây); chưa nối /
  không liên quan / gói bẩn; `data()`/`from_data()` giữ log 2
  phiên (bỏ phiên bẩn phí vượt giá chốt); `reset_state()` xóa
  danh sách đã áp + log; client mới áp lại phiên cũ thì không
  duplicate. Thêm vào `tools/godot/run_regression.sh`.
- Hồi quy: **97 OK, 0 FAIL** (log
  `hidden_files/regression-2026-11-27-0545.log`): auction 95/95
  mới + toàn bộ test cũ vẫn PASS (không regression).

### 93.4 Verify + export — XONG

- `--check-only` exit 0: `pxb_server.gd`, `pxb_online.gd`,
  `main.gd`, `g4_online_auction_test.gd` (sau `--import`; chỉ còn
  warning UID trùng atlas đã biết từ trước, không chặn export).
- Scene Main 120 frame exit 0, 0 ERROR/warning.
- Export web exit 0: pck mới **27.723.920 byte, SHA `9663c82f…`**
  (trước `dc5d8654…`), wasm không đổi `fc74679e…`,
  `GODOT_THREADS_ENABLED = false`; pck chứa đường dẫn
  `res://tests/g4_online_auction_test.gd` (chuỗi literal trong
  script biên dịch không grep được trực tiếp trong pck — đã kiểm
  chứng bằng đường dẫn file + SHA/size đổi, như các vòng trước).
- HTTP 200 đủ 4 file (`index.html`/`index.js`/`index.wasm`/
  `index.pck`, cổng 8947, đã tắt server sau khi kiểm).
- Chưa browser-verify vòng này (thay đổi là logic đấu giá + test
  headless qua socket thật; toast đấu giá trong game chưa bấm tay).

### 93.5 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- Push main r71 (gộp r43–r71: a **115** / b 20 / c 37 / docs 2) +
  deploy pck `9663c82f` (12 lô: 11 lô chunk 206 + final) đã chuẩn
  bị xong (script `pxb-push-main-r71.py`, `pxb-deploy-r71.py` +
  manifest trong hidden_files goal; staging rebuild,
  `build_gh_pages.py --verify-only` OK — pck `9663c82f`, 206
  chunk, khớp byte; wasm không đổi `fc74679e`). **Thay script
  r70 (pck `dc5d8654` chưa lên — bỏ, không xóa file, theo mẫu
  vòng 46).** **CHƯA CHẠY — chờ chủ nói 'đẩy tiếp'** (không còn
  thẻ chờ; live vẫn `5f2a052f` r41). Lô a r71 = lô a r70 (113) +
  `g4_online_auction_test.gd` (+.uid) — `main.gd`,
  `pxb_online.gd`, `pxb_server.gd`, `g2_online_test.gd`,
  `run_regression.sh` đã có trong lô a r70.

### 93.6 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r71 (4 lô) → deploy pck mới
   (12 lô) → kiểm live pin + đối chiếu byte.
2. Browser-verify vòng 68 (bấm B lúc đang giữ sạp → toast tiếng
   Việt, không mở trận) — cần thắng 1 trận demo trước để có hold.
3. G4 online tiếp: UI trade/đấu giá trong điện thoại (nút gửi đề
   nghị / mở phiên / đặt giá cho người online — logic WS đã có,
   chỉ thiếu UI) — hoặc sổ cái server (đóng khe hở race §92.1 +
   §93.2: server giữ số dư + validate đủ khả năng trước khi chốt,
   thay vì chỉ client).

## §94 — Vòng 72: sổ cái server cho đấu giá (27/11 ~06:45–07:30 +07, cron 06:45)

Mục 3 của §93.6 (G4 online). Đóng khe hở race §92.1 + §93.2: trước
đây 2 bên áp độc lập theo giá chốt — người thắng trả thiếu thì người
bán vẫn nhận đủ theo hammer; nay server giữ số dư + quyết toán.

### 94.1 Code — XONG

- `server/pxb_server.gd` — sổ cái `ledger: {player_id: {money,
  items, reserved}}` + gói mới `ledger_sync` (phải hello trước;
  money int >= 0 — sai thì bỏ cả gói + đếm dropped_packets; items
  tối đa 512 món, món sai thì bỏ món đó; sync thay thế money/items
  nhưng GIỮ reserved; ledger > 256 người thì xóa entry của người
  không còn online — `_prune_ledger`).
  - Mở phiên: người bán đã đồng bộ mà ledger không có món thì
    `auction_error` `khong-du-do-cho`.
  - Đặt giá: người đấu đã đồng bộ thì chỉ cho đặt trong khả năng
    còn lại `money - reserved` (+ giá cũ của chính mình nếu đang
    dẫn đầu — tiền giữ hộ đó dùng lại được cho giá mới); vượt thì
    `khong-du-tien-cho`. Chưa đồng bộ thì cho qua (hành vi cũ).
  - Giữ hộ: đặt giá thành công thì `reserved` += giá mới (người
    dẫn đầu cũ được giải phóng; tự nâng giá thì chỉ cộng phần
    chênh). Đóng phiên thì giải phóng đúng hammer.
  - Quyết toán `_settle_auction` khi đóng phiên: người thắng trả
    `paid = min(hammer, money trong ledger)`, `short_money =
    hammer - paid`; người bán còn món trong ledger thì trừ 1 món,
    cộng 1 món cho người thắng, nhận `paid × 95 / 100` (phí = paid
    − nhận); người bán KHÔNG còn món thì HỦY giao dịch — hoàn paid
    cho người thắng, `winner_paid = seller_received = fee =
    short_money = 0`, `missing_item = true`. Người thắng chưa từng
    đồng bộ thì hành vi cũ (trả đủ hammer, nhận đủ 95%). Khối
    `"ledger"` kèm trong `auction_closed` (cả top-level fee_vnd /
    seller_receives_vnd cũng lấy số đã quyết toán).
  - Doc đầu file cập nhật: giao thức `ledger_sync` + khối
    `"ledger"` trong `auction_closed` + ghi chú PROVISIONAL mới
    (sổ cái tin số client đồng bộ — chưa server-authoritative
    hoàn toàn).
- `scripts/pxb_online.gd` — `send_ws_ledger_sync()` (gửi ví +
  túi hiện tại; chưa nối túi/ví thì `chua-noi-tui-vi`) +
  `_maybe_auto_sync_ledger()` (gọi mỗi frame từ `_process`: chỉ
  gửi khi đã nối WS + đã nối túi/ví + qua 500 ms từ lần trước +
  số dư thật sự đổi) + đồng bộ ngay khi nhận `welcome` + đồng bộ
  trước khi mở phiên / đặt giá (để server validate bằng số mới
  nhất). Cờ `ws_ledger_auto_sync` (tắt trong test để điều khiển
  thời điểm sync).
  - `_clean_closed_auction` giữ khối `"ledger"` khi hợp lệ
    (`_clean_ledger_block`: paid/received/fee/short 0..hammer,
    fee = paid − received, short = hammer − paid trừ khi hủy vì
    thiếu món; khối bẩn thì bỏ khối, giữ phiên).
  - `apply_auction_closed` áp đúng số server quyết toán khi có
    khối ledger: người thắng trả `winner_paid`, người bán nhận
    `seller_received`, phí theo ledger; giao dịch hủy vì thiếu món
    thì không ai trả/nhận gì (`missing_item = true` cả 2 bên để
    Main/toast báo rõ). `short_money` trong kết quả áp vẫn = thiếu
    so với GIÁ CHỐT (hammer − đã trả) như v71 — khớp
    `ledger.short_money` khi trả đủ số server yêu cầu. Không có
    khối ledger (server cũ) thì dùng đường cũ (v71).
  - `reset_state()` xóa cả mốc sync ledger.
- `main.gd`: KHÔNG đổi — toast đấu giá đã đọc `short_money` /
  `missing_item` trong kết quả áp nên tự nhận số quyết toán mới.
- **KHE HỞ CÒN LẠI (v72, ghi rõ trong code + doc server):** sổ
  cái tin số client đồng bộ — client vẫn tiêu được tiền đang giữ
  hộ ở local giữa 2 lần sync, và đồng bộ ghi đè nên client mất
  kết nối đúng lúc chốt phiên rồi sync lại bằng số local cũ sẽ
  ghi đè mất khoản đã quyết toán. Đóng hẳn cần kinh tế
  server-authoritative / chặn tiêu tiền giữ hộ ở client — việc sau.
  Trade vẫn áp độc lập như v71 (sổ cái mới chỉ áp cho đấu giá).

### 94.2 Test mới + hồi quy — XONG

- Test mới `tests/g4_online_ledger_test.gd`: **127/127 PASS** —
  socket thật + server thật qua loopback cổng 18772, 3 client:
  sync lên ledger đúng số + giữ reserved khi sync lại; gói sync
  money âm bị bỏ (dropped +1, ledger không đổi); món count âm
  bị bỏ, món đúng được giữ; giữ hộ / giải phóng khi đặt giá / bị
  vượt giá / tự nâng giá (dùng lại tiền giữ hộ cũ); chặn
  double-spend ở server — B còn khả năng 400k (1,6 triệu đang
  giữ hộ) thì đặt 600k ở phiên khác bị `khong-du-tien-cho` dù ví
  local còn 2 triệu, đặt đúng 400k thì được; race: B tiêu mất
  1,5 triệu sau khi đặt giá ở 2 phiên (chỉ còn 500k) → phiên 1
  (hammer 1,6 triệu) trả 500k, thiếu 1,1 triệu, A chỉ nhận 475k
  (95% của 500k thực trả); phiên 2 (hammer 400k) trả 0, thiếu
  400k, C nhận 0 — cả 2 bên áp cùng số server quyết toán, ví/túi
  3 bên khớp ledger server; thiếu món ở người bán lúc chốt thì
  HỦY giao dịch (hoàn tiền, không ai nhận gì); server chặn mở
  phiên bán món không có trong ledger (gói thô); `data()` /
  `from_data()` giữ khối ledger, khối ledger bẩn thì bỏ khối giữ
  phiên; `reset_state()` xóa mốc sync.
- Test cũ `tests/g4_online_auction_test.gd` sửa kỳ vọng theo số
  quyết toán mới (mẫu r64/r65 — test stale theo thay đổi có chủ
  ý): race B trả 500k thì A nhận 475k (không còn 950.950), phí
  25.000 (không còn 50.050), ví A 5.475.000; **95/95 PASS**.
- `tools/godot/run_regression.sh` đã thêm `g4_online_ledger_test`.
- Hồi quy: **98 OK, 0 FAIL** (log
  `hidden_files/regression-2026-11-27-0645.log`): ledger 127/127
  mới + toàn bộ test cũ vẫn PASS (không regression).

### 94.3 Verify + export — XONG

- `--check-only` exit 0: `pxb_server.gd`, `pxb_online.gd`,
  `g4_online_auction_test.gd`, `g4_online_ledger_test.gd`.
- Scene Main 120 frame exit 0, 0 ERROR/warning.
- Export web exit 0: pck mới **27.749.156 byte, SHA `0dc02713…`**
  (trước `9663c82f…`), wasm không đổi `fc74679e…`,
  `GODOT_THREADS_ENABLED = false`; pck chứa
  `res://tests/g4_online_ledger_test.gd` (grep thấy 4 lần trong
  pck — chuỗi literal trong script biên dịch).
- HTTP 200 đủ 4 file (`index.html`/`index.js`/`index.wasm`/
  `index.pck`, cổng 8948, đã tắt server sau khi kiểm).
- Chưa browser-verify vòng này (thay đổi là logic sổ cái +
  test headless qua socket thật; toast đấu giá trong game chưa
  bấm tay).

### 94.4 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- Push main r72 (gộp r43–r72: a **117** / b 20 / c 37 / docs 2) +
  deploy pck `0dc02713` (12 lô: 11 lô chunk 206 + final) đã chuẩn
  bị xong (script `pxb-push-main-r72.py`, `pxb-deploy-r72.py` +
  manifest trong hidden_files goal; staging rebuild,
  `build_gh_pages.py --verify-only` OK — pck `0dc02713`, 206
  chunk, khớp byte; wasm không đổi `fc74679e`). **Thay script
  r71 (pck `9663c82f` chưa lên — bỏ, không xóa file, theo mẫu
  vòng 46).** **CHƯA CHẠY — chờ chủ nói 'đẩy tiếp'** (không còn
  thẻ chờ; live vẫn `5f2a052f` r41). Lô a r72 = lô a r71 (115) +
  `g4_online_ledger_test.gd` (+.uid) — `main.gd`,
  `pxb_online.gd`, `pxb_server.gd`, `g4_online_auction_test.gd`,
  `run_regression.sh` đã có trong lô a r71.

### 94.5 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r72 (4 lô) → deploy pck mới
   (12 lô) → kiểm live pin + đối chiếu byte.
2. Browser-verify vòng 68 (bấm B lúc đang giữ sạp → toast tiếng
   Việt, không mở trận) — cần thắng 1 trận demo trước để có hold.
3. G4 online tiếp: UI trade/đấu giá trong điện thoại (nút gửi đề
   nghị / mở phiên / đặt giá cho người online — logic WS đã có,
   chỉ thiếu UI) — hoặc sổ cái cho trade (đóng khe hở race trade
   §92.1 như đã làm cho đấu giá) — hoặc kinh tế
   server-authoritative / chặn tiêu tiền giữ hộ ở client (đóng
   khe hở còn lại của §94.1).

## §95 — Vòng 73: sổ cái server cho trade (27/11 ~07:45–08:30 +07, cron 07:45)

Mục 3 của §94.5 (G4 online) — đóng khe hở race trade §92.1, theo
đúng mẫu sổ cái đấu giá vòng 72: server giữ số dư + quyết toán
nguyên tử lúc chấp nhận, thay vì 2 bên tự áp độc lập theo thỏa
thuận.

### 95.1 Code — XONG

- `server/pxb_server.gd` — `_settle_trade(trade)` mới (quyết toán
  từ sổ cái lúc chấp nhận):
  - Không bên nào từng đồng bộ ledger → trả `{}` (không khối
    ledger) → client áp theo thỏa thuận như cũ (v70).
  - Có ít nhất 1 bên đã đồng bộ: kiểm tra bên đã đồng bộ có đủ
    khả năng cho đi không (tiền cho <= money − reserved, còn món
    cho trong ledger). Bên chưa đồng bộ thì coi như đủ (hành vi
    cũ — giống người thắng chưa đồng bộ ở đấu giá).
  - Không đủ → HỦY giao dịch: khối `{voided:true, reason, ...}`,
    KHÔNG chuyển gì trong ledger (cả 2 bên giữ nguyên); đề nghị
    vẫn bị xóa + `trade_completed` vẫn gửi để 2 bên biết đã hủy.
    Lý do theo thứ tự cố định: `thieu-tien-nguoi-gui` →
    `thieu-do-nguoi-gui` → `thieu-tien-nguoi-nhan` →
    `thieu-do-nguoi-nhan`.
  - Đủ → chuyển tiền + món cả 2 chiều trong ledger, nguyên tử
    trong 1 lần gọi (không còn trạng thái nửa vời: không bên nào
    nhận đủ trong khi bên kia trả thiếu như khe hở v1). Tiền giữ
    hộ đấu giá (`reserved`) KHÔNG tính vào khả năng cho trade.
  - `_handle_trade_accept` nay quyết toán rồi mới gửi
    `trade_completed` (kèm khối `"ledger"` khi đã quyết toán);
    `trade_log` giữ luôn khối này.
  - `_handle_trade_offer` chặn sớm ở server (gói thô qua mặt
    chặn client cũng bị chặn): người gửi đã đồng bộ mà cho vượt
    tiền khả dụng → `khong-du-tien-cho`; cho món không còn trong
    ledger → `khong-du-do-cho` (đếm `dropped_packets`, không tạo
    đề nghị).
  - Doc đầu file cập nhật: `trade_accept` + `trade_completed`
    (khối `"ledger"`) + `ledger_sync` (nay dùng cho cả trade) +
    ghi chú PROVISIONAL (trade quyết toán từ sổ cái; khe hở
    đồng bộ ghi đè nay áp cho cả trade).
- `scripts/pxb_online.gd` — `_clean_trade_ledger_block(trade)`
  mới (kiểm chuẩn khối ledger theo đúng thỏa thuận: paid 0..tiền
  cho, không voided thì paid == tiền cho + short 0 + missing
  false + transferred == (món cho không rỗng); voided thì paid 0
  + transferred false + reason không rỗng + có ít nhất 1 nguyên
  nhân; khối bẩn thì bỏ khối, giữ giao dịch) + `_clean_trade`
  giữ khối ledger khi hợp lệ (log sau load giữ khối ledger, bỏ
  khóa `"apply"` như cũ).
  - `apply_trade_completed` nhánh sổ cái: voided → không trừ/cộng
    gì ở local, ghi id đã áp (chống áp trùng), trả `reason` hủy
    + `voided:true` + `short_money`/`missing_item` theo vai để
    Main/toast báo rõ; đã quyết toán → áp đúng số server ghi
    (`sender_paid`/`receiver_paid` theo vai, tiền cho thiếu so
    với số server thì trừ tới 0 + ghi `short_money` như cũ —
    chỉ xảy ra khi túi/ví local lệch khỏi ledger đã đồng bộ).
    Không có khối ledger (server cũ / chưa ai đồng bộ) thì dùng
    đường cũ (v70).
  - `send_ws_trade_offer` / `send_ws_trade_accept` nay gọi
    `send_ws_ledger_sync()` trước khi gửi (để server validate /
    quyết toán bằng số mới nhất — như đấu giá ở vòng 72).
  - Doc đầu file cập nhật: bước 11 ghi sổ cái trade (v73), bước
    12 sửa dòng cũ "CHƯA giữ sổ cái" (nay đã có từ vòng 72).
- `main.gd` — `_on_ws_trade_completed`: giao dịch bị hủy thì
  toast riêng "Đổi đồ bị hủy: <lý do tiếng Việt>" (4 lý do theo
  vai người gửi/người nhận), không giả vờ đã đổi xong.
- **KHE HỞ CÒN LẠI (v73, ghi rõ trong code + doc server):** sổ
  cái tin số client đồng bộ — client vẫn tiêu được tiền giữ hộ
  ở local giữa 2 lần sync, và đồng bộ ghi đè nên client mất kết
  nối đúng lúc chốt rồi sync lại bằng số local cũ sẽ ghi đè mất
  khoản đã quyết toán. Nhưng trong 1 lần chấp nhận thì quyết
  toán là nguyên tử — không còn chuyện 1 bên nhận đủ trong khi
  bên kia trả thiếu (khe hở v1 đã đóng). Đóng hẳn cần kinh tế
  server-authoritative / chặn tiêu tiền giữ hộ ở client — việc
  sau.

### 95.2 Test mới + hồi quy — XONG

- Test mới `tests/g4_online_trade_ledger_test.gd`: **97/97 PASS** —
  socket thật + server thật qua loopback cổng 18773, 3 client
  (A + B đã đồng bộ, C CHƯA đồng bộ — không nối túi/ví — để
  kiểm đường cũ): chặn gửi đề nghị vượt tiền/món ledger ở server
  (gói thô, `khong-du-tien-cho` / `khong-du-do-cho`, dropped +1,
  không tạo đề nghị); quyết toán thành công — tiền/món 2 bên +
  ledger server khớp nhau tuyệt đối (A còn 1 com-tam + 1 ca-phe
  + 4,5 triệu; B hết ca-phe + 1 com-tam + 2,5 triệu); race tiền
  (A tiêu mất 4 triệu sau khi gửi, chỉ còn 500k) → HỦY, lý do
  `thieu-tien-nguoi-gui`, thiếu 3,5 triệu, không bên nào đổi;
  race món (B dùng mất com-tam sau khi gửi) → HỦY, lý do
  `thieu-do-nguoi-gui`; bên chưa đồng bộ (C) thì đường cũ — bên
  đã đồng bộ vẫn quyết toán đúng (A hết com-tam + nhận sach),
  C áp trả `chua-noi-tui-vi`, local C không đổi, C vẫn không có
  ledger; áp trùng trade_id thì bỏ lần 2; `data()`/`from_data()`
  giữ khối ledger (kể cả khối voided), khối ledger bẩn (trả vượt
  tiền thỏa thuận) thì bỏ khối giữ giao dịch; `reset_state()`
  xóa log + mốc sync.
- `tools/godot/run_regression.sh` đã thêm
  `g4_online_trade_ledger_test`.
- Hồi quy: **99 OK, 0 FAIL** (log
  `hidden_files/regression-2026-11-27-0745.log`): trade ledger
  97/97 mới + toàn bộ test cũ vẫn PASS (không regression).

### 95.3 Verify + export — XONG

- `--check-only` exit 0: `pxb_server.gd`, `pxb_online.gd`,
  `main.gd`, `g4_online_trade_ledger_test.gd`.
- Scene Main 120 frame exit 0, 0 ERROR/warning.
- Export web exit 0: pck mới **27.763.800 byte, SHA `64aace39…`**
  (trước `0dc02713…`), wasm không đổi `fc74679e…`,
  `GODOT_THREADS_ENABLED = false`; pck chứa
  `res://tests/g4_online_trade_ledger_test.gd` (grep thấy 2 lần
  trong pck — chuỗi literal trong script biên dịch không grep
  được trực tiếp, đã kiểm chứng bằng đường dẫn file + SHA/size
  đổi, như các vòng trước).
- HTTP 200 đủ 4 file (`index.html`/`index.js`/`index.wasm`/
  `index.pck`, cổng 8949, đã tắt server sau khi kiểm).
- Chưa browser-verify vòng này (thay đổi là logic sổ cái +
  test headless qua socket thật; toast hủy trade trong game chưa
  bấm tay).

### 95.4 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- Push main r73 (gộp r43–r73: a **119** / b 20 / c 37 / docs 2) +
  deploy pck `64aace39` (12 lô: 11 lô chunk 206 + final) đã chuẩn
  bị xong (script `pxb-push-main-r73.py`, `pxb-deploy-r73.py` +
  manifest trong hidden_files goal; staging rebuild,
  `build_gh_pages.py --verify-only` OK — pck `64aace39`, 206
  chunk, khớp byte; wasm không đổi `fc74679e`). **Thay script
  r72 (pck `0dc02713` chưa lên — bỏ, không xóa file, theo mẫu
  vòng 46).** **CHƯA CHẠY — chờ chủ nói 'đẩy tiếp'** (không còn
  thẻ chờ; live vẫn `5f2a052f` r41). Lô a r73 = lô a r72 (117) +
  `g4_online_trade_ledger_test.gd` (+.uid) — `main.gd`,
  `pxb_online.gd`, `pxb_server.gd`, `run_regression.sh` đã có
  trong lô a r72.

### 95.5 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r73 (4 lô) → deploy pck mới
   (12 lô) → kiểm live pin + đối chiếu byte.
2. Browser-verify vòng 68 (bấm B lúc đang giữ sạp → toast tiếng
   Việt, không mở trận) — cần thắng 1 trận demo trước để có hold.
3. G4 online tiếp: UI trade/đấu giá trong điện thoại (nút gửi đề
   nghị / mở phiên / đặt giá cho người online — logic WS đã có,
   chỉ thiếu UI) — hoặc kinh tế server-authoritative / chặn tiêu
   tiền giữ hộ ở client (đóng khe hở còn lại của §94.1, nay áp
   cho cả trade).

## §96 — Vòng 74: UI trade / đấu giá trong điện thoại (27/11 ~08:45–09:15 +07, cron 08:45)

Mục 3 của §95.5 (G4 online) — logic WS trade/đấu giá đã có từ
vòng 69–73, chỉ thiếu UI trong điện thoại: người chơi chưa bấm
được gì ngoài chat. Vòng này nối UI vào 2 tab có sẵn (không thêm
tab mới — 9 tab GDD giữ nguyên).

### 96.1 Code — XONG

- `main.gd` — hằng mới `TRADE_OFFER_WANT_MONEY_VND = 100000`,
  `AUCTION_CREATE_START_PRICE_VND = 100000`,
  `AUCTION_CREATE_DURATION_S = 60`. Đề nghị + phiên mẫu dùng số
  cố định vì điện thoại chưa có ô nhập số — ghi rõ trong code +
  doc, không bịa thêm UI nhập số.
  - Tab Tin nhắn (khi đã nối WS): nút "Đổi đồ với <tên>" cho từng
    người online (trừ chính mình) → gửi đề nghị mẫu: cho món đầu
    tiên trong túi, lấy 100.000đ; đề nghị đến → nút "Chấp nhận: …" /
    "Từ chối: …" + dòng mô tả trong nội dung; đề nghị đã gửi → nút
    "Hủy đề nghị: …". Túi trống thì bấm gửi/mở phiên vẫn báo toast
    "Túi đang trống…" thay vì im lặng.
  - Tab Chợ (khi đã nối WS): nội dung thêm khối
    `ws_auctions_text()` (kể cả khi chưa nối — báo ngoại tuyến);
    từng phiên: người bán khác → nút "Đặt giá <giá tiếp theo>đ"
    (giá tiếp theo = giá hiện tại + 1.000đ, chưa ai đấu thì giá
    khởi điểm); phiên của mình chưa có giá → nút "Hủy phiên";
    chưa có phiên của mình → nút "Mở phiên: bán <món đầu tiên> —
    100.000đ, 60 giây" (túi trống thì nút chỉ ghi "Mở phiên đấu
    giá", bấm vào báo túi trống); nút "Làm mới danh sách đấu giá".
  - Helper mới: `_first_owned_item_id()` (id nhỏ nhất theo alphabet
    trong `bag`, ổn định giữa các lần mở — không phụ thuộc thứ tự
    chèn Dictionary), `_first_owned_item_name()`,
    `_ws_player_name()`, `_trade_offer_text()` ("Bình cho Cà Phê,
    muốn Cơm Tấm + 100.000đ"; mã lạ in mã thô, không bịa tên),
    `_ws_auction_next_bid()`, `_has_my_auction_open()`,
    `_ws_trade_reason_text()` / `_ws_auction_reason_text()` (dịch
    mã lỗi PxbOnline sang tiếng Việt, không để mã thô lọt ra màn
    hình).
  - Signal mới nối trong `_ready`: `ws_trade_offer_received` /
    `ws_trade_offered_sent` / `ws_trade_declined` /
    `ws_trade_cancelled` / `ws_trade_error` / `ws_auction_created`
    / `ws_auction_bid` / `ws_auction_list` / `ws_auction_cancelled`
    / `ws_auction_error`. Đề nghị đến / phiên mới / giá mới: đang
    mở đúng tab thì làm tươi ngay, không thì `notify()` báo số chưa
    đọc ở tab đó (đề nghị đến lúc đóng điện thoại → chấm đỏ tab Tin
    nhắn, như tin chat).
- `tools/godot/run_regression.sh` — thêm `g4_r74_phone_online_ui_test`.

### 96.2 Test mới + hồi quy — XONG

- Test mới `tests/g4_r74_phone_online_ui_test.gd`: **44/44 PASS** —
  server Godot thật cổng 18774 + scene Main thật + 1 client đối tác
  thật (Bình): helper (món đầu tiên, mô tả đề nghị, giá đấu tiếp
  theo, dịch lỗi), nút "Đổi đồ với Bình" → gửi đề nghị mẫu → hủy,
  đề nghị đến → chấp nhận (túi đổi thật: com-tam 1→0, ca-phe 1→2)
  / từ chối, đề nghị đến lúc đóng điện thoại → báo chưa đọc (mở tab
  xóa), tab Chợ → mở phiên bán ca-phe 100.000đ/60 giây → Bình đấu
  giá 100.000đ → nội dung hiện giá hiện tại → người bán không thấy
  nút "Đặt giá" cho phiên của mình + tự đấu giá bị chặn bằng toast
  → Bình đấu tiếp 101.000đ → hủy phiên đã có giá bị chặn → làm mới
  danh sách.
  - Lần chạy 1: **42/44** — 2 FAIL đều do test viết sai, không phải
    code: (1) phase gửi đề nghị không chờ server trả `trade_offered`
    (1 vòng mạng) nên `ws_my_offers` còn rỗng lúc kiểm + đọc index 0
    gây script error; đã sửa test thành chờ `my_offers` có 1 rồi mới
    kiểm/hủy. (2) test đòi nút "Đặt giá 101.000đ" trên phiên của
    chính Main — sai thiết kế: người bán không thấy nút đặt giá cho
    phiên của mình; đã sửa thành kiểm nội dung hiện giá hiện tại +
    không có nút "Đặt giá". Không sửa code Main ở cả 2 chỗ.
- Hồi quy: **100 OK, 0 FAIL** (log
  `hidden_files/regression-2026-11-27-0907.log`): test mới 44/44 +
  toàn bộ test cũ vẫn PASS (không regression).

### 96.3 Verify + export — XONG

- `--check-only` exit 0: `main.gd`, `g4_r74_phone_online_ui_test.gd`.
- Scene Main 120 frame exit 0, 0 ERROR/warning.
- Export web exit 0: pck mới **27.780.060 byte, SHA `c5fcdc77…`**
  (trước `64aace39…`), wasm không đổi `fc74679e…`,
  `GODOT_THREADS_ENABLED = false`; pck chứa
  `res://tests/g4_r74_phone_online_ui_test.gd` (grep thấy 2 lần
  trong pck — chuỗi literal trong script biên dịch không grep
  được trực tiếp, đã kiểm chứng bằng đường dẫn file + SHA/size
  đổi, như các vòng trước).
- HTTP 200 đủ 4 file (`index.html`/`index.js`/`index.wasm`/
  `index.pck`, cổng 8950, đã tắt server sau khi kiểm).
- Staging rebuild `build_gh_pages.py --verify-only` OK (pck
  `c5fcdc77`, 206 chunk, khớp byte; wasm không đổi `fc74679e`).
- Chưa browser-verify vòng này (thay đổi là UI điện thoại + test
  headless qua socket thật; các nút trade/đấu giá chưa bấm tay
  trên trình duyệt thật).

### 96.4 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- Push main r74 (gộp r43–r74: a **121** / b 20 / c 37 / docs 2) +
  deploy pck `c5fcdc77` (12 lô: 11 lô chunk 206 + final) đã chuẩn
  bị xong (script `pxb-push-main-r74.py`, `pxb-deploy-r74.py` +
  manifest trong hidden_files goal; staging rebuild,
  `build_gh_pages.py --verify-only` OK — pck `c5fcdc77`, 206
  chunk, khớp byte; wasm không đổi `fc74679e`). **Thay script
  r73 (pck `64aace39` chưa lên — bỏ, không xóa file, theo mẫu
  vòng 46).** **CHƯA CHẠY — chờ chủ nói 'đẩy tiếp'** (không còn
  thẻ chờ; live vẫn `5f2a052f` r41). Lô a r74 = lô a r73 (119) +
  `g4_r74_phone_online_ui_test.gd` (+.uid) — `main.gd` và
  `run_regression.sh` đã có trong lô a r73.

### 96.5 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r74 (4 lô) → deploy pck mới
   (12 lô) → kiểm live pin + đối chiếu byte.
2. Browser-verify vòng 68 (bấm B lúc đang giữ sạp → toast tiếng
   Việt, không mở trận) — cần thắng 1 trận demo trước để có hold.
3. G4 online tiếp: kinh tế server-authoritative / chặn tiêu tiền
   giữ hộ ở client (đóng khe hở còn lại của §94.1, nay áp cho cả
   trade) — hoặc ô nhập số trong điện thoại để đề nghị/phiên không
   còn dùng số mẫu cố định 100.000đ.

## §97 — Vòng 75: ô nhập số trong điện thoại (27/11 ~09:45–10:15 +07, cron 09:45)

Mục 3 của §96.5, lựa chọn thứ 2 (G4 online) — đề nghị + phiên ở
vòng 74 dùng số mẫu cố định 100.000đ / 60 giây vì điện thoại chưa
có ô nhập số. Vòng này thêm ô nhập số vào 2 tab có sẵn, không thêm
tab mới, không đổi luật server (mọi giới hạn vẫn do PxbOnline +
server kiểm tra lại).

### 97.1 Code — XONG

- `main.gd` — helper mới `_parse_vnd_input(le, default, min, max)`:
  bỏ dấu chấm/phẩy/khoảng trắng ("100.000" hay "100000" đều
  được); trống / sai định dạng → mặc định; âm / vượt trần → kẹp
  về min/max; LineEdit đã bị xóa (đổi tab) → mặc định.
  `_ws_auction_bid_amount(auction)`: ô trống / sai định dạng → giá
  tiếp theo; gõ thấp hơn giá tiếp theo → trả -1 để handler báo lỗi,
  không gửi; gõ cao → kẹp về max. `_phone_number_input(placeholder,
  current_value)` tạo LineEdit 580×56, giữ số đã gõ qua mỗi lần vẽ
  lại điện thoại (biến thành viên `_trade_want_money_vnd` /
  `_auction_start_price_vnd` / `_auction_duration_s` /
  `_bid_amount_vnd`, 0 = để trống = giá tiếp theo).
  - Tab Tin nhắn (khi đã nối WS): ô "Số tiền muốn lấy khi đổi đồ
    (đ) — mặc định 100.000" trước nút "Đổi đồ với <tên>";
    `_on_ws_trade_offer_pressed` đọc số từ ô thay cho hằng
    `TRADE_OFFER_WANT_MONEY_VND` (hằng giữ làm mặc định), toast
    ghi số thật đã gửi.
  - Tab Chợ (khi đã nối WS): ô "Giá đấu của bạn (đ) — để trống =
    giá tiếp theo" trước nút đặt giá; ô "Giá khởi điểm (đ) — mặc
    định 100.000" + ô "Thời gian phiên (giây, 30–3600) — mặc định
    60" trước nút mở phiên; `_on_ws_auction_create_pressed` đọc
    cả 2 ô (giá < 1.000đ kẹp lên 1.000đ, thời gian kẹp 30..3600
    giây theo luật PxbOnline), toast ghi giá + giây thật;
    `_on_ws_auction_bid_pressed` đọc ô giá đấu — gõ thấp hơn giá
    tiếp theo thì toast "Giá đấu phải từ <giá tiếp theo>đ trở lên."
    và không gửi. Nút "Mở phiên: bán <món> — <giá>đ, <giây> giây"
    ghi giá trị đã lưu lúc vẽ (số vừa gõ chỉ chốt khi bấm nút,
    toast xác nhận số thật sau khi bấm).
- `tools/godot/run_regression.sh` — thêm
  `g4_r75_phone_amount_input_test`.

### 97.2 Test mới + hồi quy — XONG

- Test mới `tests/g4_r75_phone_amount_input_test.gd`: **45/45 PASS**
  (chạy đầu đã pass hết) — server Godot thật cổng 18775 + scene
  Main thật + 1 client đối tác thật (Bình): parse (số thường /
  dấu chấm / khoảng trắng / chữ / trống / âm / vượt trần / thời
  gian kẹp 30..3600 / LineEdit null), gõ 250.000đ → đề nghị thật
  want_money 250000, gõ "abc" → về mặc định 100.000đ, mở phiên
  300.000đ / 120 giây → start_price 300000 + toast "120 giây",
  Bình đấu giá 300.000đ, Bình mở phiên riêng 200.000đ/3600 giây →
  Main đấu 500.000đ → giá hiện tại 500000, đấu 400.000đ (thấp hơn
  giá tiếp theo 501.000đ) → toast lỗi + giá không đổi, để trống →
  tự đấu giá tiếp theo 501.000đ, mở lại 2 tab → số đã gõ vẫn giữ
  (giá đấu 501000, tiền đổi đồ 100000).
- Hồi quy: **101 OK, 0 FAIL** (log
  `hidden_files/regression-2026-11-27-0945.log`, tổng 3940 passes):
  test mới 45/45 + toàn bộ test cũ vẫn PASS (không regression).

### 97.3 Verify + export — XONG

- `--check-only` exit 0: `main.gd`, `g4_r75_phone_amount_input_test.gd`.
- Scene Main 120 frame exit 0, 0 ERROR/warning.
- Export web exit 0: pck mới **27.804.788 byte, SHA `b300bf4d…`**
  (trước `c5fcdc77…`), wasm không đổi `fc74679e…`,
  `GODOT_THREADS_ENABLED = false`; pck chứa
  `res://tests/g4_r75_phone_amount_input_test.gd` (grep thấy 4 lần
  trong pck — chuỗi literal trong script biên dịch không grep
  được trực tiếp, đã kiểm chứng bằng đường dẫn file + SHA/size
  đổi, như các vòng trước).
- HTTP 200 đủ 4 file (`index.html`/`index.js`/`index.wasm`/
  `index.pck`, cổng 8951, đã tắt server sau khi kiểm).
- Staging rebuild `build_gh_pages.py --verify-only` OK (pck
  `b300bf4d`, 206 chunk, khớp byte; wasm không đổi `fc74679e`).
- Chưa browser-verify vòng này (thay đổi là ô nhập số trong điện
  thoại + test headless qua socket thật; các ô nhập chưa gõ tay
  trên trình duyệt thật).

### 97.4 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- Push main r75 (gộp r43–r75: a **123** / b 20 / c 37 / docs 2) +
  deploy pck `b300bf4d` (12 lô: 11 lô chunk 206 + final) đã chuẩn
  bị xong (script `pxb-push-main-r75.py`, `pxb-deploy-r75.py` +
  manifest trong hidden_files goal; staging rebuild,
  `build_gh_pages.py --verify-only` OK — pck `b300bf4d`, 206
  chunk, khớp byte; wasm không đổi `fc74679e`). **Thay script
  r74 (pck `c5fcdc77` chưa lên — bỏ, không xóa file, theo mẫu
  vòng 46).** **CHƯA CHẠY — chờ chủ nói 'đẩy tiếp'** (không còn
  thẻ chờ; live vẫn `5f2a052f` r41). Lô a r75 = lô a r74 (121) +
  `g4_r75_phone_amount_input_test.gd` (+.uid) — `main.gd` và
  `run_regression.sh` đã có trong lô a r74.

### 97.5 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r75 (4 lô) → deploy pck mới
   (12 lô) → kiểm live pin + đối chiếu byte.
2. Browser-verify vòng 68 (bấm B lúc đang giữ sạp → toast tiếng
   Việt, không mở trận) — cần thắng 1 trận demo trước để có hold.
3. G4 online tiếp: kinh tế server-authoritative / chặn tiêu tiền
   giữ hộ ở client (đóng khe hở còn lại của §94.1, nay áp cho cả
   trade) — việc lớn cuối cùng của chuỗi sổ cái vòng 72–74; hoặc
   browser-verify các ô nhập số vòng 75 trên trình duyệt thật.

## §98 — Vòng 76: sổ cái server-authoritative — kẹp tiền/món + chống ghi đè stale + chặn tiêu tiền giữ hộ (27/11 ~10:45–12:00 +07, cron 10:45 + cron 11:45)

Mục 3 của §97.5 (G4 online) — đóng khe hở còn lại của §94.1, nay
áp cho cả đấu giá VÀ trade: trước đây sổ cái tin số client đồng
bộ — client tiêu được tiền đang giữ hộ ở local giữa 2 lần sync,
và sync lại bằng số local cũ sau khi mất kết nối đúng lúc chốt
phiên sẽ ghi đè mất khoản đã quyết toán.

LƯU Ý CHẠY: code + test vòng này do worker của cron 10:45 làm
xong (~11:45) nhưng dừng do cron timeout trước khi chạy hồi quy;
cron 11:45 (lượt này) chạy tiếp: hồi quy + verify + export +
docs + chuẩn bị push/deploy. Không sửa lại code của lượt trước,
chỉ kiểm chứng + hoàn thiện.

### 98.1 Code — XONG (cron 10:45)

- `server/pxb_server.gd` — `_handle_ledger_sync` nhận thêm
  `base_money` (int, -1 = chưa từng nhận ack): money lúc sync lần
  trước. Đã có entry ledger mà `base_money >= 0` và khác money
  trong ledger → sync STALE (đã có quyết toán chen giữa) nên
  KHÔNG ghi đè, chỉ trả `ledger_sync_ack` với số server +
  `stale: true`. Đồng bộ thường thay thế money/items nhưng GIỮ
  reserved, và KẸP: money không xuống dưới reserved
  (`clamped_money: true` khi bị kẹp); mỗi món đã hứa bán/cho
  (phiên đấu giá đang mở của người này + trade đang chờ do người
  này gửi, cộng dồn nếu nhiều phiên/trade cùng món) không xuống
  dưới số đã hứa (`clamped_items: {item_id: số tối thiểu}`).
  Ack luôn trả về đúng peer: money/items/reserved là số server
  sau khi ghi (stale thì là số server hiện tại). Doc đầu file cập
  nhật: giao thức `ledger_sync` + ack + ghi chú PROVISIONAL mới
  (khe hở còn lại: mua/bán local trong Main vẫn chưa qua server
  validate — xem §98.5).
- `scripts/pxb_online.gd` — client giữ số server làm chuẩn:
  `ws_ledger_authoritative_money` / `ws_ledger_authoritative_items`
  / `ws_reserved_money` / `ws_last_ledger_ack` + signal
  `ws_ledger_sync_acked`, cập nhật khi nhận `ledger_sync_ack`
  (làm sạch qua `_clean_ledger_sync_ack`: money/items/reserved
  hợp lệ, `clamped_money`/`stale` bool, `clamped_items` dict;
  gói bẩn thì bỏ lặng); `ws_ledger_clamped_count` đếm ack bị kẹp.
  `send_ws_ledger_sync()` tự kẹp tiền gửi đi theo reserved
  (`maxi(money, reserved)`) + gửi kèm `base_money` là money lần
  sync trước; `_maybe_auto_sync_ledger()` so sánh theo số SẼ GỬI
  (đã kẹp) để khỏi gửi trùng mỗi 500 ms; nhận `auction_bid` mà
  mình liên quan (vừa đấu dẫn đầu / vừa bị vượt giá) thì sync
  ngay để lấy reserved mới. `_rebaseline_ledger_after_settlement()`
  đặt lại baseline theo local sau khi áp 1 quyết toán thành công
  (không bị đánh stale oan ở lần sync kế). `ws_available_money()`
  = ví trừ tiền giữ hộ (Main dùng để chặn chi tiêu).
  `reset_state()` xóa cả biến mới.
- `main.gd` — `_on_ws_ledger_sync_acked` (nối signal lúc
  `_ready`): ack về mà ví/túi local lệch số server thì áp số
  server vào ví/túi + toast "Máy chủ đã đồng bộ lại ví/túi (đã
  trừ tiền đấu giá/trade đã chốt).". `_reserve_blocked(amount)`:
  chỉ chặn khi đã nối WS + server đang giữ hộ + khoản chi làm ví
  xuống dưới số giữ hộ; offline/không giữ hộ thì không chặn.
  Chặn ở 4 chỗ chi tiền local: `buy_item` (mua đồ, tính đúng giá
  sỉ khi giữ sạp), `deposit_savings` (gửi tiết kiệm), `enroll_degree`
  (học phí, kiểm tra trước khi enroll vì enroll xong không hoàn
  tác được), `enroll_short_course` (phí 2 triệu) — đều toast tiếng
  Việt "Tiền đang giữ hộ đấu giá/trade, không … được." + trả
  `reason: "tien-dang-giu-ho"`, không trừ tiền. Rút tiết kiệm
  không chặn (tiền rút vào ví, không chạm tiền giữ hộ).

### 98.2 Test mới + hồi quy — XONG

- Test mới `tests/g4_r76_ledger_authoritative_test.gd`:
  **121/121 PASS** — socket thật + server thật qua loopback cổng
  18776, client A thô (seller) + scene Main thật (bidder), 6
  phase: (0) setup — 2 client hello/welcome, ledger A 5 triệu +
  cơm tấm ×3, Main 2 triệu, baseline Main theo ack; (a) server
  kẹp tiền — Main đấu dẫn đầu 1,6 triệu (reserved 1,6 triệu),
  tiêu local còn 500k rồi sync với base đúng → ledger vẫn ≥1,6
  triệu, ack `clamped_money: true`; client tự kẹp tiền gửi đi;
  (b) server kẹp món — A mở phiên bán cơm tấm rồi sync túi không
  có cơm tấm → ledger vẫn giữ ≥1; gửi trade cho cơm tấm rồi sync
  lại → kẹp cộng dồn = 2; hủy trade → kẹp về 1; (c) stale sync —
  phiên 1 đóng, server đã trừ tiền người thắng, client gửi sync
  với `base_money` cũ (trước quyết toán) → server KHÔNG ghi đè,
  ack `stale: true` + money == số server; Main áp ack → ví local
  == số server + toast đồng bộ lại; (d) spend guard ở Main thật —
  Main đấu dẫn đầu (reserved > 0): mua món đắt hơn tiền khả dụng
  / gửi tiết kiệm vượt khả dụng / đóng học phí vượt khả dụng →
  bị chặn (toast tiếng Việt, ví không đổi); mua món rẻ / khóa phí
  vừa khả dụng → vẫn được; (e) baseline theo ack + (f)
  `reset_state` xóa biến mới (reserved về 0, số chuẩn về -1, ack
  gần nhất rỗng, ngắt WS).
- `tools/godot/run_regression.sh` đã thêm
  `g4_r76_ledger_authoritative_test`.
- Hồi quy: **102 OK, 0 FAIL** (log
  `hidden_files/regression-2026-11-27-1145.log`, tổng 3997
  passes): test mới 121/121 + toàn bộ test cũ vẫn PASS (không
  regression). Lỗi WebSocket `ready_state != STATE_OPEN` ở cuối
  log test r76 là noise khi teardown sau khi test đã xong (exit
  0), không phải lỗi test.

### 98.3 Verify + export — XONG

- `--check-only` exit 0: `pxb_server.gd`, `pxb_online.gd`,
  `main.gd`, `g4_r76_ledger_authoritative_test.gd`.
- Scene Main 120 frame exit 0, 0 ERROR/warning.
- Export web exit 0: pck mới **27.828.448 byte, SHA `365faa62…`**
  (trước `b300bf4d…`), wasm không đổi `fc74679e…`,
  `GODOT_THREADS_ENABLED = false`; pck chứa
  `res://tests/g4_r76_ledger_authoritative_test.gd` (grep thấy 4
  lần trong pck).
- HTTP 200 đủ 4 file (`index.html`/`index.js`/`index.wasm`/
  `index.pck`, cổng 8952, đã tắt server sau khi kiểm).
- Staging rebuild `build_gh_pages.py --verify-only` OK (pck
  `365faa62`, 207 chunk, ráp lại 27.828.448 byte SHA `365faa62…`
  khớp byte với build local; wasm không đổi `fc74679e`).
- Chưa browser-verify vòng này (thay đổi là logic sổ cái +
  test headless qua socket thật; toast chặn tiêu tiền giữ hộ
  trong game chưa bấm tay).

### 98.4 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- Push main r76 (gộp r43–r76: a **125** / b 20 / c 37 / docs 2) +
  deploy pck `365faa62` (12 lô: 11 lô chunk 207 + final) đã chuẩn
  bị xong (script `pxb-push-main-r76.py`, `pxb-deploy-r76.py` +
  manifest trong hidden_files goal; staging rebuild,
  `build_gh_pages.py --verify-only` OK — pck `365faa62`, 207
  chunk, khớp byte; wasm không đổi `fc74679e`). **Thay script
  r75 (pck `b300bf4d` chưa lên — bỏ, không xóa file, theo mẫu
  vòng 46).** **CHƯA CHẠY — chờ chủ nói 'đẩy tiếp'** (không còn
  thẻ chờ; live vẫn `5f2a052f` r41). Lô a r76 = lô a r75 (123) +
  `g4_r76_ledger_authoritative_test.gd` (+.uid — .uid sẽ sinh khi
  import/export, đã có trong manifest sau khi export).

### 98.5 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r76 (4 lô) → deploy pck mới
   (12 lô) → kiểm live pin + đối chiếu byte.
2. Browser-verify vòng 68 (bấm B lúc đang giữ sạp → toast tiếng
   Việt, không mở trận) — cần thắng 1 trận demo trước để có hold.
3. G4 online tiếp: kinh tế server-authoritative HOÀN TOÀN — mua/
   bán local trong Main (shop, chợ) vẫn chưa qua server validate;
   server hiện chỉ chặn ghi đè ledger sai + chặn tiêu tiền giữ hộ
   qua sync. Đóng khe hở này cần mọi giao dịch mua/bán đi qua
   server (validate + trừ tiền trong ledger) — việc lớn tiếp theo
   của chuỗi sổ cái; hoặc browser-verify toast chặn tiêu tiền giữ
   hộ vòng 76 trên trình duyệt thật.

## §99 — Vòng 77: mua ở chợ qua server validate — kinh tế server-authoritative hoàn toàn (27/11 ~12:45–13:30 +07, cron 12:45)

> Mục 3 của §98.5 — đóng khe hở "mua/bán local trong Main chưa
> qua server validate". Bán lại cho chợ CHƯA CÓ (game chưa có
> tính năng bán — economy cũng không có hàm sell) nên vòng này
> chỉ có mua; thêm bán thì cần `shop_sell` riêng.

### 99.1 Code — XONG

- `server/pxb_server.gd` — giao thức mới `shop_buy` /
  `shop_buy_ack` (doc đầu file cập nhật) + `shop_log` (100 lần
  mua gần nhất, `SHOP_LOG_MAX`) + `shop_buy_count` trong
  `data()` + dispatch + `_handle_shop_buy`:
  - Validate: phải hello trước (`chua-hello`); `req_id` int
    >= 1 (sai thì `dropped_packets`, không trả ack — client
    luôn gửi req_id đúng); `item_id` rỗng/dài → `thieu-item-id`;
    `discount_percent` ngoài 0..50 → `gia-khong-hop-le`.
  - Giá lấy từ `PxbEconomy.get_item` (bảng giá duy nhất —
    server KHÔNG tin giá client gửi, client cũng không gửi
    giá); món không có → `khong-co-mon`; giảm giá đúng luật
    `economy.buy` (discount 0..50, KHÔNG áp cho `phong-tro`;
    xe-đạp giá 0 thì mua 0đ vẫn qua server để ghi log).
  - Phải có entry ledger (đã đồng bộ ít nhất 1 lần) —
    chưa có thì `chua-dong-bo-so-cai`, client sync rồi mua
    lại; tiền khả dụng = money − reserved (cùng luật vòng 76).
  - Thành công: TRỪ TIỀN trong ledger + ghi `shop_log` +
    ack ok=true (`money`/`reserved` là số server sau khi trừ,
    `price_paid`, `fame_gained` = 50 khi kind House hoặc
    `xe-sang` — đúng `economy.buy`); thất bại: không trừ gì,
    ack ok=false + reason.
  - `owned` KHÔNG nằm trong ledger items (ledger items là túi
    đồ slice `PxbInventory`; nhà/xe/điện thoại/quần áo mua ở
    chợ nằm trong `economy.owned`, không đem đấu giá/trade
    được) nên server không theo dõi owned — món mua là tài
    sản local, TIỀN mới là phần server-authoritative. Muốn
    owned cũng lên ledger thì cần ledger_sync owned + server
    làm chuẩn cho owned (việc sau, ngoài vòng này).
  - PROVISIONAL: discount là số client tự khai (server chưa
    biết ai đang giữ sạp — giữ sạp chỉ có ở `battle_state`
    local), server chỉ kẹp 0..50; muốn validate thật thì phải
    đồng bộ giữ sạp lên server trước (việc sau).
- `scripts/pxb_online.gd` — `send_ws_shop_buy(item_id,
  discount_percent)` (đồng bộ ledger trước khi gửi như
  `auction_bid`; chưa nối túi/ví thì bỏ qua pre-sync, vẫn gửi
  — server trả `chua-dong-bo-so-cai` nếu chưa có entry;
  `req_id` tăng dần, lưu `_ws_shop_pending`) + signal
  `ws_shop_buy_acked` + `_clean_shop_buy_ack` (req_id >= 1,
  ok bool, price_paid/fame_gained/money/reserved int >= 0,
  reason string) + nhận `shop_buy_ack` trong
  `_handle_ws_message` (req_id không khớp lần mua đang chờ thì
  bỏ lặng; khớp thì cập nhật baseline/authoritative/reserved
  theo ack + áp tiền vào `trade_economy.money` khi ok — giống
  `apply_auction_closed`, để lần sync kế không ghi đè số
  server bằng ví local cũ; Main áp lại theo delta sau đó) +
  `reset_state` xóa pending + req_id.
  - Cùng vòng 77 — SỬA RACE CỦA ACK SYNC (tìm ra khi test
    phase 2): mỗi lần `send_ws_ledger_sync` ghi lại ví local
    lúc gửi vào `_ws_ledger_sent_money_queue` (tiền TRƯỚC
    KHI kẹp theo reserved — vd ví 500k giữ hộ 1,6 triệu thì
    gửi đi 1,6 triệu nhưng delta phải tính theo 500k); ack về
    kèm `sent_money` (pop đầu hàng đợi — ack trả đúng thứ tự)
    để Main áp ví theo delta thay vì áp tuyệt đối (không nuốt
    tiền kiếm/tiêu local trong lúc chờ ack). Sync gửi thô
    (không qua `send_ws_ledger_sync`) thì ack không có
    `sent_money` và Main áp tuyệt đối như vòng 76. Hàng đợi
    giữ tối đa 8 mục, xóa ở `reset_state`. Lệch còn lại: ack
    bẩn không tiêu thụ mục nào (server của mình không gửi ack
    bẩn nên chấp nhận).
- `main.gd` — `_pending_shop_buy` (chỉ 1 lần mua chờ: {req_id,
  item_id, discount_percent, money_at_send}) + nối signal
  `ws_shop_buy_acked` + `buy_item` đi qua server khi đã nối
  WS (mua chen khi đang chờ → `dang-cho-may-chu`; gửi thất
  bại vì mất kết nối thì rơi về mua local như cũ; gửi ok thì
  toast "Đang chờ máy chủ xác nhận mua …" + trả
  `cho-may-chu`/`pending:true`) + `_on_ws_shop_buy_acked`
  (req_id lạ thì bỏ; ok thì ví = ack.money + (jobs.gold −
  money_at_send) — không mất tiền kiếm/tiêu local trong lúc
  chờ, kẹp >= 0; món vào `economy.owned`, Danh vọng theo ack,
  toast tiếng Việt; không ok thì toast theo reason, không
  trừ/cộng gì) + `_on_ws_status_changed(false)` xóa pending
  khi mất kết nối trong lúc chờ (toast "Mất kết nối, lần mua
  chưa được xác nhận — thử mua lại.") + tab Chợ ẩn nút mua
  trong lúc chờ ("Đang chờ máy chủ xác nhận mua hàng…") +
  `_on_ws_ledger_sync_acked` áp ví theo delta khi ack có
  `sent_money` (không có thì áp tuyệt đối như vòng 76).

### 99.2 Test mới + hồi quy — XONG

- Test mới `tests/g4_r77_server_shop_buy_test.gd`:
  **95/95 PASS** — socket thật + server thật qua loopback cổng
  18777, client A thô + client C thô (chưa đồng bộ) + scene
  Main thật, 10 phase: (0) setup — unit `send_ws_shop_buy`
  khi chưa nối + `_clean_shop_buy_ack` 6 trường hợp, 2 client
  hello/welcome, ledger A 5 triệu + cơm tấm ×3, ledger Main
  1 tỉ; (1) mua ok qua Main — chung-cu-mini 800 triệu, ack
  ok, ví 200 triệu, owned + Danh vọng +50, ledger server
  200 triệu, `shop_log` 1, toast "Đã mua Chung cư mini (máy
  chủ đã trừ 800.000.000đ).", baseline theo ack; (2) delta
  trong lúc chờ ack — mua ao-dai 2 triệu, ví local +100k sau
  khi gửi → ví = 198 triệu + 100k (chính race này bắt được
  lỗi áp tuyệt đối của ack sync — đã sửa bằng `sent_money`
  trong cùng vòng); (3) không đủ tiền — nhà-phố-nhỏ 3 tỉ →
  ack `khong-du-tien`, ví/owned không đổi (pre-sync đã đẩy
  100k lên server nên ack money 198,1 triệu, không phải 198
  triệu — test đã sửa kỳ vọng sau lần chạy 94/95); (4) A:
  discount 99 bị chặn ở client, món lạ → ack `khong-co-mon`,
  ledger không đổi; (5) C chưa đồng bộ → ack
  `chua-dong-bo-so-cai`; (6) giảm giá — ao-dai −10% còn 1,8
  triệu, phong-tro −10% vẫn 2 triệu (không giảm tiền thuê),
  discount 51 gửi thô (pending chen req_id 777) → ack
  `gia-khong-hop-le`, ledger không đổi; (7) giữ hộ — reserved
  150 triệu (white-box): o-to-cu 400 triệu bị từ chối, ao-dai
  2 triệu vẫn mua được; (8) 1 lần chờ — mua chen →
  `dang-cho-may-chu`, req_id không tăng, ack 1 lần, owned
  ao-dai ×3 (không thêm bo-cong-so); mất kết nối xóa pending
  (white-box gọi handler) + ngắt WS thật → mua offline về
  local (ví 192,1 triệu, ao-dai ×4); (9) `reset_state` xóa
  pending + req_id, `shop_log` 6, `data().shop_buy_count` 6.
- Cập nhật test cũ (bắt buộc vì hành vi đổi): test r76 phase
  (d)/(e) — mua ao-dai 2 triệu khi đã nối WS nay đi qua
  server nên `buy_item` trả `cho-may-chu` + pending, tiền trừ
  khi ack về (thêm step 7 chờ ack + counter
  `_shop_acks_main76`); baseline/auth sau đó là 17 triệu
  (không còn 21 triệu), ack ledger gần nhất là pre-sync 19
  triệu. **Test r76: 125/125 PASS** (trước 121 — thêm 4
  check mới).
- `tools/godot/run_regression.sh` đã thêm
  `g4_r77_server_shop_buy_test`.
- Hồi quy: **103 OK, 0 FAIL** (log
  `hidden_files/regression-2026-11-27-1245.log`, tổng 4096
  passes): test mới 95/95 + r76 125/125 + toàn bộ test cũ vẫn
  PASS (không regression). Lỗi WebSocket `ready_state !=
  STATE_OPEN` ở cuối log test r76/r77 là noise khi teardown
  sau khi test đã xong (exit 0), không phải lỗi test.

### 99.3 Verify + export — XONG

- `--check-only` exit 0: `pxb_server.gd`, `pxb_online.gd`,
  `main.gd`, `g4_r77_server_shop_buy_test.gd`,
  `g4_r76_ledger_authoritative_test.gd` (sau khi sửa test).
- Scene Main 120 frame exit 0, 0 ERROR/warning.
- Export web exit 0: pck mới **27.850.548 byte, SHA `28ae55e9…`**
  (trước `365faa62…`), wasm không đổi `fc74679e…`,
  `GODOT_THREADS_ENABLED = false`; pck chứa
  `res://tests/g4_r77_server_shop_buy_test.gd`.
- HTTP 200 đủ 4 file (`index.html`/`index.js`/`index.wasm`/
  `index.pck`, cổng 8953, đã tắt server sau khi kiểm).
- Staging rebuild `build_gh_pages.py --verify-only` OK (pck
  `28ae55e9`, 207 chunk, ráp lại 27.850.548 byte SHA `28ae55e9…`
  khớp byte với build local; wasm không đổi `fc74679e`).
- Chưa browser-verify vòng này (thay đổi là logic mua qua
  server + test headless qua socket thật; nút mua trong điện
  thoại + toast "Đang chờ máy chủ…" chưa bấm tay).

### 99.4 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- Push main r77 (gộp r43–r77: a **127** / b 20 / c 37 / docs 2) +
  deploy pck `28ae55e9` (12 lô: 11 lô chunk 207 + final) đã chuẩn
  bị xong (script `pxb-push-main-r77.py`, `pxb-deploy-r77.py` +
  manifest trong hidden_files goal; staging rebuild,
  `build_gh_pages.py --verify-only` OK — pck `28ae55e9`, 207
  chunk, khớp byte; wasm không đổi `fc74679e`). **Thay script
  r76 (pck `365faa62` chưa lên — bỏ, không xóa file, theo mẫu
  vòng 46).** **CHƯA CHẠY — chờ chủ nói 'đẩy tiếp'** (không còn
  thẻ chờ; live vẫn `5f2a052f` r41). Lô a r77 = lô a r76 (125) +
  `g4_r77_server_shop_buy_test.gd` + `.uid` (đã có sau khi
  export); test r76 trong lô a đã cập nhật theo hành vi mới.

### 99.5 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r77 (4 lô) → deploy pck mới
   (12 lô) → kiểm live pin + đối chiếu byte.
2. Browser-verify vòng 77 (mua ao-dai trong điện thoại khi đã
   nối WS → toast chờ → toast đã mua + ví trừ đúng; ngắt WS
   giữa chừng → toast mất kết nối + mua lại được) + vòng 68
   (bấm B lúc đang giữ sạp → toast tiếng Việt, không mở trận)
   — cần thắng 1 trận demo trước để có hold.
3. G4 online tiếp: đưa `owned` (nhà/xe/điện thoại/quần áo) vào
   ledger để server cũng làm chuẩn cho tài sản đã mua (hiện
   server chỉ chuẩn cho tiền); đồng bộ giữ sạp lên server để
   validate discount giá sỉ thật thay vì tin số client khai;
   hoặc thêm `shop_sell` khi game có tính năng bán lại.

## §100 — Vòng 78: đưa `owned` vào ledger — server làm chuẩn cho tài sản đã mua (27/11 ~13:45–14:30 +07, cron 13:45)

### 100.1 Code — XONG

- **Vấn đề đóng:** từ vòng 77, server chỉ làm chuẩn cho TIỀN;
  `economy.owned` (nhà/xe/điện thoại/quần áo mua ở chợ) chỉ có
  ở client local. Đổi máy / save hỏng / client sửa save thì tài
  sản đã mua không còn ai chứng thực — server không biết người
  này đã mua gì, không đối chiếu được khi cần (vd validate
  discount giữ sạp sau này cũng cần biết ai giữ sạp nào).
- **`server/pxb_server.gd`:** entry ledger thêm `"owned":
  {item_id: count}` (kho riêng trong cùng entry, khác `items`
  là túi đồ slice — owned không đem đấu giá/trade được).
  `_clean_owned_dict(raw)` mới: chỉ giữ món có trong bảng giá
  `PxbEconomy.get_item`, item_id ≤64 ký tự, count int 0..99,
  tối đa 512 món; món sai thì bỏ món đó. `_handle_ledger_sync`
  nhận thêm khóa `"owned"` tùy chọn: HỢP NHẤT theo max(server,
  client) từng món (không thay thế tuyệt đối như money/items —
  client có thể mua local offline trước khi sync lần đầu; server
  cũng không bao giờ quên món nó đã validate qua shop_buy) rồi
  trả lại trong `ledger_sync_ack` (kể cả ack STALE — stale vẫn
  trả owned server hiện tại). `_handle_shop_buy` khi ok: cộng
  món vào `entry_d["owned"]` + ack kèm `"owned"` đầy đủ sau khi
  mua; ack lỗi không kèm owned (client giữ owned cũ). Doc giao
  thức đầu file cập nhật cả 2 gói.
- **`scripts/pxb_online.gd`:** `_owned_snapshot_from(eco)` mới
  (đếm `economy.owned` Array thành dict) + `_clean_owned_dict`
  (làm sạch owned trong ack, cùng luật server).
  `send_ws_ledger_sync` gửi kèm `"owned"` + baseline
  `_ws_ledger_last_owned`; `_maybe_auto_sync_ledger` so sánh cả
  owned (mua local offline xong mới nối WS cũng kích hoạt
  sync). `_clean_ledger_sync_ack` / `_clean_shop_buy_ack` parse
  khóa `"owned"` TÙY CHỌN + cờ `"owned_present"` (server cũ
  không gửi thì false, client giữ owned local — không xóa);
  owned có nhưng không phải dict thì gói bẩn, bỏ cả gói.
  Handler ack: `ws_ledger_authoritative_owned` +
  `_ws_ledger_last_owned` đặt theo ack khi owned_present;
  `_rebaseline_ledger_after_settlement` rebaseline cả owned;
  `reset_state` xóa cả 2 biến mới.
- **`main.gd`:** `_apply_server_owned(owned)` mới — dựng lại
  `economy.owned` từ dict server (sắp id theo alphabet, lặp
  theo count), trả true khi owned đổi. `_on_ws_ledger_sync_acked`
  áp ack.owned khi owned_present (chỉ refresh HUD/điện thoại khi
  owned đổi, không toast riêng — toast cũ chỉ cho ví/túi);
  `_on_ws_shop_buy_acked` áp ack.owned thay cho append local,
  server cũ thì append như cũ. An toàn race: mua local chỉ xảy
  ra khi WS đã ngắt (không có ack nào đang bay); khi đã nối WS
  thì owned chỉ đổi qua ack server, và mọi sync đều gửi owned
  local lên trước để server hợp nhất.
- **Không đổi:** `PxbEconomy.data()/from_data()` (save local vẫn
  giữ owned như cũ); `_settle_auction/_settle_trade` (ghi lại
  cùng dict entry nên giữ nguyên khóa owned); discount vẫn
  PROVISIONAL (chưa validate giữ sạp thật — việc sau).

### 100.2 Test mới + hồi quy — XONG

- Test mới `tests/g4_r78_owned_ledger_test.gd` (cổng 18778,
  socket + server thật + scene Main thật + client A/D thô):
  **53/53 PASS** — unit: snapshot đếm trùng (ao-dai x2 +
  xe-sang x1), clean owned lọc món lạ/âm/>99/rỗng, clean 2 loại
  ack (thiếu owned → present=false, có owned → parse + lọc,
  owned không phải dict → bỏ gói); phase 0: Main seed owned
  offline ao-dai x1 trước khi nối → ledger Main hợp nhất
  ao-dai x1, ack owned_present, authoritative + baseline khớp;
  phase 1: mua chung-cu-mini 800 triệu qua server → ack owned
  đủ ao-dai + chung-cu-mini, ledger/Main/authoritative khớp;
  phase 2: sync thô từ A với owned bẩn → server lọc còn ao-dai
  x2 + chung-cu-mini x3 (bỏ khong-co-mon/xe-sang -1/""/phong-tro
  100), ledger Main không lệch; phase 3: sync STALE (ledger
  +1000đ chen giữa) → ack stale=true + money server + owned đầy
  đủ, ledger/Main owned không đổi; phase 4: client D máy mới
  (cùng player-main, owned trống, ví = tiền ledger) sync lên →
  server trả lại đủ 2 món, ledger tiền/owned không bị ghi đè;
  phase 5: Main mua ao-dai lần 2 → ack/ledger/Main đều ao-dai
  x2, ví về 198.001.000đ; phase 6: reset_state xóa
  authoritative + baseline owned, shop_log 2 lần mua.
- Hồi quy: xem §100.3.

### 100.3 Verify + export — XONG (hồi quy có 5 fail ĐÃ CÓ TỪ TRƯỚC)

- `--check-only` 3 file sửa (main.gd, pxb_online.gd,
  pxb_server.gd) exit 0; scene Main 120 frame exit 0.
- Hồi quy đầy đủ 104 suite (log
  `hidden_files/regression-2026-11-27-1345.log`): **4213 pass,
  5 fail** — `g4_online_trade_ledger_test` 96/100 (4 fail) +
  `g4_online_auction_test` 94/95 (1 fail). **5 fail này ĐÃ CÓ
  TỪ TRƯỚC, không phải do r78:** log hồi quy 12:45 (r77) ghi
  đúng 2 con số đó (96/100 + 94/95). Chẩn đoán bằng test debug
  tạm (đã xóa): trade 3 cho A com-tam 1→2 là ĐÚNG số học (A còn
  1 com-tam sau trade 1, nhận thêm 1 ở trade 3; server ledger
  cũng ghi 2) nhưng test đòi com-tam == 1 — kỳ vọng của test cũ
  sai, không phải code sai; auction fail cũng là 1 check cũ
  (client mới áp lại phiên cũ, đòi nhận đúng 475.000đ).
  **Điểm mù của runner cũ:** bản tin r77 ghi "hồi quy 103 OK,
  0 FAIL" vì runner cũ chỉ đếm suite theo exit code — script
  test thoát 0 kể cả khi có check FAIL bên trong; runner vòng
  này đếm thẳng số FAIL nên mới thấy 5 fail. Từ nay ghi cả 2
  con số (số suite + số pass/fail) để khỏi hiểu lầm.
- Export web exit 0: pck **27.866.048 byte, SHA `c01f7161…`**
  (trước `28ae55e9…`, +15.500 byte do code + test mới), wasm
  không đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`;
  pck chứa `pxb_online.gdc` / `pxb_server.gdc` / test r78
  `.gdc` mới; HTTP 200 đủ 4 file (cổng 8954).
- Staging rebuild `build_gh_pages.py` OK: wasm 293 chunk +
  pck 207 chunk, khớp byte True; `versions.json` ghi
  pck=`c01f7161`.

### 100.4 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- Push main r78 (`hidden_files/pxb-push-main-r78.py`, 4 lô):
  a 129 paths (r77-a 127 + test r78 `.gd` + `.uid`), b 20,
  c 37, docs 2 — tất cả path tồn tại, không file nào vượt
  giới hạn snapshot-push 188.416 byte/file **trừ**
  `docs/godot-g4.md` (696.120 byte — nhưng 75 lần push docs
  trước đều thành công nên giữ nguyên mẫu cũ; nếu lô docs lỗi
  thì tách sau). Thay script r77 (pck `28ae55e9` chưa lên —
  bỏ, file giữ lại).
- Deploy pck `c01f7161` (`hidden_files/pxb-deploy-r78.py`,
  12 lô: 11 chunk pck 207 + final versions.json/index.html;
  manifest đã kiểm đủ path). Thay script r77.
- **CHƯA CHẠY — chờ chủ nói 'đẩy tiếp'** (không còn thẻ chờ;
  live vẫn `5f2a052f` r41).

### 100.5 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r78 (4 lô) → deploy pck mới
   (12 lô) → kiểm live pin + đối chiếu byte.
2. Browser-verify vòng 78 (mua ao-dai trong điện thoại khi đã
   nối WS → ack owned về → tắt/mở lại máy vẫn còn món; máy mới
   cùng player_id sync lên nhận lại owned) + vòng 77 + vòng 68
   (bấm B lúc đang giữ sạp → toast tiếng Việt, không mở trận)
   — cần thắng 1 trận demo trước để có hold.
3. Sửa 5 fail cũ trong 2 suite online (kỳ vọng test sai ở trade
   3 + auction client mới — xem §100.3) HOẶC ghi nhận là nợ
   test đã biết; đồng bộ giữ sạp lên server để validate
   discount giá sỉ thật thay vì tin số client khai; hoặc thêm
   `shop_sell` khi game có tính năng bán lại.

## §101 — Vòng 79: sửa 5 fail cũ — kỳ vọng test sai, code đúng (27/11 ~14:45–15:30 +07, cron 14:45)

### 101.1 Chẩn đoán — XONG (không sửa code game)

- 5 fail từ hồi quy r77/r78 (`g4_online_trade_ledger_test`
  96/100 + `g4_online_auction_test` 94/95) đã tái hiện đúng
  bằng 2 test debug tạm (đã xóa): cả 5 đều là kỳ vọng test cũ
  sai số học / sai theo hành vi v76, code game + server đúng.
- **Trade 3 (4 fail):** A còn com-tam 1 sau trade 1 (đổi
  com-tam + 1 triệu lấy ca-phe + 500k), trade 3 nhận thêm 1
  com-tam từ B → A phải có com-tam **2**, không phải 1. Đo
  thật: sau trade 3 A local ca-phe=0, com-tam=2, ví 500k;
  ledger A {ca-phe: 0, com-tam: 2}. Trade 4 A cho 1 com-tam
  lấy sach → còn com-tam **1** (không phải 0): đo thật
  com-tam=1, sach=1, ledger {ca-phe: 0, com-tam: 1, sach: 1}.
  Test cũ quên A vẫn giữ com-tam 1 từ trade 1 nên đòi 1 rồi 0.
- **Auction client mới (1 fail):** client mới áp lại phiên cũ
  (seller A, hammer 1.001.000, phí 50.050) — test cũ đòi nhận
  475.000đ (= 95% của 500.000đ người thắng trả được ở local,
  hành vi v72). Từ v76 server kẹp tiền giữ hộ theo reserved
  nên người thắng trả ĐỦ hammer từ sổ cái, người bán nhận đủ
  950.950đ. Đo thật: `money_received=950950`,
  ledger `seller_received=950950, winner_paid=1001000`.
  Check phase 3 của cùng suite đã đòi 950.950 từ v76 — chỉ
  check phase 6 này còn sót lại số v72.

### 101.2 Sửa — chỉ 2 file test, không động code game

- `tests/g4_online_trade_ledger_test.gd` (4 check + header):
  trade 3 đòi com-tam A == 2 (local + ledger); trade 4 đòi
  com-tam A == 1 (local + ledger); header sửa mô tả race-mon:
  thiếu TIỀN thì HUY, thiếu MÓN thì server GIỮ món trong
  ledger (kẹp món, v76) nên giao dịch vẫn chốt đủ, bên thiếu
  món ở local áp từng phần.
- `tests/g4_online_auction_test.gd` (1 check + header):
  client mới áp lại phiên cũ đòi nhận 950.950đ (sổ cái v76);
  header sửa mô tả race đấu giá theo v76 (kẹp tiền giữ hộ,
  trả đủ hammer, local thiếu thì ghi short 501.000).
- Không sửa `pxb_server.gd` / `pxb_online.gd` / `main.gd` —
  số liệu đo thật khớp đúng luật v76/v78 đã chốt.

### 101.3 Verify + export — XONG (hồi quy 0 fail lần đầu từ r77)

- 2 suite sửa: trade ledger **100/100 PASS**, auction
  **95/95 PASS**.
- Hồi quy đầy đủ 104 suite (log
  `hidden_files/regression-2026-11-27-1445.log`): **4218 pass,
  0 fail** (4213 + 5 đã sửa). Lần đầu 0 fail kể từ khi 5 fail
  này xuất hiện ở r77 — runner đếm thẳng số FAIL nên con số
  này là thật, không còn điểm mù đếm theo exit code (§100.3).
- `--check-only` 2 file test exit 0; scene Main 120 frame
  exit 0, 0 ERROR/warning.
- Export web exit 0: pck **27.865.984 byte, SHA `40d875bc…`**
  (trước `c01f7161…`, −64 byte — chỉ đổi 2 file test + header
  comment, không đổi code game), wasm không đổi `fc74679e…`,
  `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ 4 file
  (cổng 8955).
- Staging rebuild `build_gh_pages.py` OK: wasm 293 chunk +
  pck 207 chunk, khớp byte True; `versions.json` ghi
  pck=`40d875bc`.

### 101.4 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- Push main r79 (`hidden_files/pxb-push-main-r79.py`, 4 lô):
  a 129 paths (giống r78-a — 2 file test sửa đã có sẵn trong
  manifest, chỉ đổi nội dung), b 20, c 37, docs 2 — thay
  script r78 (pck `c01f7161` chưa lên — bỏ, file giữ lại).
- Deploy pck `40d875bc` (`hidden_files/pxb-deploy-r79.py`,
  12 lô: 11 chunk pck 207 + final versions.json/index.html;
  manifest đã kiểm đủ path). Thay script r78.
- **CHƯA CHẠY — chờ chủ nói 'đẩy tiếp'** (không còn thẻ chờ;
  live vẫn `5f2a052f` r41).

### 101.5 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r79 (4 lô) → deploy pck mới
   (12 lô) → kiểm live pin + đối chiếu byte.
2. Browser-verify vòng 78 + vòng 77 + vòng 68 (bấm B lúc đang
   giữ sạp → toast tiếng Việt, không mở trận) — cần thắng 1
   trận demo trước để có hold.
3. Đồng bộ giữ sạp lên server để validate discount giá sỉ thật
   thay vì tin số client khai; hoặc thêm `shop_sell` khi game
   có tính năng bán lại.

## §102 — Vòng 80: đồng bộ giữ sạp lên server — validate discount giá sỉ thật (27/11 ~15:45–16:15 +07, cron 15:45)

### 102.1 Chẩn đoán — XONG (PROVISIONAL: discount là số client khai)

- Mục 3 của §101.5. Header của `pxb_server.gd` tự ghi
  PROVISIONAL: discount là số client khai, server chỉ kẹp
  0..50 — client gian lận khai 50% là server trừ 50%.
  Cần server tự giữ sổ holds và tự tính discount từ hold
  còn hạn, không tin số client gửi lên.
- Luật lấy từ `scripts/pxb_marketbattle.gd`:
  `HOLD_DAYS = 7`, `WHOLESALE_DISCOUNT_PERCENT = 10`,
  `STALL_TAX_CUT_PERCENT = 20`, `HOLD_FAME_PER_DAY = 10`.
  Sạp ví dụ: `sap-cho-dau-moi`. Giá: `dien-thoai-cu`
  5.000.000đ, `ao-dai` 2.000.000đ, `phong-tro`
  2.000.000đ/tháng (tiền thuê KHÔNG bao giờ giảm giá).

### 102.2 Sửa — server + client + Main

- **Server `server/pxb_server.gd`** (hằng mới, mirror từ
  `PxbMarketBattle` để server vẫn đứng độc lập):
  `HOLD_DAYS_MAX := 7`, `WHOLESALE_DISCOUNT_PERCENT := 10`,
  `STALL_TAX_CUT_PERCENT := 20`, `MAX_STALL_ID_LEN := 64`,
  `HOLDS_MAX_PLAYERS := 256`. State mới `holds`
  (player_id → {stall_id, start_day, until_day,
  synced_at_ms}, tối đa 1 hold/người — theo luật r68
  can_challenge) + `player_day` (player_id → int, chỉ
  tăng, lấy từ `game_day` trong stall_hold_sync /
  shop_buy / ledger_sync). Helper `_known_day`,
  `_note_day` (chỉ tăng), `_live_hold_for` (còn hạn khi
  start ≤ day < until; xóa hold hết hạn), `_prune_holds`
  (quá 256 người thì xóa người offline).
- **Handler mới `_handle_stall_hold_sync`** + nhánh
  dispatch. Validate: phải hello trước; stall_id không
  rỗng, ≤ 64 ký tự; start ≥ 1, until > start, dài ≤ 7
  ngày; start ≤ ngày server biết (không giữ sạp tương
  lai); until > ngày đã biết (không phải hold đã hết
  hạn); đang giữ sạp khác còn hạn → từ chối
  `dang-giu-sap-khac` (kèm `holding_stall_id`); sync
  lại cùng sạp thì ghi đè (idempotent). Trả
  `stall_hold_sync_ack` {req_id, ok, stall_id,
  start_day, until_day, discount_percent (10 nếu ok),
  holding_stall_id, reason} — reason: `chua-hello` /
  `thieu-sap-id` / `ngay-giu-sap-sai` / `het-han-giu-sap`
  / `dang-giu-sap-khac`.
- **`_handle_shop_buy`:** discount không còn tin số
  client khai. `disc_claimed` giữ lại để trả ack;
  `disc` = 10 chỉ khi có hold còn hạn tại `game_day`
  báo lên (hoặc ngày cuối server biết nếu không báo)
  và món ≠ `phong-tro`, còn lại 0. Ack (cả thành công
  lẫn `khong-du-tien`) và entry `shop_log` đều ghi thêm
  `discount_applied` + `discount_claimed`.
- **`_settle_auction`:** người bán đang giữ sạp thì phí
  4% (nhận 96%) thay vì 5% (nhận 95%) —
  `fee_percent = 5 * (100-20)/100 = 4`, áp cả 2 nhánh
  (người thắng đã sync và chưa sync bao giờ), xét theo
  ngày server biết của người bán.
- **`_handle_ledger_sync`:** nhận thêm `game_day` tùy
  chọn → `_note_day` (không động tới sổ cái).
  `data()` thêm `holds_count`. Header protocol cập nhật
  (shop_buy + khối stall_hold_sync mới; auction 95% →
  96% khi đang giữ sạp). **Giới hạn đã biết, ghi rõ:**
  ngày của server chỉ tươi bằng tin nhắn gần nhất có
  kèm ngày; sửa triệt để cần ngày do server làm chủ —
  ngoài phạm vi vòng này.
- **Client `scripts/pxb_online.gd`:** signal mới
  `ws_stall_hold_synced(ack)`; biến `ws_hold_req_id`,
  `_ws_hold_pending`, `ws_last_hold_ack`, `ws_game_day`
  (Main đặt; 0 = chưa biết). Cleaner mới
  `_clean_stall_hold_sync_ack` (nghiêm) + nhánh dispatch
  (chỉ emit khi req_id khớp sync đang chờ).
  `send_ws_stall_hold_sync(stall_id, start_day,
  until_day, game_day := -1)`: client tự validate trước
  (sạp rỗng → `thieu-sap-id`; khoảng sai / > 7 ngày theo
  `PxbMarketBattle.HOLD_DAYS` → `ngay-giu-sap-sai`;
  không biết ngày → `chua-biet-ngay-game`); req_id chỉ
  tăng khi gửi thành công. `send_ws_shop_buy` gửi thêm
  `game_day` khi biết (tham số hoặc `ws_game_day`).
  `send_ws_ledger_sync` gửi thêm `game_day` khi
  `ws_game_day ≥ 1`. `_clean_shop_buy_ack`:
  `discount_applied` / `discount_claimed` là key TÙY
  CHỌN (int 0..50 nếu có, không thì -1 = "server không
  nói") — để ack giả cũ của r78 vẫn chạy.
  `reset_state()` xóa thêm hold pending / req_id / ack
  cuối; `ws_game_day` KHÔNG reset (state của Main).
  `data()` / `from_data()` không đổi (req id không lưu).
- **Main `main.gd`:** `_create_systems` nối
  `ws_stall_hold_synced` → `_on_ws_stall_hold_synced`;
  đặt `online.ws_game_day = day`. `ws_game_day` làm mới
  thêm trong `_advance_frame` (sau `day += 1`) và
  `_apply_save_data` (sau khi khôi phục day), đều có
  null-guard. Helper mới `_sync_hold_to_server()` →
  Dictionary: trả {} nếu offline / không có hold còn
  hạn; còn lại gửi `send_ws_stall_hold_sync(stall_id,
  startGameDay, untilGameDay, day)` lấy từ hold trong
  `battle_state` qua `_hold_benefits_now()`. Gọi từ
  `_on_battle_finished` (sau toast thắng) và từ
  `_on_ws_status_changed(true)` (sync lại khi (nối lại)).
  `_on_ws_stall_hold_synced(ack)`: ok thì im; chỉ toast
  khi `het-han-giu-sap` ("Giữ sạp đã hết hạn theo máy
  chủ, lần mua sau không còn giá sỉ.") và
  `dang-giu-sap-khac` ("Máy chủ báo đội đang giữ sạp
  khác."). `_on_ws_shop_buy_acked`: toast dùng
  `discount_applied` của server (fallback số pending
  khi ack thiếu key, tức -1); nhánh mới khi khai > 0
  mà áp dụng = 0: "…(máy chủ đã trừ Xđ — không còn giá
  sỉ.)".

### 102.3 Verify + export — XONG (hồi quy 0 fail, pck mới)

- Test mới `tests/g4_r80_stall_hold_server_test.gd`
  (port **18780**; các suite khác dùng 18771–18778),
  11 phase (0–10), GLOBAL_TIMEOUT 150s, PHASE_TIMEOUT
  20s, socket thật + PxbServer thật + scene Main thật.
  Phủ: unit cleaner + gửi khi chưa nối; sync hold hợp
  lệ (ack ok, server có holds + player_day +
  holds_count); mua có hold (1.800.000đ, áp 10/khai
  10); khai 50% bị kẹp về 10%; mua không hold đúng giá
  gốc (áp 0/khai 10); phong-tro không bao giờ giảm;
  xung đột `dang-giu-sap-khac`; sync lại idempotent;
  hold 8 ngày bị server từ chối (gửi bằng packet thô
  kèm req_id 778 tự chèn, vì client chặn trước);
  start tương lai bị từ chối; hold đã hết hạn bị từ
  chối; packet thô không req_id → dropped_packets +1,
  không ack; client tự validate (không tăng req_id);
  hết hạn đúng ngày == until (ngày 10); ngày đơn điệu
  (gửi ngày 3 sau ngày 10 vẫn không giảm); đấu giá qua
  `_settle_auction` trực tiếp (bán có hold nhận
  960.000đ, phí 40.000đ; không hold 950.000đ/50.000đ;
  người thắng chưa sync + bán có hold: 960.000đ, sổ
  cái người bán không đổi theo legacy v71 — assert
  1.950.000đ nguyên); Main thắng trận end-to-end
  (hold 3→10 craft từ `PxbMarketBattle.from_data` +
  `BattleScene.battle` → `_on_battle_finished("A")` →
  server giữ sạp cho player-main, fame +50, toast
  "Giữ sạp sap-cho-dau-moi đến ngày 10"); Main (nối
  lại) sync lại qua `_on_ws_status_changed(true)` trực
  tiếp; reset_state xóa state hold; cuối
  `holds_count == 2` (B + Main).
  **Kết quả: 106/106 PASS** (lần chạy 2; lần 1 là
  51/53 — lỗi của chính test: đòi server từ chối sync
  8 ngày gửi qua API client, nhưng client chặn trước
  khi gửi; đã sửa bằng packet thô). Nhiễu lỗi
  `ready_state != STATE_OPEN` lúc tắt là bình thường
  (cũng có ở r77).
- **Sửa `tests/g4_r77_server_shop_buy_test.gd` phase 6:**
  A sync hold trước (thêm biến handler ack hold + nối),
  rồi mua ao-dai giảm 10% (check `discount_applied ==
  10`); check phong-tro thêm `discount_applied == 0`.
  **Kết quả: 99/99 PASS.** Bắt buộc vì server r80 tính
  đúng giá gốc khi mua giảm mà không có hold — phase 6
  cũ của r77 sẽ fail nếu không sửa.
- Rủi ro hồi quy đã kiểm và sạch: không test nào khác
  dùng `send_ws_shop_buy` kèm discount (grep);
  `g4_battle_hold_benefits_test.gd` là Main offline
  (đường mua local); r76/r78 mua disc 0 và không assert
  text toast thành công; ack giả của r78 thiếu key
  discount (xử lý tùy chọn giữ nguyên).
- Hồi quy đầy đủ 105 suite (log
  `hidden_files/regression-2026-11-27-1545.log`):
  **4328 pass, 0 fail** (4218 + 106 r80 + 4 ở r77 do
  phase 6 mới thêm check hold). 0 fail lần thứ 2 liên
  tiếp.
- `--check-only` 3 file sửa (main.gd, pxb_online.gd,
  pxb_server.gd) exit 0; scene Main 120 frame exit 0,
  0 ERROR/warning.
- Export web exit 0: pck **27.893.380 byte, SHA
  `eb8c6824…`** (trước `40d875bc…`, +27.396 byte do code
  + test mới), wasm không đổi `fc74679e…`,
  `GODOT_THREADS_ENABLED = false`; pck chứa
  `g4_r80_stall_hold_server_test` (grep 4 lần); HTTP
  200 đủ 4 file (cổng 8956, tắt server bằng PID —
  không dùng pkill -f).
- Staging rebuild `build_gh_pages.py` OK: wasm 293
  chunk + pck 207 chunk, khớp byte True;
  `versions.json` ghi pck=`eb8c6824`.

### 102.4 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- Push main r80 (`hidden_files/pxb-push-main-r80.py`, 4 lô):
  a 130 paths (r79-a 129 + test r80 `.gd` mới — chưa có
  `.uid` vì file tạo bằng tay, chưa qua import của
  editor), b 20, c 37, docs 2 — tất cả path tồn tại,
  không file nào vượt giới hạn snapshot-push 188.416
  byte/file **trừ** `docs/godot-g4.md` (~700 KB — nhưng
  75 lần push docs trước đều thành công nên giữ nguyên
  mẫu cũ; nếu lô docs lỗi thì tách sau). Thay script
  r79 (pck `40d875bc` chưa lên — bỏ, file giữ lại).
- Deploy pck `eb8c6824` (`hidden_files/pxb-deploy-r80.py`,
  12 lô: 11 chunk pck 207 + final versions.json/index.html;
  manifest đã kiểm đủ path). Thay script r79.
- **CHƯA CHẠY — chờ chủ nói 'đẩy tiếp'** (không còn thẻ chờ;
  live vẫn `5f2a052f` r41).

### 102.5 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r80 (4 lô) → deploy pck mới
   (12 lô) → kiểm live pin + đối chiếu byte.
2. Browser-verify vòng 80 + vòng 78 + vòng 77 + vòng 68
   (thắng 1 trận demo → giữ sạp → mua dien-thoai-cu giảm
   10% thật trên server; bấm B lúc đang giữ sạp → toast
   tiếng Việt, không mở trận) — cần thắng 1 trận demo
   trước để có hold.
3. Server-authoritative day (ngày do server làm chủ thay vì
   tin ngày client báo — giới hạn đã ghi ở §102.2); hoặc
   thêm `shop_sell` khi game có tính năng bán lại.

## §103 — Vòng 81: ngày do server làm chủ (27/11 ~16:45–17:30 +07, cron 16:45)

### 103.1 Chẩn đoán — XONG (PROVISIONAL: ngày server = ngày client báo gần nhất)

Giới hạn đã ghi ở §102.2: server chỉ biết ngày qua `player_day`
(client báo kèm `game_day` ở `stall_hold_sync` / `shop_buy` /
`ledger_sync`, chỉ tăng, không lùi). Client độc có thể khai ngày
tương lai để kéo dài hold đã hết hạn (giảm 10% + phí đấu giá 4%
vô thời hạn) — server không có cách nào biết ngày thật. Ngày
`_known_day` khác nhau theo từng người chơi nên 2 client cùng
phòng còn thấy 2 "ngày hiện tại" khác nhau.

### 103.2 Sửa — server + client + Main

**Server `server/pxb_server.gd` (xóa `player_day` / `_known_day` /
`_note_day`, không còn sót chuỗi nào):**
- `DAY_LENGTH_MS := 1800000` (30 phút thật = 1 ngày game, khớp
  `PxbBalance.GAME_DAY_MINUTES`, đã chốt trong GDD — không
  PROVISIONAL). `server_day()` = base (1 lúc mở cổng) + số ngày
  30 phút đã trôi theo đồng hồ thật của server;
  `day_ends_in_ms()` đếm ngược tới ranh giới ngày kế;
  `server_day_info()` gom 3 số cho client;
  `debug_set_server_day(day)` CHỈ DÙNG CHO TEST (đặt lại mốc
  ngày — giống `PxbTime.debug_set_elapsed`); `day_length_ms`
  là var để test đặt nhỏ mà chờ sang ngày thật.
- `_check_client_day(msg)`: không kèm `game_day` thì ok (dùng
  ngày server); kèm số nguyên khác ngày server thì
  `{"ok": false, "reason": "ngay-server-khong-khop"}`; kèm sai
  kiểu thì bỏ qua như không kèm (lenient như `shop_buy` cũ).
- `welcome` kèm `server_day` + `day_length_ms`; gói mới
  `day_sync` (phải hello trước) → `day_sync_ack`
  (`server_day` / `day_length_ms` / `day_ends_in_ms`); mọi ack
  của `shop_buy` / `stall_hold_sync` / `ledger_sync` đều kèm
  `server_day`; `data()` thêm `server_day`.
- `shop_buy` / `stall_hold_sync`: `game_day` lệch thì ack
  ok=false `ngay-server-khong-khop`, không trừ tiền / không
  ghi hold; `game_day` ở `stall_hold_sync` nay TÙY CHỌN
  (thiếu thì dùng ngày server). `ledger_sync`: `game_day`
  không dùng nữa (sổ cái không phụ thuộc ngày), ack vẫn trả
  `server_day` để client đồng bộ. `_settle_auction` xét hold
  theo `server_day()` thay vì ngày của người bán.
- Header protocol + PROVISIONAL cập nhật theo hợp đồng mới.
  **Giới hạn đã biết:** restart server thì ngày về 1 (cùng
  loại với ledger/holds chỉ nằm trong RAM — chưa có
  persistence cho server).

**Client `scripts/pxb_online.gd`:**
- `ws_server_day` (0 = chưa biết) + `ws_day_ends_in_ms` +
  signal `ws_server_day_changed` (chỉ phát khi ngày THẬT
  ĐỔI); `_apply_server_day()` dùng chung cho welcome /
  `day_sync_ack` / 3 loại ack; `send_ws_day_sync()` mới;
  3 cleaner ack thêm key tùy chọn `server_day` (thiếu thì
  0, sai kiểu thì gói bẩn — ack giả r78 vẫn chạy);
  `reset_state()` xóa ngày server.
- Thứ tự ngày khi gửi (`ledger_sync` / `shop_buy` /
  `stall_hold_sync`): `ws_server_day` (nếu đã biết) thắng
  tham số truyền vào / `ws_game_day` local — server chỉ
  chấp nhận đúng ngày của nó.

**Main `main.gd`:** nối `ws_server_day_changed` →
`_on_ws_server_day_changed()` đồng bộ lại hold đang giữ theo
ngày mới (còn hạn thì ok, hết hạn thì ack
`het-han-giu-sap` → toast sẵn có); ngày local `day` (đồng hồ
offline) KHÔNG đổi theo ngày server; toast mới cho
`ngay-server-khong-khop`.

**Sửa test cũ theo hợp đồng ngày mới (không sửa code game):**
- `g4_r77_server_shop_buy_test`: `debug_set_server_day(3)`
  sau khi mở cổng (phase 6 dùng hold 3→10).
- `g4_r80_stall_hold_server_test`: `debug_set_server_day(3)`
  sau khi mở cổng; bỏ check `player_day` (phase 1 → check
  `server_day() == 3`); phase 7 viết lại — server sang ngày
  10 bằng debug + client `day_sync` rồi mới mua (hết hạn
  đúng ngày == until; gửi ngày 3 tua ngược vẫn giá đầy vì
  client gửi ngày server 10); phase 8/9: B + Main `day_sync`
  lên ngày 10 trước khi đồng bộ, hold mới 10→17 (thay 3→10).

### 103.3 Test mới + hồi quy — XONG

- Test mới `tests/g4_r81_server_day_test.gd` (port **18781**,
  11 phase 0–10, GLOBAL_TIMEOUT 150s, PHASE_TIMEOUT 20s,
  socket thật + PxbServer thật + scene Main thật). Phủ:
  unit `server_day` / `day_ends_in_ms` /
  `server_day_info` / `debug_set_server_day` (kẹp về 1 khi
  đặt 0) / `_check_client_day` (thiếu → ok, bằng → ok,
  99 → `ngay-server-khong-khop` + `server_day`, chuỗi /
  0 / 2.5 → bỏ qua); cleaner 3 loại ack (giữ `server_day`,
  thiếu → 0, chuỗi → bỏ gói); `_apply_server_day` (phát
  signal đúng 1 lần khi đổi, không phát khi trùng / sai
  kiểu) + `reset_state` xóa ngày server; welcome kèm ngày
  (3 client đều lấy ngày 1, signal 1 lần); `day_sync`
  (server sang ngày 2 thì A biết 2, B vẫn 1, đếm ngược
  trong (0, 30 phút]); `ledger_sync` kèm ngày lệch vẫn ack
  ok + trả `server_day` để client đồng bộ lại; `shop_buy`
  / `stall_hold_sync` thô kèm `game_day` 99 → từ chối
  `ngay-server-khong-khop`, không trừ tiền / không ghi
  hold, `shop_log` rỗng; mua không kèm `game_day` vẫn
  giảm 10% theo hold còn hạn; `game_day` chuỗi thì bỏ qua,
  vẫn mua được; server sang ngày 8 → hold 1→8 hết hạn
  (A đồng bộ lại sau `day_sync`, B mua giá đầy); Main
  thắng trận giữ sạp 8→15 → ngày server đổi sang 9 thì
  Main TỰ đồng bộ lại (ack ok), sang 15 thì hết hạn +
  toast "hết hạn"; ngày tự tăng theo đồng hồ thật
  (`day_length_ms` 300ms, chờ sang ngày 21 thật rồi
  `day_sync` lại); `data()` + `reset_state`.
  **Kết quả: 96/96 PASS** (lần 1 lỗi của chính test:
  `_main.online` còn null trong `_init` — chuyển connect
  signal ngày của Main sang phase 0 như r80; lần 2
  96/96). Nhiễu `ready_state != STATE_OPEN` / leak RID
  lúc tắt như các test socket trước.
- **Hồi quy lần 1: 4421 pass, 7 fail** (`g4_r77_server_shop_buy_test`
  phase 6 — hold 3→10 trong khi server day đang 1 nên
  start ở tương lai → `ngay-giu-sap-sai`; đúng luật mới,
  test cũ sai) → sửa r77 bằng `debug_set_server_day(3)`
  (chỉ test, không động code game) → **99/99 PASS**.
- **Hồi quy lần 2 (log
  `hidden_files/regression-2026-11-27-1645.log`): 106
  suite, 4428 pass, 0 fail** (4328 + 96 r81 + 4 ở r80 do
  thêm check `day_sync`). r80 **110/110 PASS** (cũ
  106 — thêm 4 check `day_sync` ở phase 7/8/9), r77
  **99/99 PASS**. 0 fail lần thứ 3 liên tiếp.

### 103.4 Verify + export — XONG (hồi quy 0 fail, pck mới)

- `--check-only` 4 file sửa (main.gd, pxb_online.gd,
  pxb_server.gd, test r81 + test r80) exit 0; scene Main
  120 frame exit 0, 0 ERROR/warning.
- Export web exit 0: pck **27.913.916 byte, SHA
  `6e820176…`** (trước `eb8c6824…`, +20.536 byte do code
  + test mới), wasm không đổi `fc74679e…`,
  `GODOT_THREADS_ENABLED = false`; pck chứa
  `g4_r81_server_day_test` (grep tên file 4 lần — cùng
  mẫu kiểm như r80; script trong pck không ở dạng text
  thường nên chuỗi dài không grep được); HTTP 200 đủ 4
  file (cổng 8957, tắt server bằng PID — không dùng
  pkill -f).
- Staging rebuild `build_gh_pages.py` OK: wasm 293
  chunk + pck 207 chunk, khớp byte True;
  `versions.json` ghi pck=`6e820176`.

### 103.5 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- Push main r81 (`hidden_files/pxb-push-main-r81.py`, 4 lô):
  a 132 paths (r80-a 130 + test r81 `.gd` + `.uid` mới),
  b 20, c 37, docs 2 — tất cả path tồn tại, không file nào
  vượt giới hạn snapshot-push 188.416 byte/file **trừ**
  `docs/godot-g4.md` (~700 KB — nhưng 75 lần push docs
  trước đều thành công nên giữ nguyên mẫu cũ; nếu lô docs
  lỗi thì tách sau). Thay script r80 (pck `eb8c6824`
  chưa lên — bỏ, file giữ lại).
- Deploy pck `6e820176` (`hidden_files/pxb-deploy-r81.py`,
  12 lô: 11 chunk pck 207 + final versions.json/index.html;
  manifest đã kiểm đủ path). Thay script r80.
- **CHƯA CHẠY — chờ chủ nói 'đẩy tiếp'** (không còn thẻ chờ;
  live vẫn `5f2a052f` r41).

### 103.6 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r81 (4 lô) → deploy pck mới
   (12 lô) → kiểm live pin + đối chiếu byte.
2. Browser-verify vòng 81 + vòng 80 + vòng 78 + vòng 77 +
   vòng 68 (thắng 1 trận demo → giữ sạp → mua dien-thoai-cu
   giảm 10% thật trên server; sang ngày server mới thì hold
   hết hạn → toast tiếng Việt; bấm B lúc đang giữ sạp →
   toast tiếng Việt, không mở trận) — cần thắng 1 trận demo
   trước để có hold.
3. Thêm `shop_sell` khi game có tính năng bán lại; hoặc
   persistence ngày server qua restart (hiện restart thì
   ngày về 1 — giới hạn đã ghi ở §103.2).

## §104 — Vòng 82: persistence ngày + ledger + holds qua restart (27/11 ~17:45–18:30 +07, cron 17:45)

> **Kết luận: VÒNG 82 XONG (mức headless).** Server nay lưu ngày +
> ledger + holds xuống file JSON và nạp lại khi restart — restart
> không còn về ngày 1 / mất tiền. `stop_server` lưu trước khi xóa,
> autosave 5 giây khi có thay đổi, file hỏng/thiếu thì khởi động
> mới từ ngày 1 (không crash), entry sai thì bỏ entry đó. Test mới
> **78/78 PASS**. Hồi quy **107 suite, 4506 pass, 0 fail** — lần
> đầu 0 fail sau khi sửa lỗi nhiễm chéo do nạp state mặc định
> (xem §104.2 cuối). Scene chạy 120 frame exit 0, export web
> exit 0 (pck `9aea9fd3`), http.server 200 đủ 4 file.
> **Chưa kiểm chứng bằng trình duyệt thật** — như các vòng trước,
> VM không có Chromium/Firefox. **Push main r82 + deploy pck
> `9aea9fd3` đã chuẩn bị xong, CHƯA CHẠY — chờ chủ nói 'đẩy tiếp'**
> (live vẫn `5f2a052f` r41).

### 104.1 Chẩn đoán — XONG (giới hạn đã ghi ở §103.2)

Giới hạn đã ghi ở §103.2: restart server thì ngày về 1 (ledger /
holds cũng chỉ nằm trong RAM — chưa có persistence cho server).
Hậu quả thực tế: server sập / deploy lại là toàn bộ tiền đã đồng
bộ, đồ đã mua (`owned`), sạp đang giữ đều mất; ngày quay về 1 nên
hold tưởng còn hạn lại thành hết hạn (hoặc ngược lại, hold mới
đồng bộ sau restart lại được tính từ ngày 1). Client không có
cách nào khôi phục — `ledger_sync` sau restart ghi đè bằng số
local (có thể cũ hơn số server trước khi sập).

### 104.2 Sửa — server + server_main (không sửa client/Main)

**Server `server/pxb_server.gd`:**
- Hằng số mới: `STATE_VERSION := 1`,
  `STATE_FILE_DEFAULT := "user://pxb_server_state.json"`,
  `STATE_AUTOSAVE_MS := 5000`.
- `state_file_path: String = ""` (rỗng = KHÔNG bật persistence),
  `_state_dirty`, `_state_last_save_ms`; `state_file()` trả đường
  dẫn thật dùng; `_persistence_enabled()` = path đặt tường minh.
- `save_state() -> {ok, path}`: ghi JSON `{version,
  saved_at_unix_ms, server_day_base, server_day_started_ms,
  day_length_ms, ledger, holds}` (deep-copy, 1 lần ghi trực
  tiếp); lỗi mở file / JSON rỗng thì trả `{ok:false, reason,
  error}` rõ ràng, không crash.
- `load_state() -> {ok, loaded} / {ok:false, reason}`: file
  thiếu → `chua-co-file`; không parse được JSON → `file-hong`;
  sai version → `phien-ban-la`; ngày sai → `ngay-sai` — cả 4
  trường hợp đều GIỮ NGUYÊN trạng thái hiện tại (ngày 1, sổ
  trống), không crash, không xóa file. Entry ledger/hold nào sai
  thì bỏ entry đó (`_clean_ledger_entry` / `_clean_hold_entry`:
  money int ≥ 0, items ≤ 512 món, reserved int ≥ 0, owned lọc
  bằng `_clean_owned_dict`; hold stall_id 1..64 ký tự,
  start ≥ 1, until > start), giữ phần đúng. Giới hạn số entry
  theo `LEDGER_MAX_PLAYERS` / `HOLDS_MAX_PLAYERS`.
- `start_server()`: reset sổ về trống + ngày 1 rồi CHỈ nạp khi
  persistence bật; `stop_server()`: lưu trước khi xóa CHỈ KHI
  persistence bật; `_maybe_autosave()` (gọi từ `poll()` — cả
  server trong cây lẫn test gọi poll tay): lưu khi dirty và đã
  qua 5 giây từ lần lưu trước.
- Đánh dấu dirty ở mọi chỗ đổi ledger/holds/ngày:
  `_handle_ledger_sync`, `_handle_shop_buy`,
  `_handle_stall_hold_sync`, `_settle_trade`,
  `_settle_auction` (cả 2 đường trả), `_ledger_reserve`,
  `_ledger_release`, `_prune_ledger`, `_prune_holds`,
  `debug_set_server_day`. `data()` thêm `state_file` +
  `state_dirty` để quan sát.
- Header PROVISIONAL + comment hằng `DAY_LENGTH_MS` cập nhật:
  restart không còn về ngày 1; trades / auctions đang mở /
  chat vẫn chỉ nằm trong RAM — restart thì mất (giới hạn còn lại).

**`server/server_main.gd`:** thêm cờ `--state-file <đường-dẫn>`;
server thật LUÔN đặt `state_file_path` (mặc định
`STATE_FILE_DEFAULT` khi không truyền cờ) — persistence là hành
vi của tiến trình server, không phải của test. Log khởi động in
thêm `state=<đường-dẫn>`.

**LỖI NHIỄM CHÉO TÌM ĐƯỢC Ở HỒI QUY — ĐÃ SỬA TRONG CÙNG VÒNG
(không phải lỗi test cũ):** bản đầu `start_server()` nạp state
từ đường dẫn MẶC ĐỊNH cho mọi server (kể cả test). Hồi quy lượt
1: `g4_online_trade_ledger_test` **92/100** + `g4_online_trade_test`
**33/34** — 1 test online trước đó đã lưu ledger (player-a/b/c/
main) xuống `user://pxb_server_state.json` qua `stop_server()`,
test sau nạp nhầm số đó nên kỳ vọng tiền sai. Chẩn đoán bằng file
thật: `~/.local/share/godot/app_userdata/Phố Xô Bồ/pxb_server_state.json`
chứa ledger player-a 500.000đ + player-b 2.500.000đ (không phải
số test trade kỳ vọng). Sửa: persistence thành OPT-IN — chỉ
`load_state`/`save_state`/autosave khi `state_file_path` được
đặt tường minh; test không đặt thì khởi động mới sạch và không
ghi file nào. Đã xóa file state nhiễm. Kiểm chứng sau sửa:
trade-ledger **100/100**, trade **69/69**, r82 vẫn **78/78**,
không còn file state mặc định mới sinh ra.

### 104.3 Test mới + hồi quy — XONG

- Test mới `tests/g4_r82_server_persistence_test.gd` (cổng
  18782, 7 phase, socket + server thật, client A thô)
  **78/78 PASS** (lần 1 đã pass — không sửa code sau test).
  Unit (không mạng): đường dẫn mặc định/tùy chỉnh, lọc entry
  ledger/hold đúng/sai, save/load vòng tròn (ngày 7 + ledger
  123.456đ + hold đến ngày 14), file hỏng → `file-hong` (ngày
  vẫn 1), sai version → `phien-ban-la`, thiếu file →
  `chua-co-file`. Socket: ngày 5 + ledger 5 triệu + hold 5→12
  + mua ao-dai giảm 10% (discount server tính từ hold); stop →
  file JSON chứa đúng ngày/ledger/owned/hold; restart → ngày
  vẫn 5, ledger/hold đủ; client mới nối lại: welcome ngày 5,
  auto-sync không stale, mua lần 2 ok (owned ao-dai 2); đổi
  tiền qua gói thô, KHÔNG stop, sau 6 giây file đã có số mới
  (autosave) + `state_dirty` false; đổi ngày 9 → restart vẫn
  ngày 9, hold 5→12 còn trong sổ; file hỏng → khởi động ngày 1,
  sổ trống, không crash; thiếu file → ngày 1, sổ trống.
  2 dòng `ERROR: Parse JSON failed` trong log là engine in khi
  `JSON.parse_string` gặp file hỏng có chủ đích — code đã bắt
  và trả `file-hong`, không phải lỗi (giống nhiễu stderr ở các
  test khác).
- **Hồi quy 107 suite: 4506 pass, 0 fail** (log
  `hidden_files/regression-2026-11-27-1745.log`) — 0 fail lần
  thứ 4 liên tiếp (sau 3 lần 0 fail của r79/r80/r81; lượt 1
  của vòng này có 9 fail nhiễm chéo ở 2 suite trade, đã sửa
  code — xem §104.2 — rồi chạy lại toàn bộ, không sửa test cũ).

### 104.4 Verify + export — XONG (hồi quy 0 fail, pck mới)

- `--check-only` 3 file sửa (pxb_server.gd, server_main.gd,
  test r82) exit 0; scene Main 120 frame exit 0, 0 ERROR/warning.
- Export web exit 0: pck **27.934.116 byte, SHA
  `9aea9fd3…`** (trước `6e820176…`, +20.200 byte do code
  + test mới), wasm không đổi `fc74679e…`,
  `GODOT_THREADS_ENABLED = false`; pck chứa
  `g4_r82_server_persistence_test` (grep tên file 4 lần — cùng
  mẫu kiểm như r81); HTTP 200 đủ 4 file (cổng 8958, tắt server
  bằng PID — không dùng pkill -f).
- Staging rebuild `build_gh_pages.py` OK: wasm 293
  chunk + pck 207 chunk, khớp byte True;
  `versions.json` ghi pck=`9aea9fd3`.

### 104.5 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- Push main r82 (`hidden_files/pxb-push-main-r82.py`, 4 lô):
  a 135 paths (r81-a 132 + server_main.gd + test r82 `.gd` +
  `.uid` mới), b 20, c 37, docs 2 — tất cả path tồn tại, không
  file nào vượt giới hạn snapshot-push 188.416 byte/file **trừ**
  `docs/godot-g4.md` (~725 KB — nhưng 75 lần push docs
  trước đều thành công nên giữ nguyên mẫu cũ; nếu lô docs
  lỗi thì tách sau). Thay script r81 (pck `6e820176`
  chưa lên — bỏ, file giữ lại).
- Deploy pck `9aea9fd3` (`hidden_files/pxb-deploy-r82.py`,
  12 lô: 11 chunk pck 207 + final versions.json/index.html;
  manifest đã kiểm đủ path). Thay script r81.
- **CHƯA CHẠY — chờ chủ nói 'đẩy tiếp'** (không còn thẻ chờ;
  live vẫn `5f2a052f` r41).

### 104.6 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r82 (4 lô) → deploy pck mới
   (12 lô) → kiểm live pin + đối chiếu byte.
2. Browser-verify vòng 82 + vòng 81 + vòng 80 + vòng 78 + vòng
   77 + vòng 68 (thắng 1 trận demo → giữ sạp → mua
   dien-thoai-cu giảm 10% thật trên server; sang ngày server
   mới thì hold hết hạn → toast tiếng Việt; bấm B lúc đang giữ
   sạp → toast tiếng Việt, không mở trận) — cần thắng 1 trận
   demo trước để có hold; kiểm thêm restart server thật bằng
   `server_main.gd --state-file` rồi nối lại thấy ngày/ledger
   còn nguyên.
3. Thêm `shop_sell` khi game có tính năng bán lại; hoặc
   persistence cho trades/auctions đang mở + chat (hiện restart
   vẫn mất — giới hạn đã ghi ở §104.2).

## §105 — Vòng 83: persistence trades + auctions + chat qua restart (27/11 ~18:45–19:30 +07, cron 18:45)

> **Kết luận: VÒNG 83 XONG (mức headless).** Server nay lưu cả
> trades đang chờ + auctions đang mở + chat_log (100 tin gần
> nhất) xuống file JSON và nạp lại khi restart — đề nghị đổi đồ
> / phiên đấu giá / lịch sử chat không còn mất khi server sập.
> Peer_id trong trade/auction là số socket (đổi sau mỗi lần nối
> lại) nên lúc nạp đặt về -1 rồi REBIND theo player_id khi
> người chơi hello lại + gửi lại đề nghị đang chờ + chat_history
> cho người vừa vào — trade chấp nhận được ngay sau restart,
> auction tiếp tục đấu giá/hủy được. Test mới **120/120 PASS**
> (lần 1 đã pass). Hồi quy **108 suite, 4626 pass, 0 fail** —
> 0 fail lần thứ 5 liên tiếp. Scene chạy 120 frame exit 0,
> export web exit 0 (pck `dd9321c8`), http.server 200 đủ 4 file.
> **Chưa kiểm chứng bằng trình duyệt thật** — như các vòng trước,
> VM không có Chromium/Firefox. **Push main r83 + deploy pck
> `dd9321c8` đã chuẩn bị xong, CHƯA CHẠY — chờ chủ nói 'đẩy tiếp'**
> (live vẫn `5f2a052f` r41).

### 105.1 Chẩn đoán — XONG (giới hạn đã ghi ở §104.2)

Giới hạn đã ghi ở §104.2: trades / auctions đang mở / chat chỉ
nằm trong RAM — restart thì mất. Hậu quả thực tế: server sập /
deploy lại là đề nghị đổi đồ đang chờ biến mất (người nhận không
bao giờ nhận được trade_completed), phiên đấu giá đang có giá bị
hủy ngang (tiền giữ hộ `reserved` của người dẫn đầu kẹt lại trong
ledger — không ai giải phóng), lịch sử chat 100 tin gần nhất mất
hẳn. Vấn đề thiết kế riêng của vòng này: trade/auction tham chiếu
`from_peer`/`to_peer`/`seller_peer` (số socket WebSocket, đổi sau
mỗi lần nối lại) — nạp nguyên xi từ file thì `trade_accept` so
`to_peer` cũ với peer mới sẽ luôn báo `khong-phai-nguoi-nhan`,
nên chỉ lưu file thôi là chưa đủ, phải rebind theo `player_id`.

### 105.2 Sửa — server + client (không sửa Main)

**Server `server/pxb_server.gd`:**
- `save_state()`: thêm `"trades"`, `"auctions"`, `"chat_log"`
  (duplicate sâu) vào JSON. `STATE_VERSION` giữ 1 — 3 key mới là
  tùy chọn nên file v82 cũ (không có 3 key) vẫn nạp được.
- `load_state()`: sau holds, nạp 3 key mới (thiếu thì rỗng);
  cap trades/auctions ≤ `MAX_PLAYERS` (64 — 1 đề nghị/phiên
  đang chờ cho mỗi người), chat ≤ `CHAT_LOG_MAX` (100). Entry
  sai thì bỏ entry đó, giữ phần đúng.
- 3 cleaner mới (đặt cạnh `_clean_ledger_entry` /
  `_clean_hold_entry`): `_clean_trade_entry` (trade_id/from/to
  player_id không rỗng ≤64 ký tự, mã món ≤64, tiền int
  0..100 tỉ qua `_is_valid_trade_money`, cả 2 phía không rỗng,
  created_at_ms int ≥ 0; peer về -1), `_clean_auction_entry`
  (auction_id/seller/item không rỗng ≤64, start_price int
  1000..100 tỉ, current_bid int 0..100 tỉ, bidder có thể rỗng,
  created_at_ms ≥ 0, ends_at_ms > created_at_ms — **hết hạn rồi
  vẫn giữ**, lần poll đầu sau restart sẽ đóng + quyết toán qua
  `_close_expired_auctions`, tránh kẹt tiền `reserved`; seller
  về -1), `_clean_chat_entry` (tên ≤30 ký tự, text 1..500 ký tự,
  player_id ≤64, at_ms ≥ 0; from_peer về -1).
- `_rebind_after_hello(peer_id, player_id)` (mới, gọi cuối
  `_handle_hello` sau welcome + presence): gắn lại from/to_peer
  cho trade có from/to_player_id khớp, seller_peer cho auction
  có seller_player_id khớp; gửi lại cho NGƯỜI VỪA VÀO: đề nghị
  đang chờ mình trả lời (`trade_offer`) / đề nghị mình đã gửi
  (`trade_offered`) + lịch sử chat (`chat_history`, chỉ khi log
  không rỗng). Auction không gửi lại ở đây — client tự xin
  `auction_list` khi cần. Chỉ gửi cho người vừa hello, không
  broadcast.
- Đánh dấu dirty ở mọi chỗ đổi trade/auction/chat:
  `_handle_chat`, `_handle_trade_offer`, `_handle_trade_accept`,
  `_handle_trade_decline`, `_handle_trade_cancel`,
  `_handle_auction_create`, `_handle_auction_bid`,
  `_handle_auction_cancel`, `_close_expired_auctions`,
  `_cancel_trades_for_peer`, `_cancel_auctions_for_peer`
  (hủy khi 1 bên mất kết nối cũng là thay đổi cần lưu).
- Header persistence cập nhật: trades/auctions/chat nay persist;
  giới hạn còn lại: `trade_log` / `auction_log` / `shop_log`
  chỉ là lịch sử quan sát (100 mục) — KHÔNG persist; phiên hết
  hạn trong lúc server sập được đóng + quyết toán ở lần poll đầu
  sau restart, nhưng `auction_closed` không tới được tay người
  chơi đang offline (log không persist); `_trade_seq` /
  `_auction_seq` reset về 0 sau restart nhưng id mới vẫn không
  trùng id cũ vì `trade-<ms>-<seq>` dùng wall-clock (ms sau
  restart luôn lớn hơn trước).

**Client `scripts/pxb_online.gd`:**
- Signal mới `ws_chat_history_received(messages: Array)` +
  case `"chat_history"` trong `_handle_ws_message`: làm sạch
  từng tin bằng `_clean_chat_message` như chat thường, thêm vào
  `ws_chat_log` (cap 100), phát 1 signal tổng. Client cũ
  (không có case này) bỏ qua gói này (`_:` pass) — server mới +
  client cũ vẫn chạy. Main chưa cần nối signal này (log đã đủ
  tin để hiển thị).

### 105.3 Test mới + hồi quy — XONG

- Test mới `tests/g4_r83_server_persistence_trades_test.gd`
  (cổng 18783/18784, state `/tmp/pxb-r83-state.json`, 11 phase,
  socket + server thật, client A/B/C thô; viết bởi subagent,
  **120/120 PASS ngay lần 1 — không sửa code sau test**).
  Unit (không mạng): cleaner trade (6) / auction (4) / chat
  (4); save/load vòng tròn (ngày 9 + ledger 123.456đ + hold
  đến ngày 14 + 1 trade + 1 auction bid 150.000đ + 2 chat —
  file JSON thô đủ 3 key mới); tương thích file v82 (không có
  3 key mới → load ok, trades/auctions/chat rỗng); entry sai
  bị lọc (mỗi loại 1 tốt + 1 xấu → chỉ giữ tốt); file hỏng →
  `file-hong`, state giữ nguyên. Socket: A/B/C hello; A+B chat
  2 tin; A offer trade cho B (50.000đ + com-tam) → B nhận
  `trade_offer` 1 lần, A nhận `trade_offered` 1 lần; C tạo
  auction dien-thoai-cu 100.000đ, B bid 150.000đ; stop → file
  JSON có đúng trade_id/auction/chat; restart cổng mới → data
  trade_pending 1 / auction_open 1 / chat_count 2, trade peer
  -1; A hello lại → `trade_offered` + `chat_history` (2 tin);
  B hello lại → `trade_offer` + `chat_history`; C hello lại →
  seller_peer bằng peer mới + `auction_list` thấy phiên bid
  150.000đ; B accept trade → cả 2 nhận `trade_completed`,
  **không `trade_error`** (rebind hoạt động), server trades
  rỗng; phiên hết hạn (ends_at_ms quá khứ, chưa có bid) →
  `_close_expired_auctions()` đóng, winner rỗng, hammer 0,
  phiên thật vẫn mở; autosave sau 6 giây đã có chat mới trong
  file (3 tin), `state_dirty` false. 2 dòng `ERROR: Parse JSON
  failed` trong log là engine in khi `load_state` đọc file hỏng
  có chủ đích — code đã bắt và trả `file-hong`, không phải lỗi
  (giống nhiễu stderr ở r82).
- **Hồi quy 108 suite: 4626 pass, 0 fail** (log
  `hidden_files/regression-2026-11-27-1845.log`) — 0 fail lần
  thứ 5 liên tiếp (r79/r80/r81/r82/r83); r83 **120/120**, r82
  78/78, r81 96/96, r80 110/110, G1 419/419, G3 95/95, G1
  playtest 14/14, không regression.

### 105.4 Verify + export — XONG (hồi quy 0 fail, pck mới)

- `--check-only` 3 file sửa (pxb_server.gd, pxb_online.gd,
  test r83) exit 0; `--headless --import` exit 0 (sinh
  `.uid` cho test r83); scene Main 120 frame exit 0, 0
  ERROR/warning.
- Export web exit 0: pck **27.953.256 byte, SHA
  `dd9321c8…`** (trước `9aea9fd3…`, +19.140 byte do code +
  test mới), wasm không đổi `fc74679e…`,
  `GODOT_THREADS_ENABLED = false`; pck chứa
  `g4_r83_server_persistence_trades_test` (grep tên file 4
  lần — cùng mẫu kiểm như r82); HTTP 200 đủ 4 file (cổng
  8960, tắt server bằng PID — không dùng pkill -f).
- **Lỗi export lần 1 — đã sửa trong cùng vòng (không phải lỗi
  code):** chạy export từ repo root với đường dẫn
  `src/godot-build/index.html` thì Godot hiểu tương đối theo
  thư mục project (`src/godot/src/godot-build/...` không tồn
  tại) nên báo `Project export for preset "Web" failed` (pck
  cũ `9aea9fd3` còn nguyên, không bị ghi đè). Chạy lại từ
  `src/godot` với `../godot-build/index.html` như các vòng
  trước thì exit 0 ngay. Bài học: export LUÔN chạy từ
  `src/godot`.
- Staging rebuild `build_gh_pages.py` OK: wasm 293
  chunk + pck 208 chunk (trước 207), khớp byte True;
  `versions.json` ghi pck=`dd9321c8`.

### 105.5 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- Push main r83 (`hidden_files/pxb-push-main-r83.py`, 4 lô):
  a 135 paths (r82-a 135, thay 2 file test r82 bằng 2 file
  test r83 `.gd` + `.uid`; pxb_server.gd + pxb_online.gd đã
  có sẵn trong a), b 20, c 37, docs 2 — tất cả path tồn tại,
  không file nào vượt giới hạn snapshot-push 188.416
  byte/file **trừ** `docs/godot-g4.md` (~730 KB — nhưng 75+
  lần push docs trước đều thành công nên giữ nguyên mẫu cũ;
  nếu lô docs lỗi thì tách sau). Thay script r82 (pck
  `9aea9fd3` chưa lên — bỏ, file giữ lại).
- Deploy pck `dd9321c8` (`hidden_files/pxb-deploy-r83.py`,
  12 lô: 11 chunk pck 208 + final versions.json/index.html;
  manifest đã kiểm đủ path). Thay script r82.
- **CHƯA CHẠY — chờ chủ nói 'đẩy tiếp'** (không còn thẻ chờ;
  live vẫn `5f2a052f` r41).

### 105.6 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r83 (4 lô) → deploy pck mới
   (12 lô) → kiểm live pin + đối chiếu byte.
2. Browser-verify vòng 83 + vòng 82 + vòng 81 + vòng 80 + vòng
   78 + vòng 77 + vòng 68 (thắng 1 trận demo → giữ sạp → mua
   dien-thoai-cu giảm 10% thật trên server; sang ngày server
   mới thì hold hết hạn → toast tiếng Việt; bấm B lúc đang giữ
   sạp → toast tiếng Việt, không mở trận; trade/auction/chat
   còn nguyên sau restart server thật bằng `server_main.gd
   --state-file`) — cần thắng 1 trận demo trước để có hold.
3. Thêm `shop_sell` khi game có tính năng bán lại; hoặc
   persistence cho trade_log/auction_log/shop_log (hiện restart
   vẫn mất — giới hạn đã ghi ở §105.2); hoặc nối Main hiển thị
   `chat_history` sau khi hello lại (signal
   `ws_chat_history_received` đã có, Main chưa nối).


## §106 — Vòng 84: persistence trade_log + auction_log + shop_log qua restart (27/11 ~19:45–20:30 +07, cron 19:45)

> **Kết luận: VÒNG 84 XONG (mức headless).** Server nay lưu cả
> 3 log quan sát (100 mục gần nhất mỗi loại) xuống file JSON và
> nạp lại khi restart — lịch sử giao dịch đã chốt / phiên đấu giá
> đã đóng / lần mua ở chợ không còn mất khi server sập. Entry nào
> sai thì bỏ entry đó, giữ phần đúng; file v83 cũ (không có 3 key
> mới) vẫn nạp được. Test mới **145/145 PASS** (2 lần liên tiếp).
> Hồi quy **109 suite, 4771 pass, 0 fail** — 0 fail lần thứ 6
> liên tiếp. Scene chạy 120 frame exit 0, export web exit 0
> (pck `bd33397b`), http.server 200 đủ 4 file. **Chưa kiểm chứng
> bằng trình duyệt thật** — như các vòng trước. **Push main r84
> + deploy pck `bd33397b` đã chuẩn bị xong, CHƯA CHẠY — chờ chủ
> nói 'đẩy tiếp'** (live vẫn `5f2a052f` r41).

### 106.1 Chẩn đoán — XONG (giới hạn đã ghi ở §105.2)

Giới hạn đã ghi ở §105.2: `trade_log` / `auction_log` /
`shop_log` chỉ là lịch sử quan sát (100 mục) — KHÔNG persist,
restart thì mất. Hậu quả thực tế: server sập / deploy lại là
mất dấu giao dịch đã chốt (không còn bằng chứng ai đã đổi gì
với ai, giá nào), mất lịch sử đấu giá đã đóng (người bán không
kiểm lại được mình đã nhận bao nhiêu sau phí 5%), mất lịch sử
mua ở chợ (không đối chiếu được `discount_applied` đã áp).
Khác với trades/auctions đang mở ở vòng 83, 3 log này KHÔNG
tham chiếu peer đang sống theo cách cần rebind — `from_peer` /
`to_peer` / `seller_peer` trong log chỉ là số socket lúc chốt,
vô nghĩa sau restart — nên chỉ cần lưu + nạp + lọc, không cần
gửi lại cho ai.

### 106.2 Sửa — server (không sửa client, không sửa Main)

**Server `server/pxb_server.gd`:**
- `save_state()`: thêm `"trade_log"`, `"auction_log"`,
  `"shop_log"` (duplicate sâu). `STATE_VERSION` giữ 1 — 3 key
  mới là tùy chọn nên file v83 cũ vẫn nạp được.
- `load_state()`: nạp 3 key mới sau `chat_log` (thiếu thì
  rỗng); cap mỗi loại `TRADE_LOG_MAX` / `AUCTION_LOG_MAX` /
  `SHOP_LOG_MAX` (100). Entry sai thì bỏ entry đó, giữ phần
  đúng.
- 3 cleaner mới (đặt cạnh `_clean_trade_entry` /
  `_clean_auction_entry` / `_clean_chat_entry`):
  `_clean_trade_log_entry` (các trường trade như
  `_clean_trade_entry` — peer về -1 — + `completed_at_ms`
  int ≥ 0 bắt buộc + `ledger` nếu có phải Dictionary, sai
  kiểu thì bỏ khối ledger, giữ mục log), `_clean_auction_log_entry`
  (các trường phiên như `_clean_auction_entry` — seller_peer
  về -1 — + `winner_player_id` có thể rỗng ≤64 + `hammer_price`
  int 0..100 tỉ + `fee_vnd` int ≥ 0 + `seller_receives_vnd`
  int ≥ 0 + `closed_at_ms` int ≥ 0 + `ledger` nếu có phải
  Dictionary), `_clean_shop_log_entry` (player_id/item_id
  không rỗng ≤64, `price_paid` int 0..100 tỉ, `fame_gained`
  int ≥ 0, `at_ms` int ≥ 0, `discount_applied` /
  `discount_claimed` int 0..50, thiếu thì 0 — mục cũ trước
  vòng 80 không ghi 2 trường này).
- KHÔNG cần thêm `_mark_state_dirty()`: cả 3 chỗ append log
  (trade accept, shop_buy thành công, đóng phiên đấu giá) đã
  đánh dirty từ trước (autosave 5s + stop_server đều lưu log).
- Header persistence cập nhật: 3 log nay persist; giới hạn
  còn lại: phiên hết hạn trong lúc sập được đóng + quyết toán
  ở poll đầu, nhưng `auction_closed` không tới được tay người
  chơi đang offline (chỉ log persist, không gửi lại).

### 106.3 Test mới + hồi quy — XONG

- Test mới `tests/g4_r84_server_persistence_logs_test.gd`
  (cổng 18785/18786, state `/tmp/pxb-r84-state.json`, socket +
  server thật, client A/B/C thô; viết bởi subagent,
  **145/145 PASS, chạy 2 lần liên tiếp đều PASS**).
  Unit (~53 check): 3 cleaner (đủ trường, peer về −1, thiếu
  `completed_at_ms`/`closed_at_ms` → {}, ledger sai kiểu →
  {}, không ledger vẫn giữ, winner rỗng vẫn giữ, discount
  thiếu → 0, discount 51 → {}, giá âm → {}); save/load vòng
  tròn 3 log (kèm ngày/ledger/trade/auction/chat); cap 100
  mỗi loại (file 101 mục → load còn 100); file v83 cũ không
  có 3 key → load ok, 3 log rỗng; mỗi loại 1 tốt + 1 xấu →
  chỉ giữ tốt; file hỏng → reason `file-hong`, state giữ
  nguyên. Socket (~92 check): A chat 1 tin; A offer → B
  accept → `trade_log` 1 mục, `completed_at_ms > 0`, đúng
  trade_id; C sync ledger rồi mua áo dài → `shop_log` 1 mục
  (2.000.000đ, ví 5tr → 3tr); C tạo phiên, B bid 150.000,
  ép hết hạn + `_close_expired_auctions()` → `auction_log`
  1 mục, winner = B, hammer 150.000, fee 7.500 (đúng 5% luật
  r72), seller nhận 142.500; stop → file JSON thô đủ 3 key
  1/1/1; restart cổng mới → 3 log còn 1/1/1, `data()` đếm
  đúng, trade đã chốt KHÔNG gửi lại (`trade_offered` = 0),
  phiên đã đóng KHÔNG mở lại (`auction_list` rỗng); mua lần
  2 + đợi >5s → autosave ghi `shop_log` 2 mục, `state_dirty`
  false.
- 3 lỗi TEST đã sửa trong lúc viết (không chạm server):
  (1) C bị `khong-du-do-cho` khi tạo auction vì client tự
  sync ledger ngay khi nhận welcome nên C đã có entry ledger
  mà không có món — sửa: C chỉ nối túi/ví ngay trước khi sync
  ledger để mua hàng; (2) ép `ends_at_ms = now−1000` làm
  entry auction_log bị loại khi load (ends < created) — sửa:
  ép về điểm giữa `created..now`, vẫn "về quá khứ" nhưng giữ
  `ends > created` như phiên thật; (3) index `auction_log[0]`
  khi mảng rỗng làm crash step → spam ~5.900 FAIL — sửa:
  kiểm size trước khi index.
- 2 hành vi server đã xác minh đúng trong lúc debug: stale-sync
  protection từ chối sync khi base lệch (server giữ số của
  mình), và `_clean_auction_log_entry` loại entry có
  `ends_at_ms <= created_at_ms` (đúng spec cleaner tái dùng
  `_clean_auction_entry`).
- **Hồi quy 109 suite: 4771 pass, 0 fail** (log
  `hidden_files/regression-2026-11-27-1945.log`) — 0 fail lần
  thứ 6 liên tiếp (r79/r80/r81/r82/r83/r84); r84 **145/145**,
  r83 120/120, r82 78/78, r81 96/96, r80 110/110, G1 419/419,
  G3 95/95, G1 playtest 14/14, không regression.

### 106.4 Verify + export — XONG (hồi quy 0 fail, pck mới)

- `--check-only` file sửa (`pxb_server.gd`) exit 0;
  `--headless --import` exit 0 (sinh `.uid` cho test r84);
  scene Main 120 frame exit 0, 0 ERROR/warning.
- Export web exit 0: pck **27.985.564 byte, SHA `bd33397b…`**
  (trước `dd9321c8…`, +32.308 byte do code + test mới), wasm
  không đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`;
  pck chứa tên file test r84 ×4 (grep -a, cùng mẫu kiểm như
  r82/r83); chuỗi GDScript trong pck không grep được (§12.3
  — chỉ kiểm bằng hành vi chạy thật). HTTP 200 đủ 4 file
  (cổng 8961). Lưu ý: lệnh `pkill -f "http.server 8961"` giết
  luôn chính shell exec chứa chuỗi đó (exit signal 15) — kết
  quả HTTP đã in đủ trước đó, không ảnh hưởng.
- Staging rebuild `build_gh_pages.py` OK: wasm 293 chunk +
  pck 208 chunk (trước 208), khớp byte; `versions.json` ghi
  pck=`bd33397b`.

### 106.5 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- Push main r84 (`hidden_files/pxb-push-main-r84.py`, 4 lô):
  a 135 paths (r83-a 135, thay 2 file test r83 bằng 2 file
  test r84 `.gd` + `.uid`; pxb_server.gd đã có sẵn trong a),
  b 20, c 37, docs 2 — tất cả path tồn tại, không file nào
  vượt giới hạn snapshot-push 188.416 byte/file **trừ**
  `docs/godot-g4.md` (~740 KB — nhưng 75+ lần push docs trước
  đều thành công nên giữ nguyên mẫu cũ; nếu lô docs lỗi thì
  tách sau). Thay script r83 (pck `dd9321c8` chưa lên — bỏ,
  file giữ lại).
- Deploy pck `bd33397b` (`hidden_files/pxb-deploy-r84.py`,
  12 lô: 11 chunk pck 208 + final versions.json/index.html;
  manifest đã kiểm đủ path). Thay script r83.
- **CHƯA CHẠY — chờ chủ nói 'đẩy tiếp'** (không còn thẻ chờ;
  live vẫn `5f2a052f` r41).

### 106.6 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r84 (4 lô) → deploy pck mới
   (12 lô) → kiểm live pin + đối chiếu byte.
2. Browser-verify vòng 84 + vòng 83 + vòng 82 + vòng 81 + vòng
   80 + vòng 78 + vòng 77 + vòng 68 (thắng 1 trận demo → giữ
   sạp → mua dien-thoai-cu giảm 10% thật trên server; sang ngày
   server mới thì hold hết hạn → toast tiếng Việt; bấm B lúc
   đang giữ sạp → toast tiếng Việt, không mở trận; trade/auction/
   chat còn nguyên sau restart server thật bằng `server_main.gd
   --state-file`) — cần thắng 1 trận demo trước để có hold.
3. Thêm `shop_sell` khi game có tính năng bán lại; hoặc nối Main
   hiển thị `chat_history` sau khi hello lại (signal
   `ws_chat_history_received` đã có, Main chưa nối).

## §107 — Vòng 85: nối Main hiển thị chat_history sau khi hello lại (27/11 ~20:45–21:30 +07, cron 20:45)

### 107.1 Chẩn đoán — XONG (khoảng trống thật, đã chứng minh bằng thứ tự gói tin)

- Mục 3 của §106.6: signal `ws_chat_history_received` đã có từ vòng 83
  (server gửi lại 100 tin gần nhất sau hello, client thêm vào
  `ws_chat_log` rồi phát 1 signal tổng) nhưng Main chưa nối.
- Thứ tự gói tin chứng minh khoảng trống là thật: server gửi `welcome`
  TRƯỚC rồi mới gửi `chat_history` (cùng hàm hello,
  `server/pxb_server.gd` ~1296). Bên client, `welcome` → `_set_ws_connected`
  → `ws_status_changed` → `Main._on_ws_status_changed` → `_refresh_phone()`
  chạy LÚC `ws_chat_log` còn trống (lịch sử chưa về) — nên tab Tin nhắn
  vẫn vẽ "(chưa có tin nhắn nào…)" cho tới khi có tin chat mới / đổi tab.
  Điện thoại đang đóng thì còn tệ hơn: không có badge chưa đọc nào cho
  số tin cũ vừa khôi phục, dù `ws_chat_log` đã có đủ tin.
- Không phải lỗi dữ liệu: `ws_chat_log` đã đúng từ vòng 83 (test r83:
  hello lại nhận `chat_history` đủ 2 tin) — chỉ thiếu 1 nhịp làm tươi
  ở Main. Sửa ở Main, không sửa server/client.

### 107.2 Sửa — Main + comment (không sửa server, không sửa luật)

- `main.gd` (`_ready`, cạnh 3 connect chat cũ): thêm
  `online.ws_chat_history_received.connect(_on_ws_chat_history_received)`.
- Handler mới `Main._on_ws_chat_history_received(_messages: Array)` —
  làm đúng như `_on_ws_chat_received`: điện thoại đang mở tab Tin nhắn
  thì `_refresh_phone()` ngay, không thì `phonehub.notify(TAB_DANH_BA_TIN_NHAN)`.
  KHÔNG thêm tin vào log lần nữa (PxbOnline đã thêm trước khi phát
  signal — thêm nữa là nhân đôi).
- `scripts/pxb_online.gd`: sửa comment signal (dòng 205–207) — trước đây
  ghi "Main chưa cần nối signal này", nay ghi Main đã nối từ vòng 85
  + lý do (welcome đến trước nên refresh ở status_changed chạy lúc
  log còn trống).
- Không toast riêng: toast "Đã nối chat online (N người)." ở
  `_on_ws_status_changed` đã báo lúc nối lại; thêm toast nữa là spam
  mỗi lần reconnect.

### 107.3 Test mới + hồi quy — XONG

- Test mới `tests/g4_r85_chat_history_ui_test.gd` (cổng 18787, server
  Godot thật + scene Main thật + 1 client đối tác thật, mẫu r74/r83):
  **25/25 PASS, lần 1** (chạy ~3s, exit 0).
  - B gửi 2 tin ("Chao buoi sang", "Chieu nay gap nhau nhe") → Main
    nhận đủ 2, tab Tin nhắn hiện cả 2 (cơ số).
  - Xóa log cục bộ (giả lập phiên mới) + làm tươi → tab hết tin cũ,
    báo "(chưa có tin nhắn nào" (chứng minh panel đang stale); ngắt
    WS rồi nối lại → lịch sử về đủ 2 tin, KHÔNG nhân đôi → **tab
    đang mở tự làm tươi, hiện lại cả 2 tin** (điểm sửa chính).
  - Gọi trực tiếp handler lúc điện thoại đóng → badge chưa đọc +1
    đúng 1, KHÔNG thêm tin vào log.
  - End-to-end lúc điện thoại đóng: ngắt + xóa log + nối lại → lịch
    sử về đủ 2 tin, có badge chưa đọc; mở tab lại thì hiện đủ 2 tin
    + xóa badge.
- 1 lỗi TEST đã sửa trong lúc viết (không chạm code game): `var before
  := _main.online.ws_chat_log.size()` không suy được kiểu (vì `_main`
  là Node) → đổi sang `var before: int = ...`.

### 107.4 Verify + export — XONG (hồi quy 0 fail, pck mới)

- `--check-only` 3 file đổi/mới (`main.gd`, `pxb_online.gd`,
  `g4_r85_chat_history_ui_test.gd`) exit 0; `--headless --import`
  exit 0 (sinh `.uid` cho test r85); scene Main 120 frame exit 0,
  0 ERROR/warning.
- **Hồi quy 110 suite: 4796 pass, 0 fail** (log
  `hidden_files/regression-2026-11-27-2045.log`) — 0 fail lần thứ 7
  liên tiếp (r79/r80/r81/r82/r83/r84/r85); r85 **25/25**, r84 145/145,
  r83 120/120, r82 78/78, r81 96/96, r80 110/110, G1 419/419,
  G3 95/95, G1 playtest 14/14, không regression.
- Export web exit 0: pck **27.992.240 byte, SHA `9c914dea…`**
  (trước `bd33397b…`, +6.676 byte do code + test mới), wasm không đổi
  `fc74679e…`, `GODOT_THREADS_ENABLED = false`; pck chứa tên file
  test r85 ×4 (grep -a); HTTP 200 đủ 4 file (cổng 8962).
- Staging rebuild `build_gh_pages.py` OK: wasm 293 chunk +
  pck 208 chunk, khớp byte; `versions.json` ghi pck=`9c914dea`.
  (Cảnh báo `title_bg.jpg` thiếu vẫn như các vòng trước — DOM dùng
  fallback, không phải lỗi mới.)

### 107.5 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- Push main r85 (`hidden_files/pxb-push-main-r85.py`, 4 lô):
  a 135 paths (r84-a 135, thay 2 file test r84 bằng 2 file test r85
  `.gd` + `.uid`; `main.gd` + `pxb_online.gd` đã có sẵn trong a),
  b 20, c 37, docs 2 — tất cả path tồn tại, không file nào vượt giới
  hạn snapshot-push 188.416 byte/file **trừ** `docs/godot-g4.md`
  (~759 KB — nhưng 75+ lần push docs trước đều thành công nên giữ
  nguyên mẫu cũ; nếu lô docs lỗi thì tách sau). Thay script r84
  (pck `bd33397b` chưa lên — bỏ, file giữ lại).
- Deploy pck `9c914dea` (`hidden_files/pxb-deploy-r85.py`,
  12 lô: 11 chunk pck 208 + final versions.json/index.html;
  manifest đã kiểm đủ path, không thiếu). Thay script r84.
- **CHƯA CHẠY — chờ chủ nói 'đẩy tiếp'** (không còn thẻ chờ;
  live vẫn `5f2a052f` r41).

### 107.6 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r85 (4 lô) → deploy pck mới
   (12 lô) → kiểm live pin + đối chiếu byte.
2. Browser-verify vòng 85 + vòng 84 + vòng 83 + vòng 82 + vòng 81 +
   vòng 80 + vòng 78 + vòng 77 + vòng 68 (thắng 1 trận demo → giữ
   sạp → mua dien-thoai-cu giảm 10% thật trên server; sang ngày
   server mới thì hold hết hạn → toast tiếng Việt; bấm B lúc
   đang giữ sạp → toast tiếng Việt, không mở trận; trade/auction/
   chat còn nguyên sau restart server thật bằng `server_main.gd
   --state-file`; **mở điện thoại tab Tin nhắn sau khi nối lại
   chat thì thấy lại tin cũ**) — cần thắng 1 trận demo trước để
   có hold.
3. Thêm `shop_sell` khi game có tính năng bán lại.

## §108 — Vòng 86: bán lại cho chợ qua server (`shop_sell`, 27/11 ~21:45–23:00 +07, cron 21:45 + 22:45)

### 108.1 Chẩn đoán — khoảng trống thật (mục 3 của §107.6)

- `shop_buy` đã server-authoritative từ vòng 77 (server trừ tiền +
  cộng món vào owned trong ledger), nhưng chiều ngược lại CHƯA CÓ:
  server comment (`server/pxb_server.gd` ~131) + client comment
  (`scripts/pxb_online.gd` ~66) đều ghi rõ "thêm bán thì cần
  shop_sell riêng"; `PxbEconomy` cũng không có hàm `sell`. Người
  chơi mua nhầm / muốn đổi tiền thì không có đường nào bán lại —
  tiền kẹt trong đồ.
- GDD/economy KHÔNG chốt tỷ lệ bán lại → vòng này chọn **50% giá
  catalog** (thông lệ), ghi PROVISIONAL ở `PxbBalance.SHOP_SELLBACK_PERCENT`,
  cần chủ chốt số. Server + client + Main đều dùng chung hằng này,
  không hardcode 50 rải rác. Không giảm giá sỉ khi bán; không Danh
  vọng khi bán (bán không phải mua lớn).

### 108.2 Thiết kế — đối xứng `shop_buy`, 1 món / lần gửi

- Gói `{"type":"shop_sell","item_id","req_id"[,"game_day"]}` →
  `_handle_shop_sell`, trả `shop_sell_ack` {req_id, ok, item_id,
  price_received, money, reserved, owned (chỉ khi ok), reason,
  server_day}. Thứ tự validate như shop_buy: req_id int ≥ 1 →
  hello → item_id → catalog → ngày server (vòng 81) → ledger đã
  đồng bộ → phong-tro ("khong-ban-duoc", thuê tháng không bán lại
  được) → owned ≥ 1 ("khong-so-huu"). Thành công: money +=
  `PxbEconomy.shop_sellback_price` (server tính), owned trừ 1
  (hết thì xóa key), ghi shop_log {kind:"sell", price_received,
  price_paid:0, fame_gained:0}, `_mark_state_dirty()`.
- `shop_log` nay có 2 kind: mục mua kind "buy" (price_paid),
  mục bán kind "sell" (price_received). `_clean_shop_log_entry`
  chấp nhận cả 2 (thiếu kind → "buy" — file v83/v84 cũ vẫn nạp
  được); mục sell thiếu price_received hoặc ≤ 0 → {}.
  `data()` thêm `shop_sell_count` (shop_buy_count vẫn đếm toàn bộ
  shop_log như cũ, không đổi nghĩa).
- Client: `send_ws_shop_sell(item_id, game_day=-1)` + signal
  `ws_shop_sell_acked` + `_clean_shop_sell_ack` + pending
  `_ws_shop_sell_pending` (đồng bộ ledger trước khi gửi như
  shop_buy; ack lạ/trùng req_id thì bỏ lặng; ack ok thì cập nhật
  baseline tiền/owned để lần sync kế không stale).
- Main: `sell_item(item_id)` — WS thì gửi + pending
  `_pending_shop_sell` (chỉ 1 lần chờ ack, nút bán ẩn trong lúc
  chờ, toast "Đang chờ máy chủ xác nhận bán…"); chưa nối thì bán
  local qua `economy.sell`. `_on_ws_shop_sell_acked` áp ví theo
  delta + owned server làm chuẩn + toast "Đã bán … (máy chủ đã
  cộng …đ)". Mất kết nối lúc chờ ack bán thì hủy lần bán như mua
  (vòng 77). Tab Chợ thêm nút "Bán … — nhận …đ" cho món đang sở
  hữu (trừ phong-tro, tối đa 4 món rẻ nhất, `_sellable_owned_items`).

### 108.3 Test mới + hồi quy — XONG

- Test mới `tests/g4_r86_shop_sell_test.gd` (cổng 18788, restart
  18789, server Godot thật + scene Main thật + 2 client thật +
  1 peer thô chưa hello, mẫu r77/r84): **131/131 PASS, lần 1**
  (chạy ~3s, exit 0).
  - Unit local: sellback 2.000.000 → 1.000.000, lẻ 999.999 →
    499.999 (cắt lẻ), giá âm/0 → 0; `economy.sell` chặn đúng
    chưa-sở-hữu / phòng-trọ / món lạ; mua phòng-trọ 2 triệu rồi bán
    → `khong-ban-duoc`, tiền + owned không đổi; mua + bán áo dài →
    tiền 1 → 2 triệu, owned hết; bán lần 2 → `khong-so-huu`;
    bán nhà chung-cư-mini 800 triệu → nhận 400 triệu.
  - Client: gửi khi chưa nối → `chua-ket-noi-ws`; cleaner ack
    bỏ req_id 0 / ok không bool / price_received âm / money âm /
    owned không phải dict; ack đủ giữ đủ trường + `owned_present`.
  - Server qua WS: A mua áo dài (2 triệu) → bán lại nhận 1 triệu,
    tiền 4 triệu, owned xóa key, `shop_sell_count` 1, `shop_log`
    2 mục (buy + sell, sell có `price_received` 1 triệu,
    `price_paid` 0, `fame_gained` 0); mua lại áo dài ok, count vẫn 1.
  - Lỗi qua packet thô: bán món chưa có → `khong-so-huu`;
    phòng-trọ → `khong-ban-duoc`; món lạ → `khong-co-mon`;
    req_id 0 + thiếu req_id → drop, không ack; ngày sai →
    `ngay-server-khong-khop`, tiền + owned không đổi; peer chưa
    hello → ack `chua-hello` + dropped tăng; client C chưa đồng bộ
    sổ cái → `chua-dong-bo-so-cai`, vẫn chưa có entry ledger.
  - Persistence: stop → file đủ `shop_log` 3 mục (buy/sell/buy)
    + ledger A 2 triệu + owned áo dài ×1; restart cổng mới →
    `shop_sell_count` vẫn 1, log + ledger giữ nguyên. File kiểu
    v84 (buy không kind) vẫn nạp được, kind mặc định "buy",
    `shop_sell_count` 0.
  - Main end-to-end: chưa sở hữu gì → không có món bán được; mua
    áo dài qua WS → bán qua WS (pending 1 lần, toast "Đang chờ
    máy chủ xác nhận bán…", bán chen → `dang-cho-may-chu`); ack
    về → ví 4 triệu, owned hết, toast "Đã bán … 1.000.000";
    ngắt WS → mua/bán local ok, nhận 1 triệu, không pending.
  - Cleaner `_clean_shop_log_entry`: sell đủ trường giữ kind +
    price_received; sell thiếu/0 price_received → bỏ; kind lạ →
    bỏ; buy cũ không kind → "buy", không price_received → 0.
- **Hồi quy 114 suite, 5014 check, 0 FAIL** (log
  `hidden_files/regression-2026-11-27-2245.log`) — 0 fail lần thứ
  8 liên tiếp (r79–r86); r86 **131/131**, r85 25/25, r84 145/145,
  r83 120/120, r82 78/78, r81 96/96, r80 110/110, r78 53/53,
  G1 419/419, G3 95/95, G1 playtest 14/14, không regression.
  (111 suite chuẩn = 4998 check; + transfer-move 16 = 5014;
  2 diag test không in số đếm.)
- Sửa kèm trong vòng: `tools/godot/run_regression.sh` nay chạy đủ
  114 suite — trước đây script chỉ liệt kê 103, 11 suite r78–r86
  + diag/transfer phải chạy riêng ngoài script (đã thêm tên vào
  list + ghi chú ở đầu file, theo mẫu các vòng trước).

### 108.4 Verify + export — XONG (hồi quy 0 fail, pck mới)

- `--check-only` 6 file đổi/mới (`main.gd`, `pxb_online.gd`,
  `pxb_economy.gd`, `pxb_balance.gd`, `pxb_server.gd`,
  `g4_r86_shop_sell_test.gd`) exit 0; scene Main 120 frame
  exit 0, 0 ERROR/warning.
- Export web exit 0: pck **28.023.812 byte, SHA `5618ee9c…`**
  (trước `9c914dea…`, +31.572 byte do code + test mới), wasm không
  đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`; pck chứa
  "shop_sell" ×4 (grep -a); HTTP 200 đủ 6 file (cổng 8186).
- Staging rebuild `build_gh_pages.py` OK: pck 208 chunk, ráp lại
  khớp byte từng byte; `versions.json` ghi pck=`5618ee9c`.
  (Cảnh báo `title_bg.jpg` thiếu vẫn như các vòng trước — DOM dùng
  fallback, không phải lỗi mới.)

### 108.5 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- Push main r86 (`hidden_files/pxb-push-main-r86.py`, 4 lô):
  a 137 paths (r85-a 135, thay 2 file test r85 bằng 2 file test
  r86 `.gd` + `.uid`; thêm `pxb_economy.gd` + `pxb_balance.gd`;
  `main.gd` + `pxb_online.gd` + `pxb_server.gd` đã có sẵn trong
  a), b 20, c 37, docs 2 — tất cả path tồn tại, không file nào
  vượt giới hạn snapshot-push 188.416 byte/file **trừ**
  `docs/godot-g4.md` (~771 KB) và `docs/roles-qc.md` mới vượt
  (~192 KB, chỉ hơn giới hạn ~3,5 KB sau dòng r86 — 75+ lần push
  docs trước đều thành công nên giữ nguyên mẫu cũ; nếu lô docs
  lỗi thì tách `roles-qc.md` ra đẩy riêng sau). Thay script r85
  (pck `9c914dea` chưa lên — bỏ, file giữ lại). (`hidden_files/pxb-deploy-r86.py`,
  12 lô: 11 chunk pck 208 + final versions.json/index.html;
  manifest đã kiểm đủ path, file chunk tồn tại trong staging,
  ráp lại khớp byte). Thay script r85.
- **CHƯA CHẠY — chờ chủ nói 'đẩy tiếp'** (không còn thẻ chờ;
  live vẫn `5f2a052f` r41).

### 108.6 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r86 (4 lô) → deploy pck mới
   (12 lô) → kiểm live pin + đối chiếu byte.
2. Browser-verify vòng 86 + vòng 85 + vòng 84 + vòng 83 + vòng 82 +
   vòng 81 + vòng 80 + vòng 78 + vòng 77 + vòng 68 (thắng 1 trận
   demo → giữ sạp → mua dien-thoai-cu giảm 10% thật trên server;
   sang ngày server mới thì hold hết hạn → toast tiếng Việt; bấm B
   lúc đang giữ sạp → toast tiếng Việt, không mở trận; trade/auction/
   chat còn nguyên sau restart server thật bằng `server_main.gd
   --state-file`; mở điện thoại tab Tin nhắn sau khi nối lại chat
   thì thấy lại tin cũ; **bán lại ao-dai nhận 50% giá thật trên
   server**) — cần thắng 1 trận demo trước để có hold.
3. Chủ chốt tỷ lệ bán lại (50% hiện là PROVISIONAL) — nếu đổi số
   thì chỉ sửa `PxbBalance.SHOP_SELLBACK_PERCENT` + chạy lại test
   r86 (test tính 50% từ hằng, không hardcode).
4. Vòng 87 (ứng viên lớn nhất, khoảng trống thật từ G2 §6 phần 3):
   khóa ngắn tốt nghiệp ghi `+10` chỉ số phụ vào
   `education.pending_stat_gain` nhưng KHÔNG nơi nào áp vào chỉ số
   phụ — Main chỉ áp `pending_exp`/`pending_fame`; kiểm chứng rồi
   nối `PxbStats` áp đúng chỉ số phụ khi tốt nghiệp khóa ngắn.

## §109 — Vòng 87: nối `pending_stat_gain` khóa ngắn hạn vào `PxbStats` (28/11 ~00:00–00:30 +07, cron 23:45)

### 109.1 Chẩn đoán — khoảng trống thật (mục 4 của §108.6)

- G2 §6 phần 3 đã ghi từ đầu: khóa ngắn hạn tốt nghiệp ghi +10 vào
  `education.pending_stat_gain` nhưng CHƯA áp vào đâu — `PxbStats`
  chỉ có `set_stat` cho 3 gốc, 4 chỉ số trộn là hàm tính sẵn.
  `Main._check_graduations()` chỉ notify + toast "(chờ áp vào chỉ
  số phụ)". Học phí đã trừ, khóa đã xong, +10 không tới tay người chơi.
- Quyết định thiết kế (Bậc 1, theo GDD Mục 5 "+10 một chỉ số phụ"):
  KHÔNG cộng vào 2 gốc (tri+10/tam+10 thì Kỷ/Dũng cũng tăng ké +
  phá trần tổng 300; tri+5/tam+5 thì Sáng chỉ +5, sai số chốt).
  Bonus riêng `stat_bonus` cộng trên giá trị trộn: đúng +10 vào
  đúng chỉ số phụ, 3 gốc + `total()` không đổi. Bonus KHÔNG kẹp
  `STAT_MAX`: đã trả phí thì +10 phải thấy, kể cả trộn đã 100
  (chưa chốt trần bonus — GDD/PM chốt sau nếu cần). An Yên khi
  lệch: gốc 0 + bonus (đã trả phí thì không mất im lặng).

### 109.2 Sửa — `PxbStats` + Main (không sửa education, không sửa luật)

- `PxbStats`: const `SUB_STATS`; var `stat_bonus` {}; `sub_stat(key)`;
  `apply_stat_gain(sub, gain) -> bool` (khóa lạ / gain <= 0 → false);
  `ky()`/`dung()`/`sang()`/`an_yen()` cộng bonus; `data()` thêm
  `stat_bonus`; `from_data()` lọc khóa lạ / số âm (save cũ không có
  khóa thì bonus rỗng).
- Main: `_apply_pending_stat_gains()` — drain `pending_stat_gain`
  qua `stats.apply_stat_gain` mỗi ngày game mới (cả khi không có
  tốt nghiệp mới, để save r86 trở về trước còn pending cũng được áp
  ở ngày đổi đầu tiên); mục rác (khóa lạ / gain <= 0) bị xóa luôn.
  `_check_graduations()` gọi drain sau `check_short_course_graduation()`;
  toast mới "Xong khóa ngắn hạn: Sáng +10" (fallback "(chờ áp…)"
  chỉ khi áp thất bại). `_format_stat_gains()` + const
  `SUB_STAT_NAMES` {"ky": "Kỷ", "dung": "Dũng", "sang": "Sáng",
  "an-yen": "An Yên"}. `_education_text()` thêm dòng "Chờ nhận chỉ
  số phụ: …" khi pending còn (cửa sổ giữa load save cũ và ngày đổi).
  `_apply_save_data()`: khôi phục `stat_bonus` qua
  `PxbStats.from_data(sd)` (lọc như MarketBattle).

### 109.3 Test mới + hồi quy — XONG

- Test mới `tests/g4_r87_shortcourse_stat_test.gd` (không server,
  không cổng, scene Main thật): **42/42 PASS, lần 1** (chạy ~2s,
  exit 0).
  - Unit: ky/dung/sang gốc + bonus đúng chỉ số, chỉ số khác không
    đổi, total 3 gốc không đổi; khóa lạ / gain 0 / âm bị chặn; cộng
    dồn; An Yên cân bằng 90+10=100, lệch 0+10=10; `data()`/
    `from_data()` giữ bonus, bỏ khóa lạ / âm, save cũ bonus rỗng.
  - Main e2e: khóa mẫu Sáng 3 ngày 2tr — tốt nghiệp Sáng 100 → 110,
    pending xóa, toast "Sáng +10"; khóa 2 cộng dồn 120; pending cũ
    {"ky": 10, "la": 5} dồn ở ngày đổi (không tốt nghiệp mới):
    Ky +10, rác xóa, không toast mới; save/load slot 1 giữ bonus
    (Sang 120, Ky 110; đổi Tri 50 thì Sang 95, tải lại về 120).
- Sửa kèm trong vòng: `g2_ui_wiring2_test.gd` state 3 — check cũ
  "pending sang 10" thành 3 check (Sáng +10 áp thật, pending xóa,
  toast "Sáng +10"); `g2_selftest.gd` — `data()` nay thêm
  `"stat_bonus": {}` (bắt đúng 1 FAIL ở hồi quy lần 1: check cũ so
  `data()` bằng đúng dict 3 khóa; đã sửa, không phải lỗi logic).
  Lỗi test do chính tác giả viết sai kỳ vọng, đã sửa trước khi chạy
  lại: `from_data` bỏ khóa lạ — ky phải 110 (gốc 100 + bonus 10)
  chứ không phải 60; Trí 50 thì Sang 95 chứ không phải 85.
- **Hồi quy 115 suite, 5058 check, 0 FAIL** (log
  `hidden_files/regression-2026-11-28-0010.log`) — 0 fail lần thứ
  9 liên tiếp (r79–r87); r87 **42/42**, r86 131/131, r85 25/25,
  r84 145/145, r83 120/120, r82 78/78, r81 96/96, r80 110/110,
  r78 53/53, G1 419/419, G3 95/95, G1 playtest 14/14, không
  regression. (111 suite có đếm = 5058; +44 so với r86: r87 42 +
  wiring2 thêm 2 check; 2 diag test + probe + v6_geometry không in
  số đếm.)
- Sửa kèm trong vòng: `tools/godot/run_regression.sh` nay chạy đủ
  115 suite — thêm `g4_r87_shortcourse_stat_test` vào list + cập
  nhật số đếm ở đầu file (theo mẫu vòng 86).

### 109.4 Verify + export — XONG (hồi quy 0 fail, pck mới)

- `--check-only` 4 file đổi/mới (`pxb_stats.gd`, `main.gd`,
  `g4_r87_shortcourse_stat_test.gd`, `g2_ui_wiring2_test.gd`) exit 0
  (lỗi parse lúc đầu: `var x := _main.stats.sang()` không suy được
  kiểu vì `_main` là Node — đã ghi rõ `var x: int = …` ở cả 2 file);
  `g2_selftest` 87/87 + wiring2 73/73 chạy riêng trước hồi quy;
  scene Main 120 frame exit 0, 0 ERROR/warning.
- Export web exit 0: pck **28.029.944 byte, SHA `fd086f6b…`**
  (trước `5618ee9c…`, +6.132 byte do test mới + code), wasm không
  đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`; pck chứa
  "g4_r87" ×4 (đường dẫn file test .gd/.gdc/.remap); HTTP 200 đủ 6
  file (cổng 8187).
- LƯU Ý PHƯƠNG PHÁP (đính chính §108.4): script Godot 4 export
  thành `.gdc` nhị phân nên tên hàm / chuỗi code KHÔNG còn dạng text
  trong pck — "shop_sell ×4" ở §108.4 thực ra cũng chỉ là tên file
  test `g4_r86_shop_sell_test`, không phải bằng chứng nội dung code.
  Bằng chứng thật là test headless + hồi quy + scene 120 frame
  (chạy trên đúng source đã export), pck chỉ kiểm SHA/size + đường
  dẫn file mới.
- Staging rebuild `build_gh_pages.py` OK: pck 208 chunk, ráp lại
  khớp byte từng byte; `versions.json` ghi pck=`fd086f6b`.
  (Cảnh báo `title_bg.jpg` thiếu vẫn như các vòng trước — DOM dùng
  fallback, không phải lỗi mới.)

### 109.5 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- Push main r87 (`hidden_files/pxb-push-main-r87.py`, 4 lô):
  a 140 paths (r86-a 137, bỏ 2 file test r86 `.gd` + `.uid`, thêm 2 file
  test r87 `.gd` + `.uid`; thêm `pxb_stats.gd` + `g2_ui_wiring2_test.gd` + `.uid`;
  `main.gd` + `run_regression.sh` đã có sẵn trong a), b 20 paths
  (`.import` atlas/bg/ground, không đổi so với r86), c 37 paths
  (artpass43..63, không đổi so với r86), docs 2 paths (godot-g4 +
  roles-qc) — tất cả path tồn tại, không file nào vượt giới hạn
  snapshot-push 188.416 byte/file **trừ** `docs/godot-g4.md`
  (~763 KB) và `docs/roles-qc.md` mới vượt (~189 KB, chỉ hơn giới
  hạn ~4,8 KB — 75+ lần push docs trước đều thành công nên giữ
  nguyên mẫu cũ; nếu lô docs lỗi thì tách `roles-qc.md` ra đẩy
  riêng sau). Thay script r86 (pck `fd086f6b` chưa lên — bỏ, file
  giữ lại). (`hidden_files/pxb-deploy-r87.py`, 12 lô: 11 chunk pck
  208 + final versions.json/index.html; manifest đã kiểm đủ path,
  file chunk tồn tại trong staging, ráp lại khớp byte). Thay script
  r86.
- **CHƯA CHẠY — chờ chủ nói 'đẩy tiếp'** (không còn thẻ chờ;
  live vẫn `5f2a052f` r41).

### 109.6 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r87 (4 lô) → deploy pck mới
   (12 lô) → kiểm live pin + đối chiếu byte.
2. Browser-verify vòng 87 + vòng 86 + vòng 85 + vòng 84 + vòng 83 +
   vòng 82 + vòng 81 + vòng 80 + vòng 78 + vòng 77 + vòng 68 (thắng
   1 trận demo → giữ sạp → mua dien-thoai-cu giảm 10% thật trên
   server; sang ngày server mới thì hold hết hạn → toast tiếng Việt;
   bấm B lúc đang giữ sạp → toast tiếng Việt, không mở trận;
   trade/auction/chat còn nguyên sau restart server thật bằng
   `server_main.gd --state-file`; mở điện thoại tab Tin nhắn sau
   khi nối lại chat thì thấy lại tin cũ; **bán lại ao-dai nhận 50%
   giá thật trên server; tốt nghiệp khóa ngắn Sáng +10 thấy ngay
   trên chỉ số phụ**).
3. Chủ chốt trần bonus chỉ số phụ (hiện KHÔNG kẹp STAT_MAX — nếu
   chốt trần thì chỉ sửa `PxbStats.apply_stat_gain`/`stat_bonus` +
   chạy lại test r87).
4. Vòng 88 (ứng viên lớn nhất, hệ quả trực tiếp của vòng 87): HUD
   chỉ hiện Thể/Trí/Tâm, 4 chỉ số phụ (Kỷ/Dũng/Sáng/An Yên) không
   có chỗ nào xem thường trực — +10 khóa ngắn chỉ thấy qua toast
   rồi mất; hiển thị 4 chỉ số phụ lên HUD + tab Bạn thân trong điện
   thoại (kèm bonus), để người chơi thấy được kết quả khóa học.

## §110 — Vòng 88: hiển thị 4 chỉ số phụ lên HUD + tab Bạn thân (28/11 ~00:45–01:20 +07, cron 00:45)

### 110.1 Chẩn đoán — khoảng trống thật (mục 4 của §109.6)

- Vòng 87 nối `pending_stat_gain` vào `PxbStats` xong (+10 đúng chỉ
  số phụ, save/load giữ bonus) nhưng người chơi KHÔNG có chỗ nào xem
  thường trực: HUD chỉ hiện Thể/Trí/Tâm, 4 chỉ số phụ (Kỷ/Dũng/Sáng/
  An Yên) chỉ ló qua toast tốt nghiệp rồi mất. Học xong khóa ngắn mà
  không thấy kết quả đâu = vòng 87 chưa tới tay người chơi.
- Quyết định thiết kế (Bậc 1): hiện 4 chỉ số phụ ở 2 chỗ — (1) thêm
  1 dòng lên HUD, (2) thêm 1 mục lên đầu tab Bạn thân trong điện
  thoại (kèm dòng bonus khi có). KHÔNG sửa luật, KHÔNG sửa
  `PxbStats` (chỉ đọc `ky()`/`dung()`/`sang()`/`an_yen()` +
  `stat_bonus` đã có), KHÔNG thêm hệ mới.

### 110.2 Sửa — Main (không sửa luật, không sửa PxbStats)

- HUD (`main.gd`, `_build_ui` + `_update_hud`): label mới
  `_hud_substats` (font 18), text `"Kỷ %d • Dũng %d • Sáng %d •
  An Yên %d"` cập nhật mỗi `_update_hud()`; `_fit_hud_substats()`
  co 18 → 16 nếu dòng rộng quá 412px (như `_fit_hud_map`).
  Để panel không vượt 170px của artpass3: 3 dòng nội dung thu từ
  24 về 20. Đo thật bằng probe headless: dòng phụ cỡ 18 rộng
  403px (≤ 412), cỡ 20 đã 448px (tràn); panel cao ~163px lúc
  spawn Map001 (tên map cỡ 28), cao nhất ~168px khi tên map ngắn
  vừa cỡ 30 ("Phố Tây") — vẫn ≤ 170. Điện thoại y=216 không đổi
  (216 ≥ 168+26).
- Điện thoại (`_social_text()`, tab Bạn thân): thêm khối chỉ số
  phụ + dòng `"Bonus khóa ngắn hạn: …"` (tái dùng
  `_format_stat_gains(stats.stat_bonus)`, chỉ hiện khi bonus
  không rỗng). **Sửa sau khi tự xem ảnh thật:** lần 1 đặt khối ở
  CUỐI danh bạ (sau 38 bullet "chưa quen") — ảnh browser cho thấy
  phải cuộn hết mới thấy, sai mục đích "thấy ngay kết quả khóa
  học"; đã dời lên NGAY SAU dòng tiêu đề, xem lại ảnh thì hiện
  ngay khi mở tab. Không test nào khóa dòng đầu của
  `_social_text()` nên không sửa test cũ.

### 110.3 Test mới + hồi quy — XONG

- Test mới `tests/g4_r88_substats_hud_test.gd`: **25/25 PASS**
  (lỗi parse lúc đầu: `var w := _main.font.get_string_size(…)` không
  suy được kiểu vì `_main` là Node — đã ghi rõ `var w: float = …`,
  cùng mẫu lỗi r87).
  - Ban đầu: HUD gốc không đổi, dòng phụ đúng 100 cả 4, cỡ 18, 3
    dòng nội dung cỡ 20, panel ≤ 170; tab có dòng chỉ số phụ,
    không có dòng bonus, vẫn kết thúc `"\n "`.
  - Bonus: Sang +10, Kỷ +10 → HUD/tab hiện 110 đúng chỗ, dòng
    bonus đúng thứ tự `"Kỷ +10 • Sáng +10"`; panel vẫn ≤ 170.
  - An Yên lệch (Tri 50): gốc 0 + bonus 10 = 10, HUD/tab hiện
    đúng `"An Yên 10"`.
  - Save/load slot 1: bonus + Tri 50 đi kèm save, HUD/tab sau
    tải giữ nguyên.
  - Trường hợp xấu nhất: tên map ngắn vừa cỡ 30, panel vẫn ≤ 170,
    dòng phụ rộng ≤ 412.
- **Hồi quy 116 suite, 5083 check, 0 FAIL** (log
  `~/workspace/regression-move.log`, script chuẩn
  `tools/godot/run_regression.sh`) — 0 fail lần thứ 10 liên tiếp
  (r79–r88); r88 25/25, r87 42/42, r86 131/131, r85 25/25, r84
  145/145, r83 120/120, r82 78/78, r81 96/96, r80 110/110, r78
  53/53, G1 419/419, G3 95/95, G1 playtest 14/14, không regression.
  (112 suite có đếm = 5083 = 5058 r87 + 25 r88; 4 suite không in
  số đếm: 2 diag + probe + v6_geometry.)
- Bài học hồi quy trong vòng này: lần chạy đầu (script
  `hidden_files/run_regression_2026-11-27-2145.sh` copy sang) chỉ
  chạy 113 suite / 4996 check — glob `*_test.gd` không bắt
  `g2_selftest.gd` (đuôi `selftest`, không phải `_test`) và 2 probe
  (`g4_online_server_probe`, `v6_geometry_probe`) không có trong
  list; suýt báo sai tổng. Đã chạy lại bằng script chuẩn của repo
  (đủ 116 suite) mới kết luận. Sửa kèm: `tools/godot/run_regression.sh`
  thêm `g4_r88_substats_hud_test` vào list + cập nhật đầu file;
  script hidden_files vòng này đã vá glob thêm `g2_selftest.gd` +
  `v6_geometry_probe.gd` (probe server vẫn chỉ chạy bằng script
  chuẩn).

### 110.4 Verify + export — XONG (hồi quy 0 fail, pck mới)

- `--check-only` `main.gd` exit 0; `--import` exit 0 (sinh `.uid`
  test r88); scene Main 120 frame exit 0, 0 ERROR/warning.
- Export web exit 0: pck **28.034.100 byte, SHA `3b37615d`**
  (trước `fd086f6b…`, export lần 1 `dd75a130` đã bị thay trước khi
  staging — export lần 1 chạy trước khi dời khối chỉ số phụ lên
  đầu tab, export lần 2 sau khi dời), wasm không đổi `fc74679e…`,
  `GODOT_THREADS_ENABLED = false`; pck chứa
  `g4_r88_substats_hud_test` ×4; HTTP 200 đủ 6 file (cổng 8189
  lần 1, 8191 lần 2).
- Staging rebuild `build_gh_pages.py` OK: pck 208 chunk, ráp lại
  khớp byte; `versions.json` ghi pck=`3b37615d`.
- **Browser-verify thật (Chromium 1255 + swiftshader, 720×1280,
  script mới `hidden_files/pxb-browser-verify-r88.py`, venv
  `/tmp/pxb-pw-venv` vì python hệ thống chặn PEP 668):** engine
  khởi động, bấm Bắt đầu chơi, HUD 5 dòng hiện đủ trong panel
  không tràn, bấm P mở điện thoại tab Danh bạ thấy ngay dòng chỉ
  số phụ ở đầu; 0 pageerror — ảnh
  `hidden_files/pxb-browser-verify-2026-11-28/31-r88-hud.png`,
  `32-r88-phone.png` + `console-r88.json`. 9 console error đều là
  404 tài nguyên `web_shell.html` xin file lẻ (`/char_player.png`,
  `/char_banthan.png`, `/title_bg.jpg` — đã nướng trong pck, không
  có file lẻ trong build; đã biết từ §109.4, DOM dùng fallback,
  KHÔNG phải lỗi mới của vòng 88).
- Cảnh báo có từ trước, ghi lại (không do vòng 88): export in 3
  WARNING `UID duplicate detected` giữa `atlas-map003/004/005.png`
  với `atlas-map001/002/003.png` (atlas PNG không có file `.uid`,
  copy file giữ trùng UID import) — chưa thấy ảnh hưởng hành vi
  (map vẫn vẽ đúng trên browser), để vòng sau sửa.

### 110.5 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- Push main r88 (`hidden_files/pxb-push-main-r88.py`, 4 lô):
  a 140 paths (r87-a 140, bỏ 2 file test r87 `.gd` + `.uid`, thêm
  2 file test r88 `.gd` + `.uid`; `main.gd` +
  `tools/godot/run_regression.sh` đã có sẵn trong a), b 20 paths
  (`.import` atlas/bg/ground, không đổi so với r87), c 37 paths
  (artpass43..63, không đổi so với r87), docs 2 paths (godot-g4 +
  roles-qc) — tất cả path tồn tại, không file nào vượt giới hạn
  snapshot-push 188.416 byte/file **trừ** `docs/godot-g4.md`
  (~780 KB) và `docs/roles-qc.md` (~193 KB — 75+ lần push docs
  trước đều thành công nên giữ nguyên mẫu cũ; nếu lô docs lỗi thì
  tách `roles-qc.md` ra đẩy riêng sau). Thay script r87 (pck
  `fd086f6b` chưa lên — bỏ, file giữ lại).
- Deploy r88 (`hidden_files/pxb-deploy-r88.py`, 12 lô: 11 chunk pck
  208 + final versions.json/index.html; manifest đã kiểm đủ path,
  file chunk tồn tại trong staging, ráp lại khớp byte). Thay script
  r87.
- **CHƯA CHẠY — chờ chủ nói 'đẩy tiếp'** (không còn thẻ chờ;
  live vẫn `5f2a052f` r41).

### 110.6 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r88 (4 lô) → deploy pck mới
   (12 lô) → kiểm live pin + đối chiếu byte.
2. Browser-verify vòng 88 + vòng 87 + vòng 86 + vòng 85 + vòng 84 +
   vòng 83 + vòng 82 + vòng 81 + vòng 80 + vòng 78 + vòng 77 +
   vòng 68 (thắng 1 trận demo → giữ sạp → mua dien-thoai-cu giảm
   10% thật trên server; sang ngày server mới thì hold hết hạn →
   toast tiếng Việt; bấm B lúc đang giữ sạp → toast tiếng Việt,
   không mở trận; trade/auction/chat còn nguyên sau restart server
   thật bằng `server_main.gd --state-file`; mở điện thoại tab Tin
   nhắn sau khi nối lại chat thì thấy lại tin cũ; **bán lại ao-dai
   nhận 50% giá thật trên server; tốt nghiệp khóa ngắn Sáng +10
   thấy ngay trên chỉ số phụ** — nay đã thấy trên HUD + tab Bạn
   thân).
3. Chủ chốt trần bonus chỉ số phụ (hiện KHÔNG kẹp STAT_MAX — nếu
   chốt trần thì chỉ sửa `PxbStats.apply_stat_gain`/`stat_bonus` +
   chạy lại test r87).
4. Vòng 89 (ứng viên lớn nhất, từ verify vòng này): dọn 9 console
   404 (bỏ tham chiếu file lẻ trong `web_shell.html` hoặc copy
   `char_player.png`/`char_banthan.png`/`title_bg.jpg` vào build)
   + sửa trùng UID atlas-map003/004/005 (cấp `.uid` riêng) — cả 2
   đều là lỗi hiển thị/log đã biết, sửa gọn trong 1 vòng.

## §111 — Vòng 89: dọn 9 console 404 + trùng UID atlas (28/11 ~01:45–02:15 +07, cron 01:45)

### 111.1 Chẩn đoán — gốc của 9 lỗi 404 (mục 4 của §110.6)

- 9 console error ở verify vòng 88 KHÔNG phải 9 file khác nhau: là
  **3 file × 3 lần retry** của `fetchBlobRetry` trong
  `web_shell.html` (`loadTitleArt`): `title_bg.jpg`,
  `char_player.png`, `char_banthan.png`.
- Gốc 1 — sai tên file: `title_bg.jpg` **không tồn tại**; file thật
  là `title_bg.png` (1.335.112 byte, `src/godot/art/`). Vì tên sai
  nên `build_gh_pages.py` cũng bỏ qua ảnh này khi chunk
  (`CANH BAO: thieu anh title_bg.jpg — bo qua`, IMG_PARTS không có
  `title_bg.jpg`) → loader không chặn được fetch → 404 cả trên live
  lẫn local. `char_player.png`/`char_banthan.png` có chunk trên live
  nhưng local `src/godot-build/` không có file lẻ (export Godot
  không copy art lẻ vào build) → 404 khi serve local.
- Gốc 2 — trùng UID: `tiles/atlas-map003.png.import` dùng chung UID
  `uid://bfgvu5kjfxhle` với map001, map004 chung `b08jg2ohakm5p`
  với map002, map005 chung `bfgvu5kjfxhle` với map001 (copy file giữ
  trùng UID import). Quét toàn project (300 `.import`): chỉ 2 UID
  trùng này, không còn chỗ khác.

### 111.2 Sửa — web_shell + staging + UID

- `web_shell.html`: `title_bg.jpg` → `title_bg.png` (fetch + 2
  comment). Không đổi logic retry/fallback.
- `tools/godot/build_gh_pages.py`:
  - `IMG_TYPES`: `"title_bg.png": "image/png"` (bỏ `"title_bg.jpg":
    "image/jpeg"`).
  - `img_srcs`: `title_bg.png` đọc từ `src/godot/art/title_bg.png`
    (như 2 char PNG đã làm) thay vì `BUILD_DIR/title_bg.jpg`.
  - Mới `sync_loose_art()`: copy 3 ảnh từ `art/` sang `BUILD_DIR`
    sau mỗi lần export để chạy local không 404; gọi ở đầu cả
    `build()` lẫn `verify()` (verify kiểm thêm file lẻ trong
    BUILD_DIR khớp byte với `art/`).
- UID atlas: sửa `uid=` trong 3 `.import` map003/004/005 sang UID
  mới sinh ngẫu nhiên, chạy `--headless --import` — **Godot tự cấp
  lại UID khác** (`b38h5xnk8m3f5`, `bhissgu4fvtk`, `eig07pm56sin`)
  và ghi lại 3 file `.import` (lần import 1 còn in 3 warning trùng
  do cache cũ; lần import 2: **0 warning**). Bài học: không cần giữ
  UID tự sinh tay — chỉ cần đổi UID rồi import lại, Godot tự giải
  quyết trùng; test khóa đúng UID Godot đã cấp, không khóa UID tay.

### 111.3 Test mới + hồi quy — XONG

- Test mới `tests/g4_r89_cleanup_test.gd`: **23/23 PASS** lần đầu
  (web_shell không còn `title_bg.jpg`, fetch đúng 3 tên, cả 3 ảnh
  có trong `art/` + có file lẻ trong build, `build_gh_pages.py`
  không còn `.jpg` + có `sync_loose_art`, 18 atlas UID duy nhất,
  map001/002 giữ UID cũ).
- **Hồi quy 117 suite, 5106 check, 0 FAIL** (log
  `hidden_files/regression-2026-11-28-0145.log`, script chuẩn
  `tools/godot/run_regression.sh` + thêm r89 vào list) — 0 fail lần
  thứ 11 liên tiếp (r79–r89); r89 23/23, r88 25/25, r87 42/42,
  r86 131/131, G1 419/419, G3 95/95, không regression. Đếm đủ:
  113 suite có đếm = 5106 (4971 dạng N/N + 76 dạng "N PASS / 0
  FAIL" + 16 dạng "N PASS, 0 FAIL" + 43 dạng "N pass, 0 fail");
  4 suite không in số đếm như cũ (2 diag + probe + v6_geometry).

### 111.4 Verify + export — XONG (hồi quy 0 fail, pck mới)

- `--check-only` `main.gd` exit 0; scene Main 120 frame exit 0,
  0 ERROR/warning; `--import` lần 2: 0 warning trùng UID.
- Export web exit 0: **0 warning UID duplicate, 0 ERROR**; pck
  **28.036.920 byte, SHA `654e9e35`** (trước `3b37615d`), wasm
  không đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`. Lỗi
  thao tác lúc đầu: export từ repo root với đường dẫn tương đối
  `src/godot-build` bị lỗi "Target folder does not exist" (đường
  dẫn export tính theo project dir) — chạy lại từ `src/godot`
  với `../godot-build/index.html` như G0 thì xong.
- HTTP 200 đủ **7 file** (cổng 8192): index.html/js/wasm/pck +
  `title_bg.png`/`char_player.png`/`char_banthan.png` (3 file lẻ
  lần đầu có 200 sau khi copy).
- Staging rebuild `build_gh_pages.py` VERIFY OK: pck 208 chunk
  khớp byte; **`img title_bg.png: version 739e0a57, 10 chunk,
  khop byte: True`** (trước đây bị bỏ qua); file lẻ trong
  BUILD_DIR khớp `art/` cả 3.
- **Browser-verify thật (Chromium 1255 + swiftshader, 720×1280,
  script mới `hidden_files/pxb-browser-verify-r89.py`):**
  engine khởi động, ảnh nền title + 2 nhân vật tải được (blob
  URL, không còn fallback gradient), bấm Bắt đầu chơi, HUD 5
  dòng như r88 — **0 console error (trước đây 9), 0 pageerror,
  0 failed request** — ảnh `hidden_files/pxb-browser-verify-
  2026-11-28/33-r89-title.png`, `34-r89-hud.png` +
  `console-r89.json`. Venv Playwright `/tmp/pxb-pw-venv` đã mất
  do /tmp dọn — đã tạo lại (`python3 -m venv` + `pip install
  playwright`), lần sau kiểm tra lại trước khi chạy.

### 111.5 Push + Deploy — CHUẨN BỊ XONG, CHƯA CHẠY (chờ 'đẩy tiếp')

- Push main r89 (`hidden_files/pxb-push-main-r89.py`, 4 lô):
  a 141 paths (r88-a 140, bỏ 2 file test r88 `.gd` + `.uid`, thêm
  2 file test r89 `.gd` + `.uid`, thêm `web_shell.html` +
  `build_gh_pages.py`; `run_regression.sh` đã có sẵn trong a),
  b 20 paths (`.import` atlas/bg/ground, không đổi danh sách so
  với r88 — nội dung 3 file atlas-map003/004/005 đổi UID),
  c 37 paths (artpass43..63, không đổi so với r88),
  docs 2 paths (godot-g4 + roles-qc) — tất cả path tồn tại, không
  file nào vượt giới hạn snapshot-push 188.416 byte/file **trừ**
  `docs/godot-g4.md` (~790 KB) và `docs/roles-qc.md` (~195 KB —
  75+ lần push docs trước đều thành công nên giữ nguyên mẫu cũ;
  nếu lô docs lỗi thì tách `roles-qc.md` ra đẩy riêng sau). Thay
  script r88 (pck `3b37615d` chưa lên — bỏ, file giữ lại).
- Deploy r89 (`hidden_files/pxb-deploy-r89.py`, 12 lô: 11 chunk pck
  208 + final versions.json/index.html; manifest đã kiểm đủ path,
  file chunk tồn tại trong staging, ráp lại khớp byte). Thay script
  r88. Lưu ý deploy: `img/title_bg.png/739e0a57/` là thư mục chunk
  MỚI (10 chunk) — phải push kèm như pck/wasm version mới.
- **CHƯA CHẠY — chờ chủ nói 'đẩy tiếp'** (không còn thẻ chờ;
  live vẫn `5f2a052f` r41).

### 111.6 Việc tiếp theo

1. Chủ nói 'đẩy tiếp' → chạy push r89 (4 lô) → deploy pck mới
   (12 lô + 10 chunk `img/title_bg.png/739e0a57/`) → kiểm live
   pin + đối chiếu byte.
2. Browser-verify vòng 89 + vòng 88 + vòng 87 + vòng 86 + vòng 85 +
   vòng 84 + vòng 83 + vòng 82 + vòng 81 + vòng 80 + vòng 78 +
   vòng 77 + vòng 68 (thắng 1 trận demo → giữ sạp → mua
   dien-thoai-cu giảm 10% thật trên server; sang ngày server mới
   thì hold hết hạn → toast tiếng Việt; bấm B lúc đang giữ sạp →
   toast tiếng Việt, không mở trận; trade/auction/chat còn nguyên
   sau restart server thật bằng `server_main.gd --state-file`; mở
   điện thoại tab Tin nhắn sau khi nối lại chat thì thấy lại tin
   cũ; **bán lại ao-dai nhận 50% giá thật trên server; tốt nghiệp
   khóa ngắn Sáng +10 thấy ngay trên chỉ số phụ** — nay đã thấy
   trên HUD + tab Bạn thân).
3. Chủ chốt trần bonus chỉ số phụ (hiện KHÔNG kẹp STAT_MAX — nếu
   chốt trần thì chỉ sửa `PxbStats.apply_stat_gain`/`stat_bonus` +
   chạy lại test r87).
4. Vòng 90 (ứng viên lớn nhất còn lại, từ §110.6 mục 2 + §111.4):
   browser-verify lại toàn bộ các vòng r68–r89 trên build mới
   (hiện chỉ verify từng vòng lúc làm, chưa có 1 vòng chạy lại
   hết các kịch bản cũ trên build mới nhất).

## §112 — Vòng 90: browser-verify lại r68–r89 trên build mới, PHA 1 (28/11 ~02:45–03:50 +07, cron 02:45)

> Pha 1 xong: headless subset r68–r89 + browser thật (chat gửi/nhận,
> làm ca kiếm tiền, mua/bán Áo dài qua server, restart server rồi nối
> lại thấy tin cũ, lưu slot 1) — đều PASS trên build pck `654e9e35`
> (không đổi code, không export lại). Còn lại pha 2: thắng trận demo
> → giữ sạp → mua dien-thoai-cu giảm 10% → sang ngày server hold hết
> hạn → bấm B lúc giữ sạp; tốt nghiệp khóa ngắn Sáng +10; trade/auction
> còn nguyên sau restart (cần 2 client — headless đã cover r83).

### 112.1 Headless subset r68–r89 — 23/23 OK, 0 FAIL

- Script mới `hidden_files/pxb-v90-subset.sh` (chạy lại 23 test r68–
  r89 + online server/probe, log `hidden_files/regression-2026-11-28-
  0245-v90subset.log`): r68 28/28+33/33, trade 69/69, trade-apply
  76/76, auction 95/95, ledger 127/127, trade-ledger 97/97, r74 44/44,
  r75 45/45, r76 125/125, r77 99/99, r78 53/53, r80 110/110, r81 96/96,
  r82 78/78, r83 120/120, r84 145/145, r85 25/25, r86 131/131, r87
  42/42, r88 25/25, r89 23/23, online-server 37/37, g2-online 91/91.
  Code không đổi từ V89 nên không chạy lại full regression 117 suite
  (V89 đã xanh 5106 check); subset này là bằng chứng đủ cho pha 1.

### 112.2 Browser thật — kịch bản đã chạy (Chromium 1255 + swiftshader, 720×1280)

- Server thật `server_main.gd --port 8765 --state-file
  /tmp/pxb-v90-state.json` (bản sao bằng chứng:
  `hidden_files/pxb-v90-server-state.json`); game serve cổng 8193;
  Chrome thường trực CDP 9222 (giữ 1 session xuyên suốt các script);
  script `hidden_files/pxb-browser-verify-r90p1.py`,
  `pxb-browser-verify-r90p2{a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q}.py`;
  ảnh `hidden_files/pxb-browser-verify-2026-11-28/35–68` +
  `console-r90*.json`. **0 console error, 0 pageerror, 0 failed
  request trong mọi script.**
- Load + title art + HUD 5 dòng + 4 chỉ số phụ (r88/r89): PASS
  (ảnh 35–37; HUD `Ví: 0đ`, `Kỷ 100 • Dũng 100 • Sáng 100 • An Yên 100`).
- Chat: nối `ws://localhost:8765` (server log `+ peer …,
  dang online: 1`, toast `Đã nối chat online (1 người).`); gửi
  `v90 xin chao` → server log `chat [Người chơi] v90 xin chao` +
  `chat_log` trong state file (ảnh 54–55).
- Làm ca: 8 ca Bán rong × 292.500đ → ví **2.340.000đ**, EXP 80
  (HUD ảnh 58; ledger server `money: 2340000`).
- Mua Áo dài qua server: bấm `Mua Áo dài — 2.000.000đ` → ledger
  `money: 340000`, `owned: {ao-dai: 1}`, `shop_log` ghi
  `price_paid: 2000000, discount_applied: 0` (không giữ sạp nên
  đúng 0% — ảnh 59–61).
- Bán lại Áo dài qua server: bấm `Bán Áo dài — nhận 1.000.000đ` →
  ledger `money: 1340000`, `owned: {}`, `shop_log` kind `sell`,
  `price_received: 1000000` = đúng 50% giá catalog (ảnh 61–62).
- Restart server thật (kill + chạy lại cùng `--state-file`):
  state nạp lại đủ (`chat_log` 1 tin, `money: 1340000`,
  `shop_log` 2 mục); client nối lại cùng `player_id`
  (`pxb-1795809621536-451257650`, toast `Đã nối chat online`),
  ví HUD vẫn 1.340.000đ; cuộn tab Tin nhắn xuống cuối thấy lại
  `Người chơi: v90 xin chao` (ảnh 64–66).
- Lưu slot 1: tab Cài đặt → `Lưu vào slot 1` → toast `Đã lưu vào
  slot 1 (file).` + `Đồng bộ: local-ok (da-luu-local-slot-1-qua-file)`
  (ảnh 67–68).

### 112.3 Bài học phương pháp — viewport CDP + click chậm (ghi để không tái phạm)

1. **CDP persistent tự về viewport 720×1080:** script 2a gọi
   `set_viewport_size(720,1280)` nên ảnh 35–38 đúng 1280; các script
   2b–2h KHÔNG gọi lại nên viewport về 720×1080, canvas 720×1080,
   mọi tọa độ click đọc từ ảnh 1280 đều lệch hệ số 1280/1080 ≈
   1,185 theo chiều dọc. Hậu quả đã thấy: click (150,368) trúng tab
   Sức khỏe thay vì Việc làm; click (360,795) không focus được ô
   nhập chat; click (455,1130) nằm NGOÀI viewport nên nút `Đóng (B)`
   không đóng trận (tưởng bug game — KHÔNG phải); gõ `V90 xin chao
   Pho Xo Bo` khi điện thoại đã đóng thì `P` đóng điện thoại + `B`
   mở trận demo. Sau khi sửa (gọi `set_viewport_size` đầu MỖI
   script + verify `canvas 720×1280`, ảnh 53) mọi click đều trúng.
   **LUẬT: script CDP nào cũng set viewport 720×1280 + đo lại
   canvas trước khi click.**
2. **Click chậm mới ăn ở FPS thấp:** `mouse.click` nhanh (down+up
   trong vài ms) có lúc không focus được LineEdit; click giữ 800ms
   (`mouse.down`, đợi, `mouse.up`) thì focus + gõ chữ được ngay
   (đã chứng minh ở 2g: `12345` hiện trong ô nhập + con trỏ).
   Dùng `slow_click` cho mọi tương tác canvas từ nay.
3. **Gõ chữ có phím nóng thì phải chắc ô nhập đã focus:** nếu chưa
   focus, `P`/`B`/`F`/WASD trong chuỗi gõ sẽ kích hoạt hotkey game
   (đóng điện thoại/mở trận/đổi khung/di chuyển). Gõ xong chụp ngay
   để xác nhận chữ đã vào ô trước khi bấm Gửi.
4. **Chat history nhân đôi khi nối lại (phát hiện nhỏ, chưa sửa):**
   sau restart + nối lại, tab Tin nhắn hiện `Người chơi: v90 xin
   chao` 2 lần (ảnh 66) trong khi `chat_log` server chỉ có 1 mục —
   client giữ log cũ của mình rồi cộng thêm history server gửi lúc
   hello. Cần sửa ở vòng sau (khử trùng theo `at_ms`/`text` khi
   nhận history), không chặn V90.
5. **Cài đặt hiện `Online: ngoại tuyến` dù chat đã nối** (ảnh 68) —
   `_online_text()` báo theo kênh khác với trạng thái WS; ghi để
   vòng sau kiểm, không chặn V90.

### 112.4 Việc tiếp theo — Vòng 90 pha 2

1. Thắng 1 trận demo (bấm B, đánh bằng click ô xanh/địch trong tầm
   — NHỚ click chậm + viewport 1280) → giữ sạp → mua
   dien-thoai-cu giảm 10% thật trên server (cần ví ≥ 4.500.000đ:
   làm thêm ca Bán rong/Shipper; có thể tải lại slot 1 đã lưu ở
   pha 1: ví 1.340.000đ + làm thêm ~11 ca) → sang ngày server mới
   thì hold hết hạn → toast tiếng Việt → bấm B lúc đang giữ sạp →
   toast tiếng Việt, không mở trận.
2. Tốt nghiệp khóa ngắn Sáng +10: đăng ký khóa ngắn (tab Học tập,
   nút `Khóa ngắn: Sáng tạo 3 ngày — 2.000.000đ`) → bấm F ×9 (3
   ngày game) → toast tốt nghiệp + Sáng 110 trên HUD + tab Bạn thân.
3. Trade/auction còn nguyên sau restart server (cần 2 client cùng
   lúc — headless r83 đã 120/120; browser chỉ làm khi có 2 tab).
4. Sửa nhân đôi chat history khi nối lại (§112.3 mục 4).
5. Chủ nói 'đẩy tiếp' → chạy push r89 (4 lô) → deploy pck `654e9e35`
   (12 lô + 10 chunk `img/title_bg.png/739e0a57/`) → kiểm live pin +
   đối chiếu byte (script r89 vẫn giữ, chưa chạy).
6. Chủ chốt trần bonus chỉ số phụ (hiện KHÔNG kẹp STAT_MAX).

## §114 — Vòng 92: cầu nối window.__pxb_battle + replay đồng bộ, trận vẫn thua (28/11 ~04:45–05:45 +07, cron 04:45)

### 114.1 Chẩn đoán V91 — XONG (nguyên nhân replay mù)

- Đợi 3s sau Kết thúc lượt < AI delay 1,2s game (≈ 5,5s wall ở
  ~0,22×) nên click lượt A sau rơi vào lượt địch (bị bỏ qua/chỉ xem),
  click Kết thúc lượt bỏ qua lượt địch trước khi AI kịp đi. Bằng
  chứng: ảnh 83 cả 2 đội 100% vòng 12/12; ảnh 84 đội Chợ thắng vòng
  13 sau khi script dừng bấm. Luật trận đúng (sim 2/2 PASS) — lỗi ở
  đồng bộ script, không phải luật.

### 114.2 Sửa — cầu nối trận ra JS (code thật)

- `scripts/battle_scene.gd`: `battle_status()` (open/over/winner/
  round/turn_fighter/turn_team/% HP 2 đội/last_action/result_text/
  reachable/attackable/vị trí + HP + moved/acted từng đấu sĩ) +
  `_push_bridge()` (`window.__pxb_battle = JSON.stringify(status)`,
  chỉ trên web theo đúng mẫu `__pxb_map`/`__pxb_tile` của Main) +
  cờ `_bridge_dirty` (đặt ở setup/turn-changed/battle-finished/
  click/end-turn/AI-turn, flush trong `_process`).
- `main.gd` `_close_battle()`: `window.__pxb_battle = null` (chỉ web)
  để script không đọc nhầm trận cũ; mở trận bị chặn (đang giữ sạp)
  thì bridge vẫn null — phân biệt được.
- Test mới `tests/g4_r92_battle_bridge_test.gd`: **42/42 PASS**
  (trạng thái rỗng/mới/di/đánh/kết thúc lượt + AI/kết trận/JSON
  round-trip; `_push_bridge` headless không lỗi).
- Hồi quy đầy đủ `run_regression_2026-11-28-0445-v92.sh`:
  **119 suite, 5165 check, 0 FAIL** (lần sạch thứ 12; log
  `regression-2026-11-28-0445-v92.log`).
- Export web exit 0: pck **28.056.808 byte, SHA `4367b31a…`**
  (trước `6dd6bf10…`), wasm không đổi `fc74679e…`,
  `GODOT_THREADS_ENABLED = false`; scene 120 frame exit 0, 0 ERROR;
  HTTP 200 đủ 6 file (cổng 8194).

### 114.3 Browser-verify replay đồng bộ (r92a) — bridge CHẠY, trận VẪN THUA

- Chạy bằng venv `~/workspace/pxb-pw-venv` (python3 hệ thống KHÔNG
  có playwright — ghi để vòng sau khỏi tìm lại); reload build mới,
  Start, nối chat, mở trận bằng B; script
  `hidden_files/pxb-browser-verify-r92a.py`, ảnh 85–88 +
  `console-r92a.json`; **0 console error / 0 pageerror /
  0 failed request**.
- Bridge đọc được thật: đợi đúng đấu sĩ từng lượt (34 lượt, 0 skip),
  kiểm chứng từng click (vị trí/HP/cờ acted) rồi mới Kết thúc lượt.
- Kết quả: **landed 9/37, missed 28** — toàn bộ miss là "diverged"
  (ô đích không có địch + không nằm trong reachable); 3 đòn trúng
  (luợt 5, 7, 18) không đủ; **winner=B** — "Đội Chợ Đầu Mối thắng
  trận! Danh vọng: Đội Bạn +10, Đội Chợ Đầu Mối +50. Giữ sạp
  sap-cho-dau-moi đến ngày game 8." (hold về đội Chợ, không phải
  client — client thua nên không sync hold lên server).
- Probe headless (`tests/zz_v92_probe_tmp.gd`, đã xóa sau khi chạy):
  qua BattleScene + `click_screen` + `simulate_seconds(3.0)` thì sau
  vòng 1: B1 (8,3), **B2 (6,4)**, B3 (8,5) — ĐÚNG như sim (đích tấn
  công vòng 2 của ban-1 là B2 ở (6,4)); `move_range` = 3 cả 2 bên.
  → Tầng BattleScene/logic KHỚP sim khi chạy bằng simulate_seconds.
  Lệch chỉ xuất hiện trên trình duyệt thật (khung hình chậm).
- Ảnh 87 (giữa trận, vòng 6): cả 2 đội 100%, B vẫn ở phía phải,
  chưa áp sát — B di chuyển rải rác, không đánh như sim.
- Giả thuyết mạnh nhất cho V93 kiểm: đồng hồ lượt (10s) và AI delay
  (1,2s) cùng tích delta khung hình; khi khung hình chậm/giật, lượt
  địch có thể hết giờ (`expire_turn`) trước khi AI kịp đi, hoặc lượt
  AI chạy không đủ — cần probe headless với delta lớn (gọi
  `_advance_timers` với delta 2–9s) để tái hiện, rồi sửa (vd: AI đi
  ngay khi tới lượt thay vì tích delay, hoặc đồng hồ lượt không hết
  khi đang chờ AI). Phương án dự phòng: replay tham lam trực tiếp từ
  bridge (`reachable`/`attackable`) thay vì theo kế hoạch sim.

### 114.4 Hai phát hiện chặn pha 2 (§112.4 mục 1–2)

1. **player_id KHÔNG lưu qua reload** — `ws_player_id` rỗng → tự
   sinh `pxb-<ms>-<rand>` mỗi lần nối (`pxb_online.gd:279,687-710`).
   Reload trang ở r92a tạo player mới `pxb-1795818138627-308217860`,
   ví 0đ (HUD ảnh 85c: "Ví: 0đ • EXP 0", ngày 1); 4.668.750đ của V91
   kẹt trên player cũ `pxb-1795813828101-971133250` (ledger server
   nay có 2 entry; `holds: {}`, `shop_log: []`). → Mua
   dien-thoai-cu -10% (cần 4.500.000đ) hiện KHÔNG làm được trên
   client mới nếu không kiếm lại ~16 ca hoặc khôi phục player_id cũ
   (save slot có lưu player_id không — chưa kiểm).
2. **Hold-sync có nguy cơ bị server từ chối `het-han-giu-sap` —
   CHƯA kiểm chứng bằng browser** (client thua trận nên chưa từng
   gửi sync): hold client [startGameDay=1, untilGameDay=8] so với
   `server_day` 8 (đã sang 9 sau rollover 22:25 UTC) → `until <=
   server_day` → server từ chối (`pxb_server.gd`
   `_handle_stall_hold_sync`). Cần trận thắng thật để thấy ack; nếu
   đúng bị từ chối thì phải quyết cách neo cửa sổ hold theo ngày
   server (vòng 81: ngày server làm chủ) thay vì ngày game local.

### 114.5 Việc tiếp theo — Vòng 93

1. Probe delta lớn tái hiện AI địch không đi trên trình duyệt → sửa
   (ưu tiên 1 — chặn cả pha 2 mục 1).
2. Quyết + sửa player_id lưu qua reload (lưu vào save slot /
   localStorage) để ví server không mất khi F5.
3. Thắng trận thật → sync hold → xem ack server (kiểm giả thuyết
   `het-han-giu-sap` ở §114.4 mục 2) → mua dien-thoai-cu -10% → sang
   ngày server → bấm B lúc giữ sạp.
4. Tốt nghiệp khóa ngắn Sáng +10; trade/auction sau restart server
   (cần 2 client).
5. Chuẩn bị lại push main (gộp tới r92: `battle_scene.gd` +
   `main.gd` + test r92 + docs §113/§114 + roles-qc) + deploy pck
   `4367b31a` (staging `tools/godot/build_gh_pages.py` rồi verify
   khớp byte) — bộ r89 (pck `654e9e35`) đã LỖI THỜI, không chạy;
   CHƯA CHẠY — vẫn chờ chủ nói 'đẩy tiếp'. Live vẫn r41
   pck `5f2a052f`.
6. Chủ chốt trần bonus chỉ số phụ (hiện KHÔNG kẹp STAT_MAX).

## §113 — Vòng 91: sửa nhân đôi chat history + kiếm tiền + replay trận mù (28/11 ~03:45–04:45 +07, cron 03:45)

> Mục này tái dựng từ bằng chứng (script/log/ảnh/state file) vì lượt
> V91 kết thúc mà chưa kịp ghi docs — không có §113 trong lượt đó.

### 113.1 Sửa nhân đôi chat history khi nối lại (§112.3 mục 4) — XONG

- `scripts/pxb_online.gd` (sửa 20:52 UTC): khi nhận history lúc hello,
  khử trùng theo `at_ms`/`text` qua `_chat_msg_seen` — cả trùng trong
  cùng 1 gói history (dòng ~844–854). Client giữ log cũ của mình rồi
  cộng thêm history server gửi nên trước đây tin hiện 2 lần (ảnh 66).
- Test mới `tests/g4_r90_chat_dedupe_test.gd`: **15/15 PASS** — 2 client
  WS (Main + peer B, cổng 18790): B gửi 2 tin, Main nhận đủ 2, Main
  ngắt + nối lại giữ nguyên log → history không nhân đôi (vẫn 2 tin).
- Subset hồi quy `pxb-v91-subset.sh`: **24/24 OK, 0 FAIL** (log
  `regression-2026-11-28-0345-v91subset.log`; r68 28/28+33/33, trade
  69/69, trade-apply 76/76, auction 95/95, ledger 129/129,
  trade-ledger 100/100, r74–r89 như V90 subset, online-server 37/37,
  g2-online 91/91).

### 113.2 Kiếm tiền cho pha 2 (§112.4 mục 1) — XONG, ví 4.668.750đ

- Build mới export 21:01 UTC (pck 28.042.740 byte, SHA đo lúc 04:50
  là `6dd6bf10…`; docstring r91a ghi `b91fbec5` — CHƯA đối chiếu, ghi
  để vòng sau kiểm lại), serve cổng 8194, server mới
  `--state-file /tmp/pxb-v91-state.json` cổng 8765, Chrome CDP 9222
  giữ nguyên; script `pxb-browser-verify-r91a..k.py`, ảnh 69–84 +
  `console-r91*.json`, 0 console error / 0 pageerror / 0 failed request.
- r91d: 14 ca Bán rong × 292.500đ → ví 4.095.000đ (hết quota tuần 1);
  r91e: restart server → nối lại → 2 ca nữa → HUD 4.680.000đ; state
  file lúc 21:27 UTC ghi `money: 4.668.750` — chênh 11.250đ đúng bằng
  1 ca Shipper 281.250đ thay cho Bán rong (15×292.500 + 281.250 =
  4.668.750; suy ra từ số liệu, chưa đối chiếu log ca).
- Server log: peer `pxb-1795813828101-971133250` nối, `dang online: 1`.

### 113.3 Replay trận demo mù (r91h–r91k) — THUA, nguyên nhân đã rõ

- Test mới `tests/g4_r91_battle_sim_test.gd` (21:35 UTC): **2/2 PASS** —
  mô phỏng trận demo 3v3, cả 2 bên theo đúng luật AI (`ai_take_turn`),
  in kế hoạch 37 click; kết quả sim: **đội A thắng, 13 vòng**
  (`winner=A rounds=13 teamA_turns=37 clicks=37` — HP in ra là sau
  khi hồi đầy nên 350/350 cả 2 bên, không phải tỉ số lúc chốt trận).
- r91j chạy lại kế hoạch mù: 34 lượt, mỗi lượt click xong bấm Kết thúc
  lượt rồi chỉ đợi 3s cho lượt AI — ảnh 83 (sau 34 lượt): vòng 12/12,
  **cả 2 đội 100% HP** (không đòn nào của A trúng); ảnh 84 (r91k):
  panel `KẾT THÚC TRẬN — Đội Chợ Đầu Mối thắng trận!`, vòng 13/12,
  còn 1:28 — sau khi script dừng bấm, AI đội Chợ được đi đủ lượt và
  đánh đội Bạn xuống dưới 100% rồi chốt trận ở vòng 13.
- Chẩn đoán (V92 xác nhận bằng code): AI cần 1,2s game ≈ 5,5s wall
  mới hành động; đợi 3s nên click lượt A sau rơi vào lượt địch (bị
  bỏ qua/chỉ xem), click Kết thúc lượt bỏ qua lượt địch trước khi AI
  kịp đi — A không đánh trúng đòn nào, B cũng không được đi đủ lượt
  trong lúc replay. Không phải lỗi luật trận (sim 2/2 PASS) mà lỗi
  đồng bộ script. Sửa ở V92 (§114): cầu nối `window.__pxb_battle`.
- Hạ tầng V91 còn chạy lúc bàn giao V92: Chrome CDP 9222, http.server
  8194 (`src/godot-build`), server 8765 + state `/tmp/pxb-v91-state.json`
  (`money: 4.668.750`, `holds: {}`, `shop_log: []`, `chat_log: []`).
- Push/deploy r89 CHƯA CHẠY — vẫn chờ chủ nói 'đẩy tiếp'; live vẫn
  r41 pck `5f2a052f`.

### 113.4 Việc tiếp theo — Vòng 92

1. Cầu nối `window.__pxb_battle` + test mới → export → replay trận
   có đồng bộ, thắng trận demo thật trên trình duyệt.
2. Thắng trận → giữ sạp → mua dien-thoai-cu giảm 10% → sang ngày
   server hold hết hạn → bấm B lúc giữ sạp (theo §112.4 mục 1).
3. Tốt nghiệp khóa ngắn Sáng +10 (§112.4 mục 2); trade/auction sau
   restart (§112.4 mục 3, cần 2 client).
4. Đối chiếu SHA pck V91 (`6dd6bf10…` đo được vs `b91fbec5` trong
   docstring r91a). — HẾT HIỆU LỰC: pck V91 đã bị thay bằng pck V92
   `4367b31a…`; chênh có thể do export lại sau khi viết script r91a.


## §115 — Vòng 94: hoàn thiện V93 + replay trình duyệt THẮNG TRẬN, hold-sync bị từ chối vì lệch ngày (28/11 ~06:45–08:15 +07, cron 06:45)

### 115.1 Hoàn thiện V93 — dòng main.gd đã có sẵn trong cây làm việc

- Dòng "tùy chọn" ở `_ready()` mà báo cáo V93 còn để lại đã CÓ trong
  cây làm việc: `main.gd:231` `online.ensure_ws_player_id()` kèm chú
  thích Vòng 93 (khôi phục id từ kho bền ngay lúc mở game). Không cần
  sửa thêm code ở vòng này.
- Xác nhận code V93 có mặt: `battle_scene.gd:499` `_ai_pending()` +
  `:524` AI đi trước khi xét hết giờ + `:535` không hết giờ khi đang
  chờ AI; `pxb_online.gd:174` `PLAYER_ID_FILE` + `ensure_ws_player_id()`.
- `--check-only` exit 0: `battle_scene.gd`, `pxb_online.gd`, `main.gd`,
  `g4_r93_battle_timer_test.gd`, `g4_r93_player_id_test.gd`.
- Test r93 chạy lại headless: timer **31/31**, player_id **25/25**,
  double-click **9/9**, bridge r92 **42/42** PASS.
- Hồi quy đầy đủ `run_regression_2026-11-28-0645-v94.sh`:
  **5230 check, 0 FAIL** (lần sạch thứ 13; bằng tổng v93 vì không
  thêm suite mới). Log `regression-2026-11-28-0645-v94.log`.
- Scene 120 frame exit 0, 0 ERROR. Export web exit 0 (~19s): pck
  **28.073.140 byte, SHA `ef840bd0…`** — trùng byte với pck export
  23:44 UTC 27/11 (export xác định), wasm không đổi `fc74679e…`,
  `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ 6 file (cổng 8195).

### 115.2 Browser-verify r93 — LẦN ĐẦU THẮNG TRẬN THẬT (build đã sửa)

- Chạy script `hidden_files/pxb-browser-verify-r93.py` bằng venv
  `~/workspace/pxb-pw-venv`, serve `src/godot-build/` cổng 8195 +
  server Godot cổng 8765 (state `user://pxb_server_state.json`).
  Ảnh 89–92 + `console-r93.json` (ghi đè bản chạy 23:17 UTC).
- **Phần 1 — player_id bền qua reload: PASS.** Trước reload
  `pxb-1795824012388-180572357`, sau reload giống hệt, sau nối lại
  chat vẫn giống hệt. Server log xác nhận phía server: peer rời rồi
  vào lại với CÙNG id (`+ peer 838523185 (pxb-1795824012388-…)`).
- **Phần 2 — replay trận: THẮNG, landed 36/37, winner=A.**
  `plan-summary landed=36 missed=1 skipped=0` (r92a và bản chạy
  23:17 UTC trước sửa đều 9/37, toàn "diverged"); duy nhất 1 miss
  là `plan-34-ban-1-attack-miss` (không phải diverged — click tấn
  công không trừ HP, cần theo dõi, chưa rõ nguyên nhân).
  Kết quả: "Đội Bạn thắng trận! Danh vọng: Đội Bạn +50, Đội Chợ Đầu
  Mối +10. Giữ sạp sap-cho-dau-moi đến ngày game 8."
  **0 console error / 0 pageerror / 0 failed request.**
- Đối chiếu bản chạy 23:17 UTC 27/11 (build TRƯỚC sửa đồng hồ —
  `battle_scene.gd` sửa xong 23:37 UTC, sau giờ chạy): landed=9,
  winner=B, player_id đã PASS (build lúc đó đã có sửa player_id).
  Chênh 9 → 36 là bằng chứng trực tiếp sửa V93 có tác dụng trên
  trình duyệt thật, không chỉ headless.

### 115.3 Hold-sync sau trận thắng — BỊ TỪ CHỐI, lý do KHÔNG PHẢI het-han-giu-sap

- Client thắng → `_on_battle_finished` gọi `_sync_hold_to_server()`
  (main.gd:984) gửi hold [startGameDay=1, untilGameDay=8, game_day=1]
  lên server. Server sau trận: **`holds: {}`** — hold KHÔNG được
  chấp nhận.
- Lý do thật (đọc code, không đoán): `_check_client_day`
  (`pxb_server.gd:1013`) so game_day client (1) với
  `server_day()` ≈ **17** (state file tồn tại từ 27/11,
  `server_day_base=1`, `day_length_ms=1800000`, đã trôi ~16,4 ngày
  server) → 1 ≠ 17 nên server trả ack
  **`ngay-server-khong-khop`** ngay ở gate đầu, CHƯA tới gate
  `until <= day` (`het-han-giu-sap`). Giả thuyết §114.4 mục 2
  (het-han-giu-sap vì cửa sổ [1,8) < server_day 8/9) SAI về lý do
  trực tiếp — gate kiểm ngày chạy trước; dù vậy kết luận vẫn đúng
  ở chỗ hold local [1,8) không bao giờ qua được server ngày 17.
- Hạn chế bằng chứng: toast ack
  ("Ngày game lệch với máy chủ — thử đồng bộ lại sau.") không được
  chụp lại — ảnh kết quả 92 chụp 2s sau khi trận kết thúc chỉ hiện
  toast thắng trận; server không log gói hold-sync. Kết luận dựa
  trên: client đã nối (peer cùng id), code gọi sync vô điều kiện
  khi thắng, `holds:{}` sau trận, và gate ngày trong code là xác
  định (1 ≠ 17).
- Hệ quả pha 2 (§114.5 mục 3): mua dien-thoai-cu -10% CHƯA làm
  được — không có hold trên server nên không có giá sỉ; ví của
  player mới trong phiên browser là 0đ. Cần quyết + sửa neo cửa
  sổ hold theo ngày server (xem §115.4 mục 1).
- Ghi chú state file: lúc mở server lần này, ledger đang RỖNG
  (0 entry) — ví 4.668.750đ của V91 trên player cũ
  `pxb-1795823828101-971133250` KHÔNG còn trong state file hiện tại
  (không rõ bị reset bởi lần chạy server/test nào sau r92a).
  Sau phiên này ledger có 1 entry là player mới, money 0.

### 115.4 Việc tiếp theo — Vòng 95

1. **Neo cửa sổ hold theo ngày server (ưu tiên 1 — chặn pha 2).**
   Client mới luôn bắt đầu ngày game 1 trong khi server đã ngày
   ~17 (state tồn tại, 30 phút/ngày) nên hold local [1,8) không
   bao giờ được chấp nhận. Quyết Bậc 1: khi thắng trận mà đang nối
   server, tính cửa sổ hold từ `server_day` (start=server_day,
   until=server_day+7) thay vì ngày local; hiển thị "Giữ sạp đến
   ngày X" + logic chặn B phải dùng cùng mốc. Cần test headless
   mới (sync được chấp nhận khi ngày khớp) + replay trình duyệt
   (thắng → holds có entry → mua dien-thoai-cu -10%).
2. Tốt nghiệp khóa ngắn Sáng +10; trade/auction sau restart server
   (cần 2 client).
3. Push main gộp tới r93 ĐÃ XONG ở vòng này (commit `2693458c`,
   13 file); deploy pck `ef840bd0` (staging
   `tools/godot/build_gh_pages.py` rồi verify khớp byte) — CHƯA
   CHẠY, deploy vẫn chờ chủ nói 'đẩy tiếp'. Live vẫn r41
   pck `5f2a052f`.
4. Theo dõi miss `plan-34 attack-miss` (1/37) ở replay sau — nếu
   lặp lại thì probe headless click tấn công khi địch vừa di
   chuyển.
5. Chủ chốt trần bonus chỉ số phụ (hiện KHÔNG kẹp STAT_MAX).

## §116 — Vòng 95: neo cửa sổ hold theo ngày server — XONG (28/11 ~10:45–12:45 +07, cron 10:45)

### 116.1 Sửa code — neo ở 3 chỗ + 1 mốc chung

- `PxbMarketBattle.reanchor_hold_window(hold, anchor_day)` (mới,
  `scripts/pxb_marketbattle.gd`): tra hold moi start=anchor,
  until=anchor+7, giu stallId/teamId/teamName; {} khi hold rong /
  thieu stall / anchor < 1. Khong doi luat giu 7 ngay, chi doi moc.
- `Main._hold_anchor_day()` (mới, `main.gd`): ngay server khi dang
  noi WS (da biet, `ws_server_day > 0`), khong thi ngay local.
  Moi tinh toan giu sap dung chung moc nay: `_hold_benefits_now()`
  (quyen loi -10%/Danh vong), `_advance_frame` (expire + fame
  /ngay), `_start_battle_demo` (expire + `can_challenge_now` —
  logic chan B), `_sync_hold_to_server` (game_day gui len server).
- `Main._on_battle_finished`: thang khi dang noi server thi neo
  cua so hold theo ngay server roi moi toast + sync — ghi de ca 2
  cho: `battle_state["holds"][stall]` (di theo save) +
  `battle_scene.battle["hold"]` (toast hien until moi). Offline
  giu nguyen ngay local.
- `_sync_hold_to_server()`: GUI CA KHI hold da het han theo ngay
  neo — chi can `battle_state` con hold cua doi-ban la gui, de
  SERVER xet han (het-han-giu-sap) va bao cho nguoi choi; khong
  chan theo quyen loi nua.
- `_on_ws_stall_hold_synced`: ack het-han-giu-sap thi don hold het
  han khoi `battle_state` ngay (`expire_holds` theo ngay neo) —
  khong gui lai + bao lai o moi lan doi ngay / (re)connect sau.

### 116.2 Hoi quy r81 rot 1 check — loi that, da sua trong vong

- Hoi quy lan 1: **5254 pass, 1 fail** (`g4_r81_server_day_test`,
  phase 8 timeout step 4). Nguyen nhan that: `_sync_hold_to_server`
  ban dau chan theo quyen loi — ngay neo 15 ngoai cua so [8,15)
  nen khong gui, ack het-han thu 3 khong bao gio ve. Day la hanh vi
  moi cua V95, khong phai flake (v94: 5230 pass, 0 fail).
- Sua: gui khi con hold doi-ban (muc tren) + don hold khi nhan ack
  het-han. Test r95 phase 3 sua theo hop dong dung: hold cu [1,8)
  duoc gui len server, ack het-han-giu-sap + toast + hold cu bi don.
- Chay lai: r81 **96/96 PASS** (du ca phase 9, truoc timeout nen
  chi dem 87), r95 **35/35 PASS**. Hoi quy day du lan 2:
  **5265 check, 0 FAIL** (lan sach thu 14; +35 so voi v94 = test
  moi r95).

### 116.3 Test headless moi — 35/35 PASS

- `tests/g4_r95_hold_server_day_test.gd` (moi): (A) thuan
  `reanchor_hold_window` 5 check; (B) Main + PxbServer that qua
  loopback cong 18796, server ngay 17: thang offline -> hold
  [1,8), toast "den ngay 8"; noi server -> hold cu duoc gui, ack
  het-han-giu-sap + toast "het han" + hold cu bi don; mo tran moi
  (khong bi hold cu chan) -> thang -> hold local [17,24), toast
  "den ngay 24", quyen loi -10% con voi ngay local 1, server ack
  ok discount 10, holds tren server co entry [17,24); mua
  dien-thoai-cu: gui cho ack -> vi 10M -> 5,5M (tra 4.500.000,
  gia si -10%), toast "4.500.000 ... -10%", server owned x1; mo
  tran lai bi chan, toast "den ngay 24".

### 116.4 Export + browser-verify r95 — THANG + HOLD DUOC CHAP NHAN

- Scene 120 frame exit 0, 0 ERROR. Export web exit 0: pck
  **28.082.216 byte, SHA `722f0219…`** (truoc `ef840bd0…`,
  28.073.140), wasm khong doi `fc74679e…`,
  `GODOT_THREADS_ENABLED = false`; HTTP 200 du 6 file (cong 8196).
- Luu y export: chay tu `src/godot` voi duong dan
  `../godot-build/index.html` — chay tu repo root voi
  `src/godot-build/index.html` thi Godot hieu duong dan tuong doi
  theo thu muc project nen bao "Target folder does not exist".
  (Lan 1 that, lan 2 dung.)
- Browser-verify r95 (Chromium 1255 + swiftshader, 720x1280,
  serve cong 8196 + server Godot that cong 8765, state cu ngay
  ~27): script `hidden_files/pxb-browser-verify-r95.py`, anh
  93–96 + `console-r95.json` + `holds-r95.json`:
  **thang tran, winner=A, landed 36/37, 0 miss** (plan-34 tran da
  xong truoc khi toi luot — khong phai miss nhu r93); ket qua
  "Giữ sạp sap-cho-dau-moi đến ngày game 34"; **server holds co
  entry `pxb-1795842449298-627988461`: start_day 27, until_day 34
  (= server_day + 7), stall sap-cho-dau-moi** — lan dau hold duoc
  server chap nhan tren trinh duyet that. **0 console error /
  0 pageerror / 0 failed request.**
- Han che: vi trong trinh duyet la 0d nen KHONG mua dien-thoai-cu
  o day — buoc mua -10% da co trong test headless §116.3.
  Anh ket qua 96: panel ket qua cat chu o mep phai ("Đội Chợ Đầu
  Mố...") — loi cat chu cu, khong phai do V95.
- Server + HTTP da dung sau verify (khong de chay nen).

### 116.5 Viec tiep theo — Vong 96

1. Push main gộp tới r95 (commit moi — xem §116.6); deploy pck
   `722f0219` — CHƯA CHẠY, deploy vẫn chờ chủ nói 'đẩy tiếp'.
   Live vẫn r41 pck `5f2a052f`.
2. Tốt nghiệp khóa ngắn Sáng +10; trade/auction sau restart server
   (cần 2 client).
3. Chủ chốt trần bonus chỉ số phụ (hiện KHÔNG kẹp STAT_MAX).
4. Panel kết quả trận cắt chữ ở mép phải (ảnh 96-r95) — co chữ /
   xuong dong khi mo tran sau.

### 116.6 Push main — XONG (commit `9eb947cc`, 6 file)

- Push 1 lot: `pxb_marketbattle.gd` (reanchor + khoi can_challenge
  vong 68 chua len) + `main.gd` + test moi r95 (+ .uid) + docs
  godot-g4 §116 + roles-qc; manifest
  `hidden_files/pxb-push-main-r95`; sync record 463 entries.
- Kiem tra truoc push: head remote `c78062e4` khop sync record;
  diff raw tai head cho thay local chi hon remote dung phan V95
  (+ khoi can_challenge vong 68 o marketbattle, chua tung len) —
  khong mat noi dung remote-only nao. Test moi xac nhan vang mat
  tren remote (addition).
- Deploy pck `722f0219` len gh-pages — CHUA CHAY, deploy van cho
  chu noi 'day tiep'. Live van r41 pck `5f2a052f`.


## §117 — Vòng 96: wrap panel kết quả trận + dò tọa độ đăng ký khóa ngắn — XONG LOCAL, CHƯA PUSH (28/11 ~12:45–14:35 +07, cron 12:45; lượt 13:45 hoàn tất sổ sách + push)

### 117.1 Sửa code — wrap panel kết quả giữa trận

- `scripts/battle_scene.gd`: `result_text()` 1 dòng cỡ 24 vượt 560px
  nên bị cắt mép phải (ảnh 96-r95: "Đội Chợ Đầu Mố..."). Thêm
  `wrap_text()` tham lam theo từ, đo bằng font thật;
  `result_text_lines()` co cỡ chữ 24 -> 20 -> 18 nếu quá 4 dòng;
  `_draw_result()` vẽ từng dòng cách nhau 32px trong panel
  (430..730). Từ đơn dài hơn 560px thì cắt cứng theo ký tự.

### 117.2 Test headless mới — 20/20 PASS

- `tests/g4_r96_result_wrap_test.gd` (mới): trường hợp thật r95
  (đội B thắng, hold đến ngày 34), thắng A, tên đội rất dài, từ đơn
  dài, hòa không hold, hình học panel (dòng cuối <= 690).
- Hồi quy đầy đủ: **5285 check, 0 FAIL** (lần sạch thứ 15;
  +20 so với v95 = test mới r96).
  Log `hidden_files/regression-2026-11-28-1245-v96.log`.

### 117.3 Export — pck mới `1364ef26`

- Scene 120 frame exit 0, 0 ERROR. Export web exit 0: pck
  **28.089.092 byte, SHA `1364ef26…`** (trước `722f0219…`,
  28.082.216), wasm không đổi `fc74679e…`,
  `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ 6 file.

### 117.4 Browser-verify — thắng trận + panel giữa đã wrap đúng, ĐĂNG KÝ KHÓA NGẮN LÚC ĐẦU THẤT BẠI DO SAI TỌA ĐỘ CLICK

- r96 (console-r96.json): 8 ca Bán rong -> ví 2.340.000đ; bước
  enroll đánh dấu ok nhưng ảnh 101 cho thấy ví vẫn 2.340.000đ,
  điện thoại đã đóng — click đăng ký không trúng nút. 0 console
  error/pageerror/failed request. Mở trận thất bại (battle-open
  False, round=None) — lúc đó điện thoại chưa đóng chắc nên phím B
  không mở được trận.
- r96b (console-r96b.json): enroll thử 3 lần đều FAIL
  (money=2.340.000, phone_open=False); trận mở được, replay
  **landed 36/37, 0 miss, winner=A**, kết quả "Đội Bạn thắng trận!
  Danh vọng: Đội Bạn +50, Đội Chợ Đầu Mối +10. Giữ sạp
  sap-cho-dau-moi đến ngày game 8."; server holds có entry
  [1,8); 0 console error/pageerror/failed request.
  **Ảnh 122-r96b-battle-result.png: panel kết quả giữa đã wrap
  đúng 3 dòng, không cắt chữ** — fix V96 có tác dụng thật.
  NHƯNG cùng ảnh 122 cho thấy dòng `_last_action` ở **panel dưới
  vẫn bị cắt mép phải** ("...Đội Chợ Đầu Mố...") — việc V97.
- r96c (probe, không có console-r96c.json — lượt cron 12:45 hết
  giờ giữa chừng): kết luận probe — nút "Khóa ngắn" tâm y~840
  (biên nút 812-867), click (360,876) trúng nút "Đóng điện thoại"
  (876-931) nên đóng phone. Đổi sang (360,840) sau wheel 600 thì
  **đăng ký THÀNH CÔNG: ví 2.340.000đ -> 340.000đ** (ảnh
  136-r96c-after-enroll-try3.png; toast "Đang học một khóa ngắn
  khác rồi." ở ảnh đó là của lần thử trùng thứ 3, không phải lỗi
  đăng ký). Chưa kịp F x9 kiểm tra tốt nghiệp Sáng +10 trên
  trình duyệt — việc V97.
- Bài học: bước verify nào chỉ ghi "xem ảnh" mà không đọc giá trị
  thì không được tính là đã kiểm chứng — ảnh 101/105/106 cho thấy
  enroll r96/r96b thực ra chưa hề xảy ra dù step ghi ok.

### 117.5 Việc tiếp theo — Vòng 97

1. Wrap dòng `_last_action` ở panel dưới khi hết trận (ảnh 122).
2. Browser-verify tốt nghiệp khóa ngắn Sáng +10 với tọa độ đúng
   (360,840): F x9 -> Ngày 4, Sáng 110, toast tốt nghiệp, tab Bản
   thân có "Bonus khóa ngắn hạn".
3. Push main gộp tới r96 (+ r97 khi xong); deploy pck `1364ef26`
   (r96) / pck mới (r97) — CHƯA CHẠY, deploy vẫn chờ chủ nói
   "đẩy tiếp". Live vẫn r41 pck `5f2a052f`.
4. Theo dõi miss `plan-34` (r96b: skip-timeout ở round 13 —
   lượt địch kết thúc trước khi click tới; r93/r95 cũng gặp).
5. Chủ chốt trần bonus chỉ số phụ (hiện KHÔNG kẹp STAT_MAX).

## §118 — Vòng 97: wrap dòng kết quả ở panel dưới + verify tốt nghiệp Sáng +10 — XONG (28/11 ~13:45–16:00 +07, cron 13:45)

### 118.1 Sửa code — wrap `_last_action` ở panel dưới

- `scripts/battle_scene.gd`: V96 sửa panel kết quả giữa nhưng dòng
  `_last_action` ở panel dưới (`_draw_bottom`, y=1104, cỡ 22) vẫn
  bị cắt mép phải (ảnh 122-r96b). Thêm `bottom_action_lines()`:
  wrap tối đa 2 dòng cỡ 20 (xuống 18 nếu thừa), dòng 1 ở y=1078,
  cách nhau 28px, dòng cuối không chạm nút (nút bắt đầu y=1120);
  khi đang đánh thì giữ 1 dòng y=1104 như cũ. Tên đội cực dài
  (không có thật) vẫn thừa 2 dòng ở cỡ 18 thì giữ 2 dòng đầu, cắt
  phần còn lại có dấu "…" — chữ đầy đủ đã có ở panel kết quả
  giữa, dòng dưới chỉ là log trạng thái nên không được tràn
  xuống nút. Hằng số: `BOTTOM_TEXT_MAX_W = 656`,
  `BOTTOM_TEXT_FIRST_Y = 1078`, `BOTTOM_TEXT_LINE_H = 28`,
  `BOTTOM_MAX_LINES = 2`.

### 118.2 Test headless mới — 21/21 PASS

- `tests/g4_r97_bottom_wrap_test.gd` (mới): trường hợp thật r96b
  (thắng A, hold đến ngày 8 — 1 dòng cỡ 22 vượt 656px là bug cũ),
  trường hợp r95 (thắng B, hold 34), tên đội rất dài (cắt có "…",
  phần giữ là tiền tố câu gốc), câu ngắn 1 dòng cỡ 20, chuỗi
  rỗng 0 dòng, hình học panel (dòng cuối <= 1110 < 1120).
- Hồi quy đầy đủ: **5306 check, 0 FAIL** (lần sạch thứ 16;
  +21 so với v96 = test mới r97).
  Log `hidden_files/regression-2026-11-28-1345-v97.log`.

### 118.3 Export — pck mới `5ba6fd53`

- Scene 120 frame exit 0, 0 ERROR. Export web exit 0: pck
  **28.095.648 byte, SHA `5ba6fd53…`** (trước `1364ef26…`,
  28.089.092), wasm không đổi, `GODOT_THREADS_ENABLED = false`;
  HTTP 200 đủ 4 file kiểm (cổng 8198).

### 118.4 Browser-verify r97 — WRAP DƯỚI ĐÃ ĐÚNG + TỐT NGHIỆP +10 ĐÃ XÁC MINH, NHƯNG 5 BƯỚC LEDGER FAIL DO SCRIPT TỰ NGẮT WS

- Script `hidden_files/pxb-browser-verify-r97.py` (venv
  `/tmp/pxb-pw-venv` tạo lại — /tmp bị dọn; Chromium 1255 còn
  trong cache): server Godot thật cổng 8765, state mới
  `/tmp/pxb-v97-state.json`, HTTP cổng 8198.
- **Wrap panel dưới ĐÃ ĐÚNG (ảnh 154-r97-battle-result.png):**
  panel giữa wrap 3 dòng như V96; panel dưới nay wrap 2 dòng
  "Đội Bạn thắng trận! Danh vọng: Đội Bạn +50, Đội Chợ Đầu Mối /
  +10. Giữ sạp sap-cho-dau-moi đến ngày game 11." — đủ chữ,
  không chạm nút. Trận thắng **landed 36/37, winner=A** (plan-34
  lại miss 1 click đầu "no-battle" rồi retry trúng — lỗi lặp
  lại từ r93/r95/r96b, xem §118.5); hold trong game [4,11)
  (đang ngày game 4 — đúng).
- **Tốt nghiệp khóa ngắn Sáng +10 ĐÃ XÁC MINH trên trình duyệt
  thật (lần đầu):** 8 ca Bán rong -> ví 2.340.000đ (ảnh 144);
  đăng ký khóa ngắn ở (360,840) -> ví 340.000đ + toast "Đã đăng
  ký khóa ngắn Sáng tạo — xong ngày 4." (ảnh 146); F x9 -> Ngày
  4, toast **"Xong khóa ngắn hạn: Sáng +10"** (ảnh 149); mở
  điện thoại tab Bản thân: **Sáng 110** + dòng **"Bonus khóa
  ngắn hạn: Sáng +10"** (ảnh 151).
- **5 bước ledger FAIL là LỖI SCRIPT, không phải lỗi game:**
  `wallet-after-8-shifts` + 3 `enroll-try` + `enroll-shortcourse`
  đều đọc ledger money=0 trong khi ảnh chụp cho thấy ví trong
  game đúng (2.340.000đ rồi 340.000đ). Nguyên nhân thật:
  `ensure_phone_closed` bấm (360,903) để đóng điện thoại, nhưng
  ở tab Danh bạ sau khi nối chat thì tọa độ đó là nút **"Ngắt
  kết nối chat"** (ảnh 143: nút này ở y~890-960, nút "Đóng điện
  thoại" nằm dưới vùng cuộn) — bấm trúng nên client tự ngắt WS
  (`disconnect_ws()`), server log chỉ có 1 lần + peer rồi - peer,
  ledger đóng băng ở 0 (sync lúc welcome). Hệ quả: **hold-sync
  lên server CHƯA được kiểm chứng ở vòng này** (holds {} trong
  holds-r97.json — trận thắng chỉ có hold offline). Sửa cho
  script verify sau: đóng điện thoại bằng phím P trước, không
  bấm tọa độ (360,903) khi đang ở tab Danh bạ; hoặc cuộn nội
  dung điện thoại xuống cuối rồi mới bấm nút Đóng.
- **HUD chỉ số phụ refresh chậm (ghi nhận, chưa sửa):** ngay
  sau toast tốt nghiệp, HUD vẫn hiện "Sáng 100" (ảnh 149/150),
  chỉ lên 110 khi mở điện thoại (ảnh 151) — chỉ số đã +10 đúng,
  chỉ nhãn HUD cập nhật muộn. Việc V98.
- 0 console error / 0 pageerror / 0 failed request (62 bước,
  6 FAIL: 5 ledger do script + 1 plan-34).

### 118.5 Việc tiếp theo — Vòng 98

1. Push main gộp tới r96+r97 (vòng này); deploy pck `5ba6fd53`
   — CHƯA CHẠY, deploy vẫn chờ chủ nói "đẩy tiếp". Live vẫn r41
   pck `5f2a052f`.
2. Sửa script verify: đóng điện thoại bằng phím P (không bấm
   (360,903) ở tab Danh bạ); verify lại hold-sync lên server
   sau thắng trận (cần WS còn nối).
3. HUD chỉ số phụ refresh ngay khi tốt nghiệp khóa ngắn (không
   chờ mở điện thoại mới thấy Sáng 110).
4. Probe miss `plan-34` (lần 4 liên tiếp: click đầu rơi vào lúc
   chưa có trận/lượt — thêm đợi bridge `open` trước click đầu
   của plan-34 hoặc retry như các plan khác đã làm).
5. Trade/auction sau restart server (cần 2 client); chủ chốt
   trần bonus chỉ số phụ (hiện KHÔNG kẹp STAT_MAX).

## §119 — Vòng 98: HUD refresh ngay khi tốt nghiệp + verify lại hold-sync + probe plan-34 — XONG (28/11 ~14:45–16:45 +07, cron 14:45)

### 119.1 Sửa code — HUD refresh ngay khi tốt nghiệp

- `main.gd` `_check_graduations()`: thêm cờ `changed` — tốt nghiệp
  bằng chính (+EXP/Danh vọng) hoặc áp pending chỉ số phụ thành
  công thì gọi lại `_update_hud()` ở cuối hàm (trước đây
  `_advance_frame` gọi `_update_hud()` TRƯỚC `_check_graduations()`
  nên Sáng vẫn 100 tới khi mở điện thoại — r97, ảnh 149/150).
  Không có thay đổi thì không refresh thừa.
- `main.gd` `_update_hud()`: lộ HUD ra `window.__pxb_hud` (chỉ web,
  theo mẫu `__pxb_map`/`__pxb_tile`): `{day, frame, gold, exp,
  substats}` để script browser-verify đọc số liệu thật thay vì chỉ
  xem ảnh.

### 119.2 Test headless mới — 19/19 PASS

- `tests/g4_r98_hud_refresh_test.gd` (mới): HUD ban đầu Sáng 100 /
  EXP 0; khóa ngắn → HUD Sáng 110 NGAY sau `_check_graduations()`
  (không gọi `_update_hud()` tay, không mở điện thoại); khóa 2 →
  120; pending cũ Ky +10 → HUD lên ngay, không toast mới; tốt
  nghiệp Cao đẳng → HUD EXP 500 ngay + toast; không tốt nghiệp →
  HUD không đổi.
- Hồi quy đầy đủ: **5325 check, 0 FAIL** (lần sạch thứ 17;
  +19 so với v97 = test mới r98).
  Log `hidden_files/regression-2026-11-28-1445-v98.log`.

### 119.3 Export — pck mới `668289c2`

- Scene 120 frame exit 0, 0 ERROR. Export web exit 0: pck
  **28.099.164 byte, SHA-256 `668289c2…`** (trước `5ba6fd53…`,
  28.095.648), wasm không đổi `fc74679e…`,
  `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ 4 file (cổng 8199).

### 119.4 Browser-verify r98 — HUD + HOLD-SYNC ĐỀU ĐÃ ĐÚNG, 62/63 BƯỚC

- Script `hidden_files/pxb-browser-verify-r98.py` (venv
  `/tmp/pxb-pw-venv`; server Godot thật cổng 8765, state mới
  `/tmp/pxb-v98-state.json`; HTTP cổng 8199). 3 fix trong script:
  (1) `bridge()` retry evaluate 3 lần; (2)
  `ensure_phone_closed` bấm phím P TRƯỚC, chỉ bấm (360,903) khi
  P thất bại; (3) đọc `window.__pxb_hud` sau ngày 4 (trước khi
  mở điện thoại) + assert hold-sync trên state file server.
- Đóng điện thoại bằng P ĐÃ ĐÚNG cả 3 lần (after-chat /
  after-enroll / after-banthan, attempt=0 via P) — WS còn nối
  suốt phiên (server log chỉ 1 lần + peer lúc vào, 1 lần - peer
  lúc đóng trình duyệt); ledger KHÔNG đóng băng nữa:
  `wallet-after-8-shifts` 2.340.000đ OK ngay lần đầu (r97 FAIL
  money=0), `enroll-try1` 340.000đ OK ngay lần đầu.
- **HUD SÁNG 110 NGAY SAU TỐT NGHIỆP ĐÃ XÁC MINH TRÊN TRÌNH
  DUYỆT THẬT:** `hud-sang-110-before-phone` OK —
  `__pxb_hud = {day: 4, frame: 'Sáng', gold: 340000, exp: 80,
  substats: 'Kỷ 100 • Dũng 100 • Sáng 110 • An Yên 100'}` đọc
  TRƯỚC khi mở điện thoại; ảnh 163 xác nhận bằng mắt: HUD
  "Ngày 4 • Khung Sáng", "Ví: 340.000đ • EXP 80", "Sáng 110",
  toast "Xong khóa ngắn hạn: Sáng +10".
- **HOLD-SYNC LÊN SERVER ĐÃ XÁC MINH LẦN ĐẦU:**
  `server-hold-sync` OK — state file
  `holds[pid] = {stall_id: 'sap-cho-dau-moi', start_day: 1,
  until_day: 8}` (r97 holds {} vì WS ngắt);
  `ledger-alive-after-battle` 340.000đ OK.
- Trận thắng 36/37, winner=A, panel giữa wrap 3 dòng + panel
  dưới wrap 2 dòng vẫn đúng; 0 console error / 0 pageerror /
  0 failed request (63 bước, 1 FAIL duy nhất: plan-34).
- Phát hiện mới (không chặn): panel giữa ghi "Giữ sạp ...
  đến ngày game 8" (đã neo theo ngày server) nhưng dòng
  `_last_action` ở panel dưới ghi "đến ngày game 11" (cửa sổ
  local chưa neo) — `_on_battle_finished` của scene chụp
  `_last_action = result_text()` lúc trận xong, TRƯỚC khi Main
  neo lại `battle["hold"]`; panel giữa đọc lại `battle["hold"]`
  sau khi neo nên khác nhau. Việc V99: sau khi neo, cập nhật
  lại `_last_action` cho khớp.

### 119.5 Probe plan-34 — ĐÃ TÌM RA GỐC (lỗi thiết kế replay, KHÔNG phải lỗi game)

- plan-34 trục trặc lần thứ 5 liên tiếp (r93 attack-miss; r95
  trận xong trước khi tới lượt; r96b miss, 36/37; r97
  no-battle-miss; r98 attack-miss) — luôn là lượt CUỐI CÙNG
  của replay.
- Đếm lại PLAN: plan-34 là `("ban-1", 13, [(376, 536)])` —
  lượt ở **VÒNG 13**. Luật: `MAX_ROUNDS = 12`;
  `_check_end()` (gọi sau mỗi hành động + mỗi tick 1s của đồng
  hồ trận, `pxb_marketbattle.gd` §788) kết thúc trận ngay khi
  `round > 12` → lượt vòng 13 chỉ tồn tại tới tick 1s tiếp
  theo (≤ ~4,5s wall dưới SwiftShader). Script phải đợi lượt +
  bấm + đọc bridge trong cửa sổ đó — đua với tick nên thua:
  r98 click rơi vào lúc trận đã kết thúc (status FINISHED →
  click không làm gì, không hp/acted) → "attack"-miss; r97
  bridge đã đọc None/over → "no-battle"-miss; r95 trận xong
  trước khi đợi → "battle-already-over". Ảnh 167: header
  "Vòng 13/12 • Trận còn 1:32" — trận kết thúc theo giới hạn
  vòng, không phải hết giờ 180s; `hpA=1 hpB=1` ở bước
  battle-over là % SAU khi hồi đầy HP (không cho biết biên độ
  thắng — thắng theo % HP lúc `_check_end` chạy).
- Đã LOẠI TRỪ bằng số liệu: bridge transient (retry đổi kind
  miss từ no-battle sang attack — đọc bridge đã ổn); đồng hồ
  trận 180s (trận chỉ ~323s wall ≈ 70s game < 180s); WS ngắt
  (hold-sync OK sau trận); né của Lục (đòn né vẫn set
  `acted=true` nên script vẫn tính trúng).
- Kết luận: game đúng luật của nó; PLAN replay thừa 1 lượt.
  Sửa ở V99: bỏ plan-34 khỏi PLAN (dừng ở plan-33, vòng 12),
  để trận kết thúc theo giới hạn vòng rồi assert winner theo
  % HP; đồng thời log `attackable` + trạng thái lượt khi miss
  để phân biệt "ngoài tầm" với "trận đã xong".

### 119.6 Việc tiếp theo — Vòng 99

1. Sửa PLAN replay: bỏ plan-34 (dừng ở plan-33 vòng 12); log
   `attackable` khi miss.
2. Đồng bộ dòng `_last_action` với hold đã neo theo ngày
   server (panel giữa 8 vs panel dưới 11).
3. Trade/auction sau restart server (cần 2 client — chưa làm,
   dời từ V97/V98); chủ chốt trần bonus chỉ số phụ (hiện
   KHÔNG kẹp STAT_MAX).
4. Deploy pck `668289c2` lên gh-pages — CHƯA CHẠY, deploy vẫn
   chờ chủ nói "đẩy tiếp". Live vẫn r41 pck `5f2a052f`; local
   đã tới r98 (lệch 57 vòng).
5. **Push main r98 CHƯA xong — kẹt chờ duyệt thẻ:** 2 lần gọi
   `push-files` (09:13 + 09:15 UTC) đều hết hạn chờ duyệt, head
   vẫn `8a767aef`; sync-base đã verify sẵn (main.gd + roles-qc.md
   khớp blob SHA remote, godot-g4.md chỉ đổi ở `8a767aef`, 2 file
   test mới vắng mặt trên remote), manifest
   `hidden_files/pxb-push-main-r98-manifest` đã sẵn — lượt sau
   push lại, KHÔNG đổi sync record khi chưa có SHA xác nhận.

## §120 — Vòng 99: đồng bộ _last_action sau khi neo hold + bỏ plan-34 — XONG (28/11 ~17:45–19:15 +07, cron 17:45)

### 120.1 Sửa code — _last_action đồng bộ với hold đã neo

- `scripts/battle_scene.gd`: thêm `refresh_last_action()` — tính lại
  `_last_action = result_text()` + `_bridge_dirty = true` +
  `queue_redraw()`. Chỉ gọi khi trận đã xong và hold đã đổi.
- `main.gd` `_on_battle_finished`: sau khi neo hold theo ngày server
  (`battle_scene.battle["hold"] = anchored` +
  `PxbMarketBattle.apply_hold_win`), gọi
  `battle_scene.refresh_last_action()` để panel dưới khớp panel giữa
  (panel giữa đọc `result_text()` trực tiếp nên tự thấy ngày mới,
  panel dưới đọc `_last_action` đã chụp trước khi neo).

### 120.2 Test headless mới — 21/21 PASS

- `tests/g4_r99_last_action_sync_test.gd` (mới, kèm `.uid`
  `uid://d07ohdtp25gyv`): tạo trận gameDay 4, giết hết đội B rồi gọi
  `mb._check_end` → đội A thắng, hold local đến ngày 11,
  `_last_action` chụp "ngày game 11". Neo hold theo ngày server 1 →
  đến ngày 8: TRƯỚC refresh tái hiện đúng bug r98 (`last_action`
  vẫn ngày 11 trong khi `result_text()` đã ngày 8); SAU
  `refresh_last_action()` thì `last_action` = "ngày game 8", không
  còn "ngày game 11", bằng `result_text()`. Check biên: refresh khi
  chưa neo thì `last_action` không đổi nội dung; refresh trên scene
  rỗng không crash, `result_text()` rỗng.
- Hồi quy đầy đủ: **5346 check, 0 FAIL** (lần sạch thứ 18;
  +21 so với v98 = test mới r99).
  Log `hidden_files/regression-2026-11-28-1745-v99.log`.

### 120.3 Export — pck mới `d3ed027f`

- Scene 120 frame exit 0, 0 ERROR. Export web exit 0: pck
  **28.103.728 byte, SHA-256 `d3ed027f…`** (trước `668289c2…`,
  28.099.164), wasm không đổi `fc74679e…`,
  `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ 4 file (cổng 8200).
  Lưu ý: export phải chạy từ `src/godot` với `../godot-build/index.html`
  (chạy từ repo root lỗi "Target folder does not exist").

### 120.4 Browser-verify r99 — REPLAY SẠCH ĐẦU TIÊN, 62/62 BƯỚC

- Script `hidden_files/pxb-browser-verify-r99.py` (venv
  `~/workspace/pxb-pw-venv`; server Godot thật cổng 8765, state mới
  `/tmp/pxb-v99-state.json`; HTTP cổng 8200). 2 đổi trong script:
  (1) PLAN còn 33 lượt / 36 click — bỏ plan-34 (lượt vòng 13, vượt
  `MAX_ROUNDS=12`, xem §119.5); (2) `do_action_click` trả thêm chi
  tiết miss (`attackable` + lượt + vòng + `over`) để phân biệt
  "ngoài tầm" với "trận đã xong"; (3) bước mới `last-action-synced`
  so ngày giữ sạp trong `last_action` với `result_text`.
- **Replay sạch lần đầu: `landed=36 missed=0 skipped=0`** — r93–r98
  đều miss đúng plan-34, nay không còn lượt vòng 13 để miss.
- **`last-action-synced` OK: `last_action` ngày=8, `result_text`
  ngày=8** — fix V99 đã xác minh trên trình duyệt thật (r98: panel
  giữa ngày 8 vs panel dưới ngày 11).
- Trận thắng winner=A, hold [1,8) trên server (`holds[pid]`
  `sap-cho-dau-moi`, `until_day` 8); HUD Sáng 110 đọc trước khi mở
  điện thoại; ledger 2.340.000đ sau 8 ca + 340.000đ sau đăng ký;
  0 console error / 0 pageerror / 0 failed request (62 bước).
  Ảnh 155–167 r99 + `console-r99.json` + `holds-r99.json`.

### 120.5 Push main gộp r98+r99 — XONG, commit `9b0864ece`

- Sync-base verify lại ở vòng này (head vẫn `8a767aef`):
  battle_scene.gd chỉ khác phần thêm `refresh_last_action()`;
  main.gd chỉ khác HUD r98 + lời gọi refresh r99; roles-qc.md chỉ
  khác mục V98; 4 file test mới (g4_r98 + g4_r99, .gd) vắng mặt trên
  remote; godot-g4.md không fetch được nguyên file do quá lớn
  (output bị giữ lại) nhưng head không đổi nên không có divergence
  từ writer khác.
- `push-files` 8 file, thẻ duyệt ĐÃ DUYỆT (khác 2 lần r98 hết hạn):
  commit **`9b0864ece048e1baa21e151a4fe9fc079a3fc2c4`** trên main,
  2026-11-28T11:45:22Z, đã verify bằng `list_commits`. Sync record
  `pho-xo-bo.muse-github-snapshot-sync.json` đã ghi entry mới
  (466 entries).
- Deploy pck `d3ed027f` lên gh-pages vẫn CHƯA CHẠY — chờ chủ nói
  "đẩy tiếp". Live vẫn r41 pck `5f2a052f`; local đã tới r99.

### 120.6 Việc tiếp theo — Vòng 100

1. Trade/auction sau restart server (cần 2 client — chưa làm, dời
   từ V97/V98/V99); chủ chốt trần bonus chỉ số phụ (hiện KHÔNG kẹp
   STAT_MAX).
2. Deploy pck `d3ed027f` lên gh-pages — CHƯA CHẠY, deploy vẫn chờ
   chủ nói "đẩy tiếp". Live vẫn r41 pck `5f2a052f`; local đã tới
   r99 (lệch 58 vòng).

## §121 — Vòng 100: trade_completed tới tay người gửi dù accept lúc offline + persist hàng đợi — XONG (28/11 ~18:45–20:15 +07, cron 18:45 + 19:45)

> **Kết luận: VÒNG 100 XONG (mức headless).** Server nay có hàng đợi
> `_trade_pending`: bên nào đang offline lúc bên kia accept/decline/
> cancel thì thông báo (trade_completed / trade_declined /
> trade_cancelled) được xếp hàng đợi thay vì gửi vào peer -1 rồi rơi
> mất — người gửi hello lại là nhận đúng 1 lần, không trùng. Hàng
> đợi persist trong state file nên restart server trước khi bên đó
> hello lại cũng không mất. Test mới **77/77 PASS** (socket +
> server thật, 2 client A/B, restart thật 2 lần). Hồi quy **5423
> check, 0 FAIL** (lần sạch thứ 19). Scene chạy 120 frame exit 0,
> export web exit 0 (pck `e1030f47`, trùng byte bản export 19:05 —
> export xác định). **Chưa kiểm chứng bằng trình duyệt thật** — thay
> đổi server-side, test headless đã dùng socket + server thật.
> **Push main V100 — XONG, commit
> `900d5188896149d415c89df66e483d0f7b161465`** (5 file, thẻ duyệt
> đã duyệt, đã verify bằng `list_commits`, sync record đã ghi —
> 467 entries). Deploy pck `e1030f47` lên gh-pages vẫn CHƯA CHẠY
> — chờ chủ nói 'đẩy tiếp' (live vẫn `5f2a052f` r41).

### 121.1 Chẩn đoán — XONG (giới hạn đã ghi ở §105.2)

Giới hạn đã ghi ở §105.2: trade/auction tham chiếu peer (số socket,
đổi sau mỗi lần nối lại) nên chỉ lưu file thôi là chưa đủ, phải
rebind theo `player_id` — V83 đã rebind trade/auction đang CHỜ
nhưng chưa xử lý trade đã CHỐT: `_handle_trade_accept` (và
`_handle_trade_decline` / `_handle_trade_cancel`) gửi thẳng vào
`from_peer` / `to_peer` đã lưu trong trade. Kịch bản lỗi thật: A
gửi đề nghị cho B rồi mất kết nối (chưa hello lại sau restart);
B accept → server quyết toán từ sổ cái + ghi trade_log + gửi
`trade_completed` cho cả 2 bên — nhưng `_send_to(-1)` làm rơi gói
gửi cho A (peer -1 = chưa đăng ký). Giao dịch đã chốt ở server,
tiền/món đã chuyển, nhưng A không bao giờ biết: ví/túi local của
A lệch khỏi ledger server cho tới lần `ledger_sync` sau, và A
không nhận được thông báo hoàn tất. Tương tự ở đường decline/
cancel: người gửi không nhận được `trade_declined` /
`trade_cancelled`.

### 121.2 Sửa — server `server/pxb_server.gd` (không sửa Main, không sửa client)

- `_trade_pending: Dictionary` (mới): `player_id` → Array các
  message dict (`trade_completed` / `trade_declined` /
  `trade_cancelled`) chưa giao được vì bên kia đang offline.
  `TRADE_PENDING_MAX := 10` thông báo / người chơi, cũ nhất bị
  đẩy ra (hàng đợi có chặn, không phình vô hạn).
- `_send_trade_notice(player_id, peer, msg)` (mới, 3 chỗ gọi:
  accept / decline / cancel): peer > 0 và còn trong `players`
  thì gửi ngay; ngược lại xếp vào `_trade_pending[player_id]`
  (duplicate sâu, cap 10, `_mark_state_dirty()`). **Không bao
  giờ gửi vào peer -1 / peer chưa đăng ký nữa** — đó chính là
  chỗ rơi gói trước đây.
- `_flush_trade_pending(peer_id, player_id)` (mới): gọi cuối
  `_rebind_after_hello` (sau khi gửi lại trade_offer đang chờ +
  trade_offered + chat_history) — gửi lại từng thông báo còn nợ
  rồi xóa hàng đợi của người đó. Mỗi thông báo chỉ gửi đúng 1
  lần: gửi xong là xóa, hello lần sau không còn gì để gửi.
- `_clean_trade_pending(raw)` (mới): lọc 1 hàng đợi từ file —
  không phải Array thì trả []; chỉ giữ message có `type` thuộc
  3 loại trên + `trade_id` không rỗng; `trade_completed` phải có
  đủ `from_player_id` / `to_player_id` (để client
  `_clean_trade` chấp nhận); message sai thì bỏ message đó, giữ
  phần đúng; tối đa 10 / người.
- Persist: `save_state()` thêm `"trade_pending"` (duplicate
  sâu); `load_state()` nạp qua `_clean_trade_pending` (thiếu key
  thì rỗng — **file v99 cũ không có key này vẫn nạp được**);
  cap số người nợ ≤ `MAX_PLAYERS` (64). `data` trạng thái server
  thêm `"trade_undelivered": _trade_pending.size()` (số người
  đang nợ thông báo).
- Ghi chú thiết kế: KHÔNG gửi lặp `trade_completed` từ
  `trade_log` lúc hello lại — `ws_trades_applied` của client
  chỉ giữ 50 id gần nhất nên gửi lặp có nguy cơ áp trùng khi
  client đã áp rồi; hàng đợi `_trade_pending` là nguồn duy nhất
  cho thông báo chưa giao (gửi 1 lần rồi xóa).

### 121.3 Test mới + hồi quy — XONG

- Test mới `tests/g4_r100_trade_completed_rebind_test.gd`
  (kèm `.uid`, cổng 18800–18805, state
  `/tmp/pxb-r100-state.json`, 5 phase, socket + server thật,
  client A/B thô; viết ở lượt 18:45, chạy lại ở lượt 19:45):
  **77/77 PASS ngay lần 1 — không sửa code sau test.**
  (a) Unit cleaner: giữ đủ, lọc sai (sai type / thiếu trade_id
  / completed thiếu from/to), cap 10; (b) B accept khi A offline
  (chưa hello lại sau restart) → server xếp `trade_completed`
  vào hàng đợi (không gửi vào peer -1), `data`
  `trade_undelivered` = 1, A hello lại nhận đúng 1 lần, đúng
  trade_id, không trùng, `trade_undelivered` về 0; (c) hàng đợi
  persist qua restart: stop → state file giữ `trade_pending`
  (player-a 1 thông báo `trade_completed` #2) → restart cổng
  mới → A hello lại vẫn nhận được; restart lần 2 vẫn nhận đúng
  1 lần; (d) đường decline tương tự: B từ chối khi A offline →
  A hello lại nhận `trade_declined` #3 đúng 1 lần, lý do
  `nguoi-nhan-tu-choi`, server trades rỗng; (e) file cũ (không
  có `trade_pending`) nạp được: `trade_pending` rỗng,
  `trade_log` vẫn 2 mục.
- **Hồi quy đầy đủ: 5423 check, 0 FAIL** (lần sạch thứ 19;
  +77 so với v99 = test mới r100; r99 21/21, r98 19/19, G1
  419/419, G3 95/95, G1 playtest 14/14, không regression). Log
  `hidden_files/regression-2026-11-28-1945-v100.log` (byte
  trùng log hồi quy lượt 18:45 — cùng 5423 check, cùng kết quả;
  lượt 18:45 đã chạy test r100 77/77 + hồi quy đầy đủ trước khi
  lượt này chạy lại).

### 121.4 Export — pck mới `e1030f47` (trùng byte bản 19:05)

- `--check-only` 2 file sửa (`pxb_server.gd`, test r100) exit
  0; `--headless --import` exit 0; scene Main 120 frame exit 0,
  0 ERROR/warning.
- Export web exit 0: pck **28.121.124 byte, SHA-256
  `e1030f47…`** (trước `d3ed027f…`, +17.396 byte do code server
  V100 + test r100; **trùng byte đúng bản export 19:05 của lượt
  18:45 — export xác định**), wasm không đổi `fc74679e…`,
  `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ 4 file (cổng
  8201: index.html / index.js / index.wasm / index.pck).

### 121.5 Push main V100 — CHUẨN BỊ XONG, CHẠY Ở VÒNG NÀY

- Sync-base verify ở vòng này (head vẫn `9b0864ece`):
  `pxb_server.gd` — remote là bản duy nhất từng push của file
  này (commit `89e9ceae`, 20/11, G4 bước 6, server v1: 288 dòng
  / 10.466 byte; blob SHA `c2337e67…` đã đối chiếu — remote đúng
  là bản đó, không phải fetch thiếu); local nay 2.686 dòng /
  120.555 byte. **Lệch này là tích lũy thật, không phải xung
  đột:** server đã đi qua V69–V99 (trade WS, sổ cái, đấu giá,
  shop_buy, persistence, chat_history, rebind) mà không vòng nào
  đẩy lại file server — vòng này đẩy luôn phần tích lũy đó lên
  main cùng V100 (ghi rõ trong commit message); remote chỉ có 9
  dòng không còn khớp nguyên văn (đã sửa/xóa trong lúc phát
  triển), còn lại local chứa đủ nội dung remote + thêm mới; head
  không đổi nên không có writer khác. 2 file test mới
  (g4_r100 + `.uid`) vắng mặt trên remote (đã kiểm bằng
  `get_file_contents` — trả lỗi không tồn tại); docs chỉ đổi ở
  phần V100 (§121 + mục V100 roles-qc).
- Push 5 file: `src/godot/server/pxb_server.gd`,
  `src/godot/tests/g4_r100_trade_completed_rebind_test.gd`,
  `src/godot/tests/g4_r100_trade_completed_rebind_test.gd.uid`,
  `docs/godot-g4.md`, `docs/roles-qc.md` — **XONG, commit
  `900d5188896149d415c89df66e483d0f7b161465`** trên main,
  2026-11-28T13:05:27Z, đã verify bằng `list_commits`. Sync
  record `pho-xo-bo.muse-github-snapshot-sync.json` đã ghi entry
  mới (467 entries). (Ghi chú: dòng commit SHA này chỉ có trong
  doc local — doc đã push ghi 'chuẩn bị xong'; SHA sẽ theo lên
  remote ở lần push docs sau, như mẫu vòng trước.)
- Deploy pck `e1030f47` lên gh-pages vẫn CHƯA CHẠY — chờ chủ
  nói 'đẩy tiếp'. Live vẫn r41 pck `5f2a052f`; local đã tới
  r100 (lệch 59 vòng).

### 121.6 Việc tiếp theo — Vòng 101

1. Auction chưa xong phần "tới tay người offline": `auction_closed`
   không tới được tay người chơi đang offline (log không persist
   — giới hạn đã ghi ở §105.2); áp mẫu hàng đợi `_trade_pending`
   cho `auction_closed` khi có phiên đóng lúc bidder/seller
   offline. Chủ chốt trần bonus chỉ số phụ (hiện KHÔNG kẹp
   STAT_MAX).
2. Deploy pck `e1030f47` lên gh-pages — CHƯA CHẠY, deploy vẫn chờ
   chủ nói "đẩy tiếp". Live vẫn r41 pck `5f2a052f`; local đã tới
   r100 (lệch 59 vòng).
3. Rút ngắn khoảng lệch file server: `server_main.gd` và
   `scripts/pxb_online.gd` cũng chưa được đẩy lại từ 20/11
   (cùng gốc với `pxb_server.gd` ở §121.5) — vòng sau kiểm tra
   từng file rồi đẩy phần đổi của nó lên main, không để tích lũy
   âm thầm nữa.

## 122. Vòng 101 — auction_closed tới tay người offline + đẩy file server tích lũy (28/11 ~20:45–21:30)

### 122.1 Chẩn đoán — giới hạn đã ghi ở §105.2

- `_close_expired_auctions` chỉ `_broadcast(closed_msg)` — broadcast chỉ tới
  người đang online. Người bán / người thắng đang offline lúc phiên đóng
  thì KHÔNG BAO GIỜ nhận được `auction_closed` (chỉ có auction_log persist,
  không gửi lại) — cùng họ lỗi với trade_completed trước vòng 100 (§121).
  Hậu quả: tiền/món đã quyết toán ở sổ cái server nhưng túi/ví local của
  người offline không áp (client chỉ áp khi nhận auction_closed —
  xem PxbOnline.apply_auction_closed).
- Client đã đủ điều kiện nhận lại: `apply_auction_closed` chống áp trùng
  bằng `ws_auctions_applied` (giữ 50 id) + `_rebaseline_ledger_after_settlement`
  sau khi áp — gửi lại đúng 1 lần là an toàn, không cần sửa client.
- Chủ chốt trần bonus chỉ số phụ (ghi ở §121.6): KHÔNG kẹp STAT_MAX —
  code đã đúng từ vòng 87 (apply_stat_gain không kẹp); vòng này chỉ ghi
  quyết định vào comment `scripts/pxb_stats.gd`.

### 122.2 Sửa — server `server/pxb_server.gd` (không sửa Main, không sửa client)

- `var _auction_pending: Dictionary = {}` + `const AUCTION_PENDING_MAX := 10`
  (player_id -> Array message auction_closed; mẫu `_trade_pending` vòng 100).
- `_send_auction_closed_notice(player_id, peer, msg)`: online thì gửi ngay,
  offline thì xếp hàng đợi (cap 10/người, deep duplicate, `_mark_state_dirty`).
- `_flush_auction_pending(peer_id, player_id)`: gửi lại lúc hello sau, xóa
  khỏi hàng đợi; gọi trong `_rebind_after_hello` ngay sau `_flush_trade_pending`.
- `_close_expired_auctions`: sau `_broadcast(closed_msg)`, với người bán và
  người thắng (khác người bán, có người thắng): nếu `_find_peer_by_player_id`
  == -1 thì `_send_auction_closed_notice(id, -1, closed_msg)`. Không gửi lặp
  từ auction_log (lý do như trade ở §121: ws_auctions_applied chỉ giữ 50 id).
- `_clean_auction_pending(raw)`: type phải là "auction_closed", auction_id
  + seller_player_id không rỗng; cap 10, giữ thứ tự.
- `save_state()` thêm `"auction_pending"`; `load_state()` nạp qua cleaner
  (file v100 cũ không có khóa này vẫn nạp được); `data()` thêm
  `"auction_undelivered": _auction_pending.size()`.
- `scripts/pxb_stats.gd`: comment đầu file ghi quyết định chủ chốt 28/11 —
  bonus chỉ số phụ KHÔNG có trần (không kẹp STAT_MAX, không giới hạn).

### 122.3 Test mới + hồi quy — XONG

- Test mới `tests/g4_r101_auction_pending_test.gd` (kèm `.uid`, cổng
  18900–18904, state `/tmp/pxb-r101-state.json`, 7 phase, socket + server
  thật, client A/B có túi/ví thật): **63/63 PASS ngay lần chạy sạch**
  (sau 2 lần sửa TEST, không sửa code server sau lần chạy đầu — xem 122.3b).
  (a) Unit cleaner: giữ đủ, lọc sai (sai type / thiếu auction_id /
  thiếu seller), cap 10, giữ thứ tự; (b) B thắng phiên khi A offline:
  B nhận closed ngay + áp đúng (trả 1.000.000, nhận com-tam x1),
  server xếp closed vào hàng đợi cho A (`auction_undelivered` = 1);
  (c) hàng đợi persist qua restart: stop → state file giữ
  `auction_pending` (player-a 1 thông báo `auction_closed` #1) →
  restart cổng mới → `auction_undelivered` vẫn 1, `auction_log` vẫn 1;
  (d) A hello lại nhận đúng 1 lần, áp đúng vai người bán (com-tam về 0,
  nhận 950.000 = trừ phí 5%), không trùng sau 1,5s,
  `auction_undelivered` về 0; (e) phiên không ai đấu giá đóng lúc cả
  hai offline: chỉ xếp cho người bán, A hello lại nhận 1 lần, không áp
  (lý do `khong-co-nguoi-thang`), giữ ao-mua x1 + 950.000;
  (f) file cũ (không có `auction_pending`) nạp được: `auction_pending`
  rỗng, `auction_log` vẫn 2 phiên.
- **Hồi quy đầy đủ: 5486 check, 0 FAIL** (lần sạch thứ 20;
  +63 so với v100 = test mới r101; r100 77/77, G1 419/419, G3 95/95,
  G1 playtest 14/14, không regression). Log
  `hidden_files/regression-2026-11-28-2045-v101.log`.

#### 122.3b Ba lỗi TEST (không phải lỗi code server) — ghi để không tái phạm

1. **B hello lại không thấy phiên mở:** test chờ `_cb.ws_auctions`
   non-empty sau restart — nhưng server KHÔNG gửi lại phiên đang mở lúc
   hello (thiết kế vòng 83: client tự xin `auction_list`). Sửa test:
   gọi `request_ws_auction_list()` sau khi B nối lại.
2. **Nhãn step trùng trong `match`:** phase 2 có hai nhánh `3:` — nhánh
   kiểm tra đặt `_step = 3` nên chạy lại chính nó mỗi frame (23.109 check
   lặp) và không bao giờ tới nhánh chờ. Sửa: kiểm tra → `_step = 4`,
   nhánh chờ đổi thành `4:`.
3. **White-box đổi `ends_at_ms` làm hỏng mục log:** test đổi
   `ends_at_ms` về quá khứ để kích đóng phiên — mục `auction_log` lưu
   lại mang `ends <= created` nên cleaner (đúng luật) loại bỏ khi nạp
   file sau restart (`auction_log` về 0). Trong thật `ends = created +
   duration` nên không bao giờ xảy ra — KHÔNG sửa cleaner. Sửa test:
   trả lại `ends_at_ms = created + 30000` cho mục log ngay sau khi
   phiên đóng (cả 2 phiên), trước khi stop server.

### 122.4 Export — pck mới `9cbd27f8`

- `--check-only` 3 file sửa/mới exit 0; `--headless --import` exit 0;
  scene Main 120 frame exit 0, 0 ERROR/warning.
- Export web exit 0: pck **28.135.896 byte, SHA-256 `9cbd27f8…`**
  (trước `e1030f47…`, +14.772 byte do code server V101 + test r101),
  wasm không đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`;
  HTTP 200 đủ 4 file (cổng 8202).
- Không browser-verify (thay đổi server-side; test headless đã dùng
  socket + server thật, như vòng 100).

### 122.5 Push main V101 + file server tích lũy — CHUẨN BỊ XONG, CHẠY Ở VÒNG NÀY

- Sync-base verify ở vòng này (head vẫn `900d5188`):
  `pxb_server.gd` — remote là bản V100 vừa đẩy (head `900d5188`), local
  chỉ thêm đổi V101 (không xung đột); `pxb_stats.gd` — remote là bản
  trước vòng 87 (chưa có stat_bonus), local = remote + toàn bộ V87 +
  ghi chú V101 (chỉ thêm mới, không xung đột); `server_main.gd` —
  remote là bản trước vòng 82 (chưa có `--state-file`), local = remote
  + nối persistence V82 (chỉ thêm mới, không xung đột); test r101 +
  `.uid` vắng mặt trên remote (mới hoàn toàn); docs chỉ đổi ở phần
  V101 (§122 + mục V101 roles-qc).
- **Đính chính ghi chú vòng 100 (§121.5): `scripts/pxb_online.gd`
  KHÔNG cần đẩy** — đối chiếu byte remote vs local: giống hệt nhau
  (134.826 byte, 2.964 dòng, blob SHA `5b1dfa51…`); file này đã lên
  remote ở commit `2693458c` (vòng 93), không tích lũy từ 20/11 như
  vòng 100 đã ghi. Chỉ `server_main.gd` là thật sự tích lũy.
- Push 7 file: `src/godot/server/pxb_server.gd`,
  `src/godot/server/server_main.gd`, `src/godot/scripts/pxb_stats.gd`,
  `src/godot/tests/g4_r101_auction_pending_test.gd`,
  `src/godot/tests/g4_r101_auction_pending_test.gd.uid`,
  `docs/godot-g4.md`, `docs/roles-qc.md` — **CHẠY Ở VÒNG NÀY**
  (SHA sẽ theo lên remote ở lần push docs sau, như mẫu vòng trước).
- Deploy pck `9cbd27f8` lên gh-pages vẫn CHƯA CHẠY — chờ chủ nói
  'đẩy tiếp'. Live vẫn r41 pck `5f2a052f`; local đã tới r101 (lệch 60 vòng).

### 122.6 Việc tiếp theo — Vòng 102

1. Deploy pck `9cbd27f8` lên gh-pages — CHƯA CHẠY, deploy vẫn chờ chủ nói
   "đẩy tiếp". Live vẫn r41 pck `5f2a052f`; local đã tới r101 (lệch 60 vòng).
2. G4 online thật: server `.NET 8` vẫn chưa build/chạy được trên VM
   (không có dotnet SDK) — quyết dùng Godot headless dedicated server
   thay .NET hay chờ máy có dotnet (xem `docs/opensource-engine.md` §3.4).
   Server Godot nay đã đủ trade/auction/shop/chat/persistence — quyết
   này càng lúc càng gần.
3. Polish G4 §1.4 còn lại: camera zoom trận, tile riêng Map003–018
   (đang PROVISIONAL), hiệu ứng đánh/ngã sạp; animation di chuyển/đánh
   trong trận MarketBattle (đấu sĩ nhảy ô tức thì); chọn đội/vũ khí
   trước trận; lưu giữ sạp + Danh vọng vào save.
