extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var ip = "127.0.0.1"
var port = 1912
var cert = load("res://Resources/Certificate/X509_Certificate.crt")

var username
var password
var new_account

	
func _process(_delta):
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return;
	custom_multiplayer.poll();


func ConnectToServer(_username, _password, _new_account):
	print("Trying to connect to server")
	network = NetworkedMultiplayerENet.new()
	gateway_api = MultiplayerAPI.new()
#	network.use_dtls(false)
#	network.set_dtls_verify_enabled(false) #Set true on release, pay for cert
#	network.set_dtls_certificate(cert)
	username = _username
	password = _password
	new_account = _new_account
	network.create_client(ip, port)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")


func _OnConnectionFailed():
	print("Failed to connect to login server")
	print("Pop-up server offline or something")
	get_node("../LoginScreen/NinePatchRect/LoginScreen").LoginButton.disabled = false
	get_node("../LoginScreen/NinePatchRect/LoginScreen").CreateAccountButton.disabled = false
	get_node("../LoginScreen/NinePatchRect/RegisterScreen").Confirm.disabled = false
	get_node("../LoginScreen/NinePatchRect/RegisterScreen").BackToLogin.disabled = false
	
	
func _OnConnectionSucceeded():
	print("Succesfully connected to gateway")
	if new_account == true:
		RequestCreateAccount()
	else:
		RequestLogin()
	
	
func RequestLogin():
	print("Connecting to gateway to request login")
	rpc_id(1, "LoginRequest", username, password.sha256_text())
	username = ""
	password = ""
	
remote func ReturnLoginRequestToClient(result, token):
	print("Results received: " + str(result))
	if result == true:
		GameServer.token = token
		GameServer.ConnectToServer()
	else:
		print("Please provide correct username and password")
		get_node("../SceneHandler/World/YSort/Player/UILayer/LoginScreen/NinePatchRect/LoginScreen/LoginButton").disabled = false
		get_node("../SceneHandler/World/YSort/Player/UILayer/LoginScreen/NinePatchRect/LoginScreen/CreateAccountButton").disabled = false
	network.disconnect("connection_failed", self, "_OnConnectionFailed")
	network.disconnect("connection_succeeded", self, "_OnConnectionSucceeded")


func RequestCreateAccount():
	print("Requesting new account: Username: " + username + " Password: " + password)
	rpc_id(1, "CreateAccountRequest", username, password.sha256_text())
	print(password)
	username = ""
	password = ""

remote func ReturnCreateAccountRequest(result, message):
	print("Create account request received")
	if result == true:
		print("Account created, please preceed with logging in")
		get_node("/root/SceneHandler/World/YSort/Player/UILayer/LoginScreen/")._on_BackToLogin_pressed()
	else:
		if message == 1:
			print("Couldn't create account, please try again")
		elif message == 2:
			print("The username is taken")
		get_node("/root/SceneHandler/World/YSort/Player/UILayer/LoginScreen/NinePatchRect/RegisterScreen/Confirm").disabled = false
		get_node("/root/SceneHandler/World/YSort/Player/UILayer/LoginScreen/NinePatchRect/RegisterScreen/BackToLogin").disabled = false
	network.disconnect("connection_failed", self, "_OnConnectionFailed")
	network.disconnect("connection_succeeded", self, "_OnConnectionSucceeded")
