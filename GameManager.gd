# res://scripts/GameManager.gd
extends Node
#Settings for how collectibles are spawned
@export var collectible_scene:    PackedScene = preload("res://scenes/money_bag.tscn")
@export var initial_collectibles: int      = 5
@export var tilemap_path:         NodePath = "TileMap"

var score: int = 0          # Current run score
var last_score: int = 0     # Score from last completed run
var high_score: int = 0     # Highest score recorded across runs

var _rng := RandomNumberGenerator.new()
const MAX_TRIES := 200

#Advanced Data Structures
# Set to remember filled tile locations (3rd advanced data strucutre) 
var occupied_cells := {} 
# queue to avoid placing collectibles in the same spots twice (4th advanced data strucutre) 
var recent_spawns := []  
const MAX_RECENT_SPAWNS := 10

func _ready() -> void:
	_rng.randomize()

func collectible_collected() -> void:
	score += 1
	_spawn_collectible()
	
# Called when the player dies
func game_over() -> void:
	last_score = score
	if last_score > high_score:
		high_score = last_score
	score = 0

# Called when a new run starts
func reset_run() -> void:
	score = 0
	last_score = 0
	occupied_cells.clear()
	recent_spawns.clear()

	# Remove all collectibles from the scene
	for c in get_tree().get_nodes_in_group("Collectible"):
		c.queue_free()

	# Spawn the starting collectibles
	for i in range(initial_collectibles):
		_spawn_collectible()

# Spawns one collectible at a random unoccupied tile in the tilemap
# Tries up to MAX_TRIES times to find a good spot to place
func _spawn_collectible() -> void:
	var tm   = get_tree().current_scene.get_node(tilemap_path) as TileMap
	var rect = tm.get_used_rect()
	var ts   = tm.tile_set.tile_size

	for i in range(MAX_TRIES):
		var cell = Vector2i(
			_rng.randi_range(rect.position.x, rect.position.x + rect.size.x - 1),
			_rng.randi_range(rect.position.y, rect.position.y + rect.size.y - 1)
		)

		# Use Set to skip already-used cells
		if occupied_cells.has(cell):
			continue

		if tm.get_cell_source_id(0, cell) != -1:
			continue

		var bag = collectible_scene.instantiate() as Area2D
		bag.add_to_group("Collectible")
		get_tree().current_scene.add_child(bag)

		var local_pos = tm.map_to_local(cell) + ts * 0.5
		bag.global_position = tm.to_global(local_pos)

		# Update advanced data structures
		occupied_cells[cell] = true  

		recent_spawns.append(cell) 
		if recent_spawns.size() > MAX_RECENT_SPAWNS:
			recent_spawns.pop_front() 

		return

	push_error("GameManager: couldn’t find an empty cell after %d tries." % MAX_TRIES)
