class_name HUD
extends CanvasLayer

func _ready() -> void:
	$StartButton.pressed.connect(_on_start_button_pressed)

func _enter_tree() -> void:
	MessageBus.new_game.connect(_on_new_game)
	MessageBus.score_changed.connect(_on_score_changed)
	MessageBus.game_over.connect(_on_game_over)

func _on_new_game() -> void:
	$GameOverLabel.hide()

func _on_start_button_pressed() -> void:
	MessageBus.new_game_requested.emit()

func _on_score_changed(new_score: int) -> void:
	$ScoreLabel.text = "SCORE: {0}".format([new_score])

func _on_game_over() -> void:
	$GameOverLabel.show()
