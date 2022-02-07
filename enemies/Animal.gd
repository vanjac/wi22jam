extends "res://core/Character.gd"

const walk_speed = 150
const recoil_time = 0.4

var player

var angry = false
var recoil = 0

func _ready():
	player = get_tree().get_root().find_node("Player", true, false)

func _physics_process(delta):
	if angry and is_instance_valid(player):
		var to_player = sign(player.position.x - position.x)
		if recoil > 0:
			move_vec.x = -to_player * walk_speed * (recoil / recoil_time)
			recoil -= delta
		else:
			move_vec.x = to_player * walk_speed
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
	$Sprite.modulate = Color(1, 0, 0)  # red
