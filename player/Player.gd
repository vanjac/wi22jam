extends "res://core/Character.gd"

const walk_speed = 250
const walk_accel = 5000
const walk_decel = 1000
const jump_speed = 400
const coyote_time = 0.13

var walk = 0  # 0, 1, or -1
var jumping = false
var time_since_left_ground = 0

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

	var can_jump = on_ground or (not jumping and time_since_left_ground < coyote_time)
	if can_jump and Input.is_action_just_pressed("jump"):
		move_vec.y = -jump_speed
		jumping = true
		on_ground = false

func _physics_process(delta):
	if on_ground:
		time_since_left_ground = 0
		jumping = false
	else:
		time_since_left_ground += delta

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

	move_character(delta)
