# 🎨 ASPEC-013: Spesifikasi Aset - Musuh Dukun Lumut

> **Asset Specification Document (ASPEC) - Entitas Hewan / Monster**  
> ID Dokumen: **ASPEC-013**  
> Sumber Acuan: 🟢 **[SKETCH: Tipe Tidak Menyerang]**, 📘 **[PRD: 5.3, 7.2]**, 📘 **[TRD-007]**  
> Penanggung Jawab: **Designer 2 (Artist & Animator)**

---

## 1. Konsep Visual & Karakteristik

- **Nama Karakter**: Dukun Lumut (Mossback Shaman)
- **Tipe Serangan 🟢**: `NON_ATTACKING` (Tidak Menyerang Tanaman Maupun Rumah)
- **Deskripsi Visual**: Sosok makhluk hutan purba bertubuh bungkuk yang mengenakan jubah tenunan daun kering berlapis lumut tebal. Wajahnya tersembunyi di balik tudung gelap dengan sepasang mata hijau pudar mistis. Tangan kanannya memegang tongkat kayu meliuk berujung batu kristal zamrud yang memancarkan aura pemulihan (+4 HP/detik) bagi monster kawan di sekitarnya.
- **Ukuran Kanvas Sprite**: $64 \times 64$ piksel (Area tubuh efektif $\approx 42 \times 48$ px).
- **Titik Tumpu (Pivot/Origin)**: $(32, 56)$ piksel (Alas bawah jubah dan tongkat).

---

## 2. Rincian Animasi (Standar 3–5 Frame)

### 2.1 Animasi `walk` (4 Frame, Loop)
*Kondisi: Berjalan lambat (kecepatan 30 px/s) mengawal kawanan monster.*
- **Kecepatan**: 5 FPS (Durasi $0.8$ detik).
- **Rincian Frame**:
  - **Frame 1**: Melangkah pelan, tongkat kayu ditancapkan ke tanah menopang kaki kiri.
  - **Frame 2**: Mengangkat tongkat kayu melayang di udara, helai daun jubah melambai pelan.
  - **Frame 3**: Kaki kanan melangkah maju menapak tanah, tongkat kembali ditancapkan ke tanah.
  - **Frame 4**: Tubuh bungkuk bergeser maju menyelesaikan siklus langkah tenang.

### 2.2 Animasi `chant_aura` (4 Frame, Loop)
*Kondisi: Memancarkan gelombang spora penyembuh ke musuh di sekitarnya dalam radius 80px.*
- **Kecepatan**: 6 FPS (Durasi $\approx 0.67$ detik).
- **Rincian Frame**:
  - **Frame 1**: Mengangkat tongkat kayu tinggi ke udara dengan kedua tangan, kristal zamrud mulai berpendar.
  - **Frame 2**: Kristal zamrud bersinar menyilaukan, mata di balik tudung menyala hijau terang.
  - **Frame 3**: Menghentakkan pangkal tongkat ke tanah, memancarkan lingkaran gelombang spora hijau ke rumput.
  - **Frame 4**: Kabut partikel hijau berputar di sekeliling tanah menyembuhkan kawan sebelum mengulang siklus.

### 2.3 Animasi `hurt` (3 Frame, One-Shot)
*Kondisi: Terkena serangan tembakan proyektil.*
- **Kecepatan**: 7 FPS (Durasi $\approx 0.43$ detik).
- **Rincian Frame**:
  - **Frame 1**: Tubuh bungkuk terdorong mundur, serpihan daun jubah terlepas beterbangan.
  - **Frame 2**: Berpegangan erat pada tongkat kayu menahan agar tidak roboh.
  - **Frame 3**: Menegakkan kembali punggung dengan dengusan marah berbisik.

### 2.4 Animasi `die` (4 Frame, One-Shot)
*Kondisi: HP habis (0), menjatuhkan drop orb bernilai tinggi (+18 Resource).*
- **Kecepatan**: 6 FPS (Durasi $\approx 0.67$ detik).
- **Rincian Frame**:
  - **Frame 1**: Tongkat kayu patah menjadi dua bagian, kristal zamrud pecah kehilangan cahayanya.
  - **Frame 2**: Jubah lumut runtuh lemas ke tanah seolah sosok di dalamnya menghilang.
  - **Frame 3**: Tumpukan jubah daun kering terurai menjadi pendaran kabut spora keemasan melahirkan kristal besar.
  - **Frame 4**: Dedaunan kering tersapu angin malam dan sirna sepenuhnya.

---

## 3. Checklist File Aset Siap Pakai

- [ ] `dukun_lumut_walk.png` (Spritesheet $256 \times 64$ px, 4 frames)
- [ ] `dukun_lumut_chant.png` (Spritesheet $256 \times 64$ px, 4 frames)
- [ ] `dukun_lumut_hurt.png` (Spritesheet $192 \times 64$ px, 3 frames)
- [ ] `dukun_lumut_die.png` (Spritesheet $256 \times 64$ px, 4 frames)
- [ ] Resource `dukun_lumut_frames.tres` di Godot Engine dengan 4 klip animasi di atas.
