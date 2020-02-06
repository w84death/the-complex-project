extends Control

func _ready():
	pass

func toggle_help():
	if $info/help.visible: 
		$info/help.hide() 
	else:
		$info/help.show()

func add_log(message):
	$info/logs/log.add_text("%s\n" % message)
	
func set_player_id(id):
		$info/info/vbox/player/id.set_text(str(id))
