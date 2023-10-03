extends Node3D

const EXIT = 4194305

@export var bullet_count = 10
@export var stock_count = 2

var speed
var direction
@export var WALK_SPEED = 4.0
@export var SPRINT_SPEED = 8.0
@export var JUMP_VELOCITY = 4.5
@export var gravity = 9.8

@export var SENSITIVITY_X = 0.005
@export var SENSITIVITY_Y = 0.005

@export var BOB_FREQUENCY = 2.0
@export var BOB_AMPLITUDE = 0.08
var t_BOB = 0.0

@export var BASE_FOV = 85
@export var FOV_CHANGE = 1.5

@onready var mob = $Body


func _physics_process(delta):
	player_movement(delta)


func player_movement(time):
	if not mob.is_on_floor():
		mob.velocity.y -= gravity * time

	mob.move_and_slide()
