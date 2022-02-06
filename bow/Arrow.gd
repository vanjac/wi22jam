extends KinematicBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var linear_velocity = Vector2(0,0)
var stuck = false

func _ready():
	update_angle()

func _physics_process(delta):
	if not stuck:
		linear_velocity.y += gravity * delta
		update_angle()
		var collision = move_and_collide(linear_velocity * delta, false)
		if collision:
			stuck = true
			var t = global_transform
			get_parent().remove_child(self)
			collision.collider.add_child(self)
			global_transform = t

func update_angle():
	rotation = linear_velocity.angle()
