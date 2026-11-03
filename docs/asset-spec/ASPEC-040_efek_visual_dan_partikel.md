# 🎨 ASPEC-040: Spesifikasi Aset - Efek Visual (VFX) & Partikel

> **Asset Specification Document (ASPEC) - Efek Visual & Partikel**  
> ID Dokumen: **ASPEC-040**  
> Sumber Acuan: 🟢 **[SKETCH: Drop Resource, CC Defender, Heal Supporter]**, 📘 **[PRD: 6.1, 6.3, 8.4]**, 📘 **[TRD-004, TRD-005]**  
> Penanggung Jawab: **Designer 1 / Designer 2 (VFX Artist)**

---

## 1. Konsep Visual & Karakteristik VFX

Efek visual (VFX) memegang peran vital agar pemain dapat membedakan ketiga peran tanaman dan status tempur secara sekilas:
- **Warna Identitas Role**:
  - `DAMAGE_DEALER`: Ledakan oranye-kuning berapi dan kepulan asap.
  - `SUPPORTER`: Pendaran hijau herbal, kilau zamrud, dan simbol palang/hati.
  - `DEFENDER`: Percikan getah sitrus kental, efek hantaman tameng, dan gelombang kejut.

---

## 2. Rincian Animasi VFX (Standar 3–5 Frame)

### 2.1 Drop Orb Sumber Daya (`vfx_resource_orb.png`)
*Kondisi: Muncul di titik mati monster, melayang memantul sejenak lalu melesat otomatis ke indikator saldo HUD.*
- **Dimensi**: Kanvas $1280 \times 1280$ piksel.
- **Jumlah Frame**: 4 Frame (Loop, 8 FPS).
- **Rincian Frame**:
  - **Frame 1**: Kristal tetesan air bening berpendar biru-cyan cerah dengan kilatan putih di intinya.
  - **Frame 2**: Kristal berputar $90^\circ$, memancarkan sepasang gelembung udara kecil di tepinya.
  - **Frame 3**: Kristal berputar $180^\circ$ dengan pancaran cahaya paling terang menyilaukan.
  - **Frame 4**: Kristal berputar $270^\circ$ meredup kembali menyambung ke frame awal.

### 2.2 Hentakan Sari Jeruk Tameng Sitrus (`vfx_citrus_bash.png`)
*Kondisi: Memancarkan efek Crowd Control Slow 35% dan Knockback saat Tameng Sitrus memukul tanah.*
- **Dimensi**: Kanvas $1280 \times 1280$ piksel.
- **Jumlah Frame**: 3 Frame (One-Shot, 10 FPS).
- **Rincian Frame**:
  - **Frame 1**: Gelombang cincin oranye tebal meletup tajam di permukaan tanah.
  - **Frame 2**: Cincin gelombang mengembang cepat memercikkan butiran sari jeruk sitrus ke sekeliling.
  - **Frame 3**: Tetesan sari jeruk menyebar tipis di udara dan memudar lembut (fade-out).

### 2.3 Ledakan Area Roket Bazoka Kuning (`vfx_rocket_explosion.png`)
*Kondisi: Muncul saat roket balistik pisang menabrak koordinat tanah sasaran (AOE luas).*
- **Dimensi**: Kanvas $1280 \times 1280$ piksel.
- **Jumlah Frame**: 4 Frame (One-Shot, 10 FPS).
- **Rincian Frame**:
  - **Frame 1 (Detonasi)**: Titik kilat putih terang di pusat ledakan.
  - **Frame 2 (Fireball)**: Bola api kuning-oranye mengembang liar dengan percikan serpihan pisang.
  - **Frame 3 (Smoke Cloud)**: Api meredup berganti gumpalan asap hitam pekat mengepul ke atas.
  - **Frame 4 (Dissipation)**: Asap menipis menjadi jelaga hitam yang melayang hilang tertiup angin.

### 2.4 Aura Pemulihan Medkit Anggrek (`vfx_heal_burst.png`)
*Kondisi: Muncul di atas tubuh tanaman/Rumah saat medkit mendarat sukses.*
- **Dimensi**: Kanvas $1280 \times 1280$ piksel.
- **Jumlah Frame**: 4 Frame (One-Shot, 8 FPS).
- **Rincian Frame**:
  - **Frame 1**: Cincin pendaran hijau muda meletup dari alas tanah tanaman.
  - **Frame 2**: Simbol palang hijau terang membesar di atas kepala tanaman, kilau bintang naik ke atas.
  - **Frame 3**: Simbol palang berpendar lembut, partikel daun hijau herbal berputar melayang.
  - **Frame 4**: Partikel memudar halus meninggalkan rona hijau segar pada tanaman target.

---

## 3. Indikator Ikon Status di Atas Kepala (Status Effect Overlays)

Dimensi kanvas: $1280 \times 1280$ piksel, melayang di atas kepala entitas yang terkena efek status:

| Nama Efek Status | Tipe Efek 🟢 | Frame | Deskripsi Visual |
| :--- | :---: | :---: | :--- |
| **Pusing / Pingsan (`status_stun`)** | `CC (Defender)` | 3 Frame | Tiga bintang kuning kartun berputar melingkar di atas kepala musuh (8 FPS Loop). |
| **Gerak Lambat (`status_slow`)** | `CC (Defender)` | 3 Frame | Cipratan lendir getah oranye sitrus kental yang menempel di telapak kaki musuh (6 FPS Loop). |
| **Akar Pengunci (`status_root`)** | `CC (Defender)` | 3 Frame | Sulur akar pohon cokelat kehijauan melilit pergelangan kaki musuh mengunci pijakan (6 FPS Loop). |
| **Peningkatan Stat (`status_buff`)** | `Buff (Supporter)` | 3 Frame | Dua panah pendaran hijau neon melayang naik secara berurutan di samping tubuh kawan (6 FPS Loop). |
| **Pelemahan Stat (`status_debuff`)** | `Debuff (Supporter)` | 3 Frame | Dua panah ungu pudar meluncur turun mengindikasikan penurunan daya serang musuh (6 FPS Loop). |

---

## 4. Checklist File Aset Siap Pakai

- [ ] `vfx_resource_orb.png` (Spritesheet $5120 \times 1280$ px, 4 frames @ 1280x1280)
- [ ] `vfx_citrus_bash.png` (Spritesheet $3840 \times 1280$ px, 3 frames @ 1280x1280)
- [ ] `vfx_rocket_explosion.png` (Spritesheet $5120 \times 1280$ px, 4 frames @ 1280x1280)
- [ ] `vfx_heal_burst.png` (Spritesheet $5120 \times 1280$ px, 4 frames @ 1280x1280)
- [ ] `status_stun.png` (Spritesheet $3840 \times 1280$ px, 3 frames @ 1280x1280)
- [ ] `status_slow.png` (Spritesheet $3840 \times 1280$ px, 3 frames @ 1280x1280)
- [ ] `status_buff_arrows.png` (Spritesheet $3840 \times 1280$ px, 3 frames @ 1280x1280)
- [ ] `status_debuff_arrows.png` (Spritesheet $3840 \times 1280$ px, 3 frames @ 1280x1280)
