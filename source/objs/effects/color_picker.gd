extends ColorPicker

@export var mirror_sprite: Node2D
@export var noteID: int = 0

func _ready() -> void:
	# Verhindert Absturz, falls das Array nicht existiert
	if not Save.Settings.has('noteColors'):
		Save.Settings['noteColors'] = []
	
	# Array automatisch vergrößern, falls die noteID größer ist als das Array
	while Save.Settings['noteColors'].size() <= noteID:
		Save.Settings['noteColors'].push_back(color)
	
	# Gespeicherte Farbe laden
	color = Save.Settings['noteColors'][noteID]
	
	# Signal verbinden, um Performance zu sparen (kein _process nötig)
	color_changed.connect(_on_color_changed)
	
	# Initiale Farbe auf das Sprite übertragen
	if mirror_sprite:
		mirror_sprite.modulate = color

func _on_color_changed(new_color: Color) -> void:
	if mirror_sprite:
		mirror_sprite.modulate = new_color
	
	Save.Settings['noteColors'][noteID] = new_color
	# Hier optional: Save.save_to_disk() aufrufen, wenn direkt gespeichert werden soll
