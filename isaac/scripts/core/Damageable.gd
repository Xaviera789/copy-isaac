extends CharacterBody2D
class_name Damageable

## 可伤害对象基类
## 提供生命值、无敌帧和伤害处理功能
## Player 和 Enemy 可以继承或组合使用此类

## 当前生命值
@export var hp: int = 100

## 最大生命值
@export var max_hp: int = 100

## 无敌帧持续时间（秒）
@export var invincibility_duration: float = 0.5

## 是否处于无敌状态
var is_invincible: bool = false

## 无敌帧计时器
var invincibility_timer: float = 0.0

func _ready():
	# 初始化生命值
	hp = max_hp

func _process(delta: float) -> void:
	# 更新无敌帧计时器
	if invincibility_timer > 0:
		invincibility_timer -= delta
		if invincibility_timer <= 0:
			is_invincible = false

## 受到伤害
## amount: 伤害值
func take_damage(amount: int) -> void:
	# 如果处于无敌状态，忽略伤害
	if is_invincible:
		return
	
	# 扣除生命值
	hp -= amount
	
	# 确保生命值不为负数
	hp = max(0, hp)
	
	# 触发无敌帧
	_start_invincibility()
	
	# 如果生命值归零，触发死亡
	if hp <= 0:
		die()

## 开始无敌帧
func _start_invincibility() -> void:
	is_invincible = true
	invincibility_timer = invincibility_duration

## 死亡处理
## 子类可以重写此方法来实现自定义死亡逻辑
func die() -> void:
	# 默认实现：打印日志
	print(name, " 已死亡")
	# 子类应该重写此方法
