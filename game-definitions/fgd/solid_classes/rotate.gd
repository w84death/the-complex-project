class_name QodotRotateEntity
extends QodotEntity

export(Vector3) var rotate_axis := Vector3.UP
export(float) var rotate_speed := 360.0

func update_properties():
	if 'axis' in properties:
		var axis_comps = properties['axis'].split(" ")
		rotate_axis.x = axis_comps[0].to_float()
		rotate_axis.y = axis_comps[1].to_float()
		rotate_axis.z = axis_comps[2].to_float()

	if 'speed' in properties:
		rotate_speed = properties['speed'].to_float()

func _process(delta: float) -> void:
	rotate(rotate_axis, deg2rad(rotate_speed * delta))
