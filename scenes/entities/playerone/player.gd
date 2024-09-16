extends Entity

@export_group('move')
@export var speed := 200
@export var acceleration := 400
@export var friction := 900
var direction := Vector2.ZERO 
var can_move := true
var dash := false
@export_range(0.1,2) var dash_cooldown := 0.5
var ducking := false
var gamepad_active := true

@export_group('jump')
@export var jump_strength := 360
@export var gravity := 600
@export var terminal_velocity := 500
var jump := false
var faster_fall := false
var gravity_multiplier := 1


@export_group('gun')
var aim_direction := Vector2.RIGHT
@export var crosshair_distance := 25
var y_offset := 6
var current_gun = Global.guns.AK
@export_range(0.2,2.0) var ak_cooldown := 0.5
@export_range(0.2,2.0) var shotgun_cooldown := 1.0
@export_range(0.2,2.0) var rocket_cooldown := 1.6

func _ready():
	$Timers/DashCooldown.wait_time = dash_cooldown
	$Timers/AKReload.wait_time = ak_cooldown
	$Timers/ShotgunReload.wait_time = shotgun_cooldown
	$Timers/RocketReload.wait_time = rocket_cooldown

func _process(delta):
	apply_gravity(delta)
	
	if can_move:
		get_input()
		apply_movement(delta)
		animate()
	if Input.is_action_just_pressed("shoot"):
		shoot_bullet()

func animate():
	$Crosshair.update(aim_direction,crosshair_distance,ducking)
	$PlayerGraph.update_legs(direction, is_on_floor(),ducking)
	$PlayerGraph.update_torso(aim_direction, ducking, current_gun)
	
func get_input():
	# horizontal movement 
	direction.x = Input.get_axis("left", "right")
	
	# jump 
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or $Timers/Coyote.time_left:
			jump = true
		
		if velocity.y > 0 and not is_on_floor():
			$Timers/JumpBuffer.start()
		
	if Input.is_action_just_released("jump") and not is_on_floor() and velocity.y < 0:
		faster_fall = true

	#dash
	if Input.is_action_just_pressed("dash") and velocity.x and not $Timers/DashCooldown.time_left:
		dash = true
		$Timers/DashCooldown.start()
	
	#crouch
	ducking = Input.is_action_pressed("duck") and is_on_floor()
	
	#aim
	var aim_input_gamepad = Input.get_vector("aim_left","aim_right","aim_up","aim_down")
	var aim_input_mouse = get_local_mouse_position().normalized()
	var aim_input = aim_input_gamepad if gamepad_active else aim_input_mouse
	if aim_input.length() > 0.5:
		aim_direction = Vector2(round(aim_input.x), round(aim_input.y))
	#switch
	if Input.is_action_just_pressed("switch"):
		current_gun = (current_gun + 1) % Global.guns.size()
		print(current_gun)
	#shoot
	if Input.is_action_just_pressed("shoot"):
		shoot_gun()



func _input(event):
	if event is InputEventMouseMotion:
		gamepad_active = false
	if Input.get_vector("aim_left","aim_right","aim_up","aim_down"):
		gamepad_active = true

func apply_movement(delta):
	# left/right movement 
	if direction.x:
		velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
	
	if ducking:
		velocity.x = 0
	
	# jump 
	if jump or $Timers/JumpBuffer.time_left and is_on_floor():
		velocity.y = -jump_strength
		jump = false
		faster_fall = false
	
	var on_floor = is_on_floor()
	move_and_slide()
	if on_floor and not is_on_floor() and velocity.y >= 0:
		$Timers/Coyote.start()
	
	# dash
	if dash:
		dash = false
		var dash_tween = create_tween()
		dash_tween.tween_property(self, 'velocity:x',velocity.x + direction.x * 600, 0.3)
		dash_tween.connect("finished", on_dash_finish)
		gravity_multiplier = 0
	
	
func apply_gravity(delta):
	velocity.y += gravity * delta
	velocity.y = velocity.y / 2 if faster_fall and velocity.y < 0 else velocity.y
	velocity.y = velocity.y * gravity_multiplier
	velocity.y = min(velocity.y, terminal_velocity)


func on_dash_finish():
	velocity.x = move_toward(velocity.x, 0, 500)
	gravity_multiplier = 1

func shoot_gun():
	var pos = position + aim_direction *crosshair_distance
	pos = pos if not ducking else pos + Vector2(0, y_offset)
	if current_gun == Global.guns.AK and not $Timers/AKReload.time_left:
		shoot.emit(pos,direction,current_gun)
		$Timers/AKReload.start()
	if current_gun == Global.guns.ROCKET and not $Timers/RocketReload.time_left:
		shoot.emit(pos,direction,current_gun)
		$Timers/RocketReload.start()
	if current_gun == Global.guns.SHOTGUN and not $Timers/ShotgunReload.time_left:
		shoot.emit(pos,direction,current_gun)
		$Timers/ShotgunReload.start()
		#balas dispersas
		$GPUParticles2D.position = $Crosshair.position
		$GPUParticles2D.process_material.set('direction', aim_direction)
		$GPUParticles2D.emitting = true

func get_cam():
	return $Camera2D

func shoot_bullet():
	var bullet_dir = (get_global_mouse_position() - position).normalized()
	emit_signal('shoot', position, bullet_dir, "normal")
