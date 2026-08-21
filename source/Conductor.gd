class_name Conductor

# Interner Signal-Hub, da statische Klassen keine Signale besitzen dürfen
class EventHub:
	signal on_step(step: int)
	signal on_beat(beat: int)
	signal on_measure(measure: int)

static var events: EventHub = EventHub.new()

static var safe_frames: int = 10
static var sfz: float = (safe_frames / 60.0) * 1000.0
static var time_changes: Array = []

static var time: float = 0.0:
	set(value):
		update_conductor(value)
		time = value

static var bpm: float = 100.0:
	set(value):
		bpm = value
		beat_length = (60.0 / bpm) * 1000.0
		step_length = beat_length * 0.25
		measure_length = beat_length * 4.0

static var beat_length: float = (60.0 / 100.0) * 1000.0
static var step_length: float = beat_length * 0.25
static var measure_length: float = beat_length * 4.0

static var cur_step: float = 0.0
static var cur_beat: float = 0.0
static var cur_section: float = 0.0
static var offset: float = 0.0

static func update_conductor(new_time: float) -> void:
	time_changes.sort_custom(func(a, b): return a["time"] < b["time"])

	var last_step: float = cur_step
	update_step(new_time)
	if floor(cur_step) != floor(last_step):
		events.on_step.emit(floori(cur_step))

	var last_beat: float = cur_beat
	update_beat()
	if floor(cur_beat) != floor(last_beat):
		events.on_beat.emit(floor(cur_beat))

	var last_sec: float = cur_section
	update_sec()
	if floor(cur_section) != floor(last_sec):
		events.on_measure.emit(floor(cur_section))

static func get_time_change_at(target_time: float) -> Dictionary:
	var last_time_change: Dictionary = {"time": 0.0, "bpm": bpm}
	for time_change in time_changes:
		if time_change["time"] <= (target_time - offset):
			last_time_change = time_change
	return last_time_change

static func add_time_change_at(target_time: float, target_bpm: float) -> void:
	time_changes.append({"time": target_time, "bpm": target_bpm})
	time_changes.sort_custom(func(a, b): return a["time"] < b["time"])

static func remove_latest_time_change_at(target_time: float) -> void:
	var last_time_change: Dictionary = get_time_change_at(target_time)
	if last_time_change.is_empty():
		return
	time_changes.erase(last_time_change)
	time_changes.sort_custom(func(a, b): return a["time"] < b["time"])

static func update_step(target_time: float) -> void:
	cur_step = get_step(target_time)

static func update_beat() -> void:
	cur_beat = cur_step / 4.0

static func update_sec() -> void:
	cur_section = cur_step / 16.0

static func get_step(target_time: float) -> float:
	var step: float = 0.0
	var last_time: float = 0.0
	var last_bpm: float = bpm

	for i in range(time_changes.size()):
		var tc: Dictionary = time_changes[i]
		if tc["time"] >= target_time:
			break
		var step_len: float = (60.0 / last_bpm) * 1000.0 / 4.0
		step += (tc["time"] - last_time) / step_len
		last_time = tc["time"]
		last_bpm = tc["bpm"]

	if bpm != last_bpm:
		bpm = last_bpm

	var step_len_final: float = (60.0 / last_bpm) * 1000.0 / 4.0
	step += (target_time - last_time) / step_len_final
	return step

static func get_beat(target_time: float) -> float:
	return get_step(target_time) / 4.0
