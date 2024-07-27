class_name Lever
extends Interactable

signal state_changed(bool)

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready():
	super._ready()
	play_anim_for_state()
	await get_tree().create_timer(0.5).timeout
	value_changed.emit(value)


func do_interact():
	if value <= 0:
		value = 1
	else:
		value = 0
		
	play_anim_for_state()
	value_changed.emit(value)
	#print(name, " value: ", value)


func play_anim_for_state():
	if value == 1:
		animation_player.play("on_state")
	else:
		animation_player.play("off_state")
