extends Node2D

onready var pm = Globals.getContainer().get_node("PermanenceManager")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Count up hints found.
	var totalFound = 0
	for k in pm.hintBingo.keys():
		if pm.hintBingo[k][1] > 0:
			totalFound += 1
	
	var iFound = $ScreenSize/ColorRect/InteractiblesFound
	var format = {"found": totalFound, "total": pm.hintBingo.size()}
	var formatted = iFound.bbcode_text.format(format)
	iFound.bbcode_text = formatted
