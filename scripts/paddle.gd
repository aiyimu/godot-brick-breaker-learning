extends CharacterBody2D
## Paddle — 玩家挡板
## 处理键盘输入、水平移动、冲刺加速和屏幕边界限制

# 信号：体力变化时发出，供 UI 更新
signal stamina_changed(stamina: float, max_stamina: float)

const SPEED: float = 400.0             # 普通移动速度（像素/秒）
const SPRINT_MULTIPLIER: float = 2.0   # 冲刺速度倍率
const MAX_STAMINA: float = 100.0       # 最大体力值
const STAMINA_DRAIN: float = 40.0      # 体力消耗速度（每秒）
const STAMINA_REGEN: float = 25.0      # 体力恢复速度（每秒）
const PADDLE_WIDTH: float = 128.0      # 挡板宽度
const SCREEN_WIDTH: float = 800.0      # 屏幕宽度
const FIXED_Y: float = 550.0           # 固定Y坐标（屏幕底部附近）

var stamina: float = MAX_STAMINA       # 当前体力值


func _ready() -> void:
	# 固定挡板Y坐标
	position.y = FIXED_Y


func _process(delta: float) -> void:
	# 体力恢复：不按冲刺键时缓慢恢复
	if not Input.is_action_pressed("sprint") and stamina < MAX_STAMINA:
		stamina = min(stamina + STAMINA_REGEN * delta, MAX_STAMINA)
		stamina_changed.emit(stamina, MAX_STAMINA)


func _physics_process(delta: float) -> void:
	# 获取左右输入
	var direction: float = Input.get_axis("move_left", "move_right")

	# 冲刺逻辑：按下 Shift 且有体力时加速
	var is_sprinting: bool = Input.is_action_pressed("sprint") and stamina > 0.0 and direction != 0.0
	var current_speed: float = SPEED * SPRINT_MULTIPLIER if is_sprinting else SPEED

	if is_sprinting:
		# 消耗体力
		stamina = max(stamina - STAMINA_DRAIN * delta, 0.0)
		stamina_changed.emit(stamina, MAX_STAMINA)

	# 计算水平移动
	velocity.x = direction * current_speed
	velocity.y = 0.0  # 挡板不上下移动

	# 移动并检测碰撞
	move_and_slide()

	# 限制挡板不超出左右边界
	position.x = clamp(position.x, PADDLE_WIDTH / 2.0, SCREEN_WIDTH - PADDLE_WIDTH / 2.0)
	# 锁定Y坐标
	position.y = FIXED_Y
