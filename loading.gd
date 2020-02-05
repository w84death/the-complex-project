extends Control

export var next_scene = "demo"


func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	self.get_tree().change_scene(next_scene+".tscn")
