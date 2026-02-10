extends Damageable

## 玩家脚本
## 处理玩家移动、边界限制和射击功能

## 玩家移动速度（像素/秒）
@export var move_speed: float = 200.0

## 射击冷却时间（秒）
@export var shoot_cooldown: float = 0.4

## 房间边界限制（暂时硬编码，后续接入房间系统）
@export var room_bounds: Rect2 = Rect2(0, 0, 800, 600)

## 初始生命值（3颗心）
@export var initial_hp: int = 3

## 闪烁效果相关
@onready var color_rect: ColorRect = $ColorRect
var flash_timer: float = 0.0
var is_flashing: bool = false

@onready var projectile_scene = preload("res://scenes/projectiles/Projectile.tscn")

var shoot_timer: float = 0.0
var can_shoot: bool = true

## 玩家死亡信号
signal player_died
## 玩家受伤信号
signal player_took_damage(new_hp: int)

func _ready():
	# 先设置最大生命值（3颗心）
	max_hp = initial_hp
	# 调用父类的 _ready（会设置hp = max_hp）
	super._ready()
	# 打印生命值信息
	print("玩家生命值初始化: ", hp, " / ", max_hp)

func _process(delta: float) -> void:
	# 先调用父类的 _process，更新无敌帧计时器等通用逻辑
	super._process(delta)
	# 处理闪烁效果
	_update_flash_effect(delta)

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

## 重写take_damage方法，添加视觉反馈和生命值显示
func take_damage(amount: int) -> void:
	# 调用父类方法处理伤害
	super.take_damage(amount)
	
	# 打印生命值信息
	print("玩家受到伤害: ", amount, "，当前生命值: ", hp, " / ", max_hp)
	
	# 发射受伤信号
	player_took_damage.emit(hp)
	
	# 触发闪烁效果
	_start_flash_effect()

## 重写die方法，实现死亡逻辑
func die() -> void:
	print("玩家死亡！")
	
	# 发射死亡信号
	player_died.emit()
	
	# 实现死亡逻辑：重新加载当前场景（游戏重启）
	# 注意：这里使用get_tree().reload_current_scene()来重启游戏
	# 如果后续有更复杂的游戏状态管理，可以改为切换到游戏结束场景
	get_tree().reload_current_scene()

## 开始闪烁效果
func _start_flash_effect() -> void:
	if not is_flashing:
		is_flashing = true
		flash_timer = invincibility_duration  # 闪烁持续时间与无敌帧相同

## 更新闪烁效果
func _update_flash_effect(delta: float) -> void:
	if not color_rect:
		return
	
	if is_flashing and flash_timer > 0:
		flash_timer -= delta
		
		# 计算闪烁状态（在无敌帧期间持续闪烁）
		# 使用sin函数创建平滑的闪烁效果
		var flash_alpha = sin(flash_timer * 30.0) * 0.5 + 0.5  # 0-1之间
		
		# 在无敌状态下，让玩家半透明闪烁
		if is_invincible:
			color_rect.modulate = Color(1, 1, 1, flash_alpha)
		else:
			color_rect.modulate = Color(1, 1, 1, 1)
		
		# 闪烁时间结束
		if flash_timer <= 0:
			is_flashing = false
			color_rect.modulate = Color(1, 1, 1, 1)  # 恢复正常颜色
	else:
		# 确保不在闪烁时恢复正常颜色
		if not is_invincible:
			color_rect.modulate = Color(1, 1, 1, 1)
