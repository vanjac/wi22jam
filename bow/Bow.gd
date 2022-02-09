extends Node2D

const min_shoot_speed = 200
const max_shoot_speed = 1200
const max_draw_time = 1

var arrow_scene = preload("res://bow/Arrow.tscn")
onready var player = get_parent()
onready var pivot = $Pivot
onready var sprite = $Pivot/Sprite
onready var charge_progress = $Charge

var draw_time = 0
var ignore_fire = true


func _ready():
	ignore_fire = true

func _process(delta):
	if ignore_fire:
		ignore_fire = false
		return

	var vec_to_mouse = get_global_mouse_position() - global_position
	if vec_to_mouse.x < 0:
		pivot.scale = Vector2(-1, 1)
		pivot.rotation = vec_to_mouse.angle() + PI
	else:
		pivot.scale = Vector2.ONE
		pivot.rotation = vec_to_mouse.angle()

	if Input.is_action_just_pressed("fire"):
		draw_time = 0
		charge_progress.visible = true
	if Input.is_action_pressed("fire"):
		draw_time += delta / Engine.time_scale
		charge_progress.value = clamp(draw_time / max_draw_time, 0, 1) * 100
		sprite.visible = true
	else:
		sprite.visible = false

	if Input.is_action_just_released("fire"):
		charge_progress.visible = false
		var arrow = arrow_scene.instance()
		var shoot_speed = lerp(min_shoot_speed, max_shoot_speed,
							   clamp(draw_time / max_draw_time, 0, 1))
		arrow.linear_velocity = vec_to_mouse.normalized() * shoot_speed
		player.get_parent().add_child(arrow)
		arrow.global_position = global_position
