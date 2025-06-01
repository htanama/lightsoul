#skeleton_warrior_monster.gd
extends CharacterBody3D

var speed: float = 1.0
@onready var item_object_scene = preload("res://Scenes/item_object.tscn")
@onready var state_controller = get_node("StateMachine")
@export var player : CharacterBody3D
var direction: Vector3
var Awakening: bool = false
var Attacking: bool = false
var health: int = 4
var damage: int = 2
var dying: bool = false
var just_hit: bool = false

func _ready() -> void:
	#add_to_group("monster") # we can add using script or inspector
	state_controller.change_state("Idle")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if player:
		direction = (player.global_transform.origin - self.global_transform.origin ).normalized()
	else:
		state_controller.change_state("Idle")
		#direction = self.global_transform.origin 
	
	move_and_slide()


func _on_chase_player_detection_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and !dying:
		state_controller.change_state("Run")


func _on_chase_player_detection_body_exited(body: Node3D) -> void:
	if body.is_in_group("player") and !dying:
		state_controller.change_state("Idle")


func _on_attack_player_detection_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and !dying:
		state_controller.change_state("Attack")


func _on_attack_player_detection_body_exited(body: Node3D) -> void:
	if body.is_in_group("player") and !dying:
		state_controller.change_state("Run")


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if "Awaken" in anim_name:
		Awakening = false
	elif "Attack" in anim_name:
		if (player in get_node("attack_player_detection").get_overlapping_bodies()) and !dying: 
			state_controller.change_state("Attack")
	elif "Death" in anim_name:
		death()

func death() -> void:	
	#wait for 10 second before runing the next line of code
	#await get_tree().create_timer(10.0).timeout 
	var rng = randi_range(2,4)
	for i in rng:
		var item_object_temp = item_object_scene.instantiate()
		item_object_temp.global_position = self.global_position
		get_node("../../Items").add_child(item_object_temp)
	Game.gain_exp(100)
	self.queue_free()

func hit(damage: int) -> void:
	if !just_hit:
		just_hit = true
		get_node("just_hit").start() #start the timer 
		health -= damage
		if health < 0:
			state_controller.change_state("Death")
		
		#knowckback using tweening
		var tween = create_tween()
		tween.tween_property(self,"global_position",global_position - (direction/0.5), 0.2) # do it over 0.2 second


func _on_just_hit_timeout() -> void:
	just_hit = false


func _on_damage_detector_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.hit(damage)
