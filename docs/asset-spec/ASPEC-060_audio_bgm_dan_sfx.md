# 🎨 ASPEC-060: Spesifikasi Aset - Audio (BGM & SFX)

> **Asset Specification Document (ASPEC) - Audio & Efek Suara**  
> ID Dokumen: **ASPEC-060**  
> Sumber Acuan: 🟢 **[SKETCH: Suasana Hutan & Serangan Malam]**, 📘 **[PRD: 8.4]**  
> Penanggung Jawab: **Designer 1 / Programmer 3 (Sound Designer)**

---

## 1. Konsep Desain Audio

Desain audio menggabungkan atmosfer hutan alami dengan nuansa taktis menantang:
- **Siang Hari**: Hangat, santai, dan penuh suara alam yang menenangkan untuk sesi berkebun dan merencanakan strategi.
- **Malam Hari**: Mencekam, bertempo cepat dengan perkusi kayu/kulit hewan alami yang memompa adrenalin pertahanan menara.

---

## 2. Musik Latar Belakang (BGM - Format `.ogg` Seamless Loop)

| Nama File | Durasi | Tempo | Karakter Musik & Instrumen |
| :--- | :---: | :---: | :--- |
| `bgm_day_peaceful.ogg` | 02:15 | 88 BPM | Gitar akustik nilon ceria, suling bambu lembut, petikan ukulele kayu, dan suara desau angin serta kicauan burung hutan. |
| `bgm_night_defense.ogg` | 02:40 | 128 BPM | Tabuhan gendang tribal kayu bertempo kencang, denting gambang kayu cepat, desingan biola gesek bernada rendah tegang, dan lolongan angin malam. |
| `bgm_game_over.ogg` | 00:20 | 65 BPM | Petikan dawai akustik sendu yang melambat diakhiri dengungan senja menandakan runtuhnya pondok hutan. |

---

## 3. Efek Suara Interaksi Tanaman (SFX - Format `.wav` 44.1 kHz)

| Nama File SFX | Durasi | Keterangan Suara & Momen Pemicu |
| :--- | :---: | :--- |
| `sfx_plant_place.wav` | 0.3s | Suara tanah gembur ditepuk dan helai daun segar menancap (*thump-rustle*) saat pemain menaruh tanaman di plot. |
| `sfx_plant_shovel.wav` | 0.35s | Suara sekop besi mencongkel akar tanaman dari tanah gembur (*crunch-scrape*) saat mencabut tanaman. |
| `sfx_citrus_bash.wav` | 0.5s | Suara benturan tameng keras berlapis cairan sitrus kental (*clang-squish*) diikuti desisan sari asam memercik. |
| `sfx_bazooka_fire.wav` | 0.45s | Dentuman roket artileri ditembakkan dari tabung logam berongga (*thump-whooosh*). |
| `sfx_bazooka_explode.wav`| 0.6s | Ledakan berdebam berat menggetarkan tanah dengan serpihan buah berhamburan (*ka-boom-splat*). |
| `sfx_medkit_throw.wav` | 0.4s | Desingan udara tas medkit meluncur melengkung di udara (*fwoosh*). |
| `sfx_medkit_heal.wav` | 0.5s | Gemerincing lonceng kristal herbal berpadu hembusan napas lega yang menyejukkan (*sparkle-chime*). |

---

## 4. Efek Suara Musuh & Tempur (SFX)

| Nama File SFX | Durasi | Keterangan Suara & Momen Pemicu |
| :--- | :---: | :--- |
| `sfx_wolf_bite.wav` | 0.35s | Geraman lapar serigala disusul kertakan rahang taring tajam mengatup mengoyak daun (*growl-snap*). |
| `sfx_boar_charge.wav` | 0.5s | Suara dengusan napas berat babi hutan disusul hantaman gading tanduk ke sasaran (*snort-thud*). |
| `sfx_toad_spit.wav` | 0.3s | Suara gelembung udara meletup dan semburan lendir asam basah melesat (*bloop-splurt*). |
| `sfx_shaman_chant.wav` | 0.8s | Bisikan mantra purba berdengung rendah yang menggetarkan udara diiringi bunyi gesekan kayu tongkat (*hum-rattle*). |
| `sfx_enemy_die.wav` | 0.4s | Runtuhnya jasad monster menjadi kepulan asap kabut malam (*poof-dissolve*). |

---

## 5. Efek Suara Sistem & UI (SFX)

| Nama File SFX | Durasi | Keterangan Suara & Momen Pemicu |
| :--- | :---: | :--- |
| `sfx_resource_collect.wav`| 0.25s | Suara tetesan air jernih berdenting merdu saat orb diserap ke indikator saldo (*ping-glug*). |
| `sfx_button_click.wav` | 0.15s | Suara ketukan ranting kayu kering berongga (*wood-tap*). |
| `sfx_night_warning_horn.wav`| 1.2s | Tiupan tanduk terompet hutan perang yang menggema menandakan gerombolan malam mulai menyerang (*horn-blast*). |
| `sfx_house_damaged.wav` | 0.5s | Suara balok kayu penyangga rumah berderit patah akibat benturan (*creak-crash*). |
| `sfx_house_upgrade.wav` | 0.7s | Suara palu kayu berdentang tiga kali disusul suara lonceng keberhasilan (*tap-tap-tada!*). |

---

## 6. Checklist File Audio Siap Pakai

- [ ] `bgm_day_peaceful.ogg`, `bgm_night_defense.ogg`, `bgm_game_over.ogg`
- [ ] `sfx_plant_place.wav`, `sfx_plant_shovel.wav`
- [ ] `sfx_citrus_bash.wav`, `sfx_bazooka_fire.wav`, `sfx_bazooka_explode.wav`
- [ ] `sfx_medkit_throw.wav`, `sfx_medkit_heal.wav`
- [ ] `sfx_wolf_bite.wav`, `sfx_boar_charge.wav`, `sfx_toad_spit.wav`, `sfx_shaman_chant.wav`, `sfx_enemy_die.wav`
- [ ] `sfx_resource_collect.wav`, `sfx_night_warning_horn.wav`, `sfx_house_damaged.wav`, `sfx_house_upgrade.wav`
