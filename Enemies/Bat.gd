extends KinematicBody2D

onready var stats = $Stats

var knockback = Vector2.ZERO

const FRICTION = 200
const KNOCKBACK_MULTIPLIER = 100

func _ready():
	print("bat heath: %d/%d" % [stats.health, stats.max_health])

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)

func _on_HurtBox_area_entered(area):
	stats.health -= 1
	knockback = area.knockback_vector * KNOCKBACK_MULTIPLIER
	print("bat heath: %d/%d" % [stats.health, stats.max_health])


func _on_Stats_no_heath():
	print("bat dead: %d/%d" % [stats.health, stats.max_health])
	queue_free()
