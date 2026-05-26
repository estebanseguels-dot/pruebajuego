extends SceneTree

func _init():
	var img = Image.new()
	var err = img.load("res://sprites/asset2.png")
	if err != OK:
		print("ERROR: ", err)
		quit(1)
		return

	print("asset2.png: ", img.get_width(), "x", img.get_height())

	# Row-by-row content count
	print("\n=== Rows with pixel count ===")
	for y in range(0, img.get_height()):
		var count = 0
		for x in range(0, img.get_width()):
			if img.get_pixel(x, y).a > 0.1:
				count += 1
		print("  row ", y, ": ", count, " px")

	# Column by column content count (sample every 10 cols)
	print("\n=== Column pixel counts (every 5 cols) ===")
	for x in range(0, img.get_width(), 5):
		var count = 0
		for y in range(0, img.get_height()):
			if img.get_pixel(x, y).a > 0.1:
				count += 1
		if count > 0:
			print("  col ", x, ": ", count, " px")

	# Find empty columns
	print("\n=== Empty columns (0 px) ===")
	var empty_cols = []
	for x in range(0, img.get_width()):
		var count = 0
		for y in range(0, img.get_height()):
			if img.get_pixel(x, y).a > 0.1:
				count += 1
		if count == 0:
			empty_cols.append(x)
	print("  Found ", len(empty_cols), " empty columns")
	if len(empty_cols) > 0:
		for x in empty_cols:
			print("  col ", x, " is empty")

	# Find columns with DRASTIC changes in pixel count (>50% drop)
	print("\n=== Column transitions (big pixel count changes) ===")
	var prev_count = -1
	for x in range(0, img.get_width()):
		var count = 0
		for y in range(0, img.get_height()):
			if img.get_pixel(x, y).a > 0.1:
				count += 1
		if prev_count >= 0:
			var diff = abs(count - prev_count)
			if diff > 10:
				print("  col ", x, ": ", prev_count, " -> ", count, " (delta=", diff, ")")
		prev_count = count

	quit(0)
