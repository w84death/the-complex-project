extends Node

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
	$menu_anim.play("menu_to_single")
	

func _on_btn_quit_pressed():
	self.quit_game()

func _on_btn_settings_pressed():
	$menu_anim.play("menu_to_settings")

func _on_btn_back_pressed():
	$menu_anim.play("settings_back")


func _on_btn_single_back_pressed():
	$menu_anim.play("single_back")


func _on_btn_startgame_pressed():
	self.get_tree().change_scene("res://singleplayer.tscn")


func _on_btn_a1_pressed():
	self.get_tree().change_scene("res://levels/fab_a1.tscn")


func _on_btn_a2_pressed():
	self.get_tree().change_scene("res://levels/fab_a2.tscn")
