class_name BasicRpgMovementStateMachine extends Node

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
