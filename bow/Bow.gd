extends Node2D

const shoot_speed = 1000

var arrow_scene = preload("res://bow/Arrow.tscn")
var player


func _ready():
	player = get_parent()

func _process(delta):
	var vec_to_mouse = get_global_mouse_position() - global_position
	rotation = vec_to_mouse.angle()

	if Input.is_action_just_pressed("fire"):
		var arrow = arrow_scene.instance()
		arrow.linear_velocity = vec_to_mouse.normalized() * shoot_speed
		player.get_parent().add_child(arrow)
		arrow.global_position = global_position
