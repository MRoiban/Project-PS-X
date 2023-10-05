extends Control

var UNPAUSED = false
var PAUSED = false

# func _physics_process(delta):
# 	if Input.is_action_just_pressed("pause") and PAUSED:
# 		get_tree().paused = false
# 		UNPAUSED = true

func _on_quit_to_desktop_pressed():
	get_tree().quit()

func is_unpaused():
	return UNPAUSED

func revert():
	UNPAUSED = not(UNPAUSED)

func set_paused(state: bool):
	PAUSED = state

func _on_resume_pressed():
	get_tree().paused = false
	UNPAUSED = true
	# Input.action_press("pause")
