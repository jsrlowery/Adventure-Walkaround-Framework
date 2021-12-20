extends AnimationPlayer

onready var c = Globals.getContainer()

# Retrieves the color of the animated to update the first keyframe of the animation.
func matchKeyframeColor(animationName, trackPath, animatedName):
	
	# Find our targets.
	var animated = c.find_node(animatedName, true, false)
	var animation = get_animation(animationName)
	var trackID = animation.find_track(trackPath)
	
	# Retrieve the color, then update the key.
	animation.track_set_key_value(trackID, 0, animated.color)
