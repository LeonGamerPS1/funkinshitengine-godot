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
var endPiece:Sprite2D

var missed = false
func _ready() -> void:

	sustain = TextureRect.new()
	endPiece = Sprite2D.new()
	endPiece.scale.x = 1



	endPiece.scale.y = .5
	sustain.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	
	scale = Vector2(.7, .7)

	sustain.use_parent_material = true
	sustain.show_behind_parent = true

	endPiece.use_parent_material = true
	add_child(endPiece)
	add_child(sustain)

	material = load('res://assets/shaders/noteRGB.material')

	
	set_instance_shader_parameter("use", true)
	sustain.set_instance_shader_parameter("use", true)
	endPiece.set_instance_shader_parameter("use", true)
	sustain.set_instance_shader_parameter('alpha', .9)
	endPiece.set_instance_shader_parameter('alpha', .9)

func setup(_data:Array[Variant], strum:Strum, _speed:float = 21):
	
	if not sprite_frames and not strum:
		sprite_frames = load('res://assets/ui/notes/NOTE_assets.xml')
	elif not sprite_frames and strum:
		sprite_frames = strum.sprite_frames
	hit = false
	missed = false
	data = _data
	lane = int(data[1]) % 4
	var rgb = Save.Settings.get('noteRGB')[lane]
	applyRGB(self, rgb[0],rgb[1],rgb[2])
	applyRGB(sustain, rgb[0],rgb[1],rgb[2])
	applyRGB(endPiece,rgb[0],rgb[1],rgb[2])

	
	self_modulate.a = 1

	sustain.texture = sprite_frames.get_frame_texture(colors[lane] + ' hold piece', 0)
	endPiece.texture = sprite_frames.get_frame_texture(colors[lane] + ' hold end', 0)
	play(colors[lane])
	lengthSus = data[2]

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

	var sus_height = round(0.45 * speed * (data[2] - o)) + endPiece.offset.y
	sustain.size.x = sustain.texture.get_width()
	sustain.size.y = sus_height / .7
	sustain.position.x = -sustain.size.x / 2

	
	# --- CLIPPING LOGIC FOR SPRITE2D ENDPIECE ---
	if sus_height < 0:
		var tex_h = endPiece.texture.get_height()
		# Convert the negative pixel height into how much of the sprite should stay visible
		var visible_height = round(tex_h + (sus_height / .7 / endPiece.scale.y))
		
		if visible_height <= 0:
			endPiece.visible = false
		else:
			endPiece.visible = true
			endPiece.region_enabled = true
			
			# Shift the source window down and shrink its rendering height
			var clip_offset = tex_h - visible_height
			endPiece.region_rect = Rect2(0, clip_offset, endPiece.texture.get_width(), visible_height)
			# Lock the clipped sprite to the exact cutting line (0)
			endPiece.position.y = 0 + (visible_height * endPiece.scale.y / 2.0)
	else:
		# Reset normal sprite rendering when above zero
		endPiece.visible = true
		endPiece.region_enabled = false
		endPiece.position.y = sus_height / .7
		endPiece.position.y += endPiece.texture.get_height() * endPiece.scale.y / 2.0

	
func _process(_delta: float) -> void:
	inHitZone = data[0] <= Conductor.time + (166 * eH) and data[0] >= Conductor.time - (166 * lH)
	
	
static func applyRGB(spr:CanvasItem, r,g,b):
	spr.set_instance_shader_parameter('red', r)
	spr.set_instance_shader_parameter('green', g)
	spr.set_instance_shader_parameter('blue', b)
