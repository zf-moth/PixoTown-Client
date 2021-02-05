extends Control

# UI_state nodes
onready var login_screen = get_node("NinePatchRect/LoginScreen")
onready var create_account_screen = get_node("NinePatchRect/RegisterScreen")
# Login nodes
onready var username_input = get_node("NinePatchRect/LoginScreen/Username")
onready var userpassword_input = get_node("NinePatchRect/LoginScreen/Password")
onready var login_button = get_node("NinePatchRect/LoginScreen/LoginButton")
onready var create_account_button = get_node("NinePatchRect/LoginScreen/CreateAccountButton")
# Create Account nodes
onready var create_username_input = get_node("NinePatchRect/RegisterScreen/Username")
onready var create_userpassword_input = get_node("NinePatchRect/RegisterScreen/Password")
onready var create_userpassword_repeat_input = get_node("NinePatchRect/RegisterScreen/RepeatPassword")
onready var confirm_button = get_node("NinePatchRect/RegisterScreen/Confirm")
onready var back_button = get_node("NinePatchRect/RegisterScreen/BackToLogin")


func _on_LoginButton_pressed():
	if username_input.text == "" or userpassword_input.text == "":
		#Pop-up and stop
		print("Please provide valid userID and password")
	else:
		login_button.disabled = true
		create_account_button.disabled = true
		var username = username_input.get_text()
		var password = userpassword_input.get_text()
		print("Attempting to login...")
		Gateway.ConnectToServer(username, password, false)



func _on_CreateAccountButton_pressed():
	login_screen.hide()
	create_account_screen.show()
	
	
func _on_BackToLogin_pressed():
	create_account_screen.hide()
	login_screen.show()



func _on_Confirm_pressed():
	if create_username_input.get_text() == "":
		print("Please provide a valid username")
	elif create_userpassword_input.get_text() == "":
		print("Please provide a valid password")
	elif create_userpassword_repeat_input.get_text() != create_userpassword_input.get_text():
		print("Passwords don't match")
	elif create_userpassword_input.get_text().length() <= 6:
		print("Password must contain at least 7 characters")
	else:
		print(create_username_input.get_text() + " " + create_userpassword_input.get_text())
		confirm_button.disabled = true
		back_button.disabled = true
		var username = create_username_input.get_text()
		var password = create_userpassword_input.get_text()
		Gateway.ConnectToServer(username, password, true)
