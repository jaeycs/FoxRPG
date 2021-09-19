extends MarginContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	print("                 [Screen Metrics]")
	print("            Display size: ", OS.get_screen_size())
	print("   Decorated Window size: ", OS.get_real_window_size())
	print("             Window size: ", OS.get_window_size())
	print("        Project Settings: Width=", ProjectSettings.get_setting("display/window/size/width"), " Height=", ProjectSettings.get_setting("display/window/size/height")) 
	print("         OS Window width: ", OS.get_window_size().x)
	print("        OS Window height: ", OS.get_window_size().y)
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ButtonNewGame_pressed():
	get_tree().change_scene("res://World.tscn")
