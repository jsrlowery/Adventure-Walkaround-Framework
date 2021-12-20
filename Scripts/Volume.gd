extends TextureButton

var currentMode = 2
var soundModes = ["Sound_0.png", "Sound_1.png", "Sound_2.png"]
var volumeModes = [-100, -15, 0]

func _ready():
	release_focus()

func onPressed():
	currentMode = (currentMode - 1) % soundModes.size()
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volumeModes[currentMode])
	texture_normal = load("res://Assets/" + soundModes[currentMode])
	release_focus()
