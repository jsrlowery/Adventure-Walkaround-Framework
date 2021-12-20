extends TileMap

const NO_VISIBLE_PIXELS = "There are no visible pixels in the extracted image."
onready var padding = 3
onready var i = preload("res://Scenes/Interactible.tscn")

func _ready():
	for cell in get_used_cells():
		var cellID = get_cellv(cell)
		if tile_set.tile_get_shape(cellID, 0) != null:
			add_event_to_collider(cell, cellID)
		else:
			add_event_to_sprite(cell, cellID)

func add_event_to_collider(cell, cellID):
	
	# Prep the interactible instance.
	var instance = i.instance()
	
	# Translate the collider's dimensions.
	var pnts = tile_set.tile_get_shape(cellID, 0).points
	
	var xComps = []
	var yComps = []
	for p in pnts:
		xComps.append(p.x)
		yComps.append(p.y)
	
	# Find the width and height for the extents.
	var w = ((xComps.max() - xComps.min()) / 2) 
	var h = ((yComps.max() - yComps.min()) / 2) 
	
	# Calculate the center of the collider.
	var cellVector = map_to_world(cell)
	var offset = tile_set.tile_get_shape_offset(cellID, 0)
	var posX = cellVector.x + w + xComps.min() + offset.x
	var posY = cellVector.y + h + yComps.min() + offset.y
	
	# Add the calculated Shape2D to the instance, 
	# then add it to the calculated center.
	add_instance(instance, cellID, w, h, Vector2(posX, posY))

func add_event_to_sprite(cell, cellID):
	
	# Prep the instance.
	var instance = i.instance()
	
	# Extract the image's dimensions sans invis pixels.
	var texture = tile_set.tile_get_texture(cellID)
	var texRegion = tile_set.tile_get_region(cellID)
	
	if texture != null:
		var img = texture.get_data()
		
		# Record the minimum and maximum X and Y values for the image, 
		# cropping it down to the pixels with an alpha greater than 0.
		var maxCoords = Vector2.ZERO
		var minCoords = img.get_size()
		var imgP = texRegion.position
		var imgS = texRegion.size
		img.lock()
		for imgX in range(imgP.x, imgP.x + imgS.x):
			for imgY in range(imgP.y, imgP.y + imgS.y):
				var pixel = img.get_pixel(imgX, imgY)
				if pixel.a > 0:
					# Assign new max values.
					if maxCoords.x < imgX:
						maxCoords.x = imgX
					if maxCoords.y < imgY:
						maxCoords.y = imgY

					# Assign new min values.
					if minCoords.x > imgX:
						minCoords.x = imgX
					if minCoords.y > imgY:
						minCoords.y = imgY
		
		assert(!(maxCoords == Vector2.ZERO && minCoords == img.get_size()), NO_VISIBLE_PIXELS)
		
		# Find the width and height for the extents.
		var w = ((maxCoords.x - minCoords.x) / 2) 
		var h = ((maxCoords.y - minCoords.y) / 2) 
		
		# Calculate the center of the collider.
		var cellVector = map_to_world(cell)
		var offset = tile_set.tile_get_texture_offset(cellID)
		var posX = cellVector.x + offset.x + w + (minCoords.x - imgP.x)
		var posY = cellVector.y + offset.y + h + (minCoords.y - imgP.y)
		
		# Add the calculated Shape2D to the instance, 
		# then add it to the calculated center.
		add_instance(instance, cellID, w, h, Vector2(posX, posY))

# Add the instance with the given width, height and position.
func add_instance(instance, cellID, w, h, pos):
	var iBox = RectangleShape2D.new()
	if (w * h > 32^2): 
		# Larger padding for larger objects.
		iBox.extents = Vector2(w + padding * padding, h + padding * padding)
	else: 
		# Smaller padding for smaller objects.
		iBox.extents = Vector2(w + padding, h + padding)
	
	var collider = CollisionShape2D.new()
	collider.shape = iBox
	instance.add_child(collider)
	instance.position = pos
	instance.z_index = 2
	
	# The name maps to a certain dialog resource.
	var dialogName = tile_set.tile_get_name(cellID)
	var flags = Globals.getStoryManager().getDialogFlags(dialogName)
	
	instance.autotrigger = bool(flags & 1)
	instance.onetime = bool(flags & 2)
	instance.loop = bool(flags & 4)
	
	instance.dialogName = []
	instance.dialogName.append(dialogName)
	
	get_owner().call_deferred("add_child", instance)

func removeTiles(tiles):
	var toRemove = []
	for cell in get_used_cells():
		var cellID = get_cellv(cell)
		if tiles.has(tile_set.tile_get_name(cellID)):
			toRemove.append(cellID)
	
	for cellID in toRemove:
		tile_set.remove_tile(cellID)
