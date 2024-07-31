extends Control

## HUD for TTT Gamemode

@onready var faction_label: Label = $MarginContainer/HBoxContainer/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/FactionLabel
@onready var game_stage_label: Label = $MarginContainer/HBoxContainer/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/GameStageLabel
@onready var time_left_label: Label = $MarginContainer/HBoxContainer/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/TimeLeftLabel
@onready var countdown_timer: Timer = $CountdownTimer
@onready var winner_label: RichTextLabel = $HBoxContainer/VBoxContainer/WinnerLabel
@onready var winner_label_anim_player: AnimationPlayer = $HBoxContainer/WinnerLabelAnimPlayer


func _ready():
	Server.gamemode_stage_updated.connect(on_gamemode_stage_changed)
	Server.game_stage_time_left_updated.connect(on_game_stage_time_left_changed)
	Server.player_faction_changed.connect(on_player_faction_changed)
	Server.ttt_winner_decided.connect(on_winner_decided)


func on_gamemode_stage_changed(new_stage: String):
	game_stage_label.text = new_stage


func _process(_delta):
	time_left_label.text = str(int(countdown_timer.time_left))


func on_game_stage_time_left_changed(time_left: int):
	if time_left > 0:
		countdown_timer.wait_time = time_left
		countdown_timer.start()
	else:
		countdown_timer.stop()


func on_player_faction_changed(peer_id: int, faction_name: String):
	if peer_id != Server.server_connector.get_peer_id():
		return
	var faction: FactionMgr.Factions = FactionMgr.get_faction_from_string(faction_name)
	match faction:
		FactionMgr.Factions.INNOCENT:
			faction_label.modulate = Color.GREEN
		FactionMgr.Factions.TRAITOR:
			faction_label.modulate = Color.RED
		FactionMgr.Factions.PEACEFUL:
			faction_label.modulate = Color.WHITE_SMOKE
		_:
			faction_label.modulate = Color.WHITE
	faction_label.text = FactionMgr.Factions.keys()[faction]


func on_winner_decided(traitors_won: bool):
	if traitors_won:
		winner_label.text = "[wave amp=50.0 freq=5.0 connected=1][center][font_size=48][color=red]Traitors win![/color][/font_size][/center][/wave]"
	else:
		winner_label.text = "[center][font_size=48][color=green]Innocents win![/color][/font_size][/center]"
	winner_label_anim_player.play("show_winner")
