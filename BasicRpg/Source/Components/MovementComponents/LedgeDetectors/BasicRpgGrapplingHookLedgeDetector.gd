class_name BasicRpgGrapplingHookEdgeDetector extends Node3D

## A helper class for detecting valid points for the grappling hook or the spell Grabbelkliff to hang on to.

@export var camera: Node3D


@export var debug: bool = false



## If the Edge Detector shall search for a point. Is basically the on/off switch of 
## The edge detector. If the player doesn't have a grappling hook or Grabbelkliff, it's pointless 
## to search for points. Pun intended.
var is_currently_searching: bool = true

## How far the detector will reach detecting points. An already detected point
## going out of this distance will become invalid.
@export var platform_detection_distance: float = 40.0

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
	
	if not is_currently_searching:
		return
	
	if debug:
		DebugShapes.hide_all()
	
	
	var detected_point: BasicRpgHitResult = detect_ledge_all()
	
	if detected_point.valid:
		is_detected_point_valid = validate_point(detected_platform_point)
		detected_platform_point = detected_point.position
		
	else:
		
		is_detected_point_valid = validate_point(detected_platform_point)
		
	
	
#region MAIN FUNCTIONS

func detect_ledge_all() -> BasicRpgHitResult:
	
	var first_attempt: BasicRpgHitResult = detect_ledge()
	
	if first_attempt.valid:
		return first_attempt
	else:
		return detect_ledge_big()


func detect_ledge_big():
	
	
	
	var max_y_tolerance: float = check_max_y_tolerance()
	
	if max_y_tolerance > 30.0:
		max_y_tolerance = 30.0
	
	var big_row: BasicRpgVerticalRowScanResult = cast_row_forward(max_y_tolerance, vertical_row_number_of_rays * 10)
	
	if debug:
		for result in big_row.results:
			if result.valid:
				if result.original_ray_direction.y > 0.0:
					DebugShapes.place_a_blue_sphere(result.position)
	
	
	
	
	
	
	
	
	
	
	#if big_row.breakpoint_as_ledge.under.valid:
		#DebugShapes.place_the_red_sphere(big_row.breakpoint_as_ledge.under.position)
	
	
	
	var small_row: BasicRpgLedge = approximate_ledge(big_row.breakpoint_as_ledge, vertical_row_number_of_rays)
	
	if approximate:
		small_row = approximate_ledge(small_row, approximation_row_resolution)
	
	small_row.determine_validity()
	
	if small_row.valid:
		return small_row.under
	else:
		return RayCaster.make_invalid_hit_result()
	
	



func detect_ledge() -> BasicRpgHitResult:
	
	var point: BasicRpgHitResult = RayCaster.make_invalid_hit_result()
	
	var max_y_tolerance: float = check_max_y_tolerance()
	
	if max_y_tolerance > 20.0:
		max_y_tolerance = 20.0
	
	
	var small_forward_scan: BasicRpgVerticalRowScanResult = cast_row_forward(2.0, vertical_row_number_of_rays)
	
	if debug:
		for result in small_forward_scan.results:
			if result.valid:
				DebugShapes.place_a_blue_sphere(result.position)
	
	var small_ledge = small_forward_scan.breakpoint_as_ledge
	
	small_ledge.determine_validity()
	
	if small_ledge.valid:
		small_ledge = approximate_ledge(small_ledge, approximation_row_resolution)
		
	
	var big_forward_scan: BasicRpgVerticalRowScanResult = cast_row_forward(max_y_tolerance - 0.5, vertical_row_number_of_rays)
	
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
			
			return RayCaster.make_invalid_hit_result()
			
	return RayCaster.make_invalid_hit_result()

## THE STANDARD - it uses the forward row cast approach
func detect_ledge_exp() -> BasicRpgHitResult:
	
	# If the small row cast didn't find a ledge, do a bigger one.
	
	var max_y_tolerance: float = check_max_y_tolerance()
	
	var point: BasicRpgHitResult = RayCaster.make_invalid_hit_result()
	
	for i in 4:
		
		var index = i + 1
		var yy_tolerance = 2.0 * index
		
		if yy_tolerance > max_y_tolerance:
			yy_tolerance = max_y_tolerance
		
		var forward_scan: BasicRpgVerticalRowScanResult = cast_row_forward(yy_tolerance, vertical_row_number_of_rays)
		
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
					return RayCaster.make_invalid_hit_result()
				
				
			point = ledge.under
			
			return point
			
	
	var forward_scan: BasicRpgVerticalRowScanResult = cast_row_forward(max_y_tolerance, vertical_row_number_of_rays)
		
	var ledge: BasicRpgLedge = forward_scan.breakpoint_as_ledge
	
	ledge.determine_validity()
	
	if ledge.validity == BasicRpgLedge.Validity.VALID:
		
		ledge = approximate_ledge(ledge, vertical_row_number_of_rays)
		
		if approximate:
			ledge = approximate_ledge(ledge, approximation_row_resolution)
			
		if ledge.valid:
			return ledge.under
		else:
			return RayCaster.make_invalid_hit_result()
	
	
	return RayCaster.make_invalid_hit_result()

#endregion MAIN FUNCTIONS


#region HELPER FUNCTIONS

func make_ledge(breakpnt: Array[BasicRpgHitResult]) -> BasicRpgLedge:
	
	var out: BasicRpgLedge = BasicRpgLedge.new()
	
	out.under = breakpnt[0]
	out.above = breakpnt[1]
	
	out.y_tolerance = (breakpnt[0].original_ray_begin - breakpnt[1].original_ray_begin).length()
	
	out.determine_validity()
	
	return out
	
func cast_row_forward(y_tolerance: float, number_of_rays: int) -> BasicRpgVerticalRowScanResult :
	
	var forward_direction: Vector3 = Math.get_forward_vector_of_node(camera)
	
	# Correct the y direction, so that all the rays are going upwards
	if forward_direction.y < 0.1:
		forward_direction = Vector3(forward_direction.x, 0.1, forward_direction.z).normalized()
	
	var forward_row_cast: Array[BasicRpgHitResult] = RayCaster.cast_row(self, camera.global_position, camera.global_position + Vector3.UP * y_tolerance, forward_direction, number_of_rays, platform_detection_distance, true)
		
	var breakpnt: Array[BasicRpgHitResult] = RayCaster.get_breakpoint_from_row(forward_row_cast)
	
	var out: BasicRpgVerticalRowScanResult = BasicRpgVerticalRowScanResult.new()
	
	out.results = forward_row_cast
	
	out.breakpoint_as_ledge = make_ledge(breakpnt)
	
	out.is_flat_surface = RayCaster.row_cast_is_flat_surface(forward_row_cast)
	
	out.is_completely_invalid = RayCaster.row_cast_is_none_valid(forward_row_cast)
	
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
	

func approximate_ledge(ledge: BasicRpgLedge, number_of_rays: int) -> BasicRpgLedge:
	
	if ledge == null:
		return RayCaster.make_invalid_ledge()
		
	if not ledge.valid:
		return ledge
	
	var row_begin: Vector3 = ledge.under.original_ray_begin
	
	var row_end: Vector3 = ledge.above.original_ray_begin
	
	var row_direction: Vector3 = ledge.under.original_ray_direction
	
	var hit_results : Array[BasicRpgHitResult] = RayCaster.cast_row(self, row_begin, row_end, row_direction, number_of_rays, ledge.under.original_ray_length * 2.0, true)
	
	return make_ledge(RayCaster.get_breakpoint_from_row(hit_results))


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
