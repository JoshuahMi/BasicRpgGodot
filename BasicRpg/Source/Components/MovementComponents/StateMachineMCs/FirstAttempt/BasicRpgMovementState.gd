@abstract
class_name BasicRpgMovementState extends RefCounted

var state_machine: BasicRpgMovementStateMachine = null
var body: CharacterBody3D = null

# -----------------------------------------------------------------------------
@abstract
func enter()

@abstract
func exit()

@abstract
func update()

@abstract
func physics_update()
	
