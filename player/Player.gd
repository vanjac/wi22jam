extends KinematicBody2D

const walk_speed = 250
const walk_accel = 2000
const walk_decel = 700
const jump_speed = 400

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var move_vec = Vector2(0,0)  # x component is walk, y component is grav
var walk = 0  # 0, 1, or -1
var on_ground = false

func _ready():
	pass


func _process(delta):
	var left_pressed = Input.is_action_pressed("left")
	var right_pressed = Input.is_action_pressed("right")
	if left_pressed and right_pressed:
		# prioritize most recent input
		if Input.is_action_just_pressed("left"):
			walk = -1
		elif Input.is_action_just_pressed("right"):
			walk = 1
	elif left_pressed:
		walk = -1
	elif right_pressed:
		walk = 1
	else:
		walk = 0

	# update move_vec

	if Input.is_action_pressed("jump") and on_ground:
		move_vec.y = -jump_speed
	else:
		move_vec.y += gravity * delta

	if walk != 0:
		walk *= walk_speed
		var accel = walk_accel * delta
		if abs(walk - move_vec.x) > accel:
			move_vec.x += sign(walk - move_vec.x) * accel
		else:
			move_vec.x = walk
	else:
		var decel = walk_decel * delta
		if abs(move_vec.x) > decel:
			move_vec.x -= sign(move_vec.x) * decel
		else:
			move_vec.x = 0

	# TODO snap to ground
	var moved = move_and_slide(move_vec, Vector2(0, -1), true,
							   4, 0.785398, false)
	on_ground = moved.y < move_vec.y
	if on_ground:
		move_vec.y = 0
