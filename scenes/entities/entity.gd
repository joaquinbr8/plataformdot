class_name Entity #herdaran los hijos
extends CharacterBody2D

signal shoot (pos, dir, bullet_type)
var health := 100:
	set(value):
		health = value
		if health <= 0:
			trigger_death()

func hit(damage):
	print(self)
	health -= damage
	print(health)

func trigger_death():
	print('death')
