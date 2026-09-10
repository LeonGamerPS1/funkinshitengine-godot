extends Node2D

var curID = 0
var curSelected:FreeplayIconText
var songTexts:Array[FreeplayIconText] = []
var songs:Array[FPSongData] = []
static var music:AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var songFolders = Assets.readDirectory('res://assets/songs', true)
	for songFolder in songFolders:
		var basePath = 'assets/songs/' + songFolder
		var files = Assets.readDirectory(basePath)
		var diffsForSong:PackedStringArray = []
		for file in files:
			if not file.contains('.json') or file.begins_with('events') or file.begins_with('meta'):
				continue
			diffsForSong.append(file.replace('.json', ''))
		addSong(songFolder, diffsForSong)
	select()

func addSong(songName:String, diffs:PackedStringArray):
	var song:FPSongData = FPSongData.new()
	song.name = songName
	song.diffs = diffs
	
	var text:FreeplayIconText = preload('res://assets/presets/icon_label.tscn').instantiate()
	text.setText(songName.to_upper())
	text.targetY = songTexts.size()
	text.startPosition = Vector2(90, 320)
	add_child(text)
	songTexts.push_back(text)
	songs.append(song)

func select(add:int = 0):
	curID = wrap(curID + add, 0, songTexts.size())
	curSelected = songTexts[curID]
	curSelected.targetY =  (songTexts.size()) - curID
	curSelected.modulate.a = 1
	SoundManager.play('res://assets/sounds/menu/scroll.ogg')
	
	
	var bullShit:int = 0
	for item in songTexts:
		item.targetY = bullShit - curID;
		bullShit+=1;
		item.modulate.a = 0.6 if curID != bullShit - 1 else 1.0
		
var selected = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Transition.switchScene('res://source/scenes/MainMenu.tscn')
		SoundManager.play('res://assets/sounds/menu/cancel.ogg')
	if selected:
		return
	if Input.is_action_just_pressed('ui_up'):
		select(-1)
	if Input.is_action_just_pressed('ui_down'):
		select(1)
		
	if Input.is_action_just_pressed('ui_accept'):
		confirm()

func confirm():
	var song:FPSongData = songs[curID]
	selected = true
	SoundManager.play('res://assets/sounds/menu/confirm.ogg')
	GameState.song = Song.loadFromJson(song.diffs[song.diffs.size() - 1], song.name)
	await get_tree().create_timer(1.0).timeout
	Transition.switchScene('res://source/scenes/GameState.tscn')
