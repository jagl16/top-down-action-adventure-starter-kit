extends PlayerState

@export var slide_speed_multiplier: float = 2.2  # Slide is much faster (like Apex)
@export var slide_friction: float = 0.98  # Very minimal friction to maintain speed

var _slide_manager: SlideManager = null
var _slide_velocity: Vector3 = Vector3.ZERO
var _slide_direction: Vector3 = Vector3.ZERO

func _ready() -> void:
	await super._ready()
	# Get reference to slide manager (player is now available)
	if player:
		_slide_manager = player.slide_manager

func unhandled_input(event: InputEvent) -> void:
	_parent.unhandled_input(event)

func physics_process(delta: float) -> void:
	# Apply very minimal friction to maintain slide speed (Apex-style)
	var current_speed = _slide_velocity.length()
	current_speed *= slide_friction
	_slide_velocity = _slide_direction * current_speed

	# Apply slide velocity directly
	_parent.velocity.x = _slide_velocity.x
	_parent.velocity.z = _slide_velocity.z

	# Apply gravity
	_parent.velocity.y += _parent.gravity * delta

	# Move the player
	player.move_and_slide()

	# Update animations - use high speed value to show fast movement
	var speed_ratio = _slide_velocity.length() / _parent.max_speed
	player.model.update_move_animation(min(speed_ratio, 2.0), delta)

	# Keep facing the slide direction
	if _slide_direction.length() > 0.01:
		player.model.orient_model_to_direction(_slide_direction, delta)

	# Check if slide ended (managed by SlideManager timer)
	if not _slide_manager.is_sliding():
		# Transition back to sprint or run based on input
		if Input.is_action_pressed("p1_sprint") and _parent.velocity.length() > 0.1:
			_state_machine.transition_to("Move/Sprint")
		elif _parent.velocity.length() > 0.01:
			_state_machine.transition_to("Move/Run")
		else:
			_state_machine.transition_to("Move/Idle")

	# Also check if we're airborne
	if not player.is_on_floor():
		_state_machine.transition_to("Move/Fall")

func enter(msg: = {}) -> void:
	_parent.enter(msg)

	# Capture current velocity and BOOST it significantly for the slide
	var current_velocity = _parent.velocity
	current_velocity.y = 0  # Only horizontal slide

	# Determine slide direction
	if current_velocity.length() > 0.1:
		# Use current movement direction
		_slide_direction = current_velocity.normalized()
	else:
		# Use player's facing direction if no momentum
		_slide_direction = -player.model.global_transform.basis.z
		_slide_direction.y = 0
		_slide_direction = _slide_direction.normalized()

	# Apply the speed boost - significantly faster than sprint
	var slide_speed = _parent.max_speed * slide_speed_multiplier
	_slide_velocity = _slide_direction * slide_speed

	# Start the slide in SlideManager
	_slide_manager.request_slide()

func exit() -> void:
	_parent.exit()
	_slide_velocity = Vector3.ZERO
	_slide_direction = Vector3.ZERO
