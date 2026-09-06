extends Node
class_name SoundManager

static func play(sound_path: String) -> void:
	if sound_path.is_empty():
		return
		
	var sound_stream = load(sound_path)
	if not sound_stream is AudioStream:
		return

	var player = AudioStreamPlayer.new()
	player.name = sound_path
	player.stream = sound_stream
	
	var main_loop = Engine.get_main_loop()
	if main_loop is SceneTree and main_loop.current_scene:
		main_loop.current_scene.add_child(player)
		player.play()
		player.finished.connect(func(): player.queue_free())
	else:
		player.free()
