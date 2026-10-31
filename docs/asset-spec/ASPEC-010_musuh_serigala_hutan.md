# 🎨 ASPEC-010: Spesifikasi Aset - Musuh Serigala Hutan

> **Asset Specification Document (ASPEC) - Entitas Hewan / Monster**  
> ID Dokumen: **ASPEC-010**  
> Sumber Acuan: 🟢 **[SKETCH: Hewan/Monster]**, 📘 **[PRD: 5.3, 7.2]**, 📘 **[TRD-007]**  
> Penanggung Jawab: **Designer 2 (Artist & Animator)**

---

## 1. Konsep Visual & Karakteristik

- **Nama Karakter**: Serigala Hutan (Forest Wolf)
- **Tipe Serangan 🟢**: `MELEE` (Jarak Dekat)
- **Deskripsi Visual**: Serigala liar bertubuh ramping dan atletis dengan bulu lebat berwarna abu-abu gelap keperakan. Sorot matanya merah menyala buas di kegelapan malam hutan. Mulutnya selalu terbuka menyeringai memamerkan taring runcing yang siap menggigit tanaman.
- **Ukuran Kanvas Sprite**: $1280 \times 1280$ piksel (Area tubuh efektif $\approx 1000 \times 720$ px).
- **Titik Tumpu (Pivot/Origin)**: $(640, 1080)$ piksel (Tapak kaki tengah).

---

## 2. Rincian Animasi (Standar 3–5 Frame)

### 2.1 Animasi `run` (4 Frame, Loop)
*Kondisi: Berlari kencang (kecepatan 75 px/s) dari sisi spawn menuju Rumah.*
- **Kecepatan**: 8 FPS (Durasi $0.5$ detik).
- **Rincian Frame**:
  - **Frame 1**: Kaki depan meregang jauh ke depan, kaki belakang menjejak dorongan tanah, ekor terangkat lurus.
  - **Frame 2 (Airborne)**: Keempat kaki melipat rapat di bawah perut saat tubuh melayang di udara.
  - **Frame 3**: Kaki depan mendarat menyentuh tanah meredam laju, kepala menjulur rendah mengendus mangsa.
  - **Frame 4**: Kaki belakang menginjak tanah bersiap melontarkan tubuh ke langkah berikutnya.

### 2.2 Animasi `bite` (4 Frame, One-Shot)
*Kondisi: Menyerang tanaman atau Rumah tiap 1.0 detik.*
- **Kecepatan**: 8 FPS (Durasi $0.5$ detik).
- **Rincian Frame**:
  - **Frame 1 (Windup)**: Menekuk kaki belakang, kepala ditarik mundur dengan rahang terbuka lebar $60^\circ$.
  - **Frame 2 (Snap Bite)**: Menerjang maju $4$ px mengatupkan rahang sekuat tenaga pada sasaran (memicu damage 6).
  - **Frame 3 (Tear)**: Menggelengkan kepala ke samping mencabik sasaran dengan taring tertanam.
  - **Frame 4 (Reset)**: Menarik kepala kembali ke posisi tegak menggeram buas.

### 2.3 Animasi `hurt` (3 Frame, One-Shot)
*Kondisi: Terkena hantaman roket pisang atau tameng sitrus.*
- **Kecepatan**: 8 FPS (Durasi $\approx 0.38$ detik).
- **Rincian Frame**:
  - **Frame 1**: Kepala dan moncong terpelanting ke belakang, mata memicing kaget kesakitan.
  - **Frame 2**: Tubuh terhuyung mundur $2$ px, kaki depan terangkat canggung.
  - **Frame 3**: Mendarat kembali menjejakkan kaki dengan tatapan mata semakin liar dan marah.

### 2.4 Animasi `die` (4 Frame, One-Shot)
*Kondisi: HP habis (0), memancarkan drop orb +6 Resource.*
- **Kecepatan**: 6 FPS (Durasi $\approx 0.67$ detik).
- **Rincian Frame**:
  - **Frame 1**: Kaki depan terlipat lunglai, tubuh tersungkur membentur tanah.
  - **Frame 2**: Tubuh serigala terbaring miring, mata terpejam mengeluarkan erangan terakhir.
  - **Frame 3**: Raga serigala larut menjadi asap kabut hutan kehitaman, memunculkan kristal air/resource bercahaya.
  - **Frame 4**: Asap menghilang sepenuhnya diserap tanah hutan belantara.

---

## 3. Checklist File Aset Siap Pakai

- [ ] `serigala_hutan_run.png` (Spritesheet $5120 \times 1280$ px, 4 frames @ 1280x1280)
- [ ] `serigala_hutan_bite.png` (Spritesheet $5120 \times 1280$ px, 4 frames @ 1280x1280)
- [ ] `serigala_hutan_hurt.png` (Spritesheet $3840 \times 1280$ px, 3 frames @ 1280x1280)
- [ ] `serigala_hutan_die.png` (Spritesheet $5120 \times 1280$ px, 4 frames @ 1280x1280)
- [ ] Resource `serigala_hutan_frames.tres` di Godot Engine dengan 4 klip animasi di atas.
