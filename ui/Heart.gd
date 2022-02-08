extends TextureRect

onready var destroy_timer = $Destroy

func _ready():
	pass

func lose_heart():
	modulate = Color.white
	destroy_timer.start()

func _on_Destroy_timeout():
	queue_free()
