extends Control

export var next_scene = "demo"


func _ready():
	yield(get_tree().create_timer(1.0), "timeout")
	self.get_tree().change_scene(next_scene+".tscn")
