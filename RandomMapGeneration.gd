extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var dirtTile = $DirtPathTileMap
onready var cliffTile = $CliffTileMap

var rng = RandomNumberGenerator.new()

var CellSize = Vector2(16,16)

var width = 320/CellSize.x
var height = 180/CellSize.y
var grid = []

var Tiles = {
	"empty": -1,
	"cliff": 0,
	"floor": 1
}

func _init_grid():
	grid = []
	for x in width: 
		grid.append([])
		for y in height:
			grid[x].append(-1);


# return random cardinal direction (Vector2(x,y))
func GetRandomDirection():
	var directions = [[-1, 0], [1, 0], [0, 1], [0, -1]]
	var direction = directions[rng.randi()%4]
	return Vector2(direction[0], direction[1])
	
func _create_random_path():
	var max_iterations = width * height
	var itr = 0
	
	var walker = Vector2.ZERO
	
	
	# choose random direction
	# check bounds
	# move to that direction
	while itr < max_iterations:
		var random_direction = GetRandomDirection()
		
		if (walker.x + random_direction.x >= 0 and
			walker.x + random_direction.x < width and
			walker.y + random_direction.y >= 0 and
			walker.y + random_direction.y < height):
				walker += random_direction
				
				grid[walker.x][walker.y] = Tiles.floor
				itr += 1

func _spawn_tiles():
	for x in width:
		for y in height:
			match grid[x][y]:
				Tiles.empty:
					pass
				Tiles.floor:
					dirtTile.set_cellv(Vector2(x,y), 0)
				Tiles.cliff:
					pass
					
	dirtTile.update_bitmask_region()
	cliffTile.update_bitmask_region()
					
func _clear_tilemaps():
	for x in width:
		for y in height:
			dirtTile.clear()
			cliffTile.clear()
	#dirtTile.update_bitmask_region()
	#cliffTile.update_bitmask_region()
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _input(event):
	if Input.is_key_pressed(KEY_BACKSPACE):
			rng.randomize()
			_init_grid()
			_clear_tilemaps()
			_create_random_path()
			_spawn_tiles()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
