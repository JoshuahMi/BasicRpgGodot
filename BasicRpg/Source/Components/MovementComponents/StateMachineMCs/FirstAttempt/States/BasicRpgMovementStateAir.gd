# Copyright 2026 Joshuah Skyseed, all rights reserved  

class_name BasicRpgMovementStateAir extends BasicRpgMovementState

var current_coyote_time = -1.0
var has_coyote_timer_run_out: bool = false

var original_velocity_from_enter_state: Vector3
var original_direction: Vector3
var original_speed: float

func enter():
	
	original_velocity_from_enter_state = body.velocity
	original_direction = Vector3(body.velocity.x, 0.0, body.velocity.z).normalized()
	original_speed = Vector3(body.velocity.x, 0.0, body.velocity.z).length()
	
	has_coyote_timer_run_out = false
	
	if state_machine.history.get_state_before() == BasicRpgMovementStateMachine.States.GO or state_machine.history.get_state_before() == BasicRpgMovementStateMachine.States.IDLE:
		current_coyote_time = state_machine.coyote_time
		
	else:
		current_coyote_time = -1.0
		has_coyote_timer_run_out = true
	
	pass


func exit():
	
	# Adds this state to the history, so that the next state can look up
	# where it came from.
	state_machine.history.add_state(BasicRpgMovementStateMachine.States.AIR)
	current_coyote_time = state_machine.coyote_time
	pass


func update(delta: float):
	pass


func physics_update(delta: float):
	
	current_coyote_time -= delta
	
	if (state_machine.history.get_state_before() == BasicRpgMovementStateMachine.States.GO or state_machine.history.get_state_before() == BasicRpgMovementStateMachine.States.IDLE):
		if current_coyote_time < 0.0 and not has_coyote_timer_run_out:
			state_machine.jump_charges -= 1
			has_coyote_timer_run_out = true
	
	happening_management()
	input_management()
	
	apply_gravity(delta)
	
	move(delta)
	
	pass
	
func apply_gravity(delta: float):
	
	body.velocity += body.get_gravity() * delta * state_machine.fall_gravity_multiplier
	
	pass
	
func happening_management():
	
	if state_machine.is_on_ground and state_machine.movement_direction.length_squared() > 0.01:
		transitioned.emit(BasicRpgMovementStateMachine.States.AIR, BasicRpgMovementStateMachine.States.GO)
	elif state_machine.is_on_ground and state_machine.movement_direction.length_squared() < 0.01:
		transitioned.emit(BasicRpgMovementStateMachine.States.AIR, BasicRpgMovementStateMachine.States.IDLE)

	pass
	
func input_management():
	
	if (state_machine.history.get_state_before() == BasicRpgMovementStateMachine.States.GO or state_machine.history.get_state_before() == BasicRpgMovementStateMachine.States.IDLE) and state_machine.wants_to_jump and current_coyote_time > 0.0:
		transitioned.emit(BasicRpgMovementStateMachine.States.AIR, BasicRpgMovementStateMachine.States.JUMP)
	
	if state_machine.wants_to_jump and state_machine.jump_charges > 0:
		transitioned.emit(BasicRpgMovementStateMachine.States.AIR, BasicRpgMovementStateMachine.States.JUMP)
	
	
	if state_machine.wants_to_dash and state_machine.dash_charges > 0:
		transitioned.emit(BasicRpgMovementStateMachine.States.AIR, BasicRpgMovementStateMachine.States.DASH)
	
	
	pass

func move(delta: float):
	
	if state_machine.movement_direction.length_squared() > 0.01:
		modify_velocity(delta)
	else:
		pass
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
		if state_machine.history.get_state_before_the_last() == BasicRpgMovementStateMachine.States.GO and state_machine.history.get_state_before() == BasicRpgMovementStateMachine.States.JUMP:
			
			original_direction = original_direction.normalized()
			
			var correction: float = state_machine.BASIC_RPG_JUMPING_MOVEMENT.sample(original_direction.dot(Vector3(direction_local.x, 0.0, direction_local.z).normalized()) * 0.5 + 0.5)
			
			var corrected_velocity: Vector3 = lerp(altered_velocity, Vector3(original_velocity_from_enter_state.x, original_velocity_in_this_iteration.y, original_velocity_from_enter_state.z),  correction)
			
			
			
			body.velocity = corrected_velocity
		
		else:
			body.velocity = altered_velocity

	pass
