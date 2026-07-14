# Copyright 2026 Joshuah Skyseed, all rights reserved  

class_name BasicRpgMovementStateJump extends BasicRpgMovementState
func enter():
	print("From Movement State Jump: State Entered!")
	pass


func exit():
	pass


func update(delta: float):
	pass


func physics_update(delta: float):
	pass

func apply_gravity():
	pass

## Handles things that happen, e.g. that the y velocity goes under a certain
## value, that the player touches a wall, etc.
func happening_management():
	
	pass

func input_management():
	
	
	
	if state_machine.wants_to_dash:
		transitioned.emit(BasicRpgMovementStateMachine.States.JUMP, BasicRpgMovementStateMachine.States.DASH)
		
	if state_machine.wants_to_jump:
		transitioned.emit(BasicRpgMovementStateMachine.States.JUMP, BasicRpgMovementStateMachine.States.JUMP)
		
	if state_machine.movement_direction.length_squared() > 0.001:
		transitioned.emit(BasicRpgMovementStateMachine.States.JUMP, BasicRpgMovementStateMachine.States.GO)

	
	pass
