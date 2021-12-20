extends Node2D

# Object to store data on all dialog with 'hints' within it. 
# Each array stored is a 'hintBingoBox' and they are formatted as such:
# [hint, hits]
# Hints being 'what to display if the player missed the interactible.'
# Hits being 'how many times did the player interact with this object?'
var hintBingo = {}
var initHintBingo = {}

# Tracks interactions performed with any particular Interactible.
var iLog = {}
var initILog = {}

# Tracks the number of times a player has swapped from one room to another.
var roomsEntered = 0

# Logs an interaction with an Interactible.
func logInteraction(name):
	iLog[name.to_lower()] += 1

# Records new Interactibles.
func newInteraction(name):
	iLog[name.to_lower()] = 0
	initILog[name.to_lower()] = 0

# Notes whether an 'important,' optional bit of dialog has been tracked.
func tickHintBingoBox(name):
	if hintBingo.has(name.to_lower()):
		hintBingo[name.to_lower()][1] += 1

# Records a new dialog with hint information.
func newHintBingoBox(name, hint):
	hintBingo[name.to_lower()] = [hint, 0]
	initHintBingo[name.to_lower()] = [hint, 0]

# Increments the roomsEntered.
func tickRoomsEntered():
	roomsEntered += 1
	Globals.started = true

# Returns the rooms entered.
func getRoomsEntered():
	return roomsEntered

# Set all values back to initial.
func resetValues():
	iLog = initILog
	#hintBingo = initHintBingo 
	roomsEntered = 0
