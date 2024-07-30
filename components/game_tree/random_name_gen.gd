class_name RandomNameGen
extends Node

var default_names = [
	"beef cake", 
	"butterscotch", 
	"princess", 
	"good smelling", 
	"dough nuts", 
	"dandelion", 
	"spooky face", 
	"creeper", 
	"candy corn", 
	"musketeer",
	"wizard", 
	"trick or treat", 
	"candy", 
	"biscuit", 
	"lollypop", 
	"chocolate chip",
	]

func get_random_name() -> String:
	return default_names.pick_random()
