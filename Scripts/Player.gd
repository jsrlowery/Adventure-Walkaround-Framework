extends KinematicBody2D

const TO_DISPLAY_HINT = 10

var speed = 60
var direction = Vector2.ZERO
var canMove = true
var hasMoved = false
var isDramatic = false
var timeStart = 0
var hintSeen = false
var timeDifferential = 0
var autoMove = false

# Time elapsed walking.
var walkTime = 0

func _ready():
	if Globals.debugMode:
		speed = 200
		
	timeStart = OS.get_unix_time()

func _physics_process(delta):
	
	# Display a movement hint if the player hasn't moved for the hint time.
	if !hasMoved && !hintSeen && timeStart + TO_DISPLAY_HINT < OS.get_unix_time():
		if Globals.MOBILE.has(OS.get_name()):
			$TouchscreenHelp/Fade.play("Fade In")
		else:
			$KeyboardHelp/Fade.play("Fade In")
		hintSeen = true
	
	if canMove:
		if Globals.MOBILE.has(OS.get_name()):
			_walk_mobile()
		elif !autoMove:
			_walk()
		else:
			_playWalkAnimation()

func _walk_mobile():
	direction = Vector2.ZERO
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		direction = get_global_mouse_position() - position
	direction = direction.normalized()
	
	# Check if the player has moved at all.
	if !hasMoved && direction > Vector2.ZERO:
		hasMoved = true
		if hintSeen:
			$TouchscreenHelp/Fade.play("Fade Out")
		
	_playWalkAnimation()

# Walk for most versions of the computer.
func _walk():
	direction = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		direction.x += 1.0
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1.0
	if Input.is_action_pressed("ui_down"):
		direction.y += 1.0
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1.0
	direction = direction.normalized()
	
	# Check if the player has moved at all.
	if !hasMoved && direction.abs() > Vector2.ZERO:
		hasMoved = true
		if hintSeen:
			$KeyboardHelp/Fade.play("Fade Out")
	
	_playWalkAnimation()

func _playWalkAnimation():
	if direction != Vector2.ZERO:
		$AnimationTree["parameters/playback"].travel("Walk")
		$AnimationTree["parameters/Idle/blend_position"] = direction
		$AnimationTree["parameters/Walk/blend_position"] = direction
		move_and_slide(direction * speed)
		
		# Increment walkTime to progress story elements.
		walkTime += OS.get_ticks_msec() - timeDifferential
	else:
		$AnimationTree["parameters/playback"].travel("Idle")
	timeDifferential = OS.get_ticks_msec()

# Signal that is automatically connected to all interactibles in the scene.
# Called when interacting with a Dialog and pauses movement.
func whenInteracting():
	$AnimationTree["parameters/playback"].travel("Idle")
	canMove = false

# Signal that is automatically connected to the story manager on a story-scene.
func whenDramatic():
	isDramatic = true
	speed /= 2

# Signal that is called after a story-scene.
func finishedBeingDramatic(_choiceValue):
	isDramatic = false
	speed *= 2

# Signal that is called when the dialogBox has finished.
func finishedInteracting(_choiceValue):
	canMove = true

# Available for connection to various signals to change the speed.
func updateSpeed(theSpeed):
	speed = theSpeed

# Used when resetting the game.
func resetValues():
	walkTime = 0

# A walk called not from player input.
func automaticWalk(newDirection, caller):
	direction = newDirection
	autoMove = true
	caller.connect("body_exited", self, "finishAutoWalk")

# Ends autowalk.
func finishAutoWalk(newDirection):
	direction = Vector2.ZERO
	autoMove = false
