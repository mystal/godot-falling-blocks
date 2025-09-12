class_name HUD
extends CanvasLayer

func _ready() -> void:
	pass

func _enter_tree() -> void:
	MessageBus.new_game.connect(_on_new_game)

func _on_new_game() -> void:
	$GameOverLabel.hide()
