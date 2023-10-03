extends RayCast3D


var collider
var current_collider
@onready var label = $"../../../../HUD/InteractionLabel"

func _ready():
	set_interaction_text("")

func _process(delta):
	collider = get_collider()

	if is_colliding() and collider is Interactable:
		label.visible = true
		if current_collider != collider:
			current_collider = collider
			set_interaction_text(current_collider.get_interaction_text())
		
		if Input.is_action_just_pressed("Interact"):
			current_collider.interact()
			set_interaction_text(current_collider.get_interaction_text())
		
	elif current_collider:
		current_collider = null 
		
	else:
		label.visible = false

func set_interaction_text(text):
	if !text:
		label.visible = false
		label.set_text("")
	else:
		var interact_key = OS.get_keycode_string(InputMap.action_get_events("Interact")[0].physical_keycode)
		print(interact_key)
		label.set_text("Press %s to %s" % [interact_key, text])
		label.visible = true
				
