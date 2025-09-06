class_name BlockTiles
extends TileMapLayer

const COLS := 10
const ROWS := 20

const START_POS := Vector2i(4, 20)
var cur_pos: Vector2i

var piece_type
var next_piece_type
var rotation_index := 0
var active_piece: Array

var atlas_source_id := 0
var piece_atlas_coords: Vector2i
var next_piece_atlas: Vector2i

var next_pieces := []

func _ready() -> void:
	new_game()

func new_game() -> void:
	piece_type = pick_piece()
	piece_atlas_coords = Vector2i(Pieces.ALL.find(piece_type) + 1, 0)
	create_piece()

func _process(_delta: float) -> void:
	pass

func pick_piece():
	if not next_pieces:
		next_pieces = Pieces.ALL.duplicate()
		next_pieces.shuffle()
	return next_pieces.pop_back()

func create_piece():
	# Reset variables
	cur_pos = START_POS
	active_piece = piece_type[rotation_index]
	draw_piece(active_piece, cur_pos, piece_atlas_coords)

func draw_piece(piece_blocks: Array[Vector2i], pos: Vector2i, atlas_coords: Vector2i) -> void:
	for block_pos in piece_blocks:
		set_cell(pos + block_pos, atlas_source_id, atlas_coords)
