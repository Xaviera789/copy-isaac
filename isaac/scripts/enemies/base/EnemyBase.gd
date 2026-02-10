extends Damageable

## 敌人基类
## 所有敌人都应该继承此类
## 提供基础的敌人行为和AI功能

## 敌人移动速度（像素/秒）
@export var move_speed: float = 100.0

## 初始生命值（默认1点）
@export var initial_hp: int = 1

## 房间边界限制（暂时硬编码，后续接入房间系统）
@export var room_bounds: Rect2 = Rect2(0, 0, 800, 600)

## AI状态
enum AIState {
	IDLE,      # 待机
	CHASE,     # 追击
	ATTACK,    # 攻击
	RETREAT    # 撤退
}

var current_state: AIState = AIState.IDLE
var target: Node2D = null  # 目标（通常是玩家）

func _ready():
	# 先设置最大生命值
	max_hp = initial_hp
	# 调用父类的 _ready（会设置hp = max_hp）
	super._ready()
	# 打印生命值信息
	print("敌人生命值初始化: ", hp, " / ", max_hp)
	
	# 自动查找玩家作为目标
	_find_player_target()

func _physics_process(delta: float) -> void:
	# 更新AI行为
	_update_ai(delta)
	# 限制敌人在房间边界内
	_limit_to_room_bounds()

## 更新AI行为
func _update_ai(delta: float) -> void:
	match current_state:
		AIState.IDLE:
			_handle_idle(delta)
		AIState.CHASE:
			_handle_chase(delta)
		AIState.ATTACK:
			_handle_attack(delta)
		AIState.RETREAT:
			_handle_retreat(delta)

## 处理待机状态
func _handle_idle(delta: float) -> void:
	# 默认实现：停止移动
	velocity = Vector2.ZERO
	move_and_slide()

## 处理追击状态
func _handle_chase(delta: float) -> void:
	if not target:
		current_state = AIState.IDLE
		return
	
	# 计算朝向目标的方向
	var direction = (target.global_position - global_position).normalized()
	velocity = direction * move_speed
	move_and_slide()
	
	# 限制速度，防止移动到边界外
	_limit_velocity_to_bounds()

## 处理攻击状态
func _handle_attack(delta: float) -> void:
	# 子类可以重写此方法来实现攻击逻辑
	velocity = Vector2.ZERO
	move_and_slide()

## 处理撤退状态
func _handle_retreat(delta: float) -> void:
	if not target:
		current_state = AIState.IDLE
		return
	
	# 计算远离目标的方向
	var direction = (global_position - target.global_position).normalized()
	velocity = direction * move_speed
	move_and_slide()

## 设置目标
func set_target(new_target: Node2D) -> void:
	target = new_target
	if target:
		current_state = AIState.CHASE
	else:
		current_state = AIState.IDLE

## 查找玩家目标
## 通过场景树查找Player节点
func _find_player_target() -> void:
	# 方案1：通过分组查找（如果Player在"player"分组中）
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		set_target(players[0] as Node2D)
		print("敌人找到玩家目标（通过分组）")
		return
	
	# 方案2：通过场景树递归查找Player节点（通过脚本路径判断）
	var current_scene = get_tree().current_scene
	if current_scene:
		var found_player = _find_player_recursive(current_scene)
		if found_player:
			print("敌人找到玩家目标（通过递归查找）")
			return
	
	# 如果都没找到，打印警告
	print("警告：敌人未找到玩家目标")

## 递归查找玩家节点
## 返回找到的Player节点，如果没找到返回null
func _find_player_recursive(node: Node) -> Node2D:
	# 检查当前节点是否是Player（通过脚本路径判断）
	if node.get_script():
		var script_path = node.get_script().resource_path
		if script_path and script_path.ends_with("Player.gd"):
			set_target(node as Node2D)
			return node as Node2D
	
	# 递归查找子节点
	for child in node.get_children():
		var found = _find_player_recursive(child)
		if found:
			return found
	
	return null

## 获取敌人的半尺寸
func _get_half_size() -> Vector2:
	var collision_shape = $CollisionShape2D
	if collision_shape and collision_shape.shape:
		var shape = collision_shape.shape as RectangleShape2D
		if shape:
			return shape.size / 2.0
	return Vector2(8, 8)  # 默认值（16x16的一半）

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

## 限制敌人在房间边界内
func _limit_to_room_bounds() -> void:
	var half_size = _get_half_size()
	
	# 计算边界（考虑碰撞体大小）
	# 添加0.5像素的内缩，确保敌人完全在房间内，避免浮点误差
	var margin = 0.5
	var min_pos = room_bounds.position + half_size + Vector2(margin, margin)
	var max_pos = room_bounds.position + room_bounds.size - half_size - Vector2(margin, margin)
	
	# 直接限制位置
	global_position.x = clamp(global_position.x, min_pos.x, max_pos.x)
	global_position.y = clamp(global_position.y, min_pos.y, max_pos.y)

## 重写死亡方法
func die() -> void:
	super.die()  # 调用父类的 die 方法
	# 敌人死亡时的额外处理
	queue_free()  # 从场景树中移除
