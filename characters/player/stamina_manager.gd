class_name StaminaManager
extends Node

enum StaminaState { FULL, DRAINING, DEPLETED, COOLDOWN, REGENERATING }

signal stamina_changed(old_value: float, new_value: float)
signal stamina_depleted
signal stamina_replenished
signal cooldown_started
signal cooldown_ended

@export var max_stamina: float = 100.0
@export var depletion_time: float = 0.7  # Time to fully deplete stamina
@export var cooldown_time: float = 1.5   # Time before regeneration starts
@export var regeneration_time: float = 2.0  # Time to fully regenerate

var current_state: StaminaState = StaminaState.FULL
var stamina: float = 100.0
var cooldown_timer: float = 0.0

var depletion_rate: float = 0.0
var regeneration_rate: float = 0.0

func _ready() -> void:
	depletion_rate = max_stamina / depletion_time
	regeneration_rate = max_stamina / regeneration_time
	stamina = max_stamina

func _process(delta: float) -> void:
	match current_state:
		StaminaState.DRAINING:
			_deplete_stamina(delta)
		StaminaState.COOLDOWN:
			_process_cooldown(delta)
		StaminaState.REGENERATING:
			_regenerate_stamina(delta)

func request_sprint() -> bool:
	if current_state == StaminaState.DEPLETED or current_state == StaminaState.COOLDOWN:
		return false
	if current_state != StaminaState.DRAINING:
		_enter_draining_state()
	return true

func stop_sprint() -> void:
	if current_state == StaminaState.DRAINING:
		_enter_cooldown_state()

func get_stamina_percentage() -> float:
	return (stamina / max_stamina) * 100.0

func is_depleted() -> bool:
	return current_state == StaminaState.DEPLETED or current_state == StaminaState.COOLDOWN

func _deplete_stamina(delta: float) -> void:
	var old_stamina = stamina
	stamina -= depletion_rate * delta
	stamina = max(0.0, stamina)
	stamina_changed.emit(old_stamina, stamina)

	if stamina <= 0.0:
		_enter_depleted_state()

func _regenerate_stamina(delta: float) -> void:
	var old_stamina = stamina
	stamina += regeneration_rate * delta
	stamina = min(max_stamina, stamina)
	stamina_changed.emit(old_stamina, stamina)

	if stamina >= max_stamina:
		_enter_full_state()

func _process_cooldown(delta: float) -> void:
	cooldown_timer -= delta
	if cooldown_timer <= 0.0:
		_enter_regenerating_state()

func _enter_draining_state() -> void:
	current_state = StaminaState.DRAINING

func _enter_depleted_state() -> void:
	current_state = StaminaState.DEPLETED
	stamina_depleted.emit()
	_enter_cooldown_state()

func _enter_cooldown_state() -> void:
	current_state = StaminaState.COOLDOWN
	cooldown_timer = cooldown_time
	cooldown_started.emit()

func _enter_regenerating_state() -> void:
	current_state = StaminaState.REGENERATING
	cooldown_ended.emit()

func _enter_full_state() -> void:
	current_state = StaminaState.FULL
	stamina = max_stamina
	stamina_replenished.emit()
