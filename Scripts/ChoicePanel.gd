extends Panel

# The unprocessed choice data, 
# indicating what to display and what to do in different cases.
var choiceData = null

# The raw, unfiltered choice text.
var choiceText = ""

# The distinct options currently being appraised.
var optionStrings = PoolStringArray()

# The current option in focus.
var focusOption = 0

# Bool indicating we're selecting a choice.
var awaitingSelection = false

# The choice slected.
var theChoice = -1

signal choiceSelected()
signal choiceProcessed()


# Await player input if awaitingSelection...
func _input(_event):
	if awaitingSelection && Input.is_action_pressed("ui_down"):
		if focusOption < optionStrings.size() - 1:
			focusOption += 1
		else:
			focusOption = 0
		$SelectSound.play()
		signalFocusOption()
	elif awaitingSelection && Input.is_action_pressed("ui_up"):
		if focusOption > 0:
			focusOption -= 1
		else: 
			focusOption = optionStrings.size() - 1
		$SelectSound.play()
		signalFocusOption()
	elif awaitingSelection && Input.is_action_pressed("ui_accept"):
		theChoice = focusOption
		emit_signal("choiceSelected")


# Wait for the player to request something.
func requestChoice():
	
	# Setup the choices, then open the dialogBox.
	var effectPlayer = get_node("../../DialogBoxEffects")
	setupChoices()
	signalFocusOption()
	awaitingSelection = true
	effectPlayer.play("Open")
	
	# Wait for the player to choose something.
	yield(self, "choiceSelected")
	effectPlayer.play("Close")
	
	# Now that we know the choice, do what's linked to it.
	if choiceData[theChoice][1].begins_with("/"):
		
		# Just return the value to the caller.
		if choiceData[theChoice][1].ends_with("return"):
			emit_signal("choiceProcessed")
			return choiceData[theChoice][3]
	else:
		# TODO:
		# This is where you'd pass in function calls, but...
		# You don't need that yet. So like... that's for future me.
		# If you're future me, I hope the infrastructure isn't as
		# slapdash as it currently feels.
		pass


# Take the data and perform setup on the choices.
func setupChoices():
	var firstOption = true
	for option in choiceData:
		if firstOption:
			choiceText = option[0]
			firstOption = false
		else:
			choiceText = choiceText + "\n" + option[0]
		optionStrings.append(option[0])
	$Text.bbcode_text = choiceText


# Modify the bbcode to illustrate the option of interest.
func signalFocusOption():
	var focusFormat = "> [wave]%s[/wave]"
	var focusText = focusFormat % optionStrings[focusOption]
	$Text.bbcode_text = choiceText.replace(optionStrings[focusOption], focusText)


