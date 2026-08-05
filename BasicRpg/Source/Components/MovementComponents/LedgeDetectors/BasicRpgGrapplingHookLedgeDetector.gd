class_name BasicRpgGrapplingHookEdgeDetector extends Node3D

## A helper class for detecting valid points for the grappling hook to hang on to.

# TODO: Keeping the last known valid edge point AND validating it in the sense of checking if something is between the player and the point.

@export var camera: Node3D

@export var debug: bool = false

@export var platform_detection_distance: float = 100.0
@export var vertical_row_y_tolerance: float = 2.0
@export var vertical_row_number_of_rays: int = 7
@export var approximation_row_resolution: int = 5
@export var approximate: bool = true

## This is the point that is detected by this detector. The most important variable,
## since the edge detector exists to detect this point.
var detected_platform_point: Vector3 = Vector3.ZERO:
	set(new_value):
		detected_platform_point = new_value
		if debug:
			DebugShapes.place_the_red_sphere(new_value)


func _ready() -> void:
	pass


func _physics_process(_delta: float) -> void:
	
	DebugShapes.hide_all()
	
	# test_cast_forward()
	
	var detected_point: BasicRpgHitResult = detect_ledge_0()
	
	# BUG This causes problems.
	#detected_point.valid = validate_point_as_from_player(detected_point.position)
	
	if detected_point.valid:
		
		detected_platform_point = detected_point.position

		
	
#region MAIN FUNCTIONS

func detect_ledge_0() -> BasicRpgHitResult:
	
	var base_point: BasicRpgHitResult = get_base_point() 
	
	#region Debug
	
	if debug and base_point.valid:
		DebugShapes.place_the_green_sphere(base_point.position + Vector3.UP * 0.1)
	
	#endregion Debug
	
	var ledge: BasicRpgLedge = get_ledge_from_base_point(base_point)
	
	if ledge.valid:
		return ledge.under
	else:
		
		var out: BasicRpgHitResult = BasicRpgHitResult.new()
		out.valid = false
		
		return out

func test_detect_ledge() -> BasicRpgHitResult:
	
	# This point we will actually use in the 2nd part of the function.
	var base_point: BasicRpgHitResult
	
	# first, get the wall collision position. 
	var cast_0 : BasicRpgHitResult = RayCaster.cast_forward(self, camera, platform_detection_distance)
	
	# Now Get a better base point.
	
	if not cast_0.valid:
		
		# If nothing was hit, then cast a generic vertical row forward.
		var row: Array[BasicRpgHitResult] = RayCaster.cast_row(self, camera.global_position, camera.global_position + Vector3.UP * 5.0, Math.get_forward_vector_of_node(camera), 16, 100.0, true)
		
		
		# Get the breakpoint from the row hit result
		
		var brkpnt: BasicRpgHitResult = get_breakpoint_from_row(row)[0]
		
		if not brkpnt.valid:
			return brkpnt
		
		
		base_point = brkpnt
		
	if cast_0.normal.y < 0.0 and cast_0.valid:
		
		# If we look at a surface that is pointing downwards, definitely do the up row cast.
		pass
		
		var start_row_cast = cast_0.position
		var end_row_cast = Vector3(camera.global_position.x, cast_0.position.y, camera.global_position.z)
		var row_direction = Vector3.UP
		var row_number_of_rays = 7
		
		var up_row: Array[BasicRpgHitResult] = RayCaster.cast_row(self, start_row_cast, end_row_cast, row_direction, row_number_of_rays, 10.0, true)
		
		
		# Now check the breakpoint
		
		var brkpnt: Array[BasicRpgHitResult] = get_breakpoint_from_row(up_row)
		
		# Then make an artificial hit result with the normal pointing towards the player
		base_point = BasicRpgHitResult.new()
		base_point.position = brkpnt[0].position
		
		var normal = brkpnt[0].position.direction_to(camera.global_position)
		normal = Vector3(normal.x, 0.0, normal.z).normalized()
		
		base_point.normal = normal
	
	# If the normal is horizontal, simply take the *cast 0* as base point
	# make a single up cast, to check if there is a roof.
	# 	IF so, cast an up row cast.
	# 	if NOT, take the *cast 0* as base point
	
	elif Math.equal_float(cast_0.normal.y, 0.0, 0.01) and cast_0.valid:
		
		
		
		var roof: BasicRpgHitResult = RayCaster.cast_ray_up(self, cast_0.position + cast_0.normal, 100.0, false)
		
		
		if roof.valid:
			# then do an up row ray cast
			# TODO: REFACTOR THIS into a function.
			var start_row_cast = cast_0.position
			var end_row_cast = Vector3(camera.global_position.x, cast_0.position.y, camera.global_position.z)
			var row_direction = Vector3.UP
			var row_number_of_rays = 7
		
			var up_row: Array[BasicRpgHitResult] = RayCaster.cast_row(self, start_row_cast, end_row_cast, row_direction, row_number_of_rays, 10.0, true)
		
		
		
			# Now check the breakpoint
			
			var brkpnt: Array[BasicRpgHitResult] = get_breakpoint_from_row(up_row)
			
			# Then make an artificial hit result with the normal pointing towards the player
			base_point = BasicRpgHitResult.new()
			base_point.position = brkpnt[0].position
			
			var normal = brkpnt[0].position.direction_to(camera.global_position)
			normal = Vector3(normal.x, 0.0, normal.z).normalized()
			
			base_point.normal = normal
			
			pass
		else:
			base_point = cast_0
	
	# If the normal is pointing upwards.
	elif cast_0.normal.y > 0.0 and cast_0.valid:
		
		
		# if it's a surface that is pointing upwards, simply return an invalid hit result
	
		var out: BasicRpgHitResult = BasicRpgHitResult.new()
		out.valid = false
		
		return out

	
	# ------------------ 2nd part of the function. -------------------------------------------------------------------------------
	# Now that we found a good point that we can use, cast the actual vertical row to locate a ledge and further approximate it.
	# ----------------------------------------------------------------------------------------------------------------------------
	
	if base_point == null:
		
		
		var out: BasicRpgHitResult = BasicRpgHitResult.new()
		out.valid = false
		
		return out
	
	# Then cast a row on the wall
	
	var y_tolerance: float = 2.0
	
	
	
	
	var row_cast_0_begin: Vector3 = base_point.position + base_point.normal 
	var row_cast_0_end: Vector3 = row_cast_0_begin + Vector3.UP * y_tolerance
	var number_of_rays: int = 7
	
	var row_cast_0: Array[BasicRpgHitResult] = RayCaster.cast_row(self, row_cast_0_begin, row_cast_0_end, base_point.normal * -1.0, 7, 5.0, true)

	
	
	
	
	# detect the breakpoint
	var y_interval = y_tolerance / number_of_rays
	var ledge: BasicRpgLedge = get_breakpoint_from_vertical_row(row_cast_0, y_interval)
	
	if ledge.valid:
		ledge = approximate_ledge_further(ledge, 8)
	
	ledge.validate()
	
	
	if ledge.valid:
		return ledge.under
	else:
		
		var out: BasicRpgHitResult = BasicRpgHitResult.new()
		out.valid = false
		return out

#endregion MAIN FUNCTIONS
	
#region HELPER FUNCTIONS

## General purpose function. Returns the breakpoint of a row cast, the latest place where a hit result is significantly shorter than its successor
func get_breakpoint_from_row(row: Array[BasicRpgHitResult]) -> Array[BasicRpgHitResult]:
	
	var hit_result_that_is_longer: BasicRpgHitResult = BasicRpgHitResult.new()
	hit_result_that_is_longer.valid = false
	
	var hit_result_before: BasicRpgHitResult = BasicRpgHitResult.new()
	hit_result_before.valid = false
	
	if row.size() <= 1:
		#print("From Edge Detector breakpoint function: Row doesn't have any members!")
		var out: Array[BasicRpgHitResult]
		out = []
		
		return out
	
	for index in row.size():
		if not index == row.size() - 1:
			
			if row[index].valid:
			
				var length_difference: float
				
				if row[index + 1].valid:
					pass
				length_difference = (row[index].length - row[index + 1].length) 
				#else:
					#
					#length_difference = -100.0
				
				if length_difference < 0.0:
					#print("From Ledge Detector Breakpoint Function: BREAKPOINT!")
					# THIS is the breakpoint
					hit_result_that_is_longer = row[index + 1]
					hit_result_before = row[index]
				
	
	#if not hit_result_before.valid:
		#print("From Ledge Detector Breakpoint Function: no breakpoint...")
	
	return [hit_result_before, hit_result_that_is_longer]
	




func get_breakpoint_from_vertical_row(row: Array[BasicRpgHitResult], row_y_interval: float) -> BasicRpgLedge:
	
	var out: BasicRpgLedge = BasicRpgLedge.new()
	
	
	# early return if the input row is invalid because it has only 1 or zero elements
	if row.size() <= 1:
		
		out = BasicRpgLedge.new()
		out.valid = false
		
		return out
	
	var two_results_that_display_breakpoint: Array[BasicRpgHitResult] = get_breakpoint_from_row(row)
	
	out.under = two_results_that_display_breakpoint[0]
	out.above = two_results_that_display_breakpoint[1]
	out.y_tolerance = row_y_interval
	
	if out.under:
		out.valid = true
	else:
		out.valid = false
	
	return out

func approximate_ledge_further(ledge: BasicRpgLedge, number_of_rays: int) -> BasicRpgLedge:
	
	var start_of_row = ledge.under.position + ledge.under.normal
	
	var end_of_row = start_of_row + Vector3.UP * ledge.y_tolerance 
	
	var row: Array[BasicRpgHitResult] = RayCaster.cast_row(self, start_of_row, end_of_row, ledge.under.normal * -1.0, number_of_rays, 5.0, true)
	
	return get_breakpoint_from_vertical_row(row, ledge.y_tolerance / number_of_rays)

	
	
func get_base_point() -> BasicRpgHitResult:
	
	# This point we will return
	var base_point: BasicRpgHitResult
	
	# first, get the wall collision position. 
	var cast_0 : BasicRpgHitResult = RayCaster.cast_forward(self, camera, platform_detection_distance)
	
	#region Debug
	
	if debug and cast_0.valid:
		DebugShapes.place_the_blue_sphere(cast_0.position)
	
	#endregion Debug
	# Now Get a better base point.
	
	# If the cast went into nothingness, i.e. nothing was hit, then cast a vertical row forward instead
	if not cast_0.valid:
		
		# If nothing was hit, then cast a generic vertical row forward.
		var row: Array[BasicRpgHitResult] = RayCaster.cast_row(self, camera.global_position, camera.global_position + Vector3.UP * 5.0, Math.get_forward_vector_of_node(camera), 16, 100.0, true)
		
		# Get the breakpoint from the row hit result
		
		var brkpnt: BasicRpgHitResult = get_breakpoint_from_row(row)[0]
		
		if not brkpnt.valid:
			return brkpnt
		
		
		
		base_point = brkpnt
		return base_point
	
	# If we look at a surface that is pointing downwards, do the up row cast.
	if cast_0.normal.y < 0.0 and cast_0.valid:
		
		var start_row_cast = cast_0.position
		var end_row_cast = Vector3(camera.global_position.x, cast_0.position.y, camera.global_position.z)
		var row_direction = Vector3.UP
		var row_number_of_rays = 7
		
		var up_row: Array[BasicRpgHitResult] = RayCaster.cast_row(self, start_row_cast, end_row_cast, row_direction, row_number_of_rays, 10.0, true)
		
		
		#region Debug
		
		if debug:
			for result in up_row:
				if result.valid:
					DebugShapes.place_a_green_sphere(result.position)
		
		
		
		#endregion Debug
		
		# Now check the breakpoint
		
		var brkpnt: Array[BasicRpgHitResult] = get_breakpoint_from_row(up_row)
		
		# Then make an artificial hit result with the normal pointing towards the player
		base_point = BasicRpgHitResult.new()
		base_point.position = brkpnt[0].position
		
		var normal = brkpnt[0].position.direction_to(camera.global_position)
		normal = Vector3(normal.x, 0.0, normal.z).normalized()
		
		base_point.normal = normal
		
		return base_point
	
	# If the normal is horizontal, 
	# make a single up cast, to check if there is a roof.
	# 	IF so, cast an up row cast.
	# 	if NOT, take the *cast 0* as base point
	
	elif Math.equal_float(cast_0.normal.y, 0.0, 0.01) and cast_0.valid:
		
		var roof: BasicRpgHitResult = RayCaster.cast_ray_up(self, cast_0.position + cast_0.normal, 100.0, false)
		
		if roof.valid:
			# then do an up row ray cast
			# TODO: REFACTOR THIS into a function.
			var start_row_cast = cast_0.position
			var end_row_cast = Vector3(camera.global_position.x, cast_0.position.y, camera.global_position.z)
			var row_direction = Vector3.UP
			var row_number_of_rays = 7
		
			var up_row: Array[BasicRpgHitResult] = RayCaster.cast_row(self, start_row_cast, end_row_cast, row_direction, row_number_of_rays, 10.0, true)
		
			# Now check the breakpoint
			
			var brkpnt: Array[BasicRpgHitResult] = get_breakpoint_from_row(up_row)
			
			# Then make an artificial hit result with the normal pointing towards the player
			base_point = BasicRpgHitResult.new()
			base_point.position = brkpnt[0].position
			
			var normal = brkpnt[0].position.direction_to(camera.global_position)
			normal = Vector3(normal.x, 0.0, normal.z).normalized()
			
			base_point.normal = normal
			
			return base_point
			
			pass
		else:
			base_point = cast_0
			return base_point
	
	# If the normal is pointing upwards.
	elif cast_0.normal.y > 0.0 and cast_0.valid:
		
		# if it's a surface that is pointing upwards, simply return an invalid hit result
		var out: BasicRpgHitResult = BasicRpgHitResult.new()
		out.valid = false
		
		return out

	
	
	var out: BasicRpgHitResult = BasicRpgHitResult.new()
	out.valid = false
	
	return out
	
	

func get_ledge_from_base_point(base_point: BasicRpgHitResult) -> BasicRpgLedge:
	
	if base_point == null or not base_point.valid:
		var out: BasicRpgLedge = BasicRpgLedge.new()
		out.valid = false
		
		return out
	
	# Then cast a row on the wall
	
	#var y_tolerance: float = 2.0
	
	var row_cast_0_begin: Vector3 = base_point.position + base_point.normal 
	var row_cast_0_end: Vector3 = row_cast_0_begin + Vector3.UP * vertical_row_y_tolerance
	# var number_of_rays: int = 7
	
	
	
	
	
	var row_cast_0: Array[BasicRpgHitResult] = RayCaster.cast_row(self, row_cast_0_begin, row_cast_0_end, base_point.normal * -1.0, vertical_row_number_of_rays, 5.0, true)
	
	#region Debug
	
	DebugShapes.place_a_red_sphere(row_cast_0_begin)
	DebugShapes.place_a_red_sphere(row_cast_0_end)
	
	if debug:
		for result in row_cast_0:
			
			if result.valid:
				DebugShapes.place_a_blue_sphere(result.position)
	
	#endregion Debug
	
	
	# detect the breakpoint
	var y_interval = vertical_row_y_tolerance / vertical_row_number_of_rays
	var ledge: BasicRpgLedge = get_breakpoint_from_vertical_row(row_cast_0, y_interval)
	
		
		
	
	if approximate:
		if ledge.valid:
			ledge = approximate_ledge_further(ledge, approximation_row_resolution)
	
	#region Debug
	
	if debug and ledge.valid:
		DebugShapes.place_the_green_sphere(ledge.under.position)
		
	#endregion Debug
	#ledge.validate()
	
	
	
	
	
	return ledge


## This function is purely to check if something is between the player and the point.
## Returns true if nothing is between the player and the point.
func validate_point_as_from_player(point: Vector3) -> bool:
	
	var actual_distance = (camera.global_position - point).length()
	
	var cast = RayCaster.cast_ray(self, camera.global_position, point, false)
	
	if not cast.valid:
		return true
		
	if cast.length < actual_distance + 0.1:
		return false
	
	else:
		return true
	
	
	
	
	
	
	return false
	
	
	
	
	
	
	
	pass

#endregion HELPER FUNCTIONS
