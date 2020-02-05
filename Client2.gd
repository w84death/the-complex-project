extends Node

var player = preload("res://assets/simple_fpsplayer/Player.tscn")
var player_dummy = preload("res://assets/simple_fpsplayer/PlayerDummy.tscn")
export var websocket_url = "ws://192.168.1.120:9666"

var _client = WebSocketClient.new()

func _ready():
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	_client.connect("data_received", self, "_on_data")
	print("connecting to " + str(websocket_url))
	# Initiate connection to the given URL.
	var err = _client.connect_to_url(websocket_url)
	if err != OK:
		lprint("Unable to connect")
		set_process(false)
	else:
		lprint("connecting to " + str(websocket_url))
		
func _closed(was_clean = false):
	lprint("Closed, clean: " + str(was_clean))
	set_process(false)

func _connected(proto = ""):
	lprint("Connected")
	var payload = 'JOIN'
	_client.get_peer(1).put_packet(payload.to_utf8())
	
func _on_data():
	var response = _client.get_peer(1).get_packet().get_string_from_utf8().split("/", true)
	lprint("Got data from server: " + str(response[0]))
	
	if response[0] == "YOUR_ID":
		print(response[1])
	
	if response[0] == "POS":
		lprint("%s new position: %s" % [response[1], response[2]])
		
func lprint(message):
	print(message)
	$GUI/info/logs/log.add_text("%s\n" % message)
	
func _process(delta):
	_client.poll()

func _exit_tree():
	_client.disconnect_from_host()

func _on_btn_test_pressed():
	var payload = 'POS/%s' % [Vector3(1,2,3)]
	_client.get_peer(1).put_packet(payload.to_utf8())

func _on_btn_connect_pressed():
	var payload = 'JOIN'
	_client.get_peer(1).put_packet(payload.to_utf8())
	
func spawn_player():
	var new_player = player.instance()
	new_player.translation = $hangar/start.translation
	new_player.get_node("rotation_helper/camera").make_current()
	$hangar.add_child(new_player)
