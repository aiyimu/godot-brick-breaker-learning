extends Node
## GameManager — 全局状态管理单例
## 负责分数、生命值、游戏状态的管理与信号转发

# 信号定义
signal score_updated(score: int)
signal lives_updated(lives: int)
signal game_over()
signal game_won()

# 全局状态变量
var score: int = 0          # 当前分数
var lives: int = 3          # 剩余生命
var is_game_over: bool = false
var is_paused: bool = false

# 砖块生成配置
const BRICK_SCENE: PackedScene = preload("res://scenes/brick.tscn")
const BRICK_COLS: int = 5          # 每行砖块数
const BRICK_ROWS: int = 3           # 砖块行数
const BRICK_WIDTH: float = 64.0     # 砖块宽度
const BRICK_HEIGHT: float = 24.0    # 砖块高度
const BRICK_GAP: float = 4.0        # 砖块间距
const BRICK_START_X: float = 92.0   # 起始X坐标
const BRICK_START_Y: float = 60.0   # 起始Y坐标


func _ready() -> void:
	# 初始化游戏状态
	reset_game()


## 重置游戏状态到初始值
func reset_game() -> void:
	score = 0
	lives = 3
	is_game_over = false
	is_paused = false
	# 状态变更后通知 UI 更新
	score_updated.emit(score)
	lives_updated.emit(lives)


## 生成砖块网格（由主场景调用）
func spawn_bricks(container: Node2D) -> void:
	var x_step: float = BRICK_WIDTH + BRICK_GAP
	var y_step: float = BRICK_HEIGHT + BRICK_GAP

	for row in range(BRICK_ROWS):
		for col in range(BRICK_COLS):
			var brick: StaticBody2D = BRICK_SCENE.instantiate()
			# 根据行号设置不同生命值（上方的砖块更耐打）
			brick.health = BRICK_ROWS - row
			brick.score_value = brick.health * 10
			brick.position = Vector2(
				BRICK_START_X + col * x_step,
				BRICK_START_Y + row * y_step
			)
			# 连接砖块的 brick_destroyed 信号（防止重复连接）
			if not brick.brick_destroyed.is_connected(_on_brick_destroyed):
				brick.brick_destroyed.connect(_on_brick_destroyed)
			container.add_child(brick)


## 砖块被击碎的回调
func _on_brick_destroyed(score_value: int) -> void:
	# 游戏已结束则忽略后续砖块击碎
	if is_game_over:
		return
	add_score(score_value)
	check_win()


## 增加分数
func add_score(amount: int) -> void:
	# 游戏已结束则忽略分数变化
	if is_game_over:
		return
	score += amount
	score_updated.emit(score)


## 扣除生命值
func lose_life() -> void:
	# 游戏已结束则忽略后续生命扣除
	if is_game_over:
		return
	lives -= 1
	lives_updated.emit(lives)
	if lives <= 0:
		is_game_over = true
		SoundManager.play_sfx("game_over")
		game_over.emit()


## 检查是否所有砖块已消除
func check_win() -> void:
	# 游戏已结束则不再判定胜利
	if is_game_over:
		return
	# 砖块在 hit() 中 emit 前已 remove_from_group("bricks")，
	# 故此时可立即读取到正确的砖块数量
	var bricks = get_tree().get_nodes_in_group("bricks")
	if bricks.size() == 0:
		is_game_over = true
		SoundManager.play_sfx("game_win")
		game_won.emit()
