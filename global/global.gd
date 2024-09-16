extends Node

enum guns { AK, SHOTGUN, ROCKET }

const enemy_parameters = {
	'drone':{'health': 60, 'speed' :100},
	'soldier':{'health': 20, 'speed': 50},
	'monster': {'health': 300}
}


const gun_data = {
	guns.AK: {'damage': 20, 'speed': 200, 'texture': preload("res://graphics/guns/projectiles/default.png")},
	guns.ROCKET: {'damage': 60, 'speed': 120, 'texture': preload("res://graphics/guns/projectiles/large.png")},
	guns.SHOTGUN: {'damage': 30, 'range': 40},
}



#func _ready():
	#print(guns.AK)
