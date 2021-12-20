extends Node2D

const DEFAULT = "default"

# Variable to contain a pre-prepared reference to all dialoge resources.
var allDialog = {}

# Total number of story elements for the StoryTimer to play.
var totalStory = 0

# Total number of exits.
var totalExits = 0

# Whether a dialogbox is playing already or not.
var playing = false

# If the player attempts to return the way they came.
var triedToGoBack = false

onready var dBox = preload("res://Scenes/DialogBox.tscn")

# Signals listeners that an interaction is occuring.
signal interacting()

# Signals listeners that a dramatic event is occuring.
signal dramatic()

# Signals listeners that the system is being unlocked.
signal unlocked()

# Load in all dialog assets.
func _ready():
	var path = "res://Assets/Dialog/"
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.begins_with("Story"):
				totalStory += 1
			if file_name.begins_with("Exit"):
				totalExits += 1
			if file_name.ends_with(".tres"):
				var res = load(path + file_name)
				
				# Prep the dialog data by storing its lines and flags.
				var dData = [res.lines, 0, {}]
				if res.get("autotrigger") != null && res.autotrigger:
					dData[1] = dData[1] | 1
				if res.get("onetime") != null && res.onetime:
					dData[1] = dData[1] | 2
				if res.get("loop") != null && res.loop:
					dData[1] = dData[1] | 4
				if res.get("choice") != null && res.choice:
					dData[1] = dData[1] | 8
					dData[2]["choice"] = res.choice
				
				# Prep the PermanenceManager.
				var pm = get_node("../PermanenceManager")
				pm.newInteraction(res.name)
				if res.get("hint") != null && res.hint:
					pm.newHintBingoBox(res.name, res.hint)
				
				# Map the name in the file to its lines and flags.
				allDialog[res.name.to_lower()] = dData
			file_name = dir.get_next()
		dir.list_dir_end()

func connect_player(player):
	connect("interacting", player, "whenInteracting")
	connect("dramatic", player, "whenDramatic")
	connect("dramatic", player.get_node("Light2D"), "whenDramatic")

func instanceDialogBox(dialogName, interacting=true):
	if !playing:
		get_node("../StoryTimer").locked = true
		playing = true
		
		# Contains the current dialog to be played when the dbox is instanced.
		var d
		if (allDialog.has(dialogName.to_lower())):
			d = allDialog[dialogName.to_lower()]
		else:
			d = allDialog[DEFAULT]
		
		var instance = dBox.instance()
		
		# If the flags for the dialog contains a choice, provide it to the dialogBox. 
		if bool(d[1] & 8):
			instance.choiceData = d[2]["choice"]
		
		# Denote the type of dialog being created.
		if interacting:
			emit_signal("interacting")
			instance.connect("dialogFinished", get_node("../StoryTimer"), "unlock")
			instance.connect("dialogFinished", self, "unlock")
		else:
			emit_signal("dramatic")
			instance.isDramatic = true
			instance.connect("dramaticFinished", get_node("../StoryTimer"), "unlock")
			instance.connect("dramaticFinished", self, "unlock")
		
		# Add the instance to the tree, then return it to the caller.
		add_child(instance)
		instance.begin(d[0])
		return instance
	else:
		return null

# Returns the flags for a given bit of dialog.
func getDialogFlags(dialogName):
	if allDialog.has(dialogName.to_lower()):
		return allDialog[dialogName.to_lower()][1]
	else:
		return 0

# A signal setup from the dialogBox calls this when it's finished to allow new instances to be created.
func unlock(_choiceValue):
	playing = false
	emit_signal("unlocked")

# A function to return important values to their initial state for a replay.
func resetValues():
	triedToGoBack = false
