extends Mob
class_name FpsCharacter

## First Person Player Controller
## Made with the help of Lukky's Ultimate FPS Controller tutorial: https://www.youtube.com/watch?v=xIKErMgJ1Yk

# Player's child nodes
@onready var head_pcam: PhantomCamera3D = $Neck/Head/Eyes/FpsCharPcam
@onready var eyes = $Neck/Head/Eyes
@onready var head: Node3D = $Neck/Head
@onready var neck: Node3D = $Neck
@onready var standing_col: CollisionShape3D = $StandingCol
@onready var crouching_col: CollisionShape3D = $CrouchingCol
@onready var standing_room_cast: RayCast3D = $StandingRoomCast
@onready var fps_character_state_info: FpsCharacterStateInfo = $FpsCharacterStateInfo
@onready var continue_slide_cast: RayCast3D = $ContinueSlideCast
@onready var eyes_anim_player = $Neck/Head/Eyes/EyesAnimPlayer
@onready var eye_raycast = $Neck/Head/Eyes/FpsCharPcam/EyeRaycast
#@onready var ads_anim_player = $Neck/Head/Eyes/AdsAnimPlayer
@onready var locomotion_driver: LocomotionDriver = $LocomotionDriver
@onready var peer_name_label: Label3D = $PeerNameLabel
@onready var name_label: Label3D = $NameLabel
@onready var hide_self_body: Node3D = $Knight/KnightRig

var player_name: String : set = set_player_name

# Player Height
var crouching_depth: float = -0.5
var head_height: float = 1.7

# Player Controls
const mouse_sens: float = 0.25
var lerp_speed: float = 10.0
var air_lerp_speed: float = 3.0
var player_control_direction: Vector3 = Vector3.ZERO

# Player State
var is_walking: bool = false
var is_sprinting: bool = false
var sprint_toggled: bool = false
var is_crouching: bool = false
var is_free_looking: bool = false
var is_sliding: bool = false
var is_slide_jumping: bool = false
var is_jumping: bool = false
var last_frame_velocity: Vector3 = Vector3.ZERO

# Camera Controls
var free_look_tilt_amount: float = 5.0

# Slide Variables
var slide_timer = 0.0
var slide_timer_max = 1.0
var slide_vector: Vector2 = Vector2.ZERO
var initial_slide_vector: Vector2 = Vector2.ZERO
const SlideSpeed: float = 10.0
var slide_pending: bool = false
var slide_time_debt: float = 0.0
const MaxSlideTime = 1000.0
var slide_jump_cooldown: float = 0.0
const SlideJumpCooldownMax: float = 1.0

# Head Bob Variables
const HeadBobSprintSpeed: float = 22.0
const HeadBobWalkSpeed: float = 14.0
const HeadBobCrouchSpeed: float = 10.0
const HeadBobSprintIntensity: float = 0.20
const HeadBobWalkIntensity: float = 0.10
const HeadBobCrouchIntensity: float = 0.05
var head_bobbing_vector = Vector2.ZERO # Keeps track of x y movement
var head_bobbing_index: float = 0.0 # How far we are along the sine function
var head_bobbing_intensity: float = 0.0

# Coyote Time
var coyote_frames: int = 40 # How many in-air frames to allow jumping
var in_coyote_time: bool = false # Track whether we're in coyote time or not
var last_frame_on_floor: bool = false # Tracks if on the floor last frame
@onready var coyote_timer = $CoyoteTimer

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 1.0


func _enter_tree():
	# This code runs on the server and all of the clients
	# Server and Clients all agree that multiplayer authority belongs to this name
	# The authority of the multiplayer synchronizer belongs to this peer ID
	set_multiplayer_authority(str(name).to_int())


func _ready():
	peer_name_label.text = str(get_multiplayer_authority())
	print("Created character for peer: ", get_multiplayer_authority())
	if not is_multiplayer_authority(): return
	
	hide_self_body.hide()
	
	# Activate first person camera on startup
	head_pcam.set_priority(2)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	coyote_timer.wait_time = coyote_frames / 60.0
	coyote_timer.one_shot = true
	coyote_timer.timeout.connect(on_coyote_timeout)
	
	# Tell the server who we are
	MultiplayerMgr.register_player.rpc_id(1, get_multiplayer_authority(), player_name)
	
	GameMgr.name_changed.connect(set_player_name)
	


func _input(event):
	if not is_multiplayer_authority(): return
	if GameMgr.game_paused: return
	
	# Move the head/neck with the motion of the Mouse
	if event is InputEventMouseMotion:
		if is_free_looking:
			neck.rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
			neck.rotation.y = clamp(neck.rotation.y, deg_to_rad(-120), deg_to_rad(120))
		else:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	
	if Input.is_action_just_pressed("secondary"):
		#ads_anim_player.play("aim_down_sights")
		head_pcam.set_camera_fov(30)
	if Input.is_action_just_released("secondary"):
		head_pcam.set_camera_fov(75)
		#ads_anim_player.play("unaim_down_sights")


func _physics_process(delta):
	if not is_multiplayer_authority(): return
	if GameMgr.game_paused:
		velocity = velocity.move_toward(Vector3.ZERO, delta * lerp_speed)
		# Add the gravity.
		if not is_on_floor():
			velocity.y -= locomotion_driver.gravity * delta
		move_and_slide()
		return

	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Movement
	if Input.is_action_pressed("crouch") or is_sliding:
		handle_crouch(input_dir, delta)
	# Make sure we can uncrouch
	elif !standing_room_cast.is_colliding():
		handle_stand_up(delta)
		
		if Input.is_action_pressed("sprint"):
			sprint_toggled = true
		if input_dir == Vector2.ZERO or velocity == Vector3.ZERO:
			sprint_toggled = false
		if sprint_toggled:
			handle_sprinting(delta)
		else:
			handle_walking(delta)
	
	# Handle free look
	if Input.is_action_pressed("free_look") or is_sliding:
		handle_free_look(delta)
	else:
		reset_free_look(delta)
	
	# Handle Sliding
	if is_sliding:
		handle_slide_state(input_dir, delta)
	
	# Handle Headbob
	handle_headbob(input_dir, delta)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= locomotion_driver.gravity * delta
	
	if is_on_floor():
		is_slide_jumping = false
	
	if slide_jump_cooldown > 0:
		slide_jump_cooldown -= delta
	
	# Coyote Time
	if !is_on_floor() and last_frame_on_floor and !is_jumping:
		in_coyote_time = true
		coyote_timer.start()
		#print("Starting coyote time for ", coyote_timer.wait_time, " secs")
	last_frame_on_floor = is_on_floor()
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() or in_coyote_time):
		var initial_y_velocity: float = velocity.y
		velocity.y = locomotion_driver.jump_velocity
		is_jumping = true
		# Cancel the slide if jumping
		if is_sliding:
			if slide_jump_cooldown <= 0:
				is_slide_jumping = true
				slide_vector = input_dir
				is_sliding = false
				# Slide jumping needs more of a height boost to be viable for crossing gaps
				velocity.y = locomotion_driver.jump_velocity * 1.5
				slide_jump_cooldown = SlideJumpCooldownMax
				#print("Slide jumping")
			else:
				print("Cooling down slide jump")
				# Cancel the jump
				velocity.y = initial_y_velocity
				is_jumping = false
				return
		eyes_anim_player.play("jump")
	
	# Allow them to jump if they full stop
	if velocity.length() <= locomotion_driver.crouching_speed:
		slide_jump_cooldown = 0.0
	
	# Detect when we land
	if is_on_floor():
		is_jumping = false
		if !is_sliding:
			if last_frame_velocity.y < -10.0:
				eyes_anim_player.play("heavy_landing")
			elif last_frame_velocity.y < -5.0: 
				eyes_anim_player.play("landing")
	
	# Acceleration
	if is_on_floor():
		player_control_direction = lerp(player_control_direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_speed)
	else:
		# Air control
		if input_dir != Vector2.ZERO:
			player_control_direction = lerp(player_control_direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * air_lerp_speed)
	
	if is_sliding or is_slide_jumping:
		player_control_direction = (transform.basis * Vector3(slide_vector.x, 0, slide_vector.y)).normalized()
	if is_sliding:
		locomotion_driver.current_speed = (clampf(slide_timer, 0.0, MaxSlideTime) + clampf(slide_time_debt, 0.0, MaxSlideTime) + 0.1) * SlideSpeed
	if is_slide_jumping:
		locomotion_driver.current_speed = SlideSpeed
	
	if player_control_direction:
		velocity.x = player_control_direction.x * locomotion_driver.current_speed
		velocity.z = player_control_direction.z * locomotion_driver.current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, locomotion_driver.current_speed)
		velocity.z = move_toward(velocity.z, 0, locomotion_driver.current_speed)
	
	last_frame_velocity = velocity
	move_and_slide()
	
	update_state_info()


func handle_crouch(input_dir: Vector2, delta: float):
	if is_on_floor():
		locomotion_driver.current_speed = lerp(locomotion_driver.current_speed, locomotion_driver.crouching_speed, delta * lerp_speed)
	else:
		# Multiply the gravity
		velocity.y -= locomotion_driver.gravity * 2 * delta
	head.position.y = lerp(head.position.y, crouching_depth, delta * lerp_speed)
	standing_col.disabled = true
	crouching_col.disabled = false
	
	# If we were currently sprinting and moving
	if (is_sprinting and input_dir != Vector2.ZERO):
		#print("Crouching and also sprinting")
		slide_pending = true
	if (!is_on_floor() and input_dir != Vector2.ZERO):
		if slide_pending == false:
			#print("Wants to land into slide")
			slide_pending = true
	
	if slide_pending and !is_sliding and is_on_floor():
		start_slide(input_dir)
	
	is_walking = false
	is_sprinting = false
	is_crouching = true


func start_slide(input_dir: Vector2):
	# Sliding begin logic
	slide_pending = false
	is_sliding = true
	slide_timer = slide_timer_max
	initial_slide_vector = input_dir
	slide_vector = initial_slide_vector
	is_free_looking = true
	#print("Slide begin")


func handle_slide_state(input_dir: Vector2, delta: float):
	# Count down our slide timer every physics frame
	slide_timer -= delta
	
	# Allow the user to slightly move the direction of the slide
	if !is_slide_jumping:
		slide_vector = (initial_slide_vector + input_dir).normalized()
	
	# See if we are on a slope, if so then keep sliding and add slide debt
	# This way you build up velocity while sliding and slide longer after steep slopes
	if continue_slide_cast.is_colliding():
		if continue_slide_cast.get_collision_point().y < global_position.y - 0.05:
			#print("Continue slide collision point is below player: ", str(global_position.y - continue_slide_cast.get_collision_point().y).pad_decimals(2), " meters")
			slide_timer = slide_timer_max
			slide_time_debt += delta
			#print("Slide timer: ", slide_timer, " seconds, slide time debt: ", slide_time_debt)
	
	# After the slide timer runs out, start counting down the slide debt
	if slide_timer <= 0:
		if clampf(slide_time_debt, 0.0, MaxSlideTime) > 0:
			slide_time_debt -= delta
			#print("burning slide time debt: ", slide_time_debt)
		else:
			# Slide end 
			slide_end()
	
	# If we are moving slow we have probably hit a wall, cancel the slide
	if velocity.length() < locomotion_driver.crouching_speed:
		#print("Not moving fast enough, cancelling slide")
		slide_end()


func slide_end():
	is_sliding = false
	slide_pending = false
	is_free_looking = false
	slide_time_debt = 0.0
	global_rotation.y = neck.global_rotation.y
	neck.rotation.y = 0.0
	#print("Slide end")


func handle_stand_up(delta: float):
	head.position.y = lerp(head.position.y, 0.0, delta * lerp_speed)
	standing_col.disabled = false
	crouching_col.disabled = true


func handle_sprinting(delta: float):
	locomotion_driver.current_speed = lerp(locomotion_driver.current_speed, locomotion_driver.sprinting_speed, delta * lerp_speed)
	
	is_walking = false
	is_sprinting = true
	is_crouching = false


func handle_walking(delta: float):
	locomotion_driver.current_speed = lerp(locomotion_driver.current_speed, locomotion_driver.walking_speed, delta * lerp_speed)
	is_walking = true
	is_sprinting = false
	is_crouching = false


func handle_free_look(delta: float):
	is_free_looking = true
		
	if is_sliding:
		eyes.rotation.z = lerp(eyes.rotation.z, -deg_to_rad(7.0), delta * lerp_speed)
	else:
		eyes.rotation.z = deg_to_rad(-neck.rotation.y * free_look_tilt_amount)


func reset_free_look(delta: float):
	is_free_looking = false
	neck.rotation.y = lerp(neck.rotation.y, 0.0, delta * lerp_speed)
	eyes.rotation.z = lerp(eyes.rotation.z, 0.0, delta * lerp_speed)


func handle_headbob(input_dir: Vector2, delta: float):
	if is_sprinting:
		head_bobbing_intensity = HeadBobSprintIntensity
		head_bobbing_index += HeadBobSprintSpeed * delta
	elif is_walking:
		head_bobbing_intensity = HeadBobWalkIntensity
		head_bobbing_index += HeadBobWalkSpeed * delta
	else:
		head_bobbing_intensity = HeadBobCrouchIntensity
		head_bobbing_index += HeadBobCrouchSpeed * delta
	
	if is_on_floor() and !is_sliding and input_dir != Vector2.ZERO:
		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index / 2) + 0.5
		
		eyes.position.y = lerp(eyes.position.y, head_bobbing_vector.y * (head_bobbing_intensity / 2.0), delta * lerp_speed)
		eyes.position.x = lerp(eyes.position.x, head_bobbing_vector.x * head_bobbing_intensity, delta * lerp_speed)
	else:
		eyes.position.y = lerp(eyes.position.y, 0.0, delta * lerp_speed)
		eyes.position.x = lerp(eyes.position.x, 0.0, delta * lerp_speed)


func on_coyote_timeout():
	in_coyote_time = false
	#print("Coyote time timed out")


func update_state_info():
	fps_character_state_info.set_speed(velocity.length())
	
	var state_str: String = "<"
	if is_crouching:
		state_str += "crouch + "
	else:
		if is_sprinting:
			state_str += "sprint + "
		elif is_walking:
			state_str += "walk + "
	
	if is_slide_jumping:
		state_str += "slidejump + "
	
	if is_sliding:
		state_str += "slide + "
	
	state_str += ">"
	fps_character_state_info.set_state(state_str)


func set_player_name(n: String):
	player_name = n
	name_label.text = n
	
	# Tell the server we have updated our name
	MultiplayerMgr.register_player.rpc_id(1, get_multiplayer_authority(), player_name)
