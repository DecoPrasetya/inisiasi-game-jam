class_name EffectData
extends Resource

@export var effect_id: StringName = &""
@export var effect_kind: Constants.EffectKind = Constants.EffectKind.BUFF

@export_group("Modifikasi Stat (Buff / Debuff)")
## Nama stat target, contoh: &"attack_damage", &"attack_speed", &"move_speed"
@export var target_stat: StringName = &"attack_damage"
## Penambahan/pengurangan angka tetap (Flat). Gunakan nilai negatif untuk Debuff.
@export var flat_modifier: float = 0.0
## Penambahan/pengurangan persentase (0.20 = +20%, -0.30 = -30%).
@export var percent_modifier: float = 0.0

@export_group("Crowd Control (Khusus Defender - Aturan R4)")
@export var cc_type: Constants.CrowdControlType = Constants.CrowdControlType.SLOW

@export_group("Durasi & Tumpukan")
@export_range(0.1, 60.0, 0.1) var duration: float = 5.0
@export var max_stacks: int = 1
