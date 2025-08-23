extends Node

enum music_index {
	MENU = 0, NORMAL = 1, TENSE = 2, HIGHLIGHT = 3
}
enum weather {
	CLEAR = 0, CLOUDY = 1, RAIN = 2, THUNDER = 3
}

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var change_music_timer: Timer = $ChangeMusicTimer
@onready var fps_lbl: Label = $FPSLbl

var current_time : float = 0.0
var days_passed : int = 0
var current_music_index : int = music_index.MENU
var current_weather : int = weather.CLEAR

#region Values from existing game settings file
const GAME_SETTINGS_PATH := "user://game_settings.json"
var version : int = 1
var game_difficulty : int = 0
var master_volume : float = 0.0
var music_volume : float = 0.0
var sfx_volume : float = 0.0
var window_mode : int = DisplayServer.WINDOW_MODE_FULLSCREEN
var window_screen_size : Vector2i = Vector2i(1280,720)
var fps_visibility : bool = false
#endregion

#region Default values when no game settings file is found
var default_game_difficulty : int = 0
var default_master_vol : float = 0.9
var default_music_vol : float = 0.8
var default_sfx_vol : float = 0.8
var default_win_mode : int = DisplayServer.WINDOW_MODE_FULLSCREEN
var default_res_size : Vector2i = Vector2i(1920,1080)
var default_fps_visibility : bool = false
#endregion

func _ready() -> void:
	_create_or_load_gamesettings()
	_starting_music_ambient(1.25)
	return

func _process(_delta: float) -> void:
	$FPSLbl.text = "FPS: " + str(Engine.get_frames_per_second())
	return

#region Create & load game settings for the game
func _create_or_load_gamesettings() -> void:
	if _gamesettings_exists():
		_load_gamesettings()
	else:
		game_difficulty = default_game_difficulty
		master_volume = default_master_vol
		music_volume = default_music_vol
		sfx_volume = default_sfx_vol
		window_mode = default_win_mode
		window_screen_size = default_res_size
		fps_visibility = default_fps_visibility
		_write_gamesettings()

func _gamesettings_exists() -> bool:
	return FileAccess.file_exists(GAME_SETTINGS_PATH)

func _write_gamesettings() -> void:
	var error := FileAccess.open(GAME_SETTINGS_PATH, FileAccess.WRITE)
	if error == null:
		printerr("Could not open the file %s. Aborting save operation. Error code: %s" % [GAME_SETTINGS_PATH, error])
		return
	var data : Dictionary = {
		"game_difficulty": game_difficulty,
		"master_volume": master_volume,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"window_mode": window_mode,
		"window_screen_size": {
			"x": window_screen_size.x,
			"y": window_screen_size.y
		},
		"fps_visibility": fps_visibility
	}
	error.store_string(JSON.stringify(data))
	error.close()
	return

func _load_gamesettings() -> Resource:
	var error := FileAccess.open(GAME_SETTINGS_PATH, FileAccess.READ)
	if error == null:
		printerr("Could not open the file %s. Aborting load operation. Error code: %s" % [GAME_SETTINGS_PATH, error])
		return
	var content = error.get_as_text()
	var data: Dictionary = JSON.parse_string(content)
	game_difficulty = data.game_difficulty if data.has("game_difficulty") else default_game_difficulty
	master_volume = data.master_volume if data.has("master_volume") else default_master_vol
	music_volume = data.music_volume if data.has("music_volume") else default_music_vol
	sfx_volume = data.sfx_volume if data.has("sfx_volume") else default_sfx_vol
	window_mode = data.window_mode if data.has("window_mode") else default_win_mode
	var temp_size = data.window_screen_size if data.has("window_screen_size") else default_res_size
	window_screen_size = Vector2i(temp_size.x, temp_size.y)
	fps_visibility = data.fps_visibility if data.has("fps_visibility") else default_fps_visibility
	error.close()
	return
#endregion

##Turning down the volume to absolute silent with input time value, but not longer than the change music timer will do.
func _stopping_music_ambient(time_value : float = 1.0) -> void:
	if not change_music_timer.is_stopped():	change_music_timer.stop()
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", -80.0, time_value)
	return

func _starting_music_ambient(time_value : float = 3.0) -> void:
	change_music_timer.start(time_value)
	return

func _music_ambient_chooser(index : int) -> void:
	match index:
		1:
			music_player.stream = load("res://Assets/MusicAmbient/horror_ambient_786086.mp3")
		2:
			music_player.stream = load("res://Assets/MusicAmbient/tense_music_785670.wav")
		3:
			music_player.stream = load("res://Assets/MusicAmbient/815021__universfield__space-30s.mp3")
		_:
			music_player.stream = load("res://Assets/MusicAmbient/815667__jadis0x__looping-piano-melody.wav")

	music_player.volume_db = 0.0
	music_player.play()

func _on_change_music_timer_timeout() -> void:
	music_player.stop()
	_music_ambient_chooser(current_music_index)
	return
