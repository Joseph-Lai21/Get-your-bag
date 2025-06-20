# res://scripts/gameover.gd
# Handles the game over screen: shows scores and buttons to retry or quit
extends CanvasLayer 

# Runs when the Game Over screen appears
func _ready() -> void:
	print("🔵 GameOver._ready() fired")

	# Update the labels
	$LastScoreLabel.text  = "Last: " + str(GameManager.last_score)
	$HighScoreLabel.text  = "Best: " + str(GameManager.high_score)


	var retry_btn = $retry


	retry_btn.pressed.connect(Callable(self, "_on_RetryButton_pressed"))

# Called when the retry button is pressed
func _on_RetryButton_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")

# Called when the quit button is pressed
func _on_quit_pressed():
	get_tree().quit()
