extends Sprite2D

@onready var y_offset = get_parent().y_offset

func update(direction,distance,ducking):
	var duck_offset = 6 if ducking else 0
	position = direction * distance + Vector2(0, duck_offset)
# Called when the node enters the scene tree for the first time.
