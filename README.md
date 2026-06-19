# Godot 极简打砖块 (Brick Breaker)

基于 Godot 4.6 引擎开发的 2D 打砖块游戏，一个专注于学习 2D 物理系统、碰撞检测、信号机制与 UI 交互的练习项目。

---

## 目录

- [功能特性](#功能特性)
- [项目结构](#项目结构)
- [快速开始](#快速开始)
- [游戏操作](#游戏操作)
- [场景说明](#场景说明)
- [脚本说明](#脚本说明)
- [碰撞层配置](#碰撞层配置)
- [信号系统](#信号系统)
- [输入映射](#输入映射)
- [难度系统](#难度系统)
- [技能卡系统](#技能卡系统)
- [设计规范](#设计规范)
- [开发日志](#开发日志)

---

## 功能特性

### 核心玩法
- 玩家控制挡板反弹小球，击碎屏幕上方所有砖块即可通关
- 砖块根据生命值显示不同颜色纹理（绿→黄→橙→红）
- 小球启用连续碰撞检测（CCD），防止高速穿透
- 内置防死循环逻辑，避免小球水平直线运动

### 音效系统
- 8 个音效池（SFX Pool）支持同时播放多个音效
- 独立的 BGM 播放器，支持场景切换
- 游戏内音效：砖块碰撞、砖块击碎、挡板反弹、墙壁反弹、小球丢失、游戏结束、胜利
- 背景音乐：主菜单 BGM、游戏内 BGM
- 音量可通过设置面板实时调整

### 纹理贴图
- 所有游戏实体使用渐变纹理（非纯色矩形）
- 挡板：蓝色渐变 128×16
- 小球：白色径向渐变球体 16×16
- 砖块：绿/黄/橙/红渐变 64×24（根据血量自动切换）

### 冲刺/体力系统
- 按住 `Shift` 键挡板移动速度翻倍（800 px/s）
- 体力条上限 100，冲刺消耗 40/秒，自然恢复 25/秒
- 体力不足时（<20）进度条变红提示
- 实时显示体力条 UI

### 主菜单与设置
- 启动即进入主菜单，可选择难度后开始游戏
- 难度选择：简单（2×4=8 砖块）、普通（3×5=15 砖块）、困难（4×6=24 砖块）
- 设置面板：BGM 音量、SFX 音量、初始生命值（1-10）
- 所有设置自动持久化到 `user://settings.cfg`

### 游戏内交互
- 游戏内左上角「返回主菜单」按钮，随时返回
- 按 `Esc` 键也可返回主菜单
- 游戏结束/胜利面板包含「重新开始」和「返回菜单」两个按钮

---

## 项目结构

```
godot-brick-breaker-learning/
├── assets/                     # 资源文件
│   ├── sounds/                 # 音效资源
│   │   ├── bgm/                # 背景音乐
│   │   │   ├── gameplay_bgm.mp3
│   │   │   └── menu_bgm.mp3
│   │   └── sfx/                # 音效文件
│   │       ├── brick_hit.ogg
│   │       ├── brick_destroy.ogg
│   │       ├── ball_hit_paddle.ogg
│   │       ├── ball_hit_wall.ogg
│   │       ├── ball_lost.ogg
│   │       ├── game_over.wav
│   │       └── game_win.mp3
│   └── sprites/                # 纹理资源
│       ├── paddle.png          # 挡板纹理（128×16）
│       ├── ball.png            # 小球纹理（16×16）
│       ├── brick_green.png     # 1 血砖块（绿色）
│       ├── brick_yellow.png    # 2 血砖块（黄色）
│       ├── brick_orange.png    # 3 血砖块（橙色）
│       └── brick_red.png       # 4+ 血砖块（红色）
├── scenes/                     # 场景文件
│   ├── main.tscn               # 游戏主场景
│   ├── menu.tscn               # 主菜单场景
│   ├── paddle.tscn             # 玩家挡板
│   ├── ball.tscn               # 小球
│   └── brick.tscn              # 砖块
├── scripts/                    # GDScript 脚本
│   ├── game_manager.gd         # 全局状态管理（autoload）
│   ├── sound_manager.gd        # 音效管理（autoload）
│   ├── settings_manager.gd     # 配置存储（autoload）
│   ├── main.gd                 # 主场景逻辑
│   ├── menu_manager.gd         # 主菜单逻辑
│   ├── paddle.gd               # 挡板控制
│   ├── ball.gd                 # 小球物理
│   ├── brick.gd                # 砖块逻辑
│   └── ui_manager.gd           # UI 更新管理
├── project.godot               # 项目配置文件
└── README.md                   # 本文件
```

---

## 快速开始

### 环境要求
- **Godot 4.6**（[下载地址](https://godotengine.org/download/)）
- Windows / macOS / Linux

### 运行步骤
1. 使用 Godot 4.6 打开项目根目录
2. 点击「运行项目」按钮（F5）或运行当前场景（F6）
3. 游戏将从主菜单启动

### 项目设置
| 设置项 | 值 |
|--------|-----|
| 窗口分辨率 | 800×600（可在设置面板调整） |
| 2D 重力 | (0, 0) |
| 连续碰撞检测 (CCD) | 开启 |
| 自动重载脚本 | 开启 |

---

## 游戏操作

| 按键 | 功能 |
|------|------|
| `←` / `A` | 挡板向左移动 |
| `→` / `D` | 挡板向右移动 |
| `Space` | 发射小球 |
| `Shift`（按住） | 挡板冲刺加速（消耗体力） |
| `Esc` | 返回主菜单 |

---

## 场景说明

### main.tscn — 游戏主场景

```
Main (Node2D)
├── Background (ColorRect)          # 背景层
├── GameArea (Node2D)               # 游戏区域容器
│   ├── Walls (StaticBody2D)        # 屏幕边界碰撞墙
│   ├── Paddle (CharacterBody2D)    # 玩家挡板（实例化 paddle.tscn）
│   ├── Ball (RigidBody2D)          # 小球（实例化 ball.tscn）
│   └── BricksContainer (Node2D)    # 砖块容器（动态生成）
└── UILayer (CanvasLayer)           # UI 层（独立渲染）
    ├── ScoreLabel (Label)          # 分数显示
    ├── LivesLabel (Label)          # 生命值显示
    ├── StaminaLabel (Label)        # 体力标签
    ├── StaminaBar (ProgressBar)    # 体力条
    ├── BackButton (Button)         # 返回主菜单
    └── GameOverPanel (Control)     # 游戏结束面板
        ├── DimBackground (ColorRect)
        ├── ResultLabel (Label)
        ├── RestartButton (Button)  # 重新开始
        └── MenuButton (Button)     # 返回菜单
```

### menu.tscn — 主菜单场景

```
Menu (Control)
├── TitleLabel (Label)              # "极简打砖块"
├── StartButton (Button)            # 开始游戏
├── DifficultyLabel (Label)         # "难度选择:"
├── DifficultyOptionButton          # 简单/普通/困难
├── SettingsButton (Button)         # 打开设置
├── QuitButton (Button)             # 退出游戏
└── SettingsPanel (Panel)           # 设置面板
    ├── SettingsTitle (Label)
    ├── BgmVolumeLabel + BgmVolumeSlider
    ├── SfxVolumeLabel + SfxVolumeSlider
    ├── LivesLabel + LivesSlider + LivesValueLabel
    └── CloseSettingsButton
```

---

## 脚本说明

### Autoload 单例

| 脚本 | 职责 |
|------|------|
| `game_manager.gd` | 全局状态管理：分数、生命值、游戏状态、砖块生成、胜利判定 |
| `sound_manager.gd` | 音效/背景音乐管理：8 个 SFX 池 + 1 个 BGM 播放器，音量控制 |
| `settings_manager.gd` | 配置持久化：难度预设、窗口分辨率、音量、生命值，ConfigFile 存储 |

### 场景脚本

| 脚本 | 挂载节点 | 职责 |
|------|---------|------|
| `main.gd` | Main (Node2D) | 主场景初始化、窗口设置应用、暂停/返回菜单逻辑 |
| `menu_manager.gd` | Menu (Control) | 主菜单交互：难度选择、开始游戏、设置面板、退出 |
| `paddle.gd` | Paddle (CharacterBody2D) | 玩家输入、挡板移动、边界限制、冲刺/体力系统 |
| `ball.gd` | Ball (RigidBody2D) | 小球物理运动、碰撞反弹、出界检测、发射逻辑 |
| `brick.gd` | Brick (StaticBody2D) | 砖块生命值、被击中处理、纹理切换、自我销毁 |
| `ui_manager.gd` | UILayer (CanvasLayer) | UI 更新：分数/生命值/体力条/游戏结束面板 |

---

## 碰撞层配置

| 节点 | Layer（位值） | Mask（位值） | 说明 |
|------|:---:|:---:|------|
| Ball (RigidBody2D) | 1 | 2+4+8=14 | 碰撞挡板、砖块、墙壁 |
| Paddle (CharacterBody2D) | 2 | 1 | 只碰撞小球 |
| Brick (StaticBody2D) | 4 | 1 | 只碰撞小球 |
| Wall (StaticBody2D) | 8 | 1 | 只碰撞小球 |

> 层编号与位值对应：第 1 层=1、第 2 层=2、第 3 层=4、第 4 层=8

---

## 信号系统

| 信号 | 发出者 | 参数 | 说明 |
|------|--------|------|------|
| `brick_destroyed` | brick.gd | `score_value: int` | 砖块被击碎时发出 |
| `ball_lost` | ball.gd | 无 | 小球出界（y > 600）时发出 |
| `game_over` | game_manager.gd | 无 | 生命值归零时发出 |
| `game_won` | game_manager.gd | 无 | 所有砖块消除时发出 |
| `score_updated` | game_manager.gd | `score: int` | 分数变化时发出 |
| `lives_updated` | game_manager.gd | `lives: int` | 生命值变化时发出 |
| `stamina_changed` | paddle.gd | `stamina: float, max: float` | 体力值变化时发出 |
| `setting_changed` | settings_manager.gd | `key: String, value: Variant` | 设置变更时发出 |

### 数据更新流程

**分数更新**：
```
砖块碰撞 → brick.gd 发出 brick_destroyed(score) 
→ game_manager.gd 接收 → score += score_value 
→ 发出 score_updated(score) → ui_manager.gd 更新 UI
```

**生命值更新**：
```
小球出界 → ball.gd 发出 ball_lost() 
→ game_manager.gd 接收 → lives -= 1 
→ 若 lives <= 0 → 发出 game_over()
→ 否则 → 重置小球位置，发出 lives_updated(lives)
```

**胜利判定**：
```
每帧检测 get_tree().get_nodes_in_group("bricks").size()
→ 数量为 0 → 发出 game_won()
```

---

## 输入映射

| 动作名 | 按键 | 用途 |
|--------|------|------|
| `move_left` | 左方向键 + A 键 | 挡板左移 |
| `move_right` | 右方向键 + D 键 | 挡板右移 |
| `launch` | 空格键 | 发射小球 |
| `sprint` | Shift 键 | 挡板冲刺加速 |
| `ui_cancel` | Esc 键 | 返回主菜单 |

---

## 难度系统

| 难度 | 砖块行 | 砖块列 | 总砖块数 | 砖块血量范围 |
|------|:---:|:---:|:---:|:---:|
| 简单 | 2 | 4 | 8 | 1-2 |
| 普通 | 3 | 5 | 15 | 1-3 |
| 困难 | 4 | 6 | 24 | 1-4 |

砖块在屏幕上水平居中排列，总宽度实时计算适配不同列数。

---

## 技能卡系统（计划中）

| 技能卡 | 掉落概率 | 效果 |
|--------|:---:|------|
| 小球分身 | 30% | 当前小球分裂为 3 个，方向向上，左右随机偏移 |
| 生命+1 | 30% | 玩家生命值 +1（上限 5） |
| 加速挡板 | 25% | 挡板移动速度翻倍，持续 5 秒 |
| 减速小球 | 15% | 小球速度降低 30%，持续 5 秒 |

> 详细设计见 `.tasks/文档5-新增功能.md`

---

## 设计规范

### 命名规范
- 变量/函数/信号：`snake_case`
- 常量：`UPPER_SNAKE_CASE`
- 类名/节点名：`PascalCase`
- 私有成员：前缀 `_`
- 注释语言：中文
- 代码语言：英文命名 + 中文注释

### 架构原则
- 一个脚本只负责一个节点的逻辑
- 脚本通过信号通信，避免直接引用兄弟节点
- 信号连接在 `_ready()` 中完成，使用 `is_connected` 防止重复
- 全局状态修改必须通过 `GameManager` 进行
- 状态变更后必须发出对应信号通知 UI

### 组（Groups）
| 组名 | 成员 | 用途 |
|------|------|------|
| `bricks` | 所有砖块节点 | 批量检测剩余砖块数量、胜利判定 |
| `paddle` | 挡板节点 | UI 查找挡板、连接体力信号 |

### 物理防穿透
- 小球节点启用 CCD：`Continuous CD = On`
- 小球最大速度限制：`linear_velocity.limit_length(MAX_SPEED)`
- `MAX_SPEED` = 800 px/s
- 防死循环：水平速度低于 50 时随机修正

---

## 开发日志

### 阶段一：音效 + 背景音乐
- 创建音效目录结构和占位资源（8 个 SFX + 2 个 BGM）
- 实现 `SoundManager` 单例（SFX 池 + BGM 播放器）
- 在现有脚本中接入音效触发点
- 在游戏流程中接入背景音乐

### 阶段二：2D 纹理贴图
- 生成 6 个 PNG 纹理（挡板、小球、4 色砖块）使用 SVG 渲染
- 砖块从 ColorRect 切换到 Sprite2D（血量对应纹理）
- 挡板、小球从 ColorRect 切换到 Sprite2D

### 阶段三：冲刺加速 + 体力条
- 挡板冲刺逻辑：Shift 加速 2x，消耗体力
- 体力系统：上限 100，消耗 40/s，恢复 25/s
- 体力条 UI：ProgressBar 实时显示，低体力变红

### 阶段四：主菜单 + 设置系统
- 创建 `SettingsManager` 单例（ConfigFile 持久化）
- 创建主菜单场景（标题、难度选择、开始/设置/退出按钮）
- 难度预设：简单/普通/困难（自动同步砖块行列数）
- 游戏内返回主菜单按钮 + Esc 快捷键
- 设置面板：BGM 音量、SFX 音量、初始生命值
- 项目入口改为 `menu.tscn`

---

## 许可证

MIT License