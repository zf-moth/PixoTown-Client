extends VBoxContainer

export(String, MULTILINE) var text setget set_text;
export var auto_wrap_size := 0.0;

onready var labelchat = $PanelContainer/Label

var default_min_size := Vector2(20, 24);

func _ready() -> void:
	pass

func set_text(value) -> void:
	text = value;
	labelchat.text = value;
	hide();
	show();
	hide();
	show();

	print("line count ", $PanelContainer/Label.get_line_count());
	if $PanelContainer/Label.rect_size.x > auto_wrap_size or $PanelContainer/Label.get_line_count() > 1:
		$PanelContainer/Label.autowrap = true;
		$PanelContainer.rect_min_size.x = auto_wrap_size;
	else:
		$PanelContainer/Label.autowrap = false;
		$PanelContainer.rect_min_size = default_min_size;
	get_node("../AnimationPlayer").play("ShowBubble")
	yield(get_tree().create_timer(4.0), "timeout")
	get_node("../AnimationPlayer").play("HideBubble")
