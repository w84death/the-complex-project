extends Spatial

var are_closed = true

func _ready():
	$audio.stream.set_loop(false)

func opened():
	are_closed = false
	
func closed():
	are_closed = true

func _on_Timer_timeout():
	$audio.play()
	$doors_anim.play("close")

func _on_trigger_body_entered(body):
	if body.is_in_group("can_open_door"):
		if are_closed:
			$audio.play()
			$doors_anim.play("open")
			$Timer.start()
