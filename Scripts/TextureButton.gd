extends TextureButton

onready var phaseMin = 0.4
onready var phaseMax = 0.9
onready var shift = 0.012
onready var phase = phaseMin

onready var newPos = Vector2(104, 98)
onready var toScene = "res://Scenes/Rooms/HallwayRoom.tscn"
onready var c = Globals.getContainer()

func _physics_process(delta):
	if phase > phaseMax || phase < phaseMin:
		shift = -shift
	phase += shift
	modulate = Color(1, 1, 1, sin(phase))


func _on_TextureButton_pressed():
	var theStartRoom = get_owner()
	c.fadeToScene(theStartRoom, toScene, newPos, Globals.Dir.DOWN)
