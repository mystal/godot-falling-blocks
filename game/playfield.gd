class_name Playfield
extends Node2D

@onready var board_tiles: TileMapLayer = $PlacedBlocks
@onready var active_tiles: TileMapLayer = $ActiveBlocks

# Game vars
var score: int:
	get:
		return score
	set(value):
		score = value
		MessageBus.score_changed.emit(score)
const REWARD: int = 100
var game_running: bool

# Grid vars
const COLS := 10
const ROWS := 20
const TOP_ROW := 20

# Movement vars
const DIRECTIONS := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]
# [0: left, 1: right, 2: down]
var steps: Array[float]
var steps_req := 50
const START_POS := Vector2i(4, 20)
var cur_pos: Vector2i
# TODO: Change to lines per second
var speed: float
var acceleration: float = 0.25

# Piece vars
var piece_type: Array
var next_piece_type: Array
var rotation_index := 0
var active_piece: Array[Vector2i]

# Tilemap vars
var atlas_source_id := 0
var piece_atlas_coords: Vector2i
var next_piece_atlas_coords: Vector2i

var next_pieces := []

func _ready() -> void:
	new_game()

func _enter_tree() -> void:
	MessageBus.new_game_requested.connect(new_game)

func new_game() -> void:
	# Clean up the active piece and the next piece.
	if active_piece:
		clear_piece(cur_pos, active_piece)
		clear_piece(Vector2i(14, 24), next_piece_type[0])
		clear_board()

	score = 0
	speed = 1.0
	game_running = true
	steps = [0.0, 0.0, 0.0]
	piece_type = pick_piece()
	piece_atlas_coords = Vector2i(Pieces.ALL.find(piece_type) + 1, 0)
	next_piece_type = pick_piece()
	next_piece_atlas_coords = Vector2i(Pieces.ALL.find(next_piece_type) + 1, 0)
	create_piece()

	MessageBus.new_game.emit()

func _process(_delta: float) -> void:
	if not game_running:
		return

	if Input.is_action_pressed("ui_left"):
		steps[0] += 10.0
	elif Input.is_action_pressed("ui_right"):
		steps[1] += 10.0
	elif Input.is_action_pressed("ui_down"):
		steps[2] += 10.0
	elif Input.is_action_just_pressed("ui_up"):
		rotate_piece()

	# Apply downward movement every frame
	steps[2] += speed

	# Try to move the piece
	for i in range(steps.size()):
		pass
		if steps[i] > steps_req:
			move_piece(DIRECTIONS[i])
			steps[i] = 0.0

func pick_piece() -> Array:
	if not next_pieces:
		next_pieces = Pieces.ALL.duplicate()
		next_pieces.shuffle()
	return next_pieces.pop_back()

func create_piece() -> void:
	# Reset variables
	steps = [0.0, 0.0, 0.0]
	cur_pos = START_POS
	rotation_index = 0
	active_piece = piece_type[rotation_index]
	draw_piece(active_piece, cur_pos, piece_atlas_coords)

	# Show next piece
	clear_piece(Vector2i(14, 24), active_piece)
	draw_piece(next_piece_type[0], Vector2i(14, 24), next_piece_atlas_coords)

func clear_piece(pos: Vector2i, piece_blocks: Array[Vector2i]) -> void:
	for block_pos in piece_blocks:
		active_tiles.erase_cell(pos + block_pos)

func draw_piece(piece_blocks: Array[Vector2i], pos: Vector2i, atlas_coords: Vector2i) -> void:
	for block_pos in piece_blocks:
		active_tiles.set_cell(pos + block_pos, atlas_source_id, atlas_coords)

func rotate_piece() -> void:
	if not can_rotate():
		return
	clear_piece(cur_pos, active_piece)
	rotation_index = (rotation_index + 1) % Pieces.ROTATIONS
	active_piece = piece_type[rotation_index]
	draw_piece(active_piece, cur_pos, piece_atlas_coords)

func move_piece(dir: Vector2i) -> void:
	if not can_move(dir):
		if dir == Vector2i.DOWN:
			land_piece()
			check_rows()
			piece_type = next_piece_type
			piece_atlas_coords = next_piece_atlas_coords
			next_piece_type = pick_piece()
			next_piece_atlas_coords = Vector2i(Pieces.ALL.find(next_piece_type) + 1, 0)
			create_piece()
			check_game_over()
		return

	clear_piece(cur_pos, active_piece)
	cur_pos += dir
	draw_piece(active_piece, cur_pos, piece_atlas_coords)

# Check if there is space to move a piece
func can_move(dir: Vector2i) -> bool:
	for block_pos in active_piece:
		if not is_free(cur_pos + block_pos + dir):
			return false
	return true

func can_rotate() -> bool:
	var new_rotation_index := (rotation_index + 1) % Pieces.ROTATIONS
	var new_piece: Array[Vector2i] = piece_type[new_rotation_index]
	for block_pos in new_piece:
		if not is_free(cur_pos + block_pos):
			return false
	return true

func is_free(pos: Vector2i) -> bool:
	return board_tiles.get_cell_source_id(pos) == -1

func land_piece() -> void:
	# Remove each segment from the active tiles and move to the board tiles.
	for block_pos in active_piece:
		active_tiles.erase_cell(cur_pos + block_pos)
		board_tiles.set_cell(cur_pos + block_pos, atlas_source_id, piece_atlas_coords)

func check_rows() -> void:
	var row := ROWS - 1
	while row >= 0:
		var row_full := true
		for col in range(COLS):
			if is_free(Vector2i(col, TOP_ROW + row)):
				row_full = false
				break
		if row_full:
			shift_rows(TOP_ROW + row)
			score += REWARD
			speed += acceleration
		else:
			row -= 1

func shift_rows(row: int) -> void:
	var atlas_coords: Vector2i
	for j in range(row, TOP_ROW, -1):
		for i in range(COLS):
			atlas_coords = board_tiles.get_cell_atlas_coords(Vector2i(i, j - 1))
			if atlas_coords == Vector2i(-1, -1):
				board_tiles.erase_cell(Vector2i(i, j))
			else:
				board_tiles.set_cell(Vector2i(i, j), atlas_source_id, atlas_coords)

func clear_board() -> void:
	for j in range(ROWS):
		for i in range(COLS):
			board_tiles.erase_cell(Vector2i(i, j + TOP_ROW))

func check_game_over() -> void:
	for block_pos in active_piece:
		if not is_free(cur_pos + block_pos):
			land_piece()
			game_running = false
			MessageBus.game_over.emit()
