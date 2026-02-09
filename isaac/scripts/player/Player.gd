extends CharacterBody2D

## 玩家脚本
## 处理玩家移动和射击功能

@export var move_speed: float = 200.0
@export var shoot_cooldown: float = 0.4  # 射击冷却时间（秒）

@onready var projectile_scene = preload("res://scenes/projectiles/Projectile.tscn")

var shoot_timer: float = 0.0
var can_shoot: bool = true

func _ready():
	# 初始化
	pass

func _physics_process(delta):
	# 处理移动
	handle_movement()
	
	# 更新射击冷却时间
	if shoot_timer > 0:
		shoot_timer -= delta
		can_shoot = false
	else:
		can_shoot = true
	
	# 处理射击输入
	handle_shooting()
	
	# 应用移动
	move_and_slide()

func handle_movement():
	# 获取输入方向
	var input_dir = Vector2.ZERO
	
	if Input.is_action_pressed("move_up"):
		input_dir.y -= 1
	if Input.is_action_pressed("move_down"):
		input_dir.y += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	
	# 标准化方向向量
	if input_dir.length() > 0:
		input_dir = input_dir.normalized()
	
	# 设置速度
	velocity = input_dir * move_speed

func handle_shooting():
	# 检查是否可以射击
	if not can_shoot:
		return
	
	# 检查鼠标左键输入
	if Input.is_action_just_pressed("shoot"):
		shoot()

func shoot():
	# 计算射击方向（从玩家位置指向鼠标位置）
	var mouse_pos = get_global_mouse_position()
	var shoot_direction = (mouse_pos - global_position).normalized()
	
	# 如果方向向量无效（鼠标和玩家位置相同），使用默认方向
	if shoot_direction.length() < 0.1:
		shoot_direction = Vector2.RIGHT
	
	# 创建子弹实例
	var projectile = projectile_scene.instantiate()
	
	# 设置子弹位置和方向
	projectile.global_position = global_position
	projectile.direction = shoot_direction
	
	# 将子弹添加到场景树
	get_tree().current_scene.add_child(projectile)
	
	# 重置冷却时间
	shoot_timer = shoot_cooldown
	can_shoot = false

