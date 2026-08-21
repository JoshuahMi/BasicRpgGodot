class_name BasicRpgMovementStateGrapplingHook extends BasicRpgMovementState


var distance_to_hook: float

func enter():
	
	distance_to_hook = state_machine.body.global_position.distance_to(state_machine.grappling_hook.global_position)
	
	# We need this point as a basis, obviously.
	state_machine.edge_detector.detected_platform_point
	state_machine.edge_detector.is_detected_point_valid
	
	pass

func exit():
	
	# Adds this state to the history, so that the next state can look up
	# where it came from.
	state_machine.history.add_state(BasicRpgMovementStateMachine.States.GRAPPLING_HOOK)

	pass
	
func update(delta: float):
	
	pass
	
func physics_update(delta: float):
	
	apply_gravity(delta)
	limit_distance_to_hook()
	
	input_management()
	happening_management()
	
	pass

func happening_management():
	
	pass

func input_management():
	
	# We can alter the distance to the point we hang on.
	
	
	if state_machine.wants_to_return_grappling_hook:
		#print("From Grappling Hook state: Wants tu return grappling hook!")
		state_machine.grappling_hook.return_to_player()
		transitioned.emit(BasicRpgMovementStateMachine.States.GRAPPLING_HOOK, BasicRpgMovementStateMachine.States.GO)
		pass
	
	
	pass
	
func apply_gravity(delta: float):
	if body.velocity.y >= 0.0:
		body.velocity += body.get_gravity() * delta * state_machine.jump_gravity_multiplier
	else:
		body.velocity += body.get_gravity() * delta * state_machine.fall_gravity_multiplier
	
	
func limit_distance_to_hook():
	
	if state_machine.grappling_hook.global_position.distance_to(state_machine.camera.global_position) > distance_to_hook:
		# Correct the distance by rotating the velocity vector, so that the distance to the hook stays the same.
		
		var direction: Vector3 = body.global_position - state_machine.grappling_hook.global_position
		
		direction =  direction.limit_length(distance_to_hook)
		
		body.global_position = state_machine.grappling_hook.global_position + direction
		
		
	
