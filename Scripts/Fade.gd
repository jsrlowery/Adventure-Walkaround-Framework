extends AnimationPlayer

func _on_Interactible_body_entered(body):
	if body.name == "Player" && !get_owner().autotrigger:
		play("Fade In")

func _on_Interactible_body_exited(body):
	if body.name == "Player":
		play("Fade Out")
