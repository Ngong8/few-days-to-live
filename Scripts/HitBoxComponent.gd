extends Area3D
class_name HitBoxComponent

##The [code]entity[/code] (usually) points to the root parent node.
@export var entity : Node3D
##The flag to determine whether to spawn a decal on the surface it hits, note that not every situation it will get used even [code]spawn_decal[/code] is set to [code]true[/code].
@export var spawn_decal : bool = false
##The flag to determine whether to spawn a spark on the surface it hits, note that not every situation it will get used even [code]spawn_sparks[/code] is set to [code]true[/code].
@export var spawn_sparks : bool = false
##Set the [code]avoid_target_name[/code] to match the name of incoming HurtBoxComponent's [code]own_name[/code]. If the name is matched, the hit box will ignore the specific hurt box and deal no damage to it.
@export var avoid_target_name : String =  ""
##Set the normal damage via inspector, usually set with the damage value from the specific item like weapon(s) from ItemData data file.
@export var damage : int = 5
##Set the infection progress caused via inspector
@export var infect_value : float = 0.1
##Set this should be melee attack or not.
@export var is_melee : bool = false
var current_damage : int
#For colliding on the wall and objects for bullet hole(s), make sure the [code]entity[/code] does has its own script to have it setting collision position and normal.
var collision_position : Vector3
var collision_normal : Vector3

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
		#print_debug(avoid_target_name)
		#print_debug(area.own_name)
		if area.own_name == avoid_target_name:	return
		
		area._take_damage(current_damage)
		area._take_infection(infect_value)
		if entity:	entity.queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body.collision_layer == 1:
		#print_debug(str(body) + " - " + str(body.get_class()))
		if body is StaticProps:
			if body.vital_component: #Directly use StaticProps' VitalComponent' function.
				body.vital_component._damage_health(current_damage)
		if body is DynamicProps:
			if body.vital_component: #Directly use DynamicProps' VitalComponent' function.
				body.vital_component._damage_health(current_damage)
		if spawn_sparks:
			var spark_inst = SPARKS.instantiate()
			get_tree().root.get_node("MainScene/GameWorld/Entities").add_child(spark_inst)
			spark_inst.global_transform = global_transform
		if spawn_decal:
			var bullet_hole_inst = BULLET_HOLE.instantiate()
			get_tree().root.get_node("MainScene/GameWorld/Decals").add_child(bullet_hole_inst)
			#bullet_hole_inst.global_transform = global_transform
			bullet_hole_inst.global_position = collision_position

			#region look_at() for bullet hole display
			#if collision_normal.is_zero_approx():
				#collision_normal = Vector3.UP
			#if abs(collision_normal.dot(Vector3.UP)) < 0.99:
				#bullet_hole_inst.look_at(collision_position + collision_normal, Vector3.UP)
			#else:
				#bullet_hole_inst.look_at(collision_position + collision_normal, Vector3.FORWARD)
			#bullet_hole_inst.rotate_object_local(Vector3.RIGHT, deg_to_rad(90))
			#endregion

			#region Basis.looking_at() for bullet hole display
			var forward : Vector3 = collision_normal.normalized()
			if forward.is_zero_approx():
				forward = Vector3.UP  # fallback if physics gave us a degenerate normal
			# Pick an up vector that’s not parallel to the forward
			var up = Vector3.UP
			if abs(forward.dot(up)) > 0.99: # nearly parallel → switch to another axis
				up = Vector3.FORWARD
			# Build rotation basis (Z-axis points forward by default in Godot)
			bullet_hole_inst.global_basis = Basis().looking_at(forward, up)
			bullet_hole_inst.rotate_object_local(Vector3.RIGHT, deg_to_rad(90))
			#endregion
			
			#region Almost correct code unused
			#if not collision_normal.is_equal_approx(Vector3.UP) and not collision_normal.is_equal_approx(Vector3.DOWN):
				#bullet_hole_inst.look_at(collision_position + collision_normal, Vector3.UP)
				#bullet_hole_inst.rotate_object_local(Vector3.RIGHT, deg_to_rad(90))
			#endregion

			bullet_hole_inst.rotate_object_local(Vector3(0, 1, 0), deg_to_rad(randf_range(0.0, 360.0)))
			var decals = get_tree().get_nodes_in_group("Decals")
			if decals.size() > 100:
				decals[0].queue_free()
		if entity:
			entity.queue_free()
	elif body.collision_layer == 4 and body.is_in_group("Sparkable"):
		var spark_inst = SPARKS.instantiate()
		spark_inst.global_transform = global_transform
		if entity:
			entity.queue_free()
