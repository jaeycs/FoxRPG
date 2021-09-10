extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var WANDER_TARGET_RANGE = 5

enum {
	IDLE,
	WANDER,
	CHASE
}

onready var sprite = $AnimatedSprite
onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var hurtBox = $HurtBox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController

var knockback = Vector2.ZERO
var velocity = Vector2.ZERO

var state = CHASE

const KNOCKBACK_FRICTION = 200
const KNOCKBACK_MULTIPLIER = 100

func _ready():
	state = pick_random_state_helper([IDLE, WANDER])

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, KNOCKBACK_FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, KNOCKBACK_FRICTION * delta)
			seek_player()			
			if wanderController.get_time_left() == 0:
				pick_random_state()
		WANDER:
			accelerate_towards(delta, wanderController.target_position)
			if global_position.distance_to(wanderController.target_position) <= WANDER_TARGET_RANGE:
				pick_random_state()
			
			seek_player()
			if wanderController.get_time_left() == 0:
				pick_random_state()
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				accelerate_towards(delta, player.global_position)
			else:
				state = IDLE
	
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
	velocity = move_and_slide(velocity)

func pick_random_state():
	state = pick_random_state_helper([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(1, 3))

func accelerate_towards(delta, position):
	var direction = global_position.direction_to(position) #(player.global_position - global_position).normalized()
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0

func pick_random_state_helper(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func _on_HurtBox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * KNOCKBACK_MULTIPLIER
	hurtBox.create_hit_effect()

func _on_Stats_no_health():
	create_death_effect()
	queue_free()

func create_death_effect():
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
