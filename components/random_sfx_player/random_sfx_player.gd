extends Node3D
class_name RandomSfxPlayer

## Node for playing a random sound from it's AudioStreamPlayer3D children

var sounds = []
@export var pitch_variance: float = 0.05

func _ready():
	for child in get_children():
		if child is AudioStreamPlayer3D:
			sounds.append(child)


func play_sound():
	if sounds.size() > 0:
		var sfx: AudioStreamPlayer3D = sounds.pick_random()
		if sfx:
			# Add positive or negative pitch
			if randi_range(0, 1) == 1:
				sfx.pitch_scale = 1.0 + pitch_variance * randf()
			else:
				sfx.pitch_scale = 1.0 - pitch_variance * randf()
			
			sfx.play()


func stop_sounds():
	for sound in sounds:
		var sfx: AudioStreamPlayer3D = sound
		if sfx:
			sfx.stop()
