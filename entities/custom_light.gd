extends OmniLight3D

@export var energy: float
@export var size: float
@export var model = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	light_energy = energy
	light_size = size


