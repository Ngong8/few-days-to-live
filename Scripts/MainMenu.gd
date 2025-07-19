extends Control

@onready var start_game_btn: Button = $MenuGrid/StartGameBtn
@onready var options_btn: Button = $MenuGrid/OptionsBtn
@onready var credits_btn: Button = $MenuGrid/CreditsBtn
@onready var quit_btn: Button = $MenuGrid/QuitBtn
@onready var horror_title_lbl: Label = $HorrorTitleLbl
@onready var horror_title_pnl: Panel = $HorrorTitlePnl
@onready var dark_tint_pnl: Panel = $DarkTintPnl
@onready var options_pnl: Panel = $OptionsPnl
@onready var credits_pnl: Panel = $CreditsPnl

@onready var starting_game_player: AudioStreamPlayer = $StartingGamePlayer
@onready var anim_player: AnimationPlayer = $AnimPlayer

@export var main_scene : Node3D

##Tooltips for menu buttons: Start Game - Options - Credits - Quit
var btn_tooltips : Array[String] = ["Start game NOW! See how long you can live.", "Adjust settings to your liking.", "See who made the things of the game.", "Exit to Desktop."]

func _ready() -> void:
	_reset_main_menu_thingy()
	#_set_btns_tooltip(true)
	pass

func _input(event: InputEvent) -> void:
	if dark_tint_pnl.visible and Input.is_action_just_pressed("exit_to_last_step"):
		dark_tint_pnl.hide()
		options_pnl.hide()
		credits_pnl.hide()
	return

func _reset_main_menu_thingy() -> void:
	dark_tint_pnl.hide()
	_set_btns_tooltip(true)
	_set_menu_thingy_visibility(true)
	_set_menu_btns_disabled(false)
	_set_horror_visibility(false)
	starting_game_player.stop()
	starting_game_player.stream = load("res://Assets/SFX/750242__universfield__creepy-horror-sound.mp3")
	return

func _set_btns_tooltip(value : bool) -> void:
	if not value:
		start_game_btn.tooltip_text = ""
		options_btn.tooltip_text = ""
		credits_btn.tooltip_text = ""
		quit_btn.tooltip_text = ""
		return
	start_game_btn.tooltip_text = btn_tooltips[0]
	options_btn.tooltip_text = btn_tooltips[1]
	credits_btn.tooltip_text = btn_tooltips[2]
	quit_btn.tooltip_text = btn_tooltips[3]
	return

func _set_menu_btns_disabled(value : bool) -> void:
	start_game_btn.disabled = value
	options_btn.disabled = value
	credits_btn.disabled = value
	quit_btn.disabled = value

func _set_menu_thingy_visibility(value : bool) -> void:
	$TitleLbl.visible = value
	$MenuGrid.visible = value
	return

func _set_horror_visibility(value : bool) -> void:
	horror_title_lbl.visible = value
	horror_title_pnl.visible = value

func _starting_game_in_horror_way() -> void:
	Globals._stopping_music_ambient(1.5)
	_set_menu_btns_disabled(true)
	_set_horror_visibility(true)
	_set_btns_tooltip(false)
	anim_player.play("Starting Game")
	anim_player.queue("Transition To Game")
	starting_game_player.play()
	await get_tree().create_timer(3.0).timeout
	starting_game_player.stop()
	starting_game_player.stream = load("res://Assets/SFX/574819__wesleyextreme_gamer__horror-checkpointsaving-game-sound-effect.ogg")
	starting_game_player.play()

func _quitting_game() -> void:
	get_tree().quit()
	return

func _run_intro_scene() -> void:
	if main_scene:
		main_scene.main_cam.current = false
		main_scene.game_world._intro_scene()

func _on_start_game_btn_pressed() -> void:
	_starting_game_in_horror_way()
	return

func _on_options_btn_pressed() -> void:
	dark_tint_pnl.show()
	options_pnl.show()
	return

func _on_credits_btn_pressed() -> void:
	dark_tint_pnl.show()
	credits_pnl.show()
	return

func _on_quit_btn_pressed() -> void:
	_quitting_game()
	return
