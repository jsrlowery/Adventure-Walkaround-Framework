extends CanvasModulate

var isDramatic = false

func whenDramatic():
	isDramatic = true
	if get_node("../TransitionPlayer").is_playing():
		yield(get_node("../TransitionPlayer"), "animation_finished")
	get_node("../EffectPlayer").play("darken")

func whenFinished(_choiceValue):
	if isDramatic:
		get_node("../EffectPlayer").play("neutral")
		isDramatic = false
