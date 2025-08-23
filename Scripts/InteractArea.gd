extends Area3D
##Usually connect to its parent root node like CharacterBody3D, Node3D, or other nodes such AnimationPlayer directly.
signal interaction

@export var inventory_component : InventoryComponent
##Set the [code]avoid_target_name[/code] to match the name of incoming HurtBoxComponent's [code]own_name[/code]. If the name is matched, the hit box will ignore the specific hurt box and deal no damage to it.
@export var avoid_target_name : String =  ""

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("interact_on_world"):
		var areas : Array[Area3D] = get_overlapping_areas()
		print_debug(areas.size())
		if areas.size() <= 0:	return
		for area in areas:
			if area is HurtBoxComponent:
				if avoid_target_name != area.own_name:
					var entity : CharacterBody3D = area.get_parent()
					if entity: #Do the things when it is interacting.
						emit_signal("interaction")
						return
				pass
			if area.is_in_group("Pickups"):
				if inventory_component:
					print_debug("Picked up an item.")
					var entity : Node3D = area.get_parent()
					if area.is_in_group("Shotgun"):
						inventory_component._add_item_quantity("Shotgun", 1)
						if inventory_component.active_hotbar_index == 1: #Auto-switch to equip a shotgun if the player pick up one.
							inventory_component._select_specific_active_item(2)
					elif area.is_in_group("ShotgunAmmoBox"):
						inventory_component._add_item_quantity("Shotgun Ammo", 12)
					elif area.is_in_group("ShotgunAmmo"):
						inventory_component._add_item_quantity("Shotgun Ammo", 1)
					elif area.is_in_group("Food"):
						inventory_component._add_item_quantity("Food", 1)
					elif area.is_in_group("Syringe"):
						inventory_component._add_item_quantity("Experimental Healing Syringe", 1)
					entity.queue_free()
				return

	return

#For now, this to do as the player get close to the interactable objects(such as ammo, syringe, etc.) will automatically pick up an item and make the item on the ground disappears.
func _on_area_entered(area: Area3D) -> void:
	return

	if area.is_in_group("Pickups"):
		if inventory_component:
			var entity : Node3D = area.get_parent()
			if area.is_in_group("Shotgun"):
				inventory_component._add_item_quantity("Shotgun", 1)
			elif area.is_in_group("ShotgunAmmoBox"):
				inventory_component._add_item_quantity("Shotgun Ammo", 12)
			elif area.is_in_group("ShotgunAmmo"):
				inventory_component._add_item_quantity("Shotgun Ammo", 1)
			elif area.is_in_group("Food"):
				inventory_component._add_item_quantity("Food", 1)
			elif area.is_in_group("Syringe"):
				inventory_component._add_item_quantity("Experimental Healing Syringe", 1)
			entity.queue_free()
		return
	if area is HurtBoxComponent:
		var entity : CharacterBody3D = area.get_parent()
		if entity: #Do the things when it is interacting.
			emit_signal("interaction")
			pass
		return
	return
