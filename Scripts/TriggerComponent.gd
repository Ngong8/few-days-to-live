extends Node
class_name TriggerComponent

@export var entity : Node3D
@export var trigger_point : Node3D

@export var is_ammo_type : bool = false
@export var is_random : bool = false
##How many bullets in one shot.
@export var bullet_count : int = 1

const NORMALPROJ = preload("res://Scenes/NormalProjectile.tscn")


func _trigger_with_delay(time : float = 0.0) -> void:
	if is_ammo_type:
		_spawn_bullet()
		return
	return

func _spawn_bullet() -> void:
	for i in bullet_count:
		var inst = NORMALPROJ.instantiate()
		get_tree().root.get_node("MainScene/GameWorld/Entities").add_child(inst)
		var hit_box = inst.hit_box_component as HitBoxComponent
		inst.starting_pos = entity.global_position
		inst.previous_pos = inst.starting_pos
		inst.velocity_component.move_speed = 20 #Props triggered bullets should be slower to properly be seen.
		if is_random:
			trigger_point.rotation_degrees = Vector3.ZERO
			trigger_point.rotation_degrees.x = randf_range(-45, 45)
			trigger_point.rotation_degrees.y = randf_range(0, 360)
		inst.global_transform = trigger_point.global_transform
	return
