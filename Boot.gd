extends Node

class_name AudioUtil

static func add_audio_ext(path: String) -> String:
	if path.get_extension() != "":
		return path
	
	var formats = ["ogg", "mp3", "wav"]
	for ext in formats:
		var test_path = path + "." + ext
		if FileAccess.file_exists(test_path):
			return test_path
	return path

static func load_stream(path: String) -> AudioStream:
	var final_path = add_audio_ext(path)
	
	if not FileAccess.file_exists(final_path):
		push_error("file existiert not: " + final_path)
		return null
		
	var ext = final_path.get_extension().to_lower()
	
	match ext:
		"ogg", "vorbis":
			return AudioStreamOggVorbis.load_from_file(final_path)
			
		"mp3":
			var file = FileAccess.open(final_path, FileAccess.READ)
			var stream = AudioStreamMP3.new()
			stream.data = file.get_buffer(file.get_length())
			stream.loop = false 
			return stream
			
		"wav":
			return AudioStreamWAV.load_from_file(final_path)
			
		_:
			push_error("not supported Audioformat: " + ext + ' , loading into ram')
			return load(final_path)
