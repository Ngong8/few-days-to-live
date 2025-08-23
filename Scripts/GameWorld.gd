extends Node3D

@export var particles_spawners : Node3D

@onready var intro_path_follow: PathFollow3D = $IntroPath/IntroPathFollow
@onready var intro_cam: Camera3D = $IntroPath/IntroPathFollow/IntroCam
@onready var intro_done_timer: Timer = $IntroPath/IntroPathFollow/IntroDoneTimer

@onready var terrain_3d: Terrain3D = $Terrain3D
@onready var hill_marker: Marker3D = $HillMarker
@onready var road_marker: Marker3D = $RoadMarker
@onready var player_spawn_marker: Marker3D = $Spawners/PlayerSpawnMarker

const PLAYER = preload("res://Scenes/Player.tscn")

var has_introcam_ended : bool = false
var can_skip_cutscene : bool = false

func _ready() -> void:
	$Entities/TestPlayer.queue_free()
	intro_cam.current = false
	$DayNightCycleAnim.play("RESET")
	#print_debug("Terrain 3D textures: " + str(terrain_3d.assets.texture_list) + " | Sizes: " + str(terrain_3d.assets.texture_list.size()))
	return

func _physics_process(delta: float) -> void:
	if not has_introcam_ended:
		if intro_path_follow.progress_ratio >= 0.25 and intro_path_follow.progress_ratio < 0.7: #Look at hill first...
			_introcam_look_at_target(hill_marker.global_position, 0.01)
		elif intro_path_follow.progress_ratio >= 0.7:
			_introcam_look_at_target(road_marker.global_position, 0.03)
		if intro_path_follow.progress_ratio >= 0.95 and intro_done_timer.is_stopped():
			intro_done_timer.start()
		if Input.is_action_just_pressed("exit_to_last_step") and can_skip_cutscene: #Skip intro cutscene.
			_intro_done()
			$ParticlesSpawnTimer.start()
	return

var intro_tween : Tween
##Will run thru the intro scene after the start game button is pressed and the horror title is done animating.
func _intro_scene() -> void:
	has_introcam_ended = false
	can_skip_cutscene = false
	Globals.current_music_index = Globals.music_index.NORMAL
	Globals._starting_music_ambient()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#intro_cam.rotation_degrees = Vector3()
	intro_cam.current = true
	intro_cam.rotation_degrees = Vector3(0,90,0)
	intro_path_follow.progress_ratio = 0.0
	await get_tree().create_timer(1.0).timeout
	can_skip_cutscene = true

	var props : Array[Node] = get_tree().get_nodes_in_group("StaticProps") + get_tree().get_nodes_in_group("DynamicProps")
	var pickup_spawners : Array[Node] = get_tree().get_nodes_in_group("PickupSpawners")

	for p in props:
		var interactable_area = p.get_node_or_null("InteractableArea")
		if not interactable_area:	continue
		if interactable_area.is_in_group("Pickups"):
			p.queue_free()

	for p in pickup_spawners:
		if p is PickupSpawner:
			p._spawn_item()

	if intro_tween: intro_tween.kill()
	intro_tween = create_tween()
	intro_tween.tween_property(intro_path_follow, "progress_ratio", 1.0, 15.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return

var intro_target_tween : Tween
func _introcam_look_at_target(target_pos : Vector3, weight : float = 0.05) -> void:
	#if intro_target_tween: intro_hill_tween.kill()
	#intro_target_tween = create_tween()
	#intro_target_tween.tween_property(intro_cam, "rotation_degrees", Vector3(0,-90,0), 2.0)

	var new_transform = intro_cam.global_transform.looking_at(target_pos, Vector3.UP)
	intro_cam.global_transform = intro_cam.global_transform.interpolate_with(new_transform, weight).orthonormalized()

	#intro_cam.look_at(target_pos, Vector3.UP)
	return

func _intro_done() -> void:
	intro_cam.current = false
	var player_inst = PLAYER.instantiate()
	get_node("Entities").add_child(player_inst)
	player_inst.global_position = player_spawn_marker.global_position
	player_inst.player_cam.current = true
	player_inst.is_gained_control = true
	has_introcam_ended = true
	$DayNightCycleAnim.play("Cycling")
	$DayNightCycleAnim.seek(120, true) #The animation starts at daytime.
	return

func _on_IntroDoneTimer_timeout() -> void:
	_intro_done()
	$ParticlesSpawnTimer.start()
	return

const PARTICLES = preload("res://Scenes/ContagiousParticles.tscn")
var spawners : Array[Node]
func _on_ParticlesSpawnTimer_timeout() -> void:
	if not particles_spawners:	return
	if spawners.size() <= 0:
		spawners = particles_spawners.get_children()
		spawners.shuffle()
	var spawner : Marker3D = spawners[-1] #Always take the last spawn marker after the array is randomly shuffled.
	spawners.pop_back()

	var particles_inst = PARTICLES.instantiate()
	$Entities.add_child(particles_inst)
	particles_inst.global_position = spawner.global_position
	return
