extends KinematicBody

const MAX_SPEED = 15
const ACCELERATION = 1.3
const INERTION = 1

const NO_COLLISION = 0
var boost_window = 20

const ROTATION_SPEED = 0.03
var velocity = Vector3()

var movement_direction_vector = Vector3(0, 0, 0)
var prev_location = Position3D
var collided_object = null
var current_collision_index = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	# initialize location of the object
	prev_location = self.global_transform.origin

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
		acceleration_vec.z += 1
	if Input.is_action_pressed("enemy_move_back"):
		acceleration_vec.z -= 1
		
	if Input.is_action_pressed("enemy_move_right"):
		if velocity.z > 0:
			rotate_y(-ROTATION_SPEED)
		if velocity.z < 0:
			rotate_y(ROTATION_SPEED)
	if Input.is_action_pressed("enemy_move_left"):
		if velocity.z > 0:
			rotate_y(ROTATION_SPEED)
		if velocity.z < 0:
			rotate_y(-ROTATION_SPEED)
		
	# boost of the car movement if "boost" button pressed
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
		
	# section that finds movement direction vector of current car
	movement_direction_vector = self.global_transform.origin - prev_location
	prev_location = self.global_transform.origin

	# apply collision mechanics for two cars, when one car impacts movement of 
	# another car
	current_collision_index = get_slide_count()
	if current_collision_index > NO_COLLISION:
		velocity.z *= 0.2
		collided_object = self.get_parent().get_node(get_slide_collision(current_collision_index - 1).collider.name)
		if collided_object != null:
			if typeof(collided_object) == 17:
				collided_object.move_and_slide(movement_direction_vector * 125)
		
	# apply velocity vector to the method responsible for movement
	move_and_slide(transform.basis.xform(Vector3(0, 0, velocity.z)))
	
	if boost_window < 20:
		boost_window += 1
