extends Label



var d:float = 0
var ld:float = 0
var godot_version: String = Engine.get_version_info().string
func _process(_delta: float) -> void:
	if not visible:
		return
	d += _delta
	if d >= 1:
		_update_performance_display()
		d = 0



func _update_performance_display() -> void:

	var current_fps: float = Engine.get_frames_per_second()

	var frame_time_ms: float = 0.0
	if current_fps > 0:
		frame_time_ms = 1000.0 / current_fps
	

	
	var DC = Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	var RAM = OS.get_static_memory_usage() / 1024.0 / 1024.0
	var VRAM = Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1024.0 / 1024.0
	text = "FPS: %d (%0.1f ms) | Godot: %s\nRAM: %dMB\nVRAM: %dMB\nDrawCalls: %0.1f\nNodes:%s" % [current_fps, frame_time_ms, godot_version, RAM,VRAM,DC,get_tree().get_node_count() ]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_F12:
			visible = not visible
