extends Node3D

@export var entity : CharacterBody3D
@export var player_cam : Camera3D
@export var vitality_component : VitalComponent
@export var inventory_component : InventoryComponent

@onready var melee_attack_hitbox: HitBoxComponent = $CrudeSpearModel/HitBoxComponent
@onready var shoot_point: Node3D = $"../ShootPoint"
@onready var muzzle_flash: Node3D = $Shotgun_01/MuzzleFlash
@onready var muzzle_light: OmniLight3D = $"../MuzzleLight"
@onready var gun_sfx_player: AudioStreamPlayer = $"../GunSFXPlayer"
@onready var anim_player: AnimationPlayer = $"../../../AnimPlayer"
@onready var shotgun_crosshair: TextureRect = $"../../../HUD/ShotgunCrosshair"

##How many bullets in one shot.
@export var bullet_count : int = 1
##The delay time between each shot.
@export var delay_time : float = 0.5
##The delay time between each melee attack.
@export var melee_delay_time : float = 0.5
##The spread of a weapon or tool, in degree.
@export var spread : float = 1.0

var can_shoot : bool = true
var can_use : bool = true

func _ready() -> void:
	shotgun_crosshair.hide()
	muzzle_flash.hide()
	muzzle_light.light_energy = 0.0
	melee_attack_hitbox.set_deferred("monitoring", false)
	return

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if not inventory_component or not can_use:	return
		for i in range(1,5):
			if event.is_action_pressed("hotbar_" + str(i)) and inventory_component.active_hotbar_index != i - 1:
				#print_debug(str(i))
				inventory_component._select_specific_active_item(i)
				return
		if event.is_action_pressed("swap_equipment"):
			inventory_component._active_item_scroll_down()

func _physics_process(_delta: float) -> void:
	#is_aiming = true if Input.is_action_pressed("use_secondary") else false

	if Input.is_action_pressed("use_primary") and entity.is_gained_control:
		if get_child(0).visible and can_use:
			_melee_attack()
		if get_child(1).visible and can_use and can_shoot and inventory_component.inventory[4][1] > 0:
			#inventory_component._subtract_item_quantity("Shotgun Ammo", 1)
			_shoot_thing()
		if get_child(2).visible and inventory_component.inventory[2][1] > 0 and vitality_component.current_vitality < vitality_component.vitality and can_use:
			inventory_component._subtract_item_quantity("Food", 1)
			anim_player.play("Eating Food")
			vitality_component._heal(20)
			can_use = false
			await get_tree().create_timer(anim_player.current_animation_length + 0.1).timeout
			can_use = true
		if get_child(3).visible and inventory_component.inventory[3][1] > 0 and vitality_component.current_infection_progress > 5.0 and can_use:
			inventory_component._subtract_item_quantity("Experimental Healing Syringe", 1)
			anim_player.play("Using Syringe")
			vitality_component._heal(50)
			vitality_component._decrease_infection(25.0)
			can_use = false
			await get_tree().create_timer(anim_player.current_animation_length + 0.1).timeout
			can_use = true

@export var shotgun_flow : HFlowContainer
@export var food_flow : HFlowContainer
@export var syringe_flow : HFlowContainer
func _swap_to_equipment() -> void:
	shotgun_flow.modulate = "#b4b4b4"
	food_flow.modulate = "#b4b4b4"
	syringe_flow.modulate = "#b4b4b4"
	
	var hotbar_index : int = inventory_component.active_hotbar_index
	#print_debug("Swapping to equipment: " + str(inventory_component.inventory[hotbar_index]))
	
	var items : Array[Node] = get_children()
	for i in items.size():
		var item : Node3D = items[i]
		if i == hotbar_index:
			if inventory_component.inventory[i][1] <= 0: #will not show equipped item when the specific item quantity is zero.
				continue
			item.show()
			continue
		item.hide()

	match hotbar_index:
		1:
			shotgun_flow.modulate = Color.WHITE
		2:
			food_flow.modulate = Color.WHITE
		3:
			syringe_flow.modulate = Color.WHITE
	return

func _melee_attack() -> void:
	can_use = false

	if anim_player.is_playing():
		anim_player.stop()

	anim_player.play("Using Spear")

	await get_tree().create_timer(0.25).timeout
	melee_attack_hitbox.set_deferred("monitoring", true)
	await get_tree().create_timer(melee_delay_time).timeout
	melee_attack_hitbox.set_deferred("monitoring", false)
	await get_tree().create_timer(melee_delay_time).timeout
	can_use = true
	return

const NORMALPROJ = preload("res://Scenes/NormalProjectile.tscn")
var random_flash_points : Array[int] = [-90,-60,-45,-30,-15,0,15,30,45,60,90]
var recoil_tween : Tween
func _shoot_thing() -> void:
	can_use = false
	can_shoot = false
	gun_sfx_player.play()
	#Visualisations
	if entity and player_cam:
		entity.player_cam.rotate_x(deg_to_rad(randf_range(1.5, 2.5)))
		entity.rotate_y(deg_to_rad(randf_range(-0.5, 0.5)))

	muzzle_flash.rotation_degrees.x = random_flash_points.pick_random()
	
	if anim_player.is_playing():
		anim_player.stop()
	
	anim_player.play("Using Shotgun")
	anim_player.queue("Pump Shotgun")

	#Shoot projectile
	_spawn_bullet()
	await get_tree().create_timer(delay_time).timeout
	can_use = true
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

func _on_InventoryComponent_update_selected_item() -> void:
	can_use = false
	anim_player.play("Swapping Equipment")
	await get_tree().create_timer(0.65).timeout
	if inventory_component: #For shotgun circular crosshair display only.
		if inventory_component.active_hotbar_index == 1 and inventory_component.inventory[1][1] != 0:
			shotgun_crosshair.show()
		else:
			shotgun_crosshair.hide()
	await get_tree().create_timer(0.4).timeout
	can_use = true
	return
