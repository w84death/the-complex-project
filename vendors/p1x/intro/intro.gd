
extends Spatial

func _ready():
	pass

func _input(_event):
	if Input.is_key_pressed(KEY_ESCAPE):
		self.quit_game()
	
func quit_game():
	self.get_tree().quit()

func next_scene():
	Global.goto_scene("res://menu.tscn")
