extends ColorRect

class_name CameraFlash

static var instance: CameraFlash

func _enter_tree() -> void:
	if instance == null:
		instance = self
	else:
		queue_free()

func _ready() -> void:
	anchors_preset = LayoutPreset.PRESET_FULL_RECT
	mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE
	color = Color(1, 1, 1, 1)

static var lastTween:Tween
static func flash(duration: float = 1, flash_color: Color = Color.WHITE, start:float = 1, end:float = 0) -> void:
	if instance == null:
		return
	instance.visible = true
		
	instance.color = flash_color
	instance.modulate.a = start
	
	if lastTween:
		lastTween.kill()
	var tween: Tween = instance.create_tween()
	lastTween = tween
	tween.tween_property(instance, "modulate:a", end, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
