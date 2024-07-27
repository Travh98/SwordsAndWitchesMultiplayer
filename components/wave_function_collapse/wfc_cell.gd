extends Node
class_name WfcCell

var is_collapsed: bool = false
var tile_options: Array[WfcTile]


func create_cell(collapseState: bool, tiles):
	is_collapsed = collapseState
	tile_options = tiles


func recreate_cell(tiles):
	tile_options = tiles
