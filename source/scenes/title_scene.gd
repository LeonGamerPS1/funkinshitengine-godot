extends Node2D

class_name Title

@export var logo:AnimatedSprite2D
var music:AudioStreamPlayer2D
@onready var enter:AnimatedSprite2D = $enter
@onready var gf:AnimatedSprite2D = $gf
func _ready() -> void:
	Conductor.events.on_beat.connect(beat)
	Conductor.bpm = 102.00000000000000000000000000000000
	enter.sprite_frames.set_animation_loop('Press Enter to Begin', true)
	enter.sprite_frames.set_animation_loop('ENTER PRESSED', true)
	enter.play("Press Enter to Begin")
	music = Transition.i.get_parent().get_node("music")
	
func beat(b:int = 0):
	logo.frame = 0
	logo.play('logo bumpin')
	
	if b % 2 == 0:
		gf.frame = 0
		gf.play('gfDance')
	
func free() -> void:
	Conductor.events.on_beat.disconnect(beat)

func _process(_delta: float) -> void:
	Conductor.time = music.get_playback_position() * 1000
	if(Input.is_action_just_pressed("ui_accept")):
		enter.play("ENTER PRESSED")
		CameraFlash.flash(1, Color(1.0, 1.0, 1.0, 1.0))
		await get_tree().create_timer(1.0).timeout
		Transition.switchScene('res://source/scenes/MainMenu.tscn')
