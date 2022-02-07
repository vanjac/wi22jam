extends Camera2D

export(NodePath) var player_path

const facing_offset = 120
const follow_facing_rate = 0.02
const follow_ground_rate = 0.04

var player

func _ready():
	player = get_node(player_path)


func _process(delta):
	if not is_instance_valid(player):
		return

	if player.walk != 0:
		var target_offset_x = player.walk * facing_offset
		offset.x += ((target_offset_x - offset.x)
			* pow(follow_facing_rate, delta * 60))

	global_position.x = player.global_position.x
	var player_y = player.global_position.y
	if player_y > global_position.y:
		global_position.y = player_y
	elif player.on_ground:
		global_position.y += ((player_y - global_position.y)
			* pow(follow_ground_rate, delta * 60))
