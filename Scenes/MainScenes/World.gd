extends Node2D

var player_spawn = preload("res://Scenes/SupportScenes/PlayerTemplate.tscn")
var last_world_state = 0

var world_state_buffer = []
const interpolation_offset = 100

func SpawnNewPlayer(player_id, spawn_position, username):
	if get_tree().get_network_unique_id() == player_id:
		pass
	else:
		if not get_node("YSort/OtherPlayers").has_node(str(player_id)):
			var new_player = player_spawn.instance()
			new_player.position = spawn_position
			new_player.name = str(player_id)
			new_player.SetUsername(username)
			get_node("YSort/OtherPlayers").add_child(new_player)


func DespawnPlayer(player_id):
	yield(get_tree().create_timer(0.2), "timeout")
	get_node("YSort/OtherPlayers/" + str(player_id)).queue_free()

func UpdateWorldState(world_state):
#	for key in world_state.keys():
#		if str(get_tree().get_network_unique_id()) != str(key):
#			#get_node("/Root/SceneHandler/World/OtherPlayers/" + str(key)).SetUsername(world_state[key]["U"])
#			print(world_state[key])
#			print(world_state)

	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state_buffer.append(world_state)

func _physics_process(_delta):
	var render_time = OS.get_system_time_msecs() - interpolation_offset
	if world_state_buffer.size() > 1:
		while world_state_buffer.size() > 2 and render_time > world_state_buffer[2].T:
			world_state_buffer.remove(0)
		if world_state_buffer.size() > 2: # if we have future state
			var interpolation_factor = float(render_time - world_state_buffer[1]["T"]) / float(world_state_buffer[2]["T"] - world_state_buffer[0]["T"])
			for player in world_state_buffer[2].keys():
				if str(player) == "T":
					continue
				if player == get_tree().get_network_unique_id():
					continue
				if not world_state_buffer[1].has(player):
					continue
				if get_node("YSort/OtherPlayers").has_node(str(player)):
					var new_position = lerp(world_state_buffer[1][player]["P"], world_state_buffer[2][player]["P"], interpolation_factor)
					
					var animation_vector = world_state_buffer[2][player]["A"]
					get_node("YSort/OtherPlayers/" + str(player)).MovePlayer(new_position, animation_vector)
				else:
					print("Spawning player")
					SpawnNewPlayer(player, world_state_buffer[2][player]["P"], world_state_buffer[2][player]["U"])
		elif render_time > world_state_buffer[1].T:
			var extrapolation_factor = float(render_time - world_state_buffer[0]["T"]) / float(world_state_buffer[1]["T"] - world_state_buffer[0]["T"]) - 1.00
			for player in world_state_buffer[1].keys():
				if str(player) == "T":
					continue
				if player == get_tree().get_network_unique_id():
					continue
				if not world_state_buffer[0].has(player):
					continue
				if get_node("YSort/OtherPlayers").has_node(str(player)):
					var position_delta = (world_state_buffer[1][player]["P"] - world_state_buffer[0][player]["P"])
					var new_position = world_state_buffer[1][player]["P"] + (position_delta * extrapolation_factor)
					var animation_vector = world_state_buffer[1][player]["A"]
					get_node("YSort/OtherPlayers/" + str(player)).MovePlayer(new_position, animation_vector)
					
					
					
