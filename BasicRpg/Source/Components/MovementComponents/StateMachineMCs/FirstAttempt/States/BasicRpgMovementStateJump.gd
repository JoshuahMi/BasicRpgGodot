# Copyright 2026 Joshuah Skyseed, all rights reserved  

class_name BasicRpgMovementStateJump extends BasicRpgMovementState

var original_velocity_from_enter_state: Vector3
var original_direction: Vector3
var original_speed: float


func enter():
	
	if state_machine.is_jump_from_moving == true:
		state_machine.jump_momentum = body.velocity
	original_velocity_from_enter_state = body.velocity
	original_direction = Vector3(body.velocity.x, 0.0, body.velocity.z)
	original_speed = Vector3(body.velocity.x, 0.0, body.velocity.z).length()
	
	state_machine.jump_charges -= 1
	
	body.velocity.y = 0.0
	
	body.velocity += Vector3.UP * state_machine.jump_strength
	
	pass


func exit():
	
	# Adds this state to the history, so that the next state can look up
	# where it came from.
	state_machine.history.add_state(BasicRpgMovementStateMachine.States.JUMP)
	
	pass


func update(delta: float):
	pass


func physics_update(delta: float):
	
	happening_management()
	input_management()
	
	apply_gravity(delta)
	
	move(delta)
	
	pass

func apply_gravity(delta: float):
	
	body.velocity.y += body.get_gravity().y * delta * state_machine.jump_gravity_multiplier
	
	pass

## Handles things that happen, e.g. that the y velocity goes under a certain
## value, that the player touches a wall, etc.
func happening_management():
	
	if body.velocity.y < 0.0:
		transitioned.emit(BasicRpgMovementStateMachine.States.JUMP, BasicRpgMovementStateMachine.States.AIR)
	
	if body.is_on_wall_only() and state_machine.is_jump_from_moving:
		transitioned.emit(BasicRpgMovementStateMachine.States.JUMP, BasicRpgMovementStateMachine.States.WALL)
	
	pass

func input_management():
	
	if state_machine.wants_to_dash and state_machine.dash_charges > 0:
		transitioned.emit(BasicRpgMovementStateMachine.States.JUMP, BasicRpgMovementStateMachine.States.DASH)
		
	if state_machine.wants_to_jump:
		pass
		
	#if state_machine.movement_direction.length_squared() > 0.001:
		#move(delta)
		
func move(delta: float):
	
	if state_machine.movement_direction.length_squared() > 0.01:
		modify_velocity(delta)
	else:
		pass
			
	
func modify_velocity(delta: float):
	
	if state_machine.movement_direction.length_squared() > 0.01:
	
		var movement_speed_local = state_machine.movement_speed
		
		var new_velocity = body.velocity
		var original_velocity_in_this_iteration = body.velocity
				
		var direction_local: Vector3 = Vector3(state_machine.movement_direction.x, 0.0, state_machine.movement_direction.y)
		# first determine the rotation of the movement vector
		# it shall point towards the direction the camera is facing
		var y_rotation = camera.rotation.y
		direction_local = direction_local.rotated(Vector3.UP, y_rotation)
		
		
		
				
		if state_machine.wants_to_sprint:
			
			new_velocity = lerp(body.velocity, direction_local * movement_speed_local * state_machine.sprint_multiplier, delta)
		
		else:
			
			new_velocity = lerp(body.velocity, direction_local * movement_speed_local, delta)
		
		# This is the original output, applied on the body velocity.
		# The velocity has been altered by the movement of the player, IF it is possible to navigate mid air
		var altered_velocity : Vector3 = lerp(original_velocity_in_this_iteration, Vector3(new_velocity.x, original_velocity_in_this_iteration.y, new_velocity.z), state_machine.movement_strength_while_jumping * 10.0)
		
		
		# If the jump was from a running/walking motion, correct it in the sense that IF it is possible to navigate in the air, 
		# the momentum shall not be broken because the player releases the W key.
		if state_machine.is_jump_from_moving == true and not state_machine.has_moved_while_jumping:
			
			original_direction = original_direction.normalized()
			
			var correction: float = state_machine.BASIC_RPG_JUMPING_MOVEMENT.sample(original_direction.dot(Vector3(direction_local.x, 0.0, direction_local.z).normalized()) * 0.5 + 0.5)
			
			# The momentum is broken when the player significantly moves mid air
			if correction < 0.5:
				state_machine.has_moved_while_jumping = true
			
			var corrected_velocity: Vector3 = lerp(altered_velocity, Vector3(state_machine.jump_momentum.x, original_velocity_in_this_iteration.y, state_machine.jump_momentum.z),  correction)
			
			
			
			body.velocity = corrected_velocity
		
		else:
			body.velocity = altered_velocity
