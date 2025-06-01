extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.hide()

func game_over() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	self.show()
	get_tree().paused = true
	pass


func _on_retry_pressed() -> void:
	get_tree().paused = false  #unpause the scene
	Game.player_health = 5
	get_tree().reload_current_scene()
