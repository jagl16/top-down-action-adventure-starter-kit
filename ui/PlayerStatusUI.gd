extends Control

@export var shield_container: HBoxContainer
@export var health_bar: ProgressBar

var health_manager: Node
var shield_cell_scene: PackedScene

# Visual settings for shield cells
const CELL_WIDTH = 40 # Adjust as needed
const CELL_HEIGHT = 20
const CELL_SPACING = 10

func _ready():
	if shield_container:
		shield_container.add_theme_constant_override("separation", CELL_SPACING)

func initialize(manager: Node):
	health_manager = manager
	
	# Connect signals
	health_manager.health_changed.connect(_on_health_changed)
	health_manager.shield_changed.connect(_on_shield_changed)
	
	# Initialize UI
	init_shield_cells(health_manager.max_shield)
	
	# Set initial values
	_update_health_bar(health_manager.health, health_manager.max_health)
	_update_shield_display(health_manager.shield, health_manager.max_shield)

func init_shield_cells(max_shield: int):
	# Clear existing
	for child in shield_container.get_children():
		child.queue_free()
	
	var cell_count = ceil(float(max_shield) / float(health_manager.shield_cell_value))
	
	for i in range(cell_count):
		var cell = Panel.new()
		cell.custom_minimum_size = Vector2(CELL_WIDTH, CELL_HEIGHT)
		
		# Create style for the cell (Blue fill, Grey outline)
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.0, 0.4, 1.0) # Blue
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		style.border_color = Color(0.8, 0.8, 0.8) # Light Grey
		style.set_corner_radius_all(2)
		
		cell.add_theme_stylebox_override("panel", style)
		shield_container.add_child(cell)

func _on_health_changed(current, max_val):
	_update_health_bar(current, max_val)

func _on_shield_changed(current, max_val):
	_update_shield_display(current, max_val)

func _update_health_bar(current, max_val):
	health_bar.max_value = max_val
	# Optional: Tween for smooth bar movement
	var tween = create_tween()
	tween.tween_property(health_bar, "value", current, 0.2)
	# health_bar.value = current

func _update_shield_display(current, max_val):
	var cell_value = health_manager.shield_cell_value
	var cells = shield_container.get_children()
	
	for i in range(cells.size()):
		var cell = cells[i]
		var cell_min = i * cell_value
		
		# Simple logic: if shield covers this cell fully or partially, show it as active
		# Refined logic from req: "fill out"... usually implies they can be empty or full.
		# If they are individual cells, maybe they break/disappear? 
		# "represented by a bar that fills out... mini bars"
		
		# Let's make them look "empty" or "broken" when not filled? 
		# Or just change opacity/color.
		# Requirement: "update / fill base on the total shield"
		
		if current >= (i + 1) * cell_value:
			# Full
			cell.modulate.a = 1.0
		elif current > i * cell_value:
			# Partial (if we want detailed partials we'd need a progress bar per cell, 
			# but simplistic approach is just showing it as active)
			cell.modulate.a = 1.0
		else:
			# Empty
			cell.modulate.a = 0.2 # Dimmed out
