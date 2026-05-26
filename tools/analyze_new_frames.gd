extends SceneTree

func _init():
	var dir = DirAccess.open("res://sprites/sprite_frames/")
	if dir == null:
		print("ERROR: Cannot open sprites/sprite_frames/")
		quit(1)
		return

	dir.list_dir_begin()
	var files = []
	while true:
		var f = dir.get_next()
		if f == "":
			break
		if f.ends_with(".png"):
			files.append(f)
	dir.list_dir_end()

	files.sort()
	print("Total frames: ", len(files))

	# Analyze each frame: dimensions and pixel count
	var frame_data = []
	for f in files:
		var path = "res://sprites/sprite_frames/" + f
		var img = Image.new()
		var err = img.load(path)
		if err != OK:
			print("ERROR loading ", f, ": ", err)
			continue

		var px_count = 0
		for y in range(img.get_height()):
			for x in range(img.get_width()):
				if img.get_pixel(x, y).a > 0.1:
					px_count += 1

		frame_data.append({
			"file": f,
			"w": img.get_width(),
			"h": img.get_height(),
			"px": px_count,
		})

	# Group by dimensions
	print("\n=== Grouped by height ===")
	var by_h = {}
	for fd in frame_data:
		var key = str(fd["h"])
		if not by_h.has(key):
			by_h[key] = []
		by_h[key].append(fd)

	var heights = by_h.keys()
	heights.sort()
	for h in heights:
		var list = by_h[h]
		print("height=", h, "px: ", len(list), " frames")
		for fd in list:
			print("  ", fd["file"], " (", fd["w"], "x", fd["h"], ", ", fd["px"], "px)")

	# Show all frames with their dimensions
	print("\n=== All frames in order ===")
	for fd in frame_data:
		print(fd["file"], ": ", fd["w"], "x", fd["h"], " (", fd["px"], " px)")

	quit(0)
