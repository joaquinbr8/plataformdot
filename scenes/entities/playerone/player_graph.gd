extends Node2D

@onready var y_offset = get_parent().y_offset
func update_legs(direction, on_floor, ducking):
	#flip
	if direction.x:
		$Legs.flip_h = direction.x < 0
	
	#state
	var state = 'idle' if not ducking else 'duck'
	if on_floor and direction.x and not ducking:
		state = 'run'
	if not on_floor:
		state = 'jump'
	$Legs.animation = state
	
	
func update_torso(direction, ducking, current_gun):
	$AnimationTree.selected_gun = current_gun
	
	$Torso.position.y = y_offset if ducking else 0
	
	
	match current_gun:
		Global.guns.AK:
			$AnimationTree["parameters/AK/blend_position"] = direction
		Global.guns.SHOTGUN:
			$AnimationTree["parameters/Shotgun/blend_position"] = direction
		Global.guns.ROCKET:
			$AnimationTree["parameters/Rocket/blend_position"] = direction
