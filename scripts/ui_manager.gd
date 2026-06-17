extends CanvasLayer
## UIManager — UI 更新管理
## 监听 GameManager 信号，实时更新分数、生命值显示和游戏结束面板

@onready var score_label: Label = $ScoreLabel
@onready var lives_label: Label = $LivesLabel
@onready var game_over_panel: Control = $GameOverPanel
@onready var result_label: Label = $GameOverPanel/ResultLabel
@onready var restart_button: Button = $GameOverPanel/RestartButton


func _ready() -> void:
	# 连接 GameManager 信号
	if not GameManager.score_updated.is_connected(_on_score_updated):
		GameManager.score_updated.connect(_on_score_updated)
	if not GameManager.lives_updated.is_connected(_on_lives_updated):
		GameManager.lives_updated.connect(_on_lives_updated)
	if not GameManager.game_over.is_connected(_on_game_over):
		GameManager.game_over.connect(_on_game_over)
	if not GameManager.game_won.is_connected(_on_game_won):
		GameManager.game_won.connect(_on_game_won)

	# 连接重新开始按钮
	restart_button.pressed.connect(_on_restart_button_pressed)

	# 初始化 UI 显示
	_update_score_display(GameManager.score)
	_update_lives_display(GameManager.lives)
	# 初始隐藏游戏结束面板
	game_over_panel.visible = false


## 分数更新回调
func _on_score_updated(score: int) -> void:
	_update_score_display(score)


## 生命值更新回调
func _on_lives_updated(lives: int) -> void:
	_update_lives_display(lives)


## 游戏结束回调
func _on_game_over() -> void:
	result_label.text = "游戏结束"
	game_over_panel.visible = true


## 游戏胜利回调
func _on_game_won() -> void:
	result_label.text = "恭喜通关！"
	game_over_panel.visible = true


## 重新开始按钮回调
func _on_restart_button_pressed() -> void:
	GameManager.reset_game()
	game_over_panel.visible = false
	_update_score_display(GameManager.score)
	_update_lives_display(GameManager.lives)
	# 重新加载主场景
	get_tree().reload_current_scene()


## 更新分数显示
func _update_score_display(score: int) -> void:
	score_label.text = "分数: %d" % score


## 更新生命值显示
func _update_lives_display(lives: int) -> void:
	lives_label.text = "生命: %d" % lives
