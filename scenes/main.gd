extends Node2D
var bpm: float = 160
var timesec: float # normal time
var timebeat: float # aligned to the beat
var timebeatprev: float = -1
var chart: Array[Array] = [[1, 1], [1.5, 2]] # note: [timing, hits
var chartnext: int # index of the next note
var charthit: int = -1 # index of the last hit note
var ringrad: Vector2 = Vector2(112, 80): # x: outer ring, y: inner ring
	set(val): # automatically update playerrad with a setter
		ringrad = val
		playerrad = (ringrad.x - ringrad.y) / 2
var playerrad: float # radius that fits neatly into the ring
func _ready() -> void:
	ringrad = ringrad # run the setter
	$music.stream = preload("res://music/consider.ogg")
	$music.play()
func _process(delta: float) -> void:
	if floorf(timebeat) != floorf(timebeatprev):
		beat()
	timesec += delta
	timebeatprev = timebeat
	timebeat = timesec / (60 / bpm)
	#$/root.position = Vector2(704, 396 - sin(timebeat * PI / 4) * 32)
	#$/root.size = Vector2(512, 288 - cos(timebeat * PI / 4) * 64)
	if chartnext < len(chart):
		if chart[chartnext][0] < timebeat:
			chartnext += 1
	else:
		get_tree().reload_current_scene()
	queue_redraw()
func _input(event: InputEvent) -> void:
	if event is InputEventKey && event.pressed && !event.echo:
		var acccurr: float = timebeat - chart[chartnext - 1][0] # accuracy towards the current note
		var accnext: float = 999 # placeholder for when the note is at the end
		if chartnext < len(chart):
			accnext = timebeat - chart[chartnext][0] # accuracy towards the next note (if pressing too early
		var closestnote: int = chartnext - 1 # index of closest note (set to the current note by default
		var off: int # offset for the same note detection
		if absf(accnext) < absf(acccurr): # next note is closer
			closestnote = chartnext
			off = 1
		if charthit != closestnote: # dont hit the same note twice!
			var acc: float = minf(absf(acccurr), absf(accnext)) # always assume the best!
			if acc < 0.05:
				$rating.text = "perfect"
			elif acc < 0.1:
				$rating.text = "great"
			elif acc < 0.2:
				$rating.text = "okay"
			else:
				$rating.text = "offmiss!"
				return
		else:
			$rating.text = "duplimiss!"
			return
		$tap.play()
		charthit = chartnext - 1 + off
func beat() -> void:
	pass # something will probably happen here
func _draw() -> void:
	draw_circle(get_viewport_rect().size / 2, ringrad.x, Color.WHITE, false, 2)
	draw_circle(get_viewport_rect().size / 2, ringrad.y, Color.WHITE, false, 2)
	draw_circle(posonring(timebeat, 2), playerrad, Color.WHITE, false, 2)
	for n: Array in chart:
		var pos: Vector2 = posonring(n[0], 2)
		var trans: float = 1 + (1 + timebeat - n[0]) * 2 - max(timebeat - n[0] + 0.25, 0) * 8 # clearly short for transgender
		draw_circle(pos, playerrad, Color(Color.RED, trans), false, 2)
		draw_char(ThemeDB.fallback_font, pos - Vector2(4, -7), str(n[1]), 16, Color(Color.WHITE, trans))
func posonring(time: float, div: float) -> Vector2:
	return Vector2(get_viewport_rect().size.x / 2 + sin(time * PI / div) * (ringrad.x - playerrad), get_viewport_rect().size.y / 2 + cos(time * PI / div) * (ringrad.x - playerrad))
