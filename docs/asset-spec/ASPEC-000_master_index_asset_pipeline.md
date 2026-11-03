# 🎨 ASPEC-000: Master Index & Standar Pipeline Aset

> **Asset Specification Document (ASPEC) - Master Index & Panduan Teknis Artist**  
> Proyek: **Forest Defense** (Inisiasi Game Jam)  
> Target Engine: **Godot Engine 4.x (`SpriteFrames` & `AnimatedSprite2D`)**  
> Status: **Dokumen Panduan Resmi Artist & Animator**

---

## 1. Aturan Dasar & Standar Teknis Aset Game Jam

Dokumen ini adalah acuan produksi bagi **Designer 1 (Environment/UI)** dan **Designer 2 (Entity/VFX/Animator)**:

1. **Resolusi & Dimensi Grid**:
   - **Seluruh Aset (Tanaman, Musuh, Bangunan, UI, Tileset)**: Kanvas resolusi tinggi $1280 \times 1280$ piksel (format 1:1, di-downscale sesuai kebutuhan engine).
   - **Tanaman & Musuh**: Kanvas dasar $1280 \times 1280$ piksel (area sprite efektif $\approx 960 \times 960$ px dengan margin transparan).
   - **Rumah Hutan**: Kanvas $1280 \times 1280$ piksel (menutupi footprint isometrik 3×3 sel).
   - **Tileset Belah Ketupat & Props**: Kanvas $1280 \times 1280$ piksel.
   - **Ikon UI & Kartu**: Kanvas $1280 \times 1280$ piksel.
2. **Aturan Animasi 3–5 Frame (Ringan & Cepat untuk Game Jam)**:
   - Sesuai arahan teknis game jam, setiap klip animasi **wajib berjumlah 3 sampai 5 frame** (tidak boleh terlalu banyak agar produksi efisien namun tetap luwes).
   - Kecepatan pemutaran standar: **6 sampai 8 FPS** (Frame Per Second).
3. **Titik Origin (Pivot Point) untuk Y-Sort**:
   - Seluruh sprite entitas diatur dengan titik origin di **bawah tengah (Bottom-Center)** agar sorting kedalaman isometrik Godot (`y_sort_enabled = true`) berjalan sempurna.
4. **Format File**:
   - Gambar diam & Spritesheet: `.png` 32-bit RGBA (Latar belakang transparan).
   - Animasi di Godot: Disusun dalam resource `SpriteFrames` (`.tres`).
   - Audio: `.wav` (SFX berdurasi singkat) dan `.ogg` (BGM musik loop).

---

## 2. Master Index Daftar Spesifikasi Aset (1 File = 1 Aset/Kategori)

| ID Dokumen | File Spesifikasi | Jenis Aset | Dimensi | Animator / Artist |
| :--- | :--- | :--- | :---: | :--- |
| **ASPEC-000** | [ASPEC-000_master_index_asset_pipeline.md](/docs/asset-spec/ASPEC-000_master_index_asset_pipeline.md) | Master Index & Standar Pipeline | – | Lead / Designer 2 |
| **ASPEC-001** | [ASPEC-001_tanaman_tameng_sitrus.md](/docs/asset-spec/ASPEC-001_tanaman_tameng_sitrus.md) | Tanaman Defender (Jeruk Tameng) | 1280×1280 px | Designer 2 |
| **ASPEC-002** | [ASPEC-002_tanaman_pembazoka_kuning.md](/docs/asset-spec/ASPEC-002_tanaman_pembazoka_kuning.md) | Tanaman Damage Dealer (Pisang Bazoka) | 1280×1280 px | Designer 2 |
| **ASPEC-003** | [ASPEC-003_tanaman_anggrek_paramedis.md](/docs/asset-spec/ASPEC-003_tanaman_anggrek_paramedis.md) | Tanaman Supporter (Anggrek Medkit) | 1280×1280 px | Designer 2 |
| **ASPEC-010** | [ASPEC-010_musuh_serigala_hutan.md](/docs/asset-spec/ASPEC-010_musuh_serigala_hutan.md) | Musuh Cepat Melee (Serigala Hutan) | 1280×1280 px | Designer 2 |
| **ASPEC-011** | [ASPEC-011_musuh_babi_hutan_liar.md](/docs/asset-spec/ASPEC-011_musuh_babi_hutan_liar.md) | Musuh Tank Melee (Babi Hutan Liar) | 1280×1280 px | Designer 2 |
| **ASPEC-012** | [ASPEC-012_musuh_katak_penyembur.md](/docs/asset-spec/ASPEC-012_musuh_katak_penyembur.md) | Musuh Jarak Jauh (Katak Asam) | 1280×1280 px | Designer 2 |
| **ASPEC-013** | [ASPEC-013_musuh_dukun_lumut.md](/docs/asset-spec/ASPEC-013_musuh_dukun_lumut.md) | Musuh Support (Dukun Hutan Purba) | 1280×1280 px | Designer 2 |
| **ASPEC-020** | [ASPEC-020_rumah_hutan.md](/docs/asset-spec/ASPEC-020_rumah_hutan.md) | Bangunan Utama (Rumah 3 Tingkat) | 1280×1280 px | Designer 1 |
| **ASPEC-030** | [ASPEC-030_tileset_hutan_isometrik.md](/docs/asset-spec/ASPEC-030_tileset_hutan_isometrik.md) | Lingkungan Grid Isometrik Belah Ketupat | 1280×1280 px | Designer 1 |
| **ASPEC-040** | [ASPEC-040_efek_visual_dan_partikel.md](/docs/asset-spec/ASPEC-040_efek_visual_dan_partikel.md) | Visual FX, Drop Orb, Ledakan & Proyektil | 1280×1280 px | Designer 1 / 2 |
| **ASPEC-050** | [ASPEC-050_aset_antarmuka_ui_dan_ikon.md](/docs/asset-spec/ASPEC-050_aset_antarmuka_ui_dan_ikon.md) | UI HUD, Border Rarity, Ikon Role | 1280×1280 px | Designer 1 |
| **ASPEC-060** | [ASPEC-060_audio_bgm_dan_sfx.md](/docs/asset-spec/ASPEC-060_audio_bgm_dan_sfx.md) | Musik Latar Siang/Malam & Efek Suara | Audio | Designer 1 / 3 |

---

## 3. Struktur Folder Penyimpanan Aset (`res://assets/`)

```text
res://assets/
├── entities/
│   ├── plants/
│   │   ├── tameng_sitrus/         # Spritesheet & SpriteFrames
│   │   ├── pembazoka_kuning/
│   │   └── anggrek_paramedis/
│   ├── enemies/
│   │   ├── serigala_hutan/
│   │   ├── babi_hutan_liar/
│   │   ├── katak_penyembur/
│   │   └── dukun_lumut/
│   └── house/
│       ├── level_1/
│       ├── level_2/
│       └── level_3/
├── environment/
│   ├── tileset_diamond_64x32.png
│   └── props/                     # Pohon, semak, batu
├── vfx/
│   ├── banana_rocket/
│   ├── medkit_toss/
│   ├── citrus_bash/
│   └── resource_orb/
├── ui/
│   ├── icons_roles/
│   ├── cards_rarity/
│   └── hud/
└── audio/
    ├── bgm/
    └── sfx/
```
