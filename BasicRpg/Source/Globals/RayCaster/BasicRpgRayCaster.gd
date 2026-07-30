class_name BasicRpgRayCaster extends Node3D

## The class of the surface the vertical row cast has scanned. Will be output and can be used by the Grappling Hook Edge Detector to decide which strategy it will use to detect edges
enum SurfaceClass {
	
	FLAT,	## If the y value of all normals is equal to zero
	HILLY,	## if there are y normals, but the overall y value is near zero
	POINTING_DOWNWARD, ## if the sum of the y normals is clearly negative
	POINTING_UPWARD, ## if the sum of the y normals is clearly positive
	
	
	
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass



## casts a ray from a given point downwards (-y) by a given distance
func cast_ray_down(node_this_was_called_from: Node3D, start: Vector3, distance: float, shall_hit_from_inside: bool) -> Dictionary:
	
	return cast_ray(node_this_was_called_from, start, start + Vector3.DOWN * distance, shall_hit_from_inside)

## casts a ray from a given point upwards (+y) by a given distance
func cast_ray_up(node_this_was_called_from: Node3D, start: Vector3, distance: float, shall_hit_from_inside: bool) -> Dictionary:
	
	return cast_ray(node_this_was_called_from, start, start + Vector3.UP * distance, shall_hit_from_inside)

## Here the node that the space state is taken from and the object that the ray is shot from is identical.
## Casts a ray from the node xz position that completely stays on the xz plane, so the targets y value gets discarded and the given y argument is used
func cast_ray_from_node_xz(node_this_was_called_from: Node3D, y: float, target: Vector3, shall_hit_from_inside: bool) -> Dictionary:
	
	return cast_ray(node_this_was_called_from, Vector3(global_position.x, y, global_position.z), Vector3(target.x, y, target.z), shall_hit_from_inside)

## Here the node that the space state is taken from and the object that the ray is shot from is identical.
func cast_ray_from_node(node_this_was_called_from: Node3D, target: Vector3, shall_hit_from_inside: bool) -> Dictionary:
	
	return cast_ray(node_this_was_called_from, node_this_was_called_from.global_position, target, shall_hit_from_inside)

## Casts a ray based on this nodes 3D world and returns the result
func cast_ray(node_this_was_called_from: Node3D, start: Vector3, target: Vector3, shall_hit_from_inside: bool) -> Dictionary:
	
	var query := PhysicsRayQueryParameters3D.create(start, target)
	
	query.hit_from_inside = shall_hit_from_inside
	
	var space_state = node_this_was_called_from.get_world_3d().direct_space_state
	
	# TODO: add a "length" 
	
	var result = space_state.intersect_ray(query)
	
	if not result.is_empty():
		result["length"] = (result["position"] - start).length()
	
	return result
	
## Will cast a ray forward, from the given *object*, taking its rotation into account. Will cast a ray as long as *cast distance*
func cast_forward(node_this_was_called_from: Node3D, object: Node3D, cast_distance: float) -> Dictionary:
	
	# Get the given object and takes its rotation to make a vector to point at.
	
	var direction_y_rotated: Vector3 = Vector3.FORWARD.rotated(Vector3.UP, object.global_rotation.y)
	
	# Rotate the x-axis, because the vector has to be rotated on the x-axis too.
	var x_axis: Vector3 = Vector3.RIGHT.rotated(Vector3.UP, object.global_rotation.y)

	var direction_x_rotated: Vector3 = direction_y_rotated.rotated(x_axis, object.global_rotation.x)
	
	var direction: Vector3 = (direction_x_rotated).normalized()
	
	var direction_scaled = direction * cast_distance
	
	return cast_ray(node_this_was_called_from, object.global_position, object.global_position + direction_scaled, false)



## Will cast a star shaped series of casts around the start with the given radius
## And return the hit result that is nearest to the start.
func cast_star(node_this_was_called_from: Node3D, start: Vector3, normal: Vector3, radius: float) -> Dictionary:
	
	if abs(normal.y) > 0.05:
		return {}
	
	const  FLOATING_DISTANCE = 0.1
	
	# Correct the normal by taking its y value out.
	var normal_corrected: Vector3 = Vector3(normal.x, 0.0, normal.z).normalized()
	
	# Then make the start float above the surface by using the corrected normal
	var start_floating: Vector3 = start + normal_corrected * FLOATING_DISTANCE
	
	# First, get the right and left vectors, depending on the given normal.
	var right: Vector3 = Vector3.UP.rotated(normal_corrected, -90.0)
	
	var left: Vector3 = Vector3.UP.rotated(normal_corrected, 90.0)
	
	#print(left)
	
	# then get the X - shaped vectors
	
	var right_up = Vector3.UP.rotated(normal_corrected, -45.0)
	var right_down = Vector3.UP.rotated(normal_corrected, -135.0)
	var left_up = Vector3.UP.rotated(normal_corrected, 45.0)
	var left_down = Vector3.UP.rotated(normal_corrected, 135.0)
	
	# then cast rays to the left, right, up and down.
	
	var up_result: Dictionary = cast_ray(node_this_was_called_from, start_floating, start_floating + Vector3.UP * radius, false)
	var down_result: Dictionary = cast_ray(node_this_was_called_from, start_floating, start_floating + Vector3.DOWN * radius, false)
	var right_result: Dictionary = cast_ray(node_this_was_called_from, start_floating, start_floating + right * radius, false)
	var left_result: Dictionary = cast_ray(node_this_was_called_from, start_floating, start_floating + left * radius, false)
	
	var right_up_result: Dictionary = cast_ray(node_this_was_called_from, start_floating, start_floating + right_up * radius, false)
	var right_down_result: Dictionary = cast_ray(node_this_was_called_from, start_floating, start_floating + right_down * radius, false)
	var left_up_result: Dictionary = cast_ray(node_this_was_called_from, start_floating, start_floating + left_up * radius, false)
	var left_down_result: Dictionary = cast_ray(node_this_was_called_from, start_floating, start_floating + left_down * radius, false)
	
	# then determine what is the nearest result to the starting point 
	
	var results: Array[Dictionary] = [up_result, down_result, right_result, left_result, right_up_result, right_down_result, left_up_result, left_down_result]
	
	var nearest_result = up_result
	
	for result in results:
		
		if nearest_result.is_empty():
			nearest_result = result
			continue
		
		if result.is_empty():
			continue
		
		if not nearest_result.is_empty():
			if (result["position"] - start_floating).length_squared() < (nearest_result["position"] - start_floating).length_squared():
				nearest_result = result
	
	return nearest_result


## Will cast a series of horizonzal rays in a specific direction between a minimum and a maximum height.
## The hit result array will be ordered by height from the lowest to the highest.
## Will take a hit result as *start point xz* input.
## The start of the rays will be above the normal that the *start point xz* is providing, by the *normal float* value.
func cast_vertical_row(node_this_was_called_from: Node3D, start_point_xz: Dictionary, normal_float: float, direction_xz: Vector3, ray_length: float, minimum_y: float, maximum_y: float, number_of_rays: int) -> Dictionary:
	
	DebugShapes.hide_all()
	
	if start_point_xz.is_empty():
		return {}
	
	# The output Dictionary that will be returned later
	var out: Dictionary = {}
	
	# The Array that contains all the hit results:
	var out_hit_results: Array[Dictionary] = []
	
	out_hit_results.append(start_point_xz)
	
	# First, get the y range, so the frame of the rays to be cast in
	
	var y_frame: float = abs(minimum_y - maximum_y)
	
	# Then get the height interval in which the rays shall be cast in
	var y_interval : float = y_frame / number_of_rays
	
	# Scale the direction vector to the ray length, so it can be used to determine the 
	var direction_xz_scaled = Vector3(direction_xz.x, 0.0, direction_xz.z).normalized() * ray_length
	
	DebugShapes.hide_blue_spheres()
	
	# Then cast the rays
	for index in range(1, number_of_rays + 1):
		
		var height: float = minimum_y + y_interval * index
		var start: Vector3 = Vector3(start_point_xz["position"].x, height, start_point_xz["position"].z) + Vector3(start_point_xz["normal"].x, 0.0, start_point_xz["normal"].z).normalized() * normal_float
		
		# DebugShapes.place_a_blue_sphere(start)
		
		var target: Vector3 = start + Vector3(direction_xz_scaled.x, 0.0, direction_xz_scaled.z)
		
		var hit_result = cast_ray(node_this_was_called_from, start, target, false)
		
		#if not hit_result.is_empty():
			#DebugShapes.place_a_blue_sphere(hit_result["position"])
		
		out_hit_results.append(hit_result)
		
	
	# Put the hit results into the output Dictionary
	out["hit_results"] = out_hit_results
	
	# ----------------- INTERPRETATION OF THE RESULTS --------------------------------
	
	# If all results have the same xz, it's a flat surface
	
	var is_flat_surface = true
	
	# Now check, which of the hit results is the shortest (and highest of the shortest, if 2 have the same length)
	
	var shortest_result: Dictionary = {"length": ray_length}
	
	# The sum of all y normals. Will be used to classify the surface this vertical row of casts has scanned.
	var relative_y: float = 0.0
	
	
	for result in out_hit_results:
		if not result.is_empty():
			
			#DebugShapes.place_a_blue_sphere(result["position"])
			
			# if a result has a different x or z than the starting point, the vertical row cast is obviously not scanning a perfectly flat surface.
			
			var is_x_equal : bool = Math.equal_float(result["position"].x, start_point_xz["position"].x, 0.1)
			var is_z_equal : bool = Math.equal_float(result["position"].z, start_point_xz["position"].z, 0.1)
			
			# Add the results y component of it's normal to the total relative y normal to be able to determine the surface's structure
			relative_y += result["normal"].y
			
			if !is_x_equal or !is_z_equal:
				
				is_flat_surface = false
			
			if result["length"] <= shortest_result["length"]:
				shortest_result = result
		# If one hit result is empty, it went beyond the surface, so not all hit results share the same xz
		else:
			# print("From RayCaster: Result is empty.")
			is_flat_surface = false
			
	
	if shortest_result.has("position"):
		pass
		#DebugShapes.place_the_green_sphere(shortest_result["position"])
	
	
	
	# Then check where the "breakpoint" is in the hit results, i.e. the two hit results that are the highest shortest, and the one above it.
	# Used by the grappling hook edge detector to determine in which area the ledge approximately is.
	# Obviously it can be valid if the result above the highest shortest is empty. Then it simply shot beyond the surface
	
	var breakpoint_in_hit_results: Dictionary = {"result" : {}, "y_frame" : y_interval}
	
	if shortest_result.has("position"):
		
		var is_the_shortest_the_highest = Math.equal_float(shortest_result["position"].y, start_point_xz["position"].y + y_frame, 0.05)
		
	# What if the Highest shortest actually IS the highest?
	# Then there is no ledge. 
	# Make it so that it is possible to do a second vertical row cast easily from the format this specific output provides.
		if !is_the_shortest_the_highest:
			# If it's the highest, there is no breakpoint. 
			# if not, make the shortest result the breakpoint
			breakpoint_in_hit_results["result"] = shortest_result
			#print("From RayCaster: The shortest highest is NOT the highest!!")
			pass
		else:
			#print("From RayCaster: The shortest highest is also the highest of all.")
			pass
			
	
	# Evaluate the relative y
	
	if Math.equal_float(relative_y, 0.0, 0.05):
		
		out["surface_structure"] = SurfaceClass.FLAT
		#print("From Ray Caster: Flat surface")
	
	elif Math.equal_float(relative_y, 0.0, 0.2):
		out["surface_structure"] = SurfaceClass.HILLY
		#print("From Ray Caster: Hilly surface")
	elif relative_y > 0.0:
		out["surface_structure"] = SurfaceClass.POINTING_UPWARD
		#print("From Ray Caster: Surface is pointing upwards")
	else:
		out["surface_structure"] = SurfaceClass.POINTING_DOWNWARD
		#print("From Ray Caster: Surface is pointing downwards")
		
	out["breakpoint"] = breakpoint_in_hit_results
	out["shortest"] = shortest_result
	
	
	return out
	
