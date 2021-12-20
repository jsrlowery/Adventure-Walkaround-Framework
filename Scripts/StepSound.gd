extends AudioStreamPlayer2D

onready var floorTiles = get_node_or_null("../../Floor")
onready var collider = get_node("../CollisionShape2D")

var pitchMin = 0.8
var pitchRange = 0.4

func _ready():
	randomize()

func _enter_tree():
	floorTiles = get_node_or_null("../../Floor")

func pick_and_play():
	if floorTiles != null && !playing:
		var tilePos = floorTiles.world_to_map(collider.global_position)
		var tileID = floorTiles.get_cellv(tilePos)
		var tileName = floorTiles.tile_set.tile_get_name(tileID)
		stream = load("res://Assets/" + tileName.to_lower() + "_sound.ogg")
		set_pitch_scale(randf() * pitchRange + pitchMin)
		play()
