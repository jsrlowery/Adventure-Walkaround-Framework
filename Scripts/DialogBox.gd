# Adapted from Afely's Youtube tutorial on Text Boxes.
# https://www.youtube.com/watch?v=GzPvN5wsp7Y
# Designed to loop through exactly one JSON file, block by block.
# Afterwards, it cleans itself up.

extends CanvasLayer

const SPEED_MOD = 5.0

# An array that stores the JSON values containing our dialog.
var dialog

# The current dialog line we're on.
var line = 0

# How much faster speedy text should go.
var textSpeedMultiplier = 1.0

# Checks whether the accept button was just pressed to activate this dialog.
var dialogJustActivated = false

# Whether the current line is finished or not.
var lineFinished = false

# Whether we're currently doubling the speed.
var isSpedUp = false

# Whether we're playing a dramatic story scene.
var isDramatic = false

# Whether we're making a decision at the end of this.
var choiceData = null

# If the choice intends to return a value, store it here.
var choiceValue = null

# Map storing points of speed change for the dialog.
# {<char>: <speed>}
var speedChanges = {}

# Enumerates the text speed.
enum LetterSpeeds {
	FAST,
	NORMAL,
	SLOW,
}

# The speed mode we're currently experiencing.
var currentSpeedMode = LetterSpeeds.NORMAL

# Array that represents preset speeds
var textSpeed = [0.001, 0.02, 0.22]

# A RegEx designed to find tags for speed changes.
onready var findSpeedChanges = RegEx.new()

# A RegEx designed to find blankspace
onready var findBS = RegEx.new()

# The top-level node.
onready var c = Globals.getContainer()

signal dialogFinished()
signal dramaticFinished()
signal dialogPlaying()
signal dialogPaused()

func _ready():
	findSpeedChanges.compile("\\[\/?(fast|slow)]")
	findBS.compile("\\s")
	connect("dialogFinished", c.playerRequest(), "finishedInteracting")
	connect("dramaticFinished", c.playerRequest().get_node("Light2D"), "whenFinished")
	connect("dramaticFinished", c.get_node("AmbientLighting"), "whenFinished")
	connect("dramaticFinished", c.playerRequest(), "finishedBeingDramatic")
	$Timer.wait_time = textSpeed[LetterSpeeds.NORMAL]

# Checks on every call that the text loads and that the next phrase can be caught. 
func _process(_delta):
	var jp = Input.is_action_just_pressed("ui_accept")
	
	# Captures the first input so that dialog isn't sped up.
	if !dialogJustActivated:
		dialogJustActivated = true
		
	# Captures the input to move to the next phrase.
	elif jp && lineFinished && dialog:
			nextPhrase()
			
	# Slow down the text if it's currently sped up.
	elif jp && isSpedUp:
		normaltime()
		
	# Speed up the text if it's currently not sped up.
	elif jp && !isSpedUp:
		fastfoward()

# Called from an interactible or event to start a segment of dialog.
func begin(newDialog):
	if (!dialog):
		dialog = newDialog
		nextPhrase()

# Processes the next phrase, queuing the DialogBox to free itself if there's nothing else to read.
func nextPhrase():
	
	# Check if we've reached the end of the dialog
	if checkDialogEnd():
		return
	
	# Begin dialog setup.
	setupTheme()
	phrasePrep()
	
	# Read out the dialog at the previously set speed.
	while $DialogPanel/Text.visible_characters < len($DialogPanel/Text.text):
		if (speedChanges.has($DialogPanel/Text.visible_characters)):
			adjustSpeed(speedChanges[$DialogPanel/Text.visible_characters])
			isSpedUp = false
		
		# Increment the visible characters to show one more,
		# then check if we should play a letter sound.
		$DialogPanel/Text.visible_characters += 1
		var c = $DialogPanel/Text.bbcode_text[$DialogPanel/Text.visible_characters - 1]
		var query = findBS.search(c)
		if query == null:
			emit_signal("dialogPlaying")
		
		$Timer.start()
		yield($Timer, "timeout")

	phraseCleanup()

# Helper function to prep the theme of the window.
func setupTheme():
	var character = dialog[line]["Name"].to_lower()
	
	# Update character's talk sound and voice range.
	$TalkSound.stream = load("res://Assets/" + character + "_sound.ogg")
	$TalkSound.pitchMin = $TalkSound.voiceRange[character][0]
	$TalkSound.pitchRange = $TalkSound.voiceRange[character][1] 
	
	# Check if the resource contained an animation to play on this line. 
	# If so, play it.
	if dialog[line].has("Anim"):
		for effect in dialog[line]["Anim"]:
			var actor = c.find_node(effect[0], true, false)
			actor.play(effect[1])
	
	# Check if the resource contained a SFX to play on this line. 
	# If so, play it.
	if dialog[line].has("SFX"):
		var sfx = dialog[line]["SFX"]
		var source = c.find_node(sfx, true, false)
		source.play()
	
	if dialog[line].has("OnStart"):
		var calls = dialog[line]["OnStart"]
		for c in calls:
			callTo(c[0], c[1], c[2])
	
	# Update the dialog panel with the character's theme.
	$DialogPanel.theme = load("res://Assets/Themes/" + character + "_theme.tres")

# Returns true if the dialog has reached its end to prompt a skip.
# If there's a choice, activates it at the end of the dialog.
func checkDialogEnd():
	var finalLine = line >= len(dialog)
	
	# If there is a choice associated with this dialog, open it now.
	if finalLine && choiceData != null:
		$DialogPanel/ChoicePanel.theme = $DialogPanel.theme
		
		# Open the Dialogbox and wait for a selected choice.
		$DialogPanel/ChoicePanel.choiceData = choiceData
		choiceValue = yield($DialogPanel/ChoicePanel.requestChoice(), "completed")
		choiceData = null
		return true
		
	# Otherwise, if we're at the final line, 
	# send the last signals out and release the node.
	elif finalLine:
		var theSignal = ""
		if !isDramatic:
			theSignal = "dialogFinished"
		else:
			theSignal = "dramaticFinished"
			c.player.walkTime = 0
		emit_signal(theSignal, choiceValue)
			
		queue_free()
		return true
	else:
		return false

# Helper function to prep the data after we've begun displaying the line.
func phrasePrep():
	lineFinished = false
	var theLine = dialog[line]["Text"]
	var result = findSpeedChanges.search_all(theLine)
	
	# Store the speeds and places to apply them.
	for r in result:
		var textSpeed = 1
		if ("fast" in r.strings[1]):
			textSpeed = 0
		elif ("slow" in r.strings[1]):
			textSpeed = 2
			
		if ("\/" in r.strings[0]):
			speedChanges[r.get_start() - (r.strings[0].length() - 1)] = 1
		else:
			speedChanges[r.get_start()] = textSpeed
		
		# Clear the text from the 
		theLine = findSpeedChanges.sub(theLine, "")
	
	$DialogPanel/Text.bbcode_text = theLine
	$DialogPanel/Text.visible_characters = 0

# Helper function to cleanup the data after we've finished displaying a line.
func phraseCleanup():
	emit_signal("dialogPaused")
	speedChanges = {}
	lineFinished = true
	normaltime()
	line += 1
	adjustSpeed(LetterSpeeds.NORMAL)

# Helper fucntion to adjust the text's speed.
func adjustSpeed(speedMode):
	currentSpeedMode = speedMode
	$Timer.wait_time = textSpeed[speedMode] * textSpeedMultiplier

#Helper function to call methods when a line requests it.
func callTo(target, method, args):
	var tNode = c.find_node(target, true, false)
	if tNode != null:
		tNode.callv(method, args)
	else:
		assert(false, "No node to call on.")

func fastfoward():
	$FastForward.visible = true
	textSpeedMultiplier /= SPEED_MOD
	isSpedUp = true
	adjustSpeed(currentSpeedMode)

func normaltime():
	$FastForward.visible = false
	textSpeedMultiplier = 1
	isSpedUp = false
	adjustSpeed(currentSpeedMode)
