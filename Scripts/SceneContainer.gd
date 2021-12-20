extends Control

const DIR_ANIMS = ["idle_up", "idle_down", "idle_left", "idle_right"]

var firstCall = true
var playable = false
var cProps1 = {}
var cProps2 = {}
var player

func _ready():	
	# Hide the mouse while on the game if on mobile..
	if Globals.MOBILE.has(OS.get_name()):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

# Transition the player to another scene.
func fadeToScene(callerScene, scene, playerPos=null, pDir=0):
	$TransitionPlayer.play("FadeOut")
	yield($TransitionPlayer, "animation_finished")
	
	var i = load(scene).instance()
	add_child_below_node(callerScene, i)
	Globals.exitManager.locateExits(i)

	_extractPlayer()
	callerScene.queue_free()
	_reparentPlayer(i)
	if playerPos.x < 0 || playerPos.y < 0:
		player.get_node("Camera2D").current = false
		$MenuCamera.current = true
		playable = false
	else:
		playable = true
	player.position = playerPos
	get_node("FlairManager").afterPlayerSituated()
	player.finishedInteracting(null)
	player.get_node("AnimationPlayer").play(DIR_ANIMS[pDir])

	if firstCall:
		$AmbientMusic.play()
		$StoryManager.connect_player(player)
		firstCall = false
	
	if playable:
		$AmbientLighting.visible = true
		$MenuCamera.current = false
		player.find_node("Camera2D").current = true
		$TransitionPlayer.play("FadeIn")
	else:
		$TransitionPlayer.play("FadeInToMenu")

# Returns the player instance when its ass is firmly planted somewhere.
# The node gets around, after all.
func playerRequest():
	player = self.find_node("Player", true, false)
	if !player.is_inside_tree():
		yield(player, "tree_entered")
	return player

# Returns the player and makes it a direct child to preserve the instance between scenes.
func _extractPlayer():
	player = self.find_node("Player", true, false)
	player.get_parent().remove_child(player)
	return player

# Move the player from one node to another, then increase the number of rooms entered.
func _reparentPlayer(newParent):
	var ysort = newParent.find_node("SortedMap")
	if ysort != null:
		ysort.add_child_below_node(get_child(0), player)
	else:
		newParent.add_child_below_node(get_child(0), player)
	get_node("PermanenceManager").tickRoomsEntered()
	return player

# For debug purposes.
func getCurrentCamera2D():
	var viewport = get_viewport()
	if not viewport:
		return null
	var camerasGroupName = "__cameras_%d" % viewport.get_viewport_rid().get_id()
	var cameras = get_tree().get_nodes_in_group(camerasGroupName)
	for camera in cameras:
		if camera is Camera2D and camera.current:
			return camera
	return null
