extends Area3D

@export var inventory_component : InventoryComponent

#For now, this to do as the player get close to the interactable objects(such as ammo, syringe, etc.) will automatically pick up an item and make the item on the ground disappears.
func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("Pickups"):
		if inventory_component:
			var entity : Node3D = area.get_parent()
			if area.is_in_group("Shotgun"):
				inventory_component._add_item_quantity("Shotgun", 1)
			elif area.is_in_group("ShotgunAmmoBox"):
				inventory_component._add_item_quantity("Shotgun Ammo", 10)
			elif area.is_in_group("ShotgunAmmo"):
				inventory_component._add_item_quantity("Shotgun Ammo", 1)
			elif area.is_in_group("Food"):
				inventory_component._add_item_quantity("Food", 1)
			elif area.is_in_group("Syringe"):
				inventory_component._add_item_quantity("Experimental Healing Syringe", 1)
			entity.queue_free()
		pass
	pass # Replace with function body.
