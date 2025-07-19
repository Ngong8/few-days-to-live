class_name InventoryComponent
extends Node

signal update_selected_item

const NUM_HOTBAR_SLOTS = 4

var inventory : Dictionary = {
	0: ["Spear", 1],
	1: ["Shotgun", 0],
	2: ["Food", 2],
	3: ["Experimental Healing Syringe", 0],
	4: ["Shotgun Ammo", 0]
}

var active_hotbar_index : int = 0

func _ready() -> void:
	return

func _input(event: InputEvent) -> void:
	#if event is InputEventKey and event.is_pressed():
		#for i in range(1,4):
			#if event.is_action_pressed("hotbar_" + str(i)):
				#active_hotbar_index = i - 1
				#return
		#if event.is_action_pressed("swap_equipment"):
			#_active_item_scroll_down()
			#active_hotbar_index = active_hotbar_index + 1 if active_hotbar_index < NUM_HOTBAR_SLOTS else 1
	return

func _active_item_scroll_up() -> void:
	#if active_hotbar_index == 0:
		#active_hotbar_index = NUM_HOTBAR_SLOTS - 1
	#else:
		#active_hotbar_index -= 1
	active_hotbar_index = (active_hotbar_index - 1 + NUM_HOTBAR_SLOTS) % NUM_HOTBAR_SLOTS
	emit_signal("update_selected_item")
	return

func _active_item_scroll_down() -> void:
	active_hotbar_index = (active_hotbar_index + 1) % NUM_HOTBAR_SLOTS
	emit_signal("update_selected_item")
	return

func _select_specific_active_item(hotkey_index : int = 1) -> void:
	print_debug("Hotbar key pressed: " + str(hotkey_index))
	active_hotbar_index = hotkey_index - 1
	emit_signal("update_selected_item")
	return

func _add_item_quantity(item_name: String, amount: int):
	for key in inventory:
		if inventory[key][0] == item_name:
			inventory[key][1] += amount
			print_debug(item_name, " now: ", inventory[key][1])  # Debug
			return
	# Optionally, add the item if not found
	var new_key = inventory.size()
	inventory[new_key] = [item_name, amount]
