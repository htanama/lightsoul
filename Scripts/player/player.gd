extends CharacterBody3D

@onready var animation_tree = get_node("AnimationTree")
@onready var playback = animation_tree.get("parameters/playback")
@onready var player_mesh = get_node("Knight")

@export var gravity: float = 9.8
@export var jump_force: int = 9
@export var walk_speed: int = 5
@export var run_speed: int = 25


#animation name names
var idle_node_name: String = "Idle"
var walk_node_name: String = "Walk"
var run_node_name: String = "Run"
var jump_node_name: String = "Jump"
var attack1_node_name: String = "Attack1"
var death_node_name: String = "Death"

#State Machine Conditions
var is_attacking: bool 
var is_walking: bool 
var is_running: bool
var is_dying: bool

#physics values
var direction: Vector3
var horizontal_velocity: Vector3
var aim_turn: float
var movement: Vector3
var vertical_velocity: Vector3
var movement_speed: int
var angular_acceleration: float
var acceleration: float
var just_hit: bool

@onready var camrot_h = get_node("camroot/h")

func _ready() -> void:
	#Game.player_health = Game.player_health_max
	#add_to_group("player") # we can add from script or inspector
	
	var gameNode = get_node(Game.get_path())
	gameNode.level_up.connect(Callable(self, "_on_level_up"))
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		aim_turn = -event.relative.x * 0.015
	if event.is_action_pressed("aim"):
		direction = camrot_h.global_transform.basis.z


func _process(delta: float) -> void:
	var on_floor = is_on_floor()
	if !is_dying:
		attack1()
		if !on_floor:
			vertical_velocity += Vector3.DOWN * gravity * 2 * delta
		else:
			vertical_velocity = Vector3.DOWN * gravity / 10 
		if Input.is_action_just_pressed("jump") and (!is_attacking) and on_floor:
			vertical_velocity = Vector3.UP * jump_force
		angular_acceleration = 10
		movement_speed = 0
		acceleration = 15 
		
		if(attack1_node_name in playback.get_current_node()):
			is_attacking = true
			pass
		else:
			is_attacking = false
		
		var h_rot = camrot_h.global_transform.basis.get_euler().y
		if(Input.is_action_pressed("forward") || Input.is_action_pressed("backward") || Input.is_action_pressed("left") || Input.is_action_pressed("right")):
			direction = Vector3(
				Input.get_action_strength("left") - Input.get_action_strength("right"),
				0,
				Input.get_action_strength("forward") - Input.get_action_strength("backward")
			)
			direction = direction.rotated(Vector3.UP, h_rot).normalized()
			if Input.is_action_just_pressed("sprint") and (is_walking):
				movement_speed = run_speed
				is_running = true
			else:
				is_walking = true
				movement_speed = walk_speed
		else:
			is_walking = false
			is_running = false
		
		if Input.is_action_pressed("aim"):
			player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, camrot_h.rotation.y, delta * angular_acceleration)
		else:
			player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(direction.x, direction.z) - rotation.y, delta * angular_acceleration)
		
		if is_attacking:
			horizontal_velocity = horizontal_velocity.lerp(direction.normalized() * 0.1, acceleration * delta)
		else:
			horizontal_velocity = horizontal_velocity.lerp(direction.normalized() * movement_speed, acceleration * delta)
		velocity.z = horizontal_velocity.z + vertical_velocity.z
		velocity.x = horizontal_velocity.x + vertical_velocity.x
		velocity.y = vertical_velocity.y
		move_and_slide()
		
	animation_tree["parameters/conditions/IsOnFloor"] = on_floor
	animation_tree["parameters/conditions/IsInAir"] = !on_floor
	animation_tree["parameters/conditions/IsWalking"] = is_walking
	animation_tree["parameters/conditions/IsNotWalking"] = !is_walking
	animation_tree["parameters/conditions/IsRunning"] = is_running
	animation_tree["parameters/conditions/IsNotRunning"] = !is_running
	animation_tree["parameters/conditions/is_dying"] = is_dying
	


func attack1() -> void:
	if (idle_node_name in playback.get_current_node() or walk_node_name in playback.get_current_node() or run_node_name in playback.get_current_node()):
		if Input.is_action_just_pressed("attack"):
			if !is_attacking:
				playback.travel(attack1_node_name)
			

func _on_damage_detector_body_entered(body: Node3D) -> void:
	if body.is_in_group("monster") and is_attacking:
		body.hit(Game.player_damage)

func hit(damage: int) -> void:
	if !just_hit:
		get_node("just_hit").start()
		var damage_done = damage - Game.player_defense
		if damage_done > 0:
			Game.damage_player(damage_done)
			just_hit = true
			
		if Game.player_health <= 0:
			is_dying = true
			playback.travel(death_node_name)
		
		#knowckback using tweening
		var tween = create_tween()
		tween.tween_property(self,"global_position",global_position - (direction/1.5), 0.2) # do it over 0.2 second

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if "Death" in anim_name:
		#wait 10 second to play the "Death" animation and then delete/free this object
		await get_tree().create_timer(1.0).timeout 
		get_node("../gameover_overlay").game_over()
		# we can add game over menu/panel over here
		#self.queue_free()

func _on_just_hit_timeout() -> void:
	just_hit = false


func _on_level_up() -> void:
	print(Game.player_level)
	pass

#const SPEED = 5.0
#const JUMP_VELOCITY = 4.5
#
#
#func _physics_process(delta: float) -> void:
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#if direction:
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
#
	#move_and_slide()
