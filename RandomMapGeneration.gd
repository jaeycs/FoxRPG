extends Node2D


onready var dirtTile = $DirtPathTileMap
onready var cliffTile = $CliffTileMap

var rng = RandomNumberGenerator.new()

var CellSize = Vector2(32,32)

var screenSize = Vector2(640, 360)
#var screenSize = Vector2(3200, 1800)

var width = screenSize.x/CellSize.x
var height = screenSize.y/CellSize.y
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

# to compensate the different size of tiles (dirt, cliff) 16, 32
var neighbors4 = [ [1, 0], [-1, 0], [0, 1], [0, -1]]
var neighbors8 = [ [1, 0], [-1, 0], [0, 1], [0, -1], [1, 1], [-1, -1], [1, -1], [-1, 1]]

var Tiles = {
	"empty": -1,
	"cliff": 0,
	"floor": 1,
	"dirt" : 2
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

func _create_walls():
	for x in width:
		for y in height:
			if grid[x][y] == Tiles.floor:
				for neighbor in neighbors4:
					if check_bounds(x, y, neighbor) && grid[x + neighbor[0]][y + neighbor[1]] == Tiles.empty:
						grid[x + neighbor[0]][y + neighbor[1]] = Tiles.cliff

func check_bounds(x, y, neighbor):
	return x + neighbor[0] >= 0 && y + neighbor[1] >= 0 && y + neighbor[1] < height && x + neighbor[0] > width


func _remove_singletons():
	for x in width:
		for y in height:
			if grid[x][y] == Tiles.cliff:
				var single = true
				for neighbor in neighbors4:
					if check_bounds(x, y, neighbor) && grid[x + neighbor[0]][y + neighbor[1]] != Tiles.floor:
						single = false
						break
				if single:
					grid[x][y] = Tiles.floor


func _pad_dirt():
	var visit_code = 11
	var bfs = []
	var visited = []
	
	for x in width:
		visited.append([])
		for y in height:
			if grid[x][y] == Tiles.cliff:
				bfs.append(Vector2(x,y))
				visited[x].append(0)
			else:
				visited[x].append(visit_code)
	
	while !bfs.empty():
		var position = bfs.pop_front()
		for i in range(neighbors8.size()):
			var next = Vector2(position.x + neighbors8[i][0], position.y + neighbors8[i][1])
			if next.x >= 1 and next.x < width-1 and next.y >= 1 and next.y < height-1 and (visited[next.x][next.y] == visit_code):
				visited[next.x][next.y] = visited[position.x][position.y] + 1
				bfs.append(next)
	
	for x in width:
		for y in height:
			if x == 0 or y == 0 or x == width-1 or y == height-1:
				continue
			if grid[x][y] == Tiles.floor and visited[x][y] >= 2:
				grid[x][y] = Tiles.dirt


func _remove_diagonals(tile_index):
	for x in width:
		for y in height:
			# Check if on edges
			if x == 0 or y == 0 or x == width-1 or y == height-1:
				continue
				
			# If not on edges, make sure all surrounding tiles are floor and this is wall
			var position = Vector2(x, y);
			if grid[position.x][position.y] == tile_index:
				if (grid[position.x - 1][position.y] == Tiles.floor and grid[position.x + 1][position.y] == Tiles.floor and
					grid[position.x][position.y - 1] == Tiles.floor and grid[position.x][position.y + 1] == Tiles.floor):
					grid[position.x][position.y] = Tiles.floor

				# Check if diagonal tile
				if (grid[position.x - 1][position.y] == Tiles.floor and grid[position.x][position.y-1] == Tiles.floor and
					grid[position.x - 1][position.y-1] == tile_index) or (grid[position.x + 1][position.y] == Tiles.floor and grid[position.x][position.y+1] == Tiles.floor and
					grid[position.x + 1][position.y+1] == tile_index) or (grid[position.x + 1][position.y] == Tiles.floor and grid[position.x][position.y-1] == Tiles.floor and
					grid[position.x + 1][position.y-1] == tile_index) or (grid[position.x - 1][position.y] == Tiles.floor and grid[position.x][position.y+1] == Tiles.floor and
					grid[position.x - 1][position.y+1] == tile_index):
					grid[position.x][position.y] = Tiles.floor

func _spawn_tiles():
	for x in width:
		for y in height:
			match grid[x][y]:
				Tiles.empty:
					cliffTile.set_cellv(Vector2(x,y),0)
				Tiles.floor:
					pass
				Tiles.dirt:
					dirtTile.set_cellv(Vector2(x*2,y*2), 0)
					dirtTile.set_cellv(Vector2(x*2+1,y*2), 0)
					dirtTile.set_cellv(Vector2(x*2,y*2+1), 0)
					dirtTile.set_cellv(Vector2(x*2+1,y*2+1), 0)
				Tiles.cliff:
					cliffTile.set_cellv(Vector2(x,y),0)
					
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
			_create_walls()
			_remove_singletons()
			_pad_dirt()
			_remove_diagonals(Tiles.dirt)
			_spawn_tiles()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
