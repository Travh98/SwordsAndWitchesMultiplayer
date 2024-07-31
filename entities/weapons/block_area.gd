class_name BlockArea
extends Area3D

## Blocks weapon attacks

var weapon_owner: HandItem


func _ready():
	area_entered.connect(on_area_entered)


func on_area_entered(area: Area3D):
	if area is HurtBox:
		var hurtbox: HurtBox = area
		
		# Don't parry yourself
		if hurtbox.weapon_owner == weapon_owner:
			return
			
		if hurtbox.weapon_owner:
			if hurtbox.weapon_owner is Sword:
				# This only works because the Sword is MultiplayerSynced
				hurtbox.weapon_owner.get_parried()
				
				if weapon_owner is Sword:
					weapon_owner.successful_parry()
