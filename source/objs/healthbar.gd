@tool
extends TextureProgressBar

class_name HealthBar

@export var lerp_speed: float = 15.0 
@export var iconBopScale: Vector2 = Vector2(1.2, 1.2)
var puss = 0.0

func _ready() -> void:
	if(!Engine.is_editor_hint()):
		Conductor.events.on_beat.connect(beatHit)

func _process(_delta: float) -> void:
	var icon_node = $icons
	
	if max_value > min_value:
		puss = (value - min_value) / (max_value - min_value)
	
	var fill_x_position = size.x * (1.0 - puss)
	var fill_y_position =  -75
	
	icon_node.position = Vector2(fill_x_position, fill_y_position )

var tw:Tween
func beatHit(_beat: int) -> void:
	var icon_node = $icons
	icon_node.scale = iconBopScale
	if tw:
		tw.kill()
	var bop_tween = create_tween()
	tw = bop_tween
	bop_tween.set_trans(Tween.TRANS_LINEAR)
	bop_tween.set_ease(Tween.EASE_OUT)
	bop_tween.tween_property(icon_node, "scale", Vector2.ONE, 0.15)
