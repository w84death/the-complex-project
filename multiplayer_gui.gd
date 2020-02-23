extends Spatial

func _ready():
	pass # Replace with function body.
	
func _process(delta):
	if Input.is_action_pressed("ui_cancel"):
		if $Client.is_connected_to_server():
			$Client.disconnect_from_server()
			Global.goto_scene("res://loading_multiplayer.tscn")
		else:
			Global.goto_scene("res://menu.tscn")
