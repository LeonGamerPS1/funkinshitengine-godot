extends AnimatedSprite2D
class_name Splash

signal kill
@export var dir = 0
func _ready() -> void:

	animation_finished.connect(finished)

func spawn(target:Node2D, dire:int = 0):
	if not sprite_frames:
		sprite_frames = load("res://assets/ui/splashes/noteSplashes.xml")
	dir = dire
	position = target.position
	
	play('note impact ' + str(randi_range(1,2)) + ' ' + Note.colors[dir])
	return self
func finished():
	kill.emit(self)
