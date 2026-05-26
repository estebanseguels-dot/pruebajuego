extends SceneTree

func _init():
	var img = Image.new()
	var err = img.load("res://sprites/asset2.png")
	if err != OK:
		print("ERROR: ", err)
		quit(1)
		return

	print("Original: ", img.get_width(), "x", img.get_height())

	# Chroma key green background (same as asset.png: #37634D)
	# Sample the background color from the edges
	var bg = img.get_pixel(0, 0)
	print("Background color at (0,0): ", bg)

	var threshold = 0.3
	var removed = 0

	for y in range(0, img.get_height()):
		for x in range(0, img.get_width()):
			var px = img.get_pixel(x, y)
			var diff = abs(px.r - bg.r) + abs(px.g - bg.g) + abs(px.b - bg.b)
			if diff < threshold:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
				removed += 1

	var total = img.get_width() * img.get_height()
	print("Pixels removed: ", removed, " / ", total, " (", float(removed) / total * 100, "%)")

	img.save_png("res://sprites/asset2_clean.png")
	print("Saved: res://sprites/asset2_clean.png")

	# Now analyze frames
	print("\n=== Frame analysis after chroma key ===")
	var in_frame = false
	var fx_start = 0
	var frames = []
	for x in range(0, img.get_width()):
		var has_pixel = false
		for y in range(0, img.get_height()):
			if img.get_pixel(x, y).a > 0.1:
				has_pixel = true
				break
		if has_pixel and not in_frame:
			in_frame = true
			fx_start = x
		elif not has_pixel and in_frame:
			in_frame = false
			var fx_end = x
			var real_top = img.get_height()
			var real_bot = 0
			for yy in range(0, img.get_height()):
				var row_has = false
				for xx in range(fx_start, fx_end):
					if img.get_pixel(xx, yy).a > 0.1:
						row_has = true
						break
				if row_has:
					if yy < real_top: real_top = yy
					if yy > real_bot: real_bot = yy
			frames.append({
				"x": fx_start, "y": real_top, "w": fx_end - fx_start, "h": real_bot - real_top + 1
			})

	print("Total frames: ", len(frames))
	for i in range(len(frames)):
		var f = frames[i]
		print("  [", i, "] x=", f["x"], " y=", f["y"], " w=", f["w"], " h=", f["h"])

	# Group by height
	print("\n=== By height ===")
	var by_h = {}
	for i in range(len(frames)):
		var f = frames[i]
		var key = str(f["h"])
		if not by_h.has(key):
			by_h[key] = []
		by_h[key].append(i)
	for h in by_h.keys():
		print("  height=", h, ": frames ", by_h[h], " (count=", len(by_h[h]), ")")

	# Sort by x and print groups
	print("\n=== Extract samples ===")
	DirAccess.open("res://tools/").make_dir_recursive("samples")
	for i in range(len(frames)):
		var f = frames[i]
		var out = Image.create(f["w"], f["h"], false, Image.FORMAT_RGBA8)
		for y in range(f["h"]):
			for x in range(f["w"]):
				out.set_pixel(x, y, img.get_pixel(f["x"] + x, f["y"] + y))
		var path = "res://tools/samples/a2f_" + str(i).pad_zeros(2) + ".png"
		out.save_png(path)
		print("  Saved: ", path)

	print("\nDone!")
	quit(0)
