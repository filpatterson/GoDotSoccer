extends KinematicBody

# movement constants
const MAX_SPEED = 15
const ACCELERATION = 1.3
const INERTION = 1

var boost_window = 20

# rotation speed and velocity vector
const ROTATION_SPEED = 0.03
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
	var current_max_speed = MAX_SPEED
	var current_acceleration = ACCELERATION
	
	if Input.is_action_pressed("enemy_move_forward"):
		acceleration_vec.z -= 1
	if Input.is_action_pressed("enemy_move_back"):
		acceleration_vec.z += 1
		
	if Input.is_action_pressed("enemy_move_right"):
		rotate_y(-ROTATION_SPEED)
	if Input.is_action_pressed("enemy_move_left"):
		rotate_y(ROTATION_SPEED)
		
	if Input.is_action_pressed("enemy_boost"):
		if boost_window >= 2:
			current_max_speed = MAX_SPEED * 1.5
			current_acceleration = ACCELERATION * 1.5
			boost_window -= 2
	
	
	# perform vector normalization (evading errors of too many signals from button received)
	acceleration_vec = acceleration_vec.normalized()
	
	# considering that player controls a car it is required to set a model that will scale 
	# acceleration depending on the speed (higher speed is - lower acceleration is). Currently
	# works with 4 levels of acceleration, can be changed in future
	if velocity.z > current_max_speed / 2 || velocity.z < -current_max_speed / 2:
		acceleration_vec *= current_acceleration * 0.9
		if velocity.z > current_max_speed / 1.4 || velocity.z < -current_max_speed / 1.4:
			acceleration_vec *= current_acceleration * 0.9
			if velocity.z > current_max_speed / 1.1 || velocity.z < -current_max_speed / 1.1:
				acceleration_vec *= current_acceleration * 0.95
	else:
		acceleration_vec *= current_acceleration
	
	velocity.z += acceleration_vec.z
	
	# if car moves, then its acceleration is reduced by inertion
	if velocity.z > 0:
		velocity.z -= INERTION
	if velocity.z < 0:
		velocity.z += INERTION
		
	if acceleration_vec.z == 0 && velocity.z < 1 && velocity.z > -1:
		velocity.z = 0 
		
	# car is unable to move higher than specified speed limit. Another option to reach the same
	# result is total acceleration removal at stage of getting highest speed
	if velocity.z > current_max_speed:
		velocity.z = current_max_speed
	elif velocity.z < -current_max_speed:
		velocity.z = -current_max_speed

	# apply velocity vector to the method responsible for movement
	move_and_slide(transform.basis.xform(Vector3(0, 0, velocity.z))) 
	
	if boost_window < 20:
		boost_window += 1
	
	# for debug
#	print(velocity.z)
		



#func _physics_process(delta):
#	var current_ball_position = get_parent().get_parent().get_node('Ball').global_transform.origin
#	var myself_position = get_parent().get_node("Enemy").global_transform.origin
##	print("ball position " + str(current_ball_position))
##	print("enemy's position " + str(myself_position))
#	print(get_parent().get_parent().get_node('Ball').linear_velocity)
	
