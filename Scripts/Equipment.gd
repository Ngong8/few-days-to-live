extends Node3D

@onready var muzzle_flash: Node3D = $Shotgun_01/MuzzleFlash
@onready var muzzle_light: OmniLight3D = $"../MuzzleLight"
@onready var gun_sfx_player: AudioStreamPlayer = $"../GunSFXPlayer"

##How many bullets in one shot.
@export var bullet_count : int = 1
##The delay time between each shot.
@export var delay_time : float = 0.5
##The spread of a weapon or tool, in degree.
@export var spread : float = 1.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	muzzle_flash.hide()
	muzzle_light.light_energy = 0.0
	return

var can_shoot : bool = true
func _physics_process(_delta: float) -> void:
	#is_aiming = true if Input.is_action_pressed("use_secondary") else false

	if Input.is_action_pressed("use_primary"):
		if can_shoot == true:
			_shoot_thing()

const NORMALPROJ = preload("res://Scenes/NormalProjectile.tscn")
var tween : Tween
var random_flash_points : Array[int] = [-90,-45,0,45,90]
func _shoot_thing() -> void:
	can_shoot = false
	gun_sfx_player.play()
	##Visualisations
	muzzle_flash.rotation_degrees.z = random_flash_points.pick_random()
#	muzzle_light.show()
	muzzle_flash.show()
	
#	_spawn_particles()
	var flashing_time : float = delay_time + 0.2
	var flash_anim : AnimationPlayer = muzzle_flash.get_node("AnimPlayer")
	if tween:
		tween.kill()
	if flash_anim.is_playing():
		flash_anim.stop()
	
	tween = create_tween()
	tween.tween_property(muzzle_light, "light_energy", 1.0, 0.03)
	#tween.tween_property(muzzle_flash.get_node("Flash"), "transparency", 0.0, 0.03)
	#tween.tween_property(muzzle_flash.get_node("Star"), "transparency", 0.0, 0.03)

	flash_anim.play("Flashing")
	tween.tween_property(muzzle_light, "light_energy", 0.0, delay_time)
	#tween.tween_property(muzzle_flash.get_node("Flash"), "transparency", 1.0, delay_time)
	#tween.tween_property(muzzle_flash.get_node("Star"), "transparency", 1.0, delay_time)
	tween.tween_property(muzzle_flash, "visible", false, flashing_time)

	##Shoot projectile
	_spawn_bullet()
	await get_tree().create_timer(delay_time).timeout
	#muzzle_flash.hide()
	can_shoot = true
	return

func _spawn_bullet() -> void:
	for i in bullet_count:
		var inst = NORMALPROJ.instantiate()
		get_tree().root.get_node("MainScene/GameWorld/Entities").add_child(inst)
		var hit_box = inst.hit_box_component as HitBoxComponent
		hit_box.avoid_target_name = "Player"
		hit_box.damage = range_atk_dmg
		inst.starting_pos = shoot_point.global_position
		inst.previous_pos = inst.starting_pos
		shoot_point.rotation_degrees.x = randf_range(-spread, spread)
		shoot_point.rotation_degrees.y = randf_range(-spread, spread)
		inst.global_transform = shoot_point.global_transform
	return
