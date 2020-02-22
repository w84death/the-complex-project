
extends Spatial

export var next_scene_bigfile = "scenes/big/main"

func _ready():
	pass

func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE):
		self.quit_game()
	
func quit_game():
	self.get_tree().quit()

func next_scene():
	self.get_tree().change_scene(next_scene_bigfile+".tscn")
