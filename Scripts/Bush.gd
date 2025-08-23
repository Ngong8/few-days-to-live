extends Node3D


@onready var bush_mesh = $Bush01

var tween : Tween
func _sway():
	if tween:	tween.kill()
	tween = create_tween()
	tween.tween_property(bush_mesh, "rotation_degrees", Vector3(0, 0, 5), 0.15)
	tween.tween_property(bush_mesh, "rotation_degrees", Vector3(0, 0, -5), 0.3)
	tween.tween_property(bush_mesh, "rotation_degrees", Vector3(0, 0, 0), 0.15)


func _on_InteractArea_interaction() -> void:
	_sway()
	return
