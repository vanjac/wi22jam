extends TileMap

var ripple_scene = preload("res://anger/AngerRipple.tscn")
var broken_scene = preload("res://environment/BrokenTile.tscn")

func _ready():
	pass

func _on_shot(position, direction):
	var map_pos = world_to_map(to_local(position + direction * 8))
	var broken = break_cell(map_pos)
	break_cell(map_pos + Vector2.RIGHT)
	break_cell(map_pos + Vector2.LEFT)
	break_cell(map_pos + Vector2.UP)
	break_cell(map_pos + Vector2.DOWN)

	var ripple = ripple_scene.instance()
	get_parent().add_child(ripple)
	ripple.global_position = position
	return broken

func break_cell(pos):
	if get_cellv(pos) == 1:  # breakable
		set_cellv(pos, -1)
		var broken = broken_scene.instance()
		get_parent().add_child(broken)
		broken.global_position = to_global(map_to_world(pos))
		return true
	return false
