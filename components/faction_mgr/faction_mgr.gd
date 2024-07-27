extends Node

enum Factions
{
	UNSET,
	RED,
	BLUE,
	UNDEAD,
	PLAYER,
}

func get_hostile_factions(my_faction: Factions):
	var hostile_array = []
	
	match my_faction:
		Factions.UNSET:
			pass
		Factions.RED:
			hostile_array.append(Factions.BLUE)
			hostile_array.append(Factions.PLAYER)
		Factions.BLUE:
			hostile_array.append(Factions.RED)
		Factions.UNDEAD:
			pass
	
	return hostile_array


func get_friendly_factions(my_faction: Factions):
	var friendly_array = []
	
	match my_faction:
		Factions.UNSET:
			pass
		Factions.RED:
			friendly_array.append(Factions.RED)
		Factions.BLUE:
			friendly_array.append(Factions.BLUE)
			friendly_array.append(Factions.PLAYER)
		Factions.UNDEAD:
			pass
	
	return friendly_array


func get_faction_color(faction: Factions) -> Color:
	match faction:
		Factions.UNSET:
			return Color.WHITE
		Factions.RED:
			return Color.RED
		Factions.BLUE:
			return Color.BLUE
		Factions.UNDEAD:
			return Color.GRAY
		_:
			return Color.WHITE
