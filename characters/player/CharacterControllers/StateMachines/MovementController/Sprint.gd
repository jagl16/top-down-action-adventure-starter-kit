extends PlayerState

@export var sprint_speed_multiplier: float = 1.5

var _stamina_manager: StaminaManager = null

func _ready() -> void:
	await super._ready()
	# Get reference to stamina manager
	if player and player.has_node("StaminaManager"):
		_stamina_manager = player.stamina_manager

func unhandled_input(event: InputEvent) -> void:
	_parent.unhandled_input(event)
	# Handle sprint release
	if event.is_action_released("p1_sprint"):
		_state_machine.transition_to("Move/Run")

func physics_process(delta: float) -> void:
	# Check if stamina is depleted
	if _stamina_manager and _stamina_manager.is_depleted():
		_state_machine.transition_to("Move/Run")
		return

	# Use parent's movement logic but with multiplied speed
	var original_speed = _parent.max_speed
	_parent.max_speed = original_speed * sprint_speed_multiplier

	_parent.physics_process(delta)

	# Restore original speed for next frame
	_parent.max_speed = original_speed

	# Check state transitions
	if player.is_on_floor() or player.is_on_wall():
		if _parent.velocity.length() < 0.01:
			_state_machine.transition_to("Move/Idle")

	if not player.is_on_floor():
		_state_machine.transition_to("Move/Fall")

func enter(msg: = {}) -> void:
	_parent.enter(msg)
	if _stamina_manager:
		_stamina_manager.request_sprint()

func exit() -> void:
	_parent.exit()
	if _stamina_manager:
		_stamina_manager.stop_sprint()
