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

var AI_personality_movement = 0.5
var AI_personality_brave = 0.7
var AI_max_tick_time = 1
var AI_min_tick_time = .1

var AI_move_speed = 2.5
var AI_rot_speed = 3
var AI_escape_rot = 6
var AI_escape_move = -1
var AI_move_stabilize_factor = .1
var AI_rot_stabilize_factor = .2

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
	AI_personality_movement = rand_range(0.05, 0.9)
	AI_personality_brave = rand_range(0.2, 0.7)
	$AI_tick.wait_time = rand_range(AI_min_tick_time, AI_min_tick_time + AI_max_tick_time - AI_personality_brave)
	restart_ai_tick()
	
func restart_ai_tick():
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
	
	process_audio()
	
func process_audio():
	if abs(AI_brain.move_forward) > 0.1 or (AI_brain.move_side) > 0.1:
		if not $audio_movement.is_playing(): $audio_movement.play()
	else:
		if $audio_movement.is_playing(): $audio_movement.stop()
	
func AI_decide_move():
	if randf() < AI_personality_movement:
		var decision = randf()
		if decision < 0.5:
			AI_brain.rotate += rand_range(-2, 2)
			
		if decision < 0.4:
			AI_brain.move_side += rand_range(-4, 4)
			
		if decision >= 0.3 and decision < 0.7:
			AI_brain.move_forward += rand_range(1, 15)
		
		if decision >= 0.7:
			AI_brain.move_forward *= .5
			AI_brain.rotate *= .5

func apply_ai_movement(vector, delta):
	var dir = 1
	if abs(AI_brain.move_forward) > AI_move_stabilize_factor:
		if AI_brain.move_forward < 0: dir = -1 
		else: dir = 1
		vector.y += AI_move_speed * delta * dir
	if AI_brain.move_forward < AI_move_stabilize_factor: AI_brain.move_forward += AI_move_stabilize_factor
	if AI_brain.move_forward > AI_move_stabilize_factor: AI_brain.move_forward -= AI_move_stabilize_factor
	
	if abs(AI_brain.move_side) > AI_move_stabilize_factor:
		if AI_brain.move_side < 0: dir = -1 
		else: dir = 1
		vector.y += AI_move_speed * .25 * delta * dir
		
	if AI_brain.move_side < AI_move_stabilize_factor: AI_brain.move_side += AI_move_stabilize_factor
	if AI_brain.move_side > AI_move_stabilize_factor: AI_brain.move_side -= AI_move_stabilize_factor
	
	return vector
	
func apply_ai_rot():
	var dir = 1
	if abs(AI_brain.rotate) > AI_rot_stabilize_factor:
		if AI_brain.rotate < 0: dir = -1 
		else: dir = 1
		self.rotate_y(deg2rad(AI_rot_speed * dir))
		if AI_brain.rotate < -AI_rot_stabilize_factor:
			AI_brain.rotate += AI_rot_stabilize_factor
		if AI_brain.rotate > AI_rot_stabilize_factor: 
			AI_brain.rotate -= AI_rot_stabilize_factor
	
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
	
	if get_slide_count() > 1:
		if randf() > .5:
			AI_brain.rotate = rand_range(AI_escape_rot*.5, AI_escape_rot)
		else:
			AI_brain.rotate = -rand_range(AI_escape_rot*.5, AI_escape_rot)
		if randf() < .25:
			AI_brain.move_forward = AI_escape_move
	
func _on_AI_tick_timeout():
	AI_decide_move()
	restart_ai_tick()
