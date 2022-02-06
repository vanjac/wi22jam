extends KinematicBody2D

const walk_speed = 250
const walk_accel = 5000
const walk_decel = 1000
const jump_speed = 400
const coyote_time = 0.17

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var move_vec = Vector2(0,0)  # x component is walk, y component is grav
var walk = 0  # 0, 1, or -1
var on_ground = false
var jumping = false
var time_since_left_ground = 0
# tells the camera which way to look
var facing = Vector2(1,0)

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

	if walk != 0:
		facing.x = walk

	# update move_vec

	if not on_ground:
		time_since_left_ground += delta

	var can_jump = on_ground or (not jumping and time_since_left_ground < coyote_time)
	if can_jump and Input.is_action_just_pressed("jump"):
		move_vec.y = -jump_speed
		jumping = true
	elif on_ground:
		move_vec.y = gravity * delta
		jumping = false
	else:
		move_vec.y += gravity * delta

	if walk != 0:
		var walk_vel = walk * walk_speed
		var accel = walk_accel * delta
		if abs(walk_vel - move_vec.x) > accel:
			move_vec.x += sign(walk_vel - move_vec.x) * accel
		else:
			move_vec.x = walk_vel
	else:
		var decel = walk_decel * delta
		if abs(move_vec.x) > decel:
			move_vec.x -= sign(move_vec.x) * decel
		else:
			move_vec.x = 0

	# TODO snap to ground
	var moved = move_and_slide(move_vec, Vector2(0, -1), true,
							   4, 0.785398, false)
	var was_on_ground = on_ground
	on_ground = moved.y < move_vec.y - 0.001
	if was_on_ground and not on_ground:
		time_since_left_ground = 0
	# wall collision
	if sign(moved.x) != sign(move_vec.x):
		move_vec.x = moved.x
	# ceiling collision
	if not on_ground and move_vec.y < 0 and moved.y >= 0:
		move_vec.y = 0
