extends Control

var hearts = 5 setget set_hearts
var max_hearts = 5 setget set_max_hearts

onready var label = $Label
onready var heartUIFull = $HeartUIFull
onready var heartUIEmpty = $HeartUIEmpty

const HEART_WIDTH = 15

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts) #this logic should actually be at stats or something. not at the UI script
	if heartUIFull != null:
		heartUIFull.rect_size.x = hearts * HEART_WIDTH
	if label != null:
		label.text = "HP = " + str(hearts)

func set_max_hearts(value):
	max_hearts = max(value, 1)
	if heartUIEmpty != null:
		heartUIEmpty.rect_size.x = max_hearts * HEART_WIDTH

func _ready():
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	PlayerStats.connect("health_changed", self, "set_hearts")
	PlayerStats.connect("max_health_changed", self, "set_max_hearts")
