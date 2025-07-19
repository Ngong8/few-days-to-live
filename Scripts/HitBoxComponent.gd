extends Area3D
class_name HitBoxComponent

##The [code]entity[/code] (usually) points to the root parent node.
@export var entity : Node3D
##The flag to determine whether to spawn a decal on the surface it hits, note that not every situation it will get used even [code]spawn_decal[/code] is set to [code]true[/code].
@export var spawn_decal : bool = false
##Set the [code]avoid_target_name[/code] to match the name of incoming HurtBoxComponent's [code]own_name[/code]. If the name is matched, the hit box will ignore the specific hurt box and deal no damage to it.
@export var avoid_target_name : String =  ""
##Set the normal damage via inspector, usually set with the damage value from the specific item like weapon(s) from ItemData data file.
@export var damage : int = 5
var current_damage : int

##The sparks particle scene for generic effect.
const SPARKS = preload("res://Scenes/Sparks.tscn")
##The bullet hole scene for generic decal.
const BULLET_HOLE = preload("res://Scenes/BulletHole.tscn")
func _ready() -> void:
	current_damage = damage
	return

## Change normal, stun damages and spread after changed by difficulty/other factors
#func _change_damage(value : int = 0) -> void:
	#damage = value
	#return
#
## Update the current combat stats whenever the one of the stats is changed
#func _update_combat_stats() -> void:
	#current_damage = damage
	#return

func _on_area_entered(area: Area3D) -> void:
	if area is HurtBoxComponent:
		print_debug(avoid_target_name)
		print_debug(area.own_name)
		if area.own_name == avoid_target_name:	return
		
		area._take_damage(current_damage, global_position)
	if entity:	entity.queue_free()

func _on_body_entered(body: Node3D) -> void:
		if body.collision_layer == 1:
			if spawn_decal:
				var spark_inst = SPARKS.instantiate()
				var bullet_hole_inst = BULLET_HOLE.instantiate()
				get_tree().root.get_node("MainScene/GameWorld/Entities").add_child(spark_inst)
				get_tree().root.get_node("MainScene/GameWorld/Decals").add_child(bullet_hole_inst)
				spark_inst.global_transform = global_transform
				bullet_hole_inst.global_transform = global_transform
				var decals = get_tree().get_nodes_in_group("Decals")
				if decals.size() > 100:
					decals[0].queue_free()
			if entity:	entity.queue_free()
