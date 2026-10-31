# 🎨 ASPEC-050: Spesifikasi Aset - Antarmuka Pengguna (UI) & Ikon

> **Asset Specification Document (ASPEC) - Antarmuka Pengguna (UI/UX)**  
> ID Dokumen: **ASPEC-050**  
> Sumber Acuan: 🟢 **[SKETCH: UI Role, Rarity, Space Tanaman]**, 📘 **[PRD: 8.1, 8.2, 9.7]**, 📘 **[TRD-013]**  
> Penanggung Jawab: **Designer 1 (UI/UX Artist)**

---

## 1. Panduan Gaya Visual UI (Design Language)

- **Tema Desain**: Hutan Fantasi Organik (*Forest Wooden & Herbal Parchment*).
- **Elemen Pembentuk**: Papan kayu berlumut, kertas perkamen kuno bertali rotan, dan batu permata bersinar.
- **Keterbacaan Sekilas 🟢**: Peran tanaman (Role) dan kelangkaan (Rarity) dibedakan secara tegas melalui bentuk simbol dan warna bingkai agar pemain langsung paham dalam tempo 1 detik.

---

## 2. Ikon Simbol Peran (Role Icons) 🟢 [SKETCH]

Setiap tanaman memiliki lencana peran resmi di sudut kiri atas kartu belanja dan pada panel info:

| File Aset | Simbol Bentuk | Warna Dominan | Dimensi | Keterangan Desain |
| :--- | :---: | :---: | :---: | :--- |
| `icon_role_damage_dealer.png` | ⚔️ Pedang Bersilang | `#E74C3C` (Merah Api) | $1280 \times 1280$ px | Pedang ganda menyilang di atas perisai lonjong berapi; melambangkan kekuatan penyerang tunggal. |
| `icon_role_supporter.png` | 💚 Tetes Obat / Palang | `#2ECC71` (Hijau Segar) | $1280 \times 1280$ px | Tetesan air berhiaskan simbol palang putih dan daun herbal; melambangkan buff dan pemulihan kawan. |
| `icon_role_defender.png` | 🛡️ Perisai Kokoh | `#3498DB` (Biru Safir) | $1280 \times 1280$ px | Perisai besi tebal bertakik empat dengan baut penguat; melambangkan benteng tebal dan Crowd Control. |

---

## 3. Bingkai Kartu Belanja per Rarity (Shop Cards) 🟢 [SKETCH]

Dimensi kanvas kartu belanja: $1280 \times 1280$ piksel (Di-downscale responsive ke container `HBoxContainer` di HUD bawah):

| Tingkat Rarity 🟢 | File Aset Bingkai | Kode Warna Border | Karakteristik Visual |
| :--- | :--- | :---: | :--- |
| **COMMON** (Umum) | `card_border_common.png` | `#95A5A6` (Perak / Abu) | Bingkai kayu sederhana bertali rotan dengan border perak polos (cth: Tameng Sitrus). |
| **RARE** (Langka) | `card_border_rare.png` | `#2980B9` (Safir Biru) | Bingkai kayu halus dengan ukiran daun perak dan permata safir biru di sudut atas (cth: Anggrek Paramedis). |
| **EPIC** (Luar Biasa) | `card_border_epic.png` | `#8E44AD` (Ametis Ungu) | Bingkai logam kuno berhiaskan kristal ametis ungu berpendar di kedua sisinya (cth: Pembazoka Kuning). |
| **LEGENDARY** (Legendaris) | `card_border_legendary.png`| `#F39C12` (Emas Cerah) | Bingkai emas tempa bertatahkan permata bercahaya benderang dengan ornamen mahkota. |
| **LOCKED / DISABLED** | `card_overlay_locked.png` | `#2C3E50` (Transparan $60\%$) | Lapisan abu-abu gelap dengan ikon gembok besi di tengah jika saldo kurang atau kuota Space penuh. |

---

## 4. Komponen HUD & Status Bar

| Nama Komponen | File Aset | Dimensi | Fungsi di Layar |
| :--- | :--- | :---: | :--- |
| **Ikon Sumber Daya** | `hud_icon_resource.png` | $1280 \times 1280$ px | Kristal tetesan air biru di samping angka saldo pemain. |
| **Ikon Rumah (HP)** | `hud_icon_house.png` | $1280 \times 1280$ px | Miniatur rumah kayu bersiluet hati di depan bar HP Rumah. |
| **Ikon Space Tanaman** | `hud_icon_space.png` | $1280 \times 1280$ px | Plot tanah berselut tunas hijau di samping indikator kuota (cth: "Tanaman 3/6"). |
| **Ikon Fase Siang** | `hud_icon_sun.png` | $1280 \times 1280$ px | Matahari kartun keemasan penanda waktu persiapan siang. |
| **Ikon Fase Malam** | `hud_icon_moon.png` | $1280 \times 1280$ px | Bulan sabit biru dengan awan malam penanda fase serangan. |
| **Bar HP Rumah (Fill)** | `hud_hp_bar_fill.png` | $1280 \times 1280$ px | Tekstur merah bergradasi oranye penunjuk sisa HP Rumah. |
| **Bar HP Rumah (Frame)**| `hud_hp_bar_frame.png` | $1280 \times 1280$ px | Bingkai kayu pelindung bar HP dengan baut sudut. |
| **Tombol Mulai Malam** | `btn_start_night.png` | $1280 \times 1280$ px | Tombol kayu berpahat "Mulai Malam >>" untuk mempercepat siang (Normal / Hover / Pressed). |
| **Panah Peringatan Flank**| `warning_flank_arrow.png`| $1280 \times 1280$ px | Panah merah segitiga berkedip di 4 sudut layar mengindikasikan arah gelombang musuh terberat. |

---

## 5. Modal Panel Detail Info Klik (`panel_info_popup.png`) 📘 [PRD: 8.2]

*Catatan Mekanik: Sesuai PRD Bagian 8.2, info tanaman dan musuh **hanya muncul saat diklik**, bukan saat hover.*

- **Dimensi**: Kanvas $1280 \times 1280$ piksel.
- **Visual**: Panel lembaran perkamen cokelat muda bertekstur serat kayu dengan bingkai kayu gelap berlumut.
- **Komponen Bagian Dalam**:
  - `btn_close_popup.png` ($1280 \times 1280$ px): Tombol silang merah kayu di pojok kanan atas.
  - Bingkai Avatar Portrait ($1280 \times 1280$ px): Menampilkan gambar besar wajah tanaman/musuh.
  - Garis Pembatas Rotan: Pemisah antara tabel statistik dan kotak deskripsi kemampuan.

---

## 6. Checklist File Aset Siap Pakai

- [ ] `icon_role_damage_dealer.png` ($1280 \times 1280$ px)
- [ ] `icon_role_supporter.png` ($1280 \times 1280$ px)
- [ ] `icon_role_defender.png` ($1280 \times 1280$ px)
- [ ] `card_border_common.png`, `card_border_rare.png`, `card_border_epic.png`, `card_border_legendary.png` ($1280 \times 1280$ px)
- [ ] `card_overlay_locked.png` ($1280 \times 1280$ px)
- [ ] `hud_icon_resource.png`, `hud_icon_house.png`, `hud_icon_space.png` ($1280 \times 1280$ px)
- [ ] `hud_icon_sun.png`, `hud_icon_moon.png` ($1280 \times 1280$ px)
- [ ] `hud_hp_bar_fill.png`, `hud_hp_bar_frame.png` ($1280 \times 1280$ px)
- [ ] `btn_start_night.png` ($1280 \times 1280$ px)
- [ ] `warning_flank_arrow.png` ($1280 \times 1280$ px)
- [ ] `panel_info_popup.png` ($1280 \times 1280$ px)
