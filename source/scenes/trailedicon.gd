extends Sprite2D

# Lädt die Geisterbild-Szene, die wir oben erstellt haben
const AFTERIMAGE_SCENE = preload("res://afterimage.tscn")

# Zeitabstand zwischen den Geisterbildern (in Sekunden)
@export var spawn_rate: float = 0.0001
var timer: float = 0.0

func _process(delta: float) -> void:
	# Simpler Timer für das Spawnen
	timer += delta
	if timer >= spawn_rate:
		spawn_ghost()
		timer = 0.0

func spawn_ghost() -> void:
	var ghost = AFTERIMAGE_SCENE.instantiate()
	
	# Kopiert die exakte Grafik und den aktuellen Animationsframe
	ghost.texture = texture
	ghost.vframes = vframes
	ghost.hframes = hframes
	ghost.frame = frame
	ghost.flip_h = flip_h
	ghost.scale = scale
	
	# Setzt die Position exakt dorthin, wo das Sprite JETZT gerade ist
	ghost.position = position
	# Startet bereits leicht transparent
	ghost.modulate = Color(1.0, 0.0, 1.0, 0.6) 
	
	# Setzt den Geist in der Render-Reihenfolge HINTER das Haupt-Sprite
	ghost.z_index = z_index - 1
	# Fügt den Geist der Hauptszene hinzu, damit er an Ort und Stelle bleibt
	get_parent().add_child(ghost)
