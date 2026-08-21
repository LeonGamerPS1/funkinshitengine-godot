extends Sprite2D

@export var fade_speed: float = 3.0
@export var drift_speed: float = 20.0 # Bewegt den Geist leicht nach rechts beim Faden

func _process(delta: float) -> void:
	# Verringert die Sichtbarkeit
	modulate.a -= fade_speed * delta
	
	# Lässt das Geisterbild unabhängig vom Spieler leicht nach rechts driften
	global_position.x += drift_speed * delta
	
	# Löscht das Objekt, wenn es komplett unsichtbar ist
	if modulate.a <= 0:
		queue_free()
