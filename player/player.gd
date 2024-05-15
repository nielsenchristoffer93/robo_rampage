class_name Player extends CharacterBody3D

@export var speed := 8.0
@export var jump_height := 1.0
@export var fall_multiplier := 2.0
@export var mouse_sensitivity := 0.002
@export var max_hitpoints := 100
@export var aim_multiplier := 0.7

@onready var camera_pivot: Node3D = $CameraPivot
@onready var damage_animation_player: AnimationPlayer = $DamageTexture/DamageAnimationPlayer
@onready var game_over_menu: Control = $GameOverMenu
@onready var ammo_handler: AmmoHandler = %AmmoHandler
@onready var smooth_camera: SmoothCamera = %SmoothCamera
@onready var weapon_camera: Camera3D = %WeaponCamera

@onready var smooth_camera_fov := smooth_camera.fov
@onready var weapon_camera_fov := weapon_camera.fov

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var mouse_motion := Vector2.ZERO
var hitpoints: int = max_hitpoints:
	set(value):
		if value < hitpoints:
			damage_animation_player.stop(false)
			damage_animation_player.play("take_damage")
		hitpoints = value
		if hitpoints <= 0:
			game_over_menu.game_over()

func _ready() -> void:
	# Prevent the mouse from being able to move outside of game window.
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
	if Input.is_action_pressed("aim"):
		smooth_camera.fov = lerp(smooth_camera.fov, smooth_camera_fov * aim_multiplier, delta * 20.0)
		weapon_camera.fov = lerp(weapon_camera.fov, weapon_camera_fov * aim_multiplier, delta * 20.0)
	else:
		smooth_camera.fov = lerp(smooth_camera.fov, smooth_camera_fov, delta * 30.0)
		weapon_camera.fov = lerp(weapon_camera.fov, weapon_camera_fov, delta * 30.0)

func _physics_process(delta: float) -> void:
	# Rotate the camera based on mouse motion.
	handle_camera_rotation()
	
	# Add the gravity.
	if not is_on_floor():
		if velocity.y >= 0:
			velocity.y -= gravity * delta
		else:
			velocity.y -= gravity * delta * fall_multiplier

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		# Projectile motion formula.
		velocity.y = sqrt(jump_height * 2.0 * gravity)

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		if Input.is_action_pressed("aim"):
			velocity.x *= aim_multiplier
			velocity.z *= aim_multiplier
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		mouse_motion = -event.relative * mouse_sensitivity
		if Input.is_action_just_pressed("aim"):
			mouse_motion *= aim_multiplier
	
	# Makes the mouse available for use while the game window is open.
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Makes the mouse available in-game when clicking.
	if event.is_action_pressed("fire") and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func handle_camera_rotation() -> void:
	rotate_y(mouse_motion.x)
	camera_pivot.rotate_x(mouse_motion.y)
	camera_pivot.rotation_degrees.x = clampf(camera_pivot.rotation_degrees.x, -80.0, 80.0)
	mouse_motion = Vector2.ZERO
