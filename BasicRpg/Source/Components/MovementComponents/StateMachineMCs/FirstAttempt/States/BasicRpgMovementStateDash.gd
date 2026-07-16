# Copyright 2026 Joshuah Skyseed, all rights reserved  
class_name BasicRpgMovementStateDash extends BasicRpgMovementState


var current_dash_time: float 
var dash_direction: Vector3



func enter():
	
	state_machine.dash_charges -= 1
	
	current_dash_time = state_machine.air_dash_length
	determine_direction()
	
	
	pass


func exit():
	# Adds this state to the history, so that the next state can look up
	# where it came from.
	state_machine.history.add_state(BasicRpgMovementStateMachine.States.DASH)
	
	body.velocity = body.velocity.limit_length(state_machine.movement_speed * state_machine.sprint_multiplier)

func update(delta: float):
	pass


func physics_update(delta: float):
	
	body.velocity = dash_direction * state_machine.air_dash_speed
	
	current_dash_time -= delta
	
	if current_dash_time < 0.0:
		if state_machine.is_on_ground:
			if state_machine.movement_direction.length_squared() > 0.01:
				transitioned.emit(BasicRpgMovementStateMachine.States.DASH, BasicRpgMovementStateMachine.States.GO)

			else:
				transitioned.emit(BasicRpgMovementStateMachine.States.DASH, BasicRpgMovementStateMachine.States.IDLE)

		else:
				
			transitioned.emit(BasicRpgMovementStateMachine.States.DASH, BasicRpgMovementStateMachine.States.AIR)
	
	pass


func determine_direction():
	var y_rotation = camera.rotation.y
	
	var movement_direction_local = Vector3.FORWARD
	
	var direction_local := movement_direction_local.rotated(Vector3.UP, y_rotation)
	
	dash_direction = direction_local
	
	pass
