extends CharacterBody3D

@onready var player_cam: Camera3D = $PlayerCam
@onready var hands: Node3D = $PlayerCam/Hands
@onready var equipment: Node3D = $PlayerCam/Hands/Equipment

@onready var body = $Body
@onready var muzzle_flash: Node3D = $PlayerCam/Hands/Equipment/Shotgun_01/MuzzleFlash
@onready var muzzle_light: OmniLight3D = $PlayerCam/Hands/MuzzleLight
@onready var footstep_player: AudioStreamPlayer = $FootstepPlayer
@onready var anim_player: AnimationPlayer = $AnimPlayer
@onready var perish_pnl: Panel = $HUD/PerishPnl

@export var vital_component : VitalComponent
@export var velocity_component : VelocityComponent
@export var inventory_component : InventoryComponent
@export var mouse_sensitivity : float = 0.25
@export var look_vertically_angle : float = 85

##The [code]is_gained_control[/code] flag is to determine should the player gain control to look and move around at will.
var is_gained_control : bool = false
var can_jump : bool = true
var was_on_floor : bool = true
#region Gameplay elapsed time
var elapsed : float = 0.0
var is_elapsing : bool = true
#endregion
func _ready() -> void:
	perish_pnl.hide()
	equipment._swap_to_equipment()
	return

func _input(event: InputEvent) -> void:
	if is_gained_control:
		if event is InputEventMouseMotion:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
			player_cam.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
			player_cam.rotation.x = clamp(player_cam.rotation.x, deg_to_rad(-look_vertically_angle), deg_to_rad(look_vertically_angle))

		if event is InputEventKey and event.is_pressed():
			#if not inventory_component:	return
			#for i in range(1,5):
				#if event.is_action_pressed("hotbar_" + str(i)) and inventory_component.active_hotbar_index != i - 1:
					##print_debug(str(i))
					#inventory_component._select_specific_active_item(i)
					#return
			#if event.is_action_pressed("swap_equipment"):
				#inventory_component._active_item_scroll_down()

			if event.is_action_pressed("test_damaging_self"):
				vital_component._damage_health(50)
			if event.is_action_pressed("test_infecting_self"):
				vital_component._increase_infection(10.0)
	return

func _physics_process(delta: float) -> void:
	var dir : Vector3
	
	# Just for elapsing time until the game is finished.
	if is_elapsing:
		Globals.current_time += delta
		elapsed += delta
		if Globals.current_time >= 360.0:
			Globals.current_time = 0.0
			Globals.days_passed += 1

	if not is_on_floor():
		velocity_component._apply_gravity(delta)
		if can_jump:
			can_jump = false
		if was_on_floor:
			was_on_floor = false
	else:
		if not was_on_floor:
			_play_footsteps_sfx()
			was_on_floor = true
		if (abs(velocity.x) > 1.0 or abs(velocity.z) > 1.0):
			if not footstep_player.is_playing() or (footstep_player.is_playing() and footstep_player.get_playback_position() > 0.25 and Input.is_action_pressed("sprint")):
				_play_footsteps_sfx()
		if $JumpTimer.is_stopped() and not can_jump:
			$JumpTimer.start()
		if Input.is_action_pressed("jump") and can_jump and is_gained_control:
			velocity_component._set_vertical_velocity()
			can_jump = false
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	velocity_component._set_horizontal_velocity(input_dir, delta, Input.is_action_pressed("sprint")) if is_gained_control else velocity_component._set_horizontal_velocity(Vector2(), delta)

	move_and_slide()
	_push_away_rigid_bodies(delta)

func _push_away_rigid_bodies(_delta : float):
	for i in get_slide_collision_count():
		var c := get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			c.get_collider().apply_central_impulse(-c.get_normal() * velocity_component.current_move_speed * 0.1)

const ASPHALT_FOOTSTEP_SFX = preload("res://Assets/SFX/AsphaltFootstepSFX.tres")
const GRASS_FOOTSTEP_SFX = preload("res://Assets/SFX/GrassFootstepSFX.tres")
const WATER_FOOTSTEP_SFX = preload("res://Assets/SFX/WaterFootstepSFX.tres")
func _play_footsteps_sfx() -> void:
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(global_position, global_position + Vector3(0, -500, 0))
	query.exclude = [self]
	query.collide_with_areas = true #To check areas instead of just collision bodies.
	var result: Dictionary = space_state.intersect_ray(query)
	if result:
		var node : Node = result["collider"]
		if node is StaticBody3D:
			if node.get_parent() is Terrain3D:
				var terrain_3d = node.get_parent()
				
				var base_texture_id : int = terrain_3d.data.get_texture_id(result.position).x
				var overlay_texture_id : int = terrain_3d.data.get_texture_id(result.position).y
				var blending : float = terrain_3d.data.get_texture_id(result.position).z

				if base_texture_id == texture_ids.STONE:
					if overlay_texture_id == texture_ids.GRASS:
						if blending < 0.6:
							if footstep_player.stream != ASPHALT_FOOTSTEP_SFX:
								footstep_player.stream = ASPHALT_FOOTSTEP_SFX
							#print_debug("You're walking on stone!")
						else:
							if footstep_player.stream != GRASS_FOOTSTEP_SFX:
								footstep_player.stream = GRASS_FOOTSTEP_SFX
							#print_debug("You're walking on grass!")
				else: # Default to use asphalt footsteps sfx
					if footstep_player.stream != ASPHALT_FOOTSTEP_SFX:
						footstep_player.stream = ASPHALT_FOOTSTEP_SFX
			else: #If it's not terrain3D, check the mesh's material instead.
				if node.name.begins_with("road"): #RoadManager static body
					var road_mesh : MeshInstance3D = node.get_parent()
					
					if footstep_player.stream != ASPHALT_FOOTSTEP_SFX:
						footstep_player.stream = ASPHALT_FOOTSTEP_SFX
				else: #Should be the props as static bodies.
					var node_children : Array[Node] = node.get_children()
					var static_mesh : MeshInstance3D
					for i in node_children:
						if i is MeshInstance3D:
							static_mesh = i
							#print_debug(static_mesh)
							break

					if footstep_player.stream != ASPHALT_FOOTSTEP_SFX:
						footstep_player.stream = ASPHALT_FOOTSTEP_SFX
		elif node is Area3D:
			if node.name.begins_with("Water"): #Check for water mesh.
				if footstep_player.stream != WATER_FOOTSTEP_SFX:
					footstep_player.stream = WATER_FOOTSTEP_SFX
			else: #Play asphalt sfx by default.
				if footstep_player.stream != ASPHALT_FOOTSTEP_SFX:
					footstep_player.stream = ASPHALT_FOOTSTEP_SFX
		else: #Play asphalt sfx by default if other kind of collision object(s).
			if footstep_player.stream != ASPHALT_FOOTSTEP_SFX:
				footstep_player.stream = ASPHALT_FOOTSTEP_SFX
		
	footstep_player.play()
	return

func _on_JumpTimer_timeout() -> void:
	can_jump = true

func _on_VitalComponent_zeroHealth() -> void:
	is_gained_control = false
	$HurtBoxComponent/Col.set_deferred("disabled", true)
	vital_component.current_infection_increment = vital_component.faster_infection_increment
	#Turn off basically all essential player thingy after death, and no longer to recover.
	if vital_component.current_incapacitated > vital_component.incapacitated or vital_component.current_infection_progress >= vital_component.infection_progress:
		await get_tree().create_timer(3.0).timeout
		vital_component.set_physics_process(false)
		_physics_process(false)
		get_tree().root.get_node("MainScene/GameWorld/DayNightCycleAnim").play("RESET")
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

		var elapsed_text : String = "Survived time: " + str(int(elapsed)) + " seconds (" + str(Globals.days_passed) + " day(s))"
		print_debug(elapsed_text)
		perish_pnl.show()
		$HUD/PerishPnl/ElapsedLbl.text = elapsed_text
		return
	$RecoverTimer.start() #Use default 10s to recover from incapacitated.
	return

func _on_RecoverTimer_timeout() -> void:
	vital_component.emit_signal("recover")
	return

func _on_VitalComponent_recover() -> void:
	is_gained_control = true
	$HurtBoxComponent/Col.set_deferred("disabled", false)
	vital_component.current_infection_increment = vital_component.normal_infection_increment
	vital_component.current_vitality = 40
	return

func _on_MainMenuBtn_pressed() -> void:
	print_debug("Exiting to main menu...")
	Globals._stopping_music_ambient(1.5)
	Globals.current_music_index = Globals.music_index.MENU
	Globals._starting_music_ambient()
	var props : Array[Node] = get_tree().get_nodes_in_group("StaticProps") + get_tree().get_nodes_in_group("DynamicProps")
	for p in props:
		if p is StaticProps:
			p._reset_status()
			continue
		if p is DynamicProps:
			p._reset_status()
			continue
	
	get_tree().root.get_node("MainScene/MainMenu")._reset_main_menu_thingy()
	get_tree().root.get_node("MainScene/GameWorld/ParticlesSpawnTimer").stop()
	get_tree().root.get_node("MainScene/GameWorld")
	queue_free()
	return

enum texture_ids { GRASS = 0, STONE = 1, OTHERS = 2 }
func _on_FootstepTestTimer_timeout() -> void:
	var terrain_3d : Terrain3D = get_tree().root.get_node_or_null("MainScene/GameWorld/Terrain3D")
	if terrain_3d:
		var intersection_point : Vector3 = terrain_3d.get_intersection(global_position, Vector3.DOWN * 2)
		var base_texture_id : int = terrain_3d.data.get_texture_id(intersection_point).x
		var overlay_texture_id : int = terrain_3d.data.get_texture_id(intersection_point).y
		var blending : float = terrain_3d.data.get_texture_id(intersection_point).z

		if base_texture_id == texture_ids.STONE and overlay_texture_id == texture_ids.GRASS:
			if blending < 0.9:
				print_debug("You're walking on stone!")
			else:
				print_debug("You're walking on grass!")
		print_debug("Touched the terrain: " + str(intersection_point))
		print_debug("Terrain material: " + str(terrain_3d.data.get_texture_id(intersection_point)))
		return
	pass # Replace with function body.
