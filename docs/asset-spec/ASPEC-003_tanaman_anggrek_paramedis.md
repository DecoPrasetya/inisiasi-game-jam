# 🎨 ASPEC-003: Spesifikasi Aset - Tanaman Anggrek Paramedis

> **Asset Specification Document (ASPEC) - Entitas Tanaman**  
> ID Dokumen: **ASPEC-003**  
> Sumber Acuan: 🟢 **[LIST TANAMAN: Anggrek Paramedis]**, 📘 **[TRD-011]**  
> Penanggung Jawab: **Designer 2 (Artist & Animator)**

---

## 1. Konsep Visual & Karakteristik

- **Nama Karakter**: Anggrek Paramedis (Paramedic Orchid)
- **Role & Rarity**: `SUPPORTER` / `RARE` (Langka)
- **Deskripsi Visual 🟢**: Bunga anggrek hutan yang anggun dan berwibawa dengan kelopak gradasi ungu-magenta dan putih bersih. Mengenakan selempang paramedis hijau di batangnya. Tangan kanannya membawa tas jinjing kotak pertolongan pertama (medkit) mini putih berhiaskan simbol palang hijau bersinar lembut.
- **Ukuran Kanvas Sprite**: $64 \times 64$ piksel (Area tubuh efektif $\approx 38 \times 46$ px).
- **Titik Tumpu (Pivot/Origin)**: $(32, 58)$ piksel (Alas batang di tanah).

---

## 2. Rincian Animasi (Standar 3–5 Frame)

### 2.1 Animasi `idle` (4 Frame, Loop)
*Kondisi: Mengawasi status kesehatan kawan-kawan di seluruh penjuru lahan.*
- **Kecepatan**: 6 FPS (Durasi $\approx 0.67$ detik).
- **Rincian Frame**:
  - **Frame 1**: Berdiri anggun, kelopak bunga mekar elok, tas medkit tergantung rapi di samping tangkai.
  - **Frame 2**: Batang meliuk lembut ke kiri mengikuti desau angin hutan, kelopak bergetar rileks.
  - **Frame 3**: Batang kembali tegak, mata berkedip hangat penuh welas asih.
  - **Frame 4**: Tas medkit berkedip memancarkan pendaran hijau herbal samar.

### 2.2 Animasi `throw` (4 Frame, One-Shot)
*Kondisi: Melemparkan tas medkit ke tanaman/Rumah dengan sisa HP paling kritis.*
- **Kecepatan**: 8 FPS (Durasi $0.5$ detik).
- **Rincian Frame**:
  - **Frame 1 (Windup)**: Mengangkat tas medkit tinggi ke belakang kelopak bunga, membidik kawan yang terluka.
  - **Frame 2 (Release)**: Mengayunkan tangan ke depan melengkung ke atas, melepas tas medkit terbang ke udara.
  - **Frame 3 (Follow Through)**: Daun tangan terentang ke depan mengiringi lintasan lemparan, badan condong ke depan.
  - **Frame 4 (Reset)**: Menarik tangan kembali ke samping pinggang, memunculkan tas medkit baru dari kuncup bunga.

### 2.3 Animasi `celebrate` (3 Frame, One-Shot)
*Kondisi: Reaksi ceria sesaat setelah medkit sukses mendarat memulihkan kawan.*
- **Kecepatan**: 7 FPS (Durasi $\approx 0.43$ detik).
- **Rincian Frame**:
  - **Frame 1**: Membungkuk sedikit bersiap melompat dengan wajah berbinar.
  - **Frame 2**: Melompat anggun $4$ px ke atas sambil merentangkan kedua daun tangan, partikel hati hijau berpendar.
  - **Frame 3**: Mendarat kembali dengan elok di atas tanah.

### 2.4 Animasi `die` (4 Frame, One-Shot)
*Kondisi: HP habis akibat serangan musuh yang menembus garis belakang.*
- **Kecepatan**: 6 FPS (Durasi $\approx 0.67$ detik).
- **Rincian Frame**:
  - **Frame 1**: Tas medkit terlepas jatuh terbuka menumpahkan perban herbal ke tanah, kelopak bunga terkulai ke bawah.
  - **Frame 2**: Batang patah tertekuk, warna kelopak ungu memudar pucat kelabu.
  - **Frame 3**: Seluruh helai kelopak anggrek gugur berserakan di atas tanah.
  - **Frame 4**: Mahkota kelopak mengering menjadi serpihan hijau keemasan dan perlahan menghilang.

---

## 3. Sub-Aset Proyektil & Efek Sembuh (VFX Terkait)

1. **Sprite Proyektil Medkit (`medkit_projectile.png`)**:
   - 4 Frame Berputar ($16 \times 16$ px):
     - Kotak P3K putih bersilang hijau yang berputar vertikal di udara saat melayang ke target.
2. **Animasi Ledakan Sembuh (`heal_impact.png`)**:
   - 4 Frame ($48 \times 48$ px):
     - *Frame 1*: Medkit terbuka menyentuh tanah, gelombang hijau melingkar memancar.
     - *Frame 2*: Simbol palang hijau besar bersinar di atas tubuh tanaman target (+24 HP).
     - *Frame 3*: Percikan partikel daun sembuh berkilau naik ke atas tubuh target.
     - *Frame 4*: Efek cahaya memudar halus meninggalkan kilau segar pada daun target.

---

## 4. Checklist File Aset Siap Pakai

- [ ] `anggrek_paramedis_idle.png` (Spritesheet $256 \times 64$ px, 4 frames)
- [ ] `anggrek_paramedis_throw.png` (Spritesheet $256 \times 64$ px, 4 frames)
- [ ] `anggrek_paramedis_celebrate.png` (Spritesheet $192 \times 64$ px, 3 frames)
- [ ] `anggrek_paramedis_die.png` (Spritesheet $256 \times 64$ px, 4 frames)
- [ ] `medkit_projectile.png` (Spritesheet rotasi $64 \times 16$ px, 4 frames)
- [ ] `heal_impact.png` (Spritesheet ledakan heal $192 \times 48$ px, 4 frames)
- [ ] `anggrek_paramedis_icon.png` (Ikon tunggal $32 \times 32$ px untuk shop card)
