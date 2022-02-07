extends KinematicBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var move_vec = Vector2(0,0)  # x component is walk, y component is grav
var on_ground = false
var snap_dist = 10

func move_character(delta):
	if on_ground:
		move_vec.y = gravity * delta
	else:
		move_vec.y += gravity * delta

	move_and_slide_with_snap(
		move_vec,									# linear_velocity
		Vector2(0, snap_dist if on_ground else 0),	# snap
		Vector2(0, -1),								# up direction
		true,										# stop_on_slope
		4,											# max_slides
		0.785398,									# floor_max_angle
		false)										# infinite_inertia
	on_ground = is_on_floor()
	if is_on_ceiling():
		move_vec.y = 0
	if is_on_wall():
		move_vec.x = 0

func accelerate(cur_vel, target_vel, rate):
	if abs(target_vel - cur_vel) > rate:
		return cur_vel + sign(target_vel - cur_vel) * rate
	else:
		return target_vel

func decelerate(cur_vel, rate):
	return accelerate(cur_vel, 0, rate)
