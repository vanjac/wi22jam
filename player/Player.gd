extends "res://core/Character.gd"

export (PackedScene) var dash
const dash_speed = 4000
const dash_distance = 0.2
const dash_time = 0.2

var is_dashing = false
var can_dash = true
var dash_direction : Vector2

onready var dash_timer = $dash_timer
onready var sprite = $Sprite

const walk_speed = 200
const walk_accel = 5000
const walk_decel = 1000
const jump_speed = 400
const coyote_time = 0.1
const knockback_speed = 175
const walk_step_time = 0.14
const stand_step_time = 0.3
const dash_step_time = 1.0/15.0

var walk = 0  # 0, 1, or -1
var jumping = false
var time_since_left_ground = 0
var step = 0

var health = 4
const hurt_anim_time = 0.5
var hurt_time = 0

func _ready():
	dash_timer.connect("timeout", self, "dash_timer_timeout")


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

	# update animation

	step += delta
	if walk != 0:
		sprite.scale.x = walk
	if is_dashing:
		anim_step(dash_step_time, 6, 7)
	elif not on_ground:
		if move_vec.y < 0:
			sprite.frame = 5
		else:
			sprite.frame = 4
	else:
		if walk != 0:
			anim_step(walk_step_time, 2, 3)
		else:
			anim_step(stand_step_time, 0, 1)

	if hurt_time > 0:
		sprite.modulate = Color.white.linear_interpolate(Color(1.5, 0, 0),
			hurt_time / hurt_anim_time)
		hurt_time -= delta
	else:
		sprite.modulate = Color.white

func _physics_process(delta):
	if on_ground:
		time_since_left_ground = 0
		jumping = false
		can_dash = true
	else:
		time_since_left_ground += delta

	if walk != 0:
		var walk_vel = walk * walk_speed
		move_vec.x = accelerate(move_vec.x, walk_vel, walk_accel * delta)
	else:
		move_vec.x = decelerate(move_vec.x, walk_decel * delta)

	handle_dash()

	if (is_dashing):
		move_vec = dash_direction

	move_character(delta)

func _on_attacked(direction):
	damage(1)
	move_vec = direction * knockback_speed


func damage(amt):
	hurt_time = hurt_anim_time
	health -= amt
	if health == 0:
		queue_free()


func dash_timer_timeout():
	is_dashing = false


func handle_dash():
	if (Input.is_action_pressed("dash") && can_dash && !on_ground):
		Engine.time_scale = 0.1
	else:
		Engine.time_scale = 1

	if (Input.is_action_just_released("dash") && can_dash && !on_ground):
		is_dashing = true
		can_dash = false

		dash_direction = get_local_mouse_position()
		dash_direction = dash_direction.clamped(dash_distance)
		dash_direction *= dash_speed

		dash_timer.start(dash_time)

	if (is_dashing):
		if (on_ground): is_dashing = false
		if (is_on_wall()): is_dashing = false
		pass


func anim_step(step_time, frame_a, frame_b):
	if step > step_time:
		step -= step_time
		if sprite.frame == frame_a:
			sprite.frame = frame_b
		else:
			sprite.frame = frame_a
