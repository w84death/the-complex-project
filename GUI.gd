extends Control

func _ready():
	pass

func toggle_help():
	if $info/help.visible: 
		$info/help.hide() 
	else:
		$info/help.show()

func add_log(message):
	$bottom/logs/log.add_text("%s\n" % message)
	
func set_player_id(id):
		$info/network_id/player/id.set_text(str(id))
		
func hide_network_setup():
	$info/network.hide()
	$info/network_id.show()
	
func show_network_setup():
	$info/network.show()
	$info/network_id.hide()

func get_websocket_url():
	return "ws://%s:%s" % [$info/network/setup/addres.text, $info/network/setup/port.text]
