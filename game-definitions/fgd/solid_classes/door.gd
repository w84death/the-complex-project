extends QodotEntity

var pressed = false
var base_translation = Vector3.ZERO
var angle := 0.0
var speed := 8.0
var depth := 0.8
var wait := 0.25
var delay :=  0.5

signal pressed

func _ready() -> void:
	if 'angle' in properties:
		angle = properties['angle'].to_float()

	if 'speed' in properties:
		speed = properties['speed'].to_float()

	if 'depth' in properties:
		depth = properties['depth'].to_float()

	if 'wait' in properties:
		wait = properties['wait'].to_float()

	if 'delay' in properties:
		delay = properties['delay'].to_float()

	base_translation = translation

	var children := get_children()
	if children.size() > 0:
		var physics_body = children[0]
		if physics_body is Area:
			physics_body.connect("body_entered", self, "check_trigger")

func _process(delta: float) -> void:
	var target_position = base_translation + (Vector3.FORWARD.rotated(Vector3.UP, deg2rad(-angle)) * (depth if pressed else 0.0))
	translation = translation.linear_interpolate(target_position, speed * delta)

func check_trigger(body) -> void:
	print(body)

func press():
	if pressed:
		return

	pressed = true
	if wait >= 0:
		yield(get_tree().create_timer(wait), "timeout")
		release()

	fire_pressed()

func fire_pressed():
	yield(get_tree().create_timer(delay), "timeout")
	emit_signal("pressed")


func release():
	if not pressed:
		return

	pressed = false
