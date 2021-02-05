extends Node

var mapstart = preload("res://Scenes/MainScenes/World.tscn")
var loginstart = preload("res://Scenes/MainScenes/LoginScreen.tscn")


func _ready():
	#var playerUI = get_node("World/YSort/Player/UILayer")
	var mapstart_instance = mapstart.instance()
	#var loginstart_instance = loginstart.instance()
	add_child(mapstart_instance)
	#playerUI.add_child(loginstart_instance)
