extends Node

var player = preload("res://addons/simple_fpsplayer/Player.tscn")
var player_dummy = preload("res://addons/simple_fpsplayer/PlayerDummy.tscn")
export var websocket_url = "ws://p1x.in:9666"
var player_node
var player_last_posrot
var player_last_flashlight = false
var my_id = 0
var networking_started = false

var _client = WebSocketClient.new()

func _ready():
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	_client.connect("data_received", self, "_on_data")
		
func _closed(was_clean = false):
	lprint("Connection closed.")
	$GUI.show_network_setup()
	set_process(false)
	networking_started = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if player_node:
		player_node.queue_free()
		remove_child(player_node)
		$cameras/camera1.make_current()
	$tick.stop()

func _connected(proto = ""):
	lprint("Joining..")
	$GUI.hide_network_setup()
	var payload = 'JOIN'
	_client.get_peer(1).put_packet(payload.to_utf8())
	networking_started = true

func connect_to_server():
	lprint("Connecting to " + str(websocket_url))
	var err = _client.connect_to_url(websocket_url)
	if err != OK:
		lprint("Unable to connect")
		set_process(false)
	else:
		lprint("Connection established.")
		set_process(true)

func disconnect_from_server():
	lprint("Disconnecting from " + str(websocket_url))
	_client.disconnect_from_host()
	
func _on_data():
	var response = _client.get_peer(1).get_packet().get_string_from_utf8().split("/", true)
	
	if response[0] == "YOUR_ID":
		lprint("Joined, got Network ID.")
		$GUI.set_player_id(response[1])
		my_id = response[1]
		spawn_player(response[1])
		var payload = 'GET_PLAYERS_LIST'
		_client.get_peer(1).put_packet(payload.to_utf8())
	
	if response[0] == "NEW_JOIN":
		if response[1] != my_id:
			spawn_player_dummy(response[1], response[2], response[3])
			lprint("%s joined" % [response[1]])

	if response[0] == "POS":
		update_players_posrot(response[1], response[2], response[3])
	
	if response[0] == "FLASHLIGHT":
		update_player_flashlight(response[1], response[2])
		
	if response[0] == "DIS":
		for p_node in $players.get_children():
			if p_node.multiplayer_id == response[1]:
				$players.remove_child(p_node)
		lprint("%s disconnected" % [response[1]])
		
	if response[0] == "MOTD":
		lprint(response[1])

func update_players_posrot(id, pos, rot):
	var parse_pos = pos.split(',')
	var new_pos = Vector3(parse_pos[0],parse_pos[1],parse_pos[2])
	var parse_rot = rot.split(',')
	var new_rot = Vector2(parse_rot[0],parse_rot[1])
	for p_node in $players.get_children():
		if p_node.multiplayer_id == id:
			p_node.translation = new_pos
			p_node.get_node('rotation_helper').rotation_degrees.x = new_rot.x
			p_node.rotation_degrees.y = new_rot.y

func update_player_flashlight(id, flashlight):
	var onoff = false
	if flashlight == 'True': onoff = true
	for p_node in $players.get_children():
		if p_node.multiplayer_id == id:
			p_node.flashlight(onoff)
			
func lprint(message):
	print(message)
	$GUI.add_log(message)
	
func _process(delta):
	_client.poll()

func _exit_tree():
	_client.disconnect_from_host()

func emit_position():
	var payload = player_node.get_posrot()
	_client.get_peer(1).put_packet(payload.to_utf8())

func emit_flashlight():
	var payload = 'FLASHLIGHT/%s' % player_node.get_flashlight_status()
	_client.get_peer(1).put_packet(payload.to_utf8())
	
func _on_btn_connect_pressed():
	websocket_url = $GUI.get_websocket_url()
	connect_to_server()
	
func spawn_player(id):
	player_node = player.instance()
	player_node.translation = $level/start.translation
	player_node.get_node("rotation_helper/camera").make_current()
	player_node.multiplayer_id = id
	add_child(player_node)
	$tick.start()
	
func spawn_player_dummy(id, pos, flashlight):
	var player_new = player_dummy.instance()
	var parse_pos = pos.split(',')
	var new_pos = Vector3(parse_pos[0],parse_pos[1],parse_pos[2])
	player_new.translation = new_pos
	player_new.multiplayer_id = id
	player_new.flashlight(flashlight)
	$players.add_child(player_new)

func is_connected_to_server():
	return networking_started
	
func _on_tick_timeout():
	if is_connected_to_server():
		if player_last_posrot != player_node.get_posrot():
			emit_position()
			player_last_posrot = player_node.get_posrot()
		if player_last_flashlight != player_node.get_flashlight_status():
			emit_flashlight()
			player_last_flashlight = player_node.get_flashlight_status()
