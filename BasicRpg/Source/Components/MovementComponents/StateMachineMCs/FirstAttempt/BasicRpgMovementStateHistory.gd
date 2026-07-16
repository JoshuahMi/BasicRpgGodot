class_name BasicRpgMovementStateHistory extends RefCounted

## A class for saving the states the movement state machine went through.

## Will store up to 3 states.
var history: Array[BasicRpgMovementStateMachine.States] = []

## Will add a state to the array, pushing all the states one place back.
func add_state(state: BasicRpgMovementStateMachine.States):
	
	history.push_front(state)
	
	if history.size() > 3:
		history.resize(3)

## Will return the state that was added before the current state was entered.
func get_state_before() -> BasicRpgMovementStateMachine.States:
	
	if history.size() > 0:
		return history[0]
	else:
		return BasicRpgMovementStateMachine.States.NULL
	
