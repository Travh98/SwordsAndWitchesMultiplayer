extends Mob

const KNIGHT_RAGDOLL = preload("res://assets/characters/knight_ragdoll.tscn")

@onready var rescan_timer = $DetectionArea/RescanTimer
@onready var detection_area: DetectionArea = $DetectionArea
@onready var navigation_agent_3d = $NavigationAgent3D
@onready var sword: HandItem = $Arms/Sword
@onready var line_of_sight_cast: RayCast3D = $LineOfSightCast
@onready var health_component: HealthComponent = $HealthComponent
@onready var mesh_instance_3d = $bodyMesh
@onready var knight: FactionMeshColor = $Knight
@onready var knight_ik_arm: IkArm = $Knight/KnightIkArmL
@onready var knight_ik_arm_2: IkArm = $Knight/KnightIkArmR

var attack_target: Mob
var angular_speed: float = 8.0
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	rescan_timer.timeout.connect(on_rescan)
	health_component.health_died.connect(on_death)
	
	match faction:
		FactionMgr.Factions.BLUE:
			mesh_instance_3d.get_active_material(0).albedo_color = Color.BLUE
		FactionMgr.Factions.RED:
			mesh_instance_3d.get_active_material(0).albedo_color = Color.RED
		_:
			pass
	knight.set_faction(faction)
	
	knight_ik_arm.set_ik_target(sword.grab_node_r)
	knight_ik_arm_2.set_ik_target(sword.grab_node_l)
	
	sword.register_user(self)


func on_rescan():
	attack_target = detection_area.scan_for_hostile_faction_members(faction)


func _physics_process(delta: float):
	if attack_target == null:
		return
	if health_component.is_dead:
		return
	
	if attack_target.global_position.distance_to(navigation_agent_3d.target_position) > 2.0:
		navigation_agent_3d.target_position = attack_target.global_position
	
	var dir_to_target: Vector3 = global_position.direction_to(attack_target.global_position)
	velocity = global_position.direction_to(navigation_agent_3d.get_next_path_position())
	rotation.y = lerp_angle(rotation.y, atan2(-dir_to_target.x, -dir_to_target.z), delta * angular_speed)
	
	line_of_sight_cast.target_position = line_of_sight_cast.to_local(attack_target.global_position + Vector3.UP)
	line_of_sight_cast.force_raycast_update()
	if line_of_sight_cast.is_colliding():
		var hit_obj = line_of_sight_cast.get_collider()
		if hit_obj == attack_target:
			if line_of_sight_cast.get_collision_point().distance_to(line_of_sight_cast.global_position) < 1:
				var rand_index: int = randi_range(0, 3)
				match rand_index:
					0:
						sword.primary_use()
					1:
						sword.alt1_use()
					2:
						sword.alt2_use()
				velocity = Vector3.ZERO
	
	if !is_on_floor():
		velocity.y -= gravity * delta
	
	move_and_slide()
	



func on_death():
	var ragdoll: Ragdoll = KNIGHT_RAGDOLL.instantiate()
	get_tree().root.add_child(ragdoll)
	ragdoll.global_position = global_position
	ragdoll.global_rotation = global_rotation
	ragdoll.start_ragdoll()
	for child in ragdoll.get_children():
		if child is FactionMeshColor:
			child.set_faction(faction)
	queue_free.call_deferred()
	pass



