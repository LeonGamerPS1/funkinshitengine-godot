extends Node2D

@export
var inst:AudioStreamPlayer2D
@export
var voices:AudioStreamPlayer2D

@export var strumLines:Array[StrumLine]
@export var characters:Array[Character]
@export var downscroll = false
@onready var camHUD:CanvasLayer = $camHUD
@onready var camGame:Camera2D = $camFollow/Camera2D
@export var healthBar:HealthBar
@export var timeBar:HealthBar
@export var iconP1:Array[Sprite2D] = []
@export var iconP2:Array[Sprite2D] = []
var timeTxt:Label

static var song:Variant

var startedCountdown = false
var startedSong = false
var health = 1


func _ready() -> void:
	timeTxt = timeBar.get_node("progress text")
	timeBar.modulate.a = 0
	startCountdown()
	song = Song.loadFromJson('hard', 'manifest')
	inst.stream = AudioUtil.load_stream(AudioUtil.add_audio_ext('res://assets/songs/' + str(song.song).to_lower().replace(' ','-')) + '/Inst')
	voices.stream = AudioUtil.load_stream(AudioUtil.add_audio_ext('res://assets/songs/' + str(song.song).to_lower().replace(' ','-')) + '/Voices')
	timeBar.value = 0
	timeBar.max_value = voices.stream.get_length()
	Conductor.bpm = song.bpm

	Conductor.time = -Conductor.beat_length * 5
	Conductor.events.on_measure.connect(onSectionHit)
	if downscroll:
		$camHUD/Node2D/strumlines.position.y = 720 - 150 - (160 * 0.3)
		healthBar.position.y = 68
	
	var pos = 0
	var sectionLength = Conductor.measure_length
	for section in song.notes:
		if(section.has('changeBPM') && section.changeBPM):
			Conductor.add_time_change_at(pos, section.bpm)
			sectionLength = (60 / section.bpm) * 4000
		pos += sectionLength
		for note in section.sectionNotes:
			var wasGoodHit = section.mustHitSection
			if(note[1] > 3):
				wasGoodHit = !wasGoodHit
			strumLines[1 if wasGoodHit else 0].addNoteArray(note)
	for i in strumLines:
		i.speed = song.speed
		i.downscroll = downscroll
		i.sor1()
		i.noteHit.connect(hitNote)
		i.noteMiss.connect(missNote)
		
	
func startCountdown():
	startedCountdown = true
	
func startSong():
	if startedSong:
		return
	startedSong = true
	inst.play(0)
	var tween = timeBar.create_tween()
	tween.tween_property(timeBar, 'modulate:a', 1, 1)

	voices.play(inst.get_playback_position())

var sec: Variant

func onSectionHit(section: int):
	sec = null 
	
	if section >= 0 and section < song.notes.size():
		sec = song.notes[section]

	if sec:
		var char_index = 1 if sec.mustHitSection else 0
		if char_index < characters.size() and is_instance_valid(characters[char_index]):
			var chara: Character = characters[char_index]
			$camFollow.position = chara.position + chara.camPos

	camGame.zoom += Vector2(0.015, 0.015)
	camHUD.scale += Vector2(0.03, 0.03)

	
func _process(_delta: float) -> void:
	if healthBar.value != health:
		healthBar.value = health
		var perc =  health / healthBar.max_value

		
		for icon in iconP1:
			updateIcon(icon, true, perc)
		for icon in iconP2:
			updateIcon(icon, false, perc)
			
		if health <= 0:
			onDeath()
			return
			
		
	camGame.zoom = lerp(Vector2.ONE,camGame.zoom,exp(-_delta * 8) )
	camHUD.scale = lerp(Vector2.ONE,camHUD.scale,exp(-_delta * 8) )
	var inst_pos = inst.get_playback_position()
	if(inst.playing):

		timeBar.value = inst_pos

		var song_name: String = song.song
		var difficulty: String = "HARD"
		var current_seconds: float = timeBar.value
		var total_seconds: float = timeBar.max_value


		var cur_min: float = current_seconds / 60.0
		var cur_sec: int = int(current_seconds) % 60
		var tot_min: float = total_seconds / 60.0
		var tot_sec: int = int(total_seconds) % 60

		timeTxt.text = "%s - %s  (%d:%02f / %d:%02d)" % [
		song_name, 
		difficulty, 
		cur_min, 
		cur_sec, 
		tot_min, 
		tot_sec
		]

	
		Conductor.time = 1000 * (inst.get_playback_position())
		
		if voices.playing:
			
			var voice_pos = voices.get_playback_position()
			if abs(inst_pos - voice_pos) > 0.015:
				voices.seek(inst_pos)
				
	if(startedCountdown and not startedSong):
		# Keep delta processing during countdown
		Conductor.time += _delta * 1000
		if(Conductor.time >= 0):
			startSong()
			

func hitNote(note:Note, strumline:StrumLine):
	if not note.cpu:
		health += 0.023
		
func missNote(note:Note, strumline:StrumLine):
	health -= 0.047 * 2
	
func updateIcon(icon:Sprite2D, player:bool, percent:float):
	if icon.hframes == 1:
		return # incase your icon is single framed just dont add it if its single framed... this is just incase
	icon.frame = 0
	if player:
		if percent > 0.8:
			icon.frame = 2  if icon.hframes >= 3  else 0
		if percent < 0.2:
			icon.frame = 1
	else:
		if percent > 0.8:
			icon.frame = 1
		if percent < 0.2:
			icon.frame = 2  if icon.hframes >= 3  else 0
			
		
func onDeath():
	Transition.switchScene('res://source/scenes/GameState.tscn')

	
