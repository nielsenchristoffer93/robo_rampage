class_name SmoothCamera extends Camera3D

## Controls the interpolation rate.
@export var speed := 44.0

# Smoothly follows its parent’s position and transform. 
func _physics_process(delta: float) -> void:
	var weight = clamp(delta * speed, 0.0, 1.0)
	global_transform = global_transform.interpolate_with(
		get_parent().global_transform, weight
	)
	global_position = get_parent().global_position
