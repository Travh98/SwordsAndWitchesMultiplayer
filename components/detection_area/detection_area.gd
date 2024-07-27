class_name DetectionArea
extends Area3D


func scan_for_living_target() -> Mob:
	var found_target: Node3D = null
	for n in get_overlapping_bodies():
		if n is Mob:
			if n == get_parent():
				continue # Don't detect parent
			
			if n.has_node("HealthComponent"):
				if n.get_node("HealthComponent").is_dead:
					continue # Don't target the dead
			
			if found_target == null:
				# If this is the first one found
				found_target = n
			else:
				# Find the closest item
				if global_position.distance_to(n.global_position) \
				< global_position.distance_to(found_target.global_position):
					found_target = n
	
	return found_target


func scan_for_living_player() -> Mob:
	var found_target: Node3D = null
	for n in get_overlapping_bodies():
		if n is Mob:
			if n == get_parent():
				continue # Don't detect parent
			
			if n.has_node("HealthComponent"):
				if n.get_node("HealthComponent").is_dead:
					continue # Don't target the dead
			
			#if !n.has_node("PlayerController"):
				#continue
			
			if n is FpsCharacter != true:
				continue
			
			if found_target == null:
				# If this is the first one found
				found_target = n
			else:
				# Find the closest item
				if global_position.distance_to(n.global_position) \
				< global_position.distance_to(found_target.global_position):
					found_target = n
	
	return found_target


func scan_get_all_living_mobs() -> Array:
	var living_mobs = []
	for n in get_overlapping_bodies():
		if n is Mob:
			if n == get_parent():
				continue # Don't detect parent
			
			if n.has_node("HealthComponent"):
				if n.get_node("HealthComponent").is_dead:
					continue # Don't target the dead
			
			living_mobs.append(n)
	
	return living_mobs


func scan_for_hostile_faction_members(my_faction: FactionMgr.Factions) -> Mob:
	var found_target: Node3D = null
	for n in get_overlapping_bodies():
		if n is Mob:
			if n == get_parent():
				continue # Don't detect parent
			
			if n.has_node("HealthComponent"):
				if n.get_node("HealthComponent").is_dead:
					continue # Don't target the dead
			
			if !FactionMgr.get_hostile_factions(my_faction).has(n.faction):
				continue
			
			if found_target == null:
				# If this is the first one found
				found_target = n
			else:
				# Find the closest item
				if global_position.distance_to(n.global_position) \
				< global_position.distance_to(found_target.global_position):
					found_target = n
	
	return found_target
