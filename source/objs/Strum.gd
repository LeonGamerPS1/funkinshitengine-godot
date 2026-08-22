extends AnimatedSprite2D

class_name Strum
static var animations:Array[String] = ['left', 'down', 'up', 'right']
var dir = 0
var r = 0
var noteColor = Color.WHITE


var holding = false
func init(data:int = 0):
	dir = data
	sprite_frames = load('res://assets/ui/notes/NOTE_assets.xml')
	scale = Vector2.ONE
	apply_scale(Vector2(.7, .7))
	play('arrow' + animations[data %  animations.size()].to_upper())
	sprite_frames.set_animation_loop('arrow' + animations[data %  animations.size()].to_upper(), true)
	show_behind_parent = true
	noteColor = Save.Settings['noteColors'][dir]
	idle()
	centered = true
func confirm():
	frame = 0
	play(animations[dir %  animations.size()] + ' confirm')
	
func press():
	play(animations[dir %  animations.size()] + ' press')
	
func idle():
	play('arrow' + animations[dir %  animations.size()].to_upper())
func _process(delta: float) -> void:
	if(r != 0):
		r -= delta
		if(r < 0):
			r = 0
			idle()
			
			
			

	
