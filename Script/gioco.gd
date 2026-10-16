extends Node3D

var player
@onready var mappa: Node3D = $Mappa

func _ready() -> void:
	$MultiplayerSpawner.set_multiplayer_authority(1)
	if multiplayer.is_server():
		print("--> Avvio in modalità SERVER (Nessun player fisico locale).")
		multiplayer.peer_disconnected.connect(remove_player)
		OnlineLobby.players.push_back(1)
	else:
		print("--> Avvio in modalità CLIENT. In attesa di connessione...")
		# Usiamo il segnale per evitare di inviare l'RPC prima che la rete sia pronta
		if not multiplayer.connected_to_server.is_connected(_on_connected_to_server):
			multiplayer.connected_to_server.connect(_on_connected_to_server)

func _on_connected_to_server() -> void:
	print("Connessione stabilita con il server! Avviso il server...")
	notify_server_ready.rpc_id(1)

func add_player(id):
	# 1. CONTROLLO DUPLICATI SPOSTATO ALL'INIZIO (Evita nodi orfani)
	if $Players.has_node(str(id)):
		print("Il player ", id, " esiste già.")
		return

	print("Sto aggiungendo il player ", id)
	
	player = load("res://Risorse/XRPack.tscn").instantiate()
	player.name = str(id)
	player.position.y += 2
	
	if not multiplayer.is_server() and (multiplayer.get_unique_id() == id):
		var xr_interface = XRServer.find_interface("OpenXR")
		if xr_interface and xr_interface.is_initialized():
			print("OpenXR initialized successfully per il client ", id)
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
			get_viewport().use_xr = true
		else:
			print("OpenXR not initialized, controlla che il visore sia collegato.")

	$Players.add_child(player, true)

@rpc("any_peer", "call_local", "reliable")
func notify_server_ready():
	var peer_id = multiplayer.get_remote_sender_id()
	print("Il Client ", peer_id, " è pronto. Spawno il suo player...")
	add_player(peer_id)

func _on_multiplayer_spawner_spawned(node: Node) -> void:
	print("Spawnato tramite MultiplayerSpawner: ", node)

func remove_player(id: int):
	var node_path = str("Players/", id)
	if $Players.has_node(str(id)):
		get_node(node_path).queue_free()
		print("Rimosso player ", id)
