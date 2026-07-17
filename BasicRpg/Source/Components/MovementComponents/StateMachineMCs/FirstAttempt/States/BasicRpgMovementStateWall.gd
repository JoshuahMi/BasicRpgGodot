# Copyright 2026 Joshuah Skyseed, all rights reserved  

class_name BasicRpgMovementStateWall extends BasicRpgMovementState
func enter():
	
	body.velocity.y *= 0.3
	
	state_machine.wall_run_momentum = body.velocity
	
	pass


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
		wall_normal = collision.get_normal()
	else:
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
	
	if state_machine.wants_to_jump:
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
