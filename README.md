# Grow & Steal: Mystic Garden Tycoon

**Build prototipe kebun, belum siap publish.** Pengguna telah menyetujui pengerjaan
lintas fase tanpa meminta konfirmasi setiap tahap. Status jujur per fase ada di
[`docs/PROGRESS.md`](docs/PROGRESS.md); tidak semua fitur master prompt selesai.

## Untuk pengguna Windows yang tidak menulis kode

1. Unduh file **MysticGarden.rbxlx** yang dilampirkan agen.
2. Di Roblox Studio pilih **File → Open from File…**, lalu pilih file itu.
3. Klik **Play** (segitiga biru).
4. Di panel kebun klik **Klaim kebun saya**. Karakter dipindahkan ke petak Anda.
5. Buka **Toko**, beli **Happy Sprout** seharga 10 Coins.
6. Kembali ke **Kebun**, klik slot kosong untuk menanam.
7. Setelah 10 detik, klik **PANEN**. Buka **Tas** lalu klik hasil panen untuk menjual.

Jika tulisan **DATA UJI (tidak disimpan)** muncul, Anda tetap bisa mencoba gameplay,
tetapi progres sesi itu tidak bertahan. Untuk menguji penyimpanan sungguhan,
publish ke experience **pengujian terpisah**, kemudian aktifkan **Enable Studio
Access to API Services** melalui pengaturan Security. Nama/menu Studio dapat
berbeda sesuai versi. Jangan mengaktifkan akses Studio ke data game produksi.
Masuk ulang dan periksa Coins, benih, panen, dan tanaman tumbuh tetap ada.

File `.rbxlx` diekspor dari source yang sama dengan proyek; tidak memerlukan
Rojo/Wally untuk dibuka. Format XML dan kesamaan semua source telah dites;
**pembukaan aktual dan Play di Studio belum diuji di lingkungan agen**. Jika muncul
error, buka panel Output dan kirim screenshot pesan merahnya. Jangan publish
build ini untuk pemain umum atau mengaktifkan pembayaran dahulu.

## Yang tersedia dalam source

- 30 petak, masing-masing 8 slot, dengan model tanaman sederhana.
- 10 jenis benih; starter 100 Coins; beli → tanam → tumbuh → panen → jual.
- Pertumbuhan memakai waktu server, termasuk waktu saat pemain offline.
  Ini bukan pendapatan Coins otomatis saat offline.
- Fusion 3 panen biasa menjadi 1 mutant bernilai jual x2 (biaya 100 Coins).
- Album penemuan, hadiah harian 7 hari, misi panen/fusion, free season 50 tier.
- Siklus 25 menit siang / 5 menit malam berbasis UTC.
- ProfileStore asli dengan session lock, autosave 60 detik, pemeriksaan schema,
  ledger server dan leaderstats sebagai tampilan saja.
- Remote allowlist, grammar/ID validation, token bucket, distance/ownership checks,
  log evidence terbatas dan fallback pemeriksaan kecepatan horizontal.
- UI prototipe dengan tombol sentuh, header Coins/Gems dan timer.

Pencurian, trading, auction, guild, premium pass, Robux, Cmdr, 150 tanaman dan
optimasi beban besar **belum tersedia**. `EnableSteal=false` dan monetisasi disabled
secara sengaja. Tidak ada tombol yang menjanjikan barang berbayar atau transaksi
lintas pemain yang belum aman. Quest steal juga disembunyikan pada build ini.

## Untuk pengembang

```sh
npm ci
npm test
python3 tools/build_place.py
```

`npm test` mengompilasi seluruh source Luau lewat WASM, menjalankan logika layanan
produksi dengan service doubles, lalu tes Python untuk struktur/config/XML.
Ini bukan Luau type analysis, TestEZ dalam Studio, tes jaringan Roblox, atau tes
DataStore sungguhan. Detail skenario di `docs/STUDIO_TESTS.md`.

### Alternatif Rojo

```sh
aftman install
rojo build default.project.json -o build/MysticGarden.rbxlx
rojo serve default.project.json
```

Buat folder `build` jika belum ada. Sambungkan plugin Rojo Studio ke
`localhost:34872`. Rojo bukan halaman web. Download CLI Rojo/Wally pada lingkungan
agen masih diblokir host redirect GitHub. Exporter Python disediakan sebagai
jalur alternatif terbatas untuk pohon proyek ini, bukan pengganti Rojo umum.

`wally.toml` mendeklarasikan dependensi target. Hanya ProfileStore yang telah
benar-benar diintegrasikan, melalui source upstream yang dipin dan disertakan
beserta lisensinya di `src/server/Vendor`. Lihat `docs/DEPENDENCIES.md`. Janitor,
Signal dan UI factory lokal masih digunakan; migrasi Fusion/Janitor upstream,
Promise, Cmdr dan lockfile Wally belum selesai. Tidak ada klaim seluruh tech stack
master prompt sudah terpasang.

## File penting

- `src/shared/Config`: balancing, season, limit remote dan feature gates.
- `src/server/Services`: data, ekonomi, petak, tanaman, fusion, quest, season, world.
- `src/server/AntiCheat`: grammar remote, evidence dan fallback movement.
- `src/client/Controllers/UIController.lua`: UI prototipe.
- `SECURITY_AUDIT.md`: batas jaminan dan matriks validasi.
- `BALANCING_SHEET.md`: nilai tanaman dan reward.
- `docs/PROGRESS.md`: pekerjaan selesai/sebagian/belum dimulai.
