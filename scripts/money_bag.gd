extends Area2D

func _ready() -> void:
	# connect the built‐in signal to our handler
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	# only trigger if the thing that hit us is the player
	if body.is_in_group("Player"):
		# notify the GameManager (AutoLoad or node in scene)
		GameManager.collectible_collected()
		queue_free()
