extends CharacterBody3D
@onready var input_component: BasicRpgInputComponent = $BasicRpgInputComponent
@onready var movement_component: BasicRpgMovementStateMachine = $BasicRpgMovementStateMachine
@onready var hud: Control = $BasicRpgTestHud


func _ready() -> void:
	
	hud.state_machine = movement_component
	hud.input_component = input_component
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	movement_component.state_changed.connect(_on_state_changed)

func _physics_process(delta: float) -> void:
	
	if input_component.is_test_just_pressed:
		movement_component.wants_to_dash = true
	else:
		movement_component.wants_to_dash = false
	
	if input_component.jump_window:
		movement_component.wants_to_jump = true
	else:
		movement_component.wants_to_jump = false
		
	if input_component.is_sprint_pressed:
		movement_component.wants_to_sprint = true
	else:
		movement_component.wants_to_sprint = false
	
	movement_component.movement_direction = input_component.movement_direction
	movement_component.look_direction = input_component.look_vector
	
	
func _on_state_changed(new_state):
	
	pass
