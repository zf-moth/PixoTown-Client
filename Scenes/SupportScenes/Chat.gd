extends Control

onready var chatButton = $Panel/VBoxContainer/HBoxContainer/Button
onready var lineEdit = $Panel/VBoxContainer/HBoxContainer/LineEdit
onready var ChatText = $Panel/VBoxContainer/MarginContainer/RichTextLabel

#TODO: Limiter for chat sending

func _on_Button_pressed():
	var text = $Panel/VBoxContainer/HBoxContainer/LineEdit.get_text()
	if text != "":
		GameServer.SendChat(text)
		lineEdit.clear()
		chatButton.release_focus()

func _process(delta):
	pass
#	if lineEdit.has_focus():
#		get_node("/root/SceneHandler/World/YSort/Player").in_chat = true
#	else:
#		get_node("/root/SceneHandler/World/YSort/Player").in_chat = false

func _input(event):
	var text = $Panel/VBoxContainer/HBoxContainer/LineEdit.get_text()
	if event is InputEventKey:
		if lineEdit.has_focus() and event.is_action_pressed("ui_enter"):
			if text != "":
				GameServer.SendChat(text)
				lineEdit.clear()
				lineEdit.release_focus()
	if lineEdit.has_focus():
		get_node("/root/SceneHandler/World/YSort/Player").in_chat = true
	else:
		get_node("/root/SceneHandler/World/YSort/Player").in_chat = false

func ShowChat(player_id, chat):
	var username = get_node("/root/SceneHandler/World").world_state_buffer[2][player_id]["U"]
	print(str(username) + ": " + chat)
	ChatText.text += str(username) + ": " + chat + "\n"
	if get_tree().get_network_unique_id() != player_id:
		get_node("/root/SceneHandler/World/YSort/OtherPlayers/" + str(player_id) + "/ChatBubble").set_text(chat)
	else:
		get_node("/root/SceneHandler/World/YSort/Player/ChatBubble").set_text(chat)
