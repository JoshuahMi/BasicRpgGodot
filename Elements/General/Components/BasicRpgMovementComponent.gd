class_name BasicRpgMovementComponent extends Node

## This Movement Component is made up from "Core Functions", called after their respective booleans are set to true from outside the component,
## "helper Functions", which help the core functions work, and builtin functions, which take care of the validity of values.
## The behaviour of the core functions is dependant on "States", defined in BasicRpgGeneral. 

@export_category("References")
@export var body: CharacterBody3D
@export var model: MeshInstance3D
@export var camera: Camera3D


#region Signals
signal state_changed(new_state: BasicRpgGeneral.PlayerMovementStates)
#endregion Signals

#region Current State

## THE CURRENT STATE
## used to determine the behaviour of the core functions.
## Use the setter to implement functionality that is specific to entering and exiting a specific state.
var current_state: BasicRpgGeneral.PlayerMovementStates = BasicRpgGeneral.PlayerMovementStates.ON_FLOOR_IDLE:
	set(new_value):
		if new_value != current_state:
			## Implement all state specific exiting logic here!
			match current_state:
				BasicRpgGeneral.PlayerMovementStates.ON_FLOOR_IDLE:
					pass
				BasicRpgGeneral.PlayerMovementStates.ON_FLOOR_MOVEMENT_NORMAL:
					pass
				BasicRpgGeneral.PlayerMovementStates.ON_FLOOR_MOVEMENT_SPRINTING:
					pass
				BasicRpgGeneral.PlayerMovementStates.IN_AIR_FROM_JUMP:
					pass
				BasicRpgGeneral.PlayerMovementStates.IN_AIR_FROM_KNOCKBACK:
					pass
				BasicRpgGeneral.PlayerMovementStates.IN_AIR_FROM_FALLING:
					pass
				BasicRpgGeneral.PlayerMovementStates.IN_AIR_WHILE_DASH:
					pass
			
			## implement all state specific entering logic here!
			match new_value:
				BasicRpgGeneral.PlayerMovementStates.ON_FLOOR_IDLE:
					pass
				BasicRpgGeneral.PlayerMovementStates.ON_FLOOR_MOVEMENT_NORMAL:
					pass
				BasicRpgGeneral.PlayerMovementStates.ON_FLOOR_MOVEMENT_SPRINTING:
					pass
				BasicRpgGeneral.PlayerMovementStates.IN_AIR_FROM_JUMP:
					pass
				BasicRpgGeneral.PlayerMovementStates.IN_AIR_FROM_KNOCKBACK:
					pass
				BasicRpgGeneral.PlayerMovementStates.IN_AIR_FROM_FALLING:
					pass
				BasicRpgGeneral.PlayerMovementStates.IN_AIR_WHILE_DASH:
					pass
				
			current_state = new_value
			state_changed.emit(new_value)
		else:
			current_state = new_value

#endregion Current State



#region State determining Variables

# These Variables determine the state. We distinguish between input from the player or other controller
# and things that just happen. 

## If true, can jump and sprint normally.
## meant to be set by the object this component belongs to.
## usually this is set to false because the player/NPC ran out of stamina,
## and is set to true because they have enough.
## State determining Variable!
## This Variable lets the component have two condition: A normal and a reduced one. 
## This is because in games usually we have a stamina reserve that is used to perform movement,
## and without enough stamina for example sprinting isn't possible. This is implemented by this 
## variable, set it to "false" when stamina is depleted.
## CAN be set on tick/on process, but doesn't have to be
var is_normal_movement_possible : bool = true:
	set(new_value):
		if new_value == is_normal_movement_possible:
			is_normal_movement_possible = new_value
		else:
			is_normal_movement_possible = new_value
			determine_state()

## State determining Variable!
## Is set by the jump() and knockback() function, and the _physics_process() function, with their respective situations.
## Shall show what kind of movement is currently active, and why. One can argue that this is an unnecessary doubling of the state, but it works.
var movement_position: BasicRpgGeneral.MovementPosition = BasicRpgGeneral.MovementPosition.MP_IN_AIR_FROM_FALLING:
	set(new_value):
		movement_position = new_value
		determine_state()

## State determining Variable!
## This is set by the object that is using this component. Will tell this component that it wants to sprint by setting it to true.
## The state won't change to sprinting though if is_normal_movement_possible is false. 
var wants_to_sprint: bool = false:
	set(new_value):
		if new_value != wants_to_sprint:
			wants_to_sprint = new_value
			determine_state()
			pass
		else:
			wants_to_sprint = new_value
			
## State determining Variable!
## This is set by the object that is using this component. Will tell this component that it wants to jump by setting this variable to true.
## Will only be performed as a normal jump then if is_normal_movement_possible is true
var wants_to_jump: bool = false:
	set(new_value):
		if new_value != wants_to_jump:
			wants_to_jump = new_value
			determine_state()
		else:
			wants_to_jump = new_value

## Will be set by the class using the component. This will determine the direction the component will let the instance move.
## Used by the move() function.
## State determining Variable!
var movement_direction: Vector2 = Vector2.ZERO:
	set(new_value):
		if new_value == movement_direction:
			movement_direction = new_value	
		else:
			movement_direction = new_value
			determine_state()


#endregion State determining Variables



#region Variables


## Is simply mirroring body.is_on_floor(), and is set every frame, but will, in its setter, make sure that is_just_landed and has_just_left_ground are true in their respective situations, and are only true for one single frame.
var is_body_on_floor: bool = false:
	set(new_value):
		if new_value != is_body_on_floor:
			if new_value == true:
				is_just_landed = true
			else:
				has_just_left_ground = true
			is_body_on_floor = new_value
		else:
			is_body_on_floor = new_value
			is_just_landed = false
			has_just_left_ground = false

## is calculated from is_on_floor_frame_counter. This variable is only true on the first frame when body.is_on_floor() returns true.
## used to make sure that after jumping the jump charges don't get immediately replenished because the game thinks that the body is still on the floor because of the still low distance to it on the immediate next frame.
var is_just_landed := false:
	set(new_value):
		is_just_landed = new_value
		
## Used to determine the is in air state.
var has_just_left_ground := false:
	set(new_value):
			has_just_left_ground = new_value


@export_category("Jump Parameters")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity_local = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var jump_strength: float = 6.0

## How many times the player can jump consequently. "2" is a double jump. "1" is a single jump
@export var max_jump_charges: int = 2
var jump_charges = 2

## which multiplier is applied to the jump strength when a weak jump is performed
@export var weak_jump_strength_multiplier: float = 0.25

## how good can the player navigate while in air
## 0.0 = none
## 1.0 = like on the ground
@export var movement_strength_while_jumping: float =  0.0

@export_category("Movement Parameters")

@export var mouse_sensitivity := 1.0
@export var movement_speed := 3.0

var movement_acceleration := 1000.0

## The multiplier applied to the regular movement speed when sprinting
@export var sprint_multiplier: float = 1.75


#endregion Variables

#region Builtin Functions

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	
	is_body_on_floor = body.is_on_floor()
	
	if is_just_landed:
		movement_position = BasicRpgGeneral.MovementPosition.MP_ON_SURFACE
		jump_charges = max_jump_charges
		determine_state()
		
	if has_just_left_ground:
		
		# If the movement position wasn't set by jump() or knockback(), obviously you're falling
		if movement_position == BasicRpgGeneral.MovementPosition.MP_ON_SURFACE:
			movement_position = BasicRpgGeneral.MovementPosition.MP_IN_AIR_FROM_FALLING
	
	if not is_body_on_floor:

		body.velocity.y -= gravity_local * delta
	
	body.move_and_slide()
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if body.is_on_wall_only():
		body.get_wall_normal()
		# print("From Movement Component: Is on Wall only!")
	
	if wants_to_jump:
		jump()
	
	move(delta)	


	
#endregion Builtin Functions

#region Core Functions

## This method causes the character to jump.
## Adds a Y value to the velocity.
func jump() -> void:
	
	wants_to_jump = false
	
	match current_state:
		BasicRpgGeneral.PlayerMovementStates.ON_FLOOR_IDLE:
			perform_jump(jump_strength)
		BasicRpgGeneral.PlayerMovementStates.ON_FLOOR_MOVEMENT_NORMAL:
			perform_jump(jump_strength)
		BasicRpgGeneral.PlayerMovementStates.ON_FLOOR_MOVEMENT_SPRINTING:
			perform_jump(jump_strength)
		BasicRpgGeneral.PlayerMovementStates.IN_AIR_FROM_JUMP:
			perform_jump(jump_strength)
		BasicRpgGeneral.PlayerMovementStates.IN_AIR_FROM_KNOCKBACK:
			# Can't jump in the air when knocked back, even if the player has jump charges.
			pass
		BasicRpgGeneral.PlayerMovementStates.IN_AIR_FROM_FALLING:
			perform_jump(jump_strength)
	
## causes the camera to rotate. Will clamp the looking up/down within reasonable values
func look(look_up: float, look_right: float) -> void:
	
	# print("Rotate camera! Up: " + str(look_up) + ", right: " + str(look_right))
	
	camera.rotation.x += (look_up * -1.0 * mouse_sensitivity * 0.01)
	camera.rotation.x  = clampf(camera.rotation.x, -1.5, 1.5)
	camera.rotation.y += (look_right * -1.0 * mouse_sensitivity * 0.01)
	
	pass

## causes the player to walk. This function will take in an input vector provided 
## by the _input function and rotate the provided vector, so that the movement 
## direction will face in the direction the camera is rotated to.
## it behaves differently when in the air. Movement possibilities are determined 
## by the "movement_strength_while_jumping"-variable 
func move(delta: float) -> void:
	
	var movement_speed_local = movement_speed

	# first determine the rotation of the movement vector
	# it shall point towards the direction the camera is facing
	var y_rotation = camera.rotation.y
	
	var direction_local: Vector3 = Vector3(movement_direction.x, 0.0, movement_direction.y)
	
	direction_local = direction_local.rotated(Vector3.UP, y_rotation)
	
	# make velocity local, to interpolate it afterwards to implement the movement strength in the air
	var velocity_local = body.velocity
	
	match current_state:
		
		#movement on the floor:
		BasicRpgGeneral.PlayerMovementStates.ON_FLOOR_IDLE:
			# here it can just use "move toward" directily on the velocity
			body.velocity.x = move_toward(body.velocity.x, direction_local.x * movement_speed_local, movement_acceleration * delta)
			body.velocity.z = move_toward(body.velocity.z, direction_local.z * movement_speed_local, movement_acceleration * delta)
	
		BasicRpgGeneral.PlayerMovementStates.ON_FLOOR_MOVEMENT_NORMAL:
			# here it can just use "move toward" directily on the velocity
			body.velocity.x = move_toward(body.velocity.x, direction_local.x * movement_speed_local, movement_acceleration * delta)
			body.velocity.z = move_toward(body.velocity.z, direction_local.z * movement_speed_local, movement_acceleration * delta)
	
		BasicRpgGeneral.PlayerMovementStates.ON_FLOOR_MOVEMENT_SPRINTING:
			# here it can just use "move toward" directily on the velocity
			body.velocity.x = move_toward(body.velocity.x, direction_local.x * movement_speed_local * sprint_multiplier, movement_acceleration * delta)
			body.velocity.z = move_toward(body.velocity.z, direction_local.z * movement_speed_local * sprint_multiplier, movement_acceleration * delta)
			
		BasicRpgGeneral.PlayerMovementStates.IN_AIR_FROM_JUMP:
			# then use "move toward" to move the player
			velocity_local.x = move_toward(body.velocity.x, direction_local.x * movement_strength_while_jumping * movement_speed_local, movement_acceleration * delta)
			velocity_local.z = move_toward(body.velocity.z, direction_local.z * movement_strength_while_jumping * movement_speed_local, movement_acceleration * delta)
		
			# here it has to interpolate, because we're in the air
			body.velocity = lerp(body.velocity, velocity_local, movement_strength_while_jumping)	
		BasicRpgGeneral.PlayerMovementStates.IN_AIR_FROM_KNOCKBACK:
			pass
		BasicRpgGeneral.PlayerMovementStates.IN_AIR_FROM_FALLING:
			# then use "move toward" to move the player
			velocity_local.x = move_toward(body.velocity.x, direction_local.x * movement_strength_while_jumping * movement_speed_local, movement_acceleration * delta)
			velocity_local.z = move_toward(body.velocity.z, direction_local.z * movement_strength_while_jumping * movement_speed_local, movement_acceleration * delta)
		
			# here it has to interpolate, because we're in the air
			body.velocity = lerp(body.velocity, velocity_local, movement_strength_while_jumping)	
	
## knocks the thing in the provided direction. 
## currently independent from the state.
func knockback(direction: Vector3, directional_strength: float, in_jump_strength: float) -> void:
	
	match current_state:
		BasicRpgGeneral.PlayerMovementStates.ON_FLOOR_IDLE:
			perform_knockback(direction, directional_strength, in_jump_strength)
		BasicRpgGeneral.PlayerMovementStates.ON_FLOOR_MOVEMENT_NORMAL:
			perform_knockback(direction, directional_strength, in_jump_strength)
		BasicRpgGeneral.PlayerMovementStates.ON_FLOOR_MOVEMENT_SPRINTING:
			perform_knockback(direction, directional_strength, in_jump_strength)
		BasicRpgGeneral.PlayerMovementStates.IN_AIR_FROM_JUMP:
			perform_knockback(direction, directional_strength, in_jump_strength)
		BasicRpgGeneral.PlayerMovementStates.IN_AIR_FROM_KNOCKBACK:
			perform_knockback(direction, directional_strength, in_jump_strength)
		BasicRpgGeneral.PlayerMovementStates.IN_AIR_FROM_FALLING:
			perform_knockback(direction, directional_strength, in_jump_strength)
	
	

#endregion Core Functions


#region helper functions

## may or may not be called by the jump() function, depending on the state.
func perform_jump(in_jump_strength: float):
	
	if jump_charges > 0:
		
		# If normal movement is possible (aka the creature component has enough stamina), then perform a full jump.
		# If it is not, perform a weak jump.
		if is_normal_movement_possible:
			# Jump! 
			body.velocity.y += in_jump_strength 
			# jump_charges minus one
			jump_charges -= 1
			# Change State!
			movement_position = BasicRpgGeneral.MovementPosition.MP_IN_AIR_FROM_JUMP
			
		else:
			# Jump! 
			body.velocity.y += in_jump_strength * weak_jump_strength_multiplier
			# jump_charges minus one
			jump_charges -= 1
			# Change State!
			movement_position = BasicRpgGeneral.MovementPosition.MP_IN_AIR_FROM_JUMP
			


func perform_knockback(direction: Vector3, directional_strength: float, jump_strength: float):
	
	movement_position = BasicRpgGeneral.MovementPosition.MP_IN_AIR_FROM_KNOCKBACK
	body.velocity.y += jump_strength 

	var direction_planar = Vector3(direction.x, 0.0, direction.z)
	direction_planar = direction_planar.normalized()

	body.velocity += direction_planar * directional_strength
	
	movement_position = BasicRpgGeneral.MovementPosition.MP_IN_AIR_FROM_KNOCKBACK
	
	pass

## determines the current state, depending on the state determining variables (See the region or the comment with that name).
## See the region (and comment) "State determining variable"
func determine_state():
		
	match movement_position:
			
		BasicRpgGeneral.MovementPosition.MP_ON_SURFACE:
				
			if wants_to_sprint and is_normal_movement_possible and movement_direction.length() > 0.01:
				
				current_state = BasicRpgGeneral.PlayerMovementStates.ON_FLOOR_MOVEMENT_SPRINTING
			
			elif movement_direction.length() > 0.05:
				
				# if the character is just moving: NORMAL MOVEMENT
				current_state = BasicRpgGeneral.PlayerMovementStates.ON_FLOOR_MOVEMENT_NORMAL
				# else: IDLE
			else:
				
				current_state = BasicRpgGeneral.PlayerMovementStates.ON_FLOOR_IDLE
			
		BasicRpgGeneral.MovementPosition.MP_IN_AIR_FROM_KNOCKBACK:
			
			current_state = BasicRpgGeneral.PlayerMovementStates.IN_AIR_FROM_KNOCKBACK
		
				
		BasicRpgGeneral.MovementPosition.MP_IN_AIR_FROM_JUMP:
				
			current_state = BasicRpgGeneral.PlayerMovementStates.IN_AIR_FROM_JUMP
			
				
		BasicRpgGeneral.MovementPosition.MP_IN_AIR_FROM_FALLING:
			
			current_state = BasicRpgGeneral.PlayerMovementStates.IN_AIR_FROM_FALLING

#endregion helper funtions

#region Signal Callback Functions

	
#endregion Signal Callback Functions
