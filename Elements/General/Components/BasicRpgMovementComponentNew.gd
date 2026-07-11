# Copyright 2026 Joshuah Skyseed, all rights reserved  


class_name BasicRpgMovementComponentNew extends Node

# For the prototype I will just focus on the states and the functionality of the core functions.
# 


# TODO:
# climb
# ledge grab
# I think I will make the climb first, because obviously it includes going 
# at the top of the climbable over a ledge.




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

var movement_place_state: BasicRpgGeneral.MovementPlaceState = BasicRpgGeneral.MovementPlaceState.GROUND:
	set(new_value):
		
		movement_place_state = new_value
		match new_value:
			BasicRpgGeneral.MovementPlaceState.GROUND:
				#print("Is on Ground!")
				pass
			BasicRpgGeneral.MovementPlaceState.AIR:
				#print("Is in Air!")
				pass
			BasicRpgGeneral.MovementPlaceState.WALL:
				body.velocity.y = body.velocity.y * 0.1
				#print("Is on a Wall!")
				pass
			BasicRpgGeneral.MovementPlaceState.SWIMMING:
				#print("Is swimming!")
				pass
			BasicRpgGeneral.MovementPlaceState.UNDERWATER:
				#print("Is underwater!")
				pass
var movement_effort_state: BasicRpgGeneral.MovementEffortState = BasicRpgGeneral.MovementEffortState.IDLE

#endregion STATE

#region SIGNALS

#endregion SIGNALS

#region VARIABLES

# JUMP

## When jumping, the velocity will be stored in this variable, to interpolate between it and the movement direction.
var recorded_velocity: Vector3 = Vector3.ZERO


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity_local = ProjectSettings.get_setting("physics/3d/default_gravity")

var has_just_left_ground := false:
	set(new_value):
		has_just_left_ground = new_value
		if new_value == true:
			movement_place_state = BasicRpgGeneral.MovementPlaceState.AIR
			#print("From Movement Component: Has just left the ground!")
	
var has_just_landed := false:
	set(new_value):
		has_just_landed = new_value
		if new_value == true:
			movement_place_state = BasicRpgGeneral.MovementPlaceState.GROUND
			#print("From Movement Component: Has just landed!")

var is_body_on_floor: bool = false:
	set(new_value):
		if new_value != is_body_on_floor:
			if new_value == true:
				has_just_landed = true
			else:
				has_just_left_ground = true
			is_body_on_floor = new_value
		else:
			is_body_on_floor = new_value
			has_just_landed = false
			has_just_left_ground = false
	

var has_just_touched_wall: bool = false:
	set(new_value):
		has_just_touched_wall = new_value
		if is_wall_jump_possible != true:
			return
		if new_value == true:
			movement_place_state = BasicRpgGeneral.MovementPlaceState.WALL
			var collision: KinematicCollision3D = body.get_last_slide_collision()
			if collision != null:
				collision.get_position()
				wall_normal = collision.get_normal()
			else:
				wall_normal = body.get_wall_normal()

var has_just_left_wall: bool = false:
	set(new_value):
		has_just_left_wall = new_value
		if new_value == true:
			#print("From Movement Component: Has just left a wall!")
			if is_body_on_floor == false:
				movement_place_state = BasicRpgGeneral.MovementPlaceState.AIR
			else:
				movement_place_state = BasicRpgGeneral.MovementPlaceState.GROUND
				
var is_body_on_wall: bool = false:
	set(new_value):
		#print(new_value)
		if new_value != is_body_on_wall:
			if new_value == true:
				has_just_touched_wall = true
			else:
				has_just_left_wall = true
			is_body_on_wall = new_value
		else:
			is_body_on_wall = new_value
			has_just_touched_wall = false
			has_just_left_wall = false


var wall_normal: Vector3 = Vector3.RIGHT




#endregion VARIABLES

#region PARAMETER



@export_category("General Movement")

const MOVEMENT_ACCELERATION: float = 1000.0

@export var movement_speed: float = 3.0

## The multiplier applied to the regular movement speed when sprinting
@export var sprint_multiplier: float = 2.0

@export var dash_strength: float = 20.0

@export var mouse_sensitivity: float = 1.0

@export_category("Jump")

@export var jump_strength: float = 6.0

## how good can the player navigate while in air
## 0.0 = none
## 1.0 = like on the ground
@export var movement_strength_while_jumping := 0.4

## This constant is used to correct the value of movement strength while jumping,
## since it only works between 0.0 and 0.2. 
const MOVEMENT_STRENGTH_WHILE_JUMPING_CORRECTOR := 0.2

@export_category("Wall run")

## If the wall run is possible. If true, wall jump is possible too.
## Wall run/jump is automatically active when a player doesn't touch the ground, but touches a wall,
## as long as this variable stays true. Set it to false on demand to implement a wall run on push of a button
@export var is_wall_run_possible: bool = true:
	set(new_value):
		is_wall_run_possible = new_value
		if new_value == true:
			is_wall_jump_possible = true

## If the wall jump is possible. Can be true while wall run is not possible.
## Then the player isn't able to move while on a wall. Gravity will slowly pull them towards the ground.
## They have to jump away from the wall, or sink to the ground.
## Wall jump is automatically active when a player doesn't touch the ground, but touches a wall,
## as long as this variable stays true. Set it to false on demand to implement a wall jump on push of a button
@export var is_wall_jump_possible: bool = true

## The multiplier that is applied to the gravity strength when on a wall.
## Does nothing at 1.0
@export var wall_gravity_multiplier: float = 0.1

## How much the movement speed is increased when on a wall.
## Does nothing at 1.0
@export var wall_speed_multiplier: float = 3.0

## When jumping from a wall, this variable is applied to the UP vector.
## Does nothing at 1.0
@export var wall_jump_y_multiplier: float = 1.0


## When jumping from the wall, this variable tells how strong the player will be kicked into the walls normal direction.
## Does nothing at 1.0
@export var wall_jump_normal_multiplier: float = 1.2

#endregion PARAMETER

#region BUILTIN FUNCTIONS

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	determine_initial_state()
	
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	
	apply_gravity(delta)
	
	is_body_on_floor = body.is_on_floor()
	is_body_on_wall = body.is_on_wall_only()
		
	match movement_place_state:
		BasicRpgGeneral.MovementPlaceState.GROUND:
			move(delta)
			body.move_and_slide()
		BasicRpgGeneral.MovementPlaceState.AIR:
			move(delta)
			body.move_and_slide()
		BasicRpgGeneral.MovementPlaceState.WALL:
			#body.apply_floor_snap()
			#body.floor_block_on_wall = true
			body.floor_snap_length
			body.floor_stop_on_slope
			move(delta)
			body.move_and_slide()
			
		BasicRpgGeneral.MovementPlaceState.SWIMMING:
			move(delta)
			body.move_and_slide()
		BasicRpgGeneral.MovementPlaceState.UNDERWATER:
			move(delta)
			body.move_and_slide()
	

	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	
	pass
	
#endregion BUILTIN FUNCTIONS

#region CORE FUNCTIONS

# The core functions basically determine the behaviour of the mirroring "perform" functions.
# Judging from the state there may be slight differences in behaviour.
# So the core functions look up the state and define the behaviour of their wrapped functions.

func look(look_up: float, look_right: float):
	perform_look(look_up, look_right)
	
func move(delta: float):
	var movement_speed_evaluated: float
	if wants_to_sprint == true:
		movement_speed_evaluated = movement_speed * sprint_multiplier
	else:
		movement_speed_evaluated = movement_speed
	
	
	match movement_place_state:
		BasicRpgGeneral.MovementPlaceState.GROUND:
			
			var direction_local: Vector3 = Vector3(movement_direction.x, 0.0, movement_direction.y)
			perform_move(direction_local, delta)
			
			pass
		BasicRpgGeneral.MovementPlaceState.AIR:
			
			var movement_speed_local = movement_speed_evaluated
			# make velocity local, to interpolate it afterwards to implement the movement strength in the air
			var velocity_local = body.velocity
			
			var direction_local: Vector3 = Vector3(movement_direction.x, 0.0, movement_direction.y)
			# first determine the rotation of the movement vector
			# it shall point towards the direction the camera is facing
			var y_rotation = camera.rotation.y
			direction_local = direction_local.rotated(Vector3.UP, y_rotation)
			
			var velocity_original = body.velocity
			
			# then use "move toward" to move the player
			velocity_local.x = move_toward(body.velocity.x, direction_local.x * movement_speed_local, MOVEMENT_ACCELERATION * delta * movement_strength_while_jumping * MOVEMENT_STRENGTH_WHILE_JUMPING_CORRECTOR)
			velocity_local.z = move_toward(body.velocity.z, direction_local.z * movement_speed_local, MOVEMENT_ACCELERATION * delta * movement_strength_while_jumping * MOVEMENT_STRENGTH_WHILE_JUMPING_CORRECTOR)
			# here it has to interpolate, because we're in the air
			body.velocity = lerp(velocity_original, velocity_local, movement_strength_while_jumping * MOVEMENT_STRENGTH_WHILE_JUMPING_CORRECTOR)
			# body.velocity = velocity_local
			
			
		BasicRpgGeneral.MovementPlaceState.WALL:
			
			if is_wall_jump_possible and not is_wall_run_possible:
				
				var stick_strength = 5.0
				
				var stick_direction: Vector3 = Vector3(wall_normal.x, 0.0, wall_normal.z)
				
				var direction_local: Vector3 = (stick_direction * -1.0).normalized()
				
				body.velocity.x = move_toward(body.velocity.x, direction_local.x * stick_strength, MOVEMENT_ACCELERATION * delta)
				body.velocity.z = move_toward(body.velocity.z, direction_local.z * stick_strength, MOVEMENT_ACCELERATION * delta)
				
				pass
			if is_wall_run_possible:
				var stick_direction = Vector3(wall_normal.x, 0.0, wall_normal.z)
				# var direction_local: Vector3 = Vector3(movement_direction.x, 0.0, movement_direction.y)
				var direction_local: Vector3 = Vector3(0.0, 0.0, movement_direction.y)
				var movement_speed_local = movement_speed_evaluated * wall_speed_multiplier
				#print(wall_normal)
				
				# first determine the rotation of the movement vector
				# it shall point towards the direction the camera is facing
				var y_rotation = camera.rotation.y
				direction_local = direction_local.rotated(Vector3.UP, y_rotation)
				
				var wall_direction: Vector3 = stick_direction.rotated(Vector3.UP, -90.0)
				
				if direction_local.dot(wall_direction) < 0.01:
					wall_direction = stick_direction.rotated(Vector3.UP, 90.0)
				
				# print(wall_direction)
				
				if direction_local.length_squared() > 0.01:
					direction_local = wall_direction
				else:
					direction_local = Vector3.ZERO
					
				direction_local = (direction_local.normalized() + stick_direction * -1.0).normalized()
				
				body.velocity.x = move_toward(body.velocity.x, direction_local.x * movement_speed_local, MOVEMENT_ACCELERATION * delta)
				body.velocity.z = move_toward(body.velocity.z, direction_local.z * movement_speed_local, MOVEMENT_ACCELERATION * delta)
			#print(body.velocity)
			
			pass
		BasicRpgGeneral.MovementPlaceState.SWIMMING:
			pass
		BasicRpgGeneral.MovementPlaceState.UNDERWATER:
			pass
		
	
	
	pass
	
func jump():
	
	
	match movement_place_state:
		BasicRpgGeneral.MovementPlaceState.GROUND:
			perform_jump(Vector3.UP, jump_strength)
			pass
		BasicRpgGeneral.MovementPlaceState.AIR:
			perform_jump(Vector3.UP, jump_strength)
			pass
		BasicRpgGeneral.MovementPlaceState.WALL:
			
			# Actually this if-statement is not necessary, because we won't get
			# into that state if is wall jump possible is false
			
			if is_wall_jump_possible and not is_wall_run_possible:
				movement_place_state = BasicRpgGeneral.MovementPlaceState.AIR
				perform_jump(Vector3.UP * wall_jump_y_multiplier + wall_normal * wall_jump_normal_multiplier, jump_strength)
				
			else:
				movement_place_state = BasicRpgGeneral.MovementPlaceState.AIR
				perform_jump(Vector3.UP * wall_jump_y_multiplier + wall_normal * wall_jump_normal_multiplier + Vector3.FORWARD.rotated(Vector3.UP, camera.rotation.y), jump_strength)
				
		BasicRpgGeneral.MovementPlaceState.SWIMMING:
			perform_jump(Vector3.UP, jump_strength)
			pass
		BasicRpgGeneral.MovementPlaceState.UNDERWATER:
			perform_jump(Vector3.UP, jump_strength)
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
	
func perform_move(in_movement_direction: Vector3, delta: float):
	
	var movement_speed_local: float
	if wants_to_sprint:
		movement_speed_local = movement_speed * sprint_multiplier
	else:
		movement_speed_local = movement_speed

	# first determine the rotation of the movement vector
	# it shall point towards the direction the camera is facing
	var y_rotation = camera.rotation.y
	
	var direction_local = in_movement_direction.rotated(Vector3.UP, y_rotation)
	
	# make velocity local, to interpolate it afterwards to implement the movement strength in the air
	# var velocity_local = body.velocity
	
	# here it can just use "move toward" directily on the velocity
	body.velocity.x = move_toward(body.velocity.x, direction_local.x * movement_speed_local, MOVEMENT_ACCELERATION * delta)
	body.velocity.z = move_toward(body.velocity.z, direction_local.z * movement_speed_local, MOVEMENT_ACCELERATION * delta)
	# print("From Movement Component: velocity: " + str(body.velocity))
	
	pass
	
func perform_jump(in_jump_direction: Vector3, in_jump_strength: float):
	
	
	body.velocity += in_jump_direction * in_jump_strength 
	recorded_velocity = body.velocity
	
	pass

func perform_dash():
	if movement_strength_while_jumping == 1.0:
		var direction: Vector3 = Vector3.FORWARD.rotated(Vector3.UP, camera.rotation.y)
			
		body.velocity += direction.normalized() * dash_strength
	else:
		var direction: Vector3 = Vector3.FORWARD.rotated(Vector3.UP, camera.rotation.y)
			
		body.velocity += direction.normalized() * dash_strength * 0.15


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
			# print("From Movement Component: Apply gravity! Gravity: " + str(gravity_local * delta))
			pass
		BasicRpgGeneral.MovementPlaceState.WALL:
			
			# At first, don't apply gravity. Then over time, add more and more, until the applied gravity matches gravity_local.
			body.velocity.y -= gravity_local * wall_gravity_multiplier * delta
			
			pass
		BasicRpgGeneral.MovementPlaceState.SWIMMING:
			# Don't apply gravity
			pass
		BasicRpgGeneral.MovementPlaceState.UNDERWATER:
			# Don't apply gravity
			pass


func determine_initial_state():
	
	if body.is_on_floor():
		movement_place_state = BasicRpgGeneral.MovementPlaceState.GROUND
	else:
		movement_place_state = BasicRpgGeneral.MovementPlaceState.AIR



#endregion HELPER FUNCTIONS
