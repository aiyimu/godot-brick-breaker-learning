extends Control
## MenuManager — 主菜单逻辑
## 处理按钮事件、难度选择初始化与场景切换

@onready var start_button: Button = $StartButton
@onready var difficulty_option: OptionButton = $DifficultyOptionButton
@onready var settings_button: Button = $SettingsButton
@onready var quit_button: Button = $QuitButton


func _ready() -> void:
	# 初始化难度选项
	_populate_difficulty_options()

	# 连接按钮信号
	start_button.pressed.connect(_on_start_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	difficulty_option.item_selected.connect(_on_difficulty_selected)


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
	# 设置功能将在后续步骤中实现
	# TODO: 切换到设置场景或弹出设置面板


## 退出游戏按钮
func _on_quit_pressed() -> void:
	SoundManager.play_sfx("brick_hit")
	get_tree().quit()