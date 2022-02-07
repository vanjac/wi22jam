extends Light2D

const anim_time = 1
const max_scale = 2

var time = 0.0

func _ready():
	pass

func _process(delta):
	time += delta
	var time_frac = clamp(time / anim_time, 0, 1)
	scale = Vector2.ONE * max_scale * time_frac
	color = Color(2 - time_frac, time_frac, time_frac)
	if time_frac >= 1:
		queue_free()


func _on_Area2D_body_entered(body):
	print(body)
	if body.has_method("_on_angered"):
		body._on_angered()
