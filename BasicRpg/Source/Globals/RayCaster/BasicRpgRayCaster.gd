extends Node3D


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
	
	return space_state.intersect_ray(query)
	
## Will cast a ray forward, from the given *object*, taking its rotation into account. Will cast a ray as long as *cast distance*
func cast_forward(node_this_was_called_from: Node3D, object: Node3D, cast_distance: float) -> Dictionary:
	
	# Get the given object and takes its rotation to make a vector to point at.
	
	var distant_point: Vector3 = Vector3.FORWARD.rotated(Vector3.UP, object.rotation.y)
	var distant_point_0: Vector3 = Vector3.FORWARD.rotated(Vector3.LEFT, object.rotation.x)
	
	var direction: Vector3 = (distant_point + distant_point_0).normalized()
	
	direction *= cast_distance
	
	return cast_ray(node_this_was_called_from, object.global_position, object.global_position + direction, false)



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
