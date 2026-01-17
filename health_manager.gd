extends Node

signal health_changed(current_value, max_value)
signal shield_changed(current_value, max_value)
signal damage_taken(amount)
signal shield_damaged(amount)
signal died
signal health_replenished

@export var max_health: int = 100
@export var start_health: int = 100
@export var max_shield: int = 125 # Default 5 cells * 25
@export var start_shield: int = 0
@export var shield_cell_value: int = 25

var health: float = 0.0: set = set_health
var shield: float = 0.0: set = set_shield

func _ready():
	health = start_health
	shield = start_shield
	# Emit initial values
	call_deferred("emit_status_signals")

func emit_status_signals():
	health_changed.emit(health, max_health)
	shield_changed.emit(shield, max_shield)

func set_health(value: float):
	var previous = health
	health = clamp(value, 0, max_health)
	
	if health != previous:
		health_changed.emit(health, max_health)
		
	if health <= 0 and previous > 0:
		died.emit()
	if health == max_health and previous != max_health:
		health_replenished.emit()

func set_shield(value: float):
	var previous = shield
	shield = clamp(value, 0, max_shield)
	
	if shield != previous:
		shield_changed.emit(shield, max_shield)

func get_damage(amount: int):
	if shield > 0:
		var damage_to_shield = min(shield, amount)
		shield -= damage_to_shield
		amount -= damage_to_shield
		shield_damaged.emit(damage_to_shield)
		
	if amount > 0:
		get_damage_direct(amount)

func get_damage_direct(amount: int):
	health -= amount
	damage_taken.emit(amount)

func add_health(amount: float, duration: float = 0.0):
	if duration <= 0:
		health += amount
	else:
		var tween = create_tween()
		tween.tween_method(func(val): health = val, health, min(health + amount, max_health), duration)

func add_shield(amount: float, duration: float = 0.0):
	if duration <= 0:
		shield += amount
	else:
		var tween = create_tween()
		tween.tween_method(func(val): shield = val, shield, min(shield + amount, max_shield), duration)

func get_full_health():
	health = max_health

func instant_death():
	health = 0
