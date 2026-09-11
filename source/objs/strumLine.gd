extends Node2D
class_name StrumLine

signal noteHit
signal noteMiss
signal penaltyMiss
@export var strums: int = 4
@export var isOpponentSide: bool = true
@export var downscroll = false
var speed = 1.0
@export var character: Character
@export var camPos: Vector2 = Vector2()
var strumArray: Array[Strum] = []
var noteDatas: Array[Variant] = []
var deadNotes: Array[Note] = []
var aliveNotes: Array[Note] = []

var deadSplashes: Array[Splash] = []
var aliveSplashes: Array[Splash] = []

static var DefaultStrumResetTime = 0.15



func _ready() -> void:

	Conductor.events.on_step.connect(stepHit)
	var strum_width: float = 160.0 * 0.7
	var total_width: float = strum_width * strums
	var start_x: float = -(total_width / 2.0) + (strum_width / 2.0)
	var magic = 0
	for i in range(strums):
		var strum: Strum = Strum.new()
		strum.init(i)
		
		strum.position.x = start_x + magic
		strum.position.y = 40
		magic += strum.sprite_frames.get_frame_texture(strum.animation, 0).get_width() * strum.scale.x
		strumArray.push_back(strum)
		add_child(strum)

func addNoteArray(array: Array[Variant]):
	noteDatas.push_back(array)
	




func sor1():
	noteDatas.sort_custom(sort_ascending)

func _process(_delta: float) -> void:
	while noteDatas.size() > 0:
		var data = noteDatas[0]
		if data[0] <= Conductor.time + (1500 / speed):
			var strum: Strum = strumArray[int(data[1]) % strums] 
			var note: Note = getNoteFromDump()
			add_child(note)
			note.setup(data, strum, speed)
			note.cpu = isOpponentSide
			aliveNotes.append(note)
			note.susCont.rotation_degrees = 180 if downscroll else 0
			noteDatas.remove_at(0) 
		else:
			break 
	
	if not isOpponentSide:
		keyShit()
	for i in range(aliveNotes.size() - 1, -1, -1):
		if i >= aliveNotes.size(): 
			continue
			
			
		var killZone = 350.0 / speed
		var note: Note = aliveNotes[i]
		var strum: Strum = strumArray[note.lane]
		var time = note.data[0]
		
		if note.hit and !isOpponentSide and !strum.holding:
			note.missed = true
			note.hit = false
		
		note.position = strum.position
		

		if  time <= Conductor.time and isOpponentSide:
			hitNote(note)
			
		if note.lengthSus > 0 and (note.hit or note.missed):
			note.updateSusLength(speed)

	

			
		if not note.hit:
			
			if not downscroll:
				note.position.y += (time - Conductor.time) * (0.45 * speed) 
			else:
				note.position.y -= (time - Conductor.time) * (0.45 * speed) 
		var p = killZone if note.missed else 0.0
		if (note.hit or note.missed) and time + note.lengthSus + p <= Conductor.time:
			wreckNote(note)

	

		if not note.hit and not note.missed and  time <= Conductor.time - (350 / speed):
			if not isOpponentSide:
				noteMiss.emit(note, self)
			wreckNote(note)


func hitNote(note:Note):
	if note.missed:
		return
	var strum:Strum = strumArray[note.lane]

	if not note.hit:
		noteHit.emit(note, self)
		strum.confirm()
		doCharAnim(note)
		if(note.cpu):
			strum.r = DefaultStrumResetTime
			var splash = getSplashFromDump()
			splash.spawn(note, note.lane)
			add_child(splash)
			if not splash.kill.is_connected(splashEnd):
				splash.kill.connect(splashEnd)
			
	
	
	if not isOpponentSide and not hitDir.has(note.lane):
		hitDir.push_front(note.lane)

	if note.lengthSus <= 0:
		wreckNote(note)
	note.hit = true
func wreckNote(note: Note):
	
		aliveNotes.erase(note) 
		if not note in deadNotes:
			deadNotes.append(note)
		if(note.get_parent()):
			note.get_parent().remove_child(note)

func doCharAnim(note:Note):
	if character:
		character.playAnim(Character.singAnims[note.lane])
		character.holdTimer = Conductor.beat_length / 1000.0

func getNoteFromDump() -> Note:
	if deadNotes.size() > 0:
		var recycled_note:Note = deadNotes.pop_front()
	
		recycled_note.hit = false
		recycled_note.inHitZone = false

			
		return recycled_note
		
	return Note.new()

func splashEnd(splash:Splash):
	remove_child(splash)
	deadSplashes.push_front(splash)
	aliveSplashes.erase(splash)
	
func getSplashFromDump() -> Splash:
	if deadSplashes.size() > 0:
		var recycled_note: Splash = deadSplashes.pop_front()
		return recycled_note
		
	return Splash.new()


func sort_ascending(a, b):
	if a[0] < b[0]:
		return true
	return false

var hitNotes:Array[Note] = []
var dirs:Array[int] = []
var hitDir:Array[int] = []

func keyShit():
	hitNotes.clear()
	dirs.clear()
	hitDir.clear()
	
	var keyJP = [Input.is_action_just_pressed("ui_left"),Input.is_action_just_pressed("ui_down"),Input.is_action_just_pressed("ui_up"),Input.is_action_just_pressed("ui_right")]
	var keyP = [Input.is_action_pressed("ui_left"),Input.is_action_pressed("ui_down"),Input.is_action_pressed("ui_up"),Input.is_action_pressed("ui_right")]
	var keyJR = [Input.is_action_just_released("ui_left"),Input.is_action_just_released("ui_down"),Input.is_action_just_released("ui_up"),Input.is_action_just_released("ui_right")]
	
	for strum in strumArray:
		if strum.dir > keyP.size() - 1:
			break
		strum.holding = keyP[strum.dir]
		if(keyJP[strum.dir]):
			strum.press()
		elif (keyJR[strum.dir]):
			strum.idle()
	
	if(keyP.count(true) > 0):
		for note in aliveNotes:
			if note.inHitZone and not note.hit:
				hitNotes.push_back(note)
				dirs.push_back(note.lane)
				
	for strum in strumArray:
		if strum.dir > keyP.size() - 1:
			break
		if(hitNotes.size() < 1):
			break
		if(keyJP[strum.dir] and dirs.count(strum.dir) < 1):
			penaltyMiss.emit(strum.dir)


	var lanesHitThisFrame: Array[int] = []

	for note in hitNotes:

		if lanesHitThisFrame.has(note.lane):
			continue
			
		if(keyJP[note.lane]):
			hitNote(note)
			lanesHitThisFrame.push_back(note.lane) 
func stepHit(_step:int):
	for note in aliveNotes:
		if note.hit and not note.missed:
			doCharAnim(note)
			var strum = strumArray[note.lane]
			strum.confirm()
			noteHit.emit(note, self)
			if note.cpu:
				strum.r = DefaultStrumResetTime
			
func _exit_tree() -> void:
	Conductor.events.on_step.disconnect(stepHit)
	for splash in deadSplashes:
		splash.free()
		
		
	deadSplashes.resize(0)
	
	for n in deadNotes:
		n.free()
	deadNotes.resize(0)
