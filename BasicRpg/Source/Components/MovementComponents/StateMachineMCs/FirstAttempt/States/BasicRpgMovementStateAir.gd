# Copyright 2026 Joshuah Skyseed, all rights reserved  

class_name BasicRpgMovementStateAir extends BasicRpgMovementState
func enter():
	print("From Movement State Air: State entered!")
	pass


func exit():
	pass


func update(delta: float):
	pass


func physics_update(delta: float):
	
	happening_management()
	input_management()
	
	apply_gravity(delta)
	
	pass
	
func apply_gravity(delta: float):
	
	body.velocity += body.get_gravity() * delta
	
	pass
	
func happening_management():
	
	if state_machine.has_just_landed and state_machine.movement_direction.length_squared() > 0.01:
		transitioned.emit(BasicRpgMovementStateMachine.States.AIR, BasicRpgMovementStateMachine.States.GO)
	elif state_machine.has_just_landed and state_machine.movement_direction.length_squared() < 0.01:
		transitioned.emit(BasicRpgMovementStateMachine.States.AIR, BasicRpgMovementStateMachine.States.IDLE)

	pass
	
func input_management():
	
	pass
