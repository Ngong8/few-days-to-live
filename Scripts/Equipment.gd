extends Node3D

@export var entity : CharacterBody3D
@export var vitality_component : VitalComponent
@export var inventory_component : InventoryComponent
@onready var shoot_point: Node3D = $"../ShootPoint"
@onready var muzzle_flash: Node3D = $Shotgun_01/MuzzleFlash
@onready var muzzle_light: OmniLight3D = $"../MuzzleLight"
@onready var gun_sfx_player: AudioStreamPlayer = $"../GunSFXPlayer"
@onready var anim_player: AnimationPlayer = $"../../../AnimPlayer"

##How many bullets in one shot.
@export var bullet_count : int = 1
##The delay time between each shot.
@export var delay_time : float = 0.5
##The spread of a weapon or tool, in degree.
@export var spread : float = 1.0

var can_shoot : bool = true
var can_use : bool = true

func _ready() -> void:
	muzzle_flash.hide()
	muzzle_light.light_energy = 0.0
	return

func _physics_process(_delta: float) -> void:
	#is_aiming = true if Input.is_action_pressed("use_secondary") else false

	if Input.is_action_pressed("use_primary") and entity.is_gained_control:
		if get_child(1).visible and can_shoot == true and inventory_component.inventory[4][1] > 0:
			inventory_component._subtract_item_quantity("Shotgun Ammo", 1)
			_shoot_thing()
		if get_child(2).visible and inventory_component.inventory[2][1] > 0 and vitality_component.current_vitality < vitality_component.vitality - 5 and can_use:
			inventory_component._subtract_item_quantity("Food", 1)
			anim_player.play("Eating Food")
			vitality_component._heal(20)
			can_use = false
			await get_tree().create_timer(1.5).timeout
			can_use = true
		if get_child(3).visible and inventory_component.inventory[3][1] > 0 and vitality_component.current_vitality < vitality_component.vitality - 20 and can_use:
			inventory_component._subtract_item_quantity("Experimental Healing Syringe", 1)
			anim_player.play("Using Syringe")
			vitality_component._heal(50)
			vitality_component._decrease_infection(25.0)
			can_use = false
			await get_tree().create_timer(0.8).timeout
			can_use = true

const NORMALPROJ = preload("res://Scenes/NormalProjectile.tscn")
var random_flash_points : Array[int] = [-90,-45,0,45,90]
func _shoot_thing() -> void:
	can_shoot = false
	gun_sfx_player.play()
	#Visualisations
	muzzle_flash.rotation_degrees.x = random_flash_points.pick_random()
	
	if anim_player.is_playing():
		anim_player.stop()
	
	anim_player.play("Using Shotgun")
	anim_player.queue("Pump Shotgun")

	#Shoot projectile
	_spawn_bullet()
	await get_tree().create_timer(delay_time).timeout
	can_shoot = true
	return

func _spawn_bullet() -> void:
	for i in bullet_count:
		var inst = NORMALPROJ.instantiate()
		get_tree().root.get_node("MainScene/GameWorld/Entities").add_child(inst)
		var hit_box = inst.hit_box_component as HitBoxComponent
		hit_box.avoid_target_name = "Player"
		#hit_box.damage = range_atk_dmg #Use default damage from NormalProjectile for now.
		inst.starting_pos = shoot_point.global_position
		inst.previous_pos = inst.starting_pos
		shoot_point.rotation_degrees.x = randf_range(-spread, spread)
		shoot_point.rotation_degrees.y = randf_range(-spread, spread)
		inst.global_transform = shoot_point.global_transform
	return
