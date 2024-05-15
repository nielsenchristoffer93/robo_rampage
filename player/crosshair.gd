@tool
class_name Crosshair extends Control

func _draw() -> void:
	# Center circle of crosshair
	draw_circle(Vector2.ZERO, 4, Color.DIM_GRAY)
	draw_circle(Vector2.ZERO, 3, Color.WHITE)
	
	# Right line of crosshair
	draw_line(Vector2(16, 0), Vector2(24, 0), Color.WHITE, 2)
	# Bottom line of crosshair
	draw_line(Vector2(0, 16), Vector2(0, 24), Color.WHITE, 2)
	# Left line of crosshair
	draw_line(Vector2(-16, 0), Vector2(-24, 0), Color.WHITE, 2)
	# Top line of crosshair
	draw_line(Vector2(0, -16), Vector2(0, -24), Color.WHITE, 2)
