extends AnimatedSprite2D
class_name Note
static var colors:Array[String] = ['purple', 'blue', 'green', 'red']

var hit = false
var data:Array[Variant]
var lane = 0
var inHitZone = false
var cpu = false
var frameHeight = 0
var eH = 1
var lH = 1
var lengthSus = 0
var sustain:TextureRect
var endPiece:AnimatedSprite2D
var sustainContainer:Node2D
var missed = false
func _ready() -> void:
	sustainContainer = Node2D.new()
	add_child(sustainContainer)
	sustain = TextureRect.new()
	endPiece = AnimatedSprite2D.new()
	endPiece.scale.x = 1
	sustainContainer.show_behind_parent = true
	sustainContainer.position.y = 0

	sustain.expand_mode = TextureRect.EXPAND_IGNORE_SIZE


	sustainContainer.add_child(sustain)
	sustainContainer.add_child(endPiece)

func setup(_data:Array[Variant], strum:Strum, _speed:float = 21):
	if not sprite_frames and not strum:
		sprite_frames = load('res://assets/ui/notes/NOTE_assets.xml')
	elif not sprite_frames and strum:
		sprite_frames = strum.sprite_frames
	hit = false
	missed = false
	data = _data
	lane = int(data[1]) % 4
	
	sustainContainer.modulate.a = 1
	modulate = Color.WHITE
	self_modulate.a = 1
	sustain.texture = sprite_frames.get_frame_texture(colors[lane] + ' hold piece', 0)
	endPiece.sprite_frames = sprite_frames
	endPiece.play(colors[lane] + ' hold end')
	play(colors[lane])
	lengthSus = data[2]
	sustainContainer.visible = lengthSus > 0
	sustainContainer.show_behind_parent = true
	if(lengthSus > 0):
			sustain.visible = true
			endPiece.visible = true

	
			sustain.stretch_mode = TextureRect.STRETCH_SCALE


			updateSusLength(_speed)
	else:
			sustain.visible = false
			endPiece.visible = false

		
	
func updateSusLength(speed:float  = 1):
	var o = 0.0
	if hit and !missed:
		o =  Conductor.time-data[0]
		self_modulate.a = 0
	var sus_height = round(0.45 * speed * (data[2] - o)) - sustain.texture.get_height() * endPiece.scale.y
	sustain.size.x = sustain.texture.get_width()
	sustain.size.y = sus_height / .7
	sustain.position.x = -sustain.size.x / 2

	
	# --- CLIPPING LOGIC FOR SPRITE2D ENDPIECE ---
	if sus_height < 0:
		var tex_h =  endPiece.sprite_frames.get_frame_texture(colors[lane] + ' hold end', 0).get_height()
		# Convert the negative pixel height into how much of the sprite should stay visible
		var visible_height = round(tex_h + (sus_height / .7 / endPiece.scale.y)) 
		
		if visible_height <= 0:
			endPiece.visible = false
		else:
			endPiece.visible = true

			
			# Shift the source window down and shrink its rendering height
			#var clip_offset = tex_h - visible_height
		#	endPiece.region_rect = Rect2(0, clip_offset, endPiece.texture.get_width(), visible_height)
			# Lock the clipped sprite to the exact cutting line (0)
			endPiece.position.y = 0 + (visible_height * endPiece.scale.y / 2.0)
	else:
		# Reset normal sprite rendering when above zero
		endPiece.visible = true
		endPiece.position.y = sus_height / .7
		endPiece.position.y += endPiece.sprite_frames.get_frame_texture(colors[lane] + ' hold end', 0).get_height() * endPiece.scale.y / 2.0

	
func _process(_delta: float) -> void:
	inHitZone = data[0] <= Conductor.time + (166 * eH) and data[0] >= Conductor.time - (166 * lH)
