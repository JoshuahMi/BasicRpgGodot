class_name BasicRpgGrapplingHookEdgeDetector extends Node3D

## A helper class for detecting valid points for the grappling hook to hang on to.

# TODO: Keeping the last known valid edge point AND validating it in the sense of checking if something is between the player and the point.
# TODO: Add more debug functionality
# TODO: Add "Abtasten" function in a reasonable way

@export var camera: Node3D

@export var debug: bool = true

@export var platform_detection_distance: float = 100.0

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
	
	# test_cast_forward()
	
	var detected_point: BasicRpgHitResult = test_detect_ledge()
	
	if detected_point.valid:
		#print("From Ledge Detector: detected point VALID!")
		detected_platform_point = detected_point.position
	else:
		pass
		#print("From Ledge Detector: detected point invalid!")
	
	
	#if detected_platform_point.valid:
	#
		#DebugShapes.place_the_red_sphere(detected_platform_point["position"])
	
#region MAIN FUNCTIONS

func test_detect_ledge() -> BasicRpgHitResult:
	
	# This point we will actually use in the 2nd part of the function.
	var base_point: BasicRpgHitResult
	
	# first, get the wall collision position. 
	var cast_0 : BasicRpgHitResult = RayCaster.cast_forward(self, camera, platform_detection_distance)
	
	# TODO: Get a better wall collision.
	
	if not cast_0.valid:
		
		# TODO: If nothing was hit, then cast a generic vertical row forward.
		var row: Array[BasicRpgHitResult] = RayCaster.cast_row(self, camera.global_position, camera.global_position + Vector3.UP * 5.0, Math.get_forward_vector_of_node(camera), 16, 100.0, true)
		
		#region Debug
		
		for result in row:
			
			if result.valid:
				DebugShapes.place_a_blue_sphere(result.position)
		
		#endregion Debug
		
		# Get the breakpoint from the row hit result
		
		var brkpnt: BasicRpgHitResult = get_breakpoint_from_row(row)[0]
		
		if not brkpnt.valid:
			return brkpnt
		
		else:
			DebugShapes.place_the_green_sphere(brkpnt.position)
		
		# BUG somehow this doesn't work as a base point.
		# To be more precise, this 
		
		
		
		base_point = brkpnt
		#print(base_point.normal)
		#print(base_point.position)
		
	if cast_0.normal.y < 0.0 and cast_0.valid:
		
		# If we look at a surface that is pointing downwards, definitely do the up row cast.
		pass
		
		var start_row_cast = cast_0.position
		var end_row_cast = Vector3(camera.global_position.x, cast_0.position.y, camera.global_position.z)
		var row_direction = Vector3.UP
		var row_number_of_rays = 7
		
		var up_row: Array[BasicRpgHitResult] = RayCaster.cast_row(self, start_row_cast, end_row_cast, row_direction, row_number_of_rays, 10.0, true)
		
		#region Debug
		
		#for result in up_row:
			#if result.valid:
				#
				#DebugShapes.place_a_green_sphere(result.position)
		
		
		
		#endregion Debug
		
		
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
		
			#region Debug
			
			#for result in up_row:
				#if result.valid:
					#
					#DebugShapes.place_a_green_sphere(result.position)
			
			
			
			#endregion Debug
		
		
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
		print("From Ledge Detector: Surface is pointing upwards")
		var out: BasicRpgHitResult = BasicRpgHitResult.new()
		out.valid = false
		
		return out

	
	# ------------------ 2nd part of the function. -------------------------------------------------------------------------------
	# Now that we found a good point that we can use, cast the actual vertical row to locate a ledge and further approximate it.
	# ----------------------------------------------------------------------------------------------------------------------------
	
	if base_point == null:
		print("From Ledge Detector: base point is null!")
		#print("From Ledge Detector: Base point is null!")
		var out: BasicRpgHitResult = BasicRpgHitResult.new()
		out.valid = false
		
		return out
	
	# Then cast a row on the wall
	
	var y_tolerance: float = 2.0
	
	
	# BUG The beginning and end points are invalid when the base point comes from a generic vertical row.
	print("From Ledge detector: 2nd Part of the function")
	#print(base_point.normal)
	print(base_point.position)
	var row_cast_0_begin: Vector3 = base_point.position + base_point.normal 
	var row_cast_0_end: Vector3 = row_cast_0_begin + Vector3.UP * y_tolerance
	var number_of_rays: int = 7
	
	var row_cast_0: Array[BasicRpgHitResult] = RayCaster.cast_row(self, row_cast_0_begin, row_cast_0_end, base_point.normal * -1.0, 7, 5.0, true)
	
	
	#region Debug
	
	# Okay, so when the base point is from a generic row because the player didn't look directly at a surface but into nothingness,
	# the vertical row doesn't hit anything.
	
	#DebugShapes.hide_all()
	
	DebugShapes.place_a_red_sphere(row_cast_0_begin)
	DebugShapes.place_a_red_sphere(row_cast_0_end)
	#print(row_cast_0_begin)
	#print(row_cast_0_end)
	
	
	if row_cast_0.size() == 0:
		print("From Ledge Detector: Row didn't happen.")
	
	var is_at_least_one_valid = false
	
	for result in row_cast_0:
		if result.valid:
			is_at_least_one_valid = true
	
	if is_at_least_one_valid:
		print("From Ledge Detector: One is valid!")
	
	
	#DebugShapes.hide_all()
	
	#for result in row_cast_0:
		#if result.valid:
			#DebugShapes.place_a_green_sphere(result.position)
	
	
	#endregion Debug
	
	
	
	
	# detect the breakpoint
	var y_interval = y_tolerance / number_of_rays
	var ledge: BasicRpgLedge = get_breakpoint_from_vertical_row(row_cast_0, y_interval)
	
	if ledge.valid:
		ledge = approximate_ledge_further(ledge, 8)
	
	ledge.validate()
	
	#if row_cast_0_breakpoint.valid:
		#
		#DebugShapes.place_the_blue_sphere(row_cast_0_breakpoint.under.position)
	
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
		
		var out: Array[BasicRpgHitResult]
		out = []
		
		return out
	
	for index in row.size():
		if not index == row.size() - 1:
			
			if row[index].valid:
				
				var is_this_hit_result_shorter_than_its_successor: bool 
				var length_difference: float
				if row[index + 1].valid:
					is_this_hit_result_shorter_than_its_successor = row[index].length < row[index + 1].length
					length_difference = abs(row[index].length - row[index + 1].length)
				else:
					is_this_hit_result_shorter_than_its_successor = true
					length_difference = 1.0
				
				if is_this_hit_result_shorter_than_its_successor and length_difference > 0.1:
					# THIS is the breakpoint
					hit_result_that_is_longer = row[index + 1]
					hit_result_before = row[index]
	
	
	return [hit_result_before, hit_result_that_is_longer]
	




func get_breakpoint_from_vertical_row(row: Array[BasicRpgHitResult], row_y_interval: float) -> BasicRpgLedge:
	
	
	var hit_result_that_is_longer: BasicRpgHitResult = BasicRpgHitResult.new()
	hit_result_that_is_longer.valid = false
	
	var Hit_result_before: BasicRpgHitResult = BasicRpgHitResult.new()
	Hit_result_before.valid = false
	
	# early return if the input row is invalid because it has only 1 or zero elements
	if row.size() <= 1:
		
		var out: BasicRpgLedge = BasicRpgLedge.new()
		out.valid = false
		
		return out
	
	for index in row.size():
		if not index == row.size() - 1:
			
			if row[index].valid:
				
				var is_this_hit_result_shorter_than_its_successor: bool 
				var length_difference: float
				if row[index + 1].valid:
					is_this_hit_result_shorter_than_its_successor = row[index].length < row[index + 1].length
					length_difference = abs(row[index].length - row[index + 1].length)
				else:
					is_this_hit_result_shorter_than_its_successor = true
					length_difference = 1.0
				
				if is_this_hit_result_shorter_than_its_successor and length_difference > 0.1:
					# THIS is the breakpoint
					hit_result_that_is_longer = row[index + 1]
					Hit_result_before = row[index]
	
	
	var out: BasicRpgLedge = BasicRpgLedge.new()
	
	out.under = Hit_result_before
	out.above = hit_result_that_is_longer
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


#func get_shortest_from_row_cast(row: Array[BasicRpgHitResult]) -> BasicRpgHitResult:
	#
	#var shortest: BasicRpgHitResult = BasicRpgHitResult.new()
	#shortest.valid = false
	#
	#shortest.length = 100.0
	#
	#
	#if row.size() < 1:
		#shortest.valid = false
		#return shortest
	#
	#elif row.size() == 1:
		#shortest = row[0]
		#return shortest
		#
	#for result in row:
	
	
	
	
	
	



#endregion HELPER FUNCTIONS
