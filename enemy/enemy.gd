class_name Enemy extends CharacterBody3D

@export var attack_range := 1.5
@export var max_hitpoints := 100
@export var attack_damage := 20

const SPEED = 5.0
const aggro_range := 12.0

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var player: Player
var provoked := false
var hitpoints: int = max_hitpoints:
	set(value):
		hitpoints = value
		if hitpoints <= 0:
			queue_free()
		provoked = true

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _process(_delta: float) -> void:
	if provoked:
		navigation_agent_3d.target_position = player.global_position
	
func _physics_process(delta: float) -> void:
	# Calculate the navigation path towards the player position.
	var next_position = navigation_agent_3d.get_next_path_position()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Start moving towards player if within aggro range, if player moves
	# outside of aggro range, then don't pursue.
	var direction = global_position.direction_to(next_position)
	var distance_to_player = global_position.distance_to(player.global_position)
	provoked = true if distance_to_player <= aggro_range else false
	
	if provoked and distance_to_player <= attack_range:
		playback.travel("attack")
	
	if direction:
		look_at_target(direction)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func look_at_target(direction: Vector3) -> void:
	var adjusted_direction = direction
	adjusted_direction.y = 0
	look_at(global_position + adjusted_direction, Vector3.UP, true)

func attack() -> void:
	player.hitpoints -= attack_damage
