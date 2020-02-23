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
	var con = Control.new()
	var lab = Label.new()
	lab.set_text("Loading...")
	lab.set_align(HALIGN_CENTER)
	lab.set_valign(VALIGN_CENTER)
	con.set_anchors_and_margins_preset(15)
	lab.set_anchors_and_margins_preset(8)
	con.add_child(lab)
	add_child(con)
	yield(get_tree().create_timer(.5), "timeout")
	self.get_tree().change_scene("res://levels/"+level+".tscn")
	
func check_trigger(body):
	if body.is_in_group("player"):
		next_level()
