extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

const PORT = "7000"
const DEFAULT_SERVER_IP = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS = 20

var players = []

var tutorial = true

var local_name: String = ""

var players_loaded = 0

enum Modes{PTP, SERVER}

var mode = null

func _ready():
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.peer_connected.connect(_on_player_connected)

## Per unirsi alla partita come Guest all'indirizzo [param address] alla porta [param port]
func join_game(address:String = "", port:String =""):
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	if port.is_empty() or !port.is_valid_int() or port.to_int()<0:
		port= PORT
	var error = peer.create_client(address, port.to_int())
	if error:
		print(error)
	multiplayer.multiplayer_peer = peer

func _on_player_connected(id):
	players.push_back(id)

## Per creare una partita come host alla porta [param port]
func create_game(port:String = ""):
	var peer = ENetMultiplayerPeer.new()
	if port.is_empty() or !port.is_valid_int() or port.to_int()<0:
		port= PORT
	var error = peer.create_server(port.to_int(), MAX_CONNECTIONS)
	if error != OK:
		print("Errore creazione server: ", error)
		if error == ERR_ALREADY_IN_USE:
			print("La porta è già occupata!")
		elif error == ERR_CANT_CREATE:
			print("Il sistema impedisce la creazione del socket")
	else:
		multiplayer.multiplayer_peer = peer
		print("Server avviato correttamente sulla porta ", port)
	multiplayer.multiplayer_peer = peer


func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	players.clear()


## Chiamata remota per cambiare scena
@rpc("call_local", "reliable")
func load_game(game_scene_path):
	get_tree().change_scene_to_file(game_scene_path)



@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	pass




func _on_player_disconnected(id):
	players.erase(id)
	player_disconnected.emit(id)



func _on_connected_fail():
	remove_multiplayer_peer()


func _on_server_disconnected():
	remove_multiplayer_peer()
	players.clear()
	server_disconnected.emit()
