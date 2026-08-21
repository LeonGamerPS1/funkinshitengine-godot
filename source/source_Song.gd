class_name Song

# Definiere hier deine Song-Eigenschaften
var title: String
var bpm: float

static func loadFromJson(jsonInput: String = "tutorial", folder: String = "tutorial"):
	var path: String = "res://assets/songs/" + folder + "/" + jsonInput + ".json"
	
	# 1. Datei öffnen
	if not FileAccess.file_exists(path):
		push_error("Datei nicht gefunden: " + path)
		return null
		
	var file := FileAccess.open(path, FileAccess.READ)
	var json_string := file.get_as_text()
	file.close()
	
	# 2. String in Dictionary / Array parsen
	var data = JSON.parse_string(json_string)
	if data == null:
		push_error("Fehler beim Parsen der JSON-Datei: " + path)
		return null
		

	
	return data.song
