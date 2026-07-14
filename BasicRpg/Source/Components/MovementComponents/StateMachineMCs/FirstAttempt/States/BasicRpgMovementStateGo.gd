# Copyright 2026 Joshuah Skyseed, all rights reserved  

class_name BasicRpgMovementStateGo extends BasicRpgMovementState

func enter():
	
	print("From Movement State Go: State entered!")
	
	pass


func exit():
	pass


func update(delta: float):
	pass


func physics_update(delta: float):
	
	move(delta)
	
	input_management()
	
	pass

func move(delta: float):
	
	var movement_speed_local: float
	if state_machine.wants_to_sprint:
		movement_speed_local = state_machine.movement_speed * state_machine.sprint_multiplier
	else:
		movement_speed_local = state_machine.movement_speed

	# first determine the rotation of the movement vector
	# it shall point towards the direction the camera is facing
	var y_rotation = camera.rotation.y
	
	var movement_direction_local = Vector3(state_machine.movement_direction.x, 0.0, state_machine.movement_direction.y)
	
	var direction_local = movement_direction_local.rotated(Vector3.UP, y_rotation)
	
	# make velocity local, to interpolate it afterwards to implement the movement strength in the air
	# var velocity_local = body.velocity
	
	# here it can just use "move toward" directily on the velocity
	body.velocity.x = move_toward(body.velocity.x, direction_local.x * movement_speed_local, state_machine.MOVEMENT_ACCELERATION * delta)
	body.velocity.z = move_toward(body.velocity.z, direction_local.z * movement_speed_local, state_machine.MOVEMENT_ACCELERATION * delta)
	# print("From Movement Component: velocity: " + str(body.velocity))
	

func input_management():
	
	
	
	if state_machine.wants_to_dash:
		transitioned.emit(BasicRpgMovementStateMachine.States.GO, BasicRpgMovementStateMachine.States.DASH)
		
	if state_machine.wants_to_jump:
		transitioned.emit(BasicRpgMovementStateMachine.States.GO, BasicRpgMovementStateMachine.States.JUMP)
		
	if state_machine.movement_direction.length_squared() < 0.001:
		print("Moved!")
		transitioned.emit(BasicRpgMovementStateMachine.States.GO, BasicRpgMovementStateMachine.States.IDLE)
		
	pass
