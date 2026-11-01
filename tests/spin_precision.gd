extends SceneTree
var failed := 0
var checks := 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failed += 1
		printerr("FAIL: "+message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var pad := SpinPad.new()
	root.add_child(pad)
	pad.size = Vector2(112,112)
	pad.spin = Vector2(.2,.1)
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.shift_pressed = true
	press.position = Vector2.ZERO
	pad._gui_input(press)
	check(pad.spin.is_equal_approx(Vector2(.2,.1)), "Shift press retains selected tip instead of jumping to pointer")
	var motion := InputEventMouseMotion.new()
	motion.button_mask = MOUSE_BUTTON_MASK_LEFT
	motion.shift_pressed = true
	motion.relative = Vector2(10,0)
	motion.position = Vector2(100,56)
	var before := pad.spin
	pad._gui_input(motion)
	var fine_delta := pad.spin.distance_to(before)
	check(fine_delta > 0.0 and fine_delta < .05, "fine drag can select a small sub-tenth-radius adjustment")
	pad.spin = Vector2.ZERO
	motion.shift_pressed = false
	motion.position = Vector2(66,56)
	pad._gui_input(motion)
	check(pad.spin.length() > fine_delta*4.0, "ordinary pointer mapping retains its full adjustment range")
	motion.shift_pressed = true
	motion.relative = Vector2(10000,10000)
	pad._gui_input(motion)
	check(pad.spin.length() <= .500001, "fine drag respects physical tip-offset bound")
	press.shift_pressed = false
	press.double_click = true
	pad._gui_input(press)
	check(pad.spin == Vector2.ZERO, "double-click precisely centers tip")
	pad.queue_free()
	await process_frame
	print("SPIN PRECISION: %d checks, %d failures" % [checks,failed])
	quit(1 if failed else 0)
