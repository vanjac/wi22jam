extends Node2D

const min_shoot_speed = 200
const max_shoot_speed = 1200
const max_draw_time = 1

var arrow_scene = preload("res://bow/Arrow.tscn")
var player
var pivot
var charge_progress

var draw_time = 0


func _ready():
	player = get_parent()
	pivot = $Pivot
	charge_progress = $Charge

func _process(delta):
	var vec_to_mouse = get_global_mouse_position() - global_position
	pivot.rotation = vec_to_mouse.angle()

	if Input.is_action_just_pressed("fire"):
		draw_time = 0
		charge_progress.visible = true
	if Input.is_action_pressed("fire"):
		draw_time += delta / Engine.time_scale
		charge_progress.value = clamp(draw_time / max_draw_time, 0, 1) * 100

	if Input.is_action_just_released("fire"):
		charge_progress.visible = false
		var arrow = arrow_scene.instance()
		var shoot_speed = lerp(min_shoot_speed, max_shoot_speed,
							   clamp(draw_time / max_draw_time, 0, 1))
		arrow.linear_velocity = vec_to_mouse.normalized() * shoot_speed
		player.get_parent().add_child(arrow)
		arrow.global_position = global_position
