extends CharacterBody2D

## 玩家脚本
## 处理玩家移动、边界限制和射击功能

## 玩家移动速度（像素/秒）
@export var move_speed: float = 200.0

## 射击冷却时间（秒）
@export var shoot_cooldown: float = 0.4

## 房间边界限制（暂时硬编码，后续接入房间系统）
@export var room_bounds: Rect2 = Rect2(0, 0, 800, 600)

@onready var projectile_scene = preload("res://scenes/projectiles/Projectile.tscn")

var shoot_timer: float = 0.0
var can_shoot: bool = true

func _ready():
	# 初始化
	pass

func _physics_process(delta: float) -> void:
	# 更新射击冷却时间
	if shoot_timer > 0:
		shoot_timer -= delta
		can_shoot = false
	else:
		can_shoot = true
	
	# 获取输入方向
	var input_direction = _get_input_direction()
	
	# 计算移动速度
	velocity = input_direction * move_speed
	
	# 在移动前检查边界，限制速度
	_limit_velocity_to_bounds()
	
	# 应用移动
	move_and_slide()
	
	# 移动后再次限制位置（防止浮点误差或碰撞导致的位置偏移）
	_limit_to_room_bounds()
	
	# 处理射击输入
	handle_shooting()

## 获取8方向输入
func _get_input_direction() -> Vector2:
	var direction = Vector2.ZERO
	
	# 水平输入
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	
	# 垂直输入
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1
	
	# 标准化方向向量（确保对角线移动速度一致）
	return direction.normalized()

## 获取玩家的半尺寸
func _get_half_size() -> Vector2:
	var collision_shape = $CollisionShape2D
	if collision_shape and collision_shape.shape:
		var shape = collision_shape.shape as RectangleShape2D
		return shape.size / 2.0
	return Vector2(8, 8)  # 默认值

## 限制速度，防止移动到边界外
func _limit_velocity_to_bounds() -> void:
	var half_size = _get_half_size()
	var next_pos = global_position + velocity * get_physics_process_delta_time()
	
	# 计算边界
	var min_pos = room_bounds.position + half_size
	var max_pos = room_bounds.position + room_bounds.size - half_size
	
	# 如果下一帧会超出边界，限制速度
	if next_pos.x < min_pos.x:
		velocity.x = max(0, velocity.x)
	elif next_pos.x > max_pos.x:
		velocity.x = min(0, velocity.x)
	
	if next_pos.y < min_pos.y:
		velocity.y = max(0, velocity.y)
	elif next_pos.y > max_pos.y:
		velocity.y = min(0, velocity.y)

## 限制玩家在房间边界内
func _limit_to_room_bounds() -> void:
	var half_size = _get_half_size()
	
	# 计算边界（考虑碰撞体大小）
	# room_bounds: Rect2(position, size)
	# position是左上角，size是宽高
	# 所以右边界是 position.x + size.x，下边界是 position.y + size.y
	# 为了确保玩家完全在房间内，玩家中心需要满足：
	# - 最小位置：position + half_size（玩家左/上边缘在房间左/上边界）
	# - 最大位置：position + size - half_size（玩家右/下边缘在房间右/下边界）
	# 添加0.5像素的内缩，确保玩家完全在房间内，避免浮点误差
	var margin = 0.5
	var min_pos = room_bounds.position + half_size + Vector2(margin, margin)
	var max_pos = room_bounds.position + room_bounds.size - half_size - Vector2(margin, margin)
	
	# 直接限制位置
	global_position.x = clamp(global_position.x, min_pos.x, max_pos.x)
	global_position.y = clamp(global_position.y, min_pos.y, max_pos.y)

## 处理射击输入
## 响应鼠标左键射击输入，检查冷却时间后调用射击方法
func handle_shooting():
	# 检查是否可以射击（冷却时间是否结束）
	if not can_shoot:
		return
	
	# 响应鼠标左键射击输入（通过"shoot"输入动作）
	if Input.is_action_just_pressed("shoot"):
		shoot()

## 射击方法
## 根据鼠标位置相对于角色的方位计算射击方向，并生成子弹实例
func shoot():
	# 获取鼠标的全局位置
	var mouse_pos = get_global_mouse_position()
	
	# 根据鼠标位置相对于角色的方位计算射击方向
	# 方向 = (鼠标位置 - 玩家位置) 的标准化向量
	var shoot_direction = (mouse_pos - global_position).normalized()
	
	# 如果方向向量无效（鼠标和玩家位置相同或距离太近），使用默认方向
	if shoot_direction.length() < 0.1:
		shoot_direction = Vector2.RIGHT
	
	# 生成子弹实例
	var projectile = projectile_scene.instantiate()
	
	# 设置子弹位置（从玩家位置开始）
	projectile.global_position = global_position
	
	# 设置子弹的射击方向
	projectile.direction = shoot_direction
	
	# 将子弹添加到场景树（安全地添加到当前场景）
	var current_scene = get_tree().current_scene
	if current_scene:
		current_scene.add_child(projectile)
	else:
		# 如果当前场景不存在，添加到场景树根节点
		get_tree().root.add_child(projectile)
	
	# 重置冷却时间，防止无限射击
	shoot_timer = shoot_cooldown
	can_shoot = false
