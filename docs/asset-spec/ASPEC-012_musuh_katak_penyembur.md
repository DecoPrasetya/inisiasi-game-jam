# 🎨 ASPEC-012: Spesifikasi Aset - Musuh Katak Penyembur

> **Asset Specification Document (ASPEC) - Entitas Hewan / Monster**  
> ID Dokumen: **ASPEC-012**  
> Sumber Acuan: 🟢 **[SKETCH: Hewan/Monster]**, 📘 **[PRD: 5.3, 7.2]**, 📘 **[TRD-007]**  
> Penanggung Jawab: **Designer 2 (Artist & Animator)**

---

## 1. Konsep Visual & Karakteristik

- **Nama Karakter**: Katak Penyembur (Spitter Toad)
- **Tipe Serangan 🟢**: `RANGED` (Jarak Jauh - Jangkauan 120px)
- **Deskripsi Visual**: Katak raksasa berlendir hijau lumut gelap dengan totol-totol ungu beracun di punggungnya. Memiliki kantung tenggorokan elastis berwarna kuning pucat yang dapat menggelembung besar saat mengumpulkan asam lambung beracun. Berhenti di jarak 120px dari target untuk meludahkan proyektil asam tiap 2.0 detik.
- **Ukuran Kanvas Sprite**: $1280 \times 1280$ piksel (Area tubuh efektif $\approx 880 \times 720$ px).
- **Titik Tumpu (Pivot/Origin)**: $(640, 1080)$ piksel (Alas perut dan kaki berselaput).

---

## 2. Rincian Animasi (Standar 3–5 Frame)

### 2.1 Animasi `hop` (4 Frame, Loop)
*Kondisi: Melompat-lompat lambat (kecepatan 35 px/s) mendekati jangkauan serang.*
- **Kecepatan**: 6 FPS (Durasi $\approx 0.67$ detik).
- **Rincian Frame**:
  - **Frame 1**: Meringkuk rendah di tanah, kedua kaki belakang melipat rapat siap meloncat.
  - **Frame 2 (Airborne)**: Melenting ke udara melengkung ke depan, kaki belakang terentang lurus.
  - **Frame 3**: Kaki depan mendarat menyentuh rumput meredam laju lompatan.
  - **Frame 4**: Kaki belakang menyusul mendarat mengendur di tanah.

### 2.2 Animasi `spit` (4 Frame, One-Shot)
*Kondisi: Menembakkan proyektil asam beracun tiap 2.0 detik (Damage 8).*
- **Kecepatan**: 7 FPS (Durasi $\approx 0.57$ detik).
- **Rincian Frame**:
  - **Frame 1 (Inhale & Bubble)**: Kantung tenggorokan mengembang besar seperti balon kuning bulat, mata membelalak fokus.
  - **Frame 2 (Spit Blast)**: Kantung mengempis mendadak, mulut terbuka memuntahkan bola asam lendir ungu ke depan.
  - **Frame 3 (Recoil Drool)**: Tetesan sisa asam menetes dari bibir bawah, kepala terdorong mundur sedikit.
  - **Frame 4 (Reset)**: Menelan ludah, kantung tenggorokan kembali rata ke leher.

### 2.3 Animasi `hurt` (3 Frame, One-Shot)
*Kondisi: Terkena serangan (rentan karena HP rendah 36).*
- **Kecepatan**: 8 FPS (Durasi $\approx 0.38$ detik).
- **Rincian Frame**:
  - **Frame 1**: Tubuh berlendir memipih melebar ke samping, mata terpejam kaget kesakitan.
  - **Frame 2**: Bergetar menahan rasa sakit, lendir berceceran di samping tubuh.
  - **Frame 3**: Tubuh mengembang kembali menatap waspada.

### 2.4 Animasi `die` (4 Frame, One-Shot)
*Kondisi: HP habis (0), menjatuhkan drop orb +9 Resource.*
- **Kecepatan**: 6 FPS (Durasi $\approx 0.67$ detik).
- **Rincian Frame**:
  - **Frame 1**: Kantung tenggorokan berdenyut tak stabil, tubuh limbung ke samping.
  - **Frame 2**: Tubuh katak meletus lunak menjadi genangan lendir asam berbuih di atas tanah.
  - **Frame 3**: Dari genangan asam muncul orb kristal sumber daya bercahaya biru bening.
  - **Frame 4**: Lendir mengering terserap rumput tanah hutan.

---

## 3. Sub-Aset Proyektil Asam

- **Sprite Proyektil (`acid_blob.png`)**:
  - Dimensi: Kanvas $1280 \times 1280$ piksel.
  - Gumpalan lendir asam ungu beracun dengan ekor tetesan tipis di belakangnya saat melesat di udara.

---

## 4. Checklist File Aset Siap Pakai

- [ ] `katak_penyembur_hop.png` (Spritesheet $5120 \times 1280$ px, 4 frames @ 1280x1280)
- [ ] `katak_penyembur_spit.png` (Spritesheet $5120 \times 1280$ px, 4 frames @ 1280x1280)
- [ ] `katak_penyembur_hurt.png` (Spritesheet $3840 \times 1280$ px, 3 frames @ 1280x1280)
- [ ] `katak_penyembur_die.png` (Spritesheet $5120 \times 1280$ px, 4 frames @ 1280x1280)
- [ ] `acid_blob.png` (Sprite tunggal proyektil $1280 \times 1280$ px)
- [ ] Resource `katak_penyembur_frames.tres` di Godot Engine dengan 4 klip animasi di atas.
