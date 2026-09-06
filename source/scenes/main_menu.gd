extends Node2D

@export var items:Node
@onready var camFollow = $camFollow

var curSelected:AnimatedSprite2D
var curID:int = 0
var _items:Array[AnimatedSprite2D]

var _flicker_timer:float = 0.0
var _flicker_duration:float = 0.8
var _is_flickering:bool = false

func _ready() -> void:
	_items = []
	for item in  items.get_children():
		_items.push_back(item)
	for item in _items:
		item.sprite_frames.set_animation_loop('basic', true)
		item.sprite_frames.set_animation_loop('white', true)
	updateSelect()

func updateSelect(add:int = 0):
	if _is_flickering:
		return
	curID = wrap(curID + add, 0, _items.size())
	if curSelected:
		curSelected.play('basic')
		curSelected.z_index = 0
		curSelected.visible = true
	curSelected = _items[curID]
	curSelected.play('white')
	curSelected.z_index = 1
	
	camFollow.position = curSelected.global_position
	SoundManager.play('res://assets/sounds/menu/scroll.ogg')
	
func _process(delta: float) -> void:
	if _is_flickering:
		_flicker_timer -= delta
		if Engine.get_process_frames() % 4 == 0:
			curSelected.visible = !curSelected.visible
		if _flicker_timer <= 0.0:
			_is_flickering = false
			curSelected.visible = true
			check_option_availability(curSelected.name)
		return

	if not _is_flickering:
		if Input.is_action_just_pressed('ui_up'):
			updateSelect(-1)
		if Input.is_action_just_pressed('ui_down'):
			updateSelect(1)
		if Input.is_action_just_pressed('ui_accept'):
			SoundManager.play('res://assets/sounds/menu/confirm.ogg')
			_is_flickering = true
			_flicker_timer = _flicker_duration

func check_option_availability(option_name: String) -> void:
	match option_name:
		"freeplay":
			Transition.switchScene("res://source/scenes/FreeplayMenu.tscn")
		_:
			pass

func start_option() -> void:
	pass

func reboot_state() -> void:
	curID = 0
	if curSelected:
		curSelected.play('basic')
		curSelected.z_index = 0
		curSelected.visible = true
	curSelected = null
	updateSelect(0)
