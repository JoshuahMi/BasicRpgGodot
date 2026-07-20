# Copyright 2026 Joshuah Skyseed, all rights reserved  


class_name BasicRpgMovementStateWall extends BasicRpgMovementState

const ANTI_CHEESING_POSITION_LENGTH: float = 20.0

func enter():
	
	
	
	if state_machine.is_wall_run_possible == false:
		transition()
		return
	
	# if it's the same wall you came from, transition
	state_machine.current_wall_run_cheese_cooldown = state_machine.wall_run_cheese_cooldown
	var collision: KinematicCollision3D = body.get_last_slide_collision()
	if collision != null:
		
		
		#if state_machine.current_wall_run_cheese_cooldown > 0.0 and state_machine.wall_normal == collision.get_normal() and state_machine.wall_run_last_collider == collision.get_collider_shape() and state_machine.has_wall_run_before:
		if (Vector3(collision.get_position().x, 0.0, collision.get_position().z) - state_machine.wall_touch_position).length_squared() < ANTI_CHEESING_POSITION_LENGTH and state_machine.has_wall_run_before:

			#print("From Movement State Wall: Was on the same Wall!")
			
			transition()
			return
			
	else:
		if state_machine.current_wall_run_cheese_cooldown > 0.0 and state_machine.wall_normal == body.get_wall_normal() and state_machine.has_wall_run_before:
			#print("From Movement State Wall: Was on the same Wall!")
			transition()
			return
		
	
	state_machine.wall_touch_position = Vector3(body.position.x, 0.0, body.position.z)
	
	
	state_machine.has_wall_run_before = true
	
	if state_machine.jump_charges < 1:
		state_machine.jump_charges = 1
		
	body.velocity.y *= 0.2
		
	#state_machine.wall_run_momentum = body.velocity
	
	

func exit():
	# Adds this state to the history, so that the next state can look up
	# where it came from.
	state_machine.history.add_state(BasicRpgMovementStateMachine.States.WALL)


func update(delta: float):
	pass


func physics_update(delta: float):
	
	stick(delta)
	move(delta)
	apply_gravity(delta)
	input_management()
	happening_management()
	pass
	
	
func stick(delta: float):
	
	var wall_normal: Vector3
	
	var collision: KinematicCollision3D = body.get_last_slide_collision()
	if collision != null:
		collision.get_position()
		
		state_machine.wall_normal = collision.get_normal()
		
		wall_normal = collision.get_normal()
	else:
		
		state_machine.wall_normal = body.get_wall_normal()
		
		wall_normal = body.get_wall_normal()
	
	var stick_strength = 5.0
				
	var stick_direction: Vector3 = Vector3(wall_normal.x, 0.0, wall_normal.z)
				
	var direction_local: Vector3 = (stick_direction * -1.0).normalized()
				
	body.velocity.x = move_toward(body.velocity.x, direction_local.x * stick_strength, delta)
	body.velocity.z = move_toward(body.velocity.z, direction_local.z * stick_strength, delta)
	
	pass
	
func move(delta: float):
	
	pass
	
func apply_gravity(delta: float):
	
	body.velocity += body.get_gravity() * delta * state_machine.wall_gravity_multiplier
	
	pass
	
func input_management():
	
	if state_machine.wants_to_jump and state_machine.jump_charges > 0:
		transitioned.emit(BasicRpgMovementStateMachine.States.WALL, BasicRpgMovementStateMachine.States.JUMP)
	
	pass
	
func happening_management():
	
	if not body.is_on_wall_only():
		transitioned.emit(BasicRpgMovementStateMachine.States.WALL, BasicRpgMovementStateMachine.States.AIR)
	
	
	if body.is_on_floor() and state_machine.movement_direction.length_squared() > 0.01:
		transitioned.emit(BasicRpgMovementStateMachine.States.WALL, BasicRpgMovementStateMachine.States.GO)
	elif body.is_on_floor():
		transitioned.emit(BasicRpgMovementStateMachine.States.WALL, BasicRpgMovementStateMachine.States.IDLE)
	pass

func transition():
	
	if body.is_on_floor():
				
		if state_machine.movement_direction.length_squared() > 0.01:
				
			transitioned.emit(BasicRpgMovementStateMachine.States.WALL, BasicRpgMovementStateMachine.States.GO)
				
		else:
					
			transitioned.emit(BasicRpgMovementStateMachine.States.WALL, BasicRpgMovementStateMachine.States.IDLE)

				
	else:
		transitioned.emit(BasicRpgMovementStateMachine.States.WALL, BasicRpgMovementStateMachine.States.AIR)
	
	
	
	
