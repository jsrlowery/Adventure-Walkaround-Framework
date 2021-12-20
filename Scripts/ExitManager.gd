extends Node2D

# Relevance enum.
# Used to retrieve extreme exits.
enum R {
	High_X,
	Low_X,
	High_Y,
	Low_Y
}

# Array containing the exits within the given node.
var exits = []

# Path to the exit script for comparison against other nodes.
var scriptPath = "res://Scripts/Exit.gd"

# Seeks the nodes within the given parent that have 'exit.gd' scripts attached.
func locateExits(parent):
	
	# Clears the array first.
	# If we're entering a new node, we need a fresh set of exits.
	exits.clear()
	
	# Seek all child nodes with the Exit script attached.
	for child in parent.get_children():
		var hasScript = child.get_script() != null
		if hasScript && child.get_script().resource_path == scriptPath:
			exits.append(child)

# Retrieves exits at points of greatest extremity.
func getExtremeExit(relevant):
	if exits.size() > 0:
		
		# Extract the x and y components of the position vectors.
		var yComps = {}
		var xComps = {}
		for e in exits:
			var offset = 0
			while xComps.get(e.position.x) != null: offset += 0.01
			xComps[e.position.x + offset] = e
			
			offset = 0
			while yComps.get(e.position.y) != null: offset += 0.01
			yComps[e.position.y + offset] = e
		
		# Determine the return information depending on what is 'relevant.'
		match (relevant):
			R.High_X:
				return xComps[xComps.keys().max()]
			R.Low_X:
				return xComps[xComps.keys().min()]
			R.High_Y:
				return yComps[yComps.keys().max()]
			R.Low_Y:
				return yComps[yComps.keys().min()]
			_:
				assert(false, "Invalid input for function getExtremeExit: " + str(relevant))

# Retrieves exit closest to the player.
func getClosestExit():
	if exits.size() > 0:
		var player = Globals.getContainer().playerRequest()
		var distances = {}
		for e in exits:
			distances[player.position.distance_to(e.position)] = e
		return distances[distances.keys().min()]
	else:
		return null
