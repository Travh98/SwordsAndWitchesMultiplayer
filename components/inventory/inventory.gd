extends Node
class_name BaseInventory

signal item_equipped(slot_index: int)

@onready var mob: Mob = get_parent()
var inventory_items: Array
var current_inventory_item: HandItem
var last_camera_x_delta: float
var slot_index: int = 0 : set = set_inventory_slot

@export var r_arm: IkArm
@export var l_arm: IkArm

func _ready():
	inventory_items.push_back(get_node("../Arms/PunchingArms"))
	inventory_items.push_back(get_node("../Arms/Sword"))
	equip_item.call_deferred(get_slot_item(0))
	equip_item.call_deferred(get_slot_item(1))
	slot_index = 1


func _input(event):
	if not is_multiplayer_authority(): return
	if mob.has_node("HealthComponent"):
		if mob.get_node("HealthComponent").is_dead:
			return
	
	if event is InputEventMouseMotion:
		last_camera_x_delta = event.relative.x
		return
	
	if Input.is_action_just_pressed("slot1"):
		slot_index  = 0
	if Input.is_action_just_pressed("slot2"):
		slot_index = 1
	if Input.is_action_just_pressed("slot3"):
		slot_index = 2
	if Input.is_action_just_pressed("slot4"):
		slot_index = 4
	
	if Input.is_action_just_pressed("primary"):
		if current_inventory_item:
			if current_inventory_item is Sword:
				if last_camera_x_delta > 0:
					current_inventory_item.swing_from_right = false
				else:
					current_inventory_item.swing_from_right = true
			
			current_inventory_item.primary_use()
	if Input.is_action_just_pressed("secondary"):
		if current_inventory_item:
			current_inventory_item.secondary_use()
	if Input.is_action_just_pressed("scroll_down"):
		if current_inventory_item:
			current_inventory_item.alt1_use()
	if Input.is_action_just_pressed("scroll_up"):
		if current_inventory_item:
			current_inventory_item.alt2_use()
	if Input.is_action_just_pressed("fun_attack1"):
		if current_inventory_item:
			if current_inventory_item is Sword:
				current_inventory_item.long_spiral_block()
	if Input.is_action_just_pressed("fun_attack2"):
		if current_inventory_item:
			if current_inventory_item is Sword:
				current_inventory_item.god_swing()


func get_slot_item(index: int) -> HandItem:
	#print("Equipping item: ", index)
	if inventory_items.size() > index:
		return inventory_items[index]
	return null


func equip_item(i: HandItem):
	if i == null:
		return
	
	i.register_user(mob)
	r_arm.set_ik_target(i.grab_node_r)
	l_arm.set_ik_target(i.grab_node_l)
	
	if current_inventory_item:
		current_inventory_item.visible = false
	current_inventory_item = i
	current_inventory_item.visible = true


func set_inventory_slot(new_index: int):
	if new_index == slot_index:
		return
	slot_index = new_index
	equip_item.call_deferred(get_slot_item(slot_index))
	
	if not is_multiplayer_authority(): return
	
	item_equipped.emit(slot_index)


func equip_slot(new_slot: int):
	set_inventory_slot(new_slot)
