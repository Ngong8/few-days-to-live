extends Node3D

@export var maincam_pathing_time : float = 10.0

@onready var main_menu: Control = $MainMenu
@onready var game_world: Node3D = $GameWorld
@onready var main_cam_path_follow: PathFollow3D = $Path3D/MainCamPathFollow
@onready var main_cam: Camera3D = $Path3D/MainCamPathFollow/MainCam
@onready var cam_path_timer: Timer = $CamPathTimer

var has_maincam_done_pathing : bool = false

func _ready() -> void:
	main_cam.current = true
	main_cam_path_follow.progress_ratio = 0.0

func _physics_process(delta: float) -> void:
	if main_cam_path_follow.progress_ratio >= 1.0 and not has_maincam_done_pathing:
		has_maincam_done_pathing = true
		#cam_path_timer.start()
		_reset_cam_path()
	pass

var tween : Tween
func _reset_cam_path() -> void:
	has_maincam_done_pathing = false
	main_cam_path_follow.progress_ratio = 0.0
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(main_cam_path_follow, "progress_ratio", 1.0, maincam_pathing_time)

func _on_cam_path_timer_timeout() -> void:
	_reset_cam_path()
