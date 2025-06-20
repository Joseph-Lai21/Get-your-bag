extends CharacterBody2D

const SPEED = 100
const STUCK_FRAME_THRESHOLD = 10  # Number of frames to track for stuck detection

# Current movement direction
var direction = Vector2.ZERO             
#Keeps a list of recent positions so we can tell if the enemy hasn’t moved
#(First advanced data strucutre: Queue)
var recent_positions = []    

#Remembers directions to avoid so the enemy doesn’t just turn right back around after 
#bumping something (second data strcuture: hashmap)
var blocked_directions = {}                  

@onready var sprite = $AnimatedSprite2D         # Animated sprite for movement visuals
@onready var hitbox = $Hitbox                   # Hitbox Area2D 

func _ready():
	randomize()
	pick_random_direction()
	recent_positions.append(position)

func _physics_process(_delta):
	# Movement
	velocity = direction * SPEED
	move_and_slide()

	# Check if the enemy is bumping into something
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
	#If the enemy hits another enemy, it turns
		if collider.is_in_group("enemies"):
			force_change_direction()
			break
		elif collider.is_in_group("player"):
			collider.die()
			break

	# Track recent positions to see if the enemy is stuck
	recent_positions.push_back(position)
	if recent_positions.size() > STUCK_FRAME_THRESHOLD:
		recent_positions.pop_front()

	# Check if the enemy has been still for a few seconds
	var stuck = true
	for i in range(recent_positions.size() - 1):
		if recent_positions[i].distance_to(recent_positions[i + 1]) > 0.1:
			stuck = false
			break

	if stuck:
		force_change_direction()

	#Update Sprite Animation
	update_animation()

#Picks a New Random Direction from Cardinal Directions
func pick_random_direction():
	direction = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT][randi() % 4]

#Forces a Change in Direction Avoiding Current and Opposite Directions
func force_change_direction():
	var original_dir = direction
	blocked_directions.clear()
	blocked_directions[original_dir] = true
	blocked_directions[-original_dir] = true

	var attempts = 0
	while attempts < 4:
		pick_random_direction()
		attempts += 1
		if not blocked_directions.has(direction):
			break

#Updates the Animation Based on Current Direction
func update_animation():
	match direction:
		Vector2.UP:
			sprite.play("enemy_up_run")
		Vector2.DOWN:
			sprite.play("enemy_down_run")
		Vector2.LEFT:
			sprite.play("enemy_right_run")  
		Vector2.RIGHT:
			sprite.play("enemy_left_run")  

#Changes Collision Shapes Based on Direction 
func update_collision_shape():
	$CollisionShape2D_Right.disabled = direction != Vector2.RIGHT
	$CollisionShape2D_Left.disabled = direction != Vector2.LEFT
	$CollisionShape2D_Up.disabled = direction != Vector2.UP
	$CollisionShape2D_Down.disabled = direction != Vector2.DOWN
