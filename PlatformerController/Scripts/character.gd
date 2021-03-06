extends KinematicBody2D

# Expose these variables to the Inspector
export(int, 1000, 3000) var speed : int = 1000
export(int, -3000, -1000) var jumpSpeed: int = -1100
export(float, 1000, 5000) var gravity : float = 4000
export(float, 0, 100) var mass : float = 80
export(float, 0, 500) var force : float = 80
export(float, 0, 20) var friction : float = 0.1

# Intermediary variables
var direction = Vector2.LEFT
var velocity = Vector2()
var acceleration : float = 0
var lastVPos : float = 0
var touchedGround : bool = false

# Constants to not change
var afterJumpModifier : float = 50.0
var isJumping : bool = false
var isGrabbing : bool = false
onready var grav = gravity

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta) -> void:
	get_input()
	make_velocity()
	check_floor()
	apply_gravity(delta)
	move()

func get_input() -> void:
	if Input.is_action_pressed("move_left") and !isGrabbing:
		direction.x = -1
	elif Input.is_action_pressed("move_right") and !isGrabbing:
		direction.x = 1
	else:
		direction.x = 0
	if Input.is_action_just_released("grab"):
		isGrabbing = false
		gravity = 0
		$CoyoteTimer.start()


func make_velocity() -> void:
	acceleration = 0.2
	if direction.x != 0:
		velocity.x = lerp(velocity.x, direction.x * speed, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0, friction)
	if Input.is_action_just_pressed("jump") and !isJumping and !isGrabbing: # Only allowed to jump ONCE (maybe twice)
		velocity.y = jumpSpeed
		isJumping = true
	elif Input.is_action_pressed("grab") and is_on_wall():
		velocity.y = 0
		isGrabbing = true
		isJumping = false

func apply_gravity(delta) -> void:
	if !isGrabbing:
		velocity.y += gravity * delta/2
		
		# Check to see if we're currently jumping
		if isJumping and Input.is_action_pressed("jump"):
			velocity.y += gravity * delta/2
			if velocity.y > 2 * gravity:
				velocity.y = 2 * gravity # Cap falling velocity otherwise speedrunners will always have the inventory open
		elif isJumping and Input.is_action_just_released("jump"): # We want to fall faster after we release the jump button
			velocity.y += gravity * delta * afterJumpModifier
			if velocity.y > 2 * gravity * afterJumpModifier:
				velocity.y = 2 * gravity * afterJumpModifier

func move() -> void:
	move_and_slide(velocity, Vector2.UP)
	if is_on_floor():
		isJumping = false

func check_floor() -> void:
	if !is_on_floor() and touchedGround:
		gravity = 0
		touchedGround = false
		$CoyoteTimer.start()
	elif is_on_floor() and !touchedGround:
		touchedGround = true


func _on_CoyoteTimer_timeout() -> void:
	gravity = grav
