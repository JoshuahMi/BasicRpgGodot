extends Node3D

@onready var debug_mesh: MeshInstance3D = $DebugMesh

@export var camera: Camera3D

@export var debug_box: bool = true
@export var platform_detection_distance: float = 100.0

## Used to determine how big the radius shall be to detect ledges on a wall
@export var star_cast_distance: float = 1.0

var detected_platform_point: Vector3 = Vector3.ZERO
var is_platform_detected: bool = false

var edge_point: Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	# first, detect the platform
	#detect_platform()
	detect_ledge()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	

## TODO: The more sophisticated version of the detection function
func detect_ledge():
	
	# first, get the wall collision position. 
	# if the normals absolute y value is above a certain value, the ledge position isn't valid.
	# search for a better wall collision point then.
	var cast_0 := cast_forward()
	
	# then check if around the collision point is a ledge.
	# use the normal of the wall to float above the wall and cast rays left and right, as well as up and down.
	
	if cast_0.is_empty():
		return
	
	var ledge_around_point: Dictionary = cast_star(cast_0["position"], cast_0["normal"], star_cast_distance)
	
	
	# then, IF a ledge is found, get the edge of it
	
	var result: Dictionary = {}
	
	if not ledge_around_point.is_empty():
		
		result = get_ledge_from_star_cast(ledge_around_point, 10.0)
		
		if not result.is_empty():
			pass
			#debug_place_box(result["position"])
		
		
		pass
		
	# If no ledge is found, simply get the roof ledge
	else:
		result = get_ledge_from_collision_point(cast_0["position"], 10.0)
		pass
	
	#region DEBUG
	
	if not result.is_empty():
		debug_place_box(result["position"])
	else:
		pass
		#debug_hide_box()
	
	#endregion DEBUG


## Detects a platform edge in a very basic way. 
func detect_platform():
	
	# First, let the player cast a ray to a world object:
	var cast_0 := cast_forward()
	
	if cast_0.is_empty():
		return
		
	var edge = get_ledge_from_collision_point(cast_0["position"], 10.0)
	
	if edge.is_empty():
		debug_hide_box()
		return
	else:
		set_ledge_position(edge["position"])
		debug_place_box(edge["position"])
		return
		
	


func detect_platform_simple():
	
	# First, let the player cast a ray to a world object:
	var cast_0 = cast_ray_from_player(%PlatformDetector.global_position, false) 
	
	if cast_0.is_empty():
		return
		
	var platform_roof := cast_ray_down(Vector3(cast_0["position"].x, cast_0["position"].y + 10.0, cast_0["position"].z), 20.0, false)
	
	if platform_roof.is_empty():
		return

	var platform_edge := cast_ray(Vector3(global_position.x, platform_roof["position"].y, global_position.z ), platform_roof["position"], false)
	
	if platform_edge.is_empty():
		is_platform_detected = false
		pass
	else:
		
		detected_platform_point = platform_edge["position"]
		is_platform_detected = true
		pass
		
	
	return
	
#region HELPER FUNCTIONS

func set_ledge_position(pos: Vector3):
	
	debug_place_box(pos)
	detected_platform_point = pos

## casts a ray from a given point downwards (-y) by a given distance
func cast_ray_down(start: Vector3, distance: float, shall_hit_from_inside: bool) -> Dictionary:
	
	return cast_ray(start, start + Vector3.DOWN * distance, shall_hit_from_inside)

## casts a ray from a given point upwards (+y) by a given distance
func cast_ray_up(start: Vector3, distance: float, shall_hit_from_inside: bool) -> Dictionary:
	
	return cast_ray(start, start + Vector3.UP * distance, shall_hit_from_inside)
	
## Casts a ray from the player xz position that completely stays on the xz plane, so the targets y value gets discarded and the given y argument5 is used
func cast_ray_from_player_xz(y: float, target: Vector3, shall_hit_from_inside: bool) -> Dictionary:
	
	return cast_ray(Vector3(global_position.x, y, global_position.z), Vector3(target.x, y, target.z), shall_hit_from_inside)
	
func cast_ray_from_player(target: Vector3, shall_hit_from_inside: bool) -> Dictionary:
	
	return cast_ray(global_position, target, shall_hit_from_inside)

## Casts a ray based on this nodes 3D world and returns the result
func cast_ray(start: Vector3, target: Vector3, shall_hit_from_inside: bool) -> Dictionary:
	
	var query := PhysicsRayQueryParameters3D.create(start, target)
	
	# query.hit_back_faces = shall_hit_from_inside
	query.hit_from_inside = shall_hit_from_inside
	
	var space_state = get_world_3d().direct_space_state
	var result : Dictionary = {}
	result = space_state.intersect_ray(query)
	
	return result


func cast_forward() -> Dictionary:
	
	return cast_ray_from_player(%PlatformDetector.global_position, false) 

## Will cast a star shaped series of casts around the start with the given radius
## And return the hit result that is nearest to the start.
func cast_star(start: Vector3, normal: Vector3, radius: float) -> Dictionary:
	
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
	
	var up_result: Dictionary = cast_ray(start_floating, start_floating + Vector3.UP * radius, false)
	var down_result: Dictionary = cast_ray(start_floating, start_floating + Vector3.DOWN * radius, false)
	var right_result: Dictionary = cast_ray(start_floating, start_floating + right * radius, false)
	var left_result: Dictionary = cast_ray(start_floating, start_floating + left * radius, false)
	
	var right_up_result: Dictionary = cast_ray(start_floating, start_floating + right_up * radius, false)
	var right_down_result: Dictionary = cast_ray(start_floating, start_floating + right_down * radius, false)
	var left_up_result: Dictionary = cast_ray(start_floating, start_floating + left_up * radius, false)
	var left_down_result: Dictionary = cast_ray(start_floating, start_floating + left_down * radius, false)
	
	
	
	#region DEBUG
	
	#if not left_result.is_empty():
		#debug_place_box(left_result["position"])
	#else:
		#debug_hide_box()
	#
	#endregion DEBUG
	
	
	
	
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


## Will get the ledge edge that was detected by a star cast
func get_ledge_from_star_cast(star_cast_hit_result: Dictionary, distance: float) -> Dictionary:
	
	if star_cast_hit_result.is_empty():
		return {}
	
	var edge: Dictionary = {}
	
	# the normal points upward or downward if the absolute y value is more than 0.9
	if abs(star_cast_hit_result["normal"].y) > 0.9:
		
		#if it points upward
		if star_cast_hit_result["normal"].y > 0.0:
			
			edge = cast_ray(star_cast_hit_result["position"], star_cast_hit_result["position"] + star_cast_hit_result["normal"] * 10.0, true)
			
			
			
			return edge
		
		# ...or if it points downward
		else:
			
			
			# first, get the height of the ledge
			# BUG: In this line is the problem.
			var roof := cast_ray(star_cast_hit_result["position"] + Vector3(0.0, 0.01, 0.0), star_cast_hit_result["position"] + Vector3.UP * 10.0, false)
			
			if roof.is_empty():
				
				roof = cast_ray(star_cast_hit_result["position"] + Vector3(0.0, 10.0, 0.0), star_cast_hit_result["position"] + Vector3.DOWN * 10.0, false)
				
			else:
				
				roof = cast_ray(roof["position"], roof["position"] + Vector3.DOWN, false)
				
				
				
			if roof.is_empty():
				return {}
			
			# then get the edge
			
			edge = cast_ray_from_player_xz(roof["position"].y, roof["position"], false)
			
			if not edge.is_empty():
				pass
				#debug_place_box(edge["position"])
			
			return edge
			
		## The normal points to the side if the y value is 0.0
	elif abs(star_cast_hit_result["normal"].y) < 0.1:
		
		edge = cast_ray(star_cast_hit_result["position"], star_cast_hit_result["position"] + Vector3.UP * 10.0, true)

	else:
		return {}
	
	
	return {}


## Most basic function that will return the ledge that is within the y tolerance above the given point. 
func get_ledge_from_collision_point(collision_point: Vector3, y_tolerance: float) -> Dictionary:
	
	var platform_roof := cast_ray_down(Vector3(collision_point.x, collision_point.y + y_tolerance, collision_point.z), y_tolerance + 0.1, false)
	
	if platform_roof.is_empty():
		return {}

	var platform_edge := cast_ray(Vector3(global_position.x, platform_roof["position"].y, global_position.z ), platform_roof["position"], false)
	
	return platform_edge
	





func debug_place_box(target: Vector3):
	
	if debug_box:
	
		debug_mesh.visible = true
		
	else:
		debug_mesh.visible = false
	debug_mesh.global_position = target
	pass
	
func debug_hide_box():
	debug_mesh.visible = false


#endregion HELPER FUNCTIONS
