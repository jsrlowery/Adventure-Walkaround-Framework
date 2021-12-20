extends TextureButton

onready var phaseMin = 0.4
onready var phaseMax = 0.9
onready var shift = 0.012
onready var phase = phaseMin

onready var newPos = Vector2(104, 98)
onready var toScene = "res://Scenes/Rooms/HallwayRoom.tscn"
onready var c = Globals.getContainer()
onready var player = c.playerRequest()
onready var sm = Globals.getStoryManager()
onready var pm = c.get_node("PermanenceManager")
onready var st = c.get_node("StoryTimer")

func _physics_process(delta):
	if phase > phaseMax || phase < phaseMin:
		shift = -shift
	phase += shift
	modulate = Color(1, 1, 1, sin(phase))

# Move to the hallway room.
func _on_TextureButton_pressed():
	var theStartRoom = get_owner()
	c.fadeToScene(theStartRoom, toScene, newPos, Globals.Dir.DOWN)
	resetData()

# Resets the data that the game uses for knowledge on what's been done.
func resetData():
	player.resetValues()
	sm.resetValues()
	pm.resetValues()
	st.resetValues()
