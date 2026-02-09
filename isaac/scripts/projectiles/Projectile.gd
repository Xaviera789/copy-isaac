extends Area2D

## 子弹脚本
## 处理子弹的移动、碰撞和销毁逻辑

@export var speed: float = 300.0  # 子弹速度
@export var direction: Vector2 = Vector2.RIGHT  # 射击方向
@export var lifetime: float = 5.0  # 最大存活时间（秒）

var velocity: Vector2 = Vector2.ZERO

func _ready():
	# 设置碰撞检测
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	
	# 设置生命周期
	if lifetime > 0:
		var timer = get_tree().create_timer(lifetime)
		timer.timeout.connect(queue_free)
	
	# 初始化速度
	velocity = direction.normalized() * speed

func _physics_process(delta: float) -> void:
	# 移动子弹
	global_position += velocity * delta
	
	# 检查是否超出屏幕（简单边界检查）
	var viewport = get_viewport()
	if viewport:
		var viewport_rect = viewport.get_visible_rect()
		# 如果超出屏幕一定距离，销毁子弹
		var margin = 100
		if global_position.x < viewport_rect.position.x - margin or \
		   global_position.x > viewport_rect.position.x + viewport_rect.size.x + margin or \
		   global_position.y < viewport_rect.position.y - margin or \
		   global_position.y > viewport_rect.position.y + viewport_rect.size.y + margin:
			queue_free()

func _on_body_entered(body: Node2D) -> void:
	# 当子弹碰撞到物体时销毁
	# 注意：这里可以根据需要添加伤害逻辑
	# 子弹只应该与敌人碰撞（通过collision_mask设置）
	if body.has_method("take_damage"):
		body.take_damage(1)  # 假设有伤害方法
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	# 当子弹碰撞到区域时销毁
	# 可以用于碰撞墙壁等
	queue_free()

