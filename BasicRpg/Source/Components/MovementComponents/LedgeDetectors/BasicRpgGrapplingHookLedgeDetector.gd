class_name BasicRpgGrapplingHookEdgeDetector extends Node3D

## A helper class for detecting valid points for the grappling hook to hang on to.

@export var camera: Node3D

## DEBUG:
## Two little red spheres: The beginning and end of the vertical row cast
## Blue spheres: The hit results of the vertical row cast.
## Purple sphere: Base point for the vertical row to be cast to. 
## Purple little spheres: Hit results of approximation function. Also used for the vertical row in specific situations
## Green spheres: Up row cast to determine how far towards the player the platform goes
@export var debug: bool = false

## How long the initial ray cast from the camera will be.
@export var platform_detection_distance: float = 100.0

## How high the vertical row cast will be that will detect the ledge.
@export var vertical_row_y_tolerance: float = 3.0

## The resolution of the vertical row cast that will detect the ledge.
@export var vertical_row_number_of_rays: int = 16

## If it shall approximate a detected ledge point further. Leave it at *true* to achieve maximum precision 
## And set *approximation row resolution* to a sufficient amount
@export var approximate: bool = true

## The resolution of the approximation row of ray casts, i.e. how many rays it will cast in the y position interval the ledge that is to be approximated will be.
@export var approximation_row_resolution: int = 5

## This is the point that is detected by this detector. The most important variable,
## since the edge detector exists to detect this point.
var detected_platform_point: Vector3 = Vector3.ZERO:
	set(new_value):
		detected_platform_point = new_value
		
		# In the moment it gets detected, it's valid
		is_detected_point_valid = true
		
		if debug:
			DebugShapes.place_the_red_sphere(new_value)

var is_detected_point_valid = false

func _ready() -> void:
	pass


func _physics_process(_delta: float) -> void:
	
	DebugShapes.hide_all()
	
	#var detected_point: BasicRpgHitResult = detect_ledge()
	var detected_point: BasicRpgHitResult = detect_ledge()
	
	if detected_point.valid:
		
		detected_platform_point = detected_point.position
		
	else:
		
		is_detected_point_valid = validate_point(detected_platform_point)
		
	
	
#region MAIN FUNCTIONS

## THE STANDARD
func detect_ledge() -> BasicRpgHitResult:
	
	if debug:
		DebugShapes.hide_all()
	
	
	var base_point: BasicRpgHitResult = get_base_point_refactored() 
	
	
	
	#region Debug
	
	if debug and base_point.valid:
		DebugShapes.place_the_purple_sphere(base_point.position)
		
	#endregion Debug
	
	var ledge: BasicRpgLedge = get_ledge_from_base_point_refactored(base_point)
	
	if ledge.valid:
		
		if validate_point(ledge.under.position):
		
			return ledge.under
			
		else:
			
			var out: BasicRpgHitResult = BasicRpgHitResult.new()
			out.valid = false
			return out
			
	else:
		
		var out: BasicRpgHitResult = BasicRpgHitResult.new()
		out.valid = false
		return out

func detect_ledge_experimental() -> BasicRpgHitResult:
	
	# if the 
	
	
	
	
	
	
	var row_forward : Array[BasicRpgHitResult] = cast_row_forward()
	
	var ledge = make_ledge(row_forward)
	
	ledge = approximate_ledge_further(ledge, 20)
	
	return ledge.under
	
	#ledge.determine_validity()
	var out: BasicRpgLedge
	out = approximate_ledge_further_experimental(ledge, 20)
	return out.under
	
	
	
	if ledge.validity == BasicRpgLedge.Validity.VALID:
		out = approximate_ledge_further(ledge, 20)
		return out.under
	else:
		return make_invalid_hit_result()
	
	
	if out != null:
		
		#print("From Ledge Detector: out is not null!")
		
		#DebugShapes.place_the_purple_sphere(out.position)
		
		return out.under
		
	else:
		#print("From Ledge Detector: out is null!")
		return make_invalid_hit_result()
	


#endregion MAIN FUNCTIONS


#region experimental functions

func make_invalid_ledge() -> BasicRpgLedge:
	var out: BasicRpgLedge = BasicRpgLedge.new()
	out.valid = false
	return out

func approximate_ledge_further_experimental(ledge: BasicRpgLedge, number_of_rays: int) -> BasicRpgLedge:
	
	if not ledge.valid:
		return ledge
		
		
	var normal = Vector3(ledge.under.normal.x, 0.0, ledge.under.normal.z).normalized()
	
	var start_of_row = ledge.under.position + normal + Vector3.DOWN * 0.1
	
	var end_of_row = start_of_row + Vector3.UP * ledge.y_tolerance  + 0.1
	
	var row: Array[BasicRpgHitResult] = RayCaster.cast_row(self, start_of_row, end_of_row, ledge.under.normal * -1.0, number_of_rays, 5.0, true)
	
	if debug:
		for result in row:
			
			if result.valid:
				DebugShapes.place_a_purple_sphere(result.position)
	
	return get_breakpoint_from_vertical_row(row, ledge.y_tolerance / number_of_rays)

func make_invalid_hit_result() -> BasicRpgHitResult:
	
	var out: BasicRpgHitResult = BasicRpgHitResult.new()
	out.valid = false
	out.length = 100.0
	
	return out

func make_ledge(breakpnt: Array[BasicRpgHitResult]) -> BasicRpgLedge:
	
	var out: BasicRpgLedge = BasicRpgLedge.new()
	
	out.under = breakpnt[0]
	out.above = breakpnt[1]
	
	if out.above.valid:
		out.y_tolerance = abs(out.under.position.y - out.above.position.y)
	else:
		out.y_tolerance = 1.0
	
	out.valid = true
	return out
	
	

func cast_row_forward() -> Array[BasicRpgHitResult] :
	
	var forward_row_cast: Array[BasicRpgHitResult] = RayCaster.cast_row(self, camera.global_position, camera.global_position + Vector3.UP * 2.0, Math.get_forward_vector_of_node(camera), vertical_row_number_of_rays, platform_detection_distance, true)
		
	var breakpnt: Array[BasicRpgHitResult] = get_breakpoint_from_row(forward_row_cast)
	
	return breakpnt

func cast_forward() -> BasicRpgHitResult:
	
	# first, get the wall collision position. 
	return RayCaster.cast_forward(self, camera, platform_detection_distance)


## Will cast a vertical row onto the surface and returns the results.
func scan_surface(cast: BasicRpgHitResult, y_tolerance: float) -> BasicRpgVerticalRowScanResult:
	
	#var base_point: BasicRpgHitResult
	
	var row_cast_begin: Vector3 = cast.position + cast.normal 
	var row_cast_end: Vector3 = row_cast_begin + Vector3.UP * vertical_row_y_tolerance
	
	var row_cast: Array[BasicRpgHitResult] = RayCaster.cast_row(self, row_cast_begin, row_cast_end, cast.normal * -1.0, vertical_row_number_of_rays, 5.0, true)
	
	#base_point = get_breakpoint_from_row(row_cast_0)[0]
	
	var out: BasicRpgVerticalRowScanResult = BasicRpgVerticalRowScanResult.new()
	
	out.results = row_cast
	
	out.is_flat_surface = is_flat_surface(row_cast)
	out.is_completely_invalid = is_none_valid(row_cast)
	
	out.breakpoint_as_ledge = make_ledge(get_breakpoint_from_row(row_cast))
	
	return out

## Will cast a horizontal row upwards and returns the breakpoint.
func scan_upwards(begin: BasicRpgHitResult, end: Vector3) -> BasicRpgHitResult:
	
	var base_point: BasicRpgHitResult
	
	# If we look at a surface that is pointing downwards, do the up row cast.
	if begin.normal.y < 0.0 and begin.valid:
		
		var start_row_cast = begin.position
		var end_row_cast = Vector3(camera.global_position.x, begin.position.y, camera.global_position.z)
		var row_direction = Vector3.UP
		var row_number_of_rays = 16
		
		var up_row: Array[BasicRpgHitResult] = RayCaster.cast_row(self, start_row_cast, end_row_cast, row_direction, row_number_of_rays, 10.0, true)
		
		# Now check the breakpoint
		
		var brkpnt: Array[BasicRpgHitResult] = get_breakpoint_from_row(up_row)
		

		# Then make an artificial hit result with the normal pointing towards the player
		base_point = BasicRpgHitResult.new()
		base_point.position = brkpnt[0].position
		
		var normal = brkpnt[0].position.direction_to(camera.global_position)
		normal = Vector3(normal.x, 0.0, normal.z).normalized()
		
		base_point.normal = normal
		base_point.valid = true
		
		#region Debug
		
		if debug:
			for result in up_row:
				if result.valid:
					DebugShapes.place_a_green_sphere(result.position)
		
			if base_point.valid:
				DebugShapes.place_the_green_sphere(base_point.position)
		
		#endregion Debug
		
		return base_point
	
	else:
		
		return make_invalid_hit_result()




#endregion experimental functions

#region REFACTOR


func get_base_point_refactored() -> BasicRpgHitResult:
	
	
	var forward_row_cast: Array[BasicRpgHitResult] = RayCaster.cast_row(self, camera.global_position, camera.global_position + Vector3.UP * 2.0, Math.get_forward_vector_of_node(camera), vertical_row_number_of_rays, platform_detection_distance, true)
		
	for result in forward_row_cast:
		if result.valid:
			DebugShapes.place_a_blue_sphere(result.position)
		
		
		
	var base_point_0: BasicRpgHitResult = get_breakpoint_from_row(forward_row_cast)[0]
	
	var base_point_1: BasicRpgHitResult = get_base_point()
	
	if base_point_0.valid:
		return base_point_0
	else:
		return base_point_1
	

	
func get_ledge_from_base_point_refactored(base_point: BasicRpgHitResult) -> BasicRpgLedge:
	
	if base_point == null or not base_point.valid:
		
		return make_invalid_ledge()
	
	# Then cast a row on the wall
	
	var surface_scan: BasicRpgVerticalRowScanResult = scan_surface(base_point, vertical_row_y_tolerance)
	
	# If it's a flat surface, do a big vertical row raycast.
	
	if surface_scan.is_flat_surface:
		for i in 8:
			surface_scan = scan_surface(surface_scan.results[surface_scan.results.size() - 1], vertical_row_y_tolerance * i)
			if not surface_scan.is_flat_surface:
				break
	
	# detect the breakpoint
	var ledge: BasicRpgLedge = surface_scan.breakpoint_as_ledge
	
	if ledge.under.valid:
		DebugShapes.place_the_purple_sphere(ledge.under.position)
	
	
	if approximate:
		if ledge.valid:
			ledge = approximate_ledge_further(ledge, approximation_row_resolution * 3)
	
	#region Debug
	
	if debug:
		#DebugShapes.place_a_red_sphere(row_cast_0_begin)
		#DebugShapes.place_a_red_sphere(row_cast_0_end)
		for result in surface_scan.results:
			
			if result.valid:
				DebugShapes.place_a_blue_sphere(result.position)
	if debug and ledge.valid:
		DebugShapes.place_the_green_sphere(ledge.under.position)
		
	#endregion Debug

	return ledge




#endregion REFACTOR

#region HELPER FUNCTIONS

## THE STANDARD
func get_base_point_0() -> BasicRpgHitResult:
	
	var forward_row_cast: Array[BasicRpgHitResult] = RayCaster.cast_row(self, camera.global_position, camera.global_position + Vector3.UP * 2.0, Math.get_forward_vector_of_node(camera), vertical_row_number_of_rays, platform_detection_distance, true)
		
	var breakpnt: BasicRpgHitResult = get_breakpoint_from_row(forward_row_cast)[0]
	
	if breakpnt.valid:
		
		#region Debug
		
		# TODO: This breakpoint is already a good ledge. IN SOME INSTANCES. Approximate it further to get it.
		
		#breakpnt.position = Vector3(breakpnt.position.x, breakpnt.position.y - 0.2, breakpnt.position.z)
		#print(breakpnt.normal)

			
		if Math.equal_float(breakpnt.normal.y, 0.0, 0.01):
			
			#DebugShapes.place_the_purple_sphere(breakpnt.position)
			pass
		
		if debug:
			DebugShapes.place_the_green_sphere(breakpnt.position)
			
			for result in forward_row_cast:
				if result.valid:
					DebugShapes.place_a_blue_sphere(result.position)
		
		#endregion Debug
		
		
		return breakpnt
		
	else:
		# If there's no breakpoint, then we are either looking at a flat surface or into nothingness.
		# TODO: Determine, which situation we're in.
		
		# But for now, simply use the OTHER function if we don't get a good base point with this one.
		# Sooo here we go:
		
		return get_base_point()
		


## Returns true if none of the hit results in the given row cast result is valid
func is_none_valid(row_cast: Array[BasicRpgHitResult]) -> bool:
	
	var out: bool = true
	
	for result in row_cast:
		if result.valid:
			out = false

	return out

## Returns true if all the hit results have the same x- and z-coordinate
func is_flat_surface(row_cast: Array[BasicRpgHitResult]) -> bool:
	
	var flat: bool = true
	
	for index in row_cast.size():
		
		if not index == row_cast.size() - 1:
			if row_cast[index].valid and row_cast[index + 1].valid:
				var position_x_equal = Math.equal_float(row_cast[index].position.x, row_cast[index + 1].position.x, 0.01)
				var position_z_equal = Math.equal_float(row_cast[index].position.z, row_cast[index + 1].position.z, 0.01)
				
				if not (position_x_equal and position_z_equal):
					flat = false
			else:
				flat = false
	return flat
	
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
		var row: Array[BasicRpgHitResult] = RayCaster.cast_row(self, camera.global_position, camera.global_position + Vector3.UP * 5.0, Math.get_forward_vector_of_node(camera), vertical_row_number_of_rays * 2, platform_detection_distance, true)
		
		# Get the breakpoint from the row hit result
		
		#region Debug
		
		if debug:
			for result in row:
				if result.valid:
					DebugShapes.place_a_blue_sphere(result.position)
		
		#endregion Debug		
		
		
		var brkpnt: BasicRpgHitResult = get_breakpoint_from_row(row)[0]
		
		base_point = brkpnt
		return base_point
	
	# If we look at a surface that is pointing downwards, do the up row cast.
	if cast_0.normal.y < 0.0 and cast_0.valid:
		
		var start_row_cast = cast_0.position
		var end_row_cast = Vector3(camera.global_position.x, cast_0.position.y, camera.global_position.z)
		var row_direction = Vector3.UP
		var row_number_of_rays = 16
		
		var up_row: Array[BasicRpgHitResult] = RayCaster.cast_row(self, start_row_cast, end_row_cast, row_direction, row_number_of_rays, 10.0, true)
		
		# Now check the breakpoint
		
		var brkpnt: Array[BasicRpgHitResult] = get_breakpoint_from_row(up_row)
		

		# Then make an artificial hit result with the normal pointing towards the player
		base_point = BasicRpgHitResult.new()
		base_point.position = brkpnt[0].position
		
		var normal = brkpnt[0].position.direction_to(camera.global_position)
		normal = Vector3(normal.x, 0.0, normal.z).normalized()
		
		base_point.normal = normal
		base_point.valid = true
		
		#region Debug
		
		if debug:
			for result in up_row:
				if result.valid:
					DebugShapes.place_a_green_sphere(result.position)
		
			if base_point.valid:
				DebugShapes.place_the_green_sphere(base_point.position)
		
		#endregion Debug
		
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
			var row_number_of_rays = 16
		
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
			
			base_point.valid = true
			
			return base_point

		else:
			
			base_point = cast_0
			return base_point
	
	# If the normal is pointing upwards.
	elif cast_0.normal.y > 0.0 and cast_0.valid:
		
		# if it's a surface that is pointing upwards, simply return an invalid hit result
		var out: BasicRpgHitResult = BasicRpgHitResult.new()
		out.valid = false
		
		return out
	
	# If all the cases weren't the case, simply return an invalid hit result.
	
	var out: BasicRpgHitResult = BasicRpgHitResult.new()
	out.valid = false
	
	return out
	
func get_ledge_from_base_point(base_point: BasicRpgHitResult) -> BasicRpgLedge:
	
	if base_point == null or not base_point.valid:
		var out: BasicRpgLedge = BasicRpgLedge.new()
		out.valid = false
		
		return out
	
	#base_point.normal = Vector3(base_point.normal.x, 0.0, base_point.normal.z).normalized()
	
	
	
	
	# Then cast a row on the wall
	
	var row_cast_0_begin: Vector3 = base_point.position + base_point.normal 
	var row_cast_0_end: Vector3 = row_cast_0_begin + Vector3.UP * vertical_row_y_tolerance
	
	var row_cast_0: Array[BasicRpgHitResult] = RayCaster.cast_row(self, row_cast_0_begin, row_cast_0_end, base_point.normal * -1.0, vertical_row_number_of_rays, 5.0, true)
	
	for result in row_cast_0:
		if result.valid:
			DebugShapes.place_a_blue_sphere(result.position)
	
	
	
	# Check if it's a flat surface
	
	var is_flat_surface: bool = true
	for index in row_cast_0.size():
		
		if not index == row_cast_0.size() - 1:
			if row_cast_0[index].valid and row_cast_0[index + 1].valid:
				var position_x_equal = Math.equal_float(row_cast_0[index].position.x, row_cast_0[index + 1].position.x, 0.01)
				var position_z_equal = Math.equal_float(row_cast_0[index].position.z, row_cast_0[index + 1].position.z, 0.01)
				
				if not (position_x_equal and position_z_equal):
					is_flat_surface = false
			else:
				is_flat_surface = false
	
	# If it's a flat surface, do a big vertical row raycast.
	
	if is_flat_surface:
		
		var row_cast_big_begin: Vector3 = base_point.position + base_point.normal 
		var row_cast_big_end: Vector3 = row_cast_0_begin + Vector3.UP * platform_detection_distance
		
		# First, check how high we can cast by a Up ray cast
		var y_limit: BasicRpgHitResult = RayCaster.cast_ray_up(self, row_cast_big_begin, platform_detection_distance, false)
		
		if y_limit.valid:
			row_cast_big_end = y_limit.position * 0.9
			
		var row_cast_big = RayCaster.cast_row(self, row_cast_big_begin, row_cast_big_end, base_point.normal * -1.0, vertical_row_number_of_rays, 2.0, true)
		
		var big_y_interval: float = abs(row_cast_big_begin.y - row_cast_big_end.y) / vertical_row_number_of_rays
		var big_ledge: BasicRpgLedge = get_breakpoint_from_vertical_row(row_cast_big, big_y_interval)
	
		# then do the normal vertical row on the ledge 
		# we use the approximation funtion here, because it's easier.
		
		if big_ledge.valid:
		
			big_ledge = approximate_ledge_further(big_ledge, vertical_row_number_of_rays)
		
		# and if it shall approximate, then approximate
		if approximate:
			if big_ledge.valid:
				big_ledge = approximate_ledge_further(big_ledge, approximation_row_resolution)
		
		#region Debug
	
		if debug:
			DebugShapes.place_a_red_sphere(row_cast_big_begin)
			DebugShapes.place_a_red_sphere(row_cast_big_end)
			for result in row_cast_big:
				
				if result.valid:
					DebugShapes.place_a_blue_sphere(result.position)
				
					
		if debug and big_ledge.valid:
			DebugShapes.place_the_green_sphere(big_ledge.under.position)
		
		#endregion Debug
	
		return big_ledge
	
	# and check if nothing was hit
	
	var is_none_valid: bool = true
	
	for result in row_cast_0:
		if result.valid:
			is_none_valid = false
	
	# if nothing was valid in the whole row cast, and obviously the base point is valid, otherwise the function would have had an early return,
	# the platform is too thin then. Do a down cast from the end point, to determine the actual height of the platform.
	if is_none_valid:
		
		var down_cast_distance: float = vertical_row_y_tolerance * 1.5
		var down_cast_begin: Vector3 = row_cast_0_end + base_point.normal * -1.035
		
		var down_cast: BasicRpgHitResult = RayCaster.cast_ray_down(self, down_cast_begin, down_cast_distance, false)
		
		if not down_cast.valid:
			
			var out: BasicRpgLedge = BasicRpgLedge.new()
			out.valid = false
			return out
		
		# Now that we know the height of the platform, do a vertical row cast again.
		# We don't need so many rays because the ledge will be extremely small.
		var row_cast_small_number_of_rays: int = vertical_row_number_of_rays / 2
		
		var row_cast_small_y_tolerance = abs(row_cast_0_begin.y - down_cast.position.y)
		var row_cast_small_y_interval = row_cast_small_y_tolerance / float(row_cast_small_number_of_rays)
		
		
		var row_cast_small_begin: Vector3 = row_cast_0_begin
		var row_cast_small_end: Vector3 = row_cast_small_begin + Vector3.UP * row_cast_small_y_tolerance
		var row_cast_small_distance: float = 1.0
		
		var row_cast_small: Array[BasicRpgHitResult] = RayCaster.cast_row(self, row_cast_small_begin, row_cast_small_end, base_point.normal * -1.0, row_cast_small_number_of_rays, row_cast_small_distance, false)
		
		var small_ledge: BasicRpgLedge = get_breakpoint_from_vertical_row(row_cast_small, row_cast_small_y_interval)
		
		return small_ledge
	
	# detect the breakpoint
	var y_interval: float = vertical_row_y_tolerance / vertical_row_number_of_rays
	var ledge: BasicRpgLedge = get_breakpoint_from_vertical_row(row_cast_0, y_interval)
	
	if ledge.under.valid:
		DebugShapes.place_the_purple_sphere(ledge.under.position)
	
	
	if approximate:
		if ledge.valid:
			ledge = approximate_ledge_further(ledge, approximation_row_resolution * 3)
	
	#region Debug
	
	if debug:
		DebugShapes.place_a_red_sphere(row_cast_0_begin)
		DebugShapes.place_a_red_sphere(row_cast_0_end)
		for result in row_cast_0:
			
			if result.valid:
				DebugShapes.place_a_blue_sphere(result.position)
	if debug and ledge.valid:
		DebugShapes.place_the_green_sphere(ledge.under.position)
		
	#endregion Debug

	
	return ledge


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
			
				var length_difference: float
				
				# This works because invalid Hit Results get a length of 100
				# Don't change that in the Ray Caster, or we're fucked.
				
				length_difference = (row[index].length - row[index + 1].length) 
				
				if length_difference < -0.1:
					# THIS is the breakpoint
					hit_result_that_is_longer = row[index + 1]
					hit_result_before = row[index]

	return [hit_result_before, hit_result_that_is_longer]

func get_breakpoint_from_vertical_row(row: Array[BasicRpgHitResult], row_y_interval: float) -> BasicRpgLedge:
	
	
	if row[0].valid and row[1].valid:
		row_y_interval = abs( row[0].position.y - row[1].position.y)
	
	var out: BasicRpgLedge = BasicRpgLedge.new()
	
	# early return if the input row is invalid because it has only 1 or zero elements
	if row.size() <= 1:
		
		out = BasicRpgLedge.new()
		out.valid = false
		
		return out
	
	var two_results_that_represent_breakpoint: Array[BasicRpgHitResult] = get_breakpoint_from_row(row)
	
	out.under = two_results_that_represent_breakpoint[0]
	out.above = two_results_that_represent_breakpoint[1]
	out.y_tolerance = row_y_interval
	
	if out.under:
		out.valid = true
	else:
		out.valid = false
	
	return out

func approximate_ledge_further(ledge: BasicRpgLedge, number_of_rays: int) -> BasicRpgLedge:
	
	if not ledge.valid:
		return ledge
		
	var normal = Vector3(ledge.under.normal.x, 0.0, ledge.under.normal.z).normalized()
	
	var start_of_row = ledge.under.position + ledge.under.normal
	
	var end_of_row = start_of_row + Vector3.UP * ledge.y_tolerance 
	
	var row: Array[BasicRpgHitResult] = RayCaster.cast_row(self, start_of_row, end_of_row, ledge.under.normal * -1.0, number_of_rays, 5.0, true)
	
	if debug:
		for result in row:
			
			if result.valid:
				DebugShapes.place_a_purple_sphere(result.position)
	
	return get_breakpoint_from_vertical_row(row, ledge.y_tolerance / number_of_rays)


## This function is to check if something is between the player and the point.
## And to check if the point is still within the *platform detection distance*
## And to check if the point is above the player.
## Returns true if nothing is between the player and the point AND if it's still within the detection distance AND if it's above the player.
func validate_point(point: Vector3) -> bool:
	
	var is_something_between_player_and_point: bool = false
	
	var is_point_still_within_detection_range: bool = false
	
	
	var actual_distance = (camera.global_position - point).length()
	
	var cast = RayCaster.cast_ray(self, camera.global_position, point, false)
	
	# print("From Edge detector: Cast length: " + str(cast.length) + " Actual distance: " + str(actual_distance))
	
	if not cast.valid:
		
		is_something_between_player_and_point = false
		
	elif Math.equal_float(actual_distance, cast.length, 0.01):
		
		is_something_between_player_and_point = false
	
	else:
		
		is_something_between_player_and_point = true
	
	
	if actual_distance < platform_detection_distance:
		is_point_still_within_detection_range = true
	else:
		is_point_still_within_detection_range = false
	
	
	return is_point_still_within_detection_range and not is_something_between_player_and_point and point.y > camera.global_position.y


#endregion HELPER FUNCTIONS
