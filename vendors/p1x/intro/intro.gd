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

func _on_Button_pressed():
	self.next_scene()

func _on_btn_quit_pressed():
	self.quit_game()

func _on_btn_options_pressed():
	pass # Replace with function body.


func _on_btn_server_pressed():
	self.get_tree().change_scene("res://multiplayer_server.tscn")


func _on_btn_join_pressed():
	self.get_tree().change_scene("res://multiplayer_client.tscn")
