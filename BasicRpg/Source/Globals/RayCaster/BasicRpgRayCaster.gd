class_name BasicRpgRayCaster extends Node3D

func cast_ray(node_this_was_called_from: Node3D, start: Vector3, target: Vector3, shall_hit_from_inside: bool) -> BasicRpgHitResult:
	
	var out: BasicRpgHitResult = BasicRpgHitResult.new()
	
	out.original_ray_begin = start
	out.original_ray_target = target
	out.original_ray_direction = (target - start).normalized()
	out.original_ray_length = (start - target).length()
	
	var query := PhysicsRayQueryParameters3D.create(start, target)
	
	query.hit_from_inside = shall_hit_from_inside
	
	var space_state = node_this_was_called_from.get_world_3d().direct_space_state
	
	var result = space_state.intersect_ray(query)
	
	if result.has("position") and result.has("normal"):
		out.valid = true
		out.length = result["position"].distance_to(start)
		#out.length = (result["position"] - start).length()
		out.position = result["position"]
		out.normal = result["normal"]
	else:
		
		## This is a convention of mine, that invalid hit results have a length of 100,
		## indicating that they went "into nothingness"
		out.length = 100.0
		out.valid = false
	
	return out
	
## casts a ray from a given point downwards (-y) by a given distance
func cast_ray_down(node_this_was_called_from: Node3D, start: Vector3, distance: float, shall_hit_from_inside: bool) -> BasicRpgHitResult:
	
	return cast_ray(node_this_was_called_from, start, start + Vector3.DOWN * distance, shall_hit_from_inside)

## casts a ray from a given point upwards (+y) by a given distance
func cast_ray_up(node_this_was_called_from: Node3D, start: Vector3, distance: float, shall_hit_from_inside: bool) -> BasicRpgHitResult:
	
	var result := cast_ray(node_this_was_called_from, start, start + Vector3.UP * distance, shall_hit_from_inside)
	
	return result

## Here the node that the space state is taken from and the object that the ray is shot from is identical.
## Casts a ray from the node xz position that completely stays on the xz plane, so the targets y value gets discarded and the given y argument is used
func cast_ray_from_node_xz(node_this_was_called_from: Node3D, y: float, target: Vector3, shall_hit_from_inside: bool) -> BasicRpgHitResult:
	
	return cast_ray(node_this_was_called_from, Vector3(global_position.x, y, global_position.z), Vector3(target.x, y, target.z), shall_hit_from_inside)

## Here the node that the space state is taken from and the object that the ray is shot from is identical.
func cast_ray_from_node(node_this_was_called_from: Node3D, target: Vector3, shall_hit_from_inside: bool) -> BasicRpgHitResult:
	
	return cast_ray(node_this_was_called_from, node_this_was_called_from.global_position, target, shall_hit_from_inside)
	
## Will cast a ray forward, from the given *object*, taking its rotation into account. Will cast a ray as long as *cast distance*
func cast_forward(node_this_was_called_from: Node3D, object: Node3D, cast_distance: float) -> BasicRpgHitResult:
	
	# Get the given object and takes its rotation to make a vector to point at.
	
	var direction_y_rotated: Vector3 = Vector3.FORWARD.rotated(Vector3.UP, object.global_rotation.y)
	
	# Rotate the x-axis, because the vector has to be rotated on the x-axis too.
	var x_axis: Vector3 = Vector3.RIGHT.rotated(Vector3.UP, object.global_rotation.y)

	var direction_x_rotated: Vector3 = direction_y_rotated.rotated(x_axis, object.global_rotation.x)
	
	var direction: Vector3 = (direction_x_rotated).normalized()
	
	var direction_scaled = direction * cast_distance
	
	return cast_ray(node_this_was_called_from, object.global_position, object.global_position + direction_scaled, false)

	
## General purpose function.
## Will cast a row of rays between a starting point and an end point.
func cast_row(node_this_was_called_from: Node3D, start_point: Vector3, end_point: Vector3, direction: Vector3, number_of_rays: int, ray_length: float, shall_cast_ray_from_end_too: bool) -> Array[BasicRpgHitResult]:
	
	var out: Array[BasicRpgHitResult] = []
	
	var start_point_direction: Vector3 = start_point.direction_to(end_point)
	var interval: float = (start_point - end_point).length() / float(number_of_rays)

	# *i* will have the values 0 to *number of rays* - 1
	# This will not shoot a ray from the actual end point
	for i in number_of_rays:
		
		var cast_start: Vector3 = start_point + start_point_direction * i * interval
		var cast_end: Vector3 = cast_start + direction * ray_length
		var result: BasicRpgHitResult = cast_ray(node_this_was_called_from, cast_start, cast_end, false)
	
		out.append(result)
	
	# This will actually shoot a ray from the end point, so the whole row has *number of rays + 1* rays, IF the bool was set to true
	if shall_cast_ray_from_end_too:
		
		var cast_start: Vector3 = end_point
		var cast_end: Vector3 = end_point + direction * ray_length
		var result: BasicRpgHitResult = cast_ray(node_this_was_called_from, cast_start, cast_end, false)
		
		out.append(result)
		

	return out
