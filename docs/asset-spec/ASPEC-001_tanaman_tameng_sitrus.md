# 🎨 ASPEC-001: Spesifikasi Aset - Tanaman Tameng Sitrus

> **Asset Specification Document (ASPEC) - Entitas Tanaman**  
> ID Dokumen: **ASPEC-001**  
> Sumber Acuan: 🟢 **[LIST TANAMAN: Tameng Sitrus]**, 📘 **[TRD-009]**  
> Penanggung Jawab: **Designer 2 (Artist & Animator)**

---

## 1. Konsep Visual & Karakteristik

- **Nama Karakter**: Tameng Sitrus (Citrus Shield)
- **Role & Rarity**: `DEFENDER` / `COMMON` (Umum)
- **Deskripsi Visual 🟢**: Buah jeruk bulat oranye cerah dengan ekspresi tegas dan berani. Tangan kanannya memegang erat potongan tebal irisan buah jeruk sebagai tameng kokoh berpola serat bulir sitrus berair. Mengenakan mahkota daun hijau kecil di kepalanya.
- **Ukuran Kanvas Sprite**: $64 \times 64$ piksel (Area tubuh efektif $\approx 40 \times 44$ px).
- **Titik Tumpu (Pivot/Origin)**: $(32, 58)$ piksel (Tepat di alas pijakan tanah).

---

## 2. Rincian Animasi (Standar 3–5 Frame)

Setiap klip animasi dirancang seringkas mungkin (3–5 frame) agar animasi padat, responsif, dan ringan untuk Game Jam:

### 2.1 Animasi `idle` (4 Frame, Loop)
*Kondisi: Berdiri siaga di plot tanam saat tidak ada aksi serang.*
- **Kecepatan**: 6 FPS (Durasi $\approx 0.67$ detik).
- **Rincian Frame**:
  - **Frame 1**: Berdiri tegak bersahaja, tameng menutupi setengah dada, daun di kepala bergoyang pelan.
  - **Frame 2**: Tubuh membal lembut ke bawah ($1$ px) seperti menarik napas, tameng tetap kokoh.
  - **Frame 3**: Tubuh kembali naik ke posisi puncak, mata berkedip sekali menandakan kesiapsiagaan.
  - **Frame 4**: Sedikit condong ke depan mengantisipasi ancaman dari arah luar.

### 2.2 Animasi `bash_attack` (4 Frame, One-Shot)
*Kondisi: Memancarkan skill Hentakan Sari Jeruk (CC Slow + Knockback) tiap 4 detik.*
- **Kecepatan**: 8 FPS (Durasi $0.5$ detik).
- **Rincian Frame**:
  - **Frame 1 (Windup)**: Menarik tameng irisan jeruk ke belakang tubuh dengan kedua tangan, mata menyipit fokus.
  - **Frame 2 (Impact Slam)**: Mendorong tameng sekuat tenaga ke arah depan, kaki menjejak tanah kuat-kuat.
  - **Frame 3 (Juice Splash)**: Permukaan tameng memancarkan semburan bulir sari jeruk oranye bercahaya ke area depan.
  - **Frame 4 (Recovery)**: Menarik kembali tameng ke posisi depan dada, tersenyum bangga.

### 2.3 Animasi `hit_reaction` (3 Frame, One-Shot)
*Kondisi: Terkena cakar/gigitan musuh (menerapkan passive armor reduction).*
- **Kecepatan**: 8 FPS (Durasi $\approx 0.38$ detik).
- **Rincian Frame**:
  - **Frame 1**: Tubuh tersentak mundur $2$ px, tameng bergetar menahan benturan fisik, mata meringis menahan sakit.
  - **Frame 2**: Berdiri menahan pijakan dengan tameng terdorong sedikit ke sisi tubuh.
  - **Frame 3**: Menghentakkan tameng kembali ke depan mengembalikan postur pertahanan kokoh.

### 2.4 Animasi `die` (4 Frame, One-Shot)
*Kondisi: HP mencapai 0, tanaman hancur dan plot lahan dibebaskan.*
- **Kecepatan**: 7 FPS (Durasi $\approx 0.57$ detik).
- **Rincian Frame**:
  - **Frame 1**: Tameng irisan jeruk terbelah dua dan terlempar lepas ke samping tanah.
  - **Frame 2**: Tubuh buah jeruk melembek memar kecokelatan, mata berubah menjadi tanda silang ($X\_X$).
  - **Frame 3**: Kulit jeruk pecah, memercikkan genangan sari jeruk berbusa yang meresap ke tanah.
  - **Frame 4**: Menyisakan sehelai daun kering layu di tanah sebelum memudar transparan (fade out).

---

## 3. Checklist File Aset Siap Pakai

- [ ] `tameng_sitrus_idle.png` (Spritesheet $256 \times 64$ px, 4 frames horizontal)
- [ ] `tameng_sitrus_bash.png` (Spritesheet $256 \times 64$ px, 4 frames horizontal)
- [ ] `tameng_sitrus_hit.png` (Spritesheet $192 \times 64$ px, 3 frames horizontal)
- [ ] `tameng_sitrus_die.png` (Spritesheet $256 \times 64$ px, 4 frames horizontal)
- [ ] `tameng_sitrus_icon.png` (Ikon tunggal $32 \times 32$ px untuk kartu belanja)
- [ ] Resource `tameng_sitrus_frames.tres` di Godot Engine dengan 4 klip animasi di atas.
