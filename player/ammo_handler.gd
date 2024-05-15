class_name AmmoHandler extends Node

@export var ammo_label: Label = null

enum ammo_type {
	BULLET,
	SMALL_BULLET
}

var ammo_storage := {
	ammo_type.BULLET: 10,
	ammo_type.SMALL_BULLET: 60
}

var current_ammo_type: ammo_type

func has_ammo(type: ammo_type) -> bool:
	return ammo_storage[type] > 0
	
func use_ammo(type: ammo_type) -> void:
	if has_ammo(type):
		ammo_storage[type] -= 1
		update_ammo_label(type)

func update_ammo_label(type: ammo_type) -> void:
	if type == current_ammo_type:
		ammo_label.text = str(ammo_storage[type])

func add_ammo(type: ammo_type, amount: int) -> void:
	ammo_storage[type] += amount
	update_ammo_label(type)
