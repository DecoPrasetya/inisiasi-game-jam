# 🎨 ASPEC-011: Spesifikasi Aset - Musuh Babi Hutan Liar

> **Asset Specification Document (ASPEC) - Entitas Hewan / Monster**  
> ID Dokumen: **ASPEC-011**  
> Sumber Acuan: 🟢 **[SKETCH: Hewan/Monster]**, 📘 **[PRD: 5.3, 7.2]**, 📘 **[TRD-007]**  
> Penanggung Jawab: **Designer 2 (Artist & Animator)**

---

## 1. Konsep Visual & Karakteristik

- **Nama Karakter**: Babi Hutan Liar (Wild Boar)
- **Tipe Serangan 🟢**: `MELEE` (Jarak Dekat - Tanky Charger)
- **Deskripsi Visual**: Monster babi hutan bertubuh tambun dan berotot pejal dengan kulit tebal berlapis lumpur kering. Memiliki surai bulu hitam kasar berduri di sepanjang tulang punggungnya. Ciri paling mencolok adalah sepasang taring gading putih gading tajam melengkung ke atas dari rahang bawahnya.
- **Ukuran Kanvas Sprite**: $1280 \times 1280$ piksel (Area tubuh efektif $\approx 1040 \times 800$ px).
- **Titik Tumpu (Pivot/Origin)**: $(640, 1120)$ piksel (Tapak tengah kaki).

---

## 2. Rincian Animasi (Standar 3–5 Frame)

### 2.1 Animasi `walk` (4 Frame, Loop)
*Kondisi: Bergerak maju menerobos hutan (kecepatan 45 px/s).*
- **Kecepatan**: 7 FPS (Durasi $\approx 0.57$ detik).
- **Rincian Frame**:
  - **Frame 1**: Kaki kiri depan dan kaki kanan belakang menjejak maju, kepala tertunduk rendah membidik sasaran.
  - **Frame 2**: Tubuh bergoyang berat ke kanan, surai punggung bergerak mantap, debu tanah terangkat di kaki belakang.
  - **Frame 3**: Kaki kanan depan berganti menjejak tanah, taring melengkung mengarah lurus ke depan.
  - **Frame 4**: Tubuh bergoyang ke kiri merampungkan siklus langkah berirama berat.

### 2.2 Animasi `headbutt` (4 Frame, One-Shot)
*Kondisi: Menyeruduk sasaran tiap 1.6 detik (Damage 15).*
- **Kecepatan**: 7 FPS (Durasi $\approx 0.57$ detik).
- **Rincian Frame**:
  - **Frame 1 (Crouch)**: Menekuk kaki depan, hidung dan taring hampir menyentuh tanah, mendengus uap marah.
  - **Frame 2 (Gore Upward)**: Mengayunkan kepala menyundul kuat ke atas, mencungkil tanaman dengan kedua taringnya.
  - **Frame 3 (Stomp)**: Menghentakkan kedua kaki depan ke tanah dengan kepala terangkat gagah.
  - **Frame 4 (Reset)**: Menurunkan kembali moncong taring ke posisi jelajah siaga.

### 2.3 Animasi `hurt` (3 Frame, One-Shot)
*Kondisi: Tertembus proyektil atau terhantam tameng sitrus.*
- **Kecepatan**: 7 FPS (Durasi $\approx 0.43$ detik).
- **Rincian Frame**:
  - **Frame 1**: Tubuh tambun bergetar menahan hantaman, mata menyipit geram, debu terlempar dari bulunya.
  - **Frame 2**: Kaki depan sedikit tergeser ke belakang $1$ px namun tidak tumbang.
  - **Frame 3**: Mengibaskan kepala kuat-kuat menegaskan ketebalan daya tahannya.

### 2.4 Animasi `die` (4 Frame, One-Shot)
*Kondisi: HP 120 habis terkuras, menjatuhkan drop orb +14 Resource.*
- **Kecepatan**: 6 FPS (Durasi $\approx 0.67$ detik).
- **Rincian Frame**:
  - **Frame 1**: Kaki depan patah lemas menapak tanah, taring gading menancap ke tanah.
  - **Frame 2**: Tubuh babi hutan ambruk terguling menyamping membentur tanah dengan kepulan debu.
  - **Frame 3**: Tubuhnya mulai terurai menjadi kabut partikel tanah cokelat keemasan, melahirkan orb kristal besar.
  - **Frame 4**: Sisa raga lenyap diserap bumi hutan belantara.

---

## 3. Checklist File Aset Siap Pakai

- [ ] `babi_hutan_walk.png` (Spritesheet $5120 \times 1280$ px, 4 frames @ 1280x1280)
- [ ] `babi_hutan_headbutt.png` (Spritesheet $5120 \times 1280$ px, 4 frames @ 1280x1280)
- [ ] `babi_hutan_hurt.png` (Spritesheet $3840 \times 1280$ px, 3 frames @ 1280x1280)
- [ ] `babi_hutan_die.png` (Spritesheet $5120 \times 1280$ px, 4 frames @ 1280x1280)
- [ ] Resource `babi_hutan_frames.tres` di Godot Engine dengan 4 klip animasi di atas.
