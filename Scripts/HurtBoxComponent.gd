extends Area3D
class_name HurtBoxComponent

@export var own_name : String = ""
@export var vital_component : VitalComponent

func _take_damage(value : int = 0) -> void:
	if value >= 0:
		vital_component._damage_health(value)
		set_deferred("monitoring", false)
		await get_tree().create_timer(0.05).timeout
		set_deferred("monitoring", true)
	return

func _take_infection(value : float = 0.0) -> void:
	if value >= 0.0:
		vital_component._increase_infection(value)
