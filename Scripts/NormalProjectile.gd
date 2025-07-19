extends Node3D

@onready var velocity_component = $VelocityComponent as VelocityComponent
@onready var hit_box_component = $HitBoxComponent as HitBoxComponent
@export var distance_to_despawn : int = 20
var previous_pos : Vector3
var starting_pos : Vector3
var vertical_velocity : float
var is_despawning : bool = false
func _ready() -> void:
	#$AnimPlayer.play("RESET")
	pass

func _physics_process(delta: float) -> void:
	var new_pos : Vector3 = global_position - (global_basis.z * velocity_component.move_speed * delta)
	new_pos.y += 0.5 * velocity_component.gravity * delta * delta
	
	var query : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(previous_pos, new_pos)
	var result : Dictionary = get_world_3d().direct_space_state.intersect_ray(query)

	if result:
		new_pos = result.position
	global_position = new_pos
	previous_pos = new_pos

	if global_position.distance_squared_to(starting_pos) > pow(distance_to_despawn, 2) and not is_despawning:
		_despawn_projectile()
	pass

func _despawn_projectile() -> void:
	is_despawning = true
	#$AnimPlayer.play("Fading")
	await get_tree().create_timer(0.4).timeout
	set_physics_process(false)
	hit_box_component.set_deferred("monitoring", false)
	await get_tree().create_timer(0.5).timeout
	queue_free()
