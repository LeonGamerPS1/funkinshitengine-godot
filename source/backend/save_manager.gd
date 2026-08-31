extends Node
class_name Save
var savePath: String = "user://saves/slot1.bin"

static var Settings: Dictionary = {
	"fps": 64.0,
	"volume": 0.8,
	"windowMode": DisplayServer.WINDOW_MODE_WINDOWED,
	"noteRGB": [
	[Color("ff0000ff"), Color("00ff00ff"), Color("0000ffff")],
	[Color("ff0000ff"), Color("00ff00ff"), Color("0000ffff")],
[Color("ff0000ff"), Color("00ff00ff"), Color("0000ffff")],
[Color("ff0000ff"), Color("00ff00ff"), Color("0000ffff")]
	],
	"noteskin":"NOTE_assets"

}

func _init() -> void:
	load_data()
	
func save():
	var file = FileAccess.open(savePath, FileAccess.WRITE)
	if file:
		for key in Settings:
			file.store_var(key)
			file.store_var(Settings[key])
		file.close()

func _exit_tree() -> void:
	save()
	
func onSafeFileLoad():
	Engine.max_fps = Settings.get('fps', 64) 
	DisplayServer.window_set_mode(Settings.get('windowMode', DisplayServer.WINDOW_MODE_WINDOWED))
	
func load_data():
	if not FileAccess.file_exists(savePath):
		print('no safe file found in ' + OS.get_user_data_dir() + '/save.bin')
		return

	var file = FileAccess.open(savePath, FileAccess.READ)
	if file:
		while file.get_position() < file.get_length():
			var key = file.get_var()
			var value = file.get_var()
			
			if key in Settings:
				Settings[key] = value
		onSafeFileLoad()
		file.close()
