class_name Assets

static func readDirectory(path: String, directories:bool = false) -> PackedStringArray:
	var dir = DirAccess.open(path)
	if dir:
		return dir.get_directories() if directories else dir.get_files()
	else:
		print("An error occurred when trying to access the path. check ur dir lols...")
		return PackedStringArray()
