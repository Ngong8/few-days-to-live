extends StaticBody3D
##This generic class implies that the objects which are static that sometimes need to design it can be damaged like characters but they can't have HitBoxComponent as they are extended from Area3D and it handles the character-like behaviour, which does not makes sense for static objects to give feedback to player as being interacted in any mean.[br][br]
##Because this serves for static version of "interacted" object, the code of the class will have mostly [code]@export[/code] and [code].has_xxxx()[/code] as not every static object need to have this complete set of parameters to be interacted to give feedback to player.
class_name StaticProps

##Provides if a static object has [code]VitalComponent[/code] attached, can call its related functions to take damage
@export var vital_component : VitalComponent
##Provides if a static object has [code]AnimationPlayer[/code] attached, can play different kinds of animation if it has such animation name exists.
@export var anim_player : AnimationPlayer

func _reset_status() -> void:
	if vital_component:
		vital_component._reset_stats()
	if anim_player:
		anim_player.play("RESET")
	return

#General zero health signal function from VitalComponent.
func _on_VitalComponent_zero_health() -> void:
	#if vital_component:
		#if vital_component.current_incapacitated > vital_component.incapacitated: #Not doing the same thing again after it's 'broken'.
			#return
	print_debug("Zero health for static prop! " + name)
	if anim_player:
		if anim_player.is_playing():	return
		if anim_player.has_animation("Broken"):
			anim_player.play("Broken")
			return
		if anim_player.has_animation("Destroy"):
			anim_player.play("Destroy")
			return
	return
