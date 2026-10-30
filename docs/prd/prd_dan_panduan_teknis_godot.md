# 🌲 PRD Forest Defense (Versi 2.0)

> **Product Requirements Document + Panduan Teknis Godot**
> Tower Defense · Endless · Time & Resource Management · Strategy

---

## 0. Informasi Dokumen

| Item | Isi |
| :--- | :--- |
| Nama proyek | Forest Defense *(nama kerja)* |
| Engine | Godot 4.x (target versi: **4.7.3**, 🔴 TBD) |
| Bahasa kode | GDScript dengan static typing |
| Tim | 2 Designer + 3 Programmer |
| Konteks | Game Jam |
| Sumber dokumen | **Sketch Game Jam** (sumber kebenaran utama) |
| Status | Draft 2.0, siap dipakai sebagai acuan implementasi |

### 0.1 Aturan Prioritas Sumber

1. **Sketch Game Jam selalu menang.** Jika PRD ini atau pendapat anggota tim bertabrakan dengan sketch, ikuti sketch.
2. Hal yang **tidak disebut** di sketch boleh dilengkapi, tetapi wajib diberi label supaya mudah dikenali dan diganti kalau tim memutuskan lain.

### 0.2 Legenda Label

| Label | Arti |
| :--- | :--- |
| 🟢 **[SKETCH]** | Langsung dari sketch. **Tidak boleh diubah** tanpa mengubah sketch lebih dulu. |
| 🟡 **[ASUMSI]** | Sketch diam, jadi dilengkapi dengan nilai bawaan yang masuk akal. Boleh diubah tim. |
| 🔴 **[TBD]** | Butuh keputusan tim. Ada nilai bawaan sementara supaya pengerjaan tidak macet. |
| 🔵 **[PRAKTIK]** | Praktik kerja/teknis standar tim, bukan isi sketch. |

---

## 1. Ringkasan Produk

### 1.1 Premis 🟢 [SKETCH]

Di sebuah hutan belantara yang jauh dari pemukiman, seorang manusia baru membeli rumah di tengah hutan. Hutan itu dihuni banyak hewan dan "monster" yang tidak suka dengan kehadiran manusia. Setiap malam mereka berusaha "mengusir" manusia tersebut. Semakin lama manusia itu bertahan, semakin banyak dan semakin mengerikan hewan dan monster yang datang. Manusia ini bukan orang sembarangan: ia membawa bibit tanaman yang bisa melindungi rumahnya.

### 1.2 Pernyataan Produk

Pemain berperan sebagai **manusia** yang menanam **tanaman** untuk melindungi **rumah** dari serangan **hewan/monster**. Game berjalan **endless**: tidak ada kemenangan akhir, tujuannya bertahan selama mungkin.

### 1.3 Pilar Desain

| # | Pilar | Penjabaran |
| :-- | :--- | :--- |
| P1 | **Role yang tegas** | Damage, dukungan, dan pertahanan dipisah ketat. Pemain harus menyusun kombinasi, bukan mengandalkan satu tanaman serba bisa. |
| P2 | **Tekanan makin naik** | Setiap hari yang lewat membuat musuh lebih banyak dan lebih bervariasi. |
| P3 | **Waktu & sumber daya** | Pemain memilih mau menanam, upgrade tanaman, atau upgrade rumah, dengan sumber daya dan waktu yang terbatas. |
| P4 | **Dibaca sekilas** | Aturan role dan rarity harus langsung terlihat di UI tanpa perlu membaca teks panjang. |

### 1.4 Genre & Platform

- Genre 🟢: Tower Defense, Endless Game, Time and Resource Management, Strategy.
- Platform 🟡: PC (Windows) dan Web (HTML5), sesuai kebutuhan pengumpulan Game Jam. Input utama mouse. 🔴 Dukungan touch/mobile belum diputuskan.

---

## 2. Interpretasi & Celah Sketch

Sketch sudah jelas pada aturan inti (role, atribut, aturan rumah). Tabel ini mencatat bagian yang **tersirat** atau **belum dijelaskan** di sketch, beserta cara PRD ini menanganinya.

| # | Topik | Yang dikatakan sketch 🟢 | Penanganan di PRD ini |
| :-- | :--- | :--- | :--- |
| 1 | Bentuk map | Rumah di tengah, lahan **berbentuk belah ketupat seperti CoC** | Grid isometrik berbentuk diamond (4.3) |
| 2 | Arah serangan | Musuh menyerang dari **4 sisi** | 4 sisi spawn (4.4) |
| 3 | Damage tanaman | Damage Dealer punya damage **konstan** | Tidak ada damage acak/critical (R2) |
| 4 | Cara menaikkan level rumah | Level rumah ada dan menentukan Space serta batas level tanaman, tetapi cara naiknya tidak dijelaskan. Resource dipakai untuk "membeli atau meningkatkan tanaman" | Level rumah dinaikkan dengan resource 🟡 |
| 5 | Buff ke rumah | HP rumah bisa di-**buff**, tidak bisa di-debuff, dan hanya Supporter yang boleh buff | Supporter boleh membuff rumah 🟡 (turunan logis) |
| 6 | Jenis CC | Defender boleh CC (opsional), jenisnya tidak disebut | Contoh stun, slow, root, block 🟡 |
| 7 | Atribut teknis musuh | Hanya HP, Tipe Serangan, Deskripsi Skill | Atribut tambahan (speed, damage, range, reward) ditandai 🟡 |
| 8 | Siklus waktu | Musuh menyerang "ketika malam hari" | Siang = persiapan, malam = serangan (4.2) 🟡 |
| 9 | "HP di atas rata-rata" untuk Defender | Dibandingkan dengan rata-rata tanaman lain | Didefinisikan agar bisa divalidasi otomatis (5.2.3) |
| 10 | Skill passive tanaman | Atribut wajib semua tanaman, tetapi role bersifat eksklusif | Passive tidak boleh melanggar eksklusivitas role (5.2.4) |
| 11 | Deskripsi kemampuan musuh | Setiap hewan harus punya deskripsi serangan yang jelas dan lebih detail daripada sekadar tipe serangan | Deskripsi wajib memuat cara menyerang, target yang diincar, dan efek khusus (5.3.1) |

---

## 3. Glosarium

| Istilah | Definisi |
| :--- | :--- |
| **Hewan / Monster / Musuh** | Entitas penyerang. Dalam dokumen ini disebut *musuh*. |
| **Plot / Lahan** | Satu sel pada grid tempat satu tanaman bisa ditanam. |
| **Space Tanaman** | Batas jumlah tanaman yang boleh ada sekaligus (ditentukan level rumah). |
| **Buff** | Peningkatan stat (misal +DPS, +HP, regenerasi HP). |
| **Debuff** | Penurunan stat musuh (misal -damage serangan musuh, +damage yang diterima musuh). **Bukan** damage langsung dan **bukan** CC. |
| **CC (Crowd Control)** | Pembatasan gerak atau aksi musuh (stun, slow, root, block, knockback, taunt). 🟡 *Slow dihitung CC, bukan debuff*, sehingga hanya milik Defender. |
| **DoT** | Damage over time (racun, api, dll.). Dihitung sebagai **damage**, jadi hanya boleh dimiliki Damage Dealer. |
| **Rarity** | Label seberapa sulit atau mahal tanaman didapat. |

---

## 4. Konsep Gameplay

### 4.1 Aturan Emas (Rangkuman Aturan Mutlak) 🟢 [SKETCH]

Tujuh aturan ini adalah "konstitusi" game. Semua kode, data, dan desain konten **tidak boleh melanggarnya**. Aturan ini juga dipakai sebagai dasar test di bagian 16.

| ID | Aturan |
| :-- | :--- |
| **R1** | Setiap tanaman terikat pada **tepat satu** role: Damage Dealer, Supporter, atau Defender. |
| **R2** | **Hanya Damage Dealer** yang boleh memberi damage ke musuh. Damage minimal 1 per detik, nilainya **konstan** (tidak acak), dan bisa dimodifikasi buff/debuff. |
| **R3** | **Hanya Supporter** yang boleh memberi buff ke tanaman lain atau debuff ke musuh. Setiap Supporter minimal punya satu skill buff atau debuff. |
| **R4** | **Hanya Defender** yang boleh melakukan CC (opsional per tanaman). HP awal Defender **harus di atas rata-rata** HP tanaman lain. |
| **R5** | HP Rumah boleh terkena **buff** tetapi **tidak boleh terkena debuff**. |
| **R6** | Level tanaman tidak boleh melebihi level Rumah. |
| **R7** | Jumlah tanaman yang ditanam tidak boleh melebihi Space Tanaman milik Rumah, dan Space naik seiring level Rumah. |

### 4.2 Core Loop & Siklus Hari

```text
 ┌────────────── HARI N ───────────────┐
 │  SIANG (Persiapan)                  │
 │   • Tanam / upgrade / pindah tanaman│
 │   • Upgrade Rumah                   │
 │   • Tekan "Mulai Malam" atau timer  │
 ├─────────────────────────────────────┤
 │  MALAM (Serangan)                   │
 │   • Musuh muncul dari 4 sisi        │
 │   • Musuh mati → drop resource      │
 │   • Pemain masih bisa belanja       │
 ├─────────────────────────────────────┤
 │  Fajar: malam selesai → hari N+1    │
 └─────────────────────────────────────┘
 Rumah HP = 0 → GAME OVER (skor = jumlah hari bertahan)
```

| Aspek | Aturan | Label |
| :--- | :--- | :--- |
| Urutan | Siang (persiapan) → Malam (serangan) → hari berikutnya | 🟢 (malam = serangan) 🟡 (detail fase) |
| Durasi siang | Bawaan **45 detik**, bisa dipercepat dengan tombol "Mulai Malam" | 🔴 TBD |
| Akhir malam | Malam selesai saat **semua musuh gelombang itu mati**. Tidak ada timer malam | 🟡 |
| Belanja saat malam | **Boleh** menanam dan upgrade saat malam, karena resource baru turun saat musuh mati (inilah inti "time management") | 🟡 |
| Pemulihan HP tanaman | Semua tanaman pulih penuh saat fajar, agar kerusakan tidak menumpuk permanen | 🔴 TBD |
| Kondisi kalah | HP Rumah mencapai 0 | 🟢 |
| Kondisi menang | **Tidak ada** (endless). Ukuran keberhasilan = hari terlama yang dilewati | 🟢 (endless) |
| Penyimpanan skor | Rekor hari tertinggi disimpan lokal | 🟡 (Could) |

### 4.3 Peta & Grid 🟢 [SKETCH]

- Rumah berada **di tengah**, dikelilingi lahan tanam.
- Bentuk area **belah ketupat (diamond) seperti Clash of Clans**: grid persegi yang diputar 45° (tampilan isometrik), sehingga keempat sudutnya mengarah ke atas, bawah, kiri, dan kanan layar seperti belah ketupat.
- Empat sisi diamond (NW, NE, SE, SW) adalah arah datangnya musuh (4.4).

```text
                         ◇
                       ◇   ◇
                     ◇   ◇   ◇
NW (Barat Laut) ──◇   ◇   ◇   ◇ ── NE (Timur Laut)
                 ◇   ◇   ■   ◇   ◇
               ◇   ◇   ■   ■   ◇   ◇
             ◇   ◇   ■   ■   ■   ◇   ◇
               ◇   ◇   ■   ■   ◇   ◇
                 ◇   ◇   ■   ◇   ◇
SW (Barat Daya) ──◇   ◇   ◇   ◇ ── SE (Tenggara)
                     ◇   ◇   ◇
                       ◇   ◇
                         ◇

◇ = plot tanam (1 sel)    ■ = rumah (footprint 3×3)
Gambar skematik 7×7. Grid sebenarnya mengikuti parameter di tabel berikut.
```

| Parameter | Nilai bawaan | Label |
| :--- | :--- | :--- |
| Bentuk | Diamond/isometrik, tile rasio 2:1 | 🟢 bentuk, 🟡 rasio |
| Ukuran grid | 11 × 11 sel (diamond) | 🔴 TBD |
| Footprint rumah | 3 × 3 sel di pusat | 🔴 TBD |
| Sel plot | Semua sel diamond di luar footprint rumah | 🟡 |
| Aturan isi | 1 plot = maksimal 1 tanaman | 🟡 |
| Pembatas jumlah | Dibatasi **Space Tanaman** (R7), bukan oleh jumlah plot. Plot bisa lebih banyak dari Space | 🟡 |
| Implementasi | `TileMapLayer` dengan `TileSet` bentuk isometrik | 🟡 |

> 🔴 **Alternatif yang bisa dipilih tim:** plot dibuka bertahap per "cincin" saat rumah naik level, sehingga Space terlihat langsung di map. Bawaan saat ini adalah batas jumlah (lebih sederhana).

### 4.4 Arah Serangan: 4 Sisi 🟢 [SKETCH]

- Musuh datang dari **4 sisi** area diamond: `NORTH_EAST`, `SOUTH_EAST`, `SOUTH_WEST`, `NORTH_WEST`.
- Setiap sisi punya satu atau lebih titik spawn **di luar** area plot.
- Data wave menentukan berapa musuh per sisi 🟡. Bawaan: dibagi rata, makin tinggi hari makin boleh timpang (satu sisi lebih berat) agar pemain tidak bisa menaruh semua pertahanan di satu sisi.
- Indikator UI menandai sisi mana yang akan diserang paling berat 🟡 (Should).

### 4.5 Aksi Pemain 🟡 [ASUMSI]

| Aksi | Keterangan |
| :--- | :--- |
| Tanam | Pilih tanaman dari shop, klik plot kosong, bayar **Cost**. |
| Upgrade tanaman | Naik 1 level dengan resource, tidak boleh melebihi level Rumah (R6). |
| Upgrade Rumah | Naik 1 level dengan resource. Menaikkan HP, Space, dan batas level tanaman. |
| Cabut tanaman | Membebaskan plot dan mengurangi jumlah tanaman (Space). **Tidak mengembalikan resource apa pun**, jadi pemain harus berpikir sebelum menanam atau mencabut. |
| Pindah tanaman | Tidak tersedia di versi awal (Won't). |
| Info | Info statistik dan deskripsi skill **hanya muncul saat tanaman atau musuh di-klik** (tidak muncul otomatis saat hover). Klik area kosong atau tombol tutup untuk menyembunyikannya. |
| Pause / kecepatan | Pause wajib. Tombol kecepatan x2 opsional. |

Pemain **tidak mengontrol langsung** tanaman saat menyerang. Tanaman bekerja otomatis.

---

## 5. Spesifikasi Entitas

### 5.1 Rumah (House)

**Atribut** 🟢: Health Point, Space Tanaman, Maksimal Level Tanaman.

| Atribut | Aturan | Label |
| :--- | :--- | :--- |
| **Health Point** | Menentukan apakah game bisa dilanjutkan. Harus jelas dan bisa dimodifikasi **buff**. **Tidak bisa terkena debuff** (R5). HP 0 = game over. | 🟢 |
| **Space Tanaman** | Semakin tinggi level rumah, semakin banyak tanaman yang boleh ditanam (R7). | 🟢 |
| **Maksimal Level Tanaman** | Level rumah = batas atas level tanaman (R6). Contoh: rumah Lv 4 → tanaman maksimal Lv 4. | 🟢 |
| Level awal | Level 1 | 🟡 |
| Level maksimum | 10 | 🔴 TBD |
| Menyerang? | Rumah **tidak** menyerang dan tidak punya skill. | 🟡 |
| HP saat naik level | HP maksimum naik, HP saat ini bertambah sebesar selisihnya. | 🟡 |
| Buff ke rumah | Hanya dari tanaman Supporter. | 🟡 (turunan dari R3 + R5) |

**Tabel level rumah (nilai awal contoh, diatur Designer 2 lewat `.tres`)** 🟡

| Level Rumah | HP Maks | Space Tanaman | Maks Level Tanaman | Biaya naik ke level ini |
| :-- | :-- | :-- | :-- | :-- |
| 1 | 200 | 4 | 1 | – |
| 2 | 300 | 6 | 2 | 100 |
| 3 | 450 | 8 | 3 | 200 |
| 4 | 650 | 10 | 4 | 350 |
| 5 | 900 | 12 | 5 | 550 |
| 6–10 | diisi saat balancing | | | |

### 5.2 Tanaman (Plant)

**Atribut dasar semua tanaman** 🟢: Role, Skill Passive, Biaya (Cost), Health Point, Rarity.

| Atribut | Keterangan | Label |
| :--- | :--- | :--- |
| Role | `DAMAGE_DEALER`, `SUPPORTER`, atau `DEFENDER`. Hanya **satu** (R1). | 🟢 |
| Skill Passive | Kemampuan pasif tanaman. **Tidak boleh melanggar eksklusivitas role** (lihat 5.2.4). | 🟢 |
| Cost | Harga beli. Dipengaruhi rarity. | 🟢 |
| Health Point | Jelas dan bisa dimodifikasi buff/debuff. | 🟢 |
| Rarity | Label seberapa sulit atau mahal didapat. | 🟢 |
| Level | Mulai Lv 1, naik dengan resource, dibatasi level rumah (R6). | 🟡 |
| Syarat unlock | Level rumah minimum agar tanaman muncul di shop (cara rarity "sulit didapat"). | 🔴 TBD |

**Tingkat rarity** 🟡: `COMMON`, `RARE`, `EPIC`, `LEGENDARY`. Makin langka, makin mahal dan makin tinggi syarat unlock-nya. Rarity **tidak boleh** membuat tanaman melanggar aturan role.

#### 5.2.1 Role: Damage Dealer 🟢

| Atribut | Aturan |
| :--- | :--- |
| **DPS** | Damage konstan per detik, jelas, bisa dimodifikasi buff/debuff. **Minimal 1.** |
| **HP** | Jelas, bisa dimodifikasi buff/debuff. |
| **Rarity** | Label kelangkaan. |
| Range 🟡 | Jarak serang (satuan sel grid atau piksel). |

Larangan: tidak boleh buff tanaman lain, tidak boleh debuff musuh, tidak boleh CC. **Tidak ada damage acak** (tanpa critical, tanpa rentang damage) karena sketch meminta damage konstan.

#### 5.2.2 Role: Supporter 🟢

| Atribut | Aturan |
| :--- | :--- |
| **Buff / Debuff** | Minimal satu skill: buff ke tanaman (atau rumah 🟡) **atau** debuff ke musuh. |
| **HP** | Jelas, bisa dimodifikasi buff/debuff. |
| **Rarity** | Label kelangkaan. |
| Cara kerja 🟡 | Aura dalam radius tertentu, atau efek berkala. Ada `effect_range`. |

Contoh buff 🟡: +% DPS, +% HP maks, regenerasi HP, +% HP rumah.
Contoh debuff 🟡: -% damage serangan musuh, +% damage yang diterima musuh, -% range musuh.
Larangan: tidak boleh memberi damage langsung atau DoT (itu hak Damage Dealer), tidak boleh CC (hak Defender).

#### 5.2.3 Role: Defender 🟢

| Atribut | Aturan |
| :--- | :--- |
| **Crowd Control** | **Opsional** per tanaman, tetapi **hanya** Defender yang boleh punya CC. |
| **HP** | Jelas, bisa dimodifikasi buff/debuff. **HP awal wajib di atas rata-rata tanaman lain.** |
| **Rarity** | Label kelangkaan. |

**Definisi yang dapat divalidasi** 🟡 (supaya aturan "di atas rata-rata" tidak ambigu):

```text
Untuk setiap Defender D (level 1):
    D.base_hp  >  rata-rata(base_hp seluruh tanaman lain di katalog, level 1)
```

"Tanaman lain" = semua tanaman di katalog selain D sendiri. Validasi dijalankan otomatis oleh tool validator (bagian 11.7) setiap Designer 2 mengubah angka.

Contoh CC 🟡: stun, slow, root, block/hadang, knockback, taunt. Defender tanpa CC tetap sah (tank murni).

#### 5.2.4 Aturan Skill Passive per Role 🟡

Karena sketch mewajibkan tanaman hanya punya satu role, passive tidak boleh "menyelundupkan" kemampuan role lain.

| Role | Passive yang **boleh** | Passive yang **dilarang** |
| :--- | :--- | :--- |
| Damage Dealer | Efek terkait serangan sendiri yang bersifat tetap: tembus banyak target, jangkauan, prioritas target | Buff tanaman lain, debuff musuh, CC, **critical/damage acak** |
| Supporter | Buff atau debuff (ini inti perannya), regenerasi, efek aura | Damage langsung, DoT, CC |
| Defender | Pengurangan damage yang diterima diri sendiri, CC (opsional) | Damage ke musuh (**termasuk memantulkan damage/thorns**), buff tanaman lain, debuff musuh |

> ⚠️ Nama seperti "Thorn Bush" boleh sebagai nama, tetapi **tidak boleh** memantulkan damage, karena itu damage dari non-Damage-Dealer.

### 5.3 Hewan / Monster (Enemy)

**Atribut** 🟢: Health Point, Tipe Serangan, Deskripsi Kemampuan/Skill.

| Atribut | Aturan | Label |
| :--- | :--- | :--- |
| **Health Point** | Jelas dan bisa dimodifikasi oleh buff maupun debuff. | 🟢 |
| **Tipe Serangan** | `MELEE` (jarak dekat), `RANGED` (jarak jauh), `NON_ATTACKING` (tidak menyerang). | 🟢 |
| **Deskripsi Kemampuan / Skill** | Setiap hewan **wajib** punya deskripsi serangan yang jelas, bukan hanya tipe serangan (dekat/jauh), tetapi lebih detail (lihat 5.3.1). Teks ini juga menjadi acuan logika skill yang diimplementasikan. | 🟢 |
| Atribut teknis tambahan | `move_speed`, `attack_damage`, `attack_interval`, `attack_range`, `reward` (resource saat mati). Tidak ada di sketch, dibutuhkan agar game berjalan. | 🟡 |
| Reward | Setiap musuh yang dibunuh menjatuhkan resource. | 🟢 |

#### 5.3.1 Standar Deskripsi Kemampuan 🟡

Deskripsi yang hanya berbunyi "jarak dekat" atau "menyerang dari jauh" **tidak memenuhi syarat**. Setiap deskripsi musuh memuat:

| Unsur | Pertanyaan yang dijawab | Contoh |
| :--- | :--- | :--- |
| Cara menyerang | Bagaimana dan seberapa sering musuh menyerang? | "Menggigit tiap 1 detik" |
| Target | Siapa yang diincar dan bagaimana ia memilih target? | "Mengincar tanaman dengan HP terendah" |
| Efek khusus | Ada kemampuan tambahan, perubahan perilaku, atau kondisi aktif? | "Saat HP < 50% kecepatannya naik 30%" |
| Kelemahan / ciri | Apa yang membuat musuh ini mudah dikenali atau dilawan? | "Berhenti bergerak saat menembak" |

Deskripsi ditulis dalam 2 kalimat atau lebih, disimpan pada `skill_description`, dan ditampilkan penuh di panel info musuh.

**Perilaku bawaan** 🟡:

| Aspek | Aturan bawaan |
| :--- | :--- |
| Gerak | Maju dari sisi spawn menuju Rumah mengikuti jalur lurus/grid. Tidak melewati tanaman sebelum menghancurkan atau mencapainya. 🔴 Apakah memakai `NavigationAgent2D` atau jalur lurus sederhana diputuskan Programmer 3. |
| Target `MELEE` | Menyerang target terdekat yang bisa dijangkau (tanaman atau Rumah). |
| Target `RANGED` | Menembak target terdekat dalam `attack_range`. |
| `NON_ATTACKING` | Tidak memberi damage ke tanaman maupun Rumah. Tetap bergerak dan boleh punya skill (misal menyembuhkan musuh lain, mempercepat musuh lain, mencuri resource). |
| Syarat malam selesai | `NON_ATTACKING` **ikut dihitung** harus mati agar malam selesai. 🔴 TBD |
| Sumber buff/debuff pada musuh | Debuff dari Supporter dan CC dari Defender. Skill musuh boleh menyembuhkan atau memperkuat musuh lain dan boleh melemahkan tanaman, karena eksklusivitas R2 sampai R4 hanya mengatur **tanaman**. 🟡 |

---

## 6. Sistem Pendukung

### 6.1 Sistem Modifikasi Stat (Buff / Debuff / CC) 🟡

Semua stat yang "bisa dimodifikasi" (HP, DPS, dll.) dihitung dari **nilai dasar + daftar modifier aktif**, bukan diubah langsung. Dengan begitu buff/debuff bisa dicabut bersih dan mudah dites.

```text
nilai_akhir = (nilai_dasar + Σ modifier_flat) × (1 + Σ modifier_persen)
nilai_akhir = max(nilai_akhir, batas_minimum_stat)
```

| Aturan | Isi |
| :--- | :--- |
| Struktur modifier | `stat`, `mode` (FLAT / PERCENT), `value`, `duration` (0 = selama sumber hidup), `source_id`, `is_debuff` |
| Stacking | Modifier dari **sumber yang sama** tidak menumpuk (hanya refresh durasi). Dari sumber **berbeda** menumpuk. Batas atas persen buff 🔴 TBD |
| Batas minimum | DPS tidak boleh turun di bawah **1** untuk Damage Dealer (sejalan dengan R2). HP tidak negatif. |
| Rumah | `can_receive_debuff = false`. Setiap modifier dengan `is_debuff = true` **ditolak** dan tidak mengubah apa pun (R5). |
| CC | Diterapkan sebagai status terpisah: `STUN`, `SLOW(x%)`, `ROOT`, `BLOCK`. Durasi dan stacking diatur data. Hanya sumber dari Defender yang valid. |
| Pemilik logika | `StatusEffectReceiver` (komponen reusable) dipasang di tanaman, musuh, dan rumah. |

### 6.2 Sistem Targeting 🟡

```text
bisa_menyerang(tanaman, musuh) =
      tanaman.role == DAMAGE_DEALER
  AND musuh.is_alive
  AND musuh berada dalam tanaman.attack_range
```

Supporter (debuff) dan Defender (CC) memakai aturan jangkauan yang sama: efek hanya mengenai musuh yang berada dalam `effect_range`.

**Prioritas target bawaan** 🟡: musuh terdekat dengan Rumah, lalu terdekat dengan tanaman. 🔴 Bisa dibuat per tanaman nanti.

### 6.3 Ekonomi & Resource

| Aspek | Aturan | Label |
| :--- | :--- | :--- |
| Mata uang | **Satu** jenis resource (nama tampilan 🔴 TBD) | 🟡 |
| Sumber | Musuh mati → menjatuhkan resource sebesar `reward` | 🟢 |
| Pemakaian | Beli tanaman, upgrade tanaman, upgrade rumah | 🟢 (tanaman) 🟡 (rumah) |
| Cara pengambilan | Otomatis masuk ke saldo saat musuh mati (tanpa klik) | 🟡 |
| Resource awal | 100 | 🔴 TBD |
| Biaya upgrade tanaman | `cost_upgrade(n) = base_cost × 1.5^(n-1)` untuk naik ke level n | 🔴 TBD, rumus awal |
| Pertumbuhan stat per level | +20% HP dan +20% DPS dari nilai dasar per level (tanaman DPS-based) | 🔴 TBD |
| Cabut tanaman | **Tanpa refund**: resource yang sudah dibayar (beli + upgrade) hilang | 🟡 |
| Saldo | Tidak boleh negatif. Aksi beli ditolak jika kurang. | 🟡 |

### 6.4 Progres Kesulitan (Endless) 🟢 arah, 🟡 angka awal

Sketch menetapkan: **makin banyak hari → makin banyak jumlah dan variasi musuh**. Angka di bawah hanyalah titik awal untuk Designer 2.

| Parameter | Rumus / aturan awal |
| :--- | :--- |
| Jumlah musuh per malam | `total(day) = 4 + 2 × (day − 1)`, dibagi ke 4 sisi |
| Skala HP musuh | `hp_mult(day) = 1 + 0.05 × (day − 1)` |
| Variasi | Jenis musuh baru dibuka mengikuti tabel unlock di bawah |
| Musuh "mengerikan" | Musuh kuat dan skill rumit muncul bertahap, sesuai premis |
| Boss | Setiap kelipatan 10 hari muncul satu musuh khusus 🔴 TBD |
| Komposisi | Dibangun dari `WaveData` (`.tres`), bukan hardcode |

**Contoh tabel unlock variasi (placeholder)** 🟡

| Hari | Variasi yang tersedia |
| :-- | :--- |
| 1–2 | Jarak Dekat saja |
| 3–4 | + Jarak Jauh |
| 5–6 | Varian lebih cepat/tebal dari tipe yang sudah ada |
| 7–9 | + Tidak Menyerang (support musuh) |
| 10+ | Semua tipe, varian elite, boss tiap 10 hari |

Setiap tipe serangan (Dekat / Jauh / Tidak Menyerang) **sebaiknya punya minimal satu wakil** agar semua perilaku musuh teruji.

---

## 7. Konten Awal (Placeholder untuk Balancing)

> Semua angka di bawah **contoh awal**, bukan final. Designer 2 mengatur angka akhir di file `.tres`. Nama dan desain bebas diganti, selama aturan role (R1–R7) tidak dilanggar.

### 7.1 Tanaman

| Nama | Role | Rarity | Cost | HP | Isi inti | Passive |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| Peashooter | Damage Dealer | Common | 50 | 60 | DPS 8, jangkauan sedang | Tembakan lurus menembus 1 musuh |
| Thistle Sniper | Damage Dealer | Common | 80 | 45 | DPS 10, jangkauan jauh | Jangkauan lebih jauh |
| Fire Pepper | Damage Dealer | Rare | 160 | 55 | DPS 18, jangkauan pendek | DPS tetap, serangan area kecil |
| Moss Healer | Supporter | Common | 60 | 50 | Buff: regen 2 HP/detik tanaman sekitar | Aura tetap aktif |
| Sunbloom | Supporter | Rare | 120 | 50 | Buff: +20% DPS tanaman Damage Dealer sekitar | Aura tetap aktif |
| Sap Bloom | Supporter | Rare | 110 | 45 | Debuff: musuh sekitar menerima +25% damage | Aura tetap aktif |
| Oak Wall | Defender | Common | 60 | 220 | Tanpa CC (tank murni) | Kulit kayu: damage diterima -2 flat |
| Bramble Bush | Defender | Common | 90 | 180 | CC: slow 30% musuh dalam jangkauan | – |
| Root Snare | Defender | Epic | 200 | 200 | CC: root 1,5 detik tiap 8 detik | – |

Cek aturan Defender: rata-rata HP tanaman lain untuk Oak Wall = (60+45+55+50+50+45+180+200)/8 = **85,6**; HP Oak Wall 220 > 85,6 ✅.

### 7.2 Musuh

| Nama | Serangan | HP | Reward | Deskripsi Kemampuan |
| :--- | :--- | :--- | :--- | :--- |
| Forest Wolf | Dekat | 40 | 5 | Serigala yang berlari cepat ke tanaman terdekat dari sisi spawn-nya, lalu menggigit target yang sama tiap 1 detik sampai mati sebelum berpindah. Tidak punya kemampuan khusus; ancamannya datang dari kecepatan dan jumlah. |
| Wild Boar | Dekat | 120 | 12 | Babi hutan yang menerjang lurus ke target terdekat. Saat mulai menyerang ia menyeruduk: kecepatan naik 50% selama 1 detik dan serangan pertama berdamage lebih besar. Setelah itu menyerang seperti biasa tiap 1,5 detik. |
| Spitter Toad | Jauh | 35 | 8 | Katak yang berhenti di jarak jauh dari target terdekat, lalu meludahkan lendir tiap 2 detik. Setiap ludahan hanya mengenai satu target. Ia lemah jika didekati karena HP-nya rendah. |
| Giant Crow | Dekat | 30 | 7 | Gagak besar yang bergerak cepat dan mengincar tanaman dengan HP terendah, bukan yang terdekat. Ia menyerang dengan cakar tiap 1 detik dan langsung berpindah ke tanaman berHP terendah berikutnya jika targetnya mati. |
| Night Owl | Jauh | 45 | 10 | Burung hantu yang menembakkan serangan jarak jauh tiap 2,5 detik ke tanaman terdekat dari posisinya. Ia berhenti bergerak selama menyerang, sehingga menjadi sasaran empuk bagi tanaman dengan jangkauan panjang. |
| Mossback Shaman | Tidak Menyerang | 70 | 15 | Tidak memberi damage sama sekali. Ia berjalan di belakang kelompok musuh dan memulihkan 5 HP per detik pada musuh dalam radius 3 sel (kecuali dirinya sendiri). Mengalahkannya lebih dulu menghentikan pemulihan itu. |
| Ancient Bear *(boss)* | Dekat | 800 | 100 | Beruang raksasa yang menyerang dengan cakaran berdamage besar tiap 2 detik ke target terdekat. Saat HP-nya turun di bawah 50% ia mengamuk: kecepatan gerak dan kecepatan serangnya naik 30% sampai ia mati. |

---

## 8. Kebutuhan UI/UX

### 8.1 HUD 🟡

| Elemen | Isi |
| :--- | :--- |
| Hari | "Hari N" dan ikon siang/malam |
| Timer siang | Hitung mundur + tombol "Mulai Malam" |
| Resource | Saldo saat ini (animasi saat bertambah) |
| HP Rumah | Bar HP, level Rumah |
| Space | "Tanaman 7/12" |
| Indikator sisi serang | Penanda 4 sisi dengan intensitas serangan malam ini 🟡 (Should) |

### 8.2 Shop & Info 🟡

- Panel shop menampilkan kartu tanaman: ikon, nama, **ikon role**, **warna rarity**, cost, HP, DPS (jika Damage Dealer).
- Kartu **abu-abu** + alasan jika tidak bisa dibeli (resource kurang, Space penuh, belum terbuka karena level rumah).
- Tombol upgrade **dinonaktifkan** + alasan jika level tanaman sudah sama dengan level rumah (R6).
- **Panel info (muncul saat diklik)** pada tanaman/musuh menampilkan stat, skill passive (tanaman) atau deskripsi kemampuan lengkap (musuh), dan buff/debuff yang sedang aktif. Info tidak muncul lewat hover. Hanya satu panel info terbuka pada satu waktu, dan klik pada objek lain mengganti isinya.
- Panel Rumah: level, HP, Space, batas level tanaman, tombol upgrade beserta harganya.

### 8.3 Layar Lain 🟡

Menu utama, pause, game over (hari bertahan, rekor, tombol ulang), dan layar singkat tutorial yang menjelaskan tiga role.

### 8.4 Audio & VFX 🟡

BGM siang dan malam berbeda. SFX: tanam, upgrade, musuh mati/resource, rumah terkena serangan, peringatan malam. VFX berbeda untuk buff, debuff, CC, dan serangan, agar pemain bisa membedakan role sekilas.

---

## 9. Functional Requirements

Prioritas: **M** = Must (wajib), **S** = Should, **C** = Could. Setiap FR punya kriteria penerimaan singkat.

### 9.1 Core & Alur Game

| ID | Kebutuhan | Prio | Kriteria penerimaan |
| :--- | :--- | :-- | :--- |
| FR-CORE-01 | Game memiliki state: menu, siang, malam, pause, game over | M | Transisi state benar, tidak ada state macet |
| FR-CORE-02 | Siklus hari: siang → malam → hari berikutnya | M | Hari bertambah setelah malam selesai |
| FR-CORE-03 | Malam selesai saat semua musuh wave mati | M | Tidak ada musuh sisa tersembunyi |
| FR-CORE-04 | Game over saat HP Rumah = 0 | M | Layar game over muncul, skor = hari |
| FR-CORE-05 | Tombol "Mulai Malam" mempercepat siang | S | Malam mulai segera |
| FR-CORE-06 | Simpan rekor hari tertinggi | C | Rekor bertahan setelah game ditutup |

### 9.2 Peta & Grid

| ID | Kebutuhan | Prio | Kriteria penerimaan |
| :--- | :--- | :--- | :--- |
| FR-MAP-01 | Grid belah ketupat/isometrik dengan Rumah di tengah | M | Visual dan koordinat sel benar |
| FR-MAP-02 | Penempatan tanaman pada plot, 1 plot maksimal 1 tanaman | M | Plot terisi tidak bisa ditanami lagi |
| FR-MAP-03 | Penempatan ditolak jika jumlah tanaman = Space (R7) | M | Pesan alasan tampil |
| FR-MAP-04 | Musuh spawn dari 4 sisi | M | Keempat sisi pernah menerima spawn |
| FR-MAP-05 | Highlight plot valid/invalid saat memilih tanaman | S | Hover menunjukkan status |

### 9.3 Rumah

| ID | Kebutuhan | Prio | Kriteria penerimaan |
| :--- | :--- | :--- | :--- |
| FR-HOUSE-01 | Rumah punya HP, level, Space, batas level tanaman | M | Nilai sesuai `HouseStats` |
| FR-HOUSE-02 | Buff HP rumah diterima | M | HP maks berubah sesuai buff |
| FR-HOUSE-03 | Debuff pada rumah **selalu ditolak** (R5) | M | HP rumah tidak berubah oleh debuff apa pun |
| FR-HOUSE-04 | Upgrade rumah dengan resource | M | Level, HP, Space, batas level naik |
| FR-HOUSE-05 | Level tanaman tidak melebihi level rumah (R6) | M | Upgrade ditolak saat sama dengan level rumah |

### 9.4 Tanaman

| ID | Kebutuhan | Prio | Kriteria penerimaan |
| :--- | :--- | :--- | :--- |
| FR-PLANT-01 | Setiap tanaman punya Role, Passive, Cost, HP, Rarity | M | Semua field terisi pada data |
| FR-PLANT-02 | Satu tanaman = satu role (R1) | M | Validator menolak data dengan efek lintas role |
| FR-PLANT-03 | Damage Dealer: DPS ≥ 1 dan konstan | M | Damage per detik sama persis tiap detik tanpa buff |
| FR-PLANT-04 | Hanya Damage Dealer yang mengurangi HP musuh (R2) | M | Supporter/Defender tidak pernah memicu event damage |
| FR-PLANT-05 | Supporter: minimal 1 buff atau debuff | M | Validator menolak Supporter tanpa efek |
| FR-PLANT-06 | Hanya Supporter yang memberi buff/debuff (R3) | M | Role lain tidak punya efek buff/debuff |
| FR-PLANT-07 | Defender: HP awal > rata-rata tanaman lain | M | Validator lolos untuk seluruh katalog |
| FR-PLANT-08 | Hanya Defender yang melakukan CC (R4) | M | Role lain tidak punya efek CC |
| FR-PLANT-09 | Tanaman mati saat HP = 0 dan plot dibebaskan | M | Tanaman hilang, Space berkurang |
| FR-PLANT-10 | Upgrade tanaman menaikkan stat per level | M | Stat sesuai rumus data |
| FR-PLANT-11 | Cabut tanaman membebaskan plot **tanpa mengembalikan resource** | S | Plot kosong, Space berkurang, saldo tidak berubah |
| FR-PLANT-12 | Syarat unlock berdasarkan level rumah | S | Kartu terkunci menampilkan syarat |

### 9.5 Musuh & Wave

| ID | Kebutuhan | Prio | Kriteria penerimaan |
| :--- | :--- | :--- | :--- |
| FR-ENEMY-01 | Musuh punya HP, Tipe Serangan, Deskripsi Kemampuan | M | Semua field terisi pada data |
| FR-ENEMY-02 | Tiga tipe serangan: dekat, jauh, tidak menyerang | M | Tipe "tidak menyerang" tidak pernah memberi damage |
| FR-ENEMY-03 | HP musuh bisa dimodifikasi buff dan debuff | M | Debuff Supporter dan CC Defender berefek |
| FR-ENEMY-04 | Musuh mati menjatuhkan resource | M | Saldo bertambah sebesar reward |
| FR-ENEMY-05 | Wave dibangun dari data, makin banyak/bervariasi seiring hari | M | Jumlah dan variasi naik sesuai `WaveData` |
| FR-ENEMY-06 | Skill khusus musuh (deskripsi → logika) | S | Skill berjalan sesuai deskripsi |
| FR-ENEMY-07 | Boss tiap kelipatan 10 hari | C | Boss muncul di hari yang benar |
| FR-ENEMY-08 | Setiap musuh punya deskripsi kemampuan yang jelas dan detail (5.3.1) | M | Validator menolak deskripsi kosong, terlalu pendek, atau hanya berisi tipe serangan. Deskripsi tampil penuh di panel info musuh |

### 9.6 Data & Tools

| ID | Kebutuhan | Prio | Kriteria penerimaan |
| :--- | :--- | :--- | :--- |
| FR-DATA-01 | Semua angka balancing berada di `.tres`, tidak hardcode di `.gd` | M | Mengubah `.tres` mengubah perilaku tanpa edit kode |
| FR-DATA-02 | Validator data otomatis untuk R1–R7 | M | Validator melaporkan pelanggaran dengan nama file |
| FR-DATA-03 | Debug overlay (hari, FPS, jumlah musuh, saldo, tombol cheat resource) | S | Aktif lewat tombol debug |

### 9.7 UI

| ID | Kebutuhan | Prio | Kriteria penerimaan |
| :--- | :--- | :--- | :--- |
| FR-UI-01 | HUD: hari, resource, HP rumah, Space, fase | M | Nilai selalu sinkron dengan game |
| FR-UI-02 | Shop panel dengan ikon role, rarity, cost | M | Status beli/terkunci jelas |
| FR-UI-03 | Panel info stat dan skill | S | Muncul saat objek di-klik, bukan saat hover. Tertutup saat klik di luar panel atau tombol tutup |
| FR-UI-04 | Menu utama, pause, game over | M | Semua tombol berfungsi |
| FR-UI-05 | Indikator sisi serangan | C | Muncul pada fase siang |

---

## 10. Non-Functional Requirements

| Kategori | Kebutuhan |
| :--- | :--- |
| Performa | Stabil ≥ 60 FPS di PC menengah dengan ±100 musuh dan ±30 tanaman aktif. Untuk Web, target ≥ 30 FPS. 🟡 |
| Stabilitas | Branch `dev` selalu bisa dibuka dan dijalankan tanpa crash. |
| Skalabilitas konten | Menambah tanaman/musuh baru cukup dengan menambah scene + `.tres`, tanpa mengubah sistem inti. |
| Determinisme | Damage Damage Dealer konstan. Hanya spawn dan variasi wave yang boleh memakai acak (dengan seed yang bisa diatur untuk debugging). |
| Keterbacaan | Role dan rarity dibedakan **tidak hanya oleh warna** (ada ikon/bentuk). |
| Ukuran build | Build Web ideal < 100 MB 🟡 |
| Kompatibilitas | Export Windows dan Web. Nama file huruf kecil semua agar aman di Linux/Web. |

---

## 11. Arsitektur Teknis (Godot)

### 11.1 Struktur Folder (`res://`)

```text
forest-defense/
├── project.godot
├── .gitignore
├── .gitattributes
└── res://
    ├── assets/                        # ASET STATIS (Designer)
    │   ├── audio/{bgm,sfx}/
    │   ├── entities/{plants,enemies,house}/
    │   ├── environment/               # Tileset diamond, pohon, tanah
    │   ├── fonts/
    │   ├── ui/
    │   └── vfx/
    │
    ├── src/
    │   ├── core/                      # AUTOLOAD (Prog 1)
    │   │   ├── event_bus.gd
    │   │   ├── game_manager.gd        # State, hari, resource
    │   │   └── constants.gd           # Enum global
    │   │
    │   ├── components/                # KOMPONEN REUSABLE
    │   │   ├── health_component.gd
    │   │   ├── hitbox_component.gd
    │   │   ├── hurtbox_component.gd
    │   │   └── status_effect_receiver.gd   # Buff, debuff, CC
    │   │
    │   ├── resources/
    │   │   ├── schemas/               # Definisi Resource (Programmer)
    │   │   │   ├── plant_stats.gd
    │   │   │   ├── enemy_stats.gd
    │   │   │   ├── house_stats.gd
    │   │   │   ├── effect_data.gd
    │   │   │   └── wave_data.gd
    │   │   ├── validators/
    │   │   │   └── data_validator.gd  # Cek aturan R1–R7
    │   │   └── data/                  # Diisi Designer 2
    │   │       ├── plants/
    │   │       ├── enemies/
    │   │       ├── house/
    │   │       └── waves/
    │   │
    │   ├── entities/
    │   │   ├── house/                 # Prog 1
    │   │   ├── plants/                # Prog 2
    │   │   │   ├── base_plant.tscn
    │   │   │   ├── damage_dealer/
    │   │   │   ├── supporter/
    │   │   │   └── defender/
    │   │   └── enemies/               # Prog 3
    │   │       └── base_enemy.tscn
    │   │
    │   ├── systems/
    │   │   ├── grid_placement/        # Grid diamond + penanaman (Prog 1)
    │   │   └── wave_spawner/          # Spawn 4 sisi (Prog 1)
    │   │
    │   ├── ui/                        # Prog 3 + Designer 1
    │   │   ├── hud/
    │   │   ├── shop_panel/
    │   │   └── menus/
    │   │
    │   └── stages/
    │       ├── environment_map.tscn   # Designer 1
    │       ├── planting_grid.tscn     # Prog 1
    │       └── main_forest_stage.tscn # Hanya merakit instance
    │
    └── sandbox/                       # UJI COBA MANDIRI
        ├── prog_1/  prog_2/  prog_3/
        └── designer_1/  designer_2/
```

### 11.2 Enum & Konstanta Global

```gdscript
# src/core/constants.gd  (autoload, class_name Constants)
class_name Constants

enum PlantRole { DAMAGE_DEALER, SUPPORTER, DEFENDER }
enum Rarity { COMMON, RARE, EPIC, LEGENDARY }
enum AttackType { MELEE, RANGED, NON_ATTACKING }
enum SpawnSide { NORTH_EAST, SOUTH_EAST, SOUTH_WEST, NORTH_WEST }
enum EffectKind { BUFF, DEBUFF, CROWD_CONTROL }
enum CrowdControlType { STUN, SLOW, ROOT, BLOCK, KNOCKBACK, TAUNT }
enum GamePhase { MENU, DAY, NIGHT, PAUSED, GAME_OVER }

const MAX_HOUSE_LEVEL: int = 10
const MIN_DAMAGE_DEALER_DPS: float = 1.0

# Collision layers (koordinasi dulu sebelum mengubah project.godot)
const LAYER_HOUSE: int = 1
const LAYER_PLANTS: int = 2
const LAYER_ENEMIES: int = 3
```

### 11.3 Skema Data (Resource)

```gdscript
# src/resources/schemas/plant_stats.gd
class_name PlantStats
extends Resource

@export_group("Umum")
@export var id: StringName
@export var display_name: String
@export_multiline var passive_description: String
@export var role: Constants.PlantRole
@export var rarity: Constants.Rarity
@export var cost: int = 50
@export var base_hp: float = 50.0
@export var unlock_house_level: int = 1

@export_group("Damage Dealer")
@export var base_dps: float = 0.0
@export var attack_range: float = 0.0

@export_group("Supporter & Defender")
@export var effects: Array[EffectData] = []   # BUFF/DEBUFF (Supporter) atau CROWD_CONTROL (Defender)

@export_group("Scene")
@export var scene: PackedScene
@export var sprite_frames: SpriteFrames
```

`EffectData` berisi: `kind`, `stat`, `mode` (flat/persen), `value`, `duration`, `effect_range`, `cc_type`.
`EnemyStats` berisi: `id`, `display_name`, `attack_type`, `base_hp`, `move_speed`, `attack_damage`, `attack_interval`, `attack_range`, `reward`, `skill_description` (wajib, multiline).
`HouseStats` berisi tabel per level: `hp`, `plant_space`, `upgrade_cost`. Level maksimum plant = level rumah.
`WaveData` berisi: hari, daftar entri `(EnemyStats, jumlah, SpawnSide, jeda spawn)`, dan `hp_multiplier`.

### 11.4 Penegakan Aturan di Kode

Aturan role harus **ditegakkan oleh kode dan data**, bukan hanya oleh kesepakatan.

| Aturan | Cara penegakan |
| :--- | :--- |
| R1 | Satu `role` per `PlantStats`. Scene tanaman memasang **satu** komponen perilaku sesuai role (`DamageDealerBehavior`, `SupporterBehavior`, `DefenderBehavior`). |
| R2 | Hanya `DamageDealerBehavior` yang boleh memanggil `HealthComponent.take_damage()` milik musuh. Fungsi itu melakukan `assert(source_role == DAMAGE_DEALER)` pada build debug. |
| R3, R4 | `data_validator.gd` memeriksa: `DAMAGE_DEALER` tidak punya `effects`; `SUPPORTER` hanya `BUFF/DEBUFF` dan minimal 1; `DEFENDER` hanya `CROWD_CONTROL`. |
| R2 (DPS) | Validator: `base_dps >= 1.0` untuk Damage Dealer. Tidak ada field "random damage". |
| R4 (HP) | Validator: HP setiap Defender > rata-rata HP tanaman lain. |
| Deskripsi musuh | Validator: `skill_description` tidak kosong, minimal 2 kalimat (± 80 karakter), dan tidak sekadar berisi nama tipe serangan. |
| R5 | `HealthComponent` punya `@export var can_receive_debuff: bool = true`. Pada Rumah diatur `false`; `StatusEffectReceiver` menolak debuff saat flag itu `false`. |
| R6 | `PlantUpgradeService.can_upgrade(plant)` mengembalikan `false` jika `plant.level >= house.level`. |
| R7 | `GridPlacement.can_place()` mengembalikan `false` jika `planted_count >= house.plant_space`. |

### 11.5 EventBus (Sinyal Global)

Komunikasi lintas fitur memakai `EventBus` agar scene bisa dites sendiri-sendiri.

```gdscript
# src/core/event_bus.gd (autoload)
extends Node

# Alur game
signal day_started(day_number: int)
signal night_started(day_number: int)
signal night_ended(day_number: int)
signal game_over(days_survived: int)

# Ekonomi
signal resource_changed(new_amount: int)
signal enemy_killed(reward_amount: int, enemy_id: StringName)

# Tanaman & rumah
signal plant_placed(plant_id: StringName, cell: Vector2i)
signal plant_died(cell: Vector2i)
signal plant_upgraded(plant_id: StringName, new_level: int)
signal house_upgraded(new_level: int)
signal house_health_changed(current_hp: float, max_hp: float)

# Wave
signal wave_spawned(day_number: int, enemy_count: int)
signal enemy_count_changed(remaining: int)
```

### 11.6 Collision Layer 🔵

| Layer | Nama | Isi |
| :-- | :--- | :--- |
| 1 | `House` | Rumah |
| 2 | `Plants` | Seluruh tanaman |
| 3 | `Enemies` | Seluruh musuh |

### 11.7 Tool Validator Data

`data_validator.gd` dijalankan dari scene sandbox (`F6`) milik Designer 2 dan pada CI/PR check bila ada. Output: daftar pelanggaran R1–R7 dengan nama file `.tres` yang salah, sehingga Designer 2 bisa memperbaiki angka sendiri tanpa menunggu Programmer.

---

## 12. Pembagian Tim & Kepemilikan

### 🎨 Designer

| Peran | Tanggung jawab | Area kerja |
| :--- | :--- | :--- |
| **Designer 1**: Environment, UI/UX & VFX | Peta hutan dan tileset diamond, aset Rumah per level, ikon UI/HUD, layout, VFX buff/debuff/CC/serangan, indikator 4 sisi | `assets/environment/`, `assets/ui/`, `assets/vfx/`, `stages/environment_map.tscn`, `sandbox/designer_1/` |
| **Designer 2**: Entity Artist & Game Balancer | Sprite dan animasi (`SpriteFrames`) semua tanaman & musuh, angka balancing (HP, DPS, Cost, Rarity, Reward, wave) di `.tres` | `assets/entities/`, `src/resources/data/`, `sandbox/designer_2/` |

### 💻 Programmer

| Peran | Tanggung jawab | Area kerja |
| :--- | :--- | :--- |
| **Programmer 1**: Core, House, Grid & Wave | Autoload (`EventBus`, `GameManager`), siklus siang/malam, `WaveSpawner` 4 sisi, logika Rumah (HP, level, Space, cap level), grid diamond dan penanaman | `src/core/`, `src/systems/`, `src/entities/house/`, `sandbox/prog_1/` |
| **Programmer 2**: Plant & Combat | Base class tanaman, tiga perilaku role, targeting, `StatusEffectReceiver` (buff/debuff/CC), upgrade tanaman, validator data | `src/entities/plants/`, `src/components/`, `src/resources/validators/`, `sandbox/prog_2/` |
| **Programmer 3**: Enemy, Economy & UI | Base class musuh, gerak, tiga tipe serangan, skill musuh, drop resource, integrasi UI (shop, HUD), audio | `src/entities/enemies/`, `src/ui/`, `sandbox/prog_3/` |

**Skema (`schemas/`) milik Programmer 2 dan Programmer 1 bersama**: perubahan skema wajib diumumkan di grup sebelum merge agar `.tres` Designer 2 tidak rusak.

---

## 13. Konvensi Koding 🔵

| Objek | Format | Contoh |
| :--- | :--- | :--- |
| Folder & file (`.gd`, `.tscn`, `.tres`, `.png`) | `snake_case`, bahasa Inggris | `plant_card.tscn`, `forest_wolf.png` |
| Node & `class_name` | `PascalCase` | `HealthComponent`, `class_name PlantStats` |
| Variabel & fungsi | `snake_case` (private diawali `_`) | `current_hp`, `_update_buff_timer()` |
| Konstanta | `UPPER_SNAKE_CASE` | `MAX_HOUSE_LEVEL` |
| Enum (nama) | `PascalCase`, isi `UPPER_SNAKE_CASE` | `enum AttackType { MELEE, RANGED, NON_ATTACKING }` |
| Boolean | awalan `is_` / `has_` / `can_` | `is_alive`, `can_receive_debuff` |
| Signal | kata kerja lampau | `plant_upgraded`, `wave_spawned` |

**Wajib:** static typing eksplisit (`var base_dps: float = 8.0`, `func apply_buff(m: float) -> void:`), komposisi komponen, dan **tanpa angka balancing di kode** (semuanya lewat `.tres`).

---

## 14. Anti-Konflik & Alur Git 🔵

### 14.1 Sumber Konflik di Godot (Hindari)

1. Dua orang mengedit `main_forest_stage.tscn` bersamaan.
2. Mengedit `project.godot` bersamaan (Autoload, Input Map, Physics Layer).
3. Memindah atau me-rename file lewat File Explorer/Finder (merusak UID dan referensi).
4. Designer dan Programmer sama-sama mengedit `.tscn` entitas yang sama.

### 14.2 Strategi Anti-Tabrakan (Wajib)

1. **Sandbox**: uji fitur di `res://sandbox/<role>/` dengan **F6**, jangan di `main_forest_stage.tscn`.
2. **1 scene = 1 pemilik aktif**: `main_forest_stage.tscn` hanya merakit instance dari `environment_map.tscn`, `planting_grid.tscn`, `house.tscn`, `hud.tscn`.
3. **Pisahkan visual dan data**: animasi di `SpriteFrames`/scene visual terpisah, angka di `.tres`. Programmer mengedit `.gd`, Designer mengedit `.tres`.
4. **EventBus**: tanpa referensi langsung antar fitur.
5. **Koordinasi `project.godot`**: kabari grup dulu, ubah, langsung commit dan PR ke `dev`. Pindah/rename file hanya lewat panel **FileSystem Godot**.

### 14.3 Branch

| Branch | Fungsi | Aturan |
| :--- | :--- | :--- |
| `main` | Versi stabil siap build/submit | Dilarang push langsung. Hanya PR dari `dev`. |
| `dev` | Integrasi harian | Selalu bisa dibuka dan dijalankan tanpa crash. Masuk lewat PR. |
| `feature/*` | Fitur programmer, contoh `feature/house-level-cap` | Dari `dev` terbaru, uji di sandbox, PR ke `dev` |
| `art/*` | Aset, animasi, balancing `.tres`, contoh `art/forest-diamond-tileset` | Dari `dev` terbaru, PR ke `dev` |
| `fix/*` | Bug, contoh `fix/house-debuff-immunity` | PR ke `dev` (atau `main` jika darurat) |

### 14.4 Commit (Conventional Commits)

`<type>: <deskripsi singkat bahasa Inggris>`

| Type | Untuk |
| :--- | :--- |
| `feat` | Fitur/mekanik baru |
| `art` | Aset visual, animasi, UI, audio |
| `balance` | Perubahan angka `.tres` |
| `fix` | Perbaikan bug |
| `refactor` | Ubah struktur kode tanpa ubah perilaku |
| `docs` | Dokumentasi (`prd.md`, README) |
| `chore` | Konfigurasi, `.gitignore`, export preset |

### 14.5 Alur Harian

1. **Tutup Godot Editor** → `git checkout dev` → `git pull origin dev` → `git checkout -b feature/nama-fitur` → buka Godot.
2. Kerja di folder modul dan sandbox sendiri. Simpan semua (`Ctrl+Shift+S`) sebelum commit. Cek `git status`; batalkan perubahan tidak sengaja pada file orang lain dengan `git checkout -- <path>`.
3. Sebelum PR: `git fetch origin` → `git merge origin/dev` → uji lagi dengan **F6** → `git push origin <branch>` → buka PR ke `dev`, minta minimal 1 reviewer.
4. Setelah merge, hapus branch fitur.

### 14.6 Checklist PR

- [ ] Sudah dites di sandbox (F6) dan `dev` masih bisa dijalankan
- [ ] Tidak mengubah `project.godot`/`.tscn` milik orang lain tanpa koordinasi
- [ ] Tidak ada angka balancing yang di-hardcode
- [ ] Tidak melanggar R1–R7 (validator lolos)
- [ ] Static typing lengkap
- [ ] Commit message sesuai format

---

## 15. Milestone & Definition of Done

> Sketch tidak memuat tanggal, jadi dipakai **fase relatif**. Sesuaikan dengan jadwal Game Jam.

| Fase | Sasaran | Hasil yang bisa didemokan |
| :--- | :--- | :--- |
| **M0 Fondasi** | Repo, struktur folder, Autoload, collision layer, `.gitignore`, skema `.tres`, validator awal | Proyek terbuka tanpa error, semua orang punya sandbox |
| **M1 Vertical Slice** | Grid diamond + Rumah, 1 tanaman per role, 1 musuh jarak dekat, drop resource, siklus siang/malam, game over | Satu hari penuh bisa dimainkan: tanam → serang → resource → hari berikutnya |
| **M2 Konten & Sistem** | Ketiga tipe serangan musuh (dekat, jauh, tidak menyerang), buff/debuff/CC lengkap, upgrade tanaman dan rumah (R6, R7), wave scaling 4 sisi | Semua R1–R7 teruji, ±6 tanaman dan ±6 musuh |
| **M3 UI, Aset & Audio** | HUD, shop, panel info, menu, VFX, SFX/BGM, aset final | Tampilan konsisten dan terbaca |
| **M4 Balancing & Rilis** | Balancing hari 1–15, perbaikan bug, build Windows/Web, PR `dev` → `main` | Build stabil siap dikumpulkan |

**Definition of Done sebuah fitur:** memenuhi kriteria FR terkait, lolos checklist PR, validator data hijau, dites di sandbox dan di `dev`, tanpa error di Output panel Godot.

---

## 16. Matriks Pengujian Aturan (QA)

| ID | Skenario | Hasil yang diharapkan | Aturan |
| :--- | :--- | :--- | :--- |
| T-01 | Buat data tanaman dengan dua role/efek lintas role | Validator gagal | R1 |
| T-02 | Damage Dealer dengan DPS 0 | Validator gagal | R2 |
| T-03 | Damage Dealer menembak 10 detik tanpa buff | Total damage = DPS × 10, tepat | R2 |
| T-04 | Supporter diletakkan dekat musuh tanpa Damage Dealer | HP musuh tidak berkurang oleh Supporter | R2, R3 |
| T-05 | Defender diserang musuh | Musuh tidak menerima damage balik | R2 |
| T-06 | Supporter tanpa efek buff/debuff | Validator gagal | R3 |
| T-07 | Damage Dealer diberi efek slow/stun | Validator gagal | R4 |
| T-08 | Defender dengan HP di bawah rata-rata tanaman lain | Validator gagal | R4 |
| T-09 | Debuff diarahkan ke Rumah | Ditolak, HP/stat rumah tidak berubah | R5 |
| T-10 | Buff HP diarahkan ke Rumah | HP rumah naik | R5 |
| T-11 | Upgrade tanaman Lv 4 saat rumah Lv 4 | Ditolak | R6 |
| T-12 | Naikkan level rumah lalu upgrade tanaman | Diizinkan sampai level baru | R6 |
| T-13 | Menanam saat jumlah tanaman = Space | Ditolak | R7 |
| T-14 | Naikkan level rumah | Space bertambah, penanaman lanjut | R7 |
| T-15 | Musuh `NON_ATTACKING` dibiarkan hidup | Tidak ada damage ke tanaman atau Rumah | FR-ENEMY-02 |
| T-16 | Jalankan 20 hari | Jumlah dan variasi musuh naik, keempat sisi dipakai | FR-ENEMY-05, FR-MAP-04 |
| T-17 | Bunuh musuh | Saldo naik sebesar `reward`, `enemy_killed` terpancar | FR-ENEMY-04 |
| T-18 | HP Rumah → 0 | Game over, skor = hari bertahan | FR-CORE-04 |
| T-19 | Data musuh dengan deskripsi kosong atau hanya "jarak dekat" | Validator gagal | FR-ENEMY-08 |

---

## 17. Risiko & Pertanyaan Terbuka

### 17.1 Risiko

| Risiko | Dampak | Mitigasi |
| :--- | :--- | :--- |
| Merge conflict pada `.tscn`/`project.godot` | Scene rusak, waktu terbuang | Sandbox, scene modular, koordinasi di grup |
| Scope terlalu besar untuk waktu Game Jam | Fitur tidak selesai | Kerjakan **Must** dulu, **Could** hanya jika ada waktu |
| Balancing sulit karena banyak variabel | Game terlalu mudah/sulit | Debug overlay dan cheat resource, tabel unlock bertahap |
| Aturan role "bocor" lewat skill unik | Melanggar sketch | Validator otomatis dan matriks QA di bagian 16 |
| Grid isometrik membingungkan (konversi koordinat) | Bug penempatan | Satu util konversi sel↔dunia, dites di sandbox |
| Performa Web dengan banyak musuh | FPS turun | Batasi jumlah musuh, object pooling bila perlu |

### 17.2 Pertanyaan Terbuka (🔴 Perlu Keputusan Tim)

| # | Pertanyaan | Nilai bawaan sementara |
| :-- | :--- | :--- |
| Q1 | Durasi fase siang, dan apakah ada timer? | 45 detik + tombol "Mulai Malam" |
| Q2 | Ukuran grid diamond dan footprint rumah | 11×11, rumah 3×3 |
| Q3 | Level maksimum rumah | 10 |
| Q4 | Space sebagai batas jumlah, atau plot dibuka bertahap per cincin? | Batas jumlah |
| Q5 | Apakah HP tanaman pulih tiap fajar? | Ya |
| Q6 | Apakah boleh menanam/upgrade saat malam? | Ya |
| Q7 | Apakah musuh `NON_ATTACKING` harus mati agar malam selesai? | Ya |
| Q8 | Mekanisme unlock tanaman berdasarkan rarity | Level rumah minimum |
| Q9 | Apakah Supporter boleh membuff HP Rumah? (disimpulkan dari sketch, tolong dikonfirmasi) | Ya |
| Q10 | Slow dihitung CC (hanya Defender), bukan debuff | Ya |
| Q11 | Boss tiap 10 hari | Ya (Could) |
| Q12 | Dukungan touch/mobile | Tidak |
| Q13 | Nama mata uang resource | Placeholder "Resource" |

---

## Lampiran A: Jejak Sketch → PRD (Traceability)

| Isi sketch | Dipenuhi di |
| :--- | :--- |
| Genre & premis | 1.1, 1.4 |
| Peran player (manusia menanam tanaman melindungi rumah) | 1.2, 4.5 |
| Mapping belah ketupat seperti CoC, rumah di tengah | 4.3, FR-MAP-01 |
| Musuh menyerang dari 4 sisi | 4.4, FR-MAP-04 |
| Skenario: makin banyak hari → makin banyak jumlah & variasi | 6.4, FR-ENEMY-05 |
| Musuh mati → resource untuk beli/tingkatkan tanaman | 6.3, FR-ENEMY-04 |
| Atribut tanaman (role, passive, cost, HP, rarity) | 5.2, FR-PLANT-01 |
| Satu role per tanaman | R1, FR-PLANT-02 |
| Damage Dealer: DPS konstan, damage ≥ 1, eksklusif | 5.2.1, R2, FR-PLANT-03/04 |
| Supporter: buff/debuff, eksklusif | 5.2.2, R3, FR-PLANT-05/06 |
| Defender: HP di atas rata-rata, CC opsional dan eksklusif | 5.2.3, R4, FR-PLANT-07/08 |
| Atribut hewan (HP, tipe serangan, skill) | 5.3, FR-ENEMY-01 |
| Tipe serangan dekat/jauh/tidak menyerang | 5.3, FR-ENEMY-02 |
| Deskripsi kemampuan hewan jelas dan detail | 5.3, 5.3.1, FR-ENEMY-08 |
| HP musuh bisa buff/debuff | 6.1, FR-ENEMY-03 |
| Atribut rumah (HP, Space, Maks Level Tanaman) | 5.1, FR-HOUSE-01 |
| HP rumah bisa buff, tidak bisa debuff | R5, FR-HOUSE-02/03 |
| Space naik seiring level rumah | R7, 5.1, FR-MAP-03 |
| Level tanaman ≤ level rumah | R6, FR-HOUSE-05 |

---

## Lampiran B: `.gitignore` Wajib

```gitignore
# Godot 4+
.godot/
/android/

# Exported builds
build/
exports/
*.exe
*.pck
*.apk

# OS & Editor
.DS_Store
Thumbs.db
*.tmp
*~
```

---

*Dokumen ini hidup. Setiap perubahan aturan inti harus lebih dulu diperbarui di Sketch Game Jam, baru kemudian di PRD ini, dengan commit `docs:`.*