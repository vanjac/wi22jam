extends "res://core/Character.gd"

const walk_decel = 200
const wake_time = 0.4
const recoil_time = 0.4
const chase_time = 10
const knockback_speed = 150
const knockback_decel = 200
const die_spin_speed = 100
const die_time = 2

const shake_time = 1
const shake_step = 1.0/15.0
const shake_move = 1

export(bool) var is_animal = false
export(float) var wake_prob = 1.0
export(float) var walk_speed = 100
export(float) var step_time = 0.2

onready var sprite = $Sprite
onready var player = get_tree().get_root().find_node("Player", true, false)

enum State { TAME, SHAKE, WAKE, CHASE, RECOIL, DIE }
var state = State.TAME
var time_in_state = 0

var step = 0
var shake_dir = 1

func _ready():
	set_state(State.TAME)
	if not is_animal:
		sprite.light_mask = 2  # anger_light

func _process(delta):
	time_in_state += delta

	match state:
		State.SHAKE:
			step += delta
			if step > shake_step:
				step -= shake_step
				position.x += shake_move * shake_dir
				shake_dir *= -1
			if time_in_state >= shake_time:
				set_state(State.WAKE)
		State.WAKE:
			if time_in_state >= wake_time:
				set_state(State.CHASE)
		State.CHASE:
			step += delta
			if step > step_time:
				step -= step_time
				sprite.frame = 2 if sprite.frame == 1 else 1
			if time_in_state >= chase_time:
				set_state(State.TAME)
		State.RECOIL:
			if time_in_state >= recoil_time:
				set_state(State.CHASE)
		State.DIE:
			rotation += sign(move_vec.x) * delta * deg2rad(die_spin_speed)
			if time_in_state >= die_time:
				queue_free()

func _physics_process(delta):
	var to_player = 0
	if is_instance_valid(player) and player.health != 0:
		to_player = player.position.x - position.x

	if state == State.CHASE:
		if abs(to_player) >= sprite.get_rect().size.x / 2:
			move_vec.x = sign(to_player) * walk_speed
			sprite.scale.x = -1 if to_player >= 0 else 1
		else:
			move_vec.x = decelerate(move_vec.x, walk_decel * delta)
	elif state != State.DIE:
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
	if randf() <= wake_prob:
		if is_animal:
			set_state(State.WAKE)
		else:
			set_state(State.SHAKE)

func _on_shot(position, direction):
	if is_animal:
		set_state(State.TAME)
	else:
		set_state(State.DIE)
	move_vec.x = direction.x * knockback_speed


func set_state(s):
	state = s
	time_in_state = 0
	match state:
		State.TAME:
			collision_layer = 4  # anger
			collision_mask = 1
			sprite.frame = 0
			z_index = -1
		State.WAKE:
			collision_layer = 8  # enemy
			collision_mask = 1 + 2 + 8 # general + player + enemy
			sprite.frame = 1
			z_index = 1
		State.DIE:
			collision_layer = 0
			collision_mask = 0  # fall through world
