extends CanvasLayer

export(NodePath) var player_path
onready var player = get_node(player_path)

onready var health_bar = $Health
var heart_scene = preload("res://ui/Heart.tscn")

var hearts = []
var last_health = 0

func _ready():
	pass

func _process(delta):
	var health = 0
	if is_instance_valid(player):
		health = player.health

	while health > last_health:
		var heart = heart_scene.instance()
		hearts.push_back(heart)
		health_bar.add_child(heart)
		last_health += 1
	while health < last_health:
		hearts.pop_back().lose_heart()
		last_health -= 1
