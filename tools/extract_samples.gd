extends SceneTree

func _init():
	var src = Image.new()
	src.load("res://sprites/asset.png")

	# Extract first frame of every region that looks like a character sprite
	var samples = {
		"reg00_2-35": {"x": 0, "y": 2, "w": 543, "h": 34},
		"reg01_39-74": {"x": 3, "y": 41, "w": 16, "h": 32},
		"reg02_80-115_first": {"x": 0, "y": 80, "w": 543, "h": 36},
		"reg03_151-184_first": {"x": 96, "y": 156, "w": 19, "h": 28},
		"reg03_151-184_second": {"x": 136, "y": 151, "w": 24, "h": 33},
		"reg04_209-247_first": {"x": 99, "y": 211, "w": 22, "h": 29},
		"reg06_269-300_first": {"x": 43, "y": 273, "w": 17, "h": 27},
		"reg08_320-354_first": {"x": 44, "y": 326, "w": 16, "h": 28},
		"reg10_418-459_first": {"x": 151, "y": 425, "w": 19, "h": 32},
		"reg11_464-498_first": {"x": 137, "y": 464, "w": 29, "h": 34},
		"reg12_510-545_first": {"x": 78, "y": 510, "w": 31, "h": 35},
		"reg13_578-609_first": {"x": 89, "y": 578, "w": 29, "h": 29},
		"reg14_613-647_first": {"x": 65, "y": 615, "w": 20, "h": 31},
	}

	var dir = "res://tools/samples/"
	DirAccess.open("res://tools/").make_dir_recursive("samples")

	for name in samples:
		var r = samples[name]
		var img = Image.create(r["w"], r["h"], false, Image.FORMAT_RGBA8)
		for y in range(r["h"]):
			for x in range(r["w"]):
				var sx = clampi(r["x"] + x, 0, src.get_width() - 1)
				var sy = clampi(r["y"] + y, 0, src.get_height() - 1)
				img.set_pixel(x, y, src.get_pixel(sx, sy))
		var path = dir + name + ".png"
		img.save_png(path)
		print("Saved: ", path)

	print("\nDone! Check tools/samples/ folder.")
	quit(0)
