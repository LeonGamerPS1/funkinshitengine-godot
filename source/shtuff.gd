extends CanvasLayer

class_name Music

@export var mus:AudioStreamPlayer2D
static var music:AudioStreamPlayer2D

func _ready() -> void:
	music = mus
	playMusic('res://assets/music/freakyMenu.ogg')
	
static func playMusic(n:String = ''):
	music.stream = AudioUtil.load_stream(n)
	music.play()
