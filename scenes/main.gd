extends Node2D
var bpm: float = 80
var timesec: float # normal time
var timebeat: float # aligned to the beat
var timebeatprev: float = -1
var chart: PackedFloat32Array = [0, 0.25, 0.5, 0.75, 3.125, 3.25, 3.5, 3.75, 4, 4.25, 4.5, 4.75, 6.5, 7, 7.5, 8, 8.5, 8.75]
var chartnext: int # index of the next chart note
var charthit: int # index of the last hit note
func _ready() -> void:
	$music.stream = ResourceImporterOggVorbis.load_from_file("C:/Users/User/Music/interesting.ogg")
	$music.play()
func _process(delta: float) -> void:
	if floorf(timebeat) != floorf(timebeatprev):
		beat()
	timesec += delta
	timebeatprev = timebeat
	timebeat = timesec / (60 / bpm)
	#$/root.position = Vector2(704, 396 - abs(sin(timebeat * PI / 2) * 64))
	if chartnext < len(chart):
		if chart[chartnext] < timebeat:
			chartnext += 1
	else:
		OS.alert("done")
		get_tree().quit()
	queue_redraw()
func _input(event: InputEvent) -> void:
	if event is InputEventKey && event.pressed && !event.echo:
		var acccurr: float = timebeat - chart[chartnext - 1] # accuracy towards the current note
		var accnext: float = 999 # placeholder for when the note is at the end
		if chartnext < len(chart):
			accnext = timebeat - chart[chartnext] # accuracy towards the next note (if pressing too early
		var closestnote: int = chartnext - 1 # index of closest note (set to the current note by default
		var off: int # offset for the same note detection
		if absf(accnext) < absf(acccurr): # next note is closer
			closestnote = chartnext
			off = 1
		elif absf(acccurr) < 0.25: # leniency for jacks
			closestnote = chartnext
		if charthit != closestnote: # dont hit the same note twice!
			var acc: float = minf(absf(acccurr), absf(accnext)) # always assume the best!
			if acc < 0.05:
				print("perfect")
			elif acc < 0.1:
				print("great")
			elif acc < 0.25:
				print("okay")
			else:
				print("miss!")
				return
		else:
			print("miss!")
			return
		$tap.play()
		charthit = chartnext - 1 + off
func beat() -> void:
	pass # something will probably happen here
func _draw() -> void:
	var ringouterrad: float = 112
	var ringinnerrad: float = 82
	var playerrad: float = 15
	draw_circle(Vector2(256, 144), ringouterrad, Color.WHITE, false, 2)
	draw_circle(Vector2(256, 144), ringinnerrad, Color.WHITE, false, 2)
	draw_circle(Vector2(256 + sin(timebeat * PI / 2) * (ringouterrad - playerrad), 144 + cos(timebeat * PI / 2) * (ringouterrad - playerrad)), playerrad, Color.WHITE, false, 2)
	for n: float in chart:
		draw_circle(Vector2(256 + sin(n * PI / 2) * (ringouterrad - playerrad), 144 + cos(n * PI / 2) * (ringouterrad - playerrad)), playerrad, Color(Color.RED, 1 + (1 + timebeat - n) * 2 - max(timebeat - n + 0.25, 0) * 8), false, 2)
