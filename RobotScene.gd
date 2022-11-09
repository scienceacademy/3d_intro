extends Spatial

onready var cameras = [$Camera, $StationaryCamera]
var current_camera = 0

func _input(event):
	if event.is_action_pressed("ui_focus_next"):
		current_camera = (current_camera + 1) % 2
		cameras[current_camera].current = true


func _process(delta):
	$StationaryCamera.look_at($GodotBot.transform.origin, Vector3.UP)
