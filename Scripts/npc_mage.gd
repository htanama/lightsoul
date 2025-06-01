extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		Game.shopping = true
		get_tree().paused = true
		get_node("../../GUI/shop").show() # get_node("../../GUI/shop").show()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	$Mage/AnimationPlayer.play("Idle")
