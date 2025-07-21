extends CharacterBody3D

@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D
@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var hit_box_component = $HitBoxComponent as HitBoxComponent

var player : CharacterBody3D
@export var chase_distance : float = 30.0

func _ready() -> void:
	return

func _physics_process(delta: float) -> void:
	player = get_tree().root.get_node_or_null("MainScene/GameWorld/Entities/Player")
	if not player:	return
	if global_position.distance_to(player.global_position) > chase_distance:
		velocity = velocity.move_toward((player.global_position - global_position).normalized() * velocity_component.move_speed, velocity_component.current_acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector3(), velocity_component.current_friction * delta)

	move_and_slide()

func _on_HitBoxComponent_areaEntered(area: Area3D) -> void:
	if area is HurtBoxComponent:
		if area.own_name == "Particles":	return
		hit_box_component.set_deferred("monitoring", false)
		$DelayTimer.start()

func _on_DelayTimer_timeout() -> void:
	hit_box_component.set_deferred("monitoring", true)

func _on_VitalComponent_zeroHealth() -> void:
	$AnimPlayer.play("Implode")
	gpu_particles_3d.emitting = false
	velocity = Vector3()
	_physics_process(false)
	$SFXPlayer.stop()
	$DelayTimer.stop()
	hit_box_component.set_deferred("monitoring", false)
	await get_tree().create_timer(1.25).timeout
	queue_free()
	return
