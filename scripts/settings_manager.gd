extends Node
## SettingsManager — 全局配置存储单例
## 负责游戏设置的读写、持久化（ConfigFile）与难度预设

# 信号：设置变更时发出
signal setting_changed(key: String, value: Variant)

# 配置文件路径
const CONFIG_PATH: String = "user://settings.cfg"

# 默认设置
const DEFAULTS: Dictionary = {
	"difficulty": "normal",
	"window_width": 800,
	"window_height": 600,
	"initial_lives": 3,
	"master_volume": 1.0,
	"sfx_volume": 1.0,
	"bgm_volume": 0.8,
}

# 难度预设：不同难度下的砖块行列数
const DIFFICULTY_PRESETS: Dictionary = {
	"easy": {"brick_rows": 2, "brick_cols": 4, "description": "简单"},
	"normal": {"brick_rows": 3, "brick_cols": 5, "description": "普通"},
	"hard": {"brick_rows": 4, "brick_cols": 6, "description": "困难"},
}

var _settings: Dictionary = {}       # 运行时设置缓存
var _config: ConfigFile = ConfigFile.new()


func _ready() -> void:
	_load_settings()


## 获取设置值
func get_setting(key: String, default = null) -> Variant:
	var fallback = default if default != null else DEFAULTS.get(key)
	return _settings.get(key, fallback)


## 修改设置值并持久化
func set_setting(key: String, value: Variant) -> void:
	_settings[key] = value
	_save_settings()
	setting_changed.emit(key, value)


## 应用难度预设（同步更新砖块行列数）
func apply_difficulty(difficulty: String) -> void:
	if not DIFFICULTY_PRESETS.has(difficulty):
		push_error("未知难度: %s" % difficulty)
		return

	set_setting("difficulty", difficulty)
	var preset: Dictionary = DIFFICULTY_PRESETS[difficulty]
	set_setting("brick_rows", preset["brick_rows"])
	set_setting("brick_cols", preset["brick_cols"])


## 获取当前难度的砖块行数
func get_brick_rows() -> int:
	return get_setting("brick_rows", 3)


## 获取当前难度的砖块列数
func get_brick_cols() -> int:
	return get_setting("brick_cols", 5)


## 获取当前难度描述文本
func get_difficulty_description() -> String:
	var diff: String = get_setting("difficulty", "normal")
	return DIFFICULTY_PRESETS.get(diff, {}).get("description", "普通")


## 从配置文件加载设置
func _load_settings() -> void:
	# 先填充默认值
	_settings = DEFAULTS.duplicate()

	if _config.load(CONFIG_PATH) != OK:
		# 配置文件不存在，使用默认值并保存
		_save_settings()
		return

	# 从配置文件读取所有值
	for key in DEFAULTS.keys():
		var value = _config.get_value("settings", key, DEFAULTS[key])
		_settings[key] = value


## 保存设置到配置文件
func _save_settings() -> void:
	for key in _settings.keys():
		_config.set_value("settings", key, _settings[key])
	_config.save(CONFIG_PATH)