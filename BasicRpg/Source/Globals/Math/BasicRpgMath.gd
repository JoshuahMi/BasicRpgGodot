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
	
