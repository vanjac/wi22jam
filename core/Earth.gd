extends TileMap

var ripple_scene = preload("res://anger/AngerRipple.tscn")

func _ready():
	pass

func _on_shot(position):
	var ripple = ripple_scene.instance()
	get_parent().add_child(ripple)
	ripple.global_position = position
