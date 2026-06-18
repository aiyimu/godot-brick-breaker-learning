extends StaticBody2D
## Brick — 砖块
## 处理砖块生命值、被击中逻辑、发出击碎信号与自我销毁

# 信号：砖块被击碎时发出，携带分值
signal brick_destroyed(score_value: int)

@export var health: int = 1               # 砖块生命值
@export var score_value: int = 10         # 击碎该砖块获得的分数

# 不同生命值对应的纹理
const TEXTURES: Dictionary = {
	1: preload("res://assets/sprites/brick_green.png"),
	2: preload("res://assets/sprites/brick_yellow.png"),
	3: preload("res://assets/sprites/brick_orange.png"),
	# 4 血及以上使用红色
}

@onready var sprite: Sprite2D = $Sprite2D
const BRICK_SCALE = 0.255

func _ready() -> void:
	# 加入 bricks 组，供 GameManager 批量查询
	add_to_group("bricks")
	# 根据生命值设置纹理
	_update_texture()


## 被小球击中时调用（由 ball.gd 的碰撞回调触发）
func hit() -> void:
	health -= 1
	if health <= 0:
		# 关键：先离开 bricks 组，再发射信号，最后销毁
		# 避免 GameManager 在 check_win() 时因 queue_free 延迟而读到旧数量
		remove_from_group("bricks")
		SoundManager.play_sfx("brick_destroy")
		brick_destroyed.emit(score_value)
		queue_free()
	else:
		# 还未被击碎，播放击中音效并更新纹理
		SoundManager.play_sfx("brick_hit")
		_update_texture()


## 根据当前生命值更新砖块纹理（4 血及以上使用红色）
func _update_texture() -> void:
	if sprite:
		sprite.texture = TEXTURES.get(health, preload("res://assets/sprites/brick_red.png"))
		sprite.scale = Vector2(BRICK_SCALE, BRICK_SCALE)
