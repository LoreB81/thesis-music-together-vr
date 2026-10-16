extends Node3D

## Nodo mappa
@onready var mappa: Node3D = $Mappa

## Margine della zona di spawn

# Varibili per la gestione del menù di selezione musica
var menu_toggle = false
var menu: Node

# Se è il server/host crea il proprio giocatore, altrimenti avvisa il server che è pronto
func _ready() -> void:
	$MultiplayerSpawner.set_multiplayer_authority(1)
	if multiplayer.is_server():
		multiplayer.peer_disconnected.connect(remove_player)
		OnlineLobby.players.push_back(1)
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		notify_server_ready.rpc_id(1)


## Chiamata remota per iniziare in una [param stream] un brano [param music] al tempo [param time]
@rpc("authority", "call_local", "reliable")
func start_soundtrack(stream: String, time: float = 0.0, music:String=""):
	print("sinc audio")
	if !music.is_empty():
		mappa.get_audio_node(stream).stream = load("res://Components/Sounds/"+music)
	mappa.get_audio_node(stream).play(time)

func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if multiplayer.is_server():
		if event.is_action_pressed("az_switch"):
			menu_toggle = !menu_toggle
			menu_handler()

##Gestore per il menu di selezione di musica dell'Host
func menu_handler()->void:
	if menu_toggle:
		menu = preload("res://Menus/music_selection_menu.tscn").instantiate()
		get_viewport().get_node("CanvasLayer").add_child(menu)
		menu.set_audio_list(mappa.audiostreams)
		menu.set_music_list()
		menu.caller = self
	else:
		menu.queue_free()

## Funzione per aggiungere un giocatore con il suo [param id]
func add_player(id):
	var player = preload("res://Components/Player/mp_player.tscn").instantiate()
	#salta i duplicati
	if $Players.has_node(str(id)):
		return
	player.name = str(id)
	print("Sto aggiungendo il player ", id)
	$Players.add_child(player, true)

## Notifica il server che l'host è pronto ad essere collegato
@rpc("any_peer", "call_local", "reliable")
func notify_server_ready():
	var peer_id = multiplayer.get_remote_sender_id()
	print("Il Client ", peer_id, " è pronto. Spawno il suo player...")
	add_player(peer_id)
	#if multiplayer.is_server():
		#for x in mappa.audiostreams:
			#var music = mappa.get_audio_node(x).stream.resource_path.get_file()
			#start_soundtrack.rpc_id(peer_id, x, mappa.get_audio_node(x).get_playback_position(), music)

## Inizia la stessa musica in tutto il server
func global_music_start(stream: Array[String], audio: String):
	for x in stream:
		for y in OnlineLobby.players:
			start_soundtrack.rpc_id(y, x, 0, audio)


func _on_multiplayer_spawner_spawned(node: Node) -> void:
	print("Spawnato ",node)

## Rimuove il giocatore con id [param id]
func remove_player(id:int):
	var prova = str("Players/",id)
	get_node(prova).queue_free()
