# Copyright 2026 Joshuah Skyseed, all rights reserved  

extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_state_label(state: BasicRpgMovementStateMachine.States):
	
	match state:
		BasicRpgMovementStateMachine.States.IDLE:
			
			%MovementStateLabel.text = "Idle"
			
		BasicRpgMovementStateMachine.States.GO:
			
			%MovementStateLabel.text = "Go"

		BasicRpgMovementStateMachine.States.DASH:
			
			%MovementStateLabel.text = "Dash"

		BasicRpgMovementStateMachine.States.JUMP:
			
			%MovementStateLabel.text = "Jump"

		BasicRpgMovementStateMachine.States.WALL:
			
			%MovementStateLabel.text = "Wall"

		BasicRpgMovementStateMachine.States.AIR:
			
			%MovementStateLabel.text = "Air"
			
		BasicRpgMovementStateMachine.States.KNOCKBACK:
			%MovementStateLabel.text = "Knockback"
			
		BasicRpgMovementStateMachine.States.SLIDE:
			%MovementStateLabel.text = "Slide"

		BasicRpgMovementStateMachine.States.CLIMB:
			
			%MovementStateLabel.text = "Climb"

		BasicRpgMovementStateMachine.States.LEDGE_GRAB:
			
			%MovementStateLabel.text = "Ledge Grab"

	
	
	pass
