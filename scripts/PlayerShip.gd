extends KinematicBody2D

onready var firing_position = $FiringPosition
onready var exhaust_position = $ExhaustPosition

const ROTATION_SPEED = 2
const THRUST_SPEED = 10
const THRUST_DECAY = 3
const THRUST_BRAKE = 6
const THRUST_MAX = 700

var angle = 0
var thrust = 0
var velocity = Vector2()
var score = 0
var shields = 100
var health = 100
var collision_time = 0

func _ready():
	Global.player = self
	
	rset_config("rotation", MultiplayerAPI.RPC_MODE_PUPPET)
	rset_config("position", MultiplayerAPI.RPC_MODE_PUPPET)
	rset_config("visible", MultiplayerAPI.RPC_MODE_PUPPET)
	rset_config("angle", MultiplayerAPI.RPC_MODE_PUPPET)
	rset_config("thrust", MultiplayerAPI.RPC_MODE_PUPPET)
	rset_config("velocity", MultiplayerAPI.RPC_MODE_PUPPET)
	rset_config("health", MultiplayerAPI.RPC_MODE_PUPPET)
	rset_config("shields", MultiplayerAPI.RPC_MODE_PUPPET)
	
	if(is_network_master()):
		set_process_input(true)
	else:
		set_process_input(false)
		
func _input(event):
	if event.is_action_pressed("left"):
		angle -= ROTATION_SPEED
		
	if event.is_action_pressed("right"):
		angle += ROTATION_SPEED
		
	if event.is_action_pressed("thrust"):
		thrust += THRUST_SPEED
		
	if event.is_action_pressed("brake"):
		thrust -= THRUST_BRAKE

	thrust = clamp(thrust, 0, THRUST_MAX)

func _physics_process(delta):
	collision_time += delta
	thrust -= THRUST_DECAY
	
	velocity = Vector2(thrust, 0).rotated(deg2rad(angle - 90))
		
	# velocity.x = thrust * sin(deg2rad(angle))
	# velocity.y = -thrust * cos(deg2rad(angle))
		
	rotation_degrees = angle
	var collision = move_and_collide(velocity * delta)
	if collision != null:
		if collision_time > 0.3:
			scrape(5)
			collision_time = 0
	
	if health < 100:
		health += 0.1
	else:
		if shields < 100:
			shields += 0.1
			
	health = clamp(health, 0, 100)
	shields = clamp(shields, 0, 100)
	
	if(is_network_master()):
		_synchronize()
		
func _synchronize():
	rset("position", position)
	rset("rotation", rotation)
	rset("visible", visible)
	rset("angle", angle)
	rset("thrust", thrust)
	rset("velocity", velocity)
	rset("health", health)
	rset("shields", shields)
	
func hit():
	if shields > 30:
		shields -= 30
	else:
		health -= 30
		
	if health <= 0 && is_network_master():
		Global.game_lost()

func scrape(amount):
	if shields > 1:
		shields -= amount
		return
		
	if health > 0:
		health -= amount
		
	if health <= 0 && is_network_master():
		Global.game_lost()
