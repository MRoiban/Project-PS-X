extends Node3D


var GRAVITY = 9.8
@export var speed = 0.0

@onready var mesh = $ammo_9mm_free
@onready var ray = $RayCast3D
@onready var particle = $GPUParticles3D
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Adjust this value as needed



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = transform.basis * Vector3(0, -GRAVITY, -speed) * delta
	var old_position = position
	position += velocity
	var bullet_angle = atan2(abs(position.y - old_position.y), abs(position.x - old_position.x))
	print(bullet_angle*(180/PI))
	
	if ray.is_colliding():
		mesh.visible = false
		particle.emitting = true
		await get_tree().create_timer(1.0).timeout
		queue_free()


func _on_timer_timeout():
	queue_free()
