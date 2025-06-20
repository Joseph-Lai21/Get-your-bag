# res://scripts/main.gd
extends Node2D    # or whatever your main scene root is

func _ready() -> void:
	# whenever main.tscn loads, start a fresh run
	GameManager.reset_run()
