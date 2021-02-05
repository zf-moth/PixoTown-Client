extends KinematicBody2D

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var text = get_node("Username")

func SetUsername(username):
	$Username.text = username
	

func MovePlayer(new_position, animation_vector):
	if animation_vector != Vector2.ZERO:
		animationTree.set("parameters/Idle/blend_position", animation_vector)
		animationTree.set("parameters/Run/blend_position", animation_vector)
	if new_position == position:
		animationState.travel("Idle")
	else:
		animationState.travel("Run")
		set_position(new_position)
