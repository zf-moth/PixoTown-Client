extends Control

func _process(delta):
	$ParallaxBackground.scroll_offset.x -= 1

func _on_TextureButton_pressed():
	$CanvasLayer/AnimationPlayer.play("HideMain")
	$CanvasLayer/AnimationPlayer.queue("ShowLogin")


func _on_TextureButton6_pressed():
	$CanvasLayer/AnimationPlayer.play_backwards("ShowLogin")
	$CanvasLayer/AnimationPlayer.queue("ShowMain")
