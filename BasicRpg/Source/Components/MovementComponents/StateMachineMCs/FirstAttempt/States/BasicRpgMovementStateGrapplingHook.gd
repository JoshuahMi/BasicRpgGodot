class_name BasicRpgMovementStateGrapplingHook extends BasicRpgMovementState


func enter():
	
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
	
	input_management()
	
	pass

func happening_management():
	
	pass

func input_management():
	
	# We can alter the distance to the point we hang on.
	
	
	if state_machine.wants_to_return_grappling_hook:
		print("From Grappling Hook state: Wants tu return grappling hook!")
		state_machine.grappling_hook.return_to_player()
		transitioned.emit(BasicRpgMovementStateMachine.States.GRAPPLING_HOOK, BasicRpgMovementStateMachine.States.GO)
		pass
	
	
	pass
