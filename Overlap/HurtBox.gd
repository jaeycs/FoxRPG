extends Area2D

#export(bool) var show_hit = true

const HitEffect = preload("res://Effects/HitEffect.tscn")

onready var timer = $Timer

var invincible = false setget set_invincible

signal invincibility_started
signal invincibility_ended

func set_invincible(value):
	invincible = value
	if invincible == true:
		emit_signal("invincibility_started")
	else:
		emit_signal("invincibility_ended")

func start_invincibility(duration):
	self.invincible = true
	print("invincible for " + str(duration))
	timer.start(duration)

func create_hit_effect():
#	if show_hit:
	var effect = HitEffect.instance()
	var main = get_tree().current_scene
	main.add_child(effect)
	effect.global_position = global_position - Vector2(0, 8)

func _on_Timer_timeout():
	print("timer timout")
	self.invincible = false # adding self will call the setter. otherwise setter will not be called
	#set_invincible(false)

func _on_HurtBox_invincibility_ended():
	print("invincibility ended")
	monitorable = true

func _on_HurtBox_invincibility_started():
	set_deferred("monitorable", false)
