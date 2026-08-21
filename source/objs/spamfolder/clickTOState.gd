extends Button

@export var scene: PackedScene

func _ready() -> void:
	pressed.connect(gotoState)

func gotoState() -> void:
	if not scene:
		return
		
	disabled = true
	
	# 1. Maske erstellen und an die Root hängen (unabhängig von Szenen)
	var mask = ColorRect.new()
	mask.color = Color.BLACK
	mask.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mask.scale = Vector2(5,5)
	mask.mouse_filter = Control.MOUSE_FILTER_STOP
	mask.modulate.a = 0.0
	mask.position.x -= 500
	get_tree().root.add_child(mask)
	
	# 2. Einblenden (Schwarzbild) - Tween an die Maske binden!
	var tween_in = mask.create_tween()
	tween_in.tween_property(mask, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_SINE)
	await tween_in.finished
	
	# --- DER TRICK: Die Maske übernimmt jetzt, da der Button gleich stirbt ---
	var mask_script = GDScript.new()
	mask_script.source_code = """
extends ColorRect
var target_scene: PackedScene

func execute_switch():
	# Alte Szene löschen (hier stirbt der Button sauber)
	var current = get_tree().current_scene
	if current:
		current.queue_free()
	
	# Neue Szene instanziieren und aktivieren
	var next = target_scene.instantiate()
	get_tree().root.add_child(next)
	get_tree().current_scene = next
	
	# Maske wieder ganz nach vorne schieben
	move_to_front()
	
	# Einen Frame warten, bis die neue Szene bereit ist
	await get_tree().process_frame
	
	# Ausblenden (wieder sichtbar machen)
	var tween_out = create_tween()
	tween_out.tween_property(self, "modulate:a", 0.0, 0.4).set_trans(Tween.TRANS_SINE)
	await tween_out.finished
	
	# Maske löscht sich am Ende selbst
	queue_free()
"""
	mask_script.reload()
	mask.set_script(mask_script)
	
	# Daten an die Maske übergeben und den Wechsel starten
	mask.set("target_scene", scene)
	mask.call("execute_switch")
