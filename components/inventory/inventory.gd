extends Node
class_name BaseInventory

@onready var mob: Mob = get_parent()
var inventory_items: Array
var current_inventory_item: HandItem

@export var r_arm: IkArm
@export var l_arm: IkArm

func _ready():
	inventory_items.push_back(get_node("../Arms/PunchingArms"))
	inventory_items.push_back(get_node("../Arms/Sword"))
	equip_item.call_deferred(get_slot_item(0))
	equip_item.call_deferred(get_slot_item(1))
	
	pass

func _input(_event):
	if not is_multiplayer_authority(): return
	if mob.has_node("HealthComponent"):
		if mob.get_node("HealthComponent").is_dead:
			return
	
	if Input.is_action_just_pressed("slot1"):
		equip_item(get_slot_item(0))
	if Input.is_action_just_pressed("slot2"):
		equip_item(get_slot_item(1))
	if Input.is_action_just_pressed("slot3"):
		equip_item(get_slot_item(2))
	if Input.is_action_just_pressed("slot4"):
		equip_item(get_slot_item(3))
	
	if Input.is_action_just_pressed("primary"):
		if current_inventory_item:
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
