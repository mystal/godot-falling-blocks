class_name Playfield
extends Node2D

@onready var board_tiles: TileMapLayer = $PlacedBlocks
@onready var active_tiles: TileMapLayer = $ActiveBlocks
@onready var preview_tiles: TileMapLayer = $PreviewBlocks

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
const START_POS := Vector2i(4, 20)
var cur_pos: Vector2i

var left_held: bool = false
var right_held: bool = false
var steps: Vector2
# In lines per second
var fall_speed: float
var acceleration: float = 0.1

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
	fall_speed = 1.0
	game_running = true
	steps = Vector2.ZERO
	piece_type = pick_piece()
	piece_atlas_coords = Vector2i(Pieces.ALL.find(piece_type) + 1, 0)
	next_piece_type = pick_piece()
	next_piece_atlas_coords = Vector2i(Pieces.ALL.find(next_piece_type) + 1, 0)
	create_piece()

	MessageBus.new_game.emit()

func _physics_process(delta: float) -> void:
	if not game_running:
		return

	# Horizontal movement
	# Move immediately when pressing in a direction, then repeat movement after
	# a set time of holding the input down.
	var x_dir := int(right_held) - int(left_held)
	if x_dir != 0.0:
		steps.x += 10.0 * delta

	# TODO: Figure out how to best support multiple moves/rotations at once
	if Input.is_action_just_pressed("hard_drop"):
		hard_drop_piece()
	elif Input.is_action_pressed("soft_drop"):
		steps.y += 10.0 * delta
	elif Input.is_action_just_pressed("rotate_right"):
		rotate_piece(1)
	elif Input.is_action_just_pressed("rotate_left"):
		rotate_piece(-1)

	# Apply downward movement every frame
	steps.y += fall_speed * delta

	# Try to move the piece left/right then down
	if steps.x >= 1.0:
		move_piece(Vector2i.RIGHT * x_dir)
		steps.x = 0.0
	if steps.y >= 1.0:
		move_piece(Vector2i.DOWN)
		steps.y = 0.0

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_left"):
		assert(not left_held)
		if not left_held:
			left_held = true
			steps.x = 1.0
	elif event.is_action_pressed("move_right"):
		assert(not right_held)
		if not right_held:
			right_held = true
			steps.x = 1.0
	elif event.is_action_released("move_left"):
		assert(left_held)
		if left_held:
			left_held = false
			steps.x = 1.0
	elif event.is_action_released("move_right"):
		assert(right_held)
		if right_held:
			right_held = false
			steps.x = 1.0

func pick_piece() -> Array:
	if not next_pieces:
		next_pieces = Pieces.ALL.duplicate()
		next_pieces.shuffle()
	return next_pieces.pop_back()

func create_piece() -> void:
	# Reset variables
	steps = Vector2.ZERO
	cur_pos = START_POS
	rotation_index = 0
	active_piece = piece_type[rotation_index]
	draw_piece(active_piece, cur_pos, piece_atlas_coords)

	update_preview()

	# Show next piece
	clear_piece(Vector2i(14, 24), active_piece)
	draw_piece(next_piece_type[0], Vector2i(14, 24), next_piece_atlas_coords)

func clear_piece(pos: Vector2i, piece_blocks: Array[Vector2i]) -> void:
	for block_pos in piece_blocks:
		active_tiles.erase_cell(pos + block_pos)

func draw_piece(piece_blocks: Array[Vector2i], pos: Vector2i, atlas_coords: Vector2i) -> void:
	for block_pos in piece_blocks:
		active_tiles.set_cell(pos + block_pos, atlas_source_id, atlas_coords)

func update_preview() -> void:
	preview_tiles.clear()
	var preview_pos := cur_pos
	var drop_done := false
	for row in range(cur_pos.y, TOP_ROW + ROWS):
		var loop_pos := Vector2i(cur_pos.x, row)
		for block_pos in active_piece:
			if not is_free(loop_pos + block_pos):
				preview_pos.y = row - 1
				drop_done = true
				break
		if drop_done:
			break
	for block_pos in active_piece:
		preview_tiles.set_cell(preview_pos + block_pos, atlas_source_id, piece_atlas_coords)

func rotate_piece(dir: int) -> void:
	if not can_rotate(dir):
		return
	clear_piece(cur_pos, active_piece)
	rotation_index = (rotation_index + dir) % Pieces.ROTATIONS
	active_piece = piece_type[rotation_index]
	draw_piece(active_piece, cur_pos, piece_atlas_coords)

	update_preview()

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

	update_preview()

func hard_drop_piece() -> void:
	var drop_pos := cur_pos
	var drop_done := false
	for row in range(cur_pos.y, TOP_ROW + ROWS):
		var loop_pos := Vector2i(cur_pos.x, row)
		for block_pos in active_piece:
			if not is_free(loop_pos + block_pos):
				drop_pos.y = row - 1
				drop_done = true
				break
		if drop_done:
			break

	# Land piece and create new piece!
	cur_pos = drop_pos
	active_tiles.clear()
	land_piece()
	check_rows()
	piece_type = next_piece_type
	piece_atlas_coords = next_piece_atlas_coords
	next_piece_type = pick_piece()
	next_piece_atlas_coords = Vector2i(Pieces.ALL.find(next_piece_type) + 1, 0)
	create_piece()
	check_game_over()

# Check if there is space to move a piece
func can_move(dir: Vector2i) -> bool:
	for block_pos in active_piece:
		if not is_free(cur_pos + block_pos + dir):
			return false
	return true

func can_rotate(dir: int) -> bool:
	var new_rotation_index := (rotation_index + dir) % Pieces.ROTATIONS
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
			fall_speed += acceleration
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
