extends KinematicBody

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# constants used in movement function
const SPEED = 10
const GRAVITY = 0.98
const ROTATE = 0.01
var y_pos = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# function performs control over the player at each frame

func _physics_process(delta):
	# initalization of 3d movement vector and changing value (speed) depending on pressed buttons
	var movement_vec = Vector3()
	if Input.is_action_pressed("move_forward"):
		movement_vec.z -= 1
	if Input.is_action_pressed("move_backward"):
		movement_vec.z += 1
		
	# considering that project implements car movement and it is not possible to move left/right
	# instantly here is applied rotation of the object. Considering that car is not able to turn
	# if there is no velocity of the vehicle it is required to set rotation only in case of car
	# movement. 
	if Input.is_action_pressed("move_right"):
		rotate_y(-ROTATE)
	if Input.is_action_pressed("move_left"):
		rotate_y(ROTATE)
	
	# perform speed normalization and perform speed multiplication to speed up the vehicle
	movement_vec = movement_vec.normalized()
	movement_vec *= SPEED
	movement_vec.y = 0

	move_and_slide(transform.basis.xform(Vector3(0, y_pos, movement_vec.z))) 
	
	y_pos -= GRAVITY
	print(delta)
		

func manually_handle_collision():
	var hitcount = get_slide_count()	
	if hitcount > 0:
		var collision = get_slide_collision(0)
		if collision.collider is RigidBody:
			collision.collider.apply_impulse(collision.position, - collision.normal)
