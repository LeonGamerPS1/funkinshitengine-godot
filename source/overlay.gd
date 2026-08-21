extends Label

var time_passed: float = 0.0

func _ready() -> void:
	get_window().position = Vector2i(100, 100)

func _process(delta: float) -> void:
	time_passed += delta
	# Aktualisiert die Anzeige exakt jede Sekunde
	if time_passed >= 1.0:
		_update_performance_display()
		time_passed = 0.0

func _update_performance_display() -> void:
	# 1. FPS holen
	var current_fps: int = Engine.get_frames_per_second()
	
	# 2. Frametime in Millisekunden berechnen (Sicherheits-Check gegen Division durch 0)
	var frame_time_ms: float = 0.0
	if current_fps > 0:
		frame_time_ms = 1000.0 / current_fps
	
	# 3. Godot Versions-String holen (z. B. "4.4.stable")
	var godot_version: String = Engine.get_version_info().string

	# 4. Formatierung über den %-Operator
	# %d   = FPS als Ganzzahl
	# %.1f = Frametime gerundet auf 1 Nachkommastelle
	# %s   = Godot Version als Text-String
	text = "FPS: %d (%0.1f ms) | Godot: %s" % [current_fps, frame_time_ms, godot_version]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_F12:
			visible = not visible
