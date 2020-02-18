extends Spatial

func _ready():
	pass


func _on_entity_entity_159_brush_brush_0_trigger_body_entered(body):
	if not $audio_keypad.is_playing(): $audio_keypad.play()
