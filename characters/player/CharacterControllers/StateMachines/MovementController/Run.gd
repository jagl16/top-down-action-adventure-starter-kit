extends PlayerState

var _stamina_manager: StaminaManager = null

func _ready() -> void:
	await super._ready()
	if player and player.has_node("StaminaManager"):
		_stamina_manager = player.stamina_manager

func unhandled_input(event: InputEvent) -> void:
	_parent.unhandled_input(event)


func physics_process(delta: float) -> void:
	# Check for sprint input
	if Input.is_action_pressed("p1_sprint"):
		if _stamina_manager and not _stamina_manager.is_depleted():
			_state_machine.transition_to("Move/Sprint")


	_parent.physics_process(delta)
	if player.is_on_floor() or player.is_on_wall():
		if _parent.velocity.length() < 0.01:
			_state_machine.transition_to("Move/Idle")
	# else:
	# 	_state_machine.transition_to("Move/Jump")
	if not player.is_on_floor():
		_state_machine.transition_to("Move/Fall")


func enter(msg := {}) -> void:
	_parent.enter(msg)


func exit() -> void:
	_parent.exit()
