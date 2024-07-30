class_name NpcMgr
extends Node

## Spawns networked NPCs per the server's request

const ENEMY_KNIGHT = preload("res://entities/test_enemies/enemy_knight.tscn")

func spawn_knight(red: bool):
	var k = ENEMY_KNIGHT.instantiate()
	if red:
		k.faction = FactionMgr.Factions.RED
	else:
		k.faction = FactionMgr.Factions.BLUE
	GameMgr.game_tree.level.npcs.add_child(k)
