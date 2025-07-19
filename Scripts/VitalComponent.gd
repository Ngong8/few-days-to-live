extends Node
class_name VitalComponent

##[code]zero_health[/code] signal is emitted when the [code]current_hp[/code] reaches 0. Connect the signal to base entity like CharacterBody3D to do something.
signal zero_health
##[code]recover[/code] signal is usually emitted after went unconscious, wait some seconds to recover. Connect the signal to base entity like CharacterBody3D to do something.
signal recover

@export var infection_bar : ProgressBar
@export var vitality_lbl : Label
@export var slower_infection_increment : float = 0.001
@export var normal_infection_increment : float = 0.002
@export var faster_infection_increment : float = 0.005

##Determine how much damage can the character take before falling incapacitated and eventually death.
var vitality : int = 100
##Current vitality value before reaching zero. Will recover to full or certain amount after some time from incapacitated or using some items.
var current_vitality : int
##The progress of infection that inevitably leading to FINAL DEATH. The mysterious infection cannot be cured at all, but can at least slow down infection by using and doing some items and actions.
var infection_progress : float = 100.0
var incapacitated : int = 3
##The current progress of infection, gradually increasing by time, can be decreased by using some items and doing some actions, or can be increased a bit quicker by staying at infected area, taking some hits, incapacitated, etc...
##Once it reached 100%, there is no way to decrease it and start losing vitality until falling down at last time, no recorvery will occur again and reach the game ending.
var current_infection_progress : float
var current_infection_increment : float
var current_incapacitated : int
var is_unconscious : bool = false

func _ready() -> void:
	current_vitality = vitality
	current_infection_progress = 0.0
	current_infection_increment = normal_infection_increment
	current_incapacitated = 0
	_update_HUD()
	return

func _physics_process(delta: float) -> void:
	current_infection_progress += current_infection_increment
	_update_HUD()
	return

func _update_HUD() -> void:
	if infection_bar:
		infection_bar.value = current_infection_progress
		infection_bar.max_value = infection_progress
	if vitality_lbl:
		if current_vitality >= vitality:
			vitality_lbl.text = "Status: HEALTHY"
		elif current_vitality < vitality and current_vitality >= int(vitality * 0.5):
			vitality_lbl.text = "Status: ELEVATED"
		elif current_vitality < int(vitality * 0.5) and current_vitality >= int(vitality * 0.1):
			vitality_lbl.text = "Status: DANGER"
		else:
			vitality_lbl.text = "Status: CRITICAL"
	return

func _damage_health(value : int) -> void:
	var current_damage : int = value
	if current_damage <= 0:
		current_damage = 0
	if current_vitality > 0:
		print_debug("Taking damage!")
		current_vitality -= current_damage
		#if get_hit_player and not get_hit_player.is_playing():	get_hit_player.play()
	if current_vitality <= 0 and current_incapacitated <= incapacitated:
		current_vitality = 0
		current_incapacitated += 1
		emit_signal("zero_health")
	return
	
