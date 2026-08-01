extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## Simply compares to floats and returns if the difference between the two is below the epsilon value.
## Use this to determine if two floats are approximately equal.
func equal_float(float_a: float, float_b: float, epsilon: float) -> bool:
	
	return abs(float_a - float_b) < epsilon

## Useless. Use *Vector3.direction_to*
func make_normal_as_pointing_towards_player(point: Vector3, player_position: Vector3) -> Vector3:
	
	return point.direction_to(player_position)

# TODO
#func get_up_vector_of_node(object: Node3D) -> Vector3:
	#
	#return Vector3.UP
	
	
	
func get_forward_vector_of_node(object: Node3D) -> Vector3:
	
	# Get the given object and takes its rotation to make a vector to point at.
	
	var direction_y_rotated: Vector3 = Vector3.FORWARD.rotated(Vector3.UP, object.global_rotation.y)
	
	# Rotate the x-axis, because the vector has to be rotated on the x-axis too.
	var x_axis: Vector3 = Vector3.RIGHT.rotated(Vector3.UP, object.global_rotation.y)

	var direction_x_rotated: Vector3 = direction_y_rotated.rotated(x_axis, object.global_rotation.x)
	
	var direction: Vector3 = (direction_x_rotated).normalized()
	
	return direction
