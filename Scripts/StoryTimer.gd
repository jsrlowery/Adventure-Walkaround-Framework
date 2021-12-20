extends Timer

# Int representing the char 'a'. 
const INIT_CHAR = 65

# Number of checks to perform before counting the step delay.
const STORY_CHECKS = 4

# Alternate wait limitation
const STORY_STEP_DELAY = 20000

# A counter checking how many times the timer has gone off to check story reqs.
var storyTimer = 0

# Int representing the current story step.
var storyStep = 0

# If dialog is playing, we shouldn't be checking for dialog progression.
var locked = false

# The path to the ending scene.
var endingScene = "res://Scenes/Rooms/EndScreen.tscn"

# Preload the StoryManager for instancing.
onready var storyManager = get_node("../StoryManager")
onready var em = get_node("../ExitManager")
onready var c = Globals.getContainer()

func _process(_delta):
	
	# Debug feature.
	if Globals.debugMode && timedStoryUntold() && Input.is_action_pressed("ui_cancel"):
		storyManager.instanceDialogBox("Story" + char(INIT_CHAR + storyStep), false)
		storyTimer = 0
		storyStep += 1
		
		# Restart the timer.
		start()

func _on_StoryTimer_timeout():
	if timedStoryUntold():
		
		# Check whether conditions have been met to play the next story dialog.
		var requisiteChecks = storyTimer >= STORY_CHECKS
		var walkedEnough = c.player.walkTime > STORY_STEP_DELAY
		if requisiteChecks && walkedEnough:
			storyManager.instanceDialogBox("Story" + char(INIT_CHAR + storyStep), false)
			storyTimer = 0
			storyStep += 1
		else:
			storyTimer += 1
		
		# Restart the timer.
		start()
	elif shouldProgressStory():
		
		# Ensure the exits are updated.
		for e in em.exits:
			e.updateMessage("WrongPath")
		var northmostExit = em.getExtremeExit(em.R.Low_Y)
		northmostExit.updateMessage("CorrectPath")
		northmostExit.overwriteEndpoints(endingScene, Vector2(-10, -10), Globals.Dir.DOWN)
		start()

func timedStoryUntold():
	return storyStep < storyManager.totalStory && shouldProgressStory()

func shouldProgressStory():
	var enteredTheLoop = get_node("../PermanenceManager").roomsEntered > 1
	return Globals.started && c.playable && enteredTheLoop && !locked

func unlock(_choiceValue):
	locked = false

# Reset the story values so that the story can be played again.
func resetValues():
	storyTimer = 0
	storyStep = 0
