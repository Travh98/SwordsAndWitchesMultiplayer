class_name ServerInfo
extends Control

@onready var player_list: Container = $MarginContainer/HBoxContainer/Stats/PlayerList

func add_player_entry(peer_id: int, user_name: String):
	# Update exising listing
	for existing in player_list.get_children():
		if existing.name == str(peer_id):
			existing.text = user_name + " id: " + str(peer_id)
			return
	
	#print("Adding player entry ", peer_id, " name: ", user_name)
	
	# Create new listing
	var player_label: Label = Label.new()
	player_label.name = str(peer_id)
	player_list.add_child(player_label)
	player_label.text = user_name + ": " + str(peer_id)
