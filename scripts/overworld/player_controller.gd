extends CharacterBody2D

# Player movement constants
const MOVE_SPEED: float = 150.0

# Interaction detection
@onready var interaction_area: Area2D = $InteractionArea
var nearby_interactables: Array[Node] = []
var current_facing_direction: Vector2 = Vector2.DOWN
var distance_accumulator: float = 0.0
const STEP_DISTANCE: float = 32.0  # Distance to count as one step

# Animation (scene uses Polygon2D placeholder named Sprite2D)
@onready var sprite = get_node("Sprite2D")
@onready var animation_player: AnimationPlayer = $AnimationPlayer if has_node("AnimationPlayer") else null

# Signals
signal interacted_with(target: Node)

func _ready() -> void:
	# Set up collision layers
	collision_layer = 2  # Player layer
	collision_mask = 1   # Collide with world layer

	# Connect interaction area signals
	if interaction_area:
		interaction_area.area_entered.connect(_on_interactable_entered)
		interaction_area.area_exited.connect(_on_interactable_exited)
		interaction_area.body_entered.connect(_on_interactable_body_entered)
		interaction_area.body_exited.connect(_on_interactable_body_exited)

func _physics_process(_delta: float) -> void:
	# Get input direction
	var input_direction = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)

	# Normalize diagonal movement
	if input_direction.length() > 0:
		input_direction = input_direction.normalized()
		current_facing_direction = input_direction

	# Store previous position for step tracking
	var previous_position = global_position

	# Set velocity
	velocity = input_direction * MOVE_SPEED

	# Move and collide
	move_and_slide()
	
	# Track steps for encounter system
	if global_position != previous_position:
		# Player actually moved
		var distance_moved = global_position.distance_to(previous_position)
		distance_accumulator += distance_moved
		
		if distance_accumulator >= STEP_DISTANCE:
			var steps = int(distance_accumulator / STEP_DISTANCE)
			GameState.steps_since_battle += steps
			distance_accumulator -= steps * STEP_DISTANCE
			# print("Step taken! Total steps since battle: ", GameState.steps_since_battle)

	# Update animation
	_update_animation(input_direction)

func _unhandled_input(event: InputEvent) -> void:
	# Handle interaction input
	if event.is_action_pressed("interact"):
		_try_interact()
		get_viewport().set_input_as_handled()

func _update_animation(direction: Vector2) -> void:
	if not animation_player:
		return

	if direction.length() > 0:
		# Walking
		if abs(direction.x) > abs(direction.y):
			if direction.x > 0:
				animation_player.play("walk_right")
			else:
				animation_player.play("walk_left")
		else:
			if direction.y > 0:
				animation_player.play("walk_down")
			else:
				animation_player.play("walk_up")
	else:
		# Idle
		if abs(current_facing_direction.x) > abs(current_facing_direction.y):
			if current_facing_direction.x > 0:
				animation_player.play("idle_right")
			else:
				animation_player.play("idle_left")
		else:
			if current_facing_direction.y > 0:
				animation_player.play("idle_down")
			else:
				animation_player.play("idle_up")

func _try_interact() -> void:
	# Find closest interactable
	var closest_interactable: Node = null
	var closest_distance: float = INF

	for interactable in nearby_interactables:
		if not is_instance_valid(interactable):
			continue

		var distance = global_position.distance_to(_get_interactable_position(interactable))
		if distance < closest_distance:
			closest_distance = distance
			closest_interactable = interactable

	if closest_interactable:
		# Call interact method if it exists
		if closest_interactable.has_method("interact"):
			closest_interactable.interact()

		# Emit signal for external listeners
		interacted_with.emit(closest_interactable)

func _get_interactable_position(node: Node) -> Vector2:
	if node is Node2D:
		return node.global_position
	return Vector2.ZERO

func _on_interactable_entered(area: Area2D) -> void:
	if area.get_parent().has_method("interact") or area.has_method("interact"):
		var interactable = area.get_parent() if area.get_parent().has_method("interact") else area
		if not interactable in nearby_interactables:
			nearby_interactables.append(interactable)

func _on_interactable_exited(area: Area2D) -> void:
	var interactable = area.get_parent() if area.get_parent().has_method("interact") else area
	nearby_interactables.erase(interactable)

func _on_interactable_body_entered(body: Node2D) -> void:
	if body.has_method("interact") and body != self:
		if not body in nearby_interactables:
			nearby_interactables.append(body)

func _on_interactable_body_exited(body: Node2D) -> void:
	nearby_interactables.erase(body)

func has_nearby_interactables() -> bool:
	return nearby_interactables.size() > 0

func get_nearby_interactables() -> Array[Node]:
	return nearby_interactables
