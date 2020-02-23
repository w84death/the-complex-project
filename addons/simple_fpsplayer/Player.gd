extends KinematicBody
#Variables
var global = "root/global"
var multiplayer_id = 0

export var stoned = false

var is_player = true
const GRAVITY = -64.8
var vel = Vector3()
const MAX_SPEED = 16
const JUMP_SPEED = 24
const ACCEL = 8.5

var dir = Vector3()

const DEACCEL= 16
const MAX_SLOPE_ANGLE = 90

var camera
var rotation_helper
var raycast

var MOUSE_SENSITIVITY = 0.1
var MOUSE_INVERSION = -1

const MAX_SPRINT_SPEED = 20
const SPRINT_ACCEL = 18
var is_sprinting = false
var WEAPON_COOLDOWN_TIME = 1
var WEAPON_COOL = true

var flashlight

func _ready():
	camera = $rotation_helper/camera
	rotation_helper = $rotation_helper
	flashlight = $rotation_helper/Flashlight
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	add_to_group("can_open_door")
	add_to_group("player")


func _physics_process(delta):
	process_input(delta)
	process_movement(delta)
	for i in get_slide_count():
		var collision  = get_slide_collision(i)
		if collision.collider.is_in_group("bomb"): 
			print("bum")
			collision.collider.explode()
		
func process_input(delta):
	# ----------------------------------
	# Walking
	dir = Vector3()
	var cam_xform = camera.get_global_transform()

	var input_movement_vector = Vector2()

	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x += 1

	input_movement_vector = input_movement_vector.normalized()

	dir += -cam_xform.basis.z.normalized() * input_movement_vector.y
	dir += cam_xform.basis.x.normalized() * input_movement_vector.x
	# ----------------------------------

	# ----------------------------------
	# Jumping
	if is_on_floor():
		if Input.is_action_just_pressed("movement_jump"):
			vel.y = JUMP_SPEED
	# ----------------------------------

	# ----------------------------------
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			Global.goto_scene("res://menu.tscn")
	# ----------------------------------

# ----------------------------------
# Turning the flashlight on/off
	if Input.is_action_just_pressed("flashlight"):
		#$click.play()
		if flashlight.is_visible_in_tree():
			flashlight.hide()
		else:
			flashlight.show()
# ----------------------------------

# ----------------------------------
# Invert mouse
	if Input.is_key_pressed(KEY_I):
		invert_mouse()
# ----------------------------------

func process_movement(delta):
	if stoned: return
	dir.y = 0
	dir = dir.normalized()

	vel.y += delta * GRAVITY

	var hvel = vel
	hvel.y = 0

	var target = dir
	target *= MAX_SPEED

	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL

	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))
	process_audio(hvel)
	
func _input(event):
	if stoned: return
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * MOUSE_INVERSION))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot
		
func invert_mouse():
	MOUSE_INVERSION *= -1
	
func change_mouse_sensitivity(sens):
	MOUSE_SENSITIVITY = sens

# THIS NEEDS TO BE REFACTORED -> MOVED TO THE SERVER LOGIC
func get_posrot():
	var rotpos = 'POS/%s,%s,%s/%s,%s' % [
		translation.x, 
		translation.y, 
		translation.z,
		rotation_helper.rotation_degrees.x,
		rotation_degrees.y,
	]
	return rotpos

func get_flashlight_status():
	return $rotation_helper/Flashlight.is_visible_in_tree()

func process_audio(vector):
	if abs(vector.x) > 0.1 and abs(vector.z) > 0.1 :
		if not $audio_movement.is_playing(): $audio_movement.play()
	else:
		if $audio_movement.is_playing(): $audio_movement.stop()
