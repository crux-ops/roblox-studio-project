# Grow & Steal: Mystic Garden Tycoon

Fondasi proyek Rojo, Luau strict — **Fase 0, belum game siap publish**.
Isi README lama diganti; riwayat Git tetap dipertahankan.

## Instalasi

Prasyarat: Roblox Studio, plugin Rojo yang sesuai, Aftman, Python 3.11+ untuk pemeriksaan statis.

```sh
aftman install
wally install
rojo build default.project.json -o build/MysticGarden.rbxlx
rojo serve default.project.json
```

Buat direktori `build` sebelum build bila belum ada. Sambungkan plugin Rojo Studio
ke `localhost:34872`, lalu Sync. Alternatif: buka hasil build di Studio.
Rojo adalah protokol sinkronisasi Studio, **bukan halaman web/game browser**.

Dependensi Wally dideklarasikan dengan versi tetap; keenam versi telah dicek
ada di wally-index. `wally.lock` belum dihasilkan karena instalasi tool terblokir.
Packages tidak dibutuhkan bootstrap Fase 0: Signal dan Janitor lokal adalah
utilitas kecil mandiri, bukan salinan library upstream. Integrasi package ke
pohon Rojo dilakukan setelah `wally install` sukses agar path tidak menggagalkan
bootstrap. ProfileStore dan sistem ekonomi baru masuk Fase 1.

## Pemeriksaan

```sh
python3 -m unittest discover -s tests -v
git diff --check
```

Pemeriksaan tersebut hanya memvalidasi struktur/konfigurasi, bukan eksekusi Luau.

### Smoke test Studio (wajib sebelum menyatakan Fase 0 selesai)

1. Jalankan `rojo serve`, sambungkan Studio, dan Sync.
2. Play: karakter muncul di tanah hijau. Output menampilkan pesan server/client ready.
3. Pada server Explorer, Player memiliki atribut `GardenReady = true`.
4. Start Server dengan dua client: keduanya memiliki atribut tersebut.
5. Payload `ClientReady` selain string versi `1`, argumen ekstra, atau string
   lebih dari 64 karakter harus diabaikan. Tidak ada reward/currency remote.
6. Spam remote: bucket awal 3 request, isi ulang 0.2/detik; tidak ada error server.
7. Stop, Play ulang, pastikan tidak ada binding ganda atau error timeout.

## Status validasi lingkungan agen

- Pemeriksaan statis tersedia, lihat `tests/test_scaffold.py`.
- Download Rojo/Wally gagal: jaringan memblokir host redirect
  `release-assets.githubusercontent.com` dari rilis GitHub.
- Karena itu **wally install, rojo build, rojo serve, dan Studio Play belum tervalidasi**.
- Tidak ada klaim siap publish, persistensi, 150 tanaman, atau anti-cheat penuh.
- Lanjut Fase 1 hanya setelah gerbang Fase 0 selesai dan pengguna mengonfirmasi.

## Struktur

- `src/shared`: config 10 tanaman, types, Comm, Signal, Janitor, constants.
- `src/server`: bootstrap server dan direktori layanan/anti-cheat/remotes.
- `src/client`: handshake client dan direktori controller/UI/input.
- `assets`, `tests`: aset mendatang dan pemeriksaan scaffold.
- Direktori kosong ditahan dengan `.gitkeep`; tidak ada service setengah jadi.

Seluruh angka balancing tanaman ada di `PlantConfig.lua`; limit komunikasi
ada di `AntiCheatConfig.lua`. Folder layanan fase lanjutan sengaja belum diisi.
