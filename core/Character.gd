extends KinematicBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var move_vec = Vector2(0,0)  # x component is walk, y component is grav
var on_ground = false

func move_character(delta):
	if on_ground:
		move_vec.y = gravity * delta
	else:
		move_vec.y += gravity * delta

	# TODO snap to ground
	var moved = move_and_slide(move_vec, Vector2(0, -1), true,
							   4, 0.785398, false)
	on_ground = moved.y < move_vec.y - 0.001
	# wall collision
	if sign(moved.x) != sign(move_vec.x):
		move_vec.x = moved.x
	# ceiling collision
	if not on_ground and move_vec.y < 0 and moved.y >= 0:
		move_vec.y = 0
