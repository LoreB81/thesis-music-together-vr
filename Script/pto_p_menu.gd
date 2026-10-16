extends Control

#Menu per il peer2peer

@onready var portahost: LineEdit = $SubViewportContainer/SubViewport/Sfondo/btn_host/txt_portahost
@onready var ip: LineEdit = $SubViewportContainer/SubViewport/Sfondo/Connect/txt_ip
@onready var portaguest: LineEdit = $SubViewportContainer/SubViewport/Sfondo/Connect/txt_portaguest
@onready var nickname: LineEdit = $SubViewportContainer/SubViewport/Sfondo/lbl/txt_name


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func NicknameCheck(default: String=""):
	if nickname.text.is_empty():
		OnlineLobby.local_name = default
	else: OnlineLobby.local_name = nickname.text


func _on_btn_host_pressed() -> void:
	NicknameCheck("Host")
	OnlineLobby.create_game(portahost.text)
	OnlineLobby.mode = OnlineLobby.Modes.PTP
	OnlineLobby.load_game("Networking/GameNet.tscn")

func _on_btn_connect_pressed() -> void:
	NicknameCheck("Guest")
	OnlineLobby.join_game(ip.text, portaguest.text)
	OnlineLobby.load_game("Networking/GameNet.tscn")


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/general_menu.tscn")
