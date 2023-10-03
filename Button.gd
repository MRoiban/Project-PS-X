extends Interactable

@onready var truck_green = $"../TruckGreen"
@onready var button = $"."

var state = false

func interact():
	state = !state
	button.visible = !state	
	truck_green.visible = !state
	
	
func get_interaction_text():
	return "Hide" if !state else "Unhide"

