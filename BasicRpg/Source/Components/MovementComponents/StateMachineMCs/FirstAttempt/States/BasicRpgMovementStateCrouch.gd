# Copyright 2026 Joshuah Skyseed, all rights reserved  

class_name BasicRpgMovementStateCrouch extends BasicRpgMovementState

func enter():
	pass


func exit():
	
	# Adds this state to the history, so that the next state can look up
	# where it came from.
	state_machine.history.add_state(BasicRpgMovementStateMachine.States.CROUCH)
	
	pass


func update(delta: float):
	pass


func physics_update(delta: float):
	pass
	
func move():
	
	pass
	
func input_management():
	
	pass
	
func happening_management():
	
	pass
	
func transition():
	
	pass
