extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func menu():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	self.get_tree().change_scene("res://menu.tscn")
