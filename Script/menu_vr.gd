extends Node3D

var xr_interface: XRInterface

func _ready():
	var player = load("res://Risorse/XRPack.tscn").instantiate()
	player.position.y+=1
	self.add_child(player)
	get_viewport().use_xr = true
