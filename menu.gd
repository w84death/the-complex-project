extends Control

func _ready():
	pass

func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE):
		self.quit_game()
	
func quit_game():
	self.get_tree().quit()

func _on_btn_join_pressed():
	self.get_tree().change_scene("res://multiplayer_client.tscn")

func _on_btn_start_game_pressed():
	self.get_tree().change_scene("res://singleplayer.tscn")
