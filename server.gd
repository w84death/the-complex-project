extends Node
# P1X Godot Multiplayer Server



export var PORT = 9666
var _server = WebSocketServer.new()
var client_list = []

func _ready():
	_server.connect("client_connected", self, "_connected")
	_server.connect("client_disconnected", self, "_disconnected")
	_server.connect("client_close_request", self, "_close_request")
	_server.connect("data_received", self, "_on_data")

	var err = _server.listen(PORT)
	if err != OK:
		lprint("Unable to start server")
		set_process(false)
	else:
		lprint("Server started at port " + str(PORT))

func _connected(id, proto):
	lprint("Client %d connected." % [id])
	client_list.append(id)
	refresh_player_list()

func _close_request(id, code, reason):
	lprint("Client %d disconnecting with code: %d, reason: %s" % [id, code, reason])

func _disconnected(id, was_clean = false):
	lprint("Client %d disconnected, clean: %s" % [id, str(was_clean)])
	client_list.remove(client_list.find(id))
	refresh_player_list()
	for client in client_list:
		var payload = 'DIS/%s' % [id]
		_server.get_peer(client).put_packet(payload.to_utf8())

func _on_data(id):
	var pkt = _server.get_peer(id).get_packet().get_string_from_utf8().split("/", true)
	lprint("Got data from client %d: %s" % [id, pkt[0]])
	
	if pkt[0] == "JOIN":
		var payload = 'YOUR_ID/%s' % id
		_server.get_peer(id).put_packet(payload.to_utf8())
		
		payload = 'NEW_JOIN/%s' % [id]
		for client in client_list:
			_server.get_peer(client).put_packet(payload.to_utf8())
		
	if pkt[0] == "POS":
		for client in client_list:
			var payload = 'POS/%s/%s' % [id, pkt[1]]
			if client.id != id:
				_server.get_peer(client).put_packet(payload.to_utf8())

func lprint(message):
	$GUI/panels/logs/log.add_text(message + '\n')
	
func refresh_player_list():
	$GUI/panels/info/players.clear()
	var i = 1
	for client in client_list:
		$GUI/panels/info/players.add_text(str(i) +' '+ str(client) + "\n")
		i += 1
	
func _process(delta):
	_server.poll()

func _exit_tree():
	_server.stop()
