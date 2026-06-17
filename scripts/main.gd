extends Node2D
## Main — 主场景
## 负责初始化游戏，调用 GameManager 生成砖块

@onready var bricks_container: Node2D = $GameArea/BricksContainer


func _ready() -> void:
	# 生成砖块网格
	GameManager.spawn_bricks(bricks_container)
