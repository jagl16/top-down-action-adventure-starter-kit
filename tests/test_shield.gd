extends SceneTree

func _init():
	var health_script = load("res://health_manager.gd")
	var manager = health_script.new()
	manager._ready()
	
	print("Testing Shield Logic...")
	
	# Test 1: Damage Absorption
	manager.shield = 50
	manager.health = 100
	manager.get_damage(25)
	if is_equal_approx(manager.shield, 25.0) and is_equal_approx(manager.health, 100.0):
		print("PASS: Damage Absorption")
	else:
		print("FAIL: Damage Absorption. Shield: ", manager.shield, " Health: ", manager.health)
		
	# Test 2: Shield Break
	manager.shield = 25
	manager.health = 100
	manager.get_damage(50) # 25 shield, 25 health damage
	if is_equal_approx(manager.shield, 0.0) and is_equal_approx(manager.health, 75.0):
		print("PASS: Shield Break")
	else:
		print("FAIL: Shield Break. Shield: ", manager.shield, " Health: ", manager.health)
		
	# Test 3: Direct Damage
	manager.shield = 50
	manager.health = 100
	manager.get_damage_direct(10)
	if is_equal_approx(manager.shield, 50.0) and is_equal_approx(manager.health, 90.0):
		print("PASS: Direct Damage")
	else:
		print("FAIL: Direct Damage. Shield: ", manager.shield, " Health: ", manager.health)
	
	# Test 4: Overheal/Overshield Cap
	manager.health = 90
	manager.get_damage_direct(-20) # Negative damage should not heal via this method usually, but let's check standard logic if get_damage allows verification of heal? No, I implemented add_health separately
	
	manager.health = 90
	manager.add_health(20)
	if is_equal_approx(manager.health, 100.0):
		print("PASS: Health Cap")
	else:
		print("FAIL: Health Cap. Health: ", manager.health)
		
	manager.shield = 100
	manager.add_shield(50) # Max is 125
	if is_equal_approx(manager.shield, 125.0):
		print("PASS: Shield Cap")
	else:
		print("FAIL: Shield Cap. Shield: ", manager.shield)

	quit()
