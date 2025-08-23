extends Node
class_name VitalComponent

##[code]zero_health[/code] signal is emitted when the [code]current_hp[/code] reaches 0. Connect the signal to base entity like CharacterBody3D to do something.
signal zero_health
##[code]recover[/code] signal is usually emitted after went unconscious, wait some seconds to recover. Connect the signal to base entity like CharacterBody3D to do something.
signal recover

#region GUI thingy
@export var entity : CharacterBody3D
@export var infection_bar : ProgressBar
@export var vitality_lbl : Label
@export var incap_lbl: Label
#endregion

@export var slower_infection_increment : float = 0.001
@export var normal_infection_increment : float = 0.002
@export var faster_infection_increment : float = 0.005
@export var damage_over_ticks : float = 300.0
##Determines how much damage can the character take before falling incapacitated and eventually death.
@export var vitality : int = 100
##Determines how much can the character eat before well fed.
@export var satiety : float = 100.0
##Current vitality value before reaching zero. Will recover to full or certain amount after some time from incapacitated or using some items.
var current_vitality : int
##Current satiety value, reaching zero will make the player starts losing vitality like how the infection does, reaching at least around 75% of satiety can slowly recovering vitality.
var current_satiety : float
##The progress of the mysterious infection that inevitably leading to FINAL DEATH. The mysterious infection cannot be cured at all, but can at least slow down infection by using and doing some items and actions.
var infection_progress : float = 100.0
var incapacitated : int = 0
var standard_incapacitated : int = 2
var hard_incapacitated : int = 1
##The current progress of the mysterious infection, gradually increasing by time, can be decreased by using some items and doing some actions, or can be increased a bit quicker by staying at infected area, taking some hits, incapacitated, etc...
##Once it reached 100%, the player starts losing vitality until falling down at last time, no recorvery will occur again and reach the game ending.
var current_infection_progress : float
var current_infection_increment : float
var current_incapacitated : int
var is_unconscious : bool = false
var current_damage_over_ticks : int = 0

func _ready() -> void:
	_reset_stats()
	_update_HUD()
	return

func _physics_process(delta: float) -> void:
	if entity and entity.name == "Player": #Only for player character.
		_increase_infection(current_infection_increment)
		#current_infection_progress += current_infection_increment
		_update_HUD()
		if current_infection_progress >= infection_progress and entity.is_gained_control:
			current_damage_over_ticks += 1
			if current_damage_over_ticks > damage_over_ticks:
				_damage_health(1)
				current_damage_over_ticks = 0
		else:
			if current_damage_over_ticks > 0:
				current_damage_over_ticks = 0
	return

func _reset_stats() -> void:
	current_vitality = vitality
	current_satiety = satiety * 0.6 #Starts with some satiety.
	current_infection_progress = 0.0
	current_infection_increment = normal_infection_increment
	current_incapacitated = 0
	match Globals.game_difficulty:
		0:
			incapacitated = standard_incapacitated
		1:
			incapacitated = hard_incapacitated
		_:
			incapacitated = 0
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

	if incap_lbl:
		if current_vitality <= 0:
			incap_lbl.show()
		else:
			incap_lbl.hide()
			
	return

func _damage_health(value : int) -> void:
	var current_damage : int = value
	if current_damage <= 0:
		current_damage = 0
	if current_vitality > 0:
		#print_debug(entity.name + " is taking damage!")
		current_vitality -= current_damage
		#if get_hit_player and not get_hit_player.is_playing():	get_hit_player.play()
	if current_vitality <= 0 and current_incapacitated <= incapacitated:
		current_vitality = 0
		if entity:
			if entity.name.contains("Player"): #Only player character can has this property and only when it is not incapacitated.
				if entity.is_gained_control:
					current_incapacitated += 1
		emit_signal("zero_health")
	return

func _increase_infection(value : float) -> void:
	if value <= 0:
		value = 0
	if current_infection_progress < infection_progress:
		current_infection_progress += value
	if current_infection_progress >= infection_progress:
		current_infection_progress = infection_progress
	return

func _heal(value : int) -> void:
	if value <= 0:
		value = 0
	if current_vitality < vitality:
		current_vitality += value
	if current_vitality >= vitality:
		current_vitality = vitality
	return

func _decrease_infection(value : float) -> void:
	if value <= 0:
		value = 0
	current_infection_progress -= value
	if current_infection_progress <= 0.0:
		current_infection_progress = 0.0
	
