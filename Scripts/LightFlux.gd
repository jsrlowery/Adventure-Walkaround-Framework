extends Light2D

# A value indicating what the strength should aim toward.
var targetStrength = 1.1

# The strength the light begins at.
var strength = 0

# The rate the light pulses.
export var initStrength = 1.1
export var strengthShift = 0.001
export var phaseShift = 0.008

onready var phaseMin = 0.8
onready var phaseMax = 1.3
onready var phase = phaseMin

func _ready():
	energy = (phaseMax + phaseMin) / 2
	strength = initStrength

func _physics_process(_delta):
	if phase > phaseMax || phase < phaseMin:
		phaseShift = -phaseShift
	phase += phaseShift
	
	if strength > targetStrength:
		strength -= strengthShift
	elif strength < targetStrength:
		strength += strengthShift
	
	energy = sin(phase) * strength

# Holding off on this for now...
# Work on it later, but it's still all properly connected.
func whenDramatic():
	targetStrength *= 0.6

func whenFinished(_choiceValue):
	targetStrength = initStrength
