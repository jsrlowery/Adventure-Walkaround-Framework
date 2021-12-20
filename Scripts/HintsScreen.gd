extends Node2D

var missedAll = "Look buddy, I dunno how to help you. Somehow you got through this and missed them all. I'm assuming you did this on purpose but in case, somehow, you didn't... approach stuff with an arrow and interact with it. That'd be 'z' on desktop and tapping on mobile. \n\nIf you're here on purpose though, uh, good job??"
var foundAll = "[center]Nothing left to find! Good job![/center]"
onready var pm = Globals.getContainer().get_node("PermanenceManager")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Count up hints found.
	var hints = ""
	var firstHit = true
	var missed = 0
	for k in pm.hintBingo.keys():
		if firstHit && pm.hintBingo[k][1] == 0:
			hints += pm.hintBingo[k][0]
			missed += 1
			firstHit = false
		elif pm.hintBingo[k][1] == 0:
			hints += "\n" + pm.hintBingo[k][0]
			missed += 1
	
	# Update the text based on data retrieved above.
	var hintText = $ScreenSize/ColorRect/Hints
	if missed >= pm.hintBingo.size():
		hintText.bbcode_text = missedAll
	elif missed == 0:
		hintText.bbcode_text = foundAll
	else:
		var format = {"hints": hints}
		var formatted = hintText.bbcode_text.format(format)
		hintText.bbcode_text = formatted
