extends SceneTree

func _init():
	var img = Image.new()
	img.load("res://sprites/asset2_clean.png")
	DirAccess.open("res://").make_dir_recursive("assets/frames2")

	var defs = [
		[2, 3, 17, 109, [0,37,74], [1,1,1], "idle", [0,0,0]],
		[43, 3, 52, 113, [0,37,74], [2,2,2], "walk", [0,0,0]],
		[100, 4, 18, 108, [0,36,72], [1,1,1], "walk", [3,3,3]],
		[123, 5, 23, 111, [0,37,74], [2,2,2], "walk", [4,4,4]],
		[147, 3, 52, 111, [0,37,74], [1,1,1], "run", [0,0,0]],
		[221, 5, 37, 110, [0,37,74], [3,3,3], "run", [1,1,1]],
		[259, 2, 83, 113, [0,37,74], [1,1,1], "hurt", [0,0,0]],
		[368, 5, 37, 110, [0,37,74], [1,1,1], "hurt", [1,1,1]],
		[410, 12, 42, 103, [0,34,68], [1,1,1], "hurt", [2,2,2]],
		[461, 12, 38, 104, [0,34,68], [1,1,1], "hurt", [3,3,3]],
		[512, 11, 29, 105, [0,35,70], [1,1,1], "extra", [0,0,0]],
	]

	var dirs = ["right", "up", "down"]

	for d in defs:
		var rx = d[0]
		var ry = d[1]
		var rw = d[2]
		var rh = d[3]
		var rows = d[4]
		var fpr = d[5]
		var prefix = d[6]
		var offsets = d[7]

		for ri in range(3):
			var row_ry = ry + rows[ri]
			var row_rh = rows[ri+1] - rows[ri] if ri < 2 else rh - rows[ri]
			var count = fpr[ri]
			var offset = offsets[ri]
			var dir_name = dirs[ri]

			var subs = _split_row(img, rx, rx + rw, row_ry, row_rh, count)

			for si in range(len(subs)):
				var s = subs[si]
				var frame_idx = offset + si
				var out = Image.create(s["w"], s["h"], false, Image.FORMAT_RGBA8)
				for y in range(s["h"]):
					for x in range(s["w"]):
						out.set_pixel(x, y, img.get_pixel(s["x"] + x, s["y"] + y))
				var filename = prefix + "_" + dir_name + "_" + str(frame_idx).pad_zeros(2) + ".png"
				out.save_png("res://assets/frames2/" + filename)
				print(filename, " x=", s["x"], " y=", s["y"], " w=", s["w"], " h=", s["h"])

	print("\nDone! Check assets/frames2/")
	quit(0)

func _split_row(img, rx0, rx1, ry, rh, count):
	var subs = []
	if count <= 1:
		var x0 = rx0
		var x1 = rx0
		for x in range(rx0, rx1):
			for y in range(ry, ry + rh):
				if y < img.get_height() and x < img.get_width():
					var px = img.get_pixel(x, y)
					if px.a > 0.1:
						if x0 == rx0 or x < x0: x0 = x
						if x > x1: x1 = x
						break
		if x1 >= x0:
			subs.append({"x": x0, "y": ry, "w": x1 - x0 + 1, "h": rh})
		return subs

	var total_w = rx1 - rx0
	var each = float(total_w) / float(count)
	for i in range(count):
		var fx0 = rx0 + int(floor(i * each))
		var fx1 = rx0 + int(floor((i + 1) * each))
		var x0 = fx1
		var x1 = fx0
		for x in range(fx0, fx1):
			for y in range(ry, ry + rh):
				if y < img.get_height() and x < img.get_width():
					var px = img.get_pixel(x, y)
					if px.a > 0.1:
						if x < x0: x0 = x
						if x > x1: x1 = x
						break
		if x1 >= x0:
			subs.append({"x": x0, "y": ry, "w": x1 - x0 + 1, "h": rh})
	return subs
