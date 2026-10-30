# 📐 TRD-000: Master Index & Arsitektur Sistem Teknis Godot

> **Technical Reference Document (TRD) - Seri Arsitektur & Spesifikasi Modul**  
> Proyek: **Forest Defense** (Inisiasi Game Jam)  
> Engine Target: **Godot Engine 4.x (GDScript Static Typing)**  
> Status: **Dokumen Acuan Teknis Resmi (Living Technical Reference)**

---

## 1. Konvensi Sumber Kebenaran & Sistem Penandaan (Traceability Tags)

Setiap spesifikasi, aturan, nilai stat, dan potongan kode di seluruh dokumen TRD ini wajib memiliki tanda asal-usul (traceability tag) yang jelas:

| Penanda | Kategori Sumber | Penjelasan |
| :--- | :--- | :--- |
| 🟢 **[SKETCH]** | Sumber Kebenaran Utama | Diambil langsung dari `/docs/sumber-kebenaran/Sketch Game Jam.md` atau `/docs/sumber-kebenaran/list tanaman inisiasi game jam.md`. Bersifat **mutlak / non-negotiable**. |
| 📘 **[PRD]** | Product Requirements | Diambil dari [/docs/prd/PRD-0001.md](/docs/prd/PRD-0001.md) yang merinci aturan alur game, arsitektur tim, dan batasan game. |
| ⚙️ **[REKAYASA DESAIN]** | Rekayasa Stat & Formula | Angka stat, damage, HP, durasi, rumus matematika, dan kurva balancing yang direkayasa secara logis dan terukur karena belum ada nilai pasti di sumber asli. |
| 🔵 **[TEKNIS GODOT]** | Implementasi Engine | Arsitektur node tree, script GDScript, sinyal, collision layer/mask, lifecycle Godot 4, dan konfigurasi project. |

---

## 2. Master Index & Daftar Modul TRD (1 File = 1 Modul)

Sistem TRD ini diorganisasi dengan prinsip **1 File 1 Modul** agar setiap programmer dan designer dapat membaca, mengimplementasikan, dan menguji modul secara independen tanpa konflik merge:

| ID Dokumen | Nama File Modul | Deskripsi Lingkup Modul | Penanggung Jawab |
| :--- | :--- | :--- | :--- |
| **TRD-000** | [TRD-000_master_index_dan_arsitektur_sistem.md](/docs/trd/TRD-000_master_index_dan_arsitektur_sistem.md) | Indeks master, konvensi penandaan, arsitektur global Godot, standar konfigurasi & folder. | Lead Programmer |
| **TRD-001** | [TRD-001_core_event_bus_dan_game_manager.md](/docs/trd/TRD-001_core_event_bus_dan_game_manager.md) | Autoload `EventBus`, `GameManager`, siklus siang/malam, Finite State Machine game loop. | Programmer 1 |
| **TRD-002** | [TRD-002_diamond_grid_dan_placement_system.md](/docs/trd/TRD-002_diamond_grid_dan_placement_system.md) | Grid isometrik belah ketupat 11×11, konversi koordinat, validasi penanaman, batas `plant_space`. | Programmer 1 |
| **TRD-003** | [TRD-003_house_system.md](/docs/trd/TRD-003_house_system.md) | Entitas Rumah (footprint 3×3), leveling, batas level tanaman (R6), kekebalan debuff (R5). | Programmer 1 |
| **TRD-004** | [TRD-004_currency_dan_resource_system.md](/docs/trd/TRD-004_currency_dan_resource_system.md) | Sistem resource ekonomi, drop orb otomatis dari musuh mati, validasi transaksi, aturan no-refund. | Programmer 3 |
| **TRD-005** | [TRD-005_combat_dan_status_effect_components.md](/docs/trd/TRD-005_combat_dan_status_effect_components.md) | Komponen modular: `HealthComponent`, `Hitbox/Hurtbox`, `StatusEffectReceiver` (Buff/Debuff/CC). | Programmer 2 |
| **TRD-006** | [TRD-006_wave_spawner_dan_enemy_director.md](/docs/trd/TRD-006_wave_spawner_dan_enemy_director.md) | Sistem spawner 4 sisi (NE, SE, SW, NW), formula wave scaling endless, pemicu akhir malam. | Programmer 1 |
| **TRD-007** | [TRD-007_enemy_base_dan_archetypes.md](/docs/trd/TRD-007_enemy_base_dan_archetypes.md) | Base class enemy, 3 tipe serangan (Melee, Ranged, Non-Attacking), pathfinding, deskripsi skill. | Programmer 3 |
| **TRD-008** | [TRD-008_plant_base_framework.md](/docs/trd/TRD-008_plant_base_framework.md) | Base class tanaman, penegakan 3 role eksklusif, siklus hidup, penargetan otomatis, formula level up. | Programmer 2 |
| **TRD-009** | [TRD-009_plant_tameng_sitrus.md](/docs/trd/TRD-009_plant_tameng_sitrus.md) | Modul spesifik **Tameng Sitrus** (Role: Defender, tank HP tebal > rata-rata, skill CC hentakan). | Programmer 2 |
| **TRD-010** | [TRD-010_plant_pembazoka_kuning.md](/docs/trd/TRD-010_plant_pembazoka_kuning.md) | Modul spesifik **Pembazoka Kuning** (Role: Damage Dealer, roket AOE tinggi, reload lama, DPS konstan). | Programmer 2 |
| **TRD-011** | [TRD-011_plant_anggrek_paramedis.md](/docs/trd/TRD-011_plant_anggrek_paramedis.md) | Modul spesifik **Anggrek Paramedis** (Role: Supporter, lempar medkit ke tanaman HP terendah). | Programmer 2 |
| **TRD-012** | [TRD-012_data_validator_dan_rule_enforcement.md](/docs/trd/TRD-012_data_validator_dan_rule_enforcement.md) | Tool verifikasi otomatis integritas R1–R7 untuk file data `.tres` tanpa harus membuka game. | Programmer 2 |
| **TRD-013** | [TRD-013_ui_hud_dan_shop_system.md](/docs/trd/TRD-013_ui_hud_dan_shop_system.md) | UI HUD (Hari, Saldo, HP Rumah, Space), Shop Panel (Role badges, Rarity), Modal info klik. | Programmer 3 |

---

## 3. Arsitektur Global Proyek Godot 4.x 🔵 [TEKNIS GODOT]

### 3.1 Diagram Interaksi Sistem

```mermaid
graph TD
    subgraph Engine Core [Autoload Global Singletons]
        EB[EventBus.gd]
        GM[GameManager.gd]
        CONST[Constants.gd]
    end

    subgraph World Layer [res://src/stages/main_forest_stage.tscn]
        GRID[Diamond Grid / TileMapLayer]
        HOUSE[House Entity 3x3]
        SPAWNER[WaveSpawner 4-Sisi]
    end

    subgraph Entity Instances
        PLANTS[Plants Instances]
        ENEMIES[Enemies Instances]
    end

    subgraph Modular Components
        HC[HealthComponent]
        HB[Hitbox / Hurtbox]
        SER[StatusEffectReceiver]
    end

    subgraph UI Layer
        HUD[HUD Controller]
        SHOP[Shop Panel]
        POPUP[Info Popup Modal]
    end

    GM -->|Mengontrol State| WorldLayer
    EB -->|Mendistribusikan Event Sinyal| UI Layer
    EB -->|Mendistribusikan Event Sinyal| World Layer
    PLANTS --> HC & HB & SER
    ENEMIES --> HC & HB & SER
    HOUSE --> HC & SER
    SHOP -->|Request Tanam| GRID
    GRID -->|Cek Space & Cap| HOUSE
```

---

## 4. Konfigurasi Proyek Standar (`project.godot`) 🔵 [TEKNIS GODOT]

### 4.1 Display & Viewport
- **Viewport Width**: `1280` px
- **Viewport Height**: `720` px
- **Stretch Mode**: `canvas_items`
- **Stretch Aspect**: `expand` (Mendukung resolusi layar PC maupun Web HTML5)

### 4.2 Physics 2D Layer Matrix

Wajib didaftarkan pada Project Settings → Layer Names → 2D Physics:

| Layer ID | Nama Layer | Digunakan Oleh | Keterangan Collision |
| :--- | :--- | :--- | :--- |
| **1** | `House` | Area2D / StaticBody2D Rumah | Mendeteksi musuh yang mendekat atau menabrak rumah. |
| **2** | `Plants` | Hurtbox tanaman, Area2D penempatan | Target serangan musuh. |
| **3** | `Enemies` | Hurtbox musuh, CharacterBody2D musuh | Target proyektil Damage Dealer, jangkauan aura. |
| **4** | `Projectiles` | Area2D peluru/bazoka/medkit | Bergerak di dunia game mendeteksi target spesifik. |
| **5** | `Collectibles` | Area2D orb resource | Mendeteksi kursor atau magnet penarikan saldo. |

### 4.3 Y-Sort & Kedalaman Isometrik
Untuk memastikan rendering isometrik berjalan sempurna tanpa glitch tumpukan grafis (misal musuh lewat di belakang tanaman atau di depan rumah):
- Node root stage (`Node2D`) mengaktifkan property `y_sort_enabled = true`.
- Seluruh container entitas (`PlantsContainer`, `EnemiesContainer`, `House`) memiliki `y_sort_enabled = true`.
- Titik origin (`(0, 0)`) pada setiap sprite/scene entitas diletakkan tepat pada **tapak kaki/alas bawah sprite**.

---

## 5. Struktur Direktori Proyek (`res://`) 🔵 [TEKNIS GODOT]

```text
res://
├── assets/
│   ├── audio/
│   │   ├── bgm/
│   │   └── sfx/
│   ├── entities/
│   │   ├── house/
│   │   ├── plants/
│   │   │   ├── tameng_sitrus/
│   │   │   ├── pembazoka_kuning/
│   │   │   └── anggrek_paramedis/
│   │   └── enemies/
│   ├── environment/
│   ├── ui/
│   └── vfx/
├── src/
│   ├── core/
│   │   ├── constants.gd
│   │   ├── event_bus.gd
│   │   └── game_manager.gd
│   ├── components/
│   │   ├── health_component.gd
│   │   ├── hitbox_component.gd
│   │   ├── hurtbox_component.gd
│   │   └── status_effect_receiver.gd
│   ├── resources/
│   │   ├── schemas/
│   │   │   ├── plant_stats.gd
│   │   │   ├── enemy_stats.gd
│   │   │   ├── house_stats.gd
│   │   │   ├── effect_data.gd
│   │   │   └── wave_data.gd
│   │   ├── data/
│   │   │   ├── plants/
│   │   │   ├── enemies/
│   │   │   ├── house/
│   │   │   └── waves/
│   │   └── validators/
│   │       └── data_validator.gd
│   ├── entities/
│   │   ├── house/
│   │   ├── plants/
│   │   │   ├── base_plant.gd / base_plant.tscn
│   │   │   ├── tameng_sitrus.gd / tameng_sitrus.tscn
│   │   │   ├── pembazoka_kuning.gd / pembazoka_kuning.tscn
│   │   │   └── anggrek_paramedis.gd / anggrek_paramedis.tscn
│   │   └── enemies/
│   │       ├── base_enemy.gd / base_enemy.tscn
│   │       └── archetypes/
│   ├── systems/
│   │   ├── grid_placement/
│   │   ├── wave_spawner/
│   │   └── economy/
│   └── ui/
│       ├── hud/
│       ├── shop/
│       └── popups/
└── sandbox/
    ├── prog_1/
    ├── prog_2/
    └── prog_3/
```
