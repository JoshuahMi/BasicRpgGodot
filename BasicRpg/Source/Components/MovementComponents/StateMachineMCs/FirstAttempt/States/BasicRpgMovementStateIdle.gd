# Copyright 2026 Joshuah Skyseed, all rights reserved  

class_name BasicRpgMovementStateIdle extends BasicRpgMovementState


func enter():
	
	print("From Movement State Idle: Idle state entered!")
	
	pass


func exit():
	
	print("From Movement State Idle: Idle state exited!")
	
	pass


func update(delta: float):
	pass


func physics_update(delta: float):
	
	applies(delta)
	
	happening_management()
	
	input_management()
	
	
	
## Here everything happens what being idle means. 
func applies(delta: float):
	
	
	
	var movement_deceleration_clamped = clampf(state_machine.movement_deceleration_when_idle * delta, 0.0, 1.0)
	
	body.velocity.x = lerp(body.velocity.x, 0.0, movement_deceleration_clamped)
	body.velocity.z = lerp(body.velocity.z, 0.0, movement_deceleration_clamped)
	
	pass
	
## Handles things that happen, e.g. that the y velocity goes under a certain
## value, that the player touches a wall, etc.
func happening_management():
	
	if state_machine.has_just_left_ground:
		
		transitioned.emit(BasicRpgMovementStateMachine.States.GO, BasicRpgMovementStateMachine.States.AIR)
		
	pass
	
func input_management():
	
	
	
	if state_machine.wants_to_dash:
		transitioned.emit(BasicRpgMovementStateMachine.States.IDLE, BasicRpgMovementStateMachine.States.DASH)
		
	if state_machine.wants_to_jump:
		transitioned.emit(BasicRpgMovementStateMachine.States.IDLE, BasicRpgMovementStateMachine.States.JUMP)
		
	if state_machine.movement_direction.length_squared() > 0.001:
		print("Moved!")
		transitioned.emit(BasicRpgMovementStateMachine.States.IDLE, BasicRpgMovementStateMachine.States.GO)
		

	
	
	pass
