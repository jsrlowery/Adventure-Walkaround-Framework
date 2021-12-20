extends Node2D

# Anything within this script is miscillany that adds a lil something something
# to the game. Not strictly necessary, but I feel that collecting this in
# one place should simplify managing it later.

# The manager for handling permanence.
onready var pm = get_node("../PermanenceManager")

# The manager for handling exits.
onready var em = get_node("../ExitManager")

# Called after the sceneContainer has added the new room instance to the scene tree
# And then added the player into it.
func afterPlayerSituated():
	var closestExit = em.getClosestExit()
	if pm.getRoomsEntered() == 2 && closestExit != null:
		closestExit.connect("transferring", self, "cantGoBack")

# Adds a nice little note for anyone that tries to walk back to the hallway room.
func cantGoBack():
	yield(get_node("../TransitionPlayer"), "animation_finished")
	Globals.getStoryManager().instanceDialogBox("CantGoBack")
