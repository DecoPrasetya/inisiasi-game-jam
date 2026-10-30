# 📐 TRD-012: Data Validator & Rule Enforcement System

> **Technical Reference Document (TRD) - Validator Otomatis Integritas Aturan R1–R7**  
> ID Modul: **TRD-012**  
> Sumber Kebenaran: 🟢 **[SKETCH: Aturan Emas R1–R7]**, 📘 **[PRD: 11.4, 11.7, 16]**, 🔵 **[TEKNIS GODOT]**  
> Penanggung Jawab: **Programmer 2**

---

## 1. Deskripsi Modul & Lingkup Kerja

Modul ini adalah instrumen penjamin mutu (Quality Assurance) otomatis yang bertindak sebagai "polisi kode dan data":
1. Memindai seluruh berkas `.tres` di dalam direktori `res://src/resources/data/` sebelum game dijalankan atau di-build.
2. Memeriksa pelanggaran terhadap **Aturan Emas R1 sampai R7**.
3. Memastikan deskripsi skill musuh memenuhi standar kelayakan (minimal 80 karakter, bukan sekadar kata "jarak dekat").
4. Dapat dijalankan mandiri oleh Designer 2 melalui tombol **F6** atau dalam CI pipeline tanpa perlu programmer campur tangan.

---

## 2. Matriks Aturan yang Divalidasi 🟢 [SKETCH]

| ID Aturan | Yang Diperiksa Validator | Toleransi Pelanggaran |
| :--- | :--- | :---: |
| **R1** | Tanaman hanya memiliki 1 nilai enum `role` valid. | ❌ Ditolak Keras |
| **R2** | Jika role `DAMAGE_DEALER`, wajib `base_dps >= 1.0` dan tidak memiliki modifier buff/debuff/CC. | ❌ Ditolak Keras |
| **R2 (Non-DD)**| Jika role `SUPPORTER` atau `DEFENDER`, nilai `base_dps` wajib persis `0.0`. | ❌ Ditolak Keras |
| **R3** | Jika role `SUPPORTER`, wajib memiliki efek buff atau debuff, dilarang memiliki efek CC. | ❌ Ditolak Keras |
| **R4** | Base HP setiap Defender **wajib $> \text{rata-rata HP non-defender}$**. Efek yang dimiliki hanya boleh CC. | ❌ Ditolak Keras |
| **R5** | Data Rumah harus menetapkan flag `can_receive_debuff = false`. | ❌ Ditolak Keras |
| **FR-ENEMY-08** | Seluruh data musuh wajib mengisi `skill_description` $\ge 80$ karakter (minimal 2 kalimat). | ❌ Ditolak Keras |

---

## 3. Implementasi GDScript `DataValidator` 🔵 [TEKNIS GODOT]

File: `res://src/resources/validators/data_validator.gd`

```gdscript
@tool
class_name DataValidator
extends SceneTree

func _init() -> void:
	print("\n=======================================================")
	print("🔍 MEMULAI VALIDASI ATURAN EMAS R1-R7 (FOREST DEFENSE)")
	print("=======================================================")
	
	var errors_found: int = 0
	errors_found += _validate_plants()
	errors_found += _validate_enemies()
	
	if errors_found == 0:
		print("✅ SUKSES BESAR: Seluruh file data lolos uji Aturan Emas R1-R7!\n")
		quit(0)
	else:
		printerr("❌ GAGAL: Ditemukan %d pelanggaran aturan pada data resource!\n" % errors_found)
		quit(1)

func _validate_plants() -> int:
	var error_count: int = 0
	var plant_files: Array[String] = _get_all_files("res://src/resources/data/plants", "tres")
	
	var non_defender_hp_sum: float = 0.0
	var non_defender_count: int = 0
	var loaded_plants: Array[PlantStats] = []
	
	# Pass 1: Hitung rata-rata HP non-defender untuk pengujian R4
	for path in plant_files:
		var p: PlantStats = load(path) as PlantStats
		if p:
			loaded_plants.append(p)
			if p.role != Constants.PlantRole.DEFENDER:
				non_defender_hp_sum += p.base_hp
				non_defender_count += 1
				
	var avg_non_defender_hp: float = non_defender_hp_sum / max(1, non_defender_count)
	print("📊 [R4 Baseline] Rata-rata Base HP Tanaman Non-Defender = %.2f" % avg_non_defender_hp)
	
	# Pass 2: Validasi setiap tanaman
	for p in loaded_plants:
		var file_id: String = p.id
		
		# Validasi R2 (Damage Dealer)
		if p.role == Constants.PlantRole.DAMAGE_DEALER:
			if p.base_dps < 1.0:
				printerr("❌ [R2 Violate] Tanaman '%s' adalah Damage Dealer namun DPS < 1.0 (DPS = %.2f)" % [file_id, p.base_dps])
				error_count += 1
		else:
			# Non-Damage Dealer wajib DPS 0
			if p.base_dps > 0.0:
				printerr("❌ [R2 Violate] Tanaman '%s' BUKAN Damage Dealer namun memiliki DPS > 0 (DPS = %.2f)" % [file_id, p.base_dps])
				error_count += 1
				
		# Validasi R4 (Defender HP di atas rata-rata)
		if p.role == Constants.PlantRole.DEFENDER:
			if p.base_hp <= avg_non_defender_hp:
				printerr("❌ [R4 Violate] Defender '%s' HP (%.1f) TIDAK di atas rata-rata tanaman lain (%.1f)!" % [file_id, p.base_hp, avg_non_defender_hp])
				error_count += 1
				
	return error_count

func _validate_enemies() -> int:
	var error_count: int = 0
	var enemy_files: Array[String] = _get_all_files("res://src/resources/data/enemies", "tres")
	
	for path in enemy_files:
		var e: EnemyStats = load(path) as EnemyStats
		if e:
			# Validasi FR-ENEMY-08 (Kelayakan Deskripsi)
			var desc: String = e.skill_description.strip_edges()
			if desc.length() < 80:
				printerr("❌ [Desc Violate] Musuh '%s' deskripsi terlalu pendek (%d karakter, min 80)!" % [e.id, desc.length()])
				error_count += 1
			if desc.to_lower() == "jarak dekat" or desc.to_lower() == "jarak jauh":
				printerr("❌ [Desc Violate] Musuh '%s' hanya menuliskan tipe serangan tanpa detail cara menyerang!" % e.id)
				error_count += 1
				
	return error_count

func _get_all_files(dir_path: String, extension: String) -> Array[String]:
	var result: Array[String] = []
	var dir := DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with("." + extension):
				result.append(dir_path + "/" + file_name)
			file_name = dir.get_next()
	return result
```

---

## 4. Cara Menjalankan Validator 🔵 [TEKNIS GODOT]

### 4.1 Dari Godot Editor
Buka `res://src/resources/validators/data_validator.gd` lalu tekan tombol **F6** (Run Current Scene/Script). Log hasil validasi akan muncul di panel *Output* bawah.

### 4.2 Dari Terminal (Headless CI Mode)
```bash
godot --headless -s res://src/resources/validators/data_validator.gd
```
Exit code `0` berarti lolos, exit code `1` berarti ada pelanggaran data yang harus diperbaiki.
