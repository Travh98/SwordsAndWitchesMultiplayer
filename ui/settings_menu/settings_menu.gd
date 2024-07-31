class_name SettingsMenu
extends Control

signal close_settings()
signal hat_selected(file_name: String)

const SLIDER_STEP: float = 0.01
const HAT_DIR: String = "res://assets/zavier/hats/good_hats/"

@onready var master_slider: Slider = $HBoxContainer/VBoxContainer/GridContainer/MasterSlider
@onready var music_slider: Slider = $HBoxContainer/VBoxContainer/GridContainer/MusicSlider
@onready var sfx_slider: Slider = $HBoxContainer/VBoxContainer/GridContainer/SfxSlider

@onready var master_bus: int = AudioServer.get_bus_index("Master")
@onready var music_bus: int = AudioServer.get_bus_index("Music")
@onready var sfx_bus: int = AudioServer.get_bus_index("Sfx")
@onready var close_button: Button = $HBoxContainer/VBoxContainer/CloseButton
@onready var hats_container: Container = $HBoxContainer/VBoxContainer/HatsContainer


func _ready():
	master_slider.value_changed.connect(on_master_bus_changed)
	music_slider.value_changed.connect(on_music_bus_changed)
	sfx_slider.value_changed.connect(on_sfx_bus_changed)
	close_button.pressed.connect(func(): self.close_settings.emit())
	
	# Set startup values
	on_master_bus_changed(master_slider.value)
	on_music_bus_changed(music_slider.value)
	on_sfx_bus_changed(sfx_slider.value)
	
	load_hats()


func on_master_bus_changed(value: float):
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(value))
	AudioServer.set_bus_mute(master_bus, value < SLIDER_STEP)


func on_music_bus_changed(value: float):
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(value))
	AudioServer.set_bus_mute(music_bus, value < SLIDER_STEP)


func on_sfx_bus_changed(value: float):
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(value))
	AudioServer.set_bus_mute(sfx_bus, value < SLIDER_STEP)


func load_hats():
	var hat_dir = DirAccess.open(HAT_DIR)
	if hat_dir:
		hat_dir.list_dir_begin()
		var file_name = hat_dir.get_next()
		while file_name != "":
			if hat_dir.current_is_dir():
				# This is a directory
				pass
			else:
				# This is a file
				var hat_button: Button = Button.new()
				hat_button.text = file_name
				hats_container.add_child(hat_button)
				hat_button.pressed.connect(on_hat_pressed.bind(hat_button))
			
			file_name = hat_dir.get_next()


func on_hat_pressed(button: Button):
	hat_selected.emit(button.text)
