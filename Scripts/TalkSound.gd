extends AudioStreamPlayer

# Variable to map each character's sound pitch shifts.
# [pitchMin, pitchRange]
var voiceRange = {
	"trina": [0.9, 0.35],
	"leo": [0.4, 0.5],
	"hunter": [0.0, 0.7],
}

var pitchMin = 0
var pitchRange = 1

func _ready():
	randomize()

func _while_text_playing():
	set_pitch_scale(randf() * pitchRange + pitchMin)
	play()

func _when_text_ends():
	stop()
