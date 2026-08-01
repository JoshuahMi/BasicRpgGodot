class_name BasicRpgGrapplingHookEdgeDetector extends Node3D

## A helper class for detecting valid points for the grappling hook to hang on to.

# TODO: Keeping the last known valid edge point AND validating it in the sense of checking if something is between the player and the point.
# TODO: Add more debug functionality
# TODO: Add "Abtasten" function in a reasonable way

@export var camera: Node3D

@export var debug: bool = true

@export var platform_detection_distance: float = 100.0

## Used to determine how big the radius shall be to detect ledges on a wall
@export var star_cast_distance: float = 1.0

## This is the point that is detected by this detector. The most important variable,
## since the edge detector exists to detect this point.
var valid_detected_platform_point: Vector3 = Vector3.ZERO
	
## currently invalidated detected platform point. If it gets validated, it will become the new
## *valid deteted platform point*
var detected_platform_point: Dictionary:
	set(new_value):
		detected_platform_point = new_value
		if not new_value.is_empty():
			DebugShapes.place_the_red_sphere(new_value["position"])



## If the point currently stored in *detected platform point* is actually 
## a good point for the grappling hook to hang onto, regardless of where the player is or looks to.
var is_detected_platform_point_a_valid_ledge: bool = false

## If the point currently stored in *detected platform point* is still valid in the sense that nothing is between the player and the point.
## TODO: check if the player still looks in the direction of the point.
var is_detected_platform_point_valid: bool = true:
	set(new_value):
		is_detected_platform_point_valid = new_value
		#print(new_value)

## If in the current physics frame a ledge or a climbable edge was found. If not, the *detected platform point* is from a previous
## frame that detected a valid point and it needs to be validated in the sense that nothing is between the player
## and the point.
var is_platform_detected: bool = false

func _ready() -> void:
	pass


func _physics_process(_delta: float) -> void:
	
	# test_cast_forward()
	var detected_platform_point = test_detect_ledge_2()
	
	if detected_platform_point.has("position"):
	
		DebugShapes.place_the_red_sphere(detected_platform_point["position"])
	
	#var result := detect_ledge()
	#
	#if not result.is_empty():
		#DebugShapes.place_the_red_sphere(result["position"])
	#else:
		#DebugShapes.hide_the_red_sphere()
	

	
#region MAIN FUNCTIONS


func test_detect_ledge_2() -> Dictionary:
	
	DebugShapes.hide_all()
	
	# First, and this is the new approach of this function, cast a row forward.
	
	var direction = Math.get_forward_vector_of_node(camera)
	direction = Vector3(direction.x, 0.0, direction.z).normalized()
	var initial_number_of_rays : int = 8
	# TODO: If this vector gets to be zero because the player is looking up or down, don't cast.
	
	var results: Array[Dictionary] = RayCaster.cast_row(self, camera.global_position, camera.global_position + Vector3.UP * 5.0, direction, initial_number_of_rays, 100.0)
	
	#region Debug
	#for result in results:
		#if result.has("position"):
			#DebugShapes.place_a_blue_sphere(result["position"])
		#
	#endregion Debug
	
	
	# Now detect the breakpoint.
	# The breakpoint is most likely the shortest ray cast.
	# If two have same length, the one with the higher index "wins"
	
	var shortest: Dictionary = evaluate_shortest_from_row_hit_result(results)
	
	#region Debug
	#if shortest.has("position"):
		#DebugShapes.place_the_green_sphere(shortest["position"])
	#endregion Debug
	
	# ...and scan the area around the breakpoint
	
	var interval: float = abs(camera.global_position.y - (camera.global_position + Vector3.UP * 5.0).y) / float(initial_number_of_rays)
	
	var scan_results: Array[Dictionary] = []
	if shortest.has("position") and not shortest["index"] == initial_number_of_rays - 1:
		scan_results = RayCaster.cast_row(self, shortest["position"] + shortest["normal"], shortest["position"] + shortest["normal"] + Vector3.UP * interval, shortest["normal"] * -1.0, 8, 2.0)
	
	
	var shortest_of_scan: Dictionary = evaluate_shortest_from_row_hit_result(scan_results)
	
	#region Debug
	#for result in scan_results:
		#
		#if result.has("position"):
			#DebugShapes.place_a_green_sphere(result["position"])
		#
		#pass
	#endregion Debug
	
	
	# GET THE POINT
	var point: Dictionary = {}
	if shortest_of_scan.has("position"):
		
		DebugShapes.place_the_red_sphere(shortest_of_scan["position"])
		
		# BUG: In this line lies the problem.
		point = get_edge_from_collistion_hit_result(shortest_of_scan, interval / 7.0)
		
		if point.has("position"):
			print("From Ledge Detector: found a point!")
			DebugShapes.place_the_blue_sphere(point["position"])
		else:
			print("From Ledge Detector: no point.")
		
		
		
	# Validate the point by checking if the player can reach it
	var is_point_valid: bool = false
	if point.has("position"):
		
		var length_between_player_and_point: float = (camera.global_position - point["position"]).length()
		
		
		var cast_from_player_to_point: Dictionary = RayCaster.cast_ray_from_node(self, point["position"], false)
		
		if cast_from_player_to_point.has("length"):
			
			if cast_from_player_to_point["length"] >= length_between_player_and_point:
				is_point_valid = true
			
			
		
		
		
		
		
	if is_point_valid == true:
		return point
	else:
		return {}




## Another try.
## This one seems to naively assume that we have an initial normal (*cast 0*) y value of 0, though I could see the upwards cast working when we look at faces pointing downwards too, with some slight adjustments.
func test_detect_ledge_1() -> Dictionary:
	
	DebugShapes.hide_red_spheres()
	
	var cast_0 : Dictionary = RayCaster.cast_forward(self, camera, platform_detection_distance)
	
	if cast_0.is_empty():
		return {}
	
	# Make it floating on the surface
	cast_0["position"] = cast_0["position"] + cast_0["normal"] * 0.1
	
	# Now check the height of the place we're in
	
	var maximum_y_wall := get_highest_y_value_from_hit_result(cast_0)
	var maximum_y_player := get_highest_y_value_from_point(camera.global_position)
	
	var up_raycasts: Dictionary = {}
	var breakpoint_of_the_up_raycasts: Dictionary = {}
	# now cast an incremental horizontal up cast
	if not maximum_y_wall.is_empty():
		
		up_raycasts = RayCaster.cast_row_upwards(self, cast_0["position"], camera.global_position, maximum_y_wall["position"].y * 2.0, 8)
		
		if up_raycasts.has("breakpoint"):
			breakpoint_of_the_up_raycasts = up_raycasts["breakpoint"]
	
	# Check where the breakpoint is. Then we know from the height of the second hit from the breakpoint where we can shoot the vertical row ( between this hit results y position and the players y position)
	
	if not breakpoint_of_the_up_raycasts.is_empty():
		
		# TODO: Here we have the breakpoint. Do a "scan surface" here, then we got an approximate edge point!
		# Or not. Doesn't work as reliable as it should be.
		
		#DebugShapes.place_a_red_sphere(breakpoint_of_the_up_raycasts["result"]["position"])
		#DebugShapes.place_a_red_sphere(breakpoint_of_the_up_raycasts["next_point"])
		
		var cast_1: Dictionary = RayCaster.cast_ray(self, breakpoint_of_the_up_raycasts["next_point"], breakpoint_of_the_up_raycasts["result"]["position"], false)
		var end_result: Dictionary = {}
		# This is the edge UNDER the ledge.
		if not cast_1.is_empty():
			DebugShapes.place_the_green_sphere(cast_1["position"])
			
			cast_1["position"] = cast_1["position"] + cast_1["normal"] * 0.1
			cast_1["position"] = Vector3(cast_1["position"].x, cast_1["position"].y + 0.05, cast_1["position"].z,)
			
			end_result = scan_surface_from_perceived_point(cast_1)
		
		if not end_result.is_empty():
			pass
			#DebugShapes.place_the_red_sphere(end_result["position"])
		else:
			DebugShapes.hide_all()
		
		
		#scan_surface_from_perceived_point()
		
		
		
		
		
		
		
		
	else:
		DebugShapes.hide_all()
		
		pass
	
	
	
	
	
	
	return {}


## Interestingly this one works best.
func test_detect_ledge() -> Dictionary:
	
	var cast_0 : Dictionary = RayCaster.cast_forward(self, camera, platform_detection_distance)
	
	#if not cast_0.is_empty():
		#DebugShapes.place_the_blue_sphere(cast_0["position"])
	
	if not cast_0.is_empty():
		detected_platform_point = scan_surface_from_perceived_point(cast_0)
		
	return {}


## The more sophisticated version of the detection function
func detect_ledge() -> Dictionary:
	
	# first, get the wall collision position. 
	var cast_0 : Dictionary = RayCaster.cast_forward(self, camera, platform_detection_distance)
	
	# then check if around the collision point is a ledge.
	# use the normal of the wall to float above the wall and cast rays left and right, as well as up and down.
	
	if cast_0.is_empty():
		return {}
	
	
	#if debug:
		#debug_place_sphere(cast_0["position"])
	
	
	var ledge_around_point: Dictionary = RayCaster.cast_star(self, cast_0["position"], cast_0["normal"], star_cast_distance)
	
	
	# then, IF a ledge is found, get the edge of it
	
	var result: Dictionary = {}
	
	if not ledge_around_point.is_empty():
		
		result = get_ledge_from_star_cast(ledge_around_point)
		
		if not result.is_empty():
			pass
			#debug_place_box(result["position"])
		
		
		pass
		
	# If no ledge is found, simply get the roof ledge
	else:
		result = get_edge_from_collision_point(cast_0["position"], 10.0)
		pass

	return result

## Detects a platform edge in a very basic way. 
func detect_platform():
	
	# First, let the player cast a ray to a world object:
	var cast_0 : Dictionary = RayCaster.cast_forward(self, camera, platform_detection_distance)
	
	if cast_0.is_empty():
		return
		
	var edge = get_edge_from_collision_point(cast_0["position"], 10.0)
	
	if edge.is_empty():
		#debug_hide_all()
		return
	else:
		detected_platform_point = edge["position"]
		
		return
		
	

#endregion MAIN FUNCTIONS
	
#region HELPER FUNCTIONS

func evaluate_shortest_from_row_hit_result(results: Array[Dictionary]) -> Dictionary:
	
	var shortest: Dictionary = {"length" : 1000.0, "index" : -1}
	for result in results:
		
		if result.has("length") and shortest.has("length") and result.has("index") and shortest.has("index"):
			
			if Math.equal_float(result["length"], shortest["length"], 0.05):
				
				if result["index"] > shortest["index"]:
					shortest = result
				
			elif result["length"] < shortest["length"]:
				shortest = result
		
	if shortest.has("position"):
		return shortest
	else:
		return {}







## This is to be called from the player position. Returns the highest hit result the ray cast can reach.
## Can be used for other things as well, it's not that specialized. Will return a hit result though, except for when it doesn't hit something.
## A reduced Dictionary is then returned, with its only key being *position*
func get_highest_y_value_from_point(start: Vector3) -> Dictionary:
	var result : Dictionary = RayCaster.cast_ray_up(self, start, 100.0, false)
	
	if result.is_empty():
		return {"position" : Vector3(start.x, start.y + 100.0, start.z)}
	else:
		DebugShapes.place_the_green_sphere(result["position"])
		return {"position" : result["position"]}


## This is to be called after an initial raycast to a wall, returning the highest possible y value a raycast from above could be cast from.
## This approach is very naive, obviously. To be used when nothing else works.
func get_highest_y_value_from_hit_result(start: Dictionary) -> Dictionary:
	
	if start.is_empty():
		return {}
	
	
	# if it's not a vertical surface the return value will be invalid
	if not Math.equal_float(start["normal"].y, 0.0, 0.05):
		
		return {}
	
	var starting_point_of_the_raycast = start["position"]
	
	var result : Dictionary = RayCaster.cast_ray_up(self, starting_point_of_the_raycast, 100.0, false)
	
	if result.is_empty():
		return {"position" : Vector3(start["position"].x, start["position"].y + 100.0, start["position"].z)}
	else:
		#DebugShapes.place_the_green_sphere(result["position"])
		return {"position" : result["position"]}
		

	
	
	
## This is unreliable. No clue why.
## Scans a surface by using two vertical rows of raycasts, to approximate a possible ledge for the grappling hook to hang onto
func scan_surface_from_perceived_point(perceived_point: Dictionary) -> Dictionary:
	
	if perceived_point.is_empty():
		return {}
	
	
	var source_position := perceived_point
	var normal_float := 1.0
	var direction : Vector3 = perceived_point["normal"] * -1.0
	var ray_length : float = 3.0
	
	var y_tolerance: float = 3.0
	
	var minimum_y: float = perceived_point["position"].y
	var maximum_y: float = perceived_point["position"].y + y_tolerance
	
	var number_of_rays: int = 16
	
	# THE ACTUAL RAYCASTS
	var scan_results : Dictionary = RayCaster.cast_vertical_row(self, source_position, normal_float, direction, ray_length, minimum_y, maximum_y, number_of_rays )
	
	#DebugShapes.place_the_blue_sphere(scan_results["shortest"]["position"])
	
	
	
	# Then evaluate the scan results.
	
	#DebugShapes.hide_green_spheres()
	
	
	# Do a second vertical row inside the y coordinates of the *breakpoint*
	if not scan_results["breakpoint"]["result"].is_empty():
		
		var second_cast_y_frame: float = scan_results["breakpoint"]["y_frame"]
		var second_cast_start_point: Dictionary = scan_results["breakpoint"]["result"]
		
		var second_cast_scan_results: Dictionary = RayCaster.cast_vertical_row(self, second_cast_start_point, 0.5, second_cast_start_point["normal"] * -1.0, 1.0, second_cast_start_point["position"].y, second_cast_start_point["position"].y + second_cast_y_frame, 8)
		
		#for result in second_cast_scan_results["hit_results"]:
			#if not result.is_empty():
				#DebugShapes.place_a_green_sphere(result["position"])
		
		
		if second_cast_scan_results["shortest"].has("position"):
			DebugShapes.place_the_red_sphere(second_cast_scan_results["shortest"]["position"])
			return second_cast_scan_results["shortest"]
		else:
			return {}
			#DebugShapes.hide_the_red_sphere()
	
	else:
		return {}
	# then do the *get edge fom collision point* on it and validate the point

	

## Checks if the given detected point is a valid edge point the player could hang on
## with the grappling hook.
func validate_evaluated_as_valid_edge_point(result: Dictionary) -> bool:
	if result.is_empty():
		is_detected_platform_point_valid = false
		return false

	var is_valid_edge_point = Math.equal_float(result["normal"].y, 0.0, 0.1)
	
	is_detected_platform_point_valid = is_valid_edge_point
	return is_valid_edge_point
	
## TODO: Will take an edge point and check if something is between the player and the edge point, making it invalid.
## Used when in the current frame no new edge point is found, so it will validate the last.
func validate_evaluated_as_from_player(result: Vector3):
	
	# first, check how far the distance between the evaluated point and the camera is.
	
	var distance_between_camera_and_point = (result - camera.global_position).length()
	
	# Then check if something is between the player and the edge
	
	var result_between : Dictionary = RayCaster.cast_ray(self, camera.global_position, result, false)
	
	if result_between.is_empty():
		is_detected_platform_point_valid = true
		return
	
	if (result_between["position"] - camera.global_position).length() < distance_between_camera_and_point:
		
		# then something is between the player and the point
		is_detected_platform_point_valid = false
	else:
		
		is_detected_platform_point_valid = true

## Used after detecting a point that is supposedly a valid edge to hang a grappling hook on.
## Works by checking the normal y value.
func validate_evaluated_point(result: Dictionary):
	
	if result.is_empty():
		is_detected_platform_point_valid = false
		return false
	
	var is_valid_edge_point = Math.equal_float(result["normal"].y, 0.0, 0.1)
	
	# first, check how far the distance between the evaluated point and the camera is.
	
	var distance_between_camera_and_point = (result["position"] - camera.global_position).length()
	
	# Then check if something is between the player and the edge
	
	var result_between : Dictionary = RayCaster.cast_ray(self, camera.global_position, result["position"], false)
	
	
	# if it didn't hit anything then it outreached
	if result_between.is_empty():
		
		is_detected_platform_point_valid = true
		
		return
	
	if (result_between["position"] - camera.global_position).length() < distance_between_camera_and_point or not is_valid_edge_point:
		
		# then something is between the player and the point
		is_detected_platform_point_valid = false
	else:
		
		is_detected_platform_point_valid = true

## Will get the ledge edge that was detected by a star cast
func get_ledge_from_star_cast(star_cast_hit_result: Dictionary) -> Dictionary:
	
	if star_cast_hit_result.is_empty():
		return {}
	
	var edge: Dictionary = {}
	
	# the normal points upward or downward if the absolute y value is more than 0.9
	if abs(star_cast_hit_result["normal"].y) > 0.9:
		
		#if it points upward
		if star_cast_hit_result["normal"].y > 0.0:
			
			
			# simply shoot from the normal vector to the point where the star collided
			# Why not from the player?
			# edge = cast_ray( star_cast_hit_result["position"] + star_cast_hit_result["normal"] * 10.0, star_cast_hit_result["position"], true)
			
			# okay, I'm gonna try from the player
			edge = RayCaster.cast_ray_from_node_xz(self, star_cast_hit_result["position"].y, star_cast_hit_result["position"], false)
			
			return edge
		
		# ...or if it points downward
		else:
			
			
			# first, get the height of the ledge
			var roof : Dictionary = RayCaster.cast_ray(self, star_cast_hit_result["position"] + Vector3(0.0, 0.01, 0.0), star_cast_hit_result["position"] + Vector3.UP * 10.0, false)
			
			if roof.is_empty():
				
				roof = RayCaster.cast_ray(self, star_cast_hit_result["position"] + Vector3(0.0, 10.0, 0.0), star_cast_hit_result["position"] + Vector3.DOWN * 10.0, false)
				#print(roof["position"])
			else:
				
				roof = RayCaster.cast_ray(self, roof["position"], roof["position"] + Vector3.DOWN, false)
				
				
				
			if roof.is_empty():
				return {}
			
			# then get the edge
			
			edge = RayCaster.cast_ray_from_node_xz(self, roof["position"].y, roof["position"], false)
			
			if not edge.is_empty():
				pass
				#debug_place_box(edge["position"])
			
			return edge
			
		## The normal points to the side if the y value is 0.0
	## BUG - here lies the problem. When the normal points to the side, no valid point can be found.
	elif abs(star_cast_hit_result["normal"].y) < 0.1:
		
		edge = RayCaster.cast_ray(self, star_cast_hit_result["position"] + star_cast_hit_result["normal"] * -0.01, star_cast_hit_result["position"] + star_cast_hit_result["normal"] * -0.01 + Vector3.UP * 10.0, true)
		return edge
		
	else:
		return {}

## UNRELIABLE. Only works when looking from a specific direction.
func get_edge_from_collistion_hit_result(collision_point: Dictionary, y_tolerance: float) -> Dictionary:
	
	
	if not collision_point.has("position") and not collision_point.has("normal"):
		return {}
		
	# First get the total height of the object that was collided with.
	# BUG: Here lies the problem. looking from a specific direction, no roof can be found. It just goes past the point
	
	# Jeez, even after moving the point along the normal towards the building, it's only from one side again
	var corrected_collision_point: Vector3 = collision_point["position"] + collision_point["normal"] * -0.1
	
	
	var platform_roof : Dictionary = RayCaster.cast_ray_down(self, Vector3(corrected_collision_point.x, corrected_collision_point.y + y_tolerance, corrected_collision_point.z), y_tolerance + 1.0, false)
	
	if platform_roof.is_empty():
		print("From Ledge Detector: Didn't find a roof.")
		return {}
	else:
		DebugShapes.place_a_blue_sphere(platform_roof["position"])
		
	var platform_edge : Dictionary = RayCaster.cast_ray(self, platform_roof["position"] + collision_point["normal"] * 0.1, platform_roof["position"], false)
	
	return platform_edge
	
	
	
	
## UNRELIABLE somehow. I don't know why. Only works when looking from a specific side
## Most basic function that will return the ledge that is within the y tolerance above the given point. 
func get_edge_from_collision_point(collision_point: Vector3, y_tolerance: float) -> Dictionary:
	
	
	# First get the total height of the object that was collided with.
	var platform_roof : Dictionary = RayCaster.cast_ray_down(self, Vector3(collision_point.x, collision_point.y + y_tolerance, collision_point.z), y_tolerance + 1.0, false)
	
	if platform_roof.is_empty():
		return {}
	
	# Then cast a ray from the players xz position to the roof point. It will hit the edge.
	var platform_edge : Dictionary = RayCaster.cast_ray(self, Vector3(camera.global_position.x, platform_roof["position"].y, camera.global_position.z ), platform_roof["position"], false)
	
	return platform_edge

#endregion HELPER FUNCTIONS
