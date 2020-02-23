extends Control

export var next_scene = "demo"


func _ready():
	yield(get_tree().create_timer(1.0), "timeout")
	Global.goto_scene("res://"+next_scene+".tscn")
