extends Node3D

func _process(delta):
	$Node3D.rotation.y += PI/2 * delta
