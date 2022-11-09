extends KinematicBody

var velocity = Vector3.ZERO
var speed = 0.0
var walk_speed = 4.0
var run_speed = 8.0
var accel = 4.0
var decel = 8.0
var gravity = -22
var jump_speed = 10.0
var turn_speed = 8.0
var jumping = false

onready var state_machine = $AnimationTree["parameters/playback"]
var iwr = "parameters/iwr_loop/iwr/blend_amount"
onready var camera = get_viewport().get_camera()

func get_input(delta):
	if Input.is_action_pressed("sprint"):
		speed = run_speed
	else:
		speed = walk_speed
	
	var raw = Input.get_vector("left", "right", "forward", "back")
		
#	var input = transform.basis.xform(Vector3(raw.x, 0, raw.y) * walk_speed)
	var input = Vector3(raw.x, 0, raw.y) * speed
	var b = camera.transform.basis.rotated(camera.transform.basis.x, -camera.rotation.x)
	input = b.xform(input)
	return input

func _physics_process(delta):
	velocity.y += gravity * delta
	var vy = velocity.y
	velocity.y = 0
	var nt = transform
	var inp = get_input(delta)
	var a = accel if inp.length() > 0 else decel
	velocity = lerp(velocity, inp, a * delta)
	if inp.length() > 0:
		nt = transform.looking_at(transform.origin + inp, Vector3.UP)
	var max_iwr = 1 if speed == run_speed else 0
	$AnimationTree[iwr] = range_lerp(velocity.length(), 0, speed, -1, max_iwr)
	velocity.y = vy

	transform = transform.interpolate_with(nt, turn_speed * delta)
	velocity = move_and_slide(velocity, Vector3.UP, true, 4, 0.785398, true)
	
	$AnimationTree["parameters/conditions/falling"] = !is_on_floor() and velocity.y < 0
	$AnimationTree["parameters/conditions/landed"] = is_on_floor()
	if Input.is_action_just_pressed("jump") and is_on_floor():
		state_machine.travel("Jump")
		jumping = true
		velocity.y = jump_speed
		
	if jumping and is_on_floor():
		jumping = false
