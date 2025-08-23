extends Marker3D
class_name PickupSpawner

enum Items {
	NONE, SHOTGUN_AMMO, SHOTGUN_AMMO_BOX, SHOTGUN, FOOD, SYRINGE
}

@export var spawn_item : Items
@export var spawn_item_hard : Items

const SHOTGUN_AMMO = preload("res://Scenes/Props/ShotgunAmmo.tscn")
const SHOTGUN_AMMO_BOX = preload("res://Scenes/Props/ShotgunAmmoBox.tscn")
const SHOTGUN = preload("res://Scenes/Props/Shotgun.tscn")
const FOOD = preload("res://Scenes/Props/Food.tscn")
const SYRINGE = preload("res://Scenes/Props/ExperimentalSyringe.tscn")

func _spawn_item() -> void:
	match Globals.game_difficulty:
		0:
			#Spawn items in standard difficulty:
			match spawn_item:
				Items.SHOTGUN_AMMO:
					var inst = SHOTGUN_AMMO.instantiate()
					get_tree().root.get_node("MainScene/GameWorld/Props").add_child(inst)
					inst.global_transform = global_transform
					return
				Items.SHOTGUN_AMMO_BOX:
					var inst = SHOTGUN_AMMO_BOX.instantiate()
					get_tree().root.get_node("MainScene/GameWorld/Props").add_child(inst)
					inst.global_transform = global_transform
					return
				Items.SHOTGUN:
					var inst = SHOTGUN.instantiate()
					get_tree().root.get_node("MainScene/GameWorld/Props").add_child(inst)
					inst.global_transform = global_transform
					return
				Items.FOOD:
					var inst = FOOD.instantiate()
					get_tree().root.get_node("MainScene/GameWorld/Props").add_child(inst)
					inst.global_transform = global_transform
					return
				Items.SYRINGE:
					var inst = SYRINGE.instantiate()
					get_tree().root.get_node("MainScene/GameWorld/Props").add_child(inst)
					inst.global_transform = global_transform
					return
				_:
					#print_debug("Nothing to spawn!")
					return
		1:
			#Spawn items in hard difficulty:
			match spawn_item_hard:
				Items.SHOTGUN_AMMO:
					var inst = SHOTGUN_AMMO.instantiate()
					get_tree().root.get_node("MainScene/GameWorld/Props").add_child(inst)
					inst.global_transform = global_transform
					return
				Items.SHOTGUN_AMMO_BOX:
					var inst = SHOTGUN_AMMO_BOX.instantiate()
					get_tree().root.get_node("MainScene/GameWorld/Props").add_child(inst)
					inst.global_transform = global_transform
					return
				Items.SHOTGUN:
					var inst = SHOTGUN.instantiate()
					get_tree().root.get_node("MainScene/GameWorld/Props").add_child(inst)
					inst.global_transform = global_transform
					return
				Items.FOOD:
					var inst = FOOD.instantiate()
					get_tree().root.get_node("MainScene/GameWorld/Props").add_child(inst)
					inst.global_transform = global_transform
					return
				Items.SYRINGE:
					var inst = SYRINGE.instantiate()
					get_tree().root.get_node("MainScene/GameWorld/Props").add_child(inst)
					inst.global_transform = global_transform
					return
				_:
					#print_debug("Nothing to spawn!")
					return
	return
