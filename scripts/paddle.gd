extends CharacterBody2D
## Paddle — 玩家挡板
## 处理键盘输入、水平移动和屏幕边界限制

const SPEED: float = 400.0             # 移动速度（像素/秒）
const PADDLE_WIDTH: float = 128.0      # 挡板宽度
const SCREEN_WIDTH: float = 800.0      # 屏幕宽度
const FIXED_Y: float = 550.0           # 固定Y坐标（屏幕底部附近）


func _ready() -> void:
	# 固定挡板Y坐标
	position.y = FIXED_Y


func _physics_process(delta: float) -> void:
	# 获取左右输入
	var direction: float = Input.get_axis("move_left", "move_right")

	# 计算水平移动
	velocity.x = direction * SPEED
	velocity.y = 0.0  # 挡板不上下移动

	# 移动并检测碰撞
	move_and_slide()

	# 限制挡板不超出左右边界
	position.x = clamp(position.x, PADDLE_WIDTH / 2.0, SCREEN_WIDTH - PADDLE_WIDTH / 2.0)
	# 锁定Y坐标
	position.y = FIXED_Y