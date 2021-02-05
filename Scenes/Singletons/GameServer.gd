extends Node

var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
#var ip = "actual ip"
var port = 1909
var token

var client_clock = 0
var decimal_collector : float = 0
var latency_array = []
var latency = 0
var delta_latency = 0


func _physics_process(delta):
	client_clock += int(delta * 1000) + delta_latency
	delta_latency = 0
	decimal_collector += (delta * 1000) - int(delta * 1000)
	if decimal_collector >= 1.00:
		client_clock += 1
		decimal_collector -= 1.00
	
func ConnectToServer():
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")
	
	
func _OnConnectionFailed():
	print("Failed to connect")
	
	
func _OnConnectionSucceeded():
	print("Succesfully connected to: " + str(ip) + ":" + str(port))
	rpc_id(1, "FetchServerTime", OS.get_system_time_msecs())
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.connect("timeout", self, "DetermineLatency")
	self.add_child(timer)


remote func ReturnServerTime(server_time, client_time):
	latency = (OS.get_system_time_msecs() - client_time) / 2
	client_clock = server_time + latency

func DetermineLatency():
	rpc_id(1, "DetermineLatency", OS.get_system_time_msecs())

remote func ReturnLatency(client_time):
	latency_array.append((OS.get_system_time_msecs() - client_time) / 2)
	if latency_array.size() == 9:
		var total_latency = 0
		latency_array.sort()
		var mid_point = latency_array[4]
		for i in range(latency_array.size()-1,-1,-1):
			if latency_array[i] > (2 * mid_point) and latency_array[i] > 20:
				latency_array.remove(i)
			else:
				total_latency += latency_array[i]
		delta_latency = (total_latency / latency_array.size()) - latency
		latency = total_latency / latency_array.size()
		print("New Latency: " + str(latency))
		latency_array.clear()
		

remote func FetchToken():
	rpc_id(1, "ReturnToken", token)



remote func ReturnTokenVerificationResults(result):
	if result == true:
		get_node("../SceneHandler/World/YSort/Player/UILayer/LoginScreen").queue_free()
		get_node("/root/SceneHandler/World/YSort/Player").set_process(true)
		get_node("/root/SceneHandler/World/YSort/Player/UILayer/Chat").show()
		print("Successful token verification")
	else:
		print("Login failed, please try again")
		get_node("../SceneHandler/World/YSort/Player/UILayer/LoginScreen/LoginScreen/NinePatchRect/LoginScreen/LoginButton").disabled = false
		get_node("../SceneHandler/World/YSort/Player/UILayer/LoginScreen/LoginScreen/NinePatchRect/LoginScreen/CreateAccountButton").disabled = false


func SendPlayerState(player_state):
	rpc_unreliable_id(1, "ReceivePlayerState", player_state)

remote func ReceiveWorldState(world_state):
	get_node("../SceneHandler/World").UpdateWorldState(world_state)

remote func SpawnNewPlayer(player_id, spawn_position, username):
	get_node("../SceneHandler/World").SpawnNewPlayer(player_id, spawn_position, username)
	
remote func DespawnPlayer(player_id):
	get_node("../SceneHandler/World").DespawnPlayer(player_id)
	
func SendChat(chat):
	print(chat)
	rpc_id(1, "ReceiveChat", chat)

remote func ReceiveChatOthers(player_id, chat):
	if has_node("/root/SceneHandler/World/YSort/Player/UILayer/Chat"):
		get_node("/root/SceneHandler/World/YSort/Player/UILayer/Chat").ShowChat(player_id, chat)
