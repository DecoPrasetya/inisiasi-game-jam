# 🎨 ASPEC-020: Spesifikasi Aset - Rumah Hutan

> **Asset Specification Document (ASPEC) - Entitas Utama / Objektif**  
> ID Dokumen: **ASPEC-020**  
> Sumber Acuan: 🟢 **[SKETCH: Rumah Pusat]**, 📘 **[PRD: 5.1, 9.3]**, 📘 **[TRD-003]**  
> Penanggung Jawab: **Designer 1 (Environment & Architecture Artist)**

---

## 1. Konsep Visual & Karakteristik

- **Nama Entitas**: Rumah Hutan (The Central House)
- **Peran 🟢**: Objektif inti permainan yang berada di tengah lahan belah ketupat. Game Over terjadi jika HP Rumah mencapai 0.
- **Dimensi Tapak Grid**: $3 \times 3$ sel isometrik (Area footprint tanah beresolusi tinggi).
- **Ukuran Kanvas Sprite**: $1280 \times 1280$ piksel (Tinggi vertikal menampung atap dan cerobong asap).
- **Titik Tumpu (Pivot/Origin)**: $(640, 960)$ piksel (Titik pusat belah ketupat lantai dasar).

---

## 2. Tingkatan Visual Bangunan (Tier Evolution)

Rumah berevolusi penampilannya seiring peningkatan level Rumah di game:

| Tingkatan | Rentang Level | Deskripsi Arsitektur Visual |
| :--- | :---: | :--- |
| **Tier 1 (Gubuk Kayu)** | Level 1–3 | Pondok kayu bulat sederhana beratap rumbia jerami kering tebal. Memiliki pintu kayu berpalang tali, lentera minyak kecil di samping pintu, dan cerobong batu kali dengan asap tipis mengepul. |
| **Tier 2 (Kabin Bertingkat)** | Level 4–6 | Rumah kabin kayu papan halus berlantai dua dengan atap sirap kayu kokoh. Dilengkapi teras balkon kecil di lantai atas, cerobong bata merah beratap seng, dan dua lentera kaca besi menyala hangat. |
| **Tier 3 (Benteng Hutan)** | Level 7–10 | Benteng kabin megah yang diperkuat pondasi batu belah kokoh dan pagar kayu meruncing. Memiliki menara pengawas kecil dengan bendera daun berkibar, serta jendela kaca patri bersinar terang. |

---

## 3. Rincian Animasi (Standar 3–5 Frame)

### 3.1 Animasi `idle` (4 Frame, Loop per Tier)
*Kondisi: Berdiri damai di pusat hutan dengan kepulan asap cerobong dan lentera menyala.*
- **Kecepatan**: 4 FPS (Durasi $1.0$ detik, lambat dan tenang).
- **Rincian Frame**:
  - **Frame 1**: Asap putih tipis mengepul bulat dari cerobong batu, lentera depan pintu bersinar stabil.
  - **Frame 2**: Asap meliuk naik ditiup angin sepoi-sepoi ke kanan, bayangan cahaya jendela berkedip hangat.
  - **Frame 3**: Asap membubung lebih tinggi dan menipis pudar, lentera memancarkan partikel kilau lembut.
  - **Frame 4**: Gumpalan asap baru mulai terbentuk di mulut cerobong, kembali menyambung ke frame 1.

### 3.2 Animasi `hit_reaction` (3 Frame, One-Shot)
*Kondisi: Terkena hantaman cakar atau proyektil musuh yang menembus garis pertahanan.*
- **Kecepatan**: 10 FPS (Durasi $0.3$ detik, getaran cepat mengejutkan).
- **Rincian Frame**:
  - **Frame 1**: Seluruh bangunan tersentak bergeser ke kiri $2$ px, serbuk debu kayu berhamburan dari atap.
  - **Frame 2**: Bangunan membal bergeser ke kanan $2$ px, lentera pintu berayun kencang.
  - **Frame 3**: Bangunan kembali stabil di titik pusat pondasinya.

### 3.3 Animasi `upgrade` (4 Frame, One-Shot)
*Kondisi: Saat pemain menekan tombol Upgrade Rumah di HUD.*
- **Kecepatan**: 6 FPS (Durasi $\approx 0.67$ detik).
- **Rincian Frame**:
  - **Frame 1**: Rumah terselubung kabut pendaran magis hijau hutan dari tanah.
  - **Frame 2**: Balok-balok kayu baru berputar merakit struktur atap yang lebih megah dengan partikel keemasan.
  - **Frame 3**: Bentuk arsitektur baru memadat kokoh dengan kilatan cahaya benderang.
  - **Frame 4**: Cahaya memudar menyisakan wujud rumah tier baru yang megah dan kokoh.

### 3.4 Animasi `destroyed` (4 Frame, One-Shot - Game Over 🟢)
*Kondisi: HP mencapai 0, memicu kekalahan dan layar Game Over.*
- **Kecepatan**: 6 FPS (Durasi $\approx 0.67$ detik).
- **Rincian Frame**:
  - **Frame 1**: Dinding penyangga utama retak membelah, tiang atap patah miring.
  - **Frame 2**: Atap ambles ke dalam, asap debu reruntuhan mengepul tebal menutupi sekeliling.
  - **Frame 3**: Seluruh struktur runtuh rata dengan tanah menyisakan tumpukan puing kayu berasap.
  - **Frame 4**: Puing-puing kayu menghitam terbakar dengan lentera pecah tergeletak tak bernyawa.

---

## 4. Checklist File Aset Siap Pakai

- [ ] `house_tier1_idle.png` (Spritesheet $5120 \times 1280$ px, 4 frames horizontal @ 1280x1280)
- [ ] `house_tier2_idle.png` (Spritesheet $5120 \times 1280$ px, 4 frames horizontal @ 1280x1280)
- [ ] `house_tier3_idle.png` (Spritesheet $5120 \times 1280$ px, 4 frames horizontal @ 1280x1280)
- [ ] `house_hit.png` (Spritesheet $3840 \times 1280$ px, 3 frames @ 1280x1280)
- [ ] `house_upgrade.png` (Spritesheet $5120 \times 1280$ px, 4 frames @ 1280x1280)
- [ ] `house_destroyed.png` (Spritesheet $5120 \times 1280$ px, 4 frames @ 1280x1280)
- [ ] Resource `house_frames.tres` di Godot Engine dengan seluruh animasi di atas.
