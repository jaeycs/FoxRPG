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
# the world grid
var grid = []
# multiple 'walker'
var walkers = []

class Walker:
	var dir: Vector2
	var pos: Vector2
	
var max_iterations = 1000

var walker_max_count = 3
var walker_sqawn_chance = 0.25
var walker_direction_chance = 0.5

# how much do we want to fill with random tile
var fill_percent = 0.3
var walker_destroy_chance = 0.2


var Tiles = {
	"empty": -1,
	"cliff": 0,
	"floor": 1
}

func _init_walkers():
	walkers = []
	
	var walker = Walker.new()
	walker.dir = GetRandomDirection()
	# walker initial position is centre of the map
	walker.pos = Vector2(width/2, height/2)
	walkers.append(walker)
	

# reset the world to empty state
func _init_grid():
	grid = []
	for x in width: 
		grid.append([])
		for y in height:
			#grid[x].append(Tiles.empty())
			grid[x].append(-1)


# return random cardinal direction (Vector2(x,y))
func GetRandomDirection():
	var directions = [[-1, 0], [1, 0], [0, 1], [0, -1]]
	var direction = directions[rng.randi()%4]
	return Vector2(direction[0], direction[1])
	
func _create_random_path():
	var itr = 0
	var n_tiles = 0
	
	# choose random direction
	# check bounds
	# move to that direction
	while itr < max_iterations:
		
		# randomly change walkers' direction
		for i in range(walkers.size()):
			if rng.randf() < walker_direction_chance:
				walkers[i].dir = GetRandomDirection()
				
		for i in range(walkers.size()):
			if (rng.randf() < walker_sqawn_chance and
				walkers.size() < walker_max_count):
					var walker = Walker.new()
					walker.dir = GetRandomDirection()
					walker.pos = walkers[i].pos
					walkers.append(walker)
					
		# boundary check
		for i in range(walkers.size()):
			if (walkers[i].pos.x + walkers[i].dir.x >= 0 and
				walkers[i].pos.x + walkers[i].dir.x < width and
				walkers[i].pos.y + walkers[i].dir.y >= 0 and
				walkers[i].pos.y + walkers[i].dir.y < height):
					walkers[i].pos += walkers[i].dir
					
					
					if grid[walkers[i].pos.x][walkers[i].pos.y] == Tiles.empty:
						grid[walkers[i].pos.x][walkers[i].pos.y] = Tiles.floor
						n_tiles += 1
						
						if float(n_tiles) / float(width * height) >= fill_percent:
							return
				
		itr += 1
	#end while

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

	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _input(event):
	if Input.is_key_pressed(KEY_BACKSPACE):
			rng.randomize()
			_init_walkers()
			_init_grid()
			_clear_tilemaps()
			_create_random_path()
			_spawn_tiles()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
