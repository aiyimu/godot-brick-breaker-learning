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


func _ready() -> void:
	# 初始化游戏状态
	reset_game()


## 重置游戏状态到初始值
func reset_game() -> void:
	score = 0
	lives = 3
	is_game_over = false
	is_paused = false


## 增加分数
func add_score(amount: int) -> void:
	score += amount
	score_updated.emit(score)


## 扣除生命值
func lose_life() -> void:
	lives -= 1
	lives_updated.emit(lives)
	if lives <= 0:
		is_game_over = true
		game_over.emit()


## 检查是否所有砖块已消除
func check_win() -> void:
	var bricks = get_tree().get_nodes_in_group("bricks")
	if bricks.size() == 0:
		game_won.emit()