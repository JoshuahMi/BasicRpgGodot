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
	
	# first, get the wall collision position. 
	var cast_0 : BasicRpgHitResult = RayCaster.cast_forward(self, camera, platform_detection_distance)
	
	
	if not cast_0.valid:
		return cast_0
	
	
	# Then cast a row on the wall
	
	var y_tolerance: float = 2.0
	var row_cast_0_begin: Vector3 = cast_0.position + cast_0.normal 
	var row_cast_0_end: Vector3 = row_cast_0_begin + Vector3.UP * y_tolerance
	var number_of_rays: int = 7
	#var row_cast_0: Array[BasicRpgHitResult] = RayCaster.cast_row(self, camera.global_position, row_cast_0_begin, row_cast_0_end - cast_0.position, 16, 10.0, true)
	
	var row_cast_0: Array[BasicRpgHitResult] = RayCaster.cast_row(self, row_cast_0_begin, row_cast_0_end, cast_0.normal * -1.0, 7, 5.0, true)
	
	#for result in row_cast_0:
		#
		#if result.valid:
			#DebugShapes.place_a_blue_sphere(result.position)
	
	
	
	
	
	# detect the breakpoint
	var y_interval = y_tolerance / number_of_rays
	var ledge: BasicRpgLedge = get_breakpoint_from_vertical_row(row_cast_0, y_interval)
	
	
	ledge.validate()
	
	
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

#endregion HELPER FUNCTIONS
