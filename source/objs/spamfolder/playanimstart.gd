extends AnimatedSprite2D

@export var startAnim:String = ''
@export var loopIt:bool = false

func _ready() -> void:
	sprite_frames.set_animation_loop(startAnim, loopIt)
	play(startAnim)
