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
var paddle: CharacterBody2D = null       # 挡板引用
var spawn_position: Vector2              # 初始生成位置
var is_out_of_bounds: bool = false       # 出界标记，防止重复触发 ball_lost


func _ready() -> void:
	# 启用连续碰撞检测（CCD），防止高速穿透
	continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY
	# 启用接触监测，否则 body_entered 信号不会触发
	contact_monitor = true
	max_contacts_reported = 10
	# 不受重力影响
	gravity_scale = 0.0
	# 线性/角阻尼归零，防止速度衰减
	linear_damp = 0.0
	angular_damp = 0.0
	# 创建物理材质：弹性=1.0（完全弹性碰撞），摩擦=0.0
	var physics_material := PhysicsMaterial.new()
	physics_material.bounce = 1.0
	physics_material.friction = 0.0
	physics_material_override = physics_material
	# 获取挡板引用
	paddle = get_parent().get_node("Paddle") as CharacterBody2D
	# 记录初始生成位置
	spawn_position = position
	# 连接 ball_lost 信号到 GameManager 单例（防止重复连接）
	if not ball_lost.is_connected(GameManager.lose_life):
		ball_lost.connect(GameManager.lose_life)
	# 初始状态：锁定物理，停在挡板上方
	freeze = true


func _physics_process(_delta: float) -> void:
	# 发射后保持恒定速度
	if launched:
		linear_velocity = linear_velocity.normalized() * MAX_SPEED

	# 出界检测：小球Y坐标超过屏幕底部（加标记防止重复触发）
	if position.y > DEAD_ZONE_Y and not is_out_of_bounds:
		is_out_of_bounds = true
		ball_lost.emit()
		reset_ball()

	# 未发射时跟随挡板移动
	if not launched:
		if paddle:
			position.x = paddle.position.x
			position.y = paddle.position.y - RESET_OFFSET_Y
		# 按下空格键发射小球
		if Input.is_action_just_pressed("launch"):
			launch_ball()


## 发射小球
func launch_ball() -> void:
	# 发射前确保位置在挡板上方，并同步物理引擎内部状态
	if paddle:
		var target_pos := Vector2(paddle.position.x, paddle.position.y - RESET_OFFSET_Y)
		position = target_pos
		PhysicsServer2D.body_set_state(
			get_rid(),
			PhysicsServer2D.BODY_STATE_TRANSFORM,
			Transform2D(0.0, target_pos)
		)
	launched = true
	is_out_of_bounds = false
	freeze = false
	linear_velocity = LAUNCH_VELOCITY


## 重置小球位置到挡板上方
func reset_ball() -> void:
	launched = false
	freeze = true
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	# 使用 call_deferred 延迟设置位置，确保物理引擎正确同步
	if paddle:
		var target_pos := Vector2(paddle.position.x, paddle.position.y - RESET_OFFSET_Y)
		call_deferred("_sync_ball_position", target_pos)


## 同步小球位置到物理引擎内部状态（供 call_deferred 调用）
func _sync_ball_position(pos: Vector2) -> void:
	position = pos
	PhysicsServer2D.body_set_state(
		get_rid(),
		PhysicsServer2D.BODY_STATE_TRANSFORM,
		Transform2D(0.0, pos)
	)


## 碰撞时检测水平速度，防止垂直反弹死循环；检测砖块碰撞
func _on_body_entered(body: Node) -> void:
	# 如果水平速度分量过小，添加随机偏移打破死循环
	if abs(linear_velocity.x) < MIN_HORIZONTAL_SPEED:
		linear_velocity.x += randi_range(-30, 30)
	# 检测是否碰撞到砖块，调用其 hit 方法
	if body.is_in_group("bricks") and body.has_method("hit"):
		body.hit()
