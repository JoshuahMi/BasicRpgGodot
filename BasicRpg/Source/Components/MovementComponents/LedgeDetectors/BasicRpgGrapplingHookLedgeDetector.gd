class_name BasicRpgGrapplingHookEdgeDetector extends Node3D

## A helper class for detecting valid points for the grappling hook to hang on to.

@export var camera: Node3D


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
@export var approximation_row_resolution: int = 16

## The representator that is telling the HUD if the point is currently on screen.
var detected_platform_point_representator: BasicRpgLedgeRepresentator = BasicRpgLedgeRepresentator.new()

## This is the point that is detected by this detector. The most important variable,
## since the edge detector exists to detect this point.
var detected_platform_point: Vector3 = Vector3.ZERO:
	set(new_value):
		detected_platform_point = new_value
		
		detected_platform_point_representator.set_point(new_value)
		
		if debug:
			DebugShapes.place_the_red_sphere(new_value)

var is_detected_point_valid = false

func _ready() -> void:
	
	add_child(detected_platform_point_representator)
	
	pass


func _physics_process(_delta: float) -> void:
	
	if debug:
		DebugShapes.hide_all()
	
	
	var detected_point: BasicRpgHitResult = detect_ledge()
	
	if detected_point.valid:
		is_detected_point_valid = validate_point(detected_platform_point)
		detected_platform_point = detected_point.position
		
	else:
		
		is_detected_point_valid = validate_point(detected_platform_point)
		
	
	
#region MAIN FUNCTIONS

func detect_ledge() -> BasicRpgHitResult:
	
	var point: BasicRpgHitResult = make_invalid_hit_result()
	
	var max_y_tolerance: float = check_max_y_tolerance()
	
	if max_y_tolerance > 20.0:
		max_y_tolerance = 20.0
	
	
	var small_forward_scan: BasicRpgVerticalRowScanResult = cast_row_forward(2.0)
	
	if debug:
		for result in small_forward_scan.results:
			if result.valid:
				DebugShapes.place_a_blue_sphere(result.position)
	
	var small_ledge = small_forward_scan.breakpoint_as_ledge
	
	small_ledge.determine_validity()
	
	if small_ledge.valid:
		small_ledge = approximate_ledge(small_ledge, approximation_row_resolution)
		
	
	var big_forward_scan: BasicRpgVerticalRowScanResult = cast_row_forward(max_y_tolerance - 0.5)
	
	if debug:
		for result in big_forward_scan.results:
			if result.valid:
				DebugShapes.place_a_green_sphere(result.position)
	
			if big_forward_scan.breakpoint_as_ledge.valid:
				DebugShapes.place_the_red_sphere(big_forward_scan.breakpoint_as_ledge.under.position)
				
	
	
	var additional_forward_scan: BasicRpgLedge = approximate_ledge(big_forward_scan.breakpoint_as_ledge, vertical_row_number_of_rays)
	
	additional_forward_scan.determine_validity()
	
	if approximate:
		additional_forward_scan = approximate_ledge(additional_forward_scan, approximation_row_resolution)
		additional_forward_scan.determine_validity()
	
	

	
	if small_ledge.valid:
		
		point = small_ledge.under
		
		return point
	else:
		if additional_forward_scan.valid:
		
			return additional_forward_scan.under
		else:
			
			return make_invalid_hit_result()
			
	return make_invalid_hit_result()

## THE STANDARD - it uses the forward row cast approach
func detect_ledge_exp() -> BasicRpgHitResult:
	
	# If the small row cast didn't find a ledge, do a bigger one.
	
	var max_y_tolerance: float = check_max_y_tolerance()
	
	var point: BasicRpgHitResult = make_invalid_hit_result()
	
	for i in 4:
		
		var index = i + 1
		var yy_tolerance = 2.0 * index
		
		if yy_tolerance > max_y_tolerance:
			yy_tolerance = max_y_tolerance
		
		var forward_scan: BasicRpgVerticalRowScanResult = cast_row_forward(yy_tolerance)
		
		var ledge: BasicRpgLedge = forward_scan.breakpoint_as_ledge
		
		ledge.determine_validity()
		
		if debug:
			if ledge.under.valid:
				DebugShapes.place_the_purple_sphere(ledge.under.position)
		
			for result in forward_scan.results:
				
				if result.valid:
					
					DebugShapes.place_a_blue_sphere(result.position)
		
		
		
		
		if ledge.validity == BasicRpgLedge.Validity.VALID:
			
			if approximate:
				ledge = approximate_ledge(ledge, approximation_row_resolution)
				
				ledge.determine_validity()
				
				if ledge.validity == BasicRpgLedge.Validity.VALID:
					
					return ledge.under
				else:
					return make_invalid_hit_result()
				
				
			point = ledge.under
			
			return point
			
	
	var forward_scan: BasicRpgVerticalRowScanResult = cast_row_forward(max_y_tolerance)
		
	var ledge: BasicRpgLedge = forward_scan.breakpoint_as_ledge
	
	ledge.determine_validity()
	
	if ledge.validity == BasicRpgLedge.Validity.VALID:
		
		ledge = approximate_ledge(ledge, vertical_row_number_of_rays)
		
		if approximate:
			ledge = approximate_ledge(ledge, approximation_row_resolution)
			
		if ledge.valid:
			return ledge.under
		else:
			return make_invalid_hit_result()
	
	
	return make_invalid_hit_result()

#endregion MAIN FUNCTIONS


#region HELPER FUNCTIONS


func make_invalid_ledge() -> BasicRpgLedge:
	var out: BasicRpgLedge = BasicRpgLedge.new()
	out.valid = false
	return out

func make_invalid_hit_result() -> BasicRpgHitResult:
	
	var out: BasicRpgHitResult = BasicRpgHitResult.new()
	out.valid = false
	out.length = 100.0
	
	return out

func make_ledge(breakpnt: Array[BasicRpgHitResult]) -> BasicRpgLedge:
	
	var out: BasicRpgLedge = BasicRpgLedge.new()
	
	out.under = breakpnt[0]
	out.above = breakpnt[1]
	
	out.y_tolerance = (breakpnt[0].original_ray_begin - breakpnt[1].original_ray_begin).length()
	
	out.determine_validity()
	
	return out
	
func cast_row_forward(y_tolerance: float) -> BasicRpgVerticalRowScanResult :
	
	var forward_row_cast: Array[BasicRpgHitResult] = RayCaster.cast_row(self, camera.global_position, camera.global_position + Vector3.UP * y_tolerance, Math.get_forward_vector_of_node(camera), vertical_row_number_of_rays, platform_detection_distance, true)
		
	var breakpnt: Array[BasicRpgHitResult] = get_breakpoint_from_row(forward_row_cast)
	
	var out: BasicRpgVerticalRowScanResult = BasicRpgVerticalRowScanResult.new()
	
	out.results = forward_row_cast
	
	out.breakpoint_as_ledge = make_ledge(breakpnt)
	
	out.is_flat_surface = is_flat_surface(forward_row_cast)
	
	out.is_completely_invalid = is_none_valid(forward_row_cast)
	
	return out

func cast_forward() -> BasicRpgHitResult:
	
	# first, get the wall collision position. 
	return RayCaster.cast_forward(self, camera, platform_detection_distance)

func check_max_y_tolerance() -> float:
	
	var up_hit: BasicRpgHitResult = RayCaster.cast_ray_up(self, camera.global_position, platform_detection_distance, false)
	
	if up_hit.valid:
		return up_hit.length
	else:
		return platform_detection_distance
	

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
	

## General purpose function. Returns the breakpoint of a row cast, the latest place where a hit result is significantly shorter than its successor
func get_breakpoint_from_row(row: Array[BasicRpgHitResult]) -> Array[BasicRpgHitResult]:
	
	
	
	var hit_result_that_is_longer: BasicRpgHitResult = make_invalid_hit_result()
	
	var hit_result_before: BasicRpgHitResult = make_invalid_hit_result()

	if row.size() <= 1:
		
		var out: Array[BasicRpgHitResult]
		out = [make_invalid_hit_result(), make_invalid_hit_result()]
		
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
					break
	
	
	
	# TODO: If we could add an additional row here which checks if 
	# Any two results in this additional row in the breakpoint have a significantly higher length difference
	# Than the EXPECTED AVERAGE length difference they should have, it's at least a... hm
	# On a spherical surface the last should have a longer, the first have a shorter length - 
	# we're searching for a significant, unexpected change. WAIT
	
	# IF we set the length difference of the two rays BEFORE the current one as reference, and check if 
	# it's, let's say, more than 1,25 times longer, then it should be significant!
	
	# But how do we treat invalid ones with a length of 100.0? If the normal changes slowly 
	# towards the dot product of zero between it's direction and the normal... well. What do we do with low resolution spheres?
	
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


func approximate_ledge(ledge: BasicRpgLedge, number_of_rays: int) -> BasicRpgLedge:
	
	if ledge == null:
		return make_invalid_ledge()
		
	if not ledge.valid:
		return ledge
	
	var row_begin: Vector3 = ledge.under.original_ray_begin
	
	var row_end: Vector3 = ledge.above.original_ray_begin
	
	var row_direction: Vector3 = ledge.under.original_ray_direction
	
	var hit_results : Array[BasicRpgHitResult] = RayCaster.cast_row(self, row_begin, row_end, row_direction, number_of_rays, ledge.under.original_ray_length * 2.0, true)
	
	return make_ledge(get_breakpoint_from_row(hit_results))


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
		#print("From Ledge Detector: Something is between player and point! ")
		is_something_between_player_and_point = true
	
	
	if actual_distance < platform_detection_distance:
		is_point_still_within_detection_range = true
	else:
		is_point_still_within_detection_range = false
	
	
	return is_point_still_within_detection_range and not is_something_between_player_and_point and point.y > camera.global_position.y


#endregion HELPER FUNCTIONS
