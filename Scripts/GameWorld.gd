extends Node3D

@onready var intro_path_follow: PathFollow3D = $IntroPath/IntroPathFollow
@onready var intro_cam: Camera3D = $IntroPath/IntroPathFollow/IntroCam
@onready var intro_done_timer: Timer = $IntroPath/IntroPathFollow/IntroDoneTimer

@onready var terrain_3d: Terrain3D = $Terrain3D
@onready var player_spawn_marker: Marker3D = $PlayerSpawnMarker
@onready var particles_spawners: Node3D = $ParticlesSpawners

const PLAYER = preload("res://Scenes/Player.tscn")

var has_introcam_look_at_hill : bool = false
var can_control_player : bool = false

func _ready() -> void:
	$Entities/TestPlayer.queue_free()
	intro_cam.current = false
	$DayNightCycleAnim.play("RESET")
	#print_debug("Terrain 3D textures: " + str(terrain_3d.assets.texture_list) + " | Sizes: " + str(terrain_3d.assets.texture_list.size()))
	return

func _physics_process(delta: float) -> void:
	if not has_introcam_look_at_hill:
		if intro_path_follow.progress_ratio >= 0.25:
			_introcam_look_at_hill()
		if intro_path_follow.progress_ratio >= 0.95 and intro_done_timer.is_stopped():
			intro_done_timer.start()
	return

var intro_tween : Tween
##Will run thru the intro scene after the start game button is pressed and the horror title is done animating.
func _intro_scene() -> void:
	Globals.current_music_index = Globals.music_index.NORMAL
	Globals._starting_music_ambient()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#intro_cam.rotation_degrees = Vector3()
	intro_cam.current = true
	intro_path_follow.progress_ratio = 0.0
	await get_tree().create_timer(1.0).timeout
	if intro_tween: intro_tween.kill()
	intro_tween = create_tween()
	intro_tween.tween_property(intro_path_follow, "progress_ratio", 1.0, 10.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return

var intro_hill_tween : Tween
func _introcam_look_at_hill() -> void:
	#if intro_hill_tween: intro_hill_tween.kill()
	#intro_hill_tween = create_tween()
	#intro_hill_tween.tween_property(intro_cam, "rotation_degrees", Vector3(0,-90,0), 2.0)

	var new_transform = intro_cam.global_transform.looking_at(player_spawn_marker.global_position, Vector3.UP)
	intro_cam.global_transform = intro_cam.global_transform.interpolate_with(new_transform, 0.05).orthonormalized()

	#intro_cam.look_at(player_spawn_marker.global_position, Vector3.UP)
	return

func _intro_done() -> void:
	intro_cam.current = false
	var player_inst = PLAYER.instantiate()
	get_node("Entities").add_child(player_inst)
	player_inst.global_position = player_spawn_marker.global_position
	player_inst.player_cam.current = true
	player_inst.is_gained_control = true
	has_introcam_look_at_hill = true
	$DayNightCycleAnim.play("Cycling")
	return

func _on_IntroDoneTimer_timeout() -> void:
	_intro_done()
	$ParticlesSpawnTimer.start()
	return

const PARTICLES = preload("res://Scenes/ContagiousParticles.tscn")
func _on_ParticlesSpawnTimer_timeout() -> void:
	var spawner : Marker3D = particles_spawners.get_children().pick_random()
	var particles_inst = PARTICLES.instantiate()
	$Entities.add_child(particles_inst)
	particles_inst.global_position = spawner.global_position
	return
