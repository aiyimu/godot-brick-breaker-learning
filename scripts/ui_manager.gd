extends CanvasLayer
## UIManager — UI 更新管理
## 监听 GameManager 信号，实时更新分数、生命值显示和游戏结束面板

@onready var score_label: Label = $ScoreLabel
@onready var lives_label: Label = $LivesLabel
@onready var stamina_bar: ProgressBar = $StaminaBar
@onready var game_over_panel: Control = $GameOverPanel
@onready var result_label: Label = $GameOverPanel/ResultLabel
@onready var restart_button: Button = $GameOverPanel/RestartButton
@onready var menu_button: Button = $GameOverPanel/MenuButton


func _ready() -> void:
	# 确保 UI 层在场景暂停时仍能处理输入（按钮点击等）
	process_mode = Node.PROCESS_MODE_ALWAYS

	# 连接 GameManager 信号（使用 is_connected 防止重复连接）
	if not GameManager.score_updated.is_connected(_on_score_updated):
		GameManager.score_updated.connect(_on_score_updated)
	if not GameManager.lives_updated.is_connected(_on_lives_updated):
		GameManager.lives_updated.connect(_on_lives_updated)
	if not GameManager.game_over.is_connected(_on_game_over):
		GameManager.game_over.connect(_on_game_over)
	if not GameManager.game_won.is_connected(_on_game_won):
		GameManager.game_won.connect(_on_game_won)

	# 连接挡板体力变化信号
	var paddle: CharacterBody2D = get_tree().get_first_node_in_group("paddle")
	if paddle and not paddle.stamina_changed.is_connected(_on_stamina_changed):
		paddle.stamina_changed.connect(_on_stamina_changed)

	# 连接重新开始按钮
	restart_button.pressed.connect(_on_restart_button_pressed)
	# 连接返回菜单按钮
	menu_button.pressed.connect(_on_menu_button_pressed)

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
	SoundManager.stop_bgm()
	_show_game_over_panel("游戏结束")


## 游戏胜利回调
func _on_game_won() -> void:
	SoundManager.stop_bgm()
	_show_game_over_panel("恭喜通关！")


## 重新开始按钮回调
func _on_restart_button_pressed() -> void:
	# 恢复场景树运行（游戏结束/胜利时被暂停了）
	get_tree().paused = false
	# 重新加载主场景：会自动调用 _ready() 重新生成砖块、初始化 UI
	# GameManager 是 autoload，状态也会通过 _ready() 中 reset_game() 重置
	get_tree().reload_current_scene()


## 返回菜单按钮回调
func _on_menu_button_pressed() -> void:
	# 恢复场景树运行并切换到主菜单
	get_tree().paused = false
	SoundManager.stop_bgm()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


## 显示游戏结束/胜利面板
func _show_game_over_panel(text: String) -> void:
	result_label.text = text
	game_over_panel.visible = true
	# 暂停场景树，停止物理运算和 _process/_physics_process
	get_tree().paused = true


## 更新分数显示
func _update_score_display(score: int) -> void:
	if score_label:
		score_label.text = "分数: %d" % score


## 更新生命值显示
func _update_lives_display(lives: int) -> void:
	if lives_label:
		lives_label.text = "生命: %d" % lives


## 体力变化回调
func _on_stamina_changed(stamina: float, max_stamina: float) -> void:
	if stamina_bar:
		stamina_bar.value = stamina
		# 体力不足时进度条变红提示
		stamina_bar.modulate = Color.RED if stamina < 20.0 else Color.WHITE
