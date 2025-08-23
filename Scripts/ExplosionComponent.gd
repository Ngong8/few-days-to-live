extends Marker3D


func _explosive_dig(radius : float = 1.0) -> void:
	var terrain_3d : Terrain3D = get_tree().root.get_node_or_null("MainScene/GameWorld/Terrain3D")
	if terrain_3d:
		print_debug("Got terrain 3D!")
		#terrain_3d.data.set_pixel(Terrain3DRegion.TYPE_HEIGHT, global_position, Color(0.5, 0, 0, 1))
		#terrain_3d.data.update_maps(Terrain3DRegion.TYPE_HEIGHT, true)

		#terrain_3d.data.set_height(global_position, -radius)
		##var region : Terrain3DRegion = terrain_3d.data.get_regionp(global_position)
		##region.set_edited(true)
		#terrain_3d.data.update_maps(Terrain3DRegion.TYPE_MAX, true)
		##region.set_edited(false)
		#terrain_3d.instancer.update_mmis(true)
	return
