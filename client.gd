extends Node

var player = preload("res://assets/simple_fpsplayer/Player.tscn")
var player_dummy = preload("res://assets/simple_fpsplayer/PlayerDummy.tscn")
export var websocket_url = "ws://p1x.in:9666"
var player_node
var player_last_pos 
var my_id = 0

var _client = WebSocketClient.new()

func _ready():
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	_client.connect("data_received", self, "_on_data")
		
func _closed(was_clean = false):
	lprint("Closed, clean: " + str(was_clean))
	set_process(false)

func _connected(proto = ""):
	lprint("Joining..")
	$GUI/info/info/vbox/setup.hide()
	var payload = 'JOIN'
	_client.get_peer(1).put_packet(payload.to_utf8())

func connect_to_server():
	lprint("Connecting to " + str(websocket_url))
	var err = _client.connect_to_url(websocket_url)
	if err != OK:
		lprint("Unable to connect")
		set_process(false)
	else:
		lprint("Connection established.")
		set_process(true)
		
func _on_data():
	var response = _client.get_peer(1).get_packet().get_string_from_utf8().split("/", true)
	lprint("Got data from server: " + str(response[0]))
	
	if response[0] == "YOUR_ID":
		print(response[1])
		$GUI/info/info/vbox/player/id.set_text(str(response[1]))
		my_id = response[1]
		spawn_player(response[1])
	
	if response[0] == "NEW_JOIN":
		if response[1] != my_id:
			spawn_player_dummy(response[1])
			lprint("%s joined" % [response[1]])

	if response[0] == "POS":
		var parse_pos = response[2].split(',')
		var new_pos = Vector3(parse_pos[0],parse_pos[1],parse_pos[2])
		for p_node in $players.get_children():
			if p_node.multiplayer_id == response[1]:
				p_node.translation = new_pos
		
	if response[0] == "DIS":
		for p_node in $players.get_children():
			if p_node.multiplayer_id == response[1]:
				$players.remove_child(p_node)
		lprint("%s disconnected" % [response[1]])
		
func lprint(message):
	print(message)
	$GUI/info/logs/log.add_text("%s\n" % message)
	
func _process(delta):
	_client.poll()

func _exit_tree():
	_client.disconnect_from_host()

func emit_position():
	var payload = 'POS/%s,%s,%s' % [player_node.translation.x, player_node.translation.y, player_node.translation.z]
	_client.get_peer(1).put_packet(payload.to_utf8())
	player_last_pos = player_node.translation

func _on_btn_connect_pressed():
	websocket_url = "ws://%s:%s" % [$GUI/info/info/vbox/setup/addres.text, $GUI/info/info/vbox/setup/port.text]
	connect_to_server()
	
func spawn_player(id):
	player_node = player.instance()
	player_node.translation = $hangar/start.translation
	player_last_pos = player_node.translation
	player_node.get_node("rotation_helper/camera").make_current()
	player_node.multiplayer_id = id
	add_child(player_node)
	$tick.start()
	
func spawn_player_dummy(id):
	var player_new = player_dummy.instance()
	player_new.translation = $hangar/start.translation
	player_new.multiplayer_id = id
	$players.add_child(player_new)

func _on_tick_timeout():
	if player_last_pos != player_node.translation:
		emit_position()
