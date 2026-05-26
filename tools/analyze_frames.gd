extends SceneTree

func _init():
	var img = Image.new()
	var err = img.load("res://sprites/asset.png")
	if err != OK:
		print("ERROR: ", err)
		quit(1)
		return

	print("Image: ", img.get_width(), "x", img.get_height())

	# Find all contiguous content regions (row ranges with >10 px)
	var regions = []
	var in_reg = false
	var r_start = 0
	var row_data = []
	for y in range(0, img.get_height()):
		var count = 0
		for x in range(0, img.get_width()):
			if img.get_pixel(x, y).a > 0.1:
				count += 1
		row_data.append(count)
		if count > 10 and not in_reg:
			in_reg = true
			r_start = y
		elif count <= 10 and in_reg:
			in_reg = false
			regions.append({"y0": r_start, "y1": y - 1, "h": y - r_start, "max_px": -1})

	if in_reg:
		regions.append({"y0": r_start, "y1": img.get_height() - 1, "h": img.get_height() - r_start, "max_px": -1})

	# Get max pixel count per region
	for r in regions:
		var mx = 0
		for y in range(r["y0"], r["y1"] + 1):
			if row_data[y] > mx:
				mx = row_data[y]
		r["max_px"] = mx

	print("\n=== Content Regions ===")
	for i in range(len(regions)):
		var r = regions[i]
		var label = ""
		if r["max_px"] > 400:
			label = " (FULL WIDTH - logo/text)"
		elif r["max_px"] > 250:
			label = " (wide sprite)"
		elif r["max_px"] > 100:
			label = " (medium sprite)"
		else:
			label = " (small sprite)"
		print("Region ", i, ": rows ", r["y0"], "-", r["y1"], " (h=", r["h"], "), max=", r["max_px"], "px", label)

	# For each region with medium sprite width, find exact frame bounds
	print("\n=== Frame Analysis per Region ===")
	for ri in range(len(regions)):
		var r = regions[ri]
		if r["max_px"] < 30 or r["max_px"] > 250:
			continue
		var ys = r["y0"]
		var ye = r["y1"]

		var in_frame = false
		var fx_start = 0
		var frames = []
		for x in range(0, img.get_width()):
			var has_pixel = false
			for y in range(ys, ye):
				if img.get_pixel(x, y).a > 0.1:
					has_pixel = true
					break
			if has_pixel and not in_frame:
				in_frame = true
				fx_start = x
			elif not has_pixel and in_frame:
				in_frame = false
				var fx_end = x
				var real_top = ye
				var real_bot = ys
				for yy in range(ys, ye):
					var row_has = false
					for xx in range(fx_start, fx_end):
						if img.get_pixel(xx, yy).a > 0.1:
							row_has = true
							break
					if row_has:
						if yy < real_top: real_top = yy
						if yy > real_bot: real_bot = yy
				if fx_end - fx_start > 10:
					frames.append({
						"x": fx_start, "y": real_top, "w": fx_end - fx_start, "h": real_bot - real_top + 1
					})

		if len(frames) > 0:
			print("\nRegion ", ri, " (rows ", ys, "-", ye, "): ", len(frames), " frames")
			for fi in range(min(len(frames), 14)):
				var f = frames[fi]
				print("  [", fi, "] x=", f["x"], " y=", f["y"], " w=", f["w"], " h=", f["h"])
			if len(frames) > 14:
				print("  ... (", len(frames) - 14, " more)")

	quit(0)
