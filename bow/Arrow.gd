extends KinematicBody2D

const break_velocity_factor = 0.3  # slow down arrow after breaking

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
			collision_mask = 0  # disable collision

			var collided_obj = collision.collider
			var t = global_transform
			get_parent().remove_child(self)
			collided_obj.add_child(self)
			global_transform = t

			if collided_obj.has_method("_on_shot"):
				var dir = linear_velocity.normalized()
				if collided_obj.call("_on_shot", collision.position, dir):
					stuck = false  # fall through world
					linear_velocity *= break_velocity_factor

func update_angle():
	rotation = linear_velocity.angle()
