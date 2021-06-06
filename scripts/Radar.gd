extends Panel

const RADAR_TIME = 0.1
const RADAR_VERT_OFFSET = 20
const SYMBOL_COLOUR = Color(0, 0, 1)

var time = 0
var scaling = 100

func _process(delta):
	time += delta
	
	if time > RADAR_TIME:
		update()
		time = 0
	
func _draw():
	var player = Global.current_player
	
	if player == null:
		return
	
	var px = player.global_position.x
	var py = player.global_position.y
	
	var w = rect_size.x
	var h = rect_size.y - RADAR_VERT_OFFSET
	
	var w2 = w / 2 
	var h2 = h / 2
	
#	var gray_colour = Color(0.7, 0.7, 0.7)
	
	# player position
	var x = w2
	var y = h2 + RADAR_VERT_OFFSET
	var rect = Rect2(x - 2, y - 2, 5, 5)
	draw_rect(rect, Color.white)
	
	var colour

	# rock positions
	var rocks = get_tree().get_nodes_in_group("rocks")
	for rock in rocks:
		colour = Color.green
		
		x = (rock.global_position.x - px) / scaling + w2
		y = (rock.global_position.y - py) / scaling + h2 + RADAR_VERT_OFFSET
		
		if x < 0:
			continue
		if x > w:
			continue
			
		if y < RADAR_VERT_OFFSET:
			continue
		if y > h:
			continue

		rect = Rect2(x - 1, y - 1, 3, 3)
		draw_rect(rect, colour)
		
	# alien positions
	var aliens = get_tree().get_nodes_in_group("aliens")
	for alien in aliens:
		colour = Color.red
		
		x = (alien.global_position.x - px) / scaling + w2
		y = (alien.global_position.y - py) / scaling + h2 + RADAR_VERT_OFFSET

		if x < 0:
			continue
		if x > w:
			continue
			
		if y < RADAR_VERT_OFFSET:
			continue
		if y > h:
			continue

		rect = Rect2(x - 1, y - 1, 3, 3)
		draw_rect(rect, colour)

func set_range(radar_range):
	match radar_range:
		0:
			scaling = 50
		1:
			scaling = 100
		2:
			scaling = 200
