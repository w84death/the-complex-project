extends Spatial

export var next_scene_bigfile = "scenes/big/main"
export var first_button_path = "main/menu/panel/buttons/start"
export var close_instruction_path = "main/instruction/panel/ok"
export var has_buttons = false

func _ready():
	if has_buttons: self.activate_first_button()

func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE):
		self.quit_game()
		
func _on_quit_pressed():
	self.quit_game()
	
func quit_game():
	self.get_tree().quit()

func next_scene():
	self.get_tree().change_scene(next_scene_bigfile+".tscn")

func _on_start_pressed():
	self.next_scene()

func activate_first_button():
	self.get_node(first_button_path).grab_focus()

func activate_close_button():
	self.get_node(close_instruction_path).grab_focus()

func _on_instruction_pressed():
	$main/instruction.show()
	$main/menu.hide()
	$instruction.play()
	self.activate_close_button()

func _on_ok_pressed():
	self.instrucion_hide()

func instrucion_hide():
	$main/instruction.hide()
	$main/menu.show()
	$instruction.stop()
	self.activate_first_button()

func _on_instruction_finished():
	self.instrucion_hide()
