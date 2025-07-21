extends CharacterBody3D

@onready var player_cam: Camera3D = $PlayerCam
@onready var hands: Node3D = $PlayerCam/Hands
@onready var equipment: Node3D = $PlayerCam/Hands/Equipment

@onready var body = $Body
@onready var muzzle_flash: Node3D = $PlayerCam/Hands/Equipment/Shotgun_01/MuzzleFlash
@onready var muzzle_light: OmniLight3D = $PlayerCam/Hands/MuzzleLight
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
#region Gameplay elapsed time
var elapsed : float = 0.0
var is_elapsing : bool = true
#endregion
func _ready() -> void:
	perish_pnl.hide()
	_swap_to_equipment()
	return

func _input(event: InputEvent) -> void:
	if is_gained_control:
		if event is InputEventMouseMotion:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
			player_cam.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
			player_cam.rotation.x = clamp(player_cam.rotation.x, deg_to_rad(-look_vertically_angle), deg_to_rad(look_vertically_angle))

		if event is InputEventKey and event.is_pressed():
			if not inventory_component:	return
			for i in range(1,5):
				if event.is_action_pressed("hotbar_" + str(i)):
					#print_debug(str(i))
					inventory_component._select_specific_active_item(i)
					return
			if event.is_action_pressed("swap_equipment"):
				inventory_component._active_item_scroll_down()
			if event.is_action_pressed("test_damaging_self"):
				vital_component._damage_health(50)
			if event.is_action_pressed("test_infecting_self"):
				vital_component._increase_infection(10.0)
	return

func _physics_process(delta: float) -> void:
	# Just for elapsing time until the game is finished.
	if is_elapsing:
		Globals.current_time += delta
		elapsed += delta
		if Globals.current_time >= 120.0:
			Globals.current_time = 0.0
			Globals.days_passed += 1

	if not is_on_floor():
		velocity_component._apply_gravity(delta)
		if can_jump:
			can_jump = false
	else:
		if (abs(velocity.x) > 3.0 or abs(velocity.z) > 3.0):
			if not $FootstepPlayer.is_playing() or ($FootstepPlayer.is_playing() and $FootstepPlayer.get_playback_position() > 0.25 and Input.is_action_pressed("sprint")):
				$FootstepPlayer.play()
		if $JumpTimer.is_stopped() and not can_jump:
			$JumpTimer.start()
		if Input.is_action_pressed("jump") and can_jump and is_gained_control:
			velocity_component._set_vertical_velocity()
			can_jump = false
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	velocity_component._set_horizontal_velocity(input_dir, delta, Input.is_action_pressed("sprint")) if is_gained_control else velocity_component._set_horizontal_velocity(Vector2(), delta)

	move_and_slide()

@onready var shotgun_flow: HFlowContainer = $HUD/InventorySection/ShotgunFlow
@onready var food_flow: HFlowContainer = $HUD/InventorySection/FoodFlow
@onready var syringe_flow: HFlowContainer = $HUD/InventorySection/SyringeFlow
func _swap_to_equipment() -> void:
	shotgun_flow.modulate = "#b4b4b4"
	food_flow.modulate = "#b4b4b4"
	syringe_flow.modulate = "#b4b4b4"
	
	var hotbar_index : int = inventory_component.active_hotbar_index
	print_debug("Swapping to equipment: " + str(inventory_component.inventory[hotbar_index]))
	
	var items : Array[Node] = equipment.get_children()
	for i in items.size():
		var item : Node3D = items[i]
		if i == hotbar_index:
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

func _on_JumpTimer_timeout() -> void:
	can_jump = true

func _on_InventoryComponent_updateSelectedItem() -> void:
	anim_player.play("Swapping Equipment")
	return

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
	get_tree().root.get_node("MainScene/MainMenu")._reset_main_menu_thingy()
	get_tree().root.get_node("MainScene/GameWorld/ParticlesSpawnTimer").stop()
	queue_free()
	return
