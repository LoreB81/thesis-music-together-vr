extends Node

func _ready() -> void:
	_avvia.call_deferred()

func _avvia() -> void:
	var args = OS.get_cmdline_args()
	if "--no-vr" in args:
		XRServer.remove_interface(XRServer.find_interface("OpenXR"))
		print("Avvio in modalità Server (No VR)")
		OnlineLobby.create_game()
		OnlineLobby.load_game("res://gioco.tscn")
	else:
		_avvia_vr()
func _avvia_vr()->void:
	print("Avvio in modalità Client VR. Vado al menu.")
	var xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialized successfully")

		# Turn off v-sync!
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

		# Change our main viewport to output to the HMD
		get_viewport().use_xr = true
	else:
		print("OpenXR not initialized, please check if your headset is connected")
	get_tree().change_scene_to_file("res://Menu_vr.tscn")
