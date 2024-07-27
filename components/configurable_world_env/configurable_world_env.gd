extends WorldEnvironment

## A WorldEnvironment that can be configured through settings


func _ready():
	#GlobalSettings.bloom_toggled.connect(toggle_bloom)
	#GlobalSettings.brightness_updated.connect(on_brightness_updated)
	pass


func toggle_bloom(do_bloom: bool):
	if do_bloom:
		environment.glow_enabled = true
	else:
		environment.glow_enabled = false


func on_brightness_updated(brightness: float):
	environment.adjustment_brightness = brightness
