extends AnimatedSprite2D
class_name Splash
static var splashframes:SpriteFrames
signal kill
@export var dir = 0
func _ready() -> void:
	scale = Vector2(1, -1)
	animation_finished.connect(finished)

func spawn(target:Node2D, dire:int = 0):
	if not splashframes:
		splashframes = load("res://assets/ui/splashes/noteSplashes.xml")
	sprite_frames = splashframes
	dir = dire
	position = target.position
	
	play('note impact ' + str(randi_range(1,2)) + ' ' + Note.colors[dir])
	return self
func finished():
	kill.emit(self)
