extends CharacterBody3D

# KEY DEFINITIONS
const EXIT = 4194305
# ------------------------------------------------------------------

# WEAPONS PROPERTIES
@export var bullet_count = 10
@export var stock_count = 2
@export var grenade_count = 5

var GRENADE = false
var GUN = true
# ------------------------------------------------------------------

# MOVEMENT PROPERTIES
var speed
var direction
var walking = false
var sprinting = false
var sliding = false
var crouching = false
var free_looking = false
var normal_depth = 0.4

@export var WALK_SPEED = 4.0
@export var CROUCH_SPEED = 2.0
@export var CROUCH_DEPTH = 0.0
@export var SPRINT_SPEED = 8.0
@export var JUMP_VELOCITY = 4.5
@export var gravity = 9.8
# ------------------------------------------------------------------

# CAMERA PROPERTIES
@export var SENSITIVITY_X = 0.005
@export var SENSITIVITY_Y = 0.005
@export var BOB_FREQUENCY = 2.0
@export var BOB_AMPLITUDE = 0.08

var t_BOB = 0.0

@export var BASE_FOV = 85
@export var FOV_CHANGE = 1.5
# ------------------------------------------------------------------

# RESSOURCES
@onready var body = $"."
@onready var head = $Neck/Head
@onready var neck = $"Neck"
@onready var camera = $Neck/Head/Camera3D
@onready var hand = $Neck/Head/Camera3D/Glock
@onready var gun_model = $Neck/Head/Camera3D/Glock/Model
@onready var grenade_model = $Neck/Head/Camera3D/Glock/Grenade
@onready var glock_animation = $Neck/Head/Camera3D/Glock/AnimationPlayer
@onready var glock_barrel = $Neck/Head/Camera3D/Glock/Model/RayCast3D
@onready var gun_stats_stock = $HUD/Weapon_Stats/Gun_Stats/Stock
@onready var gun_stats_bullets = $HUD/Weapon_Stats/Gun_Stats/Bullets
@onready var grenade_stats = $HUD/Weapon_Stats/Grenades
@onready var gun_stats = $HUD/Weapon_Stats/Gun_Stats
@onready var blood = $HUD/Blood
@onready var pause = $"Pause Menu"
@onready var hud = $HUD
# ------------------------------------------------------------------

var GLOBAL_TIME
var bullet = load("res://bullet.tscn")
var grenade = load("res://grenade.tscn")
var instance_bullet
var instance_grenade


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	gun_stats_bullets.text = str(bullet_count) if bullet_count >= 10 else "0" + str(bullet_count)
	gun_stats_stock.text = str(stock_count) 
	grenade_stats.text = str(grenade_count) if grenade_count >= 10 else "0" + str(grenade_count)
	pause.visible = false

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		body.rotate_y(-event.relative.x * SENSITIVITY_Y)
		camera.rotate_x(-event.relative.y * SENSITIVITY_X)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-50), deg_to_rad(60))
		camera.rotation.y = clamp(camera.rotation.y, deg_to_rad(0), deg_to_rad(0))
		camera.rotation.z = clamp(camera.rotation.z, deg_to_rad(0), deg_to_rad(0))
		if free_looking:
			head.rotate_y(-event.relative.x * SENSITIVITY_Y)
	else:
		head.rotation = lerp(head.rotation, Vector3(0, 0, 0), GLOBAL_TIME * 1.5)



func _physics_process(delta):
	GLOBAL_TIME = delta
	player_movement(delta)

	shooting() if GUN else grenade_throw()

	if Input.is_physical_key_pressed(KEY_5):
		blood.visible = true
	elif Input.is_physical_key_pressed(KEY_6):
		blood.visible = false
	elif Input.is_physical_key_pressed(KEY_1):
		GRENADE = false
		GUN = true
	elif Input.is_physical_key_pressed(KEY_2):
		GRENADE = true
		GUN = false
	
	if Input.is_action_just_pressed("pause"):
		var flag = false if pause.visible else true
		pause.set_paused(true)
		pause.visible = flag
		hud.visible = not(flag)
		get_tree().paused = flag
		if flag:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif pause.is_unpaused():
		pause.visible = false
		hud.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		pause.revert()
		pause.set_paused(false)


func player_movement(time):
	direction = direction_vector()
	if not is_on_floor():
		velocity.y -= gravity * time

	jump()
	sprint()
	crouch(10, time)
	free_look()
	velocity = _movement(velocity, direction, time)
	_head_movement(velocity, time)
	move_and_slide()


func label_weapon():
	if GRENADE:
		grenade_stats.visible = true
		gun_stats.visible = false
	elif GUN:
		grenade_stats.visible = false
		gun_stats.visible = true


func free_look():
	if Input.is_action_pressed("free_look"):
		free_looking = true
	else:
		free_looking = false


func crouch(lerp_speed, time):
	if Input.is_action_pressed("crouch"):
		neck.position.y = lerp(neck.position.y, CROUCH_DEPTH, time * lerp_speed)
		speed = CROUCH_SPEED
		crouching = true
	else:
		neck.position.y = lerp(neck.position.y, normal_depth, time * lerp_speed)
		crouching = false


func _movement(v, d, time):
	if is_on_floor():
		if d:
			v.x = d.x * speed
			v.z = d.z * speed
		else:
			v.x = lerp(v.x, d.x * speed, time * 7.0)
			v.z = lerp(v.z, d.z * speed, time * 7.0)
	else:
		v.x = lerp(v.x, d.x * speed, time * 3.0)
		v.z = lerp(v.z, d.z * speed, time * 3.0)
	return v


func grenade_throw():
	if not grenade_model.visible:
		GRENADE = true
		GUN = false
		gun_model.visible = false
		grenade_model.visible = true
	label_weapon()
	reload_immersive()
	grenade_stats.text = str(grenade_count) if grenade_count >= 10 else "0" + str(grenade_count)
	if Input.is_action_just_pressed("shoot") and (grenade_count > 0):
		grenade_count -= 1


func shooting():
	if not gun_model.visible:
		grenade_model.visible = false
		gun_model.visible = true
		GRENADE = false
		GUN = true

	label_weapon()
	reload_immersive()
	gun_stats_bullets.text = str(bullet_count) if bullet_count >= 10 else "0" + str(bullet_count)
	gun_stats_stock.text = str(stock_count)

	if Input.is_action_just_pressed("shoot") and (stock_count > 0 or bullet_count > 0):
		if !glock_animation.is_playing():
			glock_animation.play("shooting")
			instance_bullet = bullet.instantiate()
			instance_bullet.position = glock_barrel.global_position
			instance_bullet.transform.basis = glock_barrel.global_transform.basis
			get_parent().add_child(instance_bullet)
			if bullet_count > 0:
				bullet_count -= 1
			else:
				stock_count -= 1
				bullet_count = 9


func add_ammo(number):
	stock_count += number


func reload_immersive():
	if Input.is_action_just_pressed("Reload"):
		if GUN:
			if stock_count > 0:
				stock_count -= 1
				bullet_count = 10
		elif GRENADE:
			grenade_count = 10


func direction_vector() -> Vector3:
	var input_dir = Input.get_vector("ui_right", "ui_left", "ui_down", "ui_up")
	var dir = -(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	return dir


func jump():
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		walking = false
		sprinting = false
		sliding = false


func sprint():
	if Input.is_action_pressed("shift"):
		speed = SPRINT_SPEED
		walking = false
		sprinting = true
		crouching = false
	else:
		speed = WALK_SPEED
		walking = true
		sprinting = false
		crouching = false


func _head_movement(v, time):
	t_BOB += time * v.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_BOB)

	var v_clamped = clamp(v.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * v_clamped

	if is_on_floor():
		camera.fov = lerp(camera.fov, target_fov, time * 8.0)


func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQUENCY) * BOB_AMPLITUDE
	pos.x = cos(time * BOB_FREQUENCY / 2) * BOB_AMPLITUDE
	return pos
