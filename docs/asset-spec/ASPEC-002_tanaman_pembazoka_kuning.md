# 🎨 ASPEC-002: Spesifikasi Aset - Tanaman Pembazoka Kuning

> **Asset Specification Document (ASPEC) - Entitas Tanaman**  
> ID Dokumen: **ASPEC-002**  
> Sumber Acuan: 🟢 **[LIST TANAMAN: Pembazoka Kuning]**, 📘 **[TRD-010]**  
> Penanggung Jawab: **Designer 2 (Artist & Animator)**

---

## 1. Konsep Visual & Karakteristik

- **Nama Karakter**: Pembazoka Kuning (Yellow Bazooka)
- **Role & Rarity**: `DAMAGE_DEALER` / `EPIC` (Luar Biasa)
- **Deskripsi Visual 🟢**: Buah pisang berkulit kuning cerah yang mengenakan helm tempur militer hijau daun. Berdiri gagah dengan memanggul senjata bazoka artileri berat di bahu kanannya. Moncong bazoka berdiameter besar dirancang khusus untuk memuntahkan roket amunisi pisang berdaya ledak masif.
- **Ukuran Kanvas Sprite**: $64 \times 64$ piksel (Area tubuh efektif $\approx 46 \times 50$ px).
- **Titik Tumpu (Pivot/Origin)**: $(32, 58)$ piksel (Alas bawah kaki).

---

## 2. Rincian Animasi (Standar 3–5 Frame)

### 2.1 Animasi `idle` (3 Frame, Loop)
*Kondisi: Siaga menanti musuh memasuki jangkauan jauh 180px.*
- **Kecepatan**: 5 FPS (Durasi $0.6$ detik).
- **Rincian Frame**:
  - **Frame 1**: Berdiri tegap, bazoka bertengger di pundak kanan menghadap serong luar, mata mengintai target.
  - **Frame 2**: Tubuh membal turun $1$ px santai, laras bazoka ikut turun tipis mengikuti ritme napas.
  - **Frame 3**: Tubuh terangkat kembali ke posisi awal dengan mantap.

### 2.2 Animasi `shoot` (4 Frame, One-Shot)
*Kondisi: Memuntahkan roket balistik pisang ke kerumunan musuh.*
- **Kecepatan**: 8 FPS (Durasi $0.5$ detik).
- **Rincian Frame**:
  - **Frame 1 (Lock & Aim)**: Mengangkat moncong bazoka membentuk sudut elevasi $45^\circ$, kedua tangan mengunci grip.
  - **Frame 2 (Muzzle Flash)**: Semburan kilatan api kuning dan gumpalan asap keluar dari moncong bazoka, proyektil roket meluncur.
  - **Frame 3 (Recoil)**: Daya tolak balik (recoil) menghentak tubuh pisang mundur $3$ px, helm sedikit terangkat miring.
  - **Frame 4 (Reset)**: Menjejakkan kaki kembali ke posisi tegak, helm kembali ke posisi normal.

### 2.3 Animasi `reload` (4 Frame, One-Shot)
*Kondisi: Dimainkan selama jeda waktu reload 3.5 detik berlangsung.*
- **Kecepatan**: 4 FPS (Durasi $1.0$ detik, diputar perlahan).
- **Rincian Frame**:
  - **Frame 1**: Menurunkan tabung bazoka ke depan dada, membuka katup ruang bakar amunisi di bagian belakang.
  - **Frame 2**: Mengambil sebutir roket pisang baru berkilau dari kantong punggung.
  - **Frame 3**: Mendorong roket pisang masuk ke dalam tabung bazoka hingga berbunyi klik terkunci.
  - **Frame 4**: Mengangkat kembali bazoka ke pundak dengan senyum puas siap membidik gelombang berikutnya.

### 2.4 Animasi `die` (4 Frame, One-Shot)
*Kondisi: Hancur diserang monster saat lini pertahanan jebol.*
- **Kecepatan**: 6 FPS (Durasi $\approx 0.67$ detik).
- **Rincian Frame**:
  - **Frame 1**: Senjata bazoka terlepas dari pundak dan terhempas ke tanah, helm tempur terpental lepas.
  - **Frame 2**: Kulit pisang mulai terkupas dari pucuk kepala ke bawah, tubuh lunglai lunglai kehilangan tenaga.
  - **Frame 3**: Tubuh pisang ambruk terbaring di samping bazokanya yang penyok.
  - **Frame 4**: Tubuh pisang mengering menjadi sehelai kulit pisang tipis lalu memudar hilang.

---

## 3. Sub-Aset Proyektil & Efek Ledakan (VFX Terkait)

1. **Sprite Proyektil (`banana_rocket.png`)**:
   - Dimensi: $24 \times 12$ piksel.
   - Roket pisang berujung runcing dengan sirip pendorong dan nyala api kecil di bagian ekor.
2. **Animasi Ledakan AOE (`rocket_explosion.png`)**:
   - 4 Frame ($64 \times 64$ px):
     - *Frame 1*: Kilatan putih terang di titik benturan tanah.
     - *Frame 2*: Ledakan bola api kuning-oranye mengembang hingga radius 45px.
     - *Frame 3*: Percikan serpihan buah pisang dan gumpalan asap tebal mengepul.
     - *Frame 4*: Asap menipis menyisakan bekas hangus di tanah yang memudar.

---

## 4. Checklist File Aset Siap Pakai

- [ ] `pembazoka_kuning_idle.png` (Spritesheet $192 \times 64$ px, 3 frames)
- [ ] `pembazoka_kuning_shoot.png` (Spritesheet $256 \times 64$ px, 4 frames)
- [ ] `pembazoka_kuning_reload.png` (Spritesheet $256 \times 64$ px, 4 frames)
- [ ] `pembazoka_kuning_die.png` (Spritesheet $256 \times 64$ px, 4 frames)
- [ ] `banana_rocket.png` (Sprite tunggal proyektil $24 \times 12$ px)
- [ ] `banana_rocket_explosion.png` (Spritesheet ledakan $256 \times 64$ px, 4 frames)
- [ ] `pembazoka_kuning_icon.png` (Ikon tunggal $32 \times 32$ px untuk shop card)
