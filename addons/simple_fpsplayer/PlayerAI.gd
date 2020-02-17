extends KinematicBody

var vel = Vector3()
var dir = Vector3()
const GRAVITY = -64.8
const MAX_SPEED = 16
const JUMP_SPEED = 24
const ACCEL = 8.5
const DEACCEL= 16
const MAX_SLOPE_ANGLE = 90

var camera
var rotation_helper
var flashlight
var raycast
var last_rotation_deg = 0

export var AI_personality_movement = 0.5
export var AI_personality_brave = 1.0

export var AI_tick_time = .2
export var AI_move_speed = 2.5
export var AI_rot_speed = .1
export var AI_move_stabilize_factor = .5
export var AI_rot_stabilize_factor = 0.1

var AI_brain = {
	move_side = 0.0,
	move_forward = 0.0,
	rotate = 0.0
}


func _ready():
	randomize()
	camera = $rotation_helper/camera
	rotation_helper = $rotation_helper
	flashlight = $rotation_helper/Flashlight
	AI_personality_movement = rand_range(0.05, AI_personality_movement)
	restart_ai_tick()
	
func restart_ai_tick():
	$AI_tick.wait_time = rand_range(AI_tick_time, AI_tick_time * 8)
	$AI_tick.start()
	
func _physics_process(delta):
	process_input(delta)
	process_movement(delta)

func process_input(delta):
	dir = Vector3()
	var cam_xform = camera.get_global_transform()
	var input_movement_vector = Vector2()

	input_movement_vector = apply_ai_movement(input_movement_vector, delta)
	input_movement_vector = input_movement_vector.normalized()
	dir += -cam_xform.basis.z.normalized() * input_movement_vector.y
	dir += cam_xform.basis.x.normalized() * input_movement_vector.x
	apply_ai_rot()
	
func AI_decide_move():
	var decision = randf()
	if decision < AI_personality_movement:
		if decision < .2:
			AI_brain.rotate = rand_range(-1, 1)
		if decision < 0.50:
			AI_brain.move_forward += rand_range(1, 5)
		if decision < 0.75:
			AI_brain.move_side += rand_range(-.5, .5)


	
func apply_ai_movement(vector, delta):
	if abs(AI_brain.move_forward) >= 0.1:
		vector.y += AI_move_speed * delta
	if AI_brain.move_forward < 0: AI_brain.move_forward += AI_move_stabilize_factor
	if AI_brain.move_forward > 0: AI_brain.move_forward -= AI_move_stabilize_factor
	
	if abs(AI_brain.move_side) >= 0.1:
		vector.y += AI_move_speed * .25 * delta
	if AI_brain.move_side < 0: AI_brain.move_side += AI_move_stabilize_factor
	if AI_brain.move_side > 0: AI_brain.move_side -= AI_move_stabilize_factor
	
	return vector
	
func apply_ai_rot():
	if AI_brain.rotate < 0.15:
		AI_brain.rotate -= .1
	if AI_brain.rotate > 0.15: 
		AI_brain.rotate += .1
		
	if abs(AI_brain.rotate) >= 0.15:
		self.rotate_y(deg2rad(AI_rot_speed * AI_brain.rotate))

	
func process_movement(delta):
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

	
func _on_AI_tick_timeout():
	AI_decide_move()
	restart_ai_tick()
