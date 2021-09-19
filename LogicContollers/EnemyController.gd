extends Node2D

const Bat = preload("res://Enemies/Bat.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func spawn(instance, area):
	var scene_instance = instance.instance()
	scene_instance.set_name("bat")
	scene_instance.set_position(area)
	add_child(scene_instance)
	
func _input(event):	
	if Input.is_action_just_pressed("spawn"):
		var mouse = get_local_mouse_position() 
		spawn(Bat, mouse)
