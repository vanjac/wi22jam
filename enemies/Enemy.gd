extends "res://core/Character.gd"

const walk_decel = 200
const wake_time = 0.4
const recoil_time = 0.4
const chase_time = 10
const step_time = 0.2
const knockback_speed = 150
const knockback_decel = 200

export(bool) var is_animal = false
export(float) var walk_speed = 100

onready var sprite = $Sprite
onready var player = get_tree().get_root().find_node("Player", true, false)

enum State { TAME, WAKE, CHASE, RECOIL }
var state = State.TAME
var time_in_state = 0

var step = 0

func _ready():
	set_state(State.TAME)

func _process(delta):
	time_in_state += delta

	match state:
		State.WAKE:
			if time_in_state >= wake_time:
				set_state(State.CHASE)
		State.CHASE:
			step += delta
			if step > step_time:
				step -= step_time
				sprite.frame = (sprite.frame + 1) % 2
			if time_in_state >= chase_time:
				set_state(State.TAME)
		State.RECOIL:
			if time_in_state >= recoil_time:
				set_state(State.CHASE)

func _physics_process(delta):
	var to_player = 0
	if is_instance_valid(player):
		to_player = player.position.x - position.x

	if state == State.CHASE:
		if abs(to_player) >= sprite.get_rect().size.x / 2:
			move_vec.x = sign(to_player) * walk_speed
			sprite.scale.x = -1 if to_player >= 0 else 1
		else:
			move_vec.x = decelerate(move_vec.x, walk_decel * delta)
	else:
		move_vec.x = decelerate(move_vec.x, knockback_decel * delta)

	move_character(delta)

	if state == State.CHASE:
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			if collision.collider.has_method("_on_attacked"):
				collision.collider._on_attacked(Vector2(sign(to_player), 0))
				set_state(State.RECOIL)
				move_vec.x = -sign(to_player) * walk_speed

func _on_angered():
	set_state(State.WAKE)

func _on_shot(position, direction):
	set_state(State.TAME)
	move_vec.x = direction.x * knockback_speed


func set_state(s):
	state = s
	time_in_state = 0
	match state:
		State.TAME:
			collision_layer = 4  # anger
			sprite.frame = 2
		State.WAKE:
			collision_layer = 1  # move to foreground
			sprite.frame = 0
