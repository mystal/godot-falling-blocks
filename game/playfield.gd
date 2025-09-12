class_name Playfield
extends Node2D

@onready var board_tiles: TileMapLayer = $BoardTiles
@onready var active_tiles: TileMapLayer = $ActiveTiles

# Grid vars
const COLS := 10
const ROWS := 20

# Movement vars
const DIRECTIONS := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]
# [0: left, 1: right, 2: down]
var steps: Array[float]
var steps_req := 50
const START_POS := Vector2i(4, 20)
var cur_pos: Vector2i
# TODO: Change to lines per second
var speed: float

# Piece vars
var piece_type: Array
var next_piece_type
var rotation_index := 0
var active_piece: Array[Vector2i]

# Tilemap vars
var atlas_source_id := 0
var piece_atlas_coords: Vector2i
var next_piece_atlas: Vector2i

var next_pieces := []

func _ready() -> void:
	new_game()

func new_game() -> void:
	speed = 1.0
	steps = [0.0, 0.0, 0.0]
	piece_type = pick_piece()
	piece_atlas_coords = Vector2i(Pieces.ALL.find(piece_type) + 1, 0)
	create_piece()

func _process(_delta: float) -> void:
	if Input.is_action_pressed("ui_left"):
		steps[0] += 10.0
	elif Input.is_action_pressed("ui_right"):
		steps[1] += 10.0
	elif Input.is_action_pressed("ui_down"):
		steps[2] += 10.0

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
	active_piece = piece_type[rotation_index]
	draw_piece(active_piece, cur_pos, piece_atlas_coords)

func clear_piece() -> void:
	for block_pos in active_piece:
		active_tiles.erase_cell(cur_pos + block_pos)

func draw_piece(piece_blocks: Array[Vector2i], pos: Vector2i, atlas_coords: Vector2i) -> void:
	for block_pos in piece_blocks:
		active_tiles.set_cell(pos + block_pos, atlas_source_id, atlas_coords)

func move_piece(dir: Vector2i) -> void:
	if not can_move(dir):
		return
	clear_piece()
	cur_pos += dir
	draw_piece(active_piece, cur_pos, piece_atlas_coords)

# Check if there is space to move a piece
func can_move(dir: Vector2i) -> bool:
	for block_pos in active_piece:
		if not is_free(cur_pos + block_pos + dir):
			return false
	return true

func is_free(pos: Vector2i) -> bool:
	return board_tiles.get_cell_source_id(pos) == -1
