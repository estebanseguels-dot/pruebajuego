extends SceneTree

func _init():
	var img = Image.new()
	img.load("res://sprites/asset2_clean.png")
	DirAccess.open("res://").make_dir_recursive("assets/frames2")

	var raw_frames = [
		{"x":2, "y":3, "w":17, "h":109},
		{"x":43, "y":3, "w":52, "h":113},
		{"x":100, "y":4, "w":18, "h":108},
		{"x":123, "y":5, "w":23, "h":111},
		{"x":147, "y":3, "w":52, "h":111},
		{"x":221, "y":5, "w":37, "h":110},
		{"x":259, "y":2, "w":83, "h":113},
		{"x":368, "y":5, "w":37, "h":110},
		{"x":410, "y":12, "w":42, "h":103},
		{"x":461, "y":12, "w":38, "h":104},
		{"x":512, "y":11, "w":29, "h":105},
	]

	var dir_names = ["right", "up", "down"]

	var naming = {
		0: {"prefix": "idle", "per_row": 1, "offset": 0},
		1: {"prefix": "walk", "per_row": 2, "offset": 0},
		2: {"prefix": "walk", "per_row": 1, "offset": 3},
		3: {"prefix": "walk", "per_row": 2, "offset": 4},
		4: {"prefix": "run", "per_row": 1, "offset": 0},
		5: {"prefix": "run", "per_row": 3, "offset": 1},
		6: {"prefix": "hurt", "per_row": 1, "offset": 0},
		7: {"prefix": "hurt", "per_row": 1, "offset": 1},
		8: {"prefix": "hurt", "per_row": 1, "offset": 2},
		9: {"prefix": "hurt", "per_row": 1, "offset": 3},
	}

	for ri in range(len(raw_frames)):
		if not naming.has(ri):
			continue
		var n = naming[ri]
		var rf = raw_frames[ri]
		var rows = _find_rows(img, rf)
		var prefix = n["prefix"]
		var fpr = n["per_row"]
		var offset = n["offset"]

		print("\nRaw ", ri, " (", prefix, "): ", len(rows), " rows, ", fpr, " per row")
		for rii in range(len(rows)):
			var r = rows[rii]
			var dir_name = dir_names[rii]
			print("  Row ", rii, " (", dir_name, "): y=", r["y0"], "-", r["y1"], " h=", r["h"])

			var subs = _split_row(img, r, rf["x"], rf["x"] + rf["w"], fpr)
			for si in range(len(subs)):
				var s = subs[si]
				var frame_idx = offset + si
				var out = Image.create(s["w"], s["h"], false, Image.FORMAT_RGBA8)
				for y in range(s["h"]):
					for x in range(s["w"]):
						out.set_pixel(x, y, img.get_pixel(s["x"] + x, s["y"] + y))
				var filename = prefix + "_" + dir_name + "_" + str(frame_idx).pad_zeros(2) + ".png"
				out.save_png("res://assets/frames2/" + filename)
				print("    [", si, "] x=", s["x"], " y=", s["y"], " w=", s["w"], " h=", s["h"], " -> ", filename)

	print("\nDone!")
	quit(0)

func _find_rows(img, rf):
	var rows = []
	var in_row = false
	var ry0 = 0
	for y in range(rf["y"], rf["y"] + rf["h"]):
		var has = false
		for x in range(rf["x"], rf["x"] + min(rf["w"], img.get_width() - rf["x"])):
			if y < img.get_height() and x < img.get_width() and img.get_pixel(x, y).a > 0.1:
				has = true
				break
		if has and not in_row:
			in_row = true
			ry0 = y
		elif not has and in_row:
			in_row = false
			rows.append({"y0": ry0, "y1": y - 1, "h": y - ry0})
	if in_row:
		rows.append({"y0": ry0, "y1": rf["y"] + rf["h"] - 1, "h": rf["y"] + rf["h"] - ry0})
	return rows

func _split_row(img, row, rx0, rx1, count):
	var subs = []
	if count <= 1:
		var x0 = rx1
		var x1 = rx0
		for x in range(rx0, rx1):
			for y in range(row["y0"], row["y0"] + row["h"]):
				if y < img.get_height() and x < img.get_width() and img.get_pixel(x, y).a > 0.1:
					if x < x0: x0 = x
					if x > x1: x1 = x
					break
		if x1 >= x0:
			subs.append({"x": x0, "y": row["y0"], "w": x1 - x0 + 1, "h": row["h"]})
		return subs

	var total_w = rx1 - rx0
	var each = float(total_w) / float(count)
	for i in range(count):
		var fx0 = rx0 + int(i * each)
		var fx1 = rx0 + int((i + 1) * each)
		var x0 = fx1
		var x1 = fx0
		for x in range(fx0, fx1):
			for y in range(row["y0"], row["y0"] + row["h"]):
				if y < img.get_height() and x < img.get_width() and img.get_pixel(x, y).a > 0.1:
					if x < x0: x0 = x
					if x > x1: x1 = x
					break
		if x1 >= x0:
			subs.append({"x": x0, "y": row["y0"], "w": x1 - x0 + 1, "h": row["h"]})
	return subs
