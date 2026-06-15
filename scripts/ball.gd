extends RigidBody2D
## Ball — 小球
## 处理物理运动、碰撞反弹、出界检测和发射逻辑

# 信号：小球掉落屏幕底部时发出
signal ball_lost()

const MAX_SPEED: float = 600.0           # 最大速度限制
const LAUNCH_VELOCITY: Vector2 = Vector2(200, -350)  # 发射初速度
const RESET_OFFSET_Y: float = 30.0       # 重置时在挡板上方的偏移距离
const DEAD_ZONE_Y: float = 620.0         # 出界判定Y坐标
const MIN_HORIZONTAL_SPEED: float = 50.0 # 最小水平速度阈值（防死循环）

var launched: bool = false               # 是否已发射


func _ready() -> void:
	# 启用连续碰撞检测（CCD），防止高速穿透
	continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY
	# 不受重力影响
	gravity_scale = 0.0
	# 初始状态：锁定物理，停在挡板上方
	freeze = true


func _physics_process(_delta: float) -> void:
	# 限制最大速度
	linear_velocity = linear_velocity.limit_length(MAX_SPEED)

	# 出界检测：小球Y坐标超过屏幕底部
	if position.y > DEAD_ZONE_Y:
		ball_lost.emit()
		reset_ball()

	# 按下空格键发射小球
	if not launched and Input.is_action_just_pressed("launch"):
		launch_ball()


## 发射小球
func launch_ball() -> void:
	launched = true
	freeze = false
	linear_velocity = LAUNCH_VELOCITY


## 重置小球位置到挡板上方
func reset_ball() -> void:
	launched = false
	freeze = true
	linear_velocity = Vector2.ZERO
	# 位置重置到挡板上方（由GameManager或外部调用设置position）


## 碰撞时检测水平速度，防止垂直反弹死循环
func _on_body_entered(_body: Node) -> void:
	# 如果水平速度分量过小，添加随机偏移打破死循环
	if abs(linear_velocity.x) < MIN_HORIZONTAL_SPEED:
		linear_velocity.x += randi_range(-30, 30)