extends Area2D

var direction: Vector2
var speed: float = 300.0  
var damage: int

func setup(pos,dir,type):
	position = pos
	direction = dir.normalized()
	if type in [Global.guns.AK, Global.guns.ROCKET]:
		$Sprite2D.texture = Global.gun_data[type]['texture']
		speed = Global.gun_data[type]['speed']
		damage = Global.gun_data[type]['damage']



func _process(delta):
	if direction != Vector2.ZERO:
		position += direction * speed * delta
	else:
		queue_free()


func _on_kill_timer_timeout() -> void:
		queue_free()


func _on_body_entered(body):
	if 'hit' in body:
		body.hit(damage)
	
