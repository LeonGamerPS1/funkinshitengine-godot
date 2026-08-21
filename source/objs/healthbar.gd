@tool
extends TextureProgressBar

class_name HealthBar

# Erhöhe den Wert für ein schnelleres, knackigeres Zurückschrumpfen
@export var lerp_speed: float = 15.0 
@export var iconBopScale: Vector2 = Vector2(1.2, 1.2)
var puss = 0.0

func _ready() -> void:
	if(!Engine.is_editor_hint()):
		Conductor.events.on_beat.connect(beatHit)

func _process(_delta: float) -> void:
	var icon_node = $icons
	
	# Framerate-unabhängiger Lerp zurück zur Normalgröße (1.0, 1.0)
	icon_node.scale = icon_node.scale.lerp(Vector2.ONE, 1.0 - exp(-_delta * lerp_speed))
	
	# 1. Standard-Verhältnis berechnen (0.0 bis 1.0)

	if max_value > min_value:
		puss = lerp((value - min_value) / (max_value - min_value), puss, exp(-_delta * 6))
	
	# 2. VERHÄLTNIS INVERTIEREN: Für Right-to-Left Füllungen
	var fill_x_position = size.x * (1.0 - puss)
	
	# 3. Vertikal exakt in der Mitte bleiben
	var fill_y_position = size.y / 4
	
	# 4. Node2D positionieren
	icon_node.position = Vector2(fill_x_position, fill_y_position )

func beatHit(_beat: int) -> void:
	# Setzt die Skalierung beim Beat sofort auf die Bop-Größe
	$icons.scale = iconBopScale
