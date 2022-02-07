extends "res://core/Character.gd"

const walk_speed = 100
const recoil_time = 0.4
const step_time = 0.2

var sprite
var player

var angry = false
var recoil = 0
var step = 0

func _ready():
	sprite = $Sprite
	player = get_tree().get_root().find_node("Player", true, false)

func _process(delta):
	if angry:
		step += delta
		if step > step_time:
			step -= step_time
			sprite.frame = (sprite.frame + 1) % 2

func _physics_process(delta):
	if angry and is_instance_valid(player):
		var to_player = player.position.x - position.x
		if recoil > 0:
			move_vec.x = -sign(to_player) * walk_speed * (recoil / recoil_time)
			recoil -= delta
		elif abs(to_player) >= sprite.get_rect().size.x / 2:
			move_vec.x = sign(to_player) * walk_speed
		else:
			move_vec.x = 0
		sprite.scale.x = -1 if to_player >= 0 else 1
	move_character(delta)
	if angry:
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			if collision.collider.has_method("_on_attacked"):
				collision.collider._on_attacked()
				recoil = recoil_time

func _on_shot():
	angry = true
	collision_layer = 1  # move to foreground
	sprite.frame = 0
