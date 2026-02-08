extends CanvasLayer

## Shop Menu UI
## Handles buying and selling items with GameState

@onready var shop_name_label: Label = $Panel/VBoxContainer/Header/ShopName
@onready var gold_label: Label = $Panel/VBoxContainer/Header/GoldLabel
@onready var item_list: ItemList = $Panel/VBoxContainer/HSplitContainer/ItemList
@onready var detail_panel: Panel = $Panel/VBoxContainer/HSplitContainer/DetailPanel
@onready var item_name_label: Label = $Panel/VBoxContainer/HSplitContainer/DetailPanel/VBoxContainer/ItemName
@onready var item_desc_label: Label = $Panel/VBoxContainer/HSplitContainer/DetailPanel/VBoxContainer/ItemDescription
@onready var price_label: Label = $Panel/VBoxContainer/HSplitContainer/DetailPanel/VBoxContainer/PriceLabel
@onready var buy_button: Button = $Panel/VBoxContainer/HSplitContainer/DetailPanel/VBoxContainer/ActionButtons/BuyButton
@onready var sell_button: Button = $Panel/VBoxContainer/HSplitContainer/DetailPanel/VBoxContainer/ActionButtons/SellButton
@onready var exit_button: Button = $Panel/VBoxContainer/Footer/ExitButton

var current_shop_id: String = ""
var current_mode: String = "buy" # "buy" or "sell"
var _gs_override = null
var selected_item_id: String = ""
var selected_item_price: int = 0

func _ready() -> void:
	# CanvasLayer-based scenes need to be visible for sub-nodes to be ready in some contexts
	# But we can hide the main panel
	if has_node("Panel"):
		$Panel.hide()
	
	# Connect signals safely
	if item_list:
		item_list.item_selected.connect(_on_item_selected)
	if buy_button:
		buy_button.pressed.connect(_on_buy_pressed)
	if sell_button:
		sell_button.pressed.connect(_on_sell_pressed)
	if exit_button:
		exit_button.pressed.connect(hide_shop)
	
	var gs = _get_gs()
	if gs and gs.has_signal("gold_changed"):
		gs.gold_changed.connect(_on_gold_changed)

func open_shop(shop_id: String) -> void:
	current_shop_id = shop_id
	var gs = _get_gs()
	if not gs: return
	
	var shop_data = gs.get_shop_data(shop_id)
	if shop_data.is_empty():
		push_error("ShopUI: Shop data not found for " + shop_id)
		return
		
	if shop_name_label:
		shop_name_label.text = shop_data.get("name", "Shop")
	update_gold_display()
	current_mode = "buy"
	_populate_item_list(shop_data.get("inventory", []))
	
	show()
	_set_player_movement_enabled(false)

func hide_shop() -> void:
	hide()
	_set_player_movement_enabled(true)

func update_gold_display() -> void:
	var gs = _get_gs()
	if gs and gold_label:
		gold_label.text = "Gold: " + str(gs.player_gold) + "g"

func _on_gold_changed(_new_gold: int) -> void:
	update_gold_display()

func _populate_item_list(items: Array) -> void:
	if not item_list: return
	item_list.clear()
	var gs = _get_gs()
	if not gs: return
	
	for item in items:
		var item_data = gs.get_item_data(item.id)
		var price = item.price
		var display_text = "%s - %dg" % [item_data.name, price]
		var idx = item_list.add_item(display_text)
		item_list.set_item_metadata(idx, item)
		
	_clear_details()

func _clear_details() -> void:
	item_name_label.text = ""
	item_desc_label.text = "Select an item to view details."
	price_label.text = ""
	buy_button.disabled = true
	sell_button.disabled = true
	selected_item_id = ""

func _on_item_selected(index: int) -> void:
	var metadata = item_list.get_item_metadata(index)
	selected_item_id = metadata.id
	selected_item_price = metadata.price
	
	var gs = _get_gs()
	if not gs: return
	
	var item_data = gs.get_item_data(selected_item_id)
	item_name_label.text = item_data.name
	item_desc_label.text = item_data.description
	price_label.text = "Price: %dg" % [selected_item_price]
	
	if current_mode == "buy":
		buy_button.disabled = gs.player_gold < selected_item_price
		buy_button.visible = true
		sell_button.visible = false
	else:
		sell_button.disabled = false # For MVP, always allow selling if owned
		sell_button.visible = true
		buy_button.visible = false

func _on_buy_pressed() -> void:
	var gs = _get_gs()
	if selected_item_id != "" and gs and gs.buy_item(selected_item_id, selected_item_price):
		print("ShopUI: Bought " + selected_item_id)
		update_gold_display()
		_on_item_selected(item_list.get_selected_items()[0])

func _on_sell_pressed() -> void:
	# Selling usually gives back percentage of price, but for now we follow shops.json price
	# or a standard 50%? Let's assume price in metadata is buy price.
	var gs = _get_gs()
	var sell_price = int(selected_item_price * 0.5) 
	if selected_item_id != "" and gs and gs.sell_item(selected_item_id, sell_price):
		print("ShopUI: Sold " + selected_item_id)
		update_gold_display()
		# If selling, we might want to refresh list if we're in "sell" mode
		pass

func _set_player_movement_enabled(enabled: bool) -> void:
	var tree = get_tree()
	if not tree: return
	var player = tree.get_first_node_in_group("player")
	if player and player.has_method("set_physics_process"):
		player.set_physics_process(enabled)
		player.set_process_unhandled_input(enabled)

func _get_gs():
	if _gs_override: return _gs_override
	var tree = Engine.get_main_loop() as SceneTree
	if tree and tree.root.has_node("GameState"):
		return tree.root.get_node("GameState")
	return null
