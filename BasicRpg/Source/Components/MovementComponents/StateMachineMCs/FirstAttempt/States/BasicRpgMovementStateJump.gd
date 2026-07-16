# Copyright 2026 Joshuah Skyseed, all rights reserved  

class_name BasicRpgMovementStateJump extends BasicRpgMovementState
func enter():
	
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
		## then use "move toward" to move the player
		#
		#if state_machine.wants_to_sprint:
			#velocity_local.x = move_toward(body.velocity.x, direction_local.x * movement_speed_local * state_machine.sprint_multiplier, state_machine.movement_acceleration * 1000.0 * delta * state_machine.movement_strength_while_jumping * 0.2)
			#velocity_local.z = move_toward(body.velocity.z, direction_local.z * movement_speed_local * state_machine.sprint_multiplier, state_machine.movement_acceleration * 1000.0 * delta * state_machine.movement_strength_while_jumping * 0.2)
		#
		#else:
			#velocity_local.x = move_toward(body.velocity.x, direction_local.x * movement_speed_local, state_machine.movement_acceleration * 1000.0 * delta * state_machine.movement_strength_while_jumping * 0.2)
			#velocity_local.z = move_toward(body.velocity.z, direction_local.z * movement_speed_local, state_machine.movement_acceleration * 1000.0 * delta * state_machine.movement_strength_while_jumping * 0.2)
		#
		## here it has to interpolate, because we're in the air
		#body.velocity = lerp(velocity_original, velocity_local, state_machine.movement_strength_while_jumping * 0.2)
		## body.velocity = velocity_local
		modify_velocity(delta)
	else:
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
		body.velocity = lerp(velocity_original, Vector3(velocity_local.x, velocity_original.y, velocity_local.z), state_machine.movement_strength_while_jumping * 10.0)
		# body.velocity = velocity_local
	pass
