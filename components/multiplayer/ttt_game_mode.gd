class_name TttGameMode
extends Node

## Assists with TTT GameMode

const RADAR_BLIP_FEET = preload("res://components/radar_blips/radar_blip_feet.tscn")

@onready var radar_update: Timer = $RadarUpdate
@onready var radar_blips: Node = $RadarBlips

var is_local_player_traitor: bool = false : set = set_traitor
var blips_dict: Dictionary = {}


func _ready():
	radar_update.timeout.connect(move_radar_blips)
	Server.player_faction_changed.connect(on_peer_faction_changed)


func on_peer_faction_changed(peer_id: int, faction_name: String):
	if peer_id != Server.server_connector.get_peer_id():
		return
	if faction_name == "Traitor":
		is_local_player_traitor = true
	else:
		is_local_player_traitor = false


func set_traitor(t: bool):
	if t == is_local_player_traitor:
		return
	
	is_local_player_traitor = t
	if is_local_player_traitor:
		spawn_blips()
		radar_update.start()
	else:
		despawn_blips()


func move_radar_blips():
	var players = GameMgr.game_tree.player_mgr.get_players()
	for player in players:
		if !blips_dict.has(player.name):
			continue
		blips_dict[player.name].global_position = player.global_position


func spawn_blips():
	var players = GameMgr.game_tree.player_mgr.get_players()
	for player in players:
		# Don't track yourself
		if player.name == str(Server.server_connector.get_peer_id()):
			continue
		var blip = RADAR_BLIP_FEET.instantiate()
		radar_blips.add_child(blip)
		blip.name = player.name
		blip.global_position = player.global_position
		blips_dict[player.name] = blip
		if player.faction == FactionMgr.Factions.TRAITOR:
			blip.modulate = Color.RED
		else:
			blip.modulate = Color.GREEN


func despawn_blips():
	for blip in radar_blips.get_children():
		blip.queue_free()
	blips_dict.clear()
