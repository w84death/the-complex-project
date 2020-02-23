extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func _input(_event):
	if Input.is_key_pressed(KEY_ESCAPE):
		menu()
	
func menu():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Global.goto_scene("res://menu.tscn")
