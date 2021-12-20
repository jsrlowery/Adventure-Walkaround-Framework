extends Area2D

# Whether or not the interactible should go off.
var iSet = true

# The name values of all interactible resources this script can call. 
export var dialogName = []

# The current dialog number we're on in dialogName.
var dialogNum = 0

# Whether this event should go off automatically upon being walked into.
export var autotrigger = false

# Whether this event should only play one time.
export var onetime = false

# Whether the dialog should loop from the last dialog back to the first.
# If not set, the dialog will increment to the last dialogName, then keep
# playing that on interaction. 
export var loop = false

# Accessing other relevant Nodes.
onready var c = Globals.getContainer()
onready var storyManager = Globals.getStoryManager()
onready var pm = c.get_node("PermanenceManager")

var player

# Connect this interactible to the player node.
func _ready():
	if onetime && pm.iLog[dialogName[dialogNum].to_lower()] > 0:
		queue_free()
	connect("input_event", self, "_interact_mobile")
	player = c.playerRequest()

# Only relevant if the interactible is set to 'autotrigger.'
# Upon the player entering the area, request from the storyManager play the set dialog.  
func autoplayOnEnter(_body):
	if(autotrigger && overlaps_body(player)):
		if (!storyManager.playing):
			_request_instance()
		
		# In the case that the storyManager is already playing some dialog,
		# Connect a signal from when the storyManager becomes unlocked to call
		# this interactible's request_instance.
		else:
			if !storyManager.is_connected("unlocked", self, "_request_instance"):
				storyManager.connect("unlocked", self, "_request_instance")
				c.playerRequest().whenInteracting()

func _input(_event):
	if(shouldCheckForInput()):
		if((Input.is_action_just_pressed("ui_accept")) && !storyManager.playing):
			_request_instance()
			iSet = false

# Interact with the linked element.
# Only works on mobile.
func _interact_mobile(_viewport, event, _shape_idx):
	if(shouldCheckForInput()):
		if Globals.MOBILE.has(OS.get_name()):
			if((event is InputEventMouseButton && event.pressed) && !storyManager.playing):
				_request_instance()

func _request_instance():
	if $Notification.modulate.a > 0:
		$Notification/Fade.play("Fade Out")
	
	if loop && dialogNum >= dialogName.size():
		dialogNum = 0
	
	if dialogNum < dialogName.size():
		var instance = storyManager.instanceDialogBox(dialogName[dialogNum])
		if instance != null:
			pm.logInteraction(dialogName[dialogNum])
			pm.tickHintBingoBox(dialogName[dialogNum])
			dialogNum += 1
			if onetime && dialogNum >= dialogName.size():
				instance.connect("dialogFinished", self, "signalQueueFree")

# Helper function to gather together the requirements to check for input.
func shouldCheckForInput():
	return iSet && !autotrigger && overlaps_body(player)

func signalQueueFree(_choiceValue):
	queue_free()

# Upon exit, set the interaction again. 
func _onExited(body):
	iSet = true
