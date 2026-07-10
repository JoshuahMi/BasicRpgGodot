class_name BasicRpgMovementComponentNew extends Node

# For the prototype I will just focus on the states and the functionality of the core functions.
# 




#region REFERENCES

@export_category("References")
@export var body: CharacterBody3D
@export var model: MeshInstance3D
@export var camera: Camera3D

#endregion REFERENCES

#region INPUT

## INPUT
## Will be set by the class using the component. This will determine the direction the component will let the instance move.
## Used by the move() function.
var movement_direction: Vector2 = Vector2.ZERO:
	set(new_value):
		if new_value == movement_direction:
			movement_direction = new_value	
		else:
			movement_direction = new_value

## INPUT
## This is set by the object that is using this component. Will tell this component that it wants to sprint by setting it to true.
var wants_to_sprint: bool = false
			
## INPUT
## This is set by the object that is using this component. Will tell this component that it wants to jump by setting this variable to true.
## Will only be performed as a normal jump then if is_normal_movement_possible is true
var wants_to_jump: bool = false:
	set(new_value):
		wants_to_jump = new_value
		if new_value == true:
			jump()
			wants_to_jump = false	

## INPUT
## This is set by the object that is using this component. Will tell this component that it wants to dash by setting this variable to true.
var wants_to_dash: bool = false:
	set(new_value):
		wants_to_dash = new_value
		if new_value == true:
			dash()
			wants_to_dash = false



#endregion INPUT

#region STATE

var movement_place_state: BasicRpgGeneral.MovementPlaceState = BasicRpgGeneral.MovementPlaceState.GROUND
var movement_effort_state: BasicRpgGeneral.MovementEffortState = BasicRpgGeneral.MovementEffortState.IDLE

#endregion STATE

#region SIGNALS

#endregion SIGNALS

#region VARIABLES

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity_local = ProjectSettings.get_setting("physics/3d/default_gravity")

#endregion VARIABLES

#region PARAMETER

const MOVEMENT_ACCELERATION: float = 1000.0

@export var movement_speed: float = 300.0

@export var jump_strength: float = 150.0

@export var dash_strength: float = 150.0

@export var mouse_sensitivity: float = 1.0

#endregion PARAMETER

#region BUILTIN FUNCTIONS

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	apply_gravity(delta)
	
	pass
	
#endregion BUILTIN FUNCTIONS

#region CORE FUNCTIONS

# The core functions basically determine the behaviour of the mirroring "perform" functions.
# Judging from the state there may be slight differences in behaviour.
# So the core functions look up the state and define the behaviour of their wrapped functions.

func look(look_up: float, look_right: float):
	perform_look(look_up, look_right)
	
func move(delta: float):
	perform_move(delta)
	pass
	
func jump():
	perform_jump(jump_strength)
	pass

func dash():
	perform_dash()
	pass

func knockback(direction: Vector3, directional_strength: float, in_jump_strength: float):
	perform_knockback(direction, directional_strength, in_jump_strength)
	pass
	

#endregion CORE FUNCTIONS

#region PERFORMING FUNCTIONS

func perform_look(look_up: float, look_right: float):
	
	camera.rotation.x += (look_up * -1.0 * mouse_sensitivity * 0.01)
	camera.rotation.x  = clampf(camera.rotation.x, -1.5, 1.5)
	camera.rotation.y += (look_right * -1.0 * mouse_sensitivity * 0.01)
	
func perform_move(delta: float):
	
	var movement_speed_local = movement_speed

	# first determine the rotation of the movement vector
	# it shall point towards the direction the camera is facing
	var y_rotation = camera.rotation.y
	
	var direction_local: Vector3 = Vector3(movement_direction.x, 0.0, movement_direction.y)
	
	direction_local = direction_local.rotated(Vector3.UP, y_rotation)
	
	# make velocity local, to interpolate it afterwards to implement the movement strength in the air
	var velocity_local = body.velocity
	
	# here it can just use "move toward" directily on the velocity
	body.velocity.x = move_toward(body.velocity.x, direction_local.x * movement_speed_local, MOVEMENT_ACCELERATION * delta)
	body.velocity.z = move_toward(body.velocity.z, direction_local.z * movement_speed_local, MOVEMENT_ACCELERATION * delta)
	
	
	pass
	
func perform_jump(in_jump_strength: float):
	
	body.velocity.y += in_jump_strength 
	
	pass

func perform_dash():
	
	var direction: Vector3 = Vector3.FORWARD.rotated(Vector3.UP, camera.rotation.y)
		
	body.velocity += direction.normalized() * dash_strength


func perform_knockback(direction: Vector3, directional_strength: float, in_jump_strength: float):
	
	body.velocity.y += in_jump_strength 

	var direction_planar = Vector3(direction.x, 0.0, direction.z)
	direction_planar = direction_planar.normalized()

	body.velocity += direction_planar * directional_strength
	

#endregion PERFORMING FUNCTIONS

#region HELPER FUNCTIONS 

## Used in _process. Will, depending on the state, apply the gravity.
func apply_gravity(delta: float):
	
	match movement_place_state:
		BasicRpgGeneral.MovementPlaceState.GROUND:
			# Don't apply gravity when on the ground.
			pass
		BasicRpgGeneral.MovementPlaceState.AIR:
			# When in the air, apply normal gravity.
			body.velocity.y -= gravity_local * delta
			pass
		BasicRpgGeneral.MovementPlaceState.WALL:
			# At first, don't apply gravity. Then over time, add more and more, until the applied gravity matches gravity_local.
			pass
		BasicRpgGeneral.MovementPlaceState.SWIMMING:
			# Don't apply gravity
			pass
		BasicRpgGeneral.MovementPlaceState.UNDERWATER:
			# Don't apply gravity
			pass
	
	
	
	
	
	pass



#endregion HELPER FUNCTIONS
