extends Node2D
class_name Transition
static var i:Transition
static var animplayer:AnimationPlayer

func _ready() -> void:
	i = self
	animplayer = $AnimationPlayer
	visible = false

static func switchScene(scene):
	
	i.visible = true
	animplayer.play('slidein')
	i.queue_redraw()
	await animplayer.animation_finished
	doSomeShit(scene)
	animplayer.play('slideout')
	await animplayer.animation_finished
	i.visible = false

static func doSomeShit(scene):
	var tree = Engine.get_main_loop() as SceneTree
	if typeof(scene) == TYPE_STRING:
		tree.change_scene_to_file(scene)
	elif scene is PackedScene:
		tree.change_scene_to_packed(scene)
