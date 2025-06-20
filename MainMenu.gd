# res://scripts/MainMenu.gd
extends Control

func _ready() -> void:
	# Locate the buttons (adjust the paths if your hierarchy is different)
	var start_btn = $VBoxContainer/Start

	# Connect using the Godot 4 Callable API
	start_btn.pressed.connect(Callable(self, "_on_start_pressed"))


func _on_start_pressed() -> void:
	var err = get_tree().change_scene_to_file("res://main.tscn")
	if err != OK:
		push_error("Failed to load main.tscn: error %d" % err)

