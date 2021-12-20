
	#### Globals ####

extends Node2D

const MOBILE = ["Android", "iOS"]

# Enumerates the player's idle directions.
enum Dir {
	UP,
	DOWN,
	LEFT,
	RIGHT,
}

var debugMode = false

var started = false

onready var container = get_tree().get_root().get_child(1)
onready var storyManager = container.get_node("StoryManager")
onready var exitManager = container.get_node("ExitManager")

# Returns the container node holding everything.
func getContainer():
	return container

# Returns the story manager.
func getStoryManager():
	return storyManager

# Returns the exit manager.
func getExitManager():
	return exitManager
