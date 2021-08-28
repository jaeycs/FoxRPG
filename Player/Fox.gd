extends KinematicBody2D

const ACCELERATION = 10
const MAX_SPEED = 100
const FRICTION = 10

var velocity = Vector2.ZERO

func _physics_process(frameRate):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector =  input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		velocity += input_vector * ACCERATION * frameRate
		velcoity = velocity.clamped(MAX_SPEED * frameRate)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * frameRate)
	
	move_and_collide(velocity)

# Called when the node enters the scene tree for the first time.
func _ready():
	print ("Have Fun!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
