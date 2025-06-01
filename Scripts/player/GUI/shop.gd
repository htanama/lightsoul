extends CanvasLayer

@onready var shop_item_scene: PackedScene = preload("res://Scenes/player/GUI/shop_item.tscn")

var current_item: ItemData


func _ready() -> void:
	self.hide()
	get_node("buy_button/buy_complete").hide()
	for i in Game.items:
		var shop_item_temp = shop_item_scene.instantiate()
		shop_item_temp.item_info = Game.items[i]
		shop_item_temp.get_node("image").texture = Game.items[i].item_texture
		get_node("shop_items").add_child(shop_item_temp)
		get_node("item_info").hide()


func _on_buy_button_pressed() -> void:
	get_node("../container/inventory").add_item(str(current_item.item_name))
	get_node("buy_button/buy_complete").show()
	await get_tree().create_timer(1.0).timeout 
	get_node("buy_button/buy_complete").hide()


func _on_close_button_pressed() -> void:
	get_tree().paused = false
	Game.shopping = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	self.hide()
