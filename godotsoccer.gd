extends Spatial

onready var result_panel_label = get_node("ResultPanel/Label")
var player1_score = 0
onready var player1_scorelabel = get_node("ScoresPanel/Player1ScoreLabel")
var player2_score = 0
onready var player2_scorelabel = get_node("ScoresPanel/Player2ScoreLabel")
#
func _ready():
	#$ResultPanel.hide()
	reset_positions()


func reset_positions():
	$ResultPanel.hide()
	var player = get_node("Physics").get_node("Player")
	var enemy = get_node("Physics").get_node("Enemy")
	var ball = get_node("Ball")
	
	var player_spawn_point = get_node("PlayerSpawnPoint")
	var enemy_spawn_point = get_node("EnemySpawnPoint")
	var ball_spawn_point = get_node("BallSpawnPoint")
	
	player.translation = player_spawn_point.translation 
	player.rotation_degrees = player_spawn_point.rotation_degrees 
	enemy.translation = enemy_spawn_point.translation 
	enemy.rotation_degrees = enemy_spawn_point.rotation_degrees

	ball.translation = ball_spawn_point.translation
	ball.linear_velocity = Vector3(0, 0, 0)
	ball.angular_velocity = Vector3(0, 0, 0)

	pass
#
#
func _process(delta):
	if Input.is_key_pressed(KEY_R):
		#get_tree().reload_current_scene()
		reset_positions()
	if Input.is_key_pressed(KEY_N):
		set_player1_score(0)
		set_player2_score(0)
		reset_positions()
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()

#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
#
#
func _on_Area_body_entered( body ):
	if body is RigidBody:
		print("win")
		$Panel.show()
#
func _on_Team1GoalArea_body_entered(body):
	if $ResultPanel.visible:
		return
	if body is RigidBody:
		$ResultPanel.show()
		print("Red Player Win")	
		result_panel_label.text = "Red Player Win"
		set_player2_score(player2_score + 1)


	# replace with function body

func set_player1_score(score):
		player1_score = score
		player1_scorelabel.text = "Blue Player: %d" % player1_score	

func set_player2_score(score):
		player2_score = score
		player2_scorelabel.text = "Red Player: %d" % player2_score	
#
func _on_Team2GoalArea_body_entered(body):
	if $ResultPanel.visible:
		return
	if body is RigidBody:
		$ResultPanel.show()
		print("Blue Player Win")	
		result_panel_label.text = "Blue Player Win"
		set_player1_score(player1_score + 1)
