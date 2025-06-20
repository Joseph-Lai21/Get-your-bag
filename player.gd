extends CharacterBody2D
# Controls the player character’s movement and handles win/loss conditions

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animatedSprite = $AnimatedSprite2D

# Runs every frame and handles player movement + animations
func _physics_process(delta):
	var direction = Input.get_axis("LEFT", "RIGHT")
	var verticalDirection = Input.get_axis("UP", "DOWN")

	if direction || verticalDirection:
		if direction > 0:
			velocity.y = 0
			velocity.x = direction * SPEED
			animatedSprite.play("right_run")
		elif direction < 0:
			velocity.y = 0
			velocity.x = direction * SPEED
			animatedSprite.play("left_run")
			
		if verticalDirection < 0:
			velocity.x = 0
			velocity.y = verticalDirection * SPEED
			animatedSprite.play("up_run")
		elif verticalDirection > 0:
			velocity.x = 0
			velocity.y = verticalDirection * SPEED
			animatedSprite.play("down_run")
			
	else:	
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
		animatedSprite.play("idle")

	move_and_slide()

# Called when the player finishes the level
func _show_win_screen():
	get_tree().change_scene("res://win_scene.tscn")


# Called when the player dies
func _on_death():
	GameManager.game_over()
	get_tree().change_scene_to_file("res://scenes/gameover.tscn")

# Triggered when the player's hitbox touches something
func _on_hitbox_area_entered(area):
	if area.is_in_group("enemies"):
		_on_death()
