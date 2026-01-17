extends Control

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var cooldown_overlay: ColorRect = $ProgressBar/CooldownOverlay

var stamina_manager: StaminaManager = null

func _ready() -> void:
	pass

func initialize(manager: StaminaManager) -> void:
	stamina_manager = manager
	_connect_signals()
	_update_display(stamina_manager.stamina, stamina_manager.stamina)


func _connect_signals() -> void:
	if stamina_manager:
		stamina_manager.stamina_changed.connect(_on_stamina_changed)
		stamina_manager.cooldown_started.connect(_on_cooldown_started)
		stamina_manager.cooldown_ended.connect(_on_cooldown_ended)

func _on_stamina_changed(old_value: float, new_value: float) -> void:
	_update_display(old_value, new_value)

func _update_display(_old_value: float, _new_value: float) -> void:
	if not stamina_manager:
		return

	var percentage = stamina_manager.get_stamina_percentage()
	progress_bar.value = percentage

	# Update color based on stamina level
	if percentage > 50:
		progress_bar.modulate = Color(0.2, 1.0, 0.2) # Green
	elif percentage > 25:
		progress_bar.modulate = Color(1.0, 1.0, 0.2) # Yellow
	else:
		progress_bar.modulate = Color(1.0, 0.2, 0.2) # Red

func _on_cooldown_started() -> void:
	if cooldown_overlay:
		cooldown_overlay.visible = true

func _on_cooldown_ended() -> void:
	if cooldown_overlay:
		cooldown_overlay.visible = false
