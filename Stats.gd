extends Node

export(int) var max_health = 1
onready var health = max_health setget set_health

signal no_health

func set_health(value):
	health = value	
	print("bat: %d/%d" % [health, max_health])
	if health <= 0:
		emit_signal("no_health")
