extends Area2D

# Int representing the char 'a'. 
const INIT_CHAR = 65

const ARRAY_SIZE_MISMATCH = "There need to be enough exit scenes for exit positions and vice versa."

export var exitScene = PoolStringArray()
export var exitPosition = PoolVector2Array()
export(Globals.Dir) var dir

onready var c = Globals.getContainer()
onready var storyManager = Globals.getStoryManager()

export var playExitMessage = true
export var exitMessageName = ""

# A reference to the player
onready var player = c.playerRequest()

# Locking variable to ensure you can't trigger the exit activation twice.
var exiting = false

# The direction that the player enters this exit.
var enteredDirection = Vector2.ZERO

# An int representing the random message to play between areas.
var randMessage = 0

signal transferring()

# Prep the random seed.
func _ready():
	randomize()
	randMessage = randi() % storyManager.totalExits
	connect("transferring", player, "whenInteracting")
	assert(exitScene.size() == exitPosition.size(), ARRAY_SIZE_MISMATCH)

# When the player enters, request whether they want to leave or not.
# If they do, transport them to a random scene from the potential exits.
func _on_Exit_body_entered(body):
	var isPlayer = body.get_name().to_lower() == "player"
	if isPlayer && !Globals.getStoryManager().playing && !exiting:
		enteredDirection = player.direction
		if playExitMessage && exitMessageName == "":
			var instance = storyManager.instanceDialogBox("Exit" + char(INIT_CHAR + randMessage))
			instance.connect("dialogFinished", self, "_performTransfer")
		elif playExitMessage:
			var instance = storyManager.instanceDialogBox(exitMessageName)
			instance.connect("dialogFinished", self, "_performTransfer")
		else:
			_performTransfer(true)

# Transfer the player from one room to another room
func _performTransfer(choiceValue):
	if choiceValue:
		exiting = true
		emit_signal("transferring")
		var rand = randi() % exitScene.size()
		c.fadeToScene(get_parent(), exitScene[rand], exitPosition[rand], dir)
	else:
		player.automaticWalk(-enteredDirection, self)

# Updates the existing message name.
func updateMessage(newMessage):
	exitMessageName = newMessage

# Clear the existing endpoints, and replace them with a new one.
func overwriteEndpoints(theScene, thePosition, theDirection):
	exitScene.resize(0)
	exitPosition.resize(0)
	dir = theDirection
	addNewEndpoint(theScene, thePosition)

# Add a new potential destinantion for the player to end up.
# Note that the container will take the focus off the player camera if
# The player is placed in a negative position.
func addNewEndpoint(theScene, thePosition):
	exitScene.append(theScene)
	exitPosition.append(thePosition)
