# Copyright 2026 Joshuah Skyseed, all rights reserved  

class_name BasicRpgMovementStateAir extends BasicRpgMovementState

var current_coyote_time = -1.0
var has_coyote_timer_run_out: bool = false

func enter():
	
	
	has_coyote_timer_run_out = false
	
	if state_machine.history.get_state_before() == BasicRpgMovementStateMachine.States.GO or state_machine.history.get_state_before() == BasicRpgMovementStateMachine.States.IDLE:
		current_coyote_time = state_machine.coyote_time
		
	else:
		current_coyote_time = -1.0
		has_coyote_timer_run_out = true
	
	pass


func exit():
	
	# Adds this state to the history, so that the next state can look up
	# where it came from.
	state_machine.history.add_state(BasicRpgMovementStateMachine.States.AIR)
	current_coyote_time = state_machine.coyote_time
	pass


func update(delta: float):
	pass


func physics_update(delta: float):
	
	current_coyote_time -= delta
	
	if (state_machine.history.get_state_before() == BasicRpgMovementStateMachine.States.GO or state_machine.history.get_state_before() == BasicRpgMovementStateMachine.States.IDLE):
		if current_coyote_time < 0.0 and not has_coyote_timer_run_out:
			state_machine.jump_charges -= 1
			has_coyote_timer_run_out = true
	
	happening_management()
	input_management()
	
	apply_gravity(delta)
	
	pass
	
func apply_gravity(delta: float):
	
	body.velocity += body.get_gravity() * delta * state_machine.fall_gravity_multiplier
	
	pass
	
func happening_management():
	
	if state_machine.has_just_landed and state_machine.movement_direction.length_squared() > 0.01:
		transitioned.emit(BasicRpgMovementStateMachine.States.AIR, BasicRpgMovementStateMachine.States.GO)
	elif state_machine.has_just_landed and state_machine.movement_direction.length_squared() < 0.01:
		transitioned.emit(BasicRpgMovementStateMachine.States.AIR, BasicRpgMovementStateMachine.States.IDLE)

	pass
	
func input_management():
	
	if (state_machine.history.get_state_before() == BasicRpgMovementStateMachine.States.GO or state_machine.history.get_state_before() == BasicRpgMovementStateMachine.States.IDLE) and state_machine.wants_to_jump and current_coyote_time > 0.0:
		transitioned.emit(BasicRpgMovementStateMachine.States.AIR, BasicRpgMovementStateMachine.States.JUMP)
	
	if state_machine.wants_to_jump and state_machine.jump_charges > 0:
		transitioned.emit(BasicRpgMovementStateMachine.States.AIR, BasicRpgMovementStateMachine.States.JUMP)
	
	pass
