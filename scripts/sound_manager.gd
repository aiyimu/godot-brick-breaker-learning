extends Node
## SoundManager — 音效管理单例（autoload）
## 负责音效播放、背景音乐控制、音量管理

# === 音频资源预加载 ===

const SFX_RESOURCES: Dictionary = {
	"brick_hit": preload("res://assets/sounds/sfx/brick_hit.ogg"),
	"brick_destroy": preload("res://assets/sounds/sfx/brick_destroy.ogg"),
	"ball_hit_paddle": preload("res://assets/sounds/sfx/ball_hit_paddle.ogg"),
	"ball_hit_wall": preload("res://assets/sounds/sfx/ball_hit_wall.ogg"),
	"ball_lost": preload("res://assets/sounds/sfx/ball_lost.ogg"),
	"game_over": preload("res://assets/sounds/sfx/game_over.wav"),
	"game_win": preload("res://assets/sounds/sfx/game_win.mp3"),
}

const BGM_RESOURCES: Dictionary = {
	"gameplay_bgm": preload("res://assets/sounds/bgm/gameplay_bgm.mp3"),
}

# === SFX 播放器池（轮询复用，支持同时播放多个音效） ===

const SFX_POOL_SIZE: int = 8
var sfx_players: Array[AudioStreamPlayer] = []
var _sfx_index: int = 0

# === BGM 播放器（单例，同一时间只有一首背景音乐） ===

var bgm_player: AudioStreamPlayer = null

# === 音量（0.0 ~ 1.0，线性） ===

var sfx_volume: float = 1.0:
	set(v):
		sfx_volume = clamp(v, 0.0, 1.0)
		_refresh_sfx_volume()
var bgm_volume: float = 1.0:
	set(v):
		bgm_volume = clamp(v, 0.0, 1.0)
		_refresh_bgm_volume()


func _ready() -> void:
	# 确保 autoload 在场景暂停时仍能处理音频（BGM 切换等）
	process_mode = Node.PROCESS_MODE_ALWAYS

	# 创建 SFX 播放器池
	for _i in range(SFX_POOL_SIZE):
		var player := AudioStreamPlayer.new()
		add_child(player)
		sfx_players.append(player)

	# 创建 BGM 播放器
	bgm_player = AudioStreamPlayer.new()
	add_child(bgm_player)


## 播放指定名称的音效
func play_sfx(sfx_name: String) -> void:
	if not SFX_RESOURCES.has(sfx_name):
		push_warning("SoundManager: 未找到音效资源 — " + sfx_name)
		return

	var player := sfx_players[_sfx_index]
	_sfx_index = (_sfx_index + 1) % SFX_POOL_SIZE
	player.stream = SFX_RESOURCES[sfx_name]
	player.volume_db = linear_to_db(sfx_volume)
	player.play()


## 播放指定名称的背景音乐（循环播放）
func play_bgm(bgm_name: String) -> void:
	if not BGM_RESOURCES.has(bgm_name):
		push_warning("SoundManager: 未找到背景音乐资源 — " + bgm_name)
		return

	bgm_player.stream = BGM_RESOURCES[bgm_name]
	bgm_player.volume_db = linear_to_db(bgm_volume)
	bgm_player.play()


## 停止背景音乐
func stop_bgm() -> void:
	bgm_player.stop()


## 设置音效音量（0.0 ~ 1.0）
func set_sfx_volume(vol: float) -> void:
	sfx_volume = vol


## 设置背景音乐音量（0.0 ~ 1.0）
func set_bgm_volume(vol: float) -> void:
	bgm_volume = vol


# === 内部方法 ===

## 刷新所有 SFX 播放器的音量
func _refresh_sfx_volume() -> void:
	var db := linear_to_db(sfx_volume)
	for player in sfx_players:
		player.volume_db = db


## 刷新 BGM 播放器的音量
func _refresh_bgm_volume() -> void:
	if bgm_player:
		bgm_player.volume_db = linear_to_db(bgm_volume)
