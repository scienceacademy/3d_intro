extends CharacterBody3D

@export var speed = 5.0
@export var acceleration = 4.0
@export var jump_speed = 8.0
@export var mouse_sensitivity = 0.0015
@export var rotation_speed = 12.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var jumping = false
@onready var anim_state = $AnimationTree.get("parameters/playback")

func _physics_process(delta):
	velocity.y -= gravity * delta
	get_move_input(delta)
	move_and_slide()
	if velocity.length() > 1.0:
		$Rig.rotation.y = lerp_angle($Rig.rotation.y, $SpringArm3D.rotation.y + PI, rotation_speed * delta)
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_speed
		jumping = true
		$AnimationTree.set("parameters/conditions/grounded", false)
	$AnimationTree.set("parameters/conditions/jumping", jumping)
	if is_on_floor() and jumping:
		jumping = false
		$AnimationTree.set("parameters/conditions/grounded", true)
	if not is_on_floor() and not jumping:
		anim_state.travel("Jump_Idle")
		$AnimationTree.set("parameters/conditions/grounded", false)
		jumping = true
	
func get_move_input(delta):
	var vy = velocity.y
	velocity.y = 0
	var input = Input.get_vector("left", "right", "forward", "back")
	var dir = Vector3(input.x, 0, input.y).rotated(Vector3.UP, $SpringArm3D.rotation.y)
	velocity = lerp(velocity, dir * speed, acceleration * delta)
	var vt = velocity * $Rig.transform.basis
	$AnimationTree.set("parameters/IWR/blend_position", Vector2(-vt.x, -vt.z) / speed)
	velocity.y = vy
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		$SpringArm3D.rotation.y -= event.relative.x * mouse_sensitivity
		$SpringArm3D.rotation.x -= event.relative.y * mouse_sensitivity
		$SpringArm3D.rotation_degrees.x = clamp($SpringArm3D.rotation_degrees.x, -90.0, 30.0)
