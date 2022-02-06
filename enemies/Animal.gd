extends "res://core/Character.gd"

const walk_speed = 150

var player

var angry = false

func _ready():
	player = get_tree().get_root().find_node("Player", true, false)

func _physics_process(delta):
	if angry:
		move_vec.x = sign(player.position.x - position.x) * walk_speed
	move_character(delta)

func _on_shot():
	angry = true
	collision_layer = 1  # move to foreground
	$Sprite.modulate = Color(1, 0, 0)  # red
