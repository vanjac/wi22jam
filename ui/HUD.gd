extends CanvasLayer

export(NodePath) var player_path
onready var player = get_node(player_path)

onready var health_bar = $Health
var heart_scene = preload("res://ui/Heart.tscn")

var hearts = []

func _ready():
	pass

func _process(delta):
	var health = 0
	if is_instance_valid(player):
		health = player.health

	while health > len(hearts):
		var heart = heart_scene.instance()
		hearts.push_back(heart)
		health_bar.add_child(heart)
	while health < len(hearts):
		hearts.pop_back().lose_heart()
