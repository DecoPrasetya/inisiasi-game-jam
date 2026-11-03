extends Node

# 🟢 [SKETCH: Tanaman Role] - Tepat 3 role eksklusif
enum PlantRole {
	DAMAGE_DEALER,
	SUPPORTER,
	DEFENDER
}

# 🟢 [SKETCH: Rarity] & 📘 [PRD: 5.2]
enum Rarity {
	COMMON,
	RARE,
	EPIC,
	LEGENDARY
}

# 🟢 [SKETCH: Hewan Tipe Serangan]
enum AttackType {
	MELEE,
	RANGED,
	NON_ATTACKING
}

# 🟢 [SKETCH: Arah Serangan 4 Sisi]
enum SpawnSide {
	NORTH_EAST,
	SOUTH_EAST,
	SOUTH_WEST,
	NORTH_WEST
}

# 📘 [PRD: 6.1] - Jenis modifikasi stat
enum EffectKind {
	BUFF,
	DEBUFF,
	CROWD_CONTROL
}

# 🟢 [SKETCH: CC Defender] & 📘 [PRD: 6.1]
enum CrowdControlType {
	STUN,
	SLOW,
	ROOT,
	BLOCK,
	KNOCKBACK,
	TAUNT
}

# 📘 [PRD: 9.1] - Tahapan status permainan
enum GamePhase {
	MENU,
	DAY,
	NIGHT,
	PAUSED,
	GAME_OVER
}

# ⚙️ [REKAYASA DESAIN] - Batasan parameter global
const MAX_HOUSE_LEVEL: int = 10
const MIN_DAMAGE_DEALER_DPS: float = 1.0 # 🟢 [SKETCH: Damage Dealer min 1 DPS]
const DAY_DURATION_SECONDS: float = 45.0 # ⚙️ [REKAYASA DESAIN: Durasi siang]

# 🔵 [TEKNIS GODOT] - Layer Collision Physics 2D
const LAYER_HOUSE: int = 1
const LAYER_PLANTS: int = 2
const LAYER_ENEMIES: int = 3
const LAYER_PROJECTILES: int = 4
const LAYER_COLLECTIBLES: int = 5
