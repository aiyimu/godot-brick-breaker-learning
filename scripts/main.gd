extends Node2D
## Main — 主场景
## 负责初始化游戏，应用设置，适配难度系统，处理返回菜单

@onready var bricks_container: Node2D = $GameArea/BricksContainer


func _ready() -> void:
	# 应用窗口分辨率设置
	_apply_window_settings()
	# 重置 GameManager 全局状态（autoload 不会随场景重载而重置）
	GameManager.reset_game()
	# 生成砖块网格（行列数由 SettingsManager 动态提供）
	GameManager.spawn_bricks(bricks_container)
	# 播放游戏背景音乐
	SoundManager.play_bgm("gameplay_bgm")


func _process(_delta: float) -> void:
	# Esc 键返回主菜单
	if Input.is_action_just_pressed("ui_cancel"):
		_return_to_menu()


## 应用窗口分辨率设置
func _apply_window_settings() -> void:
	var width: int = SettingsManager.get_setting("window_width", 800)
	var height: int = SettingsManager.get_setting("window_height", 600)
	DisplayServer.window_set_size(Vector2i(width, height))


## 返回主菜单
func _return_to_menu() -> void:
	SoundManager.stop_bgm()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
