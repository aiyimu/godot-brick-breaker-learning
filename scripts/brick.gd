extends StaticBody2D
## Brick — 砖块
## 处理砖块生命值、被击中逻辑、发出击碎信号与自我销毁

# 信号：砖块被击碎时发出，携带分值
signal brick_destroyed(score_value: int)

@export var health: int = 1               # 砖块生命值
@export var score_value: int = 10         # 击碎该砖块获得的分数

# 不同生命值对应的颜色
const COLORS: Dictionary = {
	1: Color(0.2, 0.8, 0.2),    # 绿色 — 1 血
	2: Color(0.9, 0.8, 0.1),    # 黄色 — 2 血
	3: Color(0.9, 0.3, 0.1),    # 橙色 — 3 血
}

@onready var color_rect: ColorRect = $ColorRect


func _ready() -> void:
	# 加入 bricks 组，供 GameManager 批量查询
	add_to_group("bricks")
	# 根据生命值设置颜色
	_update_color()


## 被小球击中时调用（由 ball.gd 的碰撞回调触发）
func hit() -> void:
	health -= 1
	if health <= 0:
		# 砖块被击碎，发出信号并销毁自身
		brick_destroyed.emit(score_value)
		queue_free()
	else:
		# 还未被击碎，更新颜色
		_update_color()


## 根据当前生命值更新砖块颜色
func _update_color() -> void:
	if color_rect:
		color_rect.color = COLORS.get(health, Color(0.8, 0.2, 0.2))
