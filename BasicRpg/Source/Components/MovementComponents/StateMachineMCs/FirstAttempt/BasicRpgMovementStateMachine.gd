class_name BasicRpgMovementStateMachine extends Node

@export var body: CharacterBody3D = null

var jump_charges: int = 2
var dash_charges: int = 2

var is_normal_movement_possible: bool = true

var current_state: BasicRpgMovementState

var movement_direction: Vector2

var has_just_moved: bool = false
var has_just_stopped: bool = false

var has_just_left_ground: bool = false
var has_just_landed: bool = false

var wants_to_jump: bool = false
var wants_to_sprint: bool = false
var wants_to_dash: bool = false

enum States {
	
	IDLE,
	WALK,
	SPRINT,
	DASH,
	JUMP,
	AIR,
	WALL,
	KNOCKBACK,
	
}

#region STATES

var states: Dictionary = {}


#endregion STATES





# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if body == null:
		return 
	
	await body.ready
	
	states[States.IDLE] = BasicRpgMovementStateIdle.new()
	states[States.IDLE].body = body
	states[States.IDLE].state_machine = self
	
	states[States.WALK]
	states[States.SPRINT]
	states[States.DASH]
	states[States.JUMP]
	states[States.AIR]
	states[States.WALL]
	states[States.KNOCKBACK]
	
	
	
	
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
