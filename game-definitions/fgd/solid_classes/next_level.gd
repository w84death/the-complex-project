extends QodotEntity

var level := 'fab_a0'

func _ready() -> void:
	if 'level' in properties:
		level = properties['level']

	var children := get_children()
	if children.size() > 0:
		var physics_body = children[0]
		if physics_body is CollisionObject:
			physics_body.connect("body_entered", self, "check_trigger")

func next_level():
	Global.goto_scene("res://levels/"+level+".tscn")	
	
func check_trigger(body):
	if body.is_in_group("player"):
		next_level()
