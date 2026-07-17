# Copyright 2026 Joshuah Skyseed, all rights reserved  
class_name BasicRpgMovementStateDash extends BasicRpgMovementState


var current_dash_time: float 
var dash_direction: Vector3



func enter():
	
	if (state_machine.is_on_ground and state_machine.can_dash_on_ground == false) or (state_machine.is_on_ground and state_machine.can_dash == false):
		transition()
	else:
		state_machine.dash_charges -= 1
	
	state_machine.can_dash = false
	
	if state_machine.is_on_ground:
	
		current_dash_time = state_machine.ground_dash_length
		
	else:
		current_dash_time = state_machine.air_dash_length
	determine_direction()
	



func exit():
	# Adds this state to the history, so that the next state can look up
	# where it came from.
	state_machine.history.add_state(BasicRpgMovementStateMachine.States.DASH)
	
	body.velocity = body.velocity.limit_length(state_machine.movement_speed * state_machine.sprint_multiplier)

func update(delta: float):
	pass


func physics_update(delta: float):
	
	if state_machine.is_on_ground:
	
		body.velocity = dash_direction * state_machine.ground_dash_speed
	
	else:
		body.velocity = dash_direction * state_machine.air_dash_speed
	current_dash_time -= delta
	
	if current_dash_time < 0.0:
		transition()
	
	pass


func transition():
	
	if state_machine.is_on_ground:
		if state_machine.movement_direction.length_squared() > 0.01:
			transitioned.emit(BasicRpgMovementStateMachine.States.DASH, BasicRpgMovementStateMachine.States.GO)

		else:
			transitioned.emit(BasicRpgMovementStateMachine.States.DASH, BasicRpgMovementStateMachine.States.IDLE)
	else:
		if 	body.is_on_wall_only():
			transitioned.emit(BasicRpgMovementStateMachine.States.DASH, BasicRpgMovementStateMachine.States.WALL)

		else:
			transitioned.emit(BasicRpgMovementStateMachine.States.DASH, BasicRpgMovementStateMachine.States.AIR)

func determine_direction():
	var y_rotation = camera.rotation.y
	
	var movement_direction_local = Vector3.FORWARD
	
	var direction_local := movement_direction_local.rotated(Vector3.UP, y_rotation)
	
	dash_direction = direction_local
	
	pass
	
func happening_management():
	
	if body.is_on_wall_only():
		transition()
	
	pass
