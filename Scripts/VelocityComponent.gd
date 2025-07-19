extends Node3D
class_name VelocityComponent

@export var entity : CharacterBody3D ## Set the parent entity.
@export var move_speed : int = 10 ## The speed of moving the entity in non-liquids.
@export var move_speed_thru_liquids : int = 4 ## The speed of moving the entity in liquids.
@export var jump_force : int = 5 ## The force of jumping while in non-liquids.
@export var jump_force_thru_liquids : int = 2 ## The force of jumping while in liquids.
@export var gravity : float = -10 ## The gravity force to make entity fall down in non-liquids.
@export var gravity_thru_liquids : float = -1 ## The gravity force to make entity fall down in liquids.
var is_in_liquid : bool = false ## Check if the entity is inside the liquid blocks, with the help of liquid detector area node.

@export var acceleration : float = 0.5 ## The value of accelerating the movement speed.
@export var air_acceleration : float = 0.1 ## The value of accelerating the movement speed while in midair.
@export var air_friction : float = 0.25 ## The value of slowing down while in midair.
@export var ground_friction : float = 0.8 ## The value of slowing down when on the ground.
var current_move_speed : int
var current_acceleration : float
var current_friction : float
@export var steer_force : int = 10 ## The value of steering force determines how fast it turns to the target.
func _ready() -> void:
	current_friction = ground_friction
	current_acceleration = acceleration

## Input the x axis value for calculating the velocity in x axis and in time-dependence delta value, for moving horizontally only.
func _set_horizontal_velocity(input_dir : Vector2, _delta : float, is_sprinting : bool = false) -> void:
	var temp_move_speed : int = move_speed
	var temp_move_speed_thru_liquids : int = move_speed_thru_liquids
	temp_move_speed = move_speed * 2 if is_sprinting else move_speed
	temp_move_speed_thru_liquids = move_speed_thru_liquids * 2 if is_sprinting else move_speed_thru_liquids
	current_friction = ground_friction if entity.is_on_floor() else air_friction
	current_acceleration = acceleration if entity.is_on_floor() else air_acceleration
	current_move_speed = temp_move_speed if not is_in_liquid else temp_move_speed_thru_liquids
	if input_dir != Vector2():
		var direction := (entity.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		entity.velocity.x = move_toward(entity.velocity.x, direction.x * current_move_speed, current_acceleration)
		entity.velocity.z = move_toward(entity.velocity.z, direction.z * current_move_speed, current_acceleration)
	else:
		entity.velocity.x = move_toward(entity.velocity.x, 0.0, current_friction)
		entity.velocity.z = move_toward(entity.velocity.z, 0.0, current_friction)
	return

## Using jump force value to move vertically only, like jumping. 
func _set_vertical_velocity() -> void:
	entity.velocity.y = jump_force if not is_in_liquid else jump_force_thru_liquids
	return

## Applying the gravity in time-dependence delta value.
## Falling down normally while in liquid, falling down slowly while in liquid.
func _apply_gravity(delta : float) -> void:
	entity.velocity.y += gravity * delta if not is_in_liquid else gravity_thru_liquids * delta
	return

## Input the vector2 value for calculating the velocity in both x and y axis, moves both horizontally and vertically, in time-dependence delta value.[br][br]
## Most usage is for moving the projectiles, like a bullet.
func _set_general_velocity(input_dir : Vector3) -> void:
	entity.velocity.x = move_toward(entity.velocity.x, input_dir.x * move_speed, current_acceleration)
	entity.velocity.y = move_toward(entity.velocity.y, input_dir.y * move_speed, current_acceleration)
	entity.velocity.z = move_toward(entity.velocity.z, input_dir.z * move_speed, current_acceleration)
	return

## Acceleration for steering the entity like a homing missile.
var steer_acceleration : Vector3
## Input the vector2 value for calculating the velocity in both x and y axis, steer acceleration with steer force value for moving in steering motion like a vehicle/missile, in time-dependence delta value.
func _set_homing_velocity(input_dir : Vector3, delta : float) -> void: # Homing velocity
	var steer : Vector3 = (input_dir * move_speed - entity.velocity).normalized() * steer_force
	steer_acceleration += steer
	entity.velocity += steer_acceleration * delta
	entity.velocity = entity.velocity.limit_length(move_speed)
#	entity.rotation = entity.velocity.angle()

## Input bounce collision value, mostly from move_and_collide() function, use velocity.bounce() function and put bounce collision's get_normal() value as a parameter to, well... Bounce.
func _bounce_velocity(bounce : KinematicCollision3D) -> void: # Bouncing velocity
	entity.velocity = entity.velocity.bounce(bounce.get_normal())
	return
