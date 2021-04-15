extends KinematicBody2D

const ACCELERATION = 700
const MAX_SPEED = 125
const FRICTION = 600

var velocity = Vector2.ZERO
var player_state
var input_vector = Vector2()

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

var loginstart = preload("res://Scenes/MainScenes/LoginScreen.tscn")
onready var playerUI = $UILayer
var uistart = preload("res://Scenes/SupportScenes/UI.tscn")

var in_chat = false

func _ready():
	var loginstart_instance = loginstart.instance()
	playerUI.add_child(loginstart_instance)
	set_process(false)
	var UI_instance = uistart.instance()
	playerUI.add_child(UI_instance)

func _physics_process(delta):	# use this in case you do physics
	if in_chat == false:
		input_vector = Vector2.ZERO
		input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		input_vector = input_vector.normalized()
		if Input.is_action_just_pressed("ui_chat"):
			pass
		
		if input_vector != Vector2.ZERO:
			animationTree.set("parameters/Idle/blend_position", input_vector)
			animationTree.set("parameters/Run/blend_position", input_vector)
			animationState.travel("Run")
			velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		else:
			animationState.travel("Idle")
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		velocity = move_and_slide(velocity)
	DefinePlayerState()

func DefinePlayerState():
	player_state = {"T": GameServer.client_clock, "P": get_position(), "A": input_vector}
	GameServer.SendPlayerState(player_state)
