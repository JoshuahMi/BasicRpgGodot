# Copyright 2026 Joshuah Skyseed, all rights reserved  

class_name BasicRpgMovementStateAir extends BasicRpgMovementState

var current_coyote_time = -1.0
var has_coyote_timer_run_out: bool = false

func enter():
	
	
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
	
		#var movement_speed_local = state_machine.movement_speed
		## make velocity local, to interpolate it afterwards to implement the movement strength in the air
		#var velocity_local = body.velocity
				#
		#var direction_local: Vector3 = Vector3(state_machine.movement_direction.x, 0.0, state_machine.movement_direction.y)
		## first determine the rotation of the movement vector
		## it shall point towards the direction the camera is facing
		#var y_rotation = camera.rotation.y
		#direction_local = direction_local.rotated(Vector3.UP, y_rotation)
				#
		#var velocity_original = body.velocity
				#
		#if state_machine.wants_to_sprint:
			#
			#velocity_local.x = move_toward(body.velocity.x, direction_local.x * movement_speed_local * state_machine.sprint_multiplier, state_machine.movement_acceleration * 1000.0 * delta * state_machine.movement_strength_while_jumping * 0.2)
			#velocity_local.z = move_toward(body.velocity.z, direction_local.z * movement_speed_local * state_machine.sprint_multiplier, state_machine.movement_acceleration * 1000.0 * delta * state_machine.movement_strength_while_jumping * 0.2)
		#
		#else:
			#velocity_local.x = move_toward(body.velocity.x, direction_local.x * movement_speed_local, state_machine.movement_acceleration * 1000.0 * delta * state_machine.movement_strength_while_jumping * 0.2)
			#velocity_local.z = move_toward(body.velocity.z, direction_local.z * movement_speed_local, state_machine.movement_acceleration * 1000.0 * delta * state_machine.movement_strength_while_jumping * 0.2)
		## here it has to interpolate, because we're in the air
		#body.velocity = lerp(velocity_original, velocity_local, state_machine.movement_strength_while_air * 0.2)
		## body.velocity = velocity_local
			
		modify_velocity(delta)
	else:
		pass
	pass
	
func modify_velocity(delta: float):
	
	if state_machine.movement_direction.length_squared() > 0.01:
	
		var movement_speed_local = state_machine.movement_speed
		# make velocity local, to interpolate it afterwards to implement the movement strength in the air
		var velocity_local = body.velocity
				
		var direction_local: Vector3 = Vector3(state_machine.movement_direction.x, 0.0, state_machine.movement_direction.y)
		# first determine the rotation of the movement vector
		# it shall point towards the direction the camera is facing
		var y_rotation = camera.rotation.y
		direction_local = direction_local.rotated(Vector3.UP, y_rotation)
				
		var velocity_original = body.velocity
				
		if state_machine.wants_to_sprint:
			
			velocity_local = lerp(body.velocity, direction_local * movement_speed_local * state_machine.sprint_multiplier, delta)
			
			#velocity_local.x = move_toward(body.velocity.x, direction_local.x * movement_speed_local * state_machine.sprint_multiplier, state_machine.movement_acceleration * 1000.0 * delta * state_machine.movement_strength_while_jumping * 0.2)
			#velocity_local.z = move_toward(body.velocity.z, direction_local.z * movement_speed_local * state_machine.sprint_multiplier, state_machine.movement_acceleration * 1000.0 * delta * state_machine.movement_strength_while_jumping * 0.2)
		
		else:
			
			velocity_local = lerp(body.velocity, direction_local * movement_speed_local, delta)
			
			#velocity_local.x = move_toward(body.velocity.x, direction_local.x * movement_speed_local, state_machine.movement_acceleration * 1000.0 * delta * state_machine.movement_strength_while_jumping * 0.2)
			#velocity_local.z = move_toward(body.velocity.z, direction_local.z * movement_speed_local, state_machine.movement_acceleration * 1000.0 * delta * state_machine.movement_strength_while_jumping * 0.2)
		# here it has to interpolate, because we're in the air
		body.velocity = lerp(velocity_original, Vector3(velocity_local.x, velocity_original.y, velocity_local.z), state_machine.movement_strength_while_air * 10.0)
		# body.velocity = velocity_local
	pass
