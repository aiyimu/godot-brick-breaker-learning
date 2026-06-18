extends Control
## MenuManager — 主菜单逻辑
## 处理按钮事件、难度选择、设置面板与场景切换

@onready var start_button: Button = $StartButton
@onready var difficulty_option: OptionButton = $DifficultyOptionButton
@onready var settings_button: Button = $SettingsButton
@onready var quit_button: Button = $QuitButton
@onready var settings_panel: Panel = $SettingsPanel
@onready var bgm_volume_slider: HSlider = $SettingsPanel/BgmVolumeSlider
@onready var sfx_volume_slider: HSlider = $SettingsPanel/SfxVolumeSlider
@onready var lives_slider: HSlider = $SettingsPanel/LivesSlider
@onready var lives_value_label: Label = $SettingsPanel/LivesValueLabel
@onready var close_settings_button: Button = $SettingsPanel/CloseSettingsButton


func _ready() -> void:
	# 播放菜单背景音乐
	SoundManager.play_bgm("menu_bgm")

	# 初始化难度选项
	_populate_difficulty_options()

	# 初始化设置面板值
	_load_settings_values()

	# 连接按钮信号
	start_button.pressed.connect(_on_start_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	difficulty_option.item_selected.connect(_on_difficulty_selected)

	# 连接设置面板信号
	close_settings_button.pressed.connect(_on_close_settings)
	bgm_volume_slider.value_changed.connect(_on_bgm_volume_changed)
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_changed)
	lives_slider.value_changed.connect(_on_lives_changed)


## 填充难度下拉选项（从 SettingsManager 读取预设）
func _populate_difficulty_options() -> void:
	difficulty_option.clear()
	# 添加难度选项：简单 / 普通 / 困难
	difficulty_option.add_item("简单")
	difficulty_option.add_item("普通")
	difficulty_option.add_item("困难")

	# 选中当前难度
	var current: String = SettingsManager.get_setting("difficulty", "normal")
	match current:
		"easy":
			difficulty_option.select(0)
		"normal":
			difficulty_option.select(1)
		"hard":
			difficulty_option.select(2)


## 难度选择变更回调
func _on_difficulty_selected(index: int) -> void:
	match index:
		0:
			SettingsManager.apply_difficulty("easy")
		1:
			SettingsManager.apply_difficulty("normal")
		2:
			SettingsManager.apply_difficulty("hard")


## 开始游戏按钮
func _on_start_pressed() -> void:
	SoundManager.play_sfx("brick_hit")
	# 切换到主游戏场景
	get_tree().change_scene_to_file("res://scenes/main.tscn")


## 设置按钮
func _on_settings_pressed() -> void:
	SoundManager.play_sfx("brick_hit")
	settings_panel.visible = true


## 关闭设置面板
func _on_close_settings() -> void:
	SoundManager.play_sfx("brick_hit")
	settings_panel.visible = false


## 从 SettingsManager 加载设置值到面板控件
func _load_settings_values() -> void:
	bgm_volume_slider.value = SettingsManager.get_setting("bgm_volume", 0.8) * 100.0
	sfx_volume_slider.value = SettingsManager.get_setting("sfx_volume", 1.0) * 100.0
	lives_slider.value = SettingsManager.get_setting("initial_lives", 3)
	lives_value_label.text = str(int(lives_slider.value))


## 背景音乐音量变更
func _on_bgm_volume_changed(value: float) -> void:
	var vol: float = value / 100.0
	SettingsManager.set_setting("bgm_volume", vol)
	SoundManager.set_bgm_volume(vol)


## 音效音量变更
func _on_sfx_volume_changed(value: float) -> void:
	var vol: float = value / 100.0
	SettingsManager.set_setting("sfx_volume", vol)
	SoundManager.set_sfx_volume(vol)


## 初始生命值变更
func _on_lives_changed(value: float) -> void:
	var lives: int = int(value)
	SettingsManager.set_setting("initial_lives", lives)
	lives_value_label.text = str(lives)


## 退出游戏按钮
func _on_quit_pressed() -> void:
	SoundManager.play_sfx("brick_hit")
	get_tree().quit()