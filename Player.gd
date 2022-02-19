extends KinematicBody

# movement constants
const MAX_SPEED = 15
const ACCELERATION = 1.3
const INERTION = 1

# rotation speed and velocity vector
const ROTATION_SPEED = 0.01
var velocity = Vector3()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# function performs control over the player at each frame
func _physics_process(delta):
	# setting acceleration vector, required to estimate acceleration of player
	var acceleration_vec = Vector3()
	
	if Input.is_action_pressed("move_forward"):
		acceleration_vec.z -= 1
	if Input.is_action_pressed("move_backward"):
		acceleration_vec.z += 1
		
	if Input.is_action_pressed("move_right"):
		rotate_y(-ROTATION_SPEED)
	if Input.is_action_pressed("move_left"):
		rotate_y(ROTATION_SPEED)
	
	# perform vector normalization (evading errors of too many signals from button received)
	acceleration_vec = acceleration_vec.normalized()
	
	# considering that player controls a car it is required to set a model that will scale 
	# acceleration depending on the speed (higher speed is - lower acceleration is). Currently
	# works with 4 levels of acceleration, can be changed in future
	if velocity.z > MAX_SPEED / 2 || velocity.z < -MAX_SPEED / 2:
		acceleration_vec *= ACCELERATION * 0.9
		if velocity.z > MAX_SPEED / 1.4 || velocity.z < -MAX_SPEED / 1.4:
			acceleration_vec *= ACCELERATION * 0.9
			if velocity.z > MAX_SPEED / 1.1 || velocity.z < -MAX_SPEED / 1.1:
				acceleration_vec *= ACCELERATION * 0.95
	else:
		acceleration_vec *= ACCELERATION
	
	velocity.z += acceleration_vec.z
	
	# if car moves, then its acceleration is reduced by inertion
	if velocity.z > 0:
		velocity.z -= INERTION
	if velocity.z < 0:
		velocity.z += INERTION
		
	# car is unable to move higher than specified speed limit. Another option to reach the same
	# result is total acceleration removal at stage of getting highest speed
	if velocity.z > MAX_SPEED:
		velocity.z = MAX_SPEED
	elif velocity.z < -MAX_SPEED:
		velocity.z = -MAX_SPEED

	# apply velocity vector to the method responsible for movement
	move_and_slide(transform.basis.xform(Vector3(0, 0, velocity.z))) 
	
	# for debug
	print(velocity.z)
		
