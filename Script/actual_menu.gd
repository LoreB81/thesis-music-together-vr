extends CanvasLayer


func _on_bnt_guest_pressed() -> void:
	print("provo ad unirmi")
	OnlineLobby.join_game()
	get_tree().change_scene_to_file("res://gioco.tscn")

func _on_bnt_host_pressed() -> void:
	OnlineLobby.create_game()
	get_tree().change_scene_to_file("res://gioco.tscn")
	
