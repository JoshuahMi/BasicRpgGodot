# Copyright 2026 Joshuah Skyseed, all rights reserved  

class_name BasicRpgMovementStateJump extends BasicRpgMovementState
func enter():
	
	state_machine.jump_charges -= 1
	
	body.velocity.y = 0.0
	
	body.velocity += Vector3.UP * state_machine.jump_strength * 100.0
	
	print("From Movement State Jump: State Entered!")
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
	
	pass

func apply_gravity(delta: float):
	
	body.velocity.y += body.get_gravity().y * delta
	
	pass

## Handles things that happen, e.g. that the y velocity goes under a certain
## value, that the player touches a wall, etc.
func happening_management():
	
	if body.velocity.y < 0.0:
		transitioned.emit(BasicRpgMovementStateMachine.States.JUMP, BasicRpgMovementStateMachine.States.AIR)
	
	pass

func input_management():
	
	if state_machine.wants_to_dash:
		transitioned.emit(BasicRpgMovementStateMachine.States.JUMP, BasicRpgMovementStateMachine.States.DASH)
		
	if state_machine.wants_to_jump:
		pass
		
	if state_machine.movement_direction.length_squared() > 0.001:
		move()
		
func move():
	
	
	
	pass
