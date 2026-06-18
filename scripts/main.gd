extends Node2D
## Main — 主场景
## 负责初始化游戏，重置 GameManager 状态并生成砖块

@onready var bricks_container: Node2D = $GameArea/BricksContainer


func _ready() -> void:
	# 重置 GameManager 全局状态（autoload 不会随场景重载而重置）
	GameManager.reset_game()
	# 生成砖块网格
	GameManager.spawn_bricks(bricks_container)
	# 播放游戏背景音乐
	SoundManager.play_bgm("gameplay_bgm")
