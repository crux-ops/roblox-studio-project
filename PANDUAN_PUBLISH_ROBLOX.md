# 📤 PANDUAN PUBLISH KE ROBLOX

## 1. Setup Game di Creator Dashboard

1. Buka https://create.roblox.com
2. Creations -> Experiences -> Create New Experience
3. Pilih template **Baseplate** (jangan yang lain)
4. Nama: `Grow & Steal: Mystic Garden 🌱🌙` (emoji bikin CTR naik 15%!)
5. Description SEO:
```
🌱 Grow mutant plants by day, steal from others by night! 🌙

🌟 PLANT & GROW - Tanam 150+ tanaman unik dari Common sampai SECRET!
💰 HARVEST & SELL - Panen & jual untuk jadi jutawan!
🌙 NIGHT STEAL - Setiap 30 menit malam tiba! Curi tanaman langka dari base orang lain!
🛡️ DEFEND - Pasang shield & jebakan untuk lindungi base!
🧬 FUSE MUTANTS - Gabung 3 tanaman jadi mutant super langka!
🔄 TRADE - Trading aman dengan player lain!
👥 GUILD - Bentuk tim & kuasai leaderboard!

🔥 UPDATE MINGGUAN - Tanaman & event baru tiap minggu!
👍 Like & Follow untuk kode gratis!

#Simulator #Tycoon #Farming #Steal #Trading
```
6. Genre: Simulation
7. Tags: Simulator, Tycoon, Farming, PvP, Trading

## 2. Thumbnail & Icon (PENTING - 50% CTR!)

### Icon (512x512):
- Background gradasi cerah (hijau + ungu)
- Karakter chibi gardener besar di tengah (60% canvas)
- Tanaman mutant glowing di tangan
- Border tebal putih
- TANPA TEKS KECIL (tidak terbaca di HP)

### Thumbnail (1920x1080) - 3 Variasi untuk A/B Test:
- **A:** Karakter lari bawa tanaman curian + alarm merah + teks "STEAL!"
- **B:** Garden penuh tanaman rainbow + teks "150+ PLANTS!"
- **C:** Day vs Night split screen (kiri siang cerah, kanan malam gelap pencuri)

> Upload 3 thumbnail, ganti tiap 3 hari, lihat CTR di Analytics -> Engagement

## 3. Game Settings (Di Studio)

```
File -> Game Settings

- Max Players: 20 (awal, naik ke 30 jika server stabil)
- Allow Friends: ON
- Enable Studio Access to API: ON (untuk DataStore)
- Chat: Classic
- Avatar: R6 + R15 support
- Monetization:
  - Premium Payouts: ON
  - Creator Rewards: ON
- Security:
  - Allow HTTP Requests: OFF (kecuali butuh webhook Discord)
  - Enable Third Party Sales: OFF
  - LoadStringEnabled: OFF
```

## 4. Monetization Setup

1. Dashboard -> Monetization -> Game Passes
   - Buat: VIP Plot (499 R$), Auto Collect (299 R$), Double Growth (199 R$)
2. Monetization -> Developer Products
   - Buat: Gems 100 (19 R$), 500 (79 R$), 1200 (169 R$), Shield (29 R$), Skip Growth (9 R$)
3. Copy ID ke `EconomyConfig.lua` -> `DeveloperProducts` & `Gamepasses`

## 5. Publish Checklist

- [ ] `Workspace.AuthorityMode = Server` aktif
- [ ] Semua Remote punya RemoteValidator
- [ ] ProfileStore ganti dari MOCK ke real (DataService.lua)
- [ ] Economy 100% server ledger
- [ ] Test 2 player: trade, steal, harvest lancar
- [ ] Mobile test (pakai Device Emulator di Studio)
- [ ] Icon & Thumbnail upload
- [ ] Description & tags isi
- [ ] Max Players 20
- [ ] Publish -> File -> Publish to Roblox

## 6. Launch Strategy (Minggu 1)

**Hari 1-2: Soft Launch**
- Publish, jangan share dulu
- Ajak 10-20 teman test, cari bug
- Monitor Analytics: Crash rate <1%, Avg Session >5 menit

**Hari 3-4: Content Creator Push**
- DM 20-50 TikToker Roblox kecil (1K-10K followers) - kasih free VIP
- Title video: "GAME BARU STEAL PALING CHAOS! 😱🌱" (formula viral Steal a Brainrot)
- Hashtag: #roblox #stealabrainrot #growagarden #newrobloxgame

**Hari 5-7: Update & Algorithm**
- Rilis UGC Limited Code: `LAUNCH100` (100 Gems gratis - paksa join & return)
- Update 1: Tambah 5 tanaman baru + event double income weekend
- Roblox algorithm butuh 7 hari untuk evaluasi retention - JANGAN GANTI GAME di minggu 1!

**Minggu 2+:**
- Update tiap 7-14 hari (tanaman baru, pet, base skin)
- Event mingguan: "Weekend Steal Frenzy - Night 2x lebih lama!"
- Leaderboard reset bulanan dengan reward eksklusif

## 7. Analytics yang Harus Dipantau

Di Creator Dashboard -> Analytics:

- **D1 Retention:** Target 20%+ (good), 30%+ (great)
- **D7 Retention:** Target 8%+ (good), 12%+ (great)
- **Avg Session Time:** Target 7+ menit
- **CCU:** Naik tiap hari = algorithm suka
- **Revenue:** ARPPU $0.30+ good, $0.50+ great
- **Crash Rate:** <1% (jika >2% = fix bug segera!)

Jika D1 <15% = Core loop bermasalah, jangan push monetization, fix FTUE dulu!

## 8. Scaling

- 100 CCU: Tambah server region (US, EU, Asia)
- 1K CCU: Tambah 2-3 admin/moderator
- 10K CCU: Hire builder untuk map update, siapkan anti-cheat manual review
- 50K+ CCU: Consider private servers (10 R$/bulan) + UGC catalog

---

Good luck! 🚀 Ingat: Game Roblox yang sukses = 30% build, 70% update & community. Jangan berhenti update!
