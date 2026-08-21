@icon('res://assets/ui/icons/icon-dad.png')
extends AnimatedSprite2D
class_name Character
static var singAnims = ['left','down','up','right']
@export var isDancer: bool = false
@export var camPos:Vector2 = Vector2.ZERO
# Wir nennen es temporär anders ("anim_config" statt "animationMap")
@export var anim_config: Dictionary[String, Dictionary] = {
	"idle": { "fps": 24.0, "prefix": "", "name": "", "offsets": [0,0] },
		"left": { "fps": 24.0, "prefix": "", "name": "", "offsets": [0,0] },
			"down": { "fps": 24.0, "prefix": "", "name": "", "offsets": [0,0] },
				"up": { "fps": 24.0, "prefix": "", "name": "", "offsets": [0,0] },
					"right": { "fps": 24.0, "prefix": "", "name": "", "offsets": [0,0] },
}
var holdTimer = 0

func _ready() -> void:
	Conductor.events.on_beat.connect(dance)
	
func playAnim(anima:String):
	frame = 0
	if(anim_config.has(anima)):
		var anim = anim_config.get(anima)
		offset = Vector2(anim.offsets[0], anim.offsets[1])
		sprite_frames.set_animation_speed(anim.prefix, anim.fps)
		play(anim.prefix)
		
func dance(beat:int = 0):
	if(isDancer and holdTimer == 0):
		playAnim('danceLEFT' if beat % 2 == 0 else 'danceRIGHT')
	elif(holdTimer == 0 and beat % 2 == 0):
		playAnim('idle')

func _process(delta: float) -> void:
	if(holdTimer != 0):
		holdTimer -= delta
		if(holdTimer <= 0):
			holdTimer = 0
			dance(int(Conductor.cur_beat))
func _exit_tree() -> void:
	Conductor.events.on_beat.disconnect(dance)
