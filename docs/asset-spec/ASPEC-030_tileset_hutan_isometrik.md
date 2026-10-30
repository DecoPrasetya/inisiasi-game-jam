# 🎨 ASPEC-030: Spesifikasi Aset - Tileset Hutan Isometrik

> **Asset Specification Document (ASPEC) - Lingkungan & TileMap**  
> ID Dokumen: **ASPEC-030**  
> Sumber Acuan: 🟢 **[SKETCH: Mapping Belah Ketupat CoC]**, 📘 **[PRD: 4.3]**, 📘 **[TRD-002]**  
> Penanggung Jawab: **Designer 1 (Environment Artist)**

---

## 1. Konsep Visual & Spesifikasi Teknis Tile

- **Proyeksi**: Isometrik 2:1 standar (Diamond Clash of Clans).
- **Dimensi Tile Sel**: Lebar $64$ px, Tinggi $32$ px.
- **Rasio Proyeksi**: Sumbu X menyamping $32$ px, Sumbu Y vertikal $16$ px.
- **Palet Warna**: Hijau pinus tua hutan belantara (`#1E3F20`), hijau rumput segar (`#38761D`), cokelat tanah humus (`#4E3629`), dan aksen lumut terang (`#6AA84F`).

---

## 2. Katalog Tile dalam TileSet (`tileset_forest.png`)

File spritesheet gabungan atlas berukuran $256 \times 128$ piksel memuat:

| Indeks Tile | Nama Tile | Deskripsi Visual & Fungsi |
| :---: | :--- | :--- |
| **(0, 0)** | **Rumput Dasar A** | Permukaan rumput hijau datar bersih untuk lahan netral. |
| **(1, 0)** | **Rumput Dasar B** | Rumput hijau dengan variasi bunga liar kecil putih/kuning. |
| **(2, 0)** | **Rumput Dasar C** | Rumput hijau dengan tekstur helaian rumput rimbun berlumut. |
| **(3, 0)** | **Plot Tanam Gembur** | Tanah humus cokelat gembur berbentuk belah ketupat di tengah rumput sebagai penanda plot siap ditanami. |
| **(0, 1)** | **Highlight Hijau (Valid)** | Overlay kontur belah ketupat hijau neon transparan ($50\%$) untuk kursor penanaman yang sah. |
| **(1, 1)** | **Highlight Merah (Invalid)**| Overlay kontur belah ketupat merah neon transparan ($50\%$) untuk kursor lahan terlarang / penuh. |
| **(2, 1)** | **Tepian Tebing (NW/NE)** | Potongan tebing tanah dengan kontur batu pemisah ke hutan luar. |
| **(3, 1)** | **Tepian Tebing (SW/SE)** | Potongan tebing tanah bagian bawah mengarah ke semak liar. |

---

## 3. Props Dekoratif Lingkungan Luar (Penyekap Peta)

Ditempatkan di luar batas diamond $11 \times 11$ untuk menciptakan ilusi hutan belantara lebat yang mengurung rumah:

| Nama Prop | Dimensi Kanvas | Titik Pivot (Origin) | Deskripsi Visual |
| :--- | :---: | :---: | :--- |
| **Pohon Pinus Rimbun** | $64 \times 96$ px | $(32, 88)$ px | Pohon pinus tinggi berdaun jarum rimbun bertingkat tiga, batang pohon kecokelatan tua. |
| **Pohon Ek Kuno** | $96 \times 96$ px | $(48, 86)$ px | Pohon tua bertulang cabang besar berlumut dengan dedaunan kanopi lebat membayangi tanah. |
| **Semak Belukar Beri** | $32 \times 32$ px | $(16, 28)$ px | Rumpun semak lebat berhiaskan buah beri liar merah menyala di tepi jalur jalan. |
| **Batu Lumut Hutan** | $48 \times 32$ px | $(24, 26)$ px | Bongkahan batu kali abu-abu kebiruan yang separuh permukaannya tertutup lumut hijau tebal. |
| **Tunggul Kayu Berjamur** | $32 \times 32$ px | $(16, 26)$ px | Sisa tebangan pohon purba yang ditumbuhi jamur-jamur kecil berpendar oranye. |

---

## 4. Konfigurasi `TileSet` di Godot Engine 4.x 🔵 [TEKNIS GODOT]

1. Buka resource `TileSet` di Godot Inspector.
2. Atur **Tile Shape**: `Isometric`.
3. Atur **Tile Layout**: `Diamond Down`.
4. Atur **Tile Size**: `Vector2i(64, 32)`.
5. Buat custom data layer:
   - `is_plantable` (Boolean): Bernilai `true` khusus pada tile *Plot Tanam Gembur*.
   - `is_house_area` (Boolean): Bernilai `true` pada area 3×3 pusat.

---

## 5. Checklist File Aset Siap Pakai

- [ ] `tileset_forest_64x32.png` (Atlas PNG $256 \times 128$ px)
- [ ] `tile_selector_green.png` ($64 \times 32$ px)
- [ ] `tile_selector_red.png` ($64 \times 32$ px)
- [ ] `prop_pine_tree.png` ($64 \times 96$ px)
- [ ] `prop_oak_tree.png` ($96 \times 96$ px)
- [ ] `prop_bush_berries.png` ($32 \times 32$ px)
- [ ] `prop_mossy_stone.png` ($48 \times 32$ px)
- [ ] `prop_wood_stump.png` ($32 \times 32$ px)
- [ ] Resource `forest_tileset.tres` di Godot Engine terkonfigurasi isometrik.
