extends Panel

@onready var window_mode_opt_btn: OptionButton = $TabContainer/Video/MarginContainer/GridContainer/WindowModeOptBtn
@onready var window_size_opt_btn: OptionButton = $TabContainer/Video/MarginContainer/GridContainer/WindowSizeOptBtn
@onready var fps_checkbox: CheckBox = $TabContainer/Video/MarginContainer/GridContainer/FPSCheckbox
@onready var master_vol_slider: HSlider = $TabContainer/Audio/MarginContainer/GridContainer/MasterVolSlider
@onready var music_vol_slider: HSlider = $TabContainer/Audio/MarginContainer/GridContainer/MusicVolSlider
@onready var sfx_vol_slider: HSlider = $TabContainer/Audio/MarginContainer/GridContainer/SFXVolSlider

var temp_changes : bool = false

func _ready() -> void:
	hide()
	_load_game_settings_upon_start_or_discard()
	return

func _physics_process(delta: float) -> void:
	if not visible and temp_changes:
		temp_changes = false
		_save_and_apply()
	return

func _load_game_settings_upon_start_or_discard() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(Globals.master_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(Globals.music_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(Globals.sfx_volume))
	DisplayServer.window_set_mode(Globals.window_mode)
	DisplayServer.window_set_size(Globals.window_screen_size)
	var screen_id: int = DisplayServer.window_get_current_screen()
	var display_size: Vector2i = DisplayServer.screen_get_size(screen_id)
	var window_size: Vector2i = DisplayServer.window_get_size()
	var origin: Vector2i = DisplayServer.screen_get_position(screen_id)
	var target_pos: Vector2 = origin + (display_size / 2) - (window_size / 2)
	DisplayServer.window_set_position(target_pos)
	
	master_vol_slider.value = Globals.master_volume
	music_vol_slider.value = Globals.music_volume
	sfx_vol_slider.value = Globals.sfx_volume
	match Globals.window_screen_size:
		Vector2i(1920,1080):
			window_size_opt_btn.selected = 0
		Vector2i(1600,900):
			window_size_opt_btn.selected = 1
		Vector2i(1366,768):
			window_size_opt_btn.selected = 2
		Vector2i(1280,720):
			window_size_opt_btn.selected = 3
	match Globals.window_mode:
		DisplayServer.WINDOW_MODE_WINDOWED:
			window_mode_opt_btn.selected = 0
		DisplayServer.WINDOW_MODE_FULLSCREEN:
			window_mode_opt_btn.selected = 1
	fps_checkbox.button_pressed = Globals.fps_visibility
	temp_changes = false
	return

func _save_and_apply() -> void:
	Globals.master_volume = master_vol_slider.value
	Globals.music_volume = music_vol_slider.value
	Globals.sfx_volume = sfx_vol_slider.value
	match window_mode_opt_btn.selected:
		0:
			Globals.window_mode = DisplayServer.WINDOW_MODE_WINDOWED
		1:
			Globals.window_mode = DisplayServer.WINDOW_MODE_FULLSCREEN
	match window_size_opt_btn.selected:
		0:
			Globals.window_screen_size = Vector2i(1920,1080)
		1:
			Globals.window_screen_size = Vector2i(1600,900)
		2:
			Globals.window_screen_size = Vector2i(1366,768)
		3:
			Globals.window_screen_size = Vector2i(1280,720)
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(Globals.master_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(Globals.music_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(Globals.sfx_volume))
	DisplayServer.window_set_mode(Globals.window_mode)
	DisplayServer.window_set_size(Globals.window_screen_size)
	var screen_id: int = DisplayServer.window_get_current_screen()
	var display_size: Vector2i = DisplayServer.screen_get_size(screen_id)
	var window_size: Vector2i = DisplayServer.window_get_size()
	var origin: Vector2i = DisplayServer.screen_get_position(screen_id)
	var target_pos: Vector2 = origin + (display_size / 2) - (window_size / 2)
	DisplayServer.window_set_position(target_pos)
	Globals.fps_visibility = fps_checkbox.button_pressed
	Globals.fps_lbl.visible = Globals.fps_visibility
	Globals._write_gamesettings()

func _on_window_mode_opt_btn_item_selected(index: int) -> void:
	temp_changes = true
	match index:
		0:
			Globals.window_mode = DisplayServer.WINDOW_MODE_WINDOWED
		1:
			Globals.window_mode = DisplayServer.WINDOW_MODE_FULLSCREEN
	DisplayServer.window_set_mode(Globals.window_mode)
	DisplayServer.window_set_size(Globals.window_screen_size)
	var screen_id: int = DisplayServer.window_get_current_screen()
	var display_size: Vector2i = DisplayServer.screen_get_size(screen_id)
	var window_size: Vector2i = DisplayServer.window_get_size()
	var origin: Vector2i = DisplayServer.screen_get_position(screen_id)
	var target_pos: Vector2 = origin + (display_size / 2) - (window_size / 2)
	DisplayServer.window_set_position(target_pos)
	return

func _on_window_size_opt_btn_item_selected(index: int) -> void:
	temp_changes = true
	match index:
		0:
			Globals.window_screen_size = Vector2i(1920,1080)
		1:
			Globals.window_screen_size = Vector2i(1600,900)
		2:
			Globals.window_screen_size = Vector2i(1366,768)
		3:
			Globals.window_screen_size = Vector2i(1280,720)
	DisplayServer.window_set_mode(Globals.window_mode)
	DisplayServer.window_set_size(Globals.window_screen_size)
	var screen_id: int = DisplayServer.window_get_current_screen()
	var display_size: Vector2i = DisplayServer.screen_get_size(screen_id)
	var window_size: Vector2i = DisplayServer.window_get_size()
	var origin: Vector2i = DisplayServer.screen_get_position(screen_id)
	var target_pos: Vector2 = origin + (display_size / 2) - (window_size / 2)
	DisplayServer.window_set_position(target_pos)
	return

func _on_master_vol_slider_value_changed(value: float) -> void:
	temp_changes = true
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

func _on_music_vol_slider_value_changed(value: float) -> void:
	temp_changes = true
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))

func _on_sfx_vol_slider_value_changed(value: float) -> void:
	temp_changes = true
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))

func _on_fps_checkbox_toggled(toggled_on: bool) -> void:
	temp_changes = true
	Globals.fps_visibility = toggled_on
	Globals.fps_lbl.visible = toggled_on
	return
