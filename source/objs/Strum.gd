extends AnimatedSprite2D

class_name Strum
static var animations:Array[String] = ['left', 'down', 'up', 'right']
var dir = 0
var r = 0


var holding = false
func init(data:int = 0):
	dir = data
	var noteSkin = Save.Settings['noteskin']
	sprite_frames = load('res://assets/ui/notes/[skin].xml'.replace('[skin]',noteSkin))
	scale = Vector2(.7, .7)

	play('arrow' + animations[data %  animations.size()].to_upper())
	sprite_frames.set_animation_loop('arrow' + animations[data %  animations.size()].to_upper(), true)
	idle()
	centered = true
	
	material = load('res://assets/shaders/noteRGB.material')
	var gbr = Save.Settings.get('noteRGB')[dir]
	Note.applyRGB(self, gbr[0], gbr[1], gbr[2])

	

func confirm():
	frame = 0
	play(animations[dir %  animations.size()] + ' confirm')
	set_instance_shader_parameter('use', true)
	
func press():
	play(animations[dir %  animations.size()] + ' press')
	set_instance_shader_parameter('use', true)
	
func idle():
	play('arrow' + animations[dir %  animations.size()].to_upper())
	set_instance_shader_parameter('use', false)

func _process(delta: float) -> void:

	if(r != 0):
		r -= delta
		if(r < 0):
			r = 0
			idle()
			
			
			

	
