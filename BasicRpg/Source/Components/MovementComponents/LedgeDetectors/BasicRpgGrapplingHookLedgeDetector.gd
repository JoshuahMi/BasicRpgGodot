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
	test_detect_ledge()
	#var result := detect_ledge()
	#
	#if not result.is_empty():
		#DebugShapes.place_the_red_sphere(result["position"])
	#else:
		#DebugShapes.hide_the_red_sphere()
	

	
#region MAIN FUNCTIONS

func test_detect_ledge() -> Dictionary:
	
	var cast_0 := RayCaster.cast_forward(self, camera, platform_detection_distance)
	
	#if not cast_0.is_empty():
		#DebugShapes.place_the_blue_sphere(cast_0["position"])
	
	if not cast_0.is_empty():
		detected_platform_point = scan_surface_from_perceived_point(cast_0)
		
	return {}


## The more sophisticated version of the detection function
func detect_ledge() -> Dictionary:
	
	# first, get the wall collision position. 
	# if the normals absolute y value is above a certain value, the ledge position isn't valid.
	# TODO: search for a better wall collision point then.
	var cast_0 := RayCaster.cast_forward(self, camera, platform_detection_distance)
	
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
	var cast_0 := RayCaster.cast_forward(self, camera, platform_detection_distance)
	
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

func scan_surface_from_perceived_point(perceived_point: Dictionary) -> Dictionary:
	
	var source_position := perceived_point
	var normal_float := 1.0
	var direction : Vector3 = perceived_point["normal"] * -1.0
	var ray_length : float = 3.0
	
	var y_tolerance: float = 1.0
	
	var minimum_y: float = perceived_point["position"].y
	var maximum_y: float = perceived_point["position"].y + y_tolerance
	
	var number_of_rays: int = 6
	
	var scan_results := RayCaster.cast_vertical_row(self, source_position, normal_float, direction, ray_length, minimum_y, maximum_y, number_of_rays )
	
	# Then evaluate the scan results.
	
	DebugShapes.hide_green_spheres()
	
	# If all results have the same xz, it's a flat surface
	
	# TODO: For this we need the length of the ray cast
	
	# if a ray is shorter than the others, we know there's a ledge.
	
		# then do the *get edge fom collision point* on it and validate the point
		
	
	var shortest_result: Dictionary = {"length": ray_length}
	
	var out: Dictionary = {}
	
	for result in scan_results:
		if not result.is_empty():
			if result["length"] < shortest_result["length"]:
				shortest_result = result
			#DebugShapes.place_a_green_sphere(result["position"])
	
	if shortest_result.has("position"):
		pass
		#DebugShapes.place_the_blue_sphere(shortest_result["position"])
		
		out = get_edge_from_collision_point(shortest_result["position"], y_tolerance)
		
		#if not out.is_empty():
			#DebugShapes.place_the_red_sphere(out["position"])


	return out

func compare_float(float0: float, float1: float, epsilon: float) -> bool:
	
	# We could do it like this:
	is_equal_approx(float0, float1)
	
	return abs(float0 - float1) < epsilon
	

## Checks if the given detected point is a valid edge point the player could hang on
## with the grappling hook.
func validate_evaluated_as_valid_edge_point(result: Dictionary):
	if result.is_empty():
		is_detected_platform_point_valid = false

	var is_valid_edge_point = compare_float(result["normal"].y, 0.0, 0.1)
	
	is_detected_platform_point_valid = is_valid_edge_point
	
## TODO: Will take an edge point and check if something is between the player and the edge point, making it invalid.
## Used when in the current frame no new edge point is found, so it will validate the last.
func validate_evaluated_as_from_player(result: Vector3):
	
	# first, check how far the distance between the evaluated point and the camera is.
	
	var distance_between_camera_and_point = (result - camera.global_position).length()
	
	# Then check if something is between the player and the edge
	
	var result_between := RayCaster.cast_ray(self, camera.global_position, result, false)
	
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
	
	var is_valid_edge_point = compare_float(result["normal"].y, 0.0, 0.1)
	
	# first, check how far the distance between the evaluated point and the camera is.
	
	var distance_between_camera_and_point = (result["position"] - camera.global_position).length()
	
	# Then check if something is between the player and the edge
	
	var result_between := RayCaster.cast_ray(self, camera.global_position, result["position"], false)
	
	
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
			var roof := RayCaster.cast_ray(self, star_cast_hit_result["position"] + Vector3(0.0, 0.01, 0.0), star_cast_hit_result["position"] + Vector3.UP * 10.0, false)
			
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
	

## Most basic function that will return the ledge that is within the y tolerance above the given point. 
func get_edge_from_collision_point(collision_point: Vector3, y_tolerance: float) -> Dictionary:
	
	
	# First get the total height of the object that was collided with.
	var platform_roof := RayCaster.cast_ray_down(self, Vector3(collision_point.x, collision_point.y + y_tolerance, collision_point.z), y_tolerance + 0.1, false)
	
	if platform_roof.is_empty():
		return {}
	
	# Then cast a ray from the players xz position to the roof point. It will hit the edge.
	var platform_edge := RayCaster.cast_ray(self, Vector3(camera.global_position.x, platform_roof["position"].y, camera.global_position.z ), platform_roof["position"], false)
	
	return platform_edge

#endregion HELPER FUNCTIONS

#region TEST FUNCTIONS

func test_cast_forward():
	
	var result := RayCaster.cast_forward(self, camera, 10.0)
	
	if not result.is_empty():
		DebugShapes.place_the_blue_sphere(result["position"])
	else:
		DebugShapes.hide_the_blue_sphere()
	
	
	
	
	
	
	
	
	pass


#endregion TEST FUNCTIONS
