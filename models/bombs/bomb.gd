extends RigidBody

var activated = false
var bomb = true

func _ready():
	add_to_group("bomb")

func explode():
	$'../anim'.play("boom")


func _on_Timer_timeout():
	explode()
