# Copyright 2026 Joshuah Skyseed, all rights reserved  

extends Control

var state_machine: BasicRpgMovementStateMachine
var input_component: BasicRpgInputComponent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	update_last_state_label(state_machine.history.get_state_before())
	update_state_label(state_machine.current_state)
	update_movement_speed_label(   Vector3(state_machine.body.velocity.x, 0.0, state_machine.body.velocity.z).length())
	update_y_speed_label(state_machine.body.velocity.y)
	%JumpMomentumLabel.text = str(state_machine.jump_momentum)
	%JumpedFromRunningLabel.text = str(state_machine.is_jump_from_moving)
	%MovedWhileJumpingLabel.text = str(state_machine.has_moved_while_jumping)
	update_jump_charges_label(state_machine.jump_charges)
	%DashChargesLabel.text = str(state_machine.dash_charges)
	%CanDashLabel.text = str(state_machine.can_dash)
	%DashCooldownLabel.text = str(roundf(state_machine.ground_dash_cooldown_status))
	update_wants_to_jump_label(input_component.jump_window)
	
	pass

func update_wants_to_jump_label(in_value: bool):
	%WantsToJumpLabel.text = str(in_value)
	pass

func update_jump_charges_label(in_value: int):
	
	%JumpChargesLabel.text = str(in_value)
	

func update_movement_speed_label(in_value: float):
	
	in_value = roundf(in_value)
	
	
	%MovementSpeedLabel.text = str(in_value)
	
func update_y_speed_label(in_value: float):
	in_value = roundf(in_value)
	%MovementSpeedLabel2.text = str(in_value)
	pass

func update_last_state_label(state: BasicRpgMovementStateMachine.States):
	
	match state:
		
		BasicRpgMovementStateMachine.States.NULL:
			
			%LastMovementStateLabel.text = "NULL"
		
		BasicRpgMovementStateMachine.States.IDLE:
			
			%LastMovementStateLabel.text = "Idle"
			
		BasicRpgMovementStateMachine.States.GO:
			
			%LastMovementStateLabel.text = "Go"

		BasicRpgMovementStateMachine.States.DASH:
			
			%LastMovementStateLabel.text = "Dash"

		BasicRpgMovementStateMachine.States.JUMP:
			
			%LastMovementStateLabel.text = "Jump"

		BasicRpgMovementStateMachine.States.WALL:
			
			%LastMovementStateLabel.text = "Wall"

		BasicRpgMovementStateMachine.States.AIR:
			
			%LastMovementStateLabel.text = "Air"
			
		BasicRpgMovementStateMachine.States.KNOCKBACK:
			%LastMovementStateLabel.text = "Knockback"
			
		BasicRpgMovementStateMachine.States.SLIDE:
			%LastMovementStateLabel.text = "Slide"

		BasicRpgMovementStateMachine.States.CLIMB:
			
			%LastMovementStateLabel.text = "Climb"

		BasicRpgMovementStateMachine.States.LEDGE_GRAB:
			
			%LastMovementStateLabel.text = "Ledge Grab"
			
		BasicRpgMovementStateMachine.States.SWIM:
			
			%LastMovementStateLabel.text = "Swim"
		
		BasicRpgMovementStateMachine.States.DIVE:
			
			%LastMovementStateLabel.text = "Dive"

func update_state_label(state: BasicRpgMovementStateMachine.States):
	
	match state:
		
		BasicRpgMovementStateMachine.States.NULL:
			
			%CurrentMovementStateLabel.text = "NULL"
		
		BasicRpgMovementStateMachine.States.IDLE:
			
			%CurrentMovementStateLabel.text = "Idle"
			
		BasicRpgMovementStateMachine.States.GO:
			
			%CurrentMovementStateLabel.text = "Go"

		BasicRpgMovementStateMachine.States.DASH:
			
			%CurrentMovementStateLabel.text = "Dash"

		BasicRpgMovementStateMachine.States.JUMP:
			
			%CurrentMovementStateLabel.text = "Jump"

		BasicRpgMovementStateMachine.States.WALL:
			
			%CurrentMovementStateLabel.text = "Wall"

		BasicRpgMovementStateMachine.States.AIR:
			
			%CurrentMovementStateLabel.text = "Air"
			
		BasicRpgMovementStateMachine.States.KNOCKBACK:
			%CurrentMovementStateLabel.text = "Knockback"
			
		BasicRpgMovementStateMachine.States.SLIDE:
			%CurrentMovementStateLabel.text = "Slide"

		BasicRpgMovementStateMachine.States.CLIMB:
			
			%CurrentMovementStateLabel.text = "Climb"

		BasicRpgMovementStateMachine.States.LEDGE_GRAB:
			
			%CurrentMovementStateLabel.text = "Ledge Grab"
			
		BasicRpgMovementStateMachine.States.SWIM:
			
			%CurrentMovementStateLabel.text = "Swim"
		
		BasicRpgMovementStateMachine.States.DIVE:
			
			%CurrentMovementStateLabel.text = "Dive"

	
	
	pass
