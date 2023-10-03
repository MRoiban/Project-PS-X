extends Node3D

@onready var animation = $CSGSphere3D/AnimationPlayer
@onready var aura = $CSGSphere3D
@export var item_path = ""
var item
var item_instance


func _ready():
	animation.play("new_animation")
	if item_path != "":
		item = load(item_path)
		item_instance = item.instantiate()
		add_child(item_instance)


func _process(_delta):
	if item_path != "" and len(self.get_children()) > 1:
		self.get_children()[1].position = aura.position
